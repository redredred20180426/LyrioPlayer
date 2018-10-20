
#import "LrcParser.h"

@interface LrcParser ()

-(void) parseLrc:(NSString *)word;

@end

@implementation LrcParser



-(instancetype) init{
    self=[super init];
    if(self!=nil){
        self.wordArray=[[NSMutableArray alloc] init];
        self.startTimeArray =[[NSMutableArray alloc] init];
    }
    return  self;
}



-(NSString *)getLrcFile:(NSString *)lrc{
    NSString* filePath=[[NSBundle mainBundle] pathForResource:lrc ofType:@"lrc"];
    return  [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
}
//测试示例
-(void) parseLrcNamed:(NSString *)lrcName {
    [self parseLrc:[self getLrcFile:lrcName]];
}


-(void)parseLrc:(NSString *)lrc{
    if(![lrc isEqual:nil]){
        NSArray *sepArray=[lrc componentsSeparatedByString:@"["];
        NSArray *lineArray=[[NSArray alloc] init];
        for(int i=0;i<sepArray.count;i++){
            if([sepArray[i] length]>0){
                lineArray=[sepArray[i] componentsSeparatedByString:@"]"];
                if(![lineArray[0] isEqualToString:@"\n"]){
                    NSArray *timeArray=[lineArray[0] componentsSeparatedByString:@":"];
                    NSTimeInterval startTime = [timeArray[0] intValue]* 60 + [timeArray[1] floatValue];
                    [self.startTimeArray addObject: @(startTime)];
                    
                    [self.wordArray addObject:lineArray.count>1?lineArray[1]:@""];
                }
            }
        }
    }
    [self mergeLrcListIsNecessary];
}

- (void)mergeLrcListIsNecessary {
    if (self.startTimeArray.count == 0) {
        return;
    }
    for (NSInteger i = 0; i < self.startTimeArray.count - 1; i++) {
        NSTimeInterval duration = [[self.startTimeArray objectAtIndex:(i + 1)] doubleValue] - [[self.startTimeArray objectAtIndex:(i)] doubleValue];
        NSString *currentLyric = [self.wordArray objectAtIndex:i] ;
        NSString *nextLyric = [self stringWithoutWhiteSpace:[self.wordArray objectAtIndex:(i + 1)]];
        if (duration < 0.5 || nextLyric.length == 0) { // Less than 0.5 seconds
            NSString *mergedLyric;
            if (currentLyric.length > 0 && nextLyric.length > 0) {
                mergedLyric = [currentLyric stringByAppendingString:nextLyric];
            } else {
                mergedLyric = currentLyric;
            }
            [self.startTimeArray removeObjectAtIndex:(i + 1)];
            [self.wordArray removeObjectAtIndex:i];
            [self.wordArray removeObjectAtIndex:i];
            [self.wordArray insertObject:mergedLyric atIndex:i];
        }
    }
}

- (NSString *)stringWithoutWhiteSpace:(NSString *)string {
    if (string.length == 0) {
        return nil;
    }
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
