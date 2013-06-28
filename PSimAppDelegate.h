//
//  PSimAppDelegate.h
//  PSim
//
//  Created by Aaron Odell on 12/28/12.
//

#import <Cocoa/Cocoa.h>

@interface PSimAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
