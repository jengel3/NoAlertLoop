#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MSHeaders.h"

NSDate *lastAlert = nil;
NSMutableArray *blocked = [[[NSMutableArray alloc] init] retain];
NSMutableArray *ignored = [[[NSMutableArray alloc] init] retain];
NSString *prefsLoc = @"/var/mobile/Library/Preferences/com.jake0oo0.noalertloop.plist";
BOOL enabled = nil;
BOOL alertShowing = false;
NSString *appUrl = nil;

%group webHooks
%hook TabDocumentWK2
-(void) webView:(id)web runJavaScriptAlertPanelWithMessage:(id)msg initiatedByFrame:(id)frame completionHandler:(void (^)(NSString *param))completionBlock {
	if (lastAlert && enabled) {
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
	if (lastAlert && enabled) {
		appUrl = [[view mainFrameURL]retain];
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
	if (![alertView.title isEqualToString:@"NoAlertLoop"]) {
		return;
	}
	if (buttonIndex == 0) { // yes 
		[blocked addObject:appUrl];
	} else {
		[ignored addObject:appUrl];
	}
	alertShowing = false;
}
%end
%end

static void updatePrefs() {
	NSDictionary *prefs = [[[NSDictionary alloc] initWithContentsOfFile:prefsLoc] retain];
 	enabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : YES;
}


static void handleNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	updatePrefs();
}

%ctor {
	%init(webHooks);
	updatePrefs();
	CFNotificationCenterAddObserver(
		CFNotificationCenterGetDarwinNotifyCenter(), NULL,
		&handleNotification,
		(CFStringRef)@"com.jake0oo0.noalertloop/prefsChange",
		NULL, CFNotificationSuspensionBehaviorCoalesce);
}