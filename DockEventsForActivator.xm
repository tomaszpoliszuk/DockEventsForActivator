#import <Foundation/Foundation.h>
#import <libactivator/libactivator.h>
#import <UIKit/UIKit.h>

#include <dispatch/dispatch.h>
#include <objc/runtime.h>

@interface SBDockView : UIView
@end
@interface SBFTouchPassThroughView : UIView
@end
@interface SBFloatingDockView : SBFTouchPassThroughView
@end

#define LASendEventWithName(eventName) \
	[LASharedActivator sendEventToListener:[LAEvent eventWithName:eventName mode:[LASharedActivator currentEventMode]]]

static NSString *DockSwipeUp = @"com.tomaszpoliszuk.dockeventsforactivator.swipeup";
static NSString *DockSwipeDown = @"com.tomaszpoliszuk.dockeventsforactivator.swipedown";
static NSString *DockSwipeLeft = @"com.tomaszpoliszuk.dockeventsforactivator.swipeleft";
static NSString *DockSwipeRight = @"com.tomaszpoliszuk.dockeventsforactivator.swiperight";
static NSString *DockHold = @"com.tomaszpoliszuk.dockeventsforactivator.hold";
//static NSString *DockPinch = @"com.tomaszpoliszuk.dockeventsforactivator.pinch";
//static NSString *DockTap = @"com.tomaszpoliszuk.dockeventsforactivator.tap";
static NSString *DockDoubleTap = @"com.tomaszpoliszuk.dockeventsforactivator.doubletap";
//static NSString *DockTripleTap = @"com.tomaszpoliszuk.dockeventsforactivator.tripletap";


@interface DockEventsDataSource : NSObject <LAEventDataSource>
+ (id)sharedInstance;
@end

@implementation DockEventsDataSource
+ (id)sharedInstance {
	static id sharedInstance = nil;
	static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
		sharedInstance = [self new];
	});
	return sharedInstance;
}
+ (void)load {
	[self sharedInstance];
}
- (id)init {
	if (self = [super init]) {
		[LASharedActivator registerEventDataSource:self forEventName:DockSwipeUp];
		[LASharedActivator registerEventDataSource:self forEventName:DockSwipeDown];
		[LASharedActivator registerEventDataSource:self forEventName:DockSwipeLeft];
		[LASharedActivator registerEventDataSource:self forEventName:DockSwipeRight];
		[LASharedActivator registerEventDataSource:self forEventName:DockHold];
//		[LASharedActivator registerEventDataSource:self forEventName:DockPinch];
//		[LASharedActivator registerEventDataSource:self forEventName:DockTap];
		[LASharedActivator registerEventDataSource:self forEventName:DockDoubleTap];
//		[LASharedActivator registerEventDataSource:self forEventName:DockTripleTap];
	}
	return self;
}
- (NSString *)localizedTitleForEventName:(NSString *)eventName {
	if ([eventName isEqualToString:DockSwipeUp]) {
		return @"Swipe Up";
	} else if ([eventName isEqualToString:DockSwipeDown]) {
		return @"Swipe Down";
	} else if ([eventName isEqualToString:DockSwipeLeft]) {
		return @"Swipe Left";
	} else if ([eventName isEqualToString:DockSwipeRight]) {
		return @"Swipe Right";
	} else if ([eventName isEqualToString:DockHold]) {
		return @"Hold";
//	} else if ([eventName isEqualToString:DockPinch]) {
//		return @"Pinch";
//	} else if ([eventName isEqualToString:DockTap]) {
//		return @"Tap";
	} else if ([eventName isEqualToString:DockDoubleTap]) {
		return @"Double Tap";
//	} else if ([eventName isEqualToString:DockTripleTap]) {
//		return @"Triple Tap";
	}
	return @" ";
}
- (NSString *)localizedGroupForEventName:(NSString *)eventName {
	return @"Dock";
}
- (NSString *)localizedDescriptionForEventName:(NSString *)eventName {
	if ([eventName isEqualToString:DockSwipeUp]) {
		return @"Tap and drag up on Dock";
	} else if ([eventName isEqualToString:DockSwipeDown]) {
		return @"Tap and drag down on Dock";
	} else if ([eventName isEqualToString:DockSwipeLeft]) {
		return @"Tap and drag left on Dock";
	} else if ([eventName isEqualToString:DockSwipeRight]) {
		return @"Tap and drag right on Dock";
	} else if ([eventName isEqualToString:DockHold]) {
		return @"Tap and hold on Dock";
//	} else if ([eventName isEqualToString:DockPinch]) {
//		return @"Pinch Dock with 2 fingers";
//	} else if ([eventName isEqualToString:DockTap]) {
//		return @"Tap on Dock";
	} else if ([eventName isEqualToString:DockDoubleTap]) {
		return @"Double-tap on Dock";
//	} else if ([eventName isEqualToString:DockTripleTap]) {
//		return @"Triple-tap on Dock";
	}
	return @" ";
}
- (void)dealloc {
	[LASharedActivator unregisterEventDataSourceWithEventName:DockSwipeUp];
	[LASharedActivator unregisterEventDataSourceWithEventName:DockSwipeDown];
	[LASharedActivator unregisterEventDataSourceWithEventName:DockSwipeLeft];
	[LASharedActivator unregisterEventDataSourceWithEventName:DockSwipeRight];
	[LASharedActivator unregisterEventDataSourceWithEventName:DockHold];
//	[LASharedActivator unregisterEventDataSourceWithEventName:DockPinch];
//	[LASharedActivator unregisterEventDataSourceWithEventName:DockTap];
	[LASharedActivator unregisterEventDataSourceWithEventName:DockDoubleTap];
//	[LASharedActivator unregisterEventDataSourceWithEventName:DockTripleTap];
	[super dealloc];
}
@end

%hook SBDockView
-(void)didMoveToWindow {
	%orig;

	UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dockReceivedSwipeUpGesture:)];
	swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
	[self addGestureRecognizer:swipeUp];
	[swipeUp release];

	UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dockReceivedSwipeDownGesture:)];
	swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
	[self addGestureRecognizer:swipeDown];
	[swipeDown release];

	UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dockReceivedSwipeLeftGesture:)];
	swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
	[self addGestureRecognizer:swipeLeft];
	[swipeLeft release];

	UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dockReceivedSwipeRightGesture:)];
	swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
	[self addGestureRecognizer:swipeRight];
	[swipeRight release];

	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(dockReceivedLongPressGesture:)];
	[self addGestureRecognizer:longPress];
	[longPress release];

//	UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(dockReceivedPinchGesture:)];
//	[self addGestureRecognizer:pinch];
//	[pinch release];

//	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dockReceivedTapGesture:)];
//	[self addGestureRecognizer:tap];
//	[tap release];

	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dockReceivedDoubleTapGesture:)];
	doubleTap.numberOfTapsRequired = 2;
	doubleTap.numberOfTouchesRequired = 1;
	[self addGestureRecognizer:doubleTap];
	[doubleTap release];

//	UITapGestureRecognizer *tripleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dockReceivedTripleTapGesture:)];
//	tripleTap.numberOfTapsRequired = 3;
//	tripleTap.numberOfTouchesRequired = 1;
//	[self addGestureRecognizer:tripleTap];
//	[tripleTap release];


}
%new
-(void)dockReceivedSwipeUpGesture:(UISwipeGestureRecognizer*)arg1 {
//	UIGestureRecognizerStateBegan
//	UIGestureRecognizerStateChanged
//	UIGestureRecognizerStateEnded
	if ( arg1.state == UIGestureRecognizerStateEnded ) {
		LASendEventWithName(DockSwipeUp);
	}
}
%new
-(void)dockReceivedSwipeDownGesture:(UISwipeGestureRecognizer*)arg1 {
	if ( arg1.state == UIGestureRecognizerStateEnded ) {
		LASendEventWithName(DockSwipeDown);
	}
}
%new
-(void)dockReceivedSwipeLeftGesture:(UISwipeGestureRecognizer*)arg1 {
	if ( arg1.state == UIGestureRecognizerStateEnded ) {
		LASendEventWithName(DockSwipeLeft);
	}
}
%new
-(void)dockReceivedSwipeRightGesture:(UISwipeGestureRecognizer*)arg1 {
	if ( arg1.state == UIGestureRecognizerStateEnded ) {
		LASendEventWithName(DockSwipeRight);
	}
}
%new
-(void)dockReceivedLongPressGesture:(UILongPressGestureRecognizer*)arg1 {
	if ( arg1.state == UIGestureRecognizerStateBegan ) {
		LASendEventWithName(DockHold);
	}
}
//%new
//-(void)dockReceivedPinchGesture:(UIPinchGestureRecognizer*)arg1 {
//	if ( arg1.state == UIGestureRecognizerStateEnded ) {
//		LASendEventWithName(DockPinch);
//	}
//}
//%new
//-(void)dockReceivedTapGesture:(UITapGestureRecognizer*)arg1 {
//	if ( arg1.state == UIGestureRecognizerStateEnded ) {
//		LASendEventWithName(DockTap);
//	}
//}
%new
-(void)dockReceivedDoubleTapGesture:(UITapGestureRecognizer*)arg1 {
	if ( arg1.state == UIGestureRecognizerStateEnded ) {
		LASendEventWithName(DockDoubleTap);
	}
}
//%new
//-(void)dockReceivedTripleTapGesture:(UITapGestureRecognizer*)arg1 {
//	if ( arg1.state == UIGestureRecognizerStateEnded ) {
//		LASendEventWithName(DockTripleTap);
//	}
//}

%end


%hook SBFloatingDockView
-(void)didMoveToWindow {
	%orig;

	UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dockReceivedSwipeUpGesture:)];
	swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
	[self addGestureRecognizer:swipeUp];
	[swipeUp release];

	UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dockReceivedSwipeDownGesture:)];
	swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
	[self addGestureRecognizer:swipeDown];
	[swipeDown release];

	UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dockReceivedSwipeLeftGesture:)];
	swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
	[self addGestureRecognizer:swipeLeft];
	[swipeLeft release];

	UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dockReceivedSwipeRightGesture:)];
	swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
	[self addGestureRecognizer:swipeRight];
	[swipeRight release];

	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(dockReceivedLongPressGesture:)];
	[self addGestureRecognizer:longPress];
	[longPress release];

//	UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(dockReceivedPinchGesture:)];
//	[self addGestureRecognizer:pinch];
//	[pinch release];

//	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dockReceivedTapGesture:)];
//	[self addGestureRecognizer:tap];
//	[tap release];

	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dockReceivedDoubleTapGesture:)];
	doubleTap.numberOfTapsRequired = 2;
	doubleTap.numberOfTouchesRequired = 1;
	[self addGestureRecognizer:doubleTap];
	[doubleTap release];

//	UITapGestureRecognizer *tripleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dockReceivedTripleTapGesture:)];
//	tripleTap.numberOfTapsRequired = 3;
//	tripleTap.numberOfTouchesRequired = 1;
//	[self addGestureRecognizer:tripleTap];
//	[tripleTap release];
}
%new
-(void)dockReceivedSwipeUpGesture:(UISwipeGestureRecognizer*)arg1 {
//	UIGestureRecognizerStateBegan
//	UIGestureRecognizerStateChanged
//	UIGestureRecognizerStateEnded
	if ( arg1.state == UIGestureRecognizerStateEnded ) {
		LASendEventWithName(DockSwipeUp);
	}
}
%new
-(void)dockReceivedSwipeDownGesture:(UISwipeGestureRecognizer*)arg1 {
	if ( arg1.state == UIGestureRecognizerStateEnded ) {
		LASendEventWithName(DockSwipeDown);
	}
}
%new
-(void)dockReceivedSwipeLeftGesture:(UISwipeGestureRecognizer*)arg1 {
	if ( arg1.state == UIGestureRecognizerStateEnded ) {
		LASendEventWithName(DockSwipeLeft);
	}
}
%new
-(void)dockReceivedSwipeRightGesture:(UISwipeGestureRecognizer*)arg1 {
	if ( arg1.state == UIGestureRecognizerStateEnded ) {
		LASendEventWithName(DockSwipeRight);
	}
}
%new
-(void)dockReceivedLongPressGesture:(UILongPressGestureRecognizer*)arg1 {
	if ( arg1.state == UIGestureRecognizerStateBegan ) {
		LASendEventWithName(DockHold);
	}
}
//%new
//-(void)dockReceivedPinchGesture:(UIPinchGestureRecognizer*)arg1 {
//	if ( arg1.state == UIGestureRecognizerStateEnded ) {
//		LASendEventWithName(DockPinch);
//	}
//}
//%new
//-(void)dockReceivedTapGesture:(UITapGestureRecognizer*)arg1 {
//	if ( arg1.state == UIGestureRecognizerStateEnded ) {
//		LASendEventWithName(DockTap);
//	}
//}
%new
-(void)dockReceivedDoubleTapGesture:(UITapGestureRecognizer*)arg1 {
	if ( arg1.state == UIGestureRecognizerStateEnded ) {
		LASendEventWithName(DockDoubleTap);
	}
}
//%new
//-(void)dockReceivedTripleTapGesture:(UITapGestureRecognizer*)arg1 {
//	if ( arg1.state == UIGestureRecognizerStateEnded ) {
//		LASendEventWithName(DockTripleTap);
//	}
//}
%end
