#import "SongsCollectionViewController.h"

#import "LrcParser.h"
#import "SongCollectionViewCell.h"

@interface SongsCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@end

@implementation SongsCollectionViewController {
  SongCollectionViewCell *_measureCell;
}

static NSString * const reuseIdentifier = @"Cell";

- (instancetype)init {
  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  self = [super initWithCollectionViewLayout:layout];
  if (self) {
    _measureCell = [[SongCollectionViewCell alloc] init];
  }
  return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
  self.collectionView.backgroundColor = [UIColor whiteColor];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[SongCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
#warning Incomplete implementation, return the number of sections
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of items
    return self.songs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SongCollectionViewCell *cell = (SongCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
  cell.nameLabel.text = [self.songs objectAtIndex:indexPath.row];
  return cell;
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  _measureCell.nameLabel.text = [self.songs objectAtIndex:indexPath.row];
  return [_measureCell sizeThatFits:CGSizeMake(self.view.frame.size.width, CGFLOAT_MAX)];
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  SongCollectionViewCell *cell = [self collectionView:collectionView cellForItemAtIndexPath:indexPath];
  cell.backgroundColor = [UIColor yellowColor];
  [cell setNeedsLayout];
  [self.delegate didSelectSong:[self.songs objectAtIndex:indexPath.row] InSongsCollectionViewController:self];
}

// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<NSString *>*)songs {
  if (!_songs) {
    _songs = [NSMutableArray array];
  }
  NSString *resourcePath = [[NSBundle mainBundle]  resourcePath];
  NSArray *dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcePath error:nil];
  NSArray <NSString *> *mp3Files = [dirs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH %@", @".mp3"]];
  NSArray <NSString *> *lrcFiles = [dirs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH %@", @".lrc"]];
    mp3Files = [mp3Files sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

  for (NSString *mp3File in mp3Files) {
    NSRange nameRange = NSMakeRange(0, mp3File.length - 4);
    NSString *fileName = [mp3File substringWithRange:nameRange];
    NSString *lrcFileName = [NSString stringWithFormat:@"%@.lrc", fileName];
    if ([lrcFiles containsObject:lrcFileName]) {
      [_songs addObject:fileName];
    }
  }
  return _songs;
}

@end
