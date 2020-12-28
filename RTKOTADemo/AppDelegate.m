//
//  AppDelegate.m
//  RTKOTADemo
//
//  Created by Larry Mac Pro on 2020/12/2.
//

#import "AppDelegate.h"
#import "OTAVC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:[OTAVC new]];
    self.window.rootViewController = navVC;
    return YES;
}
@end
