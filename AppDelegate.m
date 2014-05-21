//
//  AppDelegate.m
//  SYXPathPopupButton
//
//  Created by shenyixin on 14-5-20.
//  Copyright (c) 2014年 shenyixin. All rights reserved.
//

#import "AppDelegate.h"
#import "SYXPathPopupButton.h"

@implementation AppDelegate
@synthesize pathPopupButton = _pathPopupButton;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.pathPopupButton.defaultDirs =[[NSMutableArray alloc] initWithObjects:[@"~/Desktop" stringByStandardizingPath],
                                       [@"~" stringByStandardizingPath],
                                       [@"~/Downloads" stringByStandardizingPath],
                                       [@"~/Movies" stringByStandardizingPath],
                                       [@"~/Music" stringByStandardizingPath],
                                       [@"~/Pictures" stringByStandardizingPath],
                                       [@"~/Documents" stringByStandardizingPath],nil];
    
    self.pathPopupButton.recentDirs = [[NSMutableArray alloc] initWithObjects:[@"~/Desktop" stringByStandardizingPath],
                                       [@"~/Applications" stringByStandardizingPath],
                                       [@"/users" stringByStandardizingPath],
                                       [@"~/Music" stringByStandardizingPath],

                                       [@"/bin" stringByStandardizingPath],nil];
    [self.pathPopupButton reloadData];
}



-(IBAction)selectDir:(id)sender{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setDelegate:(id)self];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setTitle:@"选择下载目录"];
	NSString *savePath = [self.pathPopupButton stringValue];
    NSURL* saveUrl = [[NSURL fileURLWithPath:savePath] retain];
	if(savePath != nil && ![savePath isEqualToString:@""]){
		BOOL isDir = FALSE;
		[[NSFileManager defaultManager] fileExistsAtPath:savePath isDirectory:&isDir];
		if( isDir )
        {
            [openPanel setDirectoryURL:saveUrl];
		}
	}
	
    
	[openPanel beginSheetModalForWindow:self.window  completionHandler:^(NSInteger result)
     {
         if( NSFileHandlingPanelOKButton == result )
         {
             NSString * dir = [[openPanel URL] relativePath];
             [self.pathPopupButton changeSelectedDir:dir];
             
             //将选中的插入并更新列表
             [self.pathPopupButton.recentDirs insertObject:dir atIndex:0];
             [self.pathPopupButton reloadData];
         }
         
     }];
    
}

@end
