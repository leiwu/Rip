/*
 *  Copyright (C) 2009 Stephen F. Booth <me@sbooth.org>
 *  All Rights Reserved
 */

#import <Cocoa/Cocoa.h>

@interface InspectorView : NSView
{
@private
	NSSize _initialWindowSize;
}

- (void) addInspectorPaneController:(NSViewController *)paneController;
- (void) addInspectorPane:(NSView *)paneBody withTitle:(NSString *)title;

@end
