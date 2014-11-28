#include <UIKit/UIKit.h>

@interface UIKeyboardImpl : UIView;
@property(assign, nonatomic) UIResponder<UIKeyInput>* delegate;
@end

static NSString* email = @"";
static BOOL enabled = NO;

static NSTimeInterval timeLast = 0;

static void loadPreferences() {
	NSString* preferencesPlist = @"/var/mobile/Library/Preferences/com.ryst.doubleat7.plist";
	NSDictionary* preferences = [NSDictionary dictionaryWithContentsOfFile:preferencesPlist];

	id object = [preferences objectForKey:@"Enabled"];
	if (object != nil) {
		enabled = [object boolValue];
	} else {
		enabled = YES;
	}

	object = [preferences objectForKey:@"EmailAddress"];
	if (object != nil) {
		email = [object copy];
	} else {
		email = @"";
	}

	if ([email isEqualToString:@""]) {
		enabled = NO;
	}
}

static void receivedNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	loadPreferences();
}

%hook UIKeyboardImpl
-(void)insertText:(NSString*)text {

	if (enabled && [text isEqualToString:@"@"] &&
		self.delegate && [self.delegate conformsToProtocol:@protocol(UITextInput)]) {

		id<UITextInput> delegate = (id<UITextInput>)self.delegate;

		NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];

		if (time - timeLast > 1.0) {

			// This is the first @ character
			timeLast = time;

		} else {

			// This is the second @ character
			[delegate deleteBackward];
			%orig(email);

			timeLast = 0;
			return;

		}
	} else {
		timeLast = 0;
	}
	
	%orig;
}
%end

%ctor {
	CFNotificationCenterAddObserver(
		CFNotificationCenterGetDarwinNotifyCenter(),
		NULL,
		receivedNotification,
		CFSTR("com.ryst.doubleat7.preferencesChanged"),
		NULL,
		CFNotificationSuspensionBehaviorCoalesce);

	loadPreferences();
}

