#import <Preferences/Preferences.h>

@interface DoubleAt7ListController: PSListController {
}
@end

@implementation DoubleAt7ListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"DoubleAt7" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
