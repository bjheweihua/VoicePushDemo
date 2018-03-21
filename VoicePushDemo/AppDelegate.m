//
//  AppDelegate.m
//  VoicePushDemo
//
//  Created by heweihua on 2018/3/22.
//  Copyright © 2018年 heweihua. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()<UIApplicationDelegate,UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    MainViewController* main = [[MainViewController alloc] init];
    UINavigationController* naviController = [[UINavigationController alloc] initWithRootViewController:main];
    [self.window setRootViewController:naviController];
    [self.window makeKeyAndVisible];
    
    // register push
    [self registerForRemoteNotifications:application];
    return YES;
}


-(void) registerForRemoteNotifications:(UIApplication *)application{
    
    if (@available(iOS 10.0, *)) {
        
        //iOS10特有
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
            if (granted) {
                // 点击允许
                NSLog(@"注册成功");
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    NSLog(@"注册成功-settings:%@", settings);
                }];
            } else {
                // 点击不允许
                NSLog(@"注册失败");
            }
        }];
    }
    else {
        //iOS8 - iOS9
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil]];
    }
    // 注册获得device Token
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}







-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
}


-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}


#pragma mark - iOS8 IOS9
// 程序处于启动状态,或者在后台运行时,会接收到推送消息,解析处理
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSLog(@"ios 8,9 userInfo = %@",userInfo);
    completionHandler(UIBackgroundFetchResultNewData);
}



#pragma mark - UNUserNotificationCenterDelegate iOS 10 收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    
    NSDictionary *userInfo = notification.request.content.userInfo;
    //    UNNotificationRequest *request = notification.request; // 收到推送的请求
    //    UNNotificationContent *content = request.content; // 收到推送的消息内容
    //    NSNumber *badge = content.badge;  // 推送消息的角标
    //    NSString *body = content.body;    // 推送消息体
    //    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    //    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    //    NSString *title = content.title;  // 推送消息的标题
    
    NSLog(@"userNotificationCenter:willPresentNotification:%@", notification.request.description);
    if (@available(iOS 10.0, *)) {
        
        if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            
            NSLog(@"iOS10 前台收到远程通知:%@", userInfo);
        }
        else{
            
            // 判断为本地通知
        }
        
        //        BOOL voiceOpen = [userInfo[@"voiceOpen"] boolValue];
        //
        //        // voice open play
        //        if (YES == voiceOpen) {
        //            notification.request.content.sound = [UNNotificationSound init];
        //        }
        //        else{
        //            notification.request.content.sound = [UNNotificationSound defaultSound];
        //        }
        completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
    } else {
        // Fallback on earlier versions
    }
}


#pragma mark - iOS 10通知的点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler{
    
    //    [self dealWithNotification:response.notification];
    completionHandler(); // 系统要求执行这个方法
}


@end

