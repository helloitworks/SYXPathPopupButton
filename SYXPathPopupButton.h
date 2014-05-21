//  Created by shenyixin on 14-5-20.
//  Copyright (c) 2014年 shenyixin. All rights reserved.
//

@interface SYXPathPopupButton : NSPopUpButton <NSMenuDelegate> {
    //个人收藏
	NSMutableArray *_defaultDirs;
    //最近访问的位置
	NSMutableArray *_recentDirs;
    //选中的目录
    NSString *_selectedDir;
    
    //最近访问位置最多展示条数
    NSUInteger _maxRecentDirsCount;
}

@property (retain) NSMutableArray *defaultDirs;
@property (retain) NSMutableArray *recentDirs;
@property (copy) NSString *selectedDir;
@property (assign) NSUInteger maxRecentDirsCount;

// 目录的路径
-(NSString *)stringValue;

- (void)changeSelectedDir:(NSString *)dir;


//重新加载数据
- (void)reloadData;


@end
