//
//  SongsCollectionViewController.h
//  LyrioPlayer
//
//  Created by Julie Zhou on 30/06/2018.
//  Copyright © 2018 Liz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SongsCollectionViewController;

@protocol SongsCollectionViewControllerDelegate

- (void)didSelectSong:(NSString *)song InSongsCollectionViewController: (SongsCollectionViewController *)viewController;

@end

@interface SongsCollectionViewController : UICollectionViewController

@property(nonatomic, weak) id<SongsCollectionViewControllerDelegate> delegate;

/** Songs in resource directory. */
@property(nonatomic) NSMutableArray <NSString *>* songs;

@property(nonatomic) NSInteger currentSongIndex;

- (instancetype)init; NS_DESIGNATED_INITIALIZER;


@end
