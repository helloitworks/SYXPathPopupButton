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
}

@property (retain) NSMutableArray *defaultDirs;
@property (retain) NSMutableArray *recentDirs;
@property (retain) NSString *selectedDir;

// 目录的路径
-(NSString *)stringValue;

//重新加载数据 
- (void)reloadData;


@end
