int main(int argc, char *argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSURL *URL = [[NSURL alloc] initWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CoffeeURL"]];
	NSString *latestCoffee = [[NSString alloc] initWithContentsOfURL:URL];
	[URL release];
	
	NSArray *components = [latestCoffee componentsSeparatedByString:@"\n"];
	NSString *name = [components objectAtIndex:0];
	NSInteger time = [[components objectAtIndex:1] integerValue];
	NSInteger lastTime = [[NSUserDefaults standardUserDefaults] integerForKey:@"LastCoffee"];
	
	if (time > lastTime) {
		if (![name isEqualToString:NSFullUserName()])
			[GrowlApplicationBridge notifyWithTitle:@"It's Coffee Time!"
										description:[NSString stringWithFormat:@"%@ says it's coffee time!", name]
								   notificationName:@"ItsCoffeeTime"
										   iconData:NULL
										   priority:1
										   isSticky:YES
									   clickContext:NULL];
		[[NSUserDefaults standardUserDefaults] setInteger:time forKey:@"LastCoffee"];
	}
	
	[pool release];
}
