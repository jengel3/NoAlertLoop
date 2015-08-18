#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MSHeaders.h"

NSDate *lastAlert = nil;
NSMutableArray *blocked = [[[NSMutableArray alloc] init] retain];
NSMutableArray *ignored = [[[NSMutableArray alloc] init] retain];
BOOL alertShowing = false;
NSString *appUrl = nil;

%group safariHooks
%hook TabDocumentWK2
-(void) webView:(id)web runJavaScriptAlertPanelWithMessage:(id)msg initiatedByFrame:(id)frame completionHandler:(void (^)(NSString *param))completionBlock {
	NSLog(@"Type of this: %@", [web class]);
	if (lastAlert) {
		NSTimeInterval secondsBetween = [[NSDate date] timeIntervalSinceDate:lastAlert];
		if ([blocked containsObject:[self URLString]] || alertShowing) {
			lastAlert = [[NSDate date]retain];
			completionBlock(nil);
		} else if (![ignored containsObject:[self URLString]] && secondsBetween <= 3 && !alertShowing) {
			lastAlert = [[NSDate date]retain];
			UIAlertView *q = [[UIAlertView alloc] initWithTitle:@"NoAlertLoop" 
				message:@"This website seems to be creating many popups. Would you like to block them?"
				delegate:self
				cancelButtonTitle:nil
				otherButtonTitles:@"Yes", nil];
			[q addButtonWithTitle:@"No"];
			alertShowing = true;
			[q show];
			[q release];
			completionBlock(nil);
		} else {
			lastAlert = [[NSDate date]retain];
			%orig;
		}
	} else {
		lastAlert = [[NSDate date]retain];
		%orig;
	}


}

%new(v@:@i)
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(long)buttonIndex {	
	if (buttonIndex == 0) { // yes 
		[blocked addObject:[self URLString]];
	} else {
		[ignored addObject:[self URLString]];
	}
	alertShowing = false;
}

%end

%hook UIWebView
- (void)webView:(id)view runJavaScriptAlertPanelWithMessage:(id)msg initiatedByFrame:(id)frame{
	appUrl = [[view mainFrameURL]retain];
	NSLog(@"Url: %@", appUrl);
	if (lastAlert) {
		NSTimeInterval secondsBetween = [[NSDate date] timeIntervalSinceDate:lastAlert];
		if ([blocked containsObject:appUrl] || alertShowing) {
			lastAlert = [[NSDate date]retain];
		} else if (![ignored containsObject:appUrl] && secondsBetween < 3 && !alertShowing) {
			lastAlert = [[NSDate date]retain];
			UIAlertView *q = [[UIAlertView alloc] initWithTitle:@"NoAlertLoop" 
				message:@"This website seems to be creating many popups. Would you like to block them?"
				delegate:self
				cancelButtonTitle:nil
				otherButtonTitles:@"Yes", nil];
			[q addButtonWithTitle:@"No"];
			alertShowing = true;
			[q show];
			[q release];
		} else {
			lastAlert = [[NSDate date]retain];
			%orig;
		}
	} else {
		lastAlert = [[NSDate date]retain];
		%orig;
	}
}

%new(v@:@i)
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(long)buttonIndex {
	NSLog(@"this alert - %@", alertView);
	if (buttonIndex == 0) { // yes 
		[blocked addObject:appUrl];
	} else {
		[ignored addObject:appUrl];
	}
	alertShowing = false;
}
%end
%end
%ctor {
	%init(safariHooks);
}