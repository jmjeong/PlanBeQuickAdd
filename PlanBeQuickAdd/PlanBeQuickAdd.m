//
//  PlanBeQuickAdd.m
//  PlanBeQuickAdd
//
//  Created by Jaemok Jeong on 2014. 3. 1..
//  Copyright (c) 2014년 namu. All rights reserved.
//

// LibActivator by Ryan Petrich
// See https://github.com/rpetrich/libactivator

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <libactivator/libactivator.h>

@interface launchplanbe : NSObject<LAListener, UIAlertViewDelegate> {
@private
	UIAlertView *av;
}
@end

@implementation launchplanbe

- (BOOL)dismiss
{
	if (av)
	{
		[av dismissWithClickedButtonIndex:[av cancelButtonIndex] animated:YES];
		return YES;
	}
	return NO;
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
	{
		NSString *title = [[alertView textFieldAtIndex:0] text];
        
		if (title.length)
		{
            [self sendTextToPlanbe:title isTask:(buttonIndex == 2)];
		}
	}
    av = nil;
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
    if (!av){
        av = [[UIAlertView alloc] initWithTitle:@"PlanBe QuickAdd" message:@"15 title @home /work" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Event", @"Task", nil];
        av.alertViewStyle = UIAlertViewStylePlainTextInput;
        [av show];
        [event setHandled:YES];
    }
}

- (void)sendTextToPlanbe:(NSString *)text isTask:(BOOL)isTask
{
#define PLANBE_URL_TEMPLATE @"%@://x-callback-url/parse?title=%@&type=%@&prompt=n"
    
	NSString *encodedText = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    for (NSString *scheme in @[@"namuplanbe", @"namuplanbelite"]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:PLANBE_URL_TEMPLATE, scheme, encodedText, isTask?@"t":@"e"]];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
            return;
        }
    }
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event
{
	// Called when event is escalated to higher event
	[self dismiss];
}

- (void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event
{
	// Called when other listener receives an event
	[self dismiss];
}

- (void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event
{
	// Called when the home button is pressed.
	// If showing UI, then dismiss it and call setHandled:.
	if ([self dismiss])
		[event setHandled:YES];
}


+ (void)load
{
	@autoreleasepool
	{
		[[LAActivator sharedInstance] registerListener:[self new] forName:@"com.jmjeong.planbequickadd"];
	}
}

@end
