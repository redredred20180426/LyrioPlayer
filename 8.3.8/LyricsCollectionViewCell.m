//
//  LyricsCellTableViewCell.m
//  MusicWeather
//
//  Created by MiZhou on 6/8/18.
//  Copyright © 2018 Changwei Zhang. All rights reserved.
//

#import "LyricsCollectionViewCell.h"

static const float kVerticalPadding = 0;
static const float kHorizontalPadding = 8;

@implementation LyricsCollectionViewCell

- (instancetype)initWithFrame: (CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    _lyricLine = [[UILabel alloc] init];
    _lyricLine.textAlignment = NSTextAlignmentLeft;
    
    _lyricLine.font = [UIFont systemFontOfSize:40];
    
    _lyricLine.lineBreakMode = NSLineBreakByWordWrapping;
    _lyricLine.numberOfLines = 0;
    [self addSubview:_lyricLine];
    }
    self.userInteractionEnabled = YES;
    
    return self;
}

- (void)layoutSubviews {
    CGFloat width = self.frame.size.width;
    [self layoutSubviewsForWidht:width setFrame:YES];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = [self layoutSubviewsForWidht:size.width setFrame:NO];
    return CGSizeMake(size.width, height);
}

- (CGFloat)layoutSubviewsForWidht: (CGFloat)width setFrame: (BOOL)setFrame {
    CGFloat currentHeight = kVerticalPadding;
    CGFloat labelWidth = width - 2 * kHorizontalPadding;
    CGSize labelSize = [self.lyricLine sizeThatFits:CGSizeMake(labelWidth, CGFLOAT_MAX)];
    if (setFrame) {
        [self.lyricLine setFrame: CGRectMake(kHorizontalPadding,
                                             currentHeight,
                                             labelSize.width,
                                             labelSize.height)];
    }
    
    currentHeight += labelSize.height + kVerticalPadding;
    return currentHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
