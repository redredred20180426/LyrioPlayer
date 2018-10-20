#import <Foundation/Foundation.h>

@interface LrcParser : NSObject

//开始时间
@property (nonatomic,strong) NSMutableArray *startTimeArray;

//歌词
@property (nonatomic,strong) NSMutableArray *wordArray;

@property (nonatomic) NSTimeInterval offset;


//解析歌词
-(void) parseLrcNamed:(NSString *)lrcName;
//解析歌词
-(void) parseLrc:(NSString*)lrc;
@end
