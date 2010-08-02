//
//  Coffee_TimeAppDelegate.m
//  Coffee Time
//
//  Created by Tim Morgan on 7/29/10.
//  Copyright 2010 Scribd. All rights reserved.
//

#import "Coffee_TimeAppDelegate.h"

@implementation Coffee_TimeAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// check for app support folder and script
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
	NSString *appSupportPath = [basePath stringByAppendingPathComponent:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
	
	NSError *error = NULL;
	if (![[NSFileManager defaultManager] fileExistsAtPath:appSupportPath])
		[[NSFileManager defaultManager] createDirectoryAtPath:appSupportPath withIntermediateDirectories:YES attributes:NULL error:&error];
	NSString *scriptPath = [appSupportPath stringByAppendingPathComponent:@"coffee_check.rb"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:scriptPath])
		[[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"coffee_check" ofType:@"rb"]
												toPath:scriptPath
												 error:&error];
	
	// check for growlnotify
	
	NSString *binPath = [appSupportPath stringByAppendingPathComponent:@"growlnotify"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:binPath])
		[[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"growlnotify" ofType:NULL]
												toPath:binPath
												 error:&error];
	
	// check for launch agent
	
	paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *libraryPath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
	
	NSString *agentPath = [libraryPath stringByAppendingPathComponent:@"LaunchAgents"];
	NSString *agent = @"com.scribd.CoffeeTime.plist";
	if (![[NSFileManager defaultManager] fileExistsAtPath:agentPath])
		[[NSFileManager defaultManager] createDirectoryAtPath:agentPath withIntermediateDirectories:YES attributes:NULL error:&error];
	NSString *agentFilePath = [agentPath stringByAppendingPathComponent:agent];
	if (![[NSFileManager defaultManager] fileExistsAtPath:agentFilePath]) {
		NSMutableString *agentString = [[NSMutableString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"com.scribd.CoffeeTime" ofType:@"plist"]];
		[agentString replaceOccurrencesOfString:@"__SCRIPT_PATH__" withString:scriptPath options:0 range:NSMakeRange(0, [agentString length])];
		[agentString writeToFile:agentFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
		[agentString release];
		
		NSArray *arguments = [[NSArray alloc] initWithObjects:@"load", @"-w", agentFilePath, NULL];
		[NSTask launchedTaskWithLaunchPath:@"/bin/launchctl" arguments:arguments];
		[arguments release];
	}
}

- (IBAction) coffeeTime:(id)sender {
	[checkmark setHidden:YES];
	NSURL *URL = [[NSURL alloc] initWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CoffeeURL"]];
	NSMutableURLRequest *ping = [[NSMutableURLRequest alloc] initWithURL:URL];
	[URL release];
	[ping setHTTPMethod:@"POST"];
	NSString *body = [[NSString alloc] initWithFormat:@"%@=%@",
					  [@"coffee[name]" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
					  [NSFullUserName() stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	[ping setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding]];
	[body release];
	
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:ping delegate:self];
	[conn autorelease];
	[spinner setHidden:NO];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[spinner setHidden:YES];
	NSAlert *alert = [[NSAlert alloc] init];
	[alert setAlertStyle:NSCriticalAlertStyle];
	[alert setMessageText:@"Couldn't connect to the Coffee Server."];
	[alert setInformativeText:@"Have you made sure that you have Internet access?"];
	[alert addButtonWithTitle:@"D'oh"];
	[alert runModal];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
	[spinner setHidden:YES];
	if ([response statusCode] == 200) [checkmark setHidden:NO];
	else {
		NSAlert *alert = [[NSAlert alloc] init];
		[alert setAlertStyle:NSCriticalAlertStyle];
		NSString *message = [[NSString alloc] initWithFormat:@"Got a %d response from the Coffee Server.", [response statusCode]];
		[alert setMessageText:message];
		[message release];
		[alert setInformativeText:@"Maybe go bug Tim and tell him to fix his shit?"];
		[alert addButtonWithTitle:@"Ah Nuts"];
		[alert runModal];
	}
}

@end
