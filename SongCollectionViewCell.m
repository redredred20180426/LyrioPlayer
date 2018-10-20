//
//  SongCollectionViewCell.m
//  LyrioPlayer
//
//  Created by Julie Zhou on 30/06/2018.
//  Copyright © 2018 Liz. All rights reserved.
//

#import "SongCollectionViewCell.h"

static const CGFloat kHorizontalPadding = 16;
static const CGFloat kVerticalPadding = 8;

@implementation SongCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.backgroundColor = [UIColor whiteColor];
    _nameLabel.textColor = [UIColor blackColor];
    _nameLabel.font = [UIFont systemFontOfSize:30];
    [self addSubview:_nameLabel];
  }
  return self;
}

- (void)layoutSubviews {
  [self layoutSubviewsForWidth:self.frame.size.width setFrame:YES];
}

- (CGSize)sizeThatFits:(CGSize)size {
  return CGSizeMake(size.width, [self layoutSubviewsForWidth:size.width setFrame:NO]);
}

#pragma mark - Private Methods

- (CGFloat)layoutSubviewsForWidth : (CGFloat)width
                          setFrame: (BOOL)setFrame {
  CGFloat currentHeight = kVerticalPadding;
  CGFloat contentWidth = self.frame.size.width - 2 * kHorizontalPadding;
  CGSize labelSize = [self.nameLabel sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)];
  if (setFrame) {
    self.nameLabel.frame = CGRectMake(kHorizontalPadding, currentHeight, contentWidth, labelSize.height);
  }
  currentHeight += labelSize.height;
  currentHeight += kHorizontalPadding;
  return currentHeight;
}

@end
