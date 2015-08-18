#import <Preferences/Preferences.h>

@interface NoAlertLoopPrefsListController: PSListController {
}
@end

@implementation NoAlertLoopPrefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"NoAlertLoopPrefs" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
