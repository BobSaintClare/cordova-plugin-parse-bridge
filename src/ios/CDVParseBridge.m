/*
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
 */

#import <Cordova/CDV.h>
#import <Parse/Parse.h>

@interface CDVParseBridge : CDVPlugin
- (void)echo:(CDVInvokedUrlCommand*)command;
- (void)registerPushNotifications:(CDVInvokedUrlCommand*)command;
- (void)setParseChannel:(CDVInvokedUrlCommand*)command;
- (void)sendParseNotification:(CDVInvokedUrlCommand*)command;
@end

@implementation CDVParseBridge

- (void)echo:(CDVInvokedUrlCommand*)command
{
  CDVPluginResult* pluginResult = nil;
  NSString* echo = [command.arguments objectAtIndex:0];

  if (echo != nil && [echo length] > 0) {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
  } else {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
  }

  [self.commandDelegate runInBackground:^{
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }];
}

- (void)registerPushNotifications:(CDVInvokedUrlCommand*)command
{
  CDVPluginResult* pluginResult = nil;
  NSString* applicationId = [command.arguments objectAtIndex:0];
  NSString* clientKey = [command.arguments objectAtIndex:1];

  if (applicationId != nil && [applicationId length] > 0
      && clientKey != nil && [clientKey length] > 0) {

    [Parse setApplicationId:applicationId
              clientKey:clientKey];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
      [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
      [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
//      [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
//       (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
                                                UIRemoteNotificationTypeAlert|
                                                UIRemoteNotificationTypeSound];
    }
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Registered for Push Notifications"];
  } else {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
  }
  [self.commandDelegate runInBackground:^{
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }];
}


- (void)setParseChannel:(CDVInvokedUrlCommand*)command
{
  CDVPluginResult* pluginResult = nil;
  NSString* channelName = [command.arguments objectAtIndex:0];

  if (channelName != nil && [channelName length] > 0) {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:channelName forKey:@"channels"];
    [currentInstallation saveInBackground];
    // TODO: not sure there's anyway to return anything other than success
    //  since we're fire and forget

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Channel saved"];
  } else {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
  }

  [self.commandDelegate runInBackground:^{
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }];
}

- (void)sendParseNotification:(CDVInvokedUrlCommand*)command
{
  CDVPluginResult* pluginResult = nil;
  NSString* notificationMessage = [command.arguments objectAtIndex:0];
  NSString* channelName = [command.arguments objectAtIndex:1];
  NSString* notificationSoundFileName = [command.arguments objectAtIndex:2];

  if (notificationMessage != nil && [notificationMessage length] > 0
      && channelName != nil && [channelName length] > 0) {

    NSDictionary *data;
    if (notificationSoundFileName != nil && [notificationSoundFileName length] > 0) {
      data = [NSDictionary dictionaryWithObjectsAndKeys:
        notificationMessage, @"alert",
        @"Increment", @"badge",
        notificationSoundFileName, @"sound",
        nil];
    } else {
      data = [NSDictionary dictionaryWithObjectsAndKeys:
        notificationMessage, @"alert",
        @"Increment", @"badge",
        nil];
    }
    PFPush *push = [[PFPush alloc] init];
    [push setChannel:channelName];
    [push setData:data];
    [push sendPushInBackground];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Notification sent"];
  } else {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
  }

  [self.commandDelegate runInBackground:^{
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }];
}

@end
