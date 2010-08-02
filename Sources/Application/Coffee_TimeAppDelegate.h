#import <Cocoa/Cocoa.h>

@interface Coffee_TimeAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	IBOutlet NSTextField *checkmark;
	IBOutlet NSProgressIndicator *spinner;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction) coffeeTime:(id)sender;

@end
