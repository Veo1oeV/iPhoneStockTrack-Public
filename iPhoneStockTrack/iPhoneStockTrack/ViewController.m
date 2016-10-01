//
//  ViewController.m
//  iPhoneStockTrack
//
//  Created by Alexander Li on 2016-09-25.
//  Copyright © 2016 Yuhui Li. All rights reserved.
//

#import "ViewController.h"
#import <MailCore/MailCore.h>

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    [self fillBigLabel];
    [NSTimer scheduledTimerWithTimeInterval:60.0
                                     target:self
                                   selector:@selector(fillBigLabel)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)sendMail:(NSString *)descriptor {
    MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
    smtpSession.hostname = @"SMTPSERVER";
    smtpSession.port = 465;
    smtpSession.username = @"EMAIL";
    smtpSession.password = @"PASSWORD";
    smtpSession.authType = MCOAuthTypeSASLPlain;
    smtpSession.connectionType = MCOConnectionTypeTLS;
    
    MCOMessageBuilder *builder = [[MCOMessageBuilder alloc] init];
    MCOAddress *from = [MCOAddress addressWithDisplayName:@"SENDER"
                                                  mailbox:@"FROM EMAIL"];
    MCOAddress *to = [MCOAddress addressWithDisplayName:nil
                                                mailbox:@"RECIPIENT"];
    [[builder header] setFrom:from];
    [[builder header] setTo:@[to]];
    [[builder header] setSubject:[NSString stringWithFormat:@"%@ is now available", descriptor]];
    [builder setHTMLBody:@"Available"];
    NSData * rfc822Data = [builder data];
    
    MCOSMTPSendOperation *sendOperation =
    [smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        if(error) {
            NSLog(@"Error sending email: %@", error);
        } else {
            NSLog(@"Successfully sent email!");
        }
    }];
}

- (void)fillBigLabel {
    
    self.mainlabel.textColor = [NSColor textColor];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    [self.mainlabel setStringValue:[NSString stringWithFormat:@"%@\n\n",[dateFormatter stringFromDate:[NSDate date]]]];
    
    
    NSDictionary *iPhoneDic = @{
                                @"iPhone 7p JB 128G":@"MN4V2VC%2FA",
                                @"iPhone 7p JB 256G":@"MN512VC%2FA",
                                @"iPhone 7p MB 128G":@"MN4M2VC%2FA",
                                @"iPhone 7p MB 256G":@"MN4W2VC%2FA"};
    
    for(NSString *descriptor in iPhoneDic) {
        NSString *stockDisplay = [self getiPhoneStock:iPhoneDic[descriptor]];
        if (![stockDisplay isEqualToString:@""]&&![stockDisplay isEqual:@"unavailable"]&&![stockDisplay isEqual:@"ineligible"]) {
            
            // Instock
            
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = descriptor;
            notification.informativeText = [NSString stringWithFormat:@"In Stock!"];
            notification.soundName = NSUserNotificationDefaultSoundName;
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
            
            [self sendMail:descriptor];
            
            [self.mainlabel setStringValue:[NSString stringWithFormat:@"%@%@: %@\n", self.mainlabel.stringValue, descriptor, stockDisplay]];
            
            self.mainlabel.textColor = [NSColor colorWithRed:0 green:204/255.f blue:0 alpha:1];
            
        }
        else {
            [self.mainlabel setStringValue:[NSString stringWithFormat:@"%@%@: NOOO/inEligible\n", self.mainlabel.stringValue, descriptor]];
        }
    }
    
}

- (NSString *)getiPhoneStock:(NSString *)part {
    NSString *myURLString = [NSString stringWithFormat:@"http://www.apple.com/ca/shop/retail/pickup-message?parts.0=%@&location=N2L+3G1&little=true", part];
    NSURL *myURL = [NSURL URLWithString:myURLString];
    
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfURL:myURL encoding: NSUTF8StringEncoding error:&error];
    
    NSDictionary *requestReply = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    
    if ([requestReply objectForKey:@"head"]) {
        if ([[[requestReply objectForKey:@"head"]objectForKey:@"status"]isEqualToString:@"200"]) {
            return [[[[[[requestReply objectForKey:@"body"]objectForKey:@"stores"]objectAtIndex:0] objectForKey:@"partsAvailability"]objectForKey:[part stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"]]objectForKey:@"pickupDisplay"];
        }
    }
    
    return @"";
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
