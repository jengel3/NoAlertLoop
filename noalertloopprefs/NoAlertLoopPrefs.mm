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

- (void)openTwitter:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/itsjake88"]];
}

- (void)openGithub:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/Jake0oo0"]];
}
@end

// vim:ft=objc
