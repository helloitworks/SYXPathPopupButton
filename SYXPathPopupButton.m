//  Created by shenyixin on 14-5-20.
//  Copyright (c) 2014年 shenyixin. All rights reserved.
//


#import "SYXPathPopupButton.h"

/*一些注意的地方
 1、怎么添加名称重复的Item?
 采用[self addItemWithTitle:title]; 并不能添加名字重复的item
 采用[self.menu addItem:newItem];可以添加名字重复的item
 
 2、怎么自定义NSMenuItem，比如像"个人收藏“那样的MenuItem。
 通过 NSMenuItem的函数setIndentationLevel:，并不能实现图中"个人收藏“那样的MenuItem。
 自定义该NSMenuItem可以通过函数setView:，具体的实现可以参看源代码中的函数categoryMenuItemWithTitle：
*/

static const NSUInteger kMenuIconWidth = 16;
static const NSUInteger kMenuIconHeigh = 16;
static const NSRect kCategoryMenuItemViewBounds = {0, 0, 100,18};
static const NSRect kCategoryMenuItemTextFieldBounds = {8, 0, 100,18};
static const NSUInteger kCategoryMenuItemTitleFontSize = 11;

static const NSUInteger kMaxRecentDirsCount = 5;

/*
typedef enum
{
    SYXPathPopupButtonDirItemType_Default = 0,
    SYXPathPopupButtonDirItemType_Seperator,
    SYXPathPopupButtonDirItemType_Category
}SYXPathPopupButtonDirItemType;


@interface SYXPathPopupButtonDirItem : NSObject
{
    NSString *_dir;
    SYXPathPopupButtonDirItemType _type;
}

@property (copy) NSString *dir;
@property (assign) SYXPathPopupButtonDirItemType type;

@end

@implementation SYXPathPopupButtonDirItem
@synthesize dir = _dir;
@synthesize type = _type;
@end
*/

@implementation SYXPathPopupButton
@synthesize defaultDirs = _defaultDirs;
@synthesize recentDirs = _recentDirs;
@synthesize selectedDir = _selectedDir;
@synthesize maxRecentDirsCount = _maxRecentDirsCount;

-(void)awakeFromNib
{
	[self setPullsDown:FALSE];
	[self setAutoenablesItems:NO];
    [self setMaxRecentDirsCount:kMaxRecentDirsCount];
    [self reloadData];
   
    //popupButton打开的事件，不能通过action，只能通过self.menu.delegate跟menuWillOpen
    //self.menu.delegate = self;
}



- (NSMenuItem *)menuItemWithDir:(NSString *)dir
{
    NSMenuItem* menuItem = [[NSMenuItem alloc] init];
    NSString * title = [[NSFileManager defaultManager] displayNameAtPath:dir];
    [menuItem setTitle:title];
    [menuItem setToolTip:dir];
    NSImage * img = [[NSWorkspace sharedWorkspace] iconForFile:dir];
    [img setSize:NSMakeSize(kMenuIconWidth, kMenuIconHeigh)];
    [menuItem setImage:img];
    [menuItem setTarget:self];
    [menuItem setAction:@selector(selectItem:)];
    return menuItem;
}

- (NSMenuItem *)categoryMenuItemWithTitle:(NSString *)title
{
    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""] ;
    NSView *view = [[NSView alloc] initWithFrame:kCategoryMenuItemViewBounds];
    NSTextField *textField = [[NSTextField alloc]initWithFrame:kCategoryMenuItemTextFieldBounds] ;
    [textField setBordered:NO];
    [textField setEditable:NO];
    [textField setEnabled:NO];
    [textField setFont:[NSFont systemFontOfSize:kCategoryMenuItemTitleFontSize]];
    textField.stringValue = title;
    [view addSubview:textField];
    [menuItem setView:view];
    return menuItem;
}


-(NSString *)stringValue
{
    return self.selectedDir;
}


- (void)reloadData
{
    [self removeAllItems];
    
    //defaultDirs默认值
    if (self.defaultDirs.count == 0)
    {
        self.defaultDirs = [[NSMutableArray alloc] initWithObjects:[@"~/Desktop" stringByStandardizingPath],
                            [@"~" stringByStandardizingPath],
                            [@"~/Downloads" stringByStandardizingPath],
                            [@"~/Movies" stringByStandardizingPath],
                            [@"~/Music" stringByStandardizingPath],
                            [@"~/Pictures" stringByStandardizingPath],
                            [@"~/Documents" stringByStandardizingPath],nil];
    }
    
    [self removeNotExitOrDuplicatedDir];
    
    if (self.selectedDir == NULL || [self.selectedDir isEqualToString:@""])
    {
        self.selectedDir = [self.defaultDirs objectAtIndex:0];
    }
    
    [self.menu addItem:[self menuItemWithDir:self.selectedDir]];
    
    [self.menu addItem:[NSMenuItem separatorItem]];
    [self.menu addItem:[self categoryMenuItemWithTitle:@"个人收藏"]];
    
	for (NSString *dir in self.defaultDirs)
    {
        [self.menu addItem:[self menuItemWithDir:dir]];
	}
    
    // 需要判断recentDirs是否有数据
    if (self.recentDirs.count)
    {
        [self.menu addItem:[NSMenuItem separatorItem]];
        [self.menu addItem:[self categoryMenuItemWithTitle:@"最近访问的位置"]];
        NSUInteger count = 0;
        for (NSString *dir in self.recentDirs)
        {
            if (count == self.maxRecentDirsCount)
            {
                return;
            }
            
            [self.menu addItem:[self menuItemWithDir:dir]];
            count ++;
        }
    }
  
}

//“个人收藏”与”最近访问的位置“都会对其自身列表进行去重操作，同时”最近访问的位置“也会根据”个人收藏“进行去重，也即出现在”个人收藏“的路径，就不会出现在”最近访问的位置里“
- (void)removeNotExitOrDuplicatedDir
{
    NSMutableArray *allDirs = [[[NSMutableArray alloc] init] autorelease];
    // defaultDir本身不能有重复
    for (NSInteger i = self.defaultDirs.count - 1; i >= 0; i--)
    {
        NSString *dir = [self.defaultDirs objectAtIndex:i];
        BOOL isDir = FALSE;
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isDir];
        
        if(exist && isDir )
        {
            if ([allDirs containsObject:dir])
            {
                [self.defaultDirs removeObjectAtIndex:i];
            }
            else
            {
                [allDirs addObject:dir];
            }
        }
        else
        {
            [self.defaultDirs removeObjectAtIndex:i];
        }
        
    }
    
    //recentDirs本身既不能有重复，同时也不能与defaultDirs有重复
    for (NSInteger i = self.recentDirs.count - 1; i >= 0; i--)
    {
        NSString *dir = [self.recentDirs objectAtIndex:i];
        BOOL isDir = FALSE;
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isDir];
        if(exist && isDir )
        {
            if ([allDirs containsObject:dir])
            {
                [self.recentDirs removeObjectAtIndex:i];
            }
            else
            {
                [allDirs addObject:dir];
            }
        }
        else
        {
            [self.recentDirs removeObjectAtIndex:i];
        }
    }
    

}



- (void)selectItem:(NSMenuItem *)item
{
    //todo: 可以通过indexOfSelectedItem，取得相应的值，而不是通过toolTip
    //NSInteger i = [self indexOfSelectedItem];
    //...
    
    NSString *dir = item.toolTip;
    //菜单选中定位到第一行
    [self changeSelectedDir:dir];
    
    //菜单选中定位到当中选中的
    //[super selectItem:item];
}


- (void)changeSelectedDir:(NSString *)dir
{
    if (_selectedDir != dir)
    {
        [_selectedDir release];
        _selectedDir = [dir copy];
        
        NSMenuItem * newMenuItem = [self menuItemWithDir:dir];
        [self.menu removeItemAtIndex:0];
        [self.menu insertItem:newMenuItem atIndex:0];
        [self selectItemAtIndex:0];
    }
    
}


/* popupButton打开的事件
 - (void)menuWillOpen:(NSMenu *)menu
 {
 NSLog(@"menuWillOpen");
 //[self reloadData];
 }
 */
@end

