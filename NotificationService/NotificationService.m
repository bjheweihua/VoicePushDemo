//
//  NotificationService.m
//  NotificationService
//
//  Created by heweihua on 2018/3/22.
//  Copyright © 2018年 heweihua. All rights reserved.
//

#import "NotificationService.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

// 参考资料
// http://danny-lau.com/2017/06/13/ios-10-notification-2/
// https://mp.weixin.qq.com/s/yYCaPMxHGT9LyRyAPewVWQ
// https://www.jianshu.com/p/3e0a399380df
// https://developer.apple.com/library/content/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/ConfiguringanAudioSession/ConfiguringanAudioSession.html#//apple_ref/doc/uid/TP40007875-CH2-SW1
@interface NotificationService ()<AVSpeechSynthesizerDelegate>

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end



@implementation NotificationService


#pragma mark - 推送拦截
/*
 // 标准格式
 {"aps":{"alert":{"title":"标题","body":"你有一笔收款到账，请查收"},"badge":0,"mutable-content":1},"voiceOpen":"1"}
 
 // 有两个声音
 {"aps":{"alert":{"title":"标题","body":"你有一笔收款到账，请查收"},"badge":0,"mutable-content":1,"sound":"sonar_pop.aif"}, "voiceOpen":"1"}
 */

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    //    self.bestAttemptContent.body = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.userInfo[@"voiceOpen"]];
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    
    BOOL voiceOpen = [self.bestAttemptContent.userInfo[@"voiceOpen"] boolValue];
    
    // voice open play
    if (YES == voiceOpen) {
        
        // 声音去不掉(需要服务端控制)
        self.bestAttemptContent.subtitle = @"打开声音";
        
        // --------------------------------语音播放
        //文字转语音
        AVSpeechUtterance *utt = [AVSpeechUtterance speechUtteranceWithString:self.bestAttemptContent.body];
        utt.rate = 0.5;
        AVSpeechSynthesisVoice* voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];//chinese
        utt.voice = voice;
        AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
        [synth setDelegate:self];
        [synth speakUtterance:utt];
        // --------------------------------语音播放
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *setCategoryError = nil;
        if (![session setCategory:AVAudioSessionCategoryPlayback
                      withOptions:AVAudioSessionCategoryOptionDuckOthers // 对其他音乐App进行了压制
                            error:&setCategoryError]) {
        }
    }
    else{
        self.bestAttemptContent.subtitle = @"关闭声音";
        //设置默认提示声
    }
    
    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}


- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    
    //  恢复被自己打断的其他的播放器  其他的播放器继续播放
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

@end

