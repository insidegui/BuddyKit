#import <TargetConditionals.h>

#if DEBUG && TARGET_OS_OSX
@import Cocoa;
@import os.log;

@interface PreviewBugFix : NSObject
@end

@implementation PreviewBugFix

/**
 Addresses a bug in recent Xcode versions where sometimes running a macOS app target right after previewing the same app target
 will cause the preview target to be activated and show up in the Dock, which can be annoying and confusing.

 This ensures that any preview instances of the app target are terminated shortly after the "normal" app instance starts up
 by looking for other app instances then sending them a distributed notification requesting app termination.

 It's done via a distributed notification because if the app is sandboxed then it can't arbitrarily terminate other apps,
 so this ensures collaboration between different instances of the same app. It's only included in debug builds and
 observing the termination notification is only done in targets that are running for previews.
 */
+ (void)load
{
    os_log_t log = os_log_create("codes.rambo.BuddyKit", "PreviewBugFix");

    NSString *bundleID = NSBundle.mainBundle.bundleIdentifier;
    NSString *notificationName = [NSString stringWithFormat:@"codes.rambo.PreviewBugFixPleaseTerminate-%@", bundleID];

    if ([NSProcessInfo.processInfo.environment[@"XCODE_RUNNING_FOR_PREVIEWS"] isEqualToString:@"1"]) {
        /// Running a preview instance, observe termination request notification.
        [NSDistributedNotificationCenter.defaultCenter addObserverForName:notificationName object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
            if (![notification.object isKindOfClass:[NSString class]]) return;
            pid_t senderPID = [notification.object intValue];
            if (senderPID == getpid()) return;

            os_log(log, "Received terminate notification, terminating.");

            exit(0);
        }];
    } else {
        /// Not running a preview instance, check if there are any other app instances and post termination request.
        NSArray <NSRunningApplication *> *apps = [NSRunningApplication runningApplicationsWithBundleIdentifier:bundleID];
        NSArray <NSRunningApplication *> *otherInstances = [apps filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"processIdentifier != %d", getpid()]];

        if (!otherInstances.count) return;

        os_log(log, "Posting preview terminate request.");

        [NSDistributedNotificationCenter.defaultCenter postNotificationName:notificationName object:[NSString stringWithFormat:@"%d", getpid()] userInfo:nil deliverImmediately:YES];
    }

}

@end
#endif // DEBUG && TARGET_OS_OSX
