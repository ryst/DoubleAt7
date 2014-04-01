#include <UIKit/UIKit.h>

@interface UIKeyboardImpl : UIView;
@property(assign, nonatomic) UIResponder<UIKeyInput>* delegate;
@end

static NSString* email = @"";
static BOOL enabled = NO;

static NSTimeInterval timeLast = 0;
static NSInteger offsetLast = 0;

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
		UITextRange* range = delegate.selectedTextRange;
		NSInteger start = [delegate offsetFromPosition:delegate.beginningOfDocument toPosition:range.start];

		if (time - timeLast > 1.0 || start == 0 || start != offsetLast + 1) {

			// This is the first @ character
			timeLast = time;
			offsetLast = start;

		} else {

			// This is the second @ character
			UITextPosition* replaceStart = [delegate positionFromPosition:range.start offset:-1];
			UITextRange* replaceRange = [delegate textRangeFromPosition:replaceStart toPosition:range.start];
			NSString* s = [delegate textInRange:replaceRange];

			if ([s isEqualToString:@"@"]) { // Just to be sure that the first @ character is there!
				NSString* firstPart;
				NSString* secondPart;
				if (email.length > 1) {
					firstPart = [email substringToIndex:email.length - 1];
					secondPart = [email substringFromIndex:email.length - 1];
				} else {
					firstPart = @"";
					secondPart = email;
				}

				[delegate replaceRange:replaceRange withText:firstPart];

				%orig(secondPart);

				return;
			} else {
				timeLast = 0;
				offsetLast = 0;
			}
		}
	} else {
		timeLast = 0;
		offsetLast = 0;
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

