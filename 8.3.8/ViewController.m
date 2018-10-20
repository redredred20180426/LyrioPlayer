#import "ViewController.h"


#import <AVFoundation/AVFoundation.h>
#import "SongsCollectionViewController.h"
#import "LyricsCollectionViewCell.h"
#import "LrcParser.h"

static NSString *const kViewCellReuseIdentifier = @"ViewCellID";

static const NSTimeInterval kTimeUnitInMs = 100;


@interface ViewController ()<UICollectionViewDataSource,
                             UICollectionViewDelegateFlowLayout,
                             UICollectionViewDelegate,
                             SongsCollectionViewControllerDelegate>
@property (nonatomic,strong) UICollectionView *collectionView;

@property (nonatomic) AVAudioPlayer *player;

@property (nonatomic, copy) NSString *fileName;

@property (nonatomic) SongsCollectionViewController *songsCollectionViewController;

@end

@implementation ViewController  {
    NSTimer *_timer;
    LrcParser *_lrcContent;
    NSInteger _currentRow;
    LyricsCollectionViewCell *_measureCell;
    BOOL _isPlayingCurrentRow;
    NSMutableArray<NSNumber *>* _highlightedLines;
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.scrollEnabled = NO;
        _collectionView.backgroundColor = [UIColor blackColor];
    }
    return _collectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _measureCell  = [[LyricsCollectionViewCell alloc] init];
    [self.view addSubview:self.collectionView];
    
    [self initPlayer];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    // 注册header和footer
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader  withReuseIdentifier:@"headerView" ];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter  withReuseIdentifier:@"footerView" ];
    
    // Register cell classes
    [self.collectionView registerClass:[LyricsCollectionViewCell class]
            forCellWithReuseIdentifier:kViewCellReuseIdentifier];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self becomeFirstResponder];
    
    [NSTimer scheduledTimerWithTimeInterval:kTimeUnitInMs / 1000
                                     target:self
                                   selector:@selector(updateTime)
                                   userInfo:nil repeats:YES];
    
    self.view.userInteractionEnabled = YES;
    UISwipeGestureRecognizer *swpipeLeftRecognier =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(handleSwipeLeft:)];
    swpipeLeftRecognier.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swpipeLeftRecognier];
    
    UISwipeGestureRecognizer *swpipeRightRecognier =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(handleSwipeRight:)];
    swpipeRightRecognier.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swpipeRightRecognier];
    
    UISwipeGestureRecognizer *swpipeUpRecognier =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(jumeToNextSentence)];
    swpipeUpRecognier.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swpipeUpRecognier];

    UISwipeGestureRecognizer *swpipeDownRecognier =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(jumeToLastSentence)];
    swpipeDownRecognier.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swpipeDownRecognier];
    
    UITapGestureRecognizer *doubleTapRecognizer =
      [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
    
    doubleTapRecognizer.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapRecognizer];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return _lrcContent.startTimeArray.count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LyricsCollectionViewCell *cell =
    (LyricsCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kViewCellReuseIdentifier
                                                                          forIndexPath:indexPath];
    cell.lyricLine.text = _lrcContent.wordArray[indexPath.row];
    if(indexPath.row== _currentRow) {
        cell.lyricLine.textColor = [UIColor yellowColor];
        cell.lyricLine.font = [UIFont systemFontOfSize:40];
        cell.backgroundColor = [UIColor darkGrayColor];
    }
    else {
        cell.lyricLine.textColor = [UIColor whiteColor];
        cell.lyricLine.font = [UIFont systemFontOfSize:40];
        cell.backgroundColor = [UIColor blackColor];
    }
    
    if ([_highlightedLines containsObject:@(indexPath.row)]) {
        cell.backgroundColor = [UIColor redColor];
    }
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    return cell;
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size
          withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.collectionView reloadData];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    }];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *header = [collectionView
                                            dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                            withReuseIdentifier:@"headerView"
                                            forIndexPath:indexPath];
        header.backgroundColor = [UIColor blackColor];
        reusableView = header;
    } else {
        UICollectionReusableView *footer = [collectionView
                                            dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                            withReuseIdentifier:@"footerView"
                                            forIndexPath:indexPath];
        footer.backgroundColor = [UIColor redColor];
        reusableView = footer;
    }
    return reusableView;
}
//设置单元格的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    _measureCell.lyricLine.text = [_lrcContent.wordArray objectAtIndex:indexPath.row];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGSize size = [_measureCell sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize headerSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 0);
    return headerSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    CGSize footerSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 0);
    return footerSize;
}

- (SongsCollectionViewController *)songsCollectionViewController {
    if (!_songsCollectionViewController) {
        _songsCollectionViewController = [[SongsCollectionViewController alloc] init];
        _songsCollectionViewController.delegate = self;
    }
    return _songsCollectionViewController;
}

#pragma mark - Shake functions

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
  [self switchPausePlay];
  [self.songsCollectionViewController.collectionView reloadData];
  [self presentViewController:self.songsCollectionViewController animated:NO completion:nil];
}

#pragma mark - SongsCollectionViewControllerDelegate

- (void)didSelectSong:(NSString *)song InSongsCollectionViewController:(id)viewController {
  if (song.length) {
    _fileName = song;
    [self initPlayer];
  } else {
    [self switchPausePlay];
  }
  [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Private methods

- (void) initPlayer{
  _lrcContent = [[LrcParser alloc] init];
  [_lrcContent parseLrcNamed:self.fileName];
  if (_lrcContent.startTimeArray.count == 0) {
    return;
  }
    _highlightedLines = [NSMutableArray array];

    AVAudioSession *session=[AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    _player=[[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle]  URLForResource:self.fileName withExtension:@"mp3"] error:nil];
    _player.numberOfLoops=100;
    [_player prepareToPlay];
    [_player play];
    
}

- (void) updateTime{
    CGFloat currentTime=_player.currentTime;
    for (int i=0; i<_lrcContent.startTimeArray.count; i++) {
        NSTimeInterval startTime = [self startTimeAtline:i];
        if(currentTime>startTime){
            _currentRow=i;
        }else
            break;
    }
    [self updateLyrics];
}

- (NSTimeInterval)nextStartPointFromCurrentTime:(NSTimeInterval)currentTime {
    for (int i=0; i<_lrcContent.startTimeArray.count; i++) {
        float lrcStartTime= [self startTimeAtline:i];
        if(currentTime < lrcStartTime){
            return lrcStartTime;
        }else {
            continue;
        }
        
    }
    return 0;
}

- (void)playAtLine:(NSInteger) lineNumber{
    if (lineNumber < 0 || lineNumber >= _lrcContent.startTimeArray.count) {
        return;
    }
    [_player pause];
    _player.currentTime = [self startTimeAtline:lineNumber];
    
    _currentRow = lineNumber;
    [self updateLyrics];
    [_player play];
}

- (void)updateLyrics {
    [self.collectionView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_currentRow inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                        animated:YES];
}


- (NSTimeInterval)startTimeAtline: (NSInteger)lineNumber {
    NSTimeInterval startTime = [[_lrcContent.startTimeArray objectAtIndex:lineNumber] doubleValue] + _lrcContent.offset / 1000;
    return startTime > 0 ? startTime : 0;
}

- (NSTimeInterval)lastStartPointFromCurrentTime:(NSTimeInterval)currentTime {
    float lastStart = 0;
    float lastLastStart = 0;
    for (int i=0; i<_lrcContent.startTimeArray.count; i++) {
        float lrcStartTime= [self startTimeAtline:i];
        if(currentTime < lrcStartTime){
            return lastLastStart;
        }else {
            lastLastStart = lastStart;
            lastStart = lrcStartTime;
        }
        
    }
    return 0;
}

- (NSString *)fileName {
    if (!_fileName) {
        NSInteger count =  self.songsCollectionViewController.songs.count;
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *component = [cal components:NSCalendarUnitDay fromDate:[NSDate date]];
        NSInteger day = component.day;
        NSInteger index = (day - 1) % count + 1;
        _fileName = self.songsCollectionViewController.songs[index];
        self.songsCollectionViewController.currentSongIndex = index;
        
    }
  return _fileName;
}

#pragma mark - remote control

- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)swipeLeft {
    _lrcContent.offset -= kTimeUnitInMs;
}

- (void)handleSwipeRight:(UISwipeGestureRecognizer *)swipeRight {
    _lrcContent.offset += kTimeUnitInMs;
}

- (void)didDoubleTap:(UISwipeGestureRecognizer *)tap {
    [self switchPausePlay];
    NSInteger row = _currentRow;
    if (![_highlightedLines containsObject:@(row)]) {
        [_highlightedLines addObject:@(row)];
    } else {
      [_highlightedLines removeObject:@(row)];
    }
    [self.collectionView reloadData];
}

- (void)switchPausePlay {
    if (_player.isPlaying) {
        [_player pause];
    } else {
        [_player play];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event{
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlNextTrack: {
            [self jumeToNextSentence];
            break;
        }
        case UIEventSubtypeRemoteControlPreviousTrack: {
            [self jumeToLastSentence];
            break;
        }
        case UIEventSubtypeRemoteControlPause: {
            [self switchPausePlay];
            break;
        }
        case UIEventSubtypeRemoteControlPlay: {
            [self switchPausePlay];
            break;
        }
        case UIEventSubtypeRemoteControlStop: {
            [self switchPausePlay];
            break;
        }
        case UIEventSubtypeRemoteControlTogglePlayPause: {
            [self jumeToLastSentence];
            break;
            
        }
        case UIEventSubtypeMotionShake: {
            [self jumeToLastSentence];
            break;
        }
        case UIEventSubtypeRemoteControlEndSeekingForward: {
            
        }
        default:
            break;
    }
}

- (void)jumeToLastSentence {
    NSTimeInterval currentTime = _player.currentTime;
    NSTimeInterval nextTime = [self lastStartPointFromCurrentTime:currentTime];
    [_player pause];
    _player.currentTime = nextTime;
    [_player play];
}

- (void)jumeToNextSentence {
    NSTimeInterval currentTime = _player.currentTime;
    NSTimeInterval nextTime = [self nextStartPointFromCurrentTime:currentTime];
    [_player pause];
    _player.currentTime = nextTime;
    [_player play];
}

@end
