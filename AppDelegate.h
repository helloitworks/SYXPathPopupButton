//
//  AppDelegate.h
//  SYXPathPopupButton
//
//  Created by shenyixin on 14-5-20.
//  Copyright (c) 2014年 shenyixin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SYXPathPopupButton;

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    SYXPathPopupButton *_pathPopupButton;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet SYXPathPopupButton *pathPopupButton;


-(IBAction)selectDir:(id)sender;

@end
