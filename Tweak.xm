#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MSHeaders.h"

NSDate *lastAlert = nil;
NSMutableArray *blocked = [[[NSMutableArray alloc] init] retain];
NSMutableArray *ignored = [[[NSMutableArray alloc] init] retain];
BOOL alertShowing = false;

%group safariHooks
%hook TabDocumentWK2
-(void) webView:(id)web runJavaScriptAlertPanelWithMessage:(id)msg initiatedByFrame:(id)frame completionHandler:(void (^)(NSString *param))completionBlock {
	if (lastAlert) {
		NSTimeInterval secondsBetween = [[NSDate date] timeIntervalSinceDate:lastAlert];
		if ([blocked containsObject:[self URLString]] || alertShowing) {
			lastAlert = [[NSDate date]retain];
			completionBlock(nil);
		} else if (![ignored containsObject:[self URLString]] && secondsBetween < 3 && !alertShowing) {
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
- (void)webView:(id)view runJavaScriptAlertPanelWithMessage:(id)arg2 initiatedByFrame:(id)arg3{
	if (lastAlert) {
		NSTimeInterval secondsBetween = [[[NSDate date]retain] timeIntervalSinceDate:lastAlert];
		if (secondsBetween <= 3) {
			[view stringByEvaluatingJavaScriptFromString:@"window.alert=null;$=null;window.onbeforeunload = null;"];
			lastAlert = [[NSDate date]retain];
			return;
		} else {
			lastAlert = [[NSDate date]retain];
			%orig;
		}
	} else {
		lastAlert = [[NSDate date]retain];
		%orig;
	}
}
%end
%end
%ctor {
	%init(safariHooks);
}