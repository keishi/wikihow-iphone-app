//
//  FlurryAPI.h
//  Flurry iPhone Analytics Agent
//
//  Copyright 2008 Flurry, Inc. All rights reserved.
//
//  The Flurry iPhone Analytics Agent allows you to track the usage and behavior of your iPhone application
//  on user's phones for viewing the Flurry Analytics system. It is designed to be as easy as possible
//  with a basic setup complete in under 5 minutes.
//
//  The easiest way to integrate this with your code is to add a single call to startSession in
//  applicationDidFinishLaunching as follows:
//
//  - (void)applicationDidFinishLaunching:(UIApplication *)application {
//	  [FlurryAPI startSession:@"YOUR_API_KEY"];
//	  //your code
//  }
//
//  And you're all set! When you build and deploy your application it will report basic metrics
//  back to the Flurry servers which are then processed for display on the Flurry Analytics website.
//
//  If you'd like to get more detailed location information with your analytics, but require the user
//  to approve the access, you can use [FlurryAPI startSessionWithLocationServices:@"YOUR_API_KEY"];
//
//  Custom tracking of errors and events are also offered:
//
//  [FlurryAPI logEvent:@"YOUR_EVENT_NAME"];
//	Use logEvent to count the number of times certain events happen during a session of your application.
//  This can be useful for measuring how much users do various actions, for example.  Your application is
//  currently limited to counting occurrences for 100 different event ids (maximum length 255 characters).
//
//  [FlurryAPI logError:@"YOUR_ERROR_NAME" message:@"YOUR_ERROR_DESCRIPTION" exception:e];
//	Use logError to report application errors.  Flurry will report the first 10 errors to occur
//	in each session.
//

#import <UIKit/UIKit.h>

@interface FlurryAPI : NSObject {
}

// Call startSession with your project apiKey in applicationDidFinishLaunching
// + This call will initiate tracking of the current user session and send any previously saved
//   sessions to the Flurry analytics servers.
+ (void)startSession:(NSString *)apiKey;

// Use this instead of startSession if you want detailed location information in your analytics.
+ (void)startSessionWithLocationServices:(NSString *)apiKey;

// Call logError to track any errors in your application that you would like to view in your analytics.
// + Errors are uniquely identified and correlated by errorID so two different calls using the same
//   errorID will be considered the same error type.
+ (void)logError:(NSString *)errorID message:(NSString *)message exception:(NSException *)exception;

// Call logEvent to track any custom events in your application, such as user behaviors or application
// execution points. The eventName is considered unique so two different calls using the same
// eventName will be considered the same event type.
+ (void)logEvent:(NSString *)eventName;

// You should not need this function.
+ (void)setServerURL:(NSString *)url;

@end
