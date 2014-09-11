---
 license: Licensed to the Apache Software Foundation (ASF) under one
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
---


#cordova-plugin-parse-bridge
---------------------------

This cordova / phonegap plugin enables usage of Parse' Push Notification services (https://www.parse.com/products/push) to: <br>
 * set a channel <br>
 * send / push a message to a channel <br>

This plugin is intended to work -and is being tested- with Phonegap / Cordova 3.4.0.

To deploy into your Cordova project: <br>
`cordova plugin add https://github.com/BobSaintClare/cordova-plugin-parse-bridge.git`

As a prerequisite to succesfully installing and using the plugin, Parse should be installed and tested as per the Parse' 'quick start guide (see https://parse.com/apps/quickstart#parse_push).

This plugin was built only to handle some very basic use cases using Parse' Push Notifications service - namely, to listen to a notification channel, and sending notifications to a channel.
If you're looking to expand this to be more comprehensive, a great project to look at is https://github.com/phonegap-build/PushPlugin. 


###To Test your Plugin Installation

1) Declare the echo function in your js:

    window.echo = function(str, callback) {
        cordova.exec(callback, function(err) {
            callback('Nothing to echo.');
        }, "ParseBridge", "echo", [str]);
    };

2) Invoke the echo function:

    window.echo("echome", function(echoValue) {
        alert(echoValue == "echome"); // should alert true.
    };

3) When running your Cordova app via the iOS or Android simulator, you should get an Alert that says "true". <br>
If the Alert shows "false", it means something is wrong with your installation.

###Parse Device Registration
Device registration needs to be done directly in your native iOS and/or Android code as per the Parse documentation; e.g. 

####In iOS:
 
    - (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
        [Parse setApplicationId:@"yoursupersecretapplicationid"
	        clientKey:@"yoursupersecretclientkey"];
	    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
	        UIRemoteNotificationTypeAlert|
            UIRemoteNotificationTypeSound];
        // Remainder of your code here
		   ...

When the above code is invoked for the first time on a device, iOS prompts the user to authorize Push Notifications for the given app.<br>
Alternatively -and on iOS only at this time- you can control when this registration occurs; and therefore control when the user would be presented with the option to allow or not push notifications:<br>
1) Declare the registerForParsePushNotifications function in your js:

    window.registerForParsePushNotifications = function(callback) {
        cordova.exec(callback, function(err) {
           callback('Could not register for Parse Push Notifications');
        }, "ParseBridge", "registerPushNotifications",
           ["yoursupersecretapplicationid", "yoursupersecretclientkey"]);
    };

2) Invoke the registerForParsePushNotifications function:

    window.registerForParsePushNotifications(function(returnValue) {
      console.log(returnValue);
    });

As a side-note - this is quite involved to test on a repeated basis: http://stackoverflow.com/questions/2438400/reset-push-notification-settings-for-app <br>
To re-iterate, the above is for iOS ONLY at this time. You have to follow the steps below for Android.

####In Android:

	public class yourCDVApp extends CordovaActivity 
	{
	    @Override
	    public void onCreate(Bundle savedInstanceState)
	    {
	        super.onCreate(savedInstanceState);
	        super.init();
	        super.loadUrl(Config.getStartUrl());
	        
	        Parse.initialize(this, "yoursupersecretapplicationid", "yoursupersecretclientkey");
	        PushService.setDefaultPushCallback(this, CordovaActivity.class);
	        ParseInstallation.getCurrentInstallation().saveInBackground();

  			// Remainder of your code here
			...


###setParseChannel

1) To declare the setParseChannel function in your js:

     window.setParseChannel = function(str, callback) {
         cordova.exec(callback, function(err) {
             callback('Could not set channel');
         }, "ParseBridge", "setParseChannel", [str]);
     };

2) To invoke the function, and set the channel to "foo":

     window.setParseChannel("foo", function(returnValue) {
         console.log(returnValue); 
     });

The above is equivalent to invoking the following code in iOS:

    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:@"foo" forKey:@"channels"];
    [currentInstallation saveInBackground];

or in Android:

    PushService.subscribe(this.cordova.getActivity().getApplicationContext(), "foo", CordovaActivity.class);

###sendParseNotification
Sends a Parse notification to the specified channel; and -in iOS only- increment the application badge and play a sound.
The sound parameter is optional, but if provided, the sound file needs to be bundled into your iOS app.

1) To declare the sendParseNotification function in your js:

	 window.sendParseNotification = function(notificationMessage, channelName, soundFileName, callback) {
	     cordova.exec(callback, function(err) {
	         callback('Could not send notifications');
	     }, "ParseBridge", "sendParseNotification", [notificationMessage, channelName, soundFileName]);
	 };

2) To invoke the function, and send the notification "myNotification" to the "foo" channel:

	 window.sendParseNotification("myNotification", "foo", "soundfile.caf", function(returnValue) {
	     console.log(returnValue); 
	 });

The above is equivalent to invoking the following code in iOS:

    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
      @"myNotification", @"alert",
      @"Increment", @"badge",
      @"soundfile.caf", @"sound",
      nil];
    PFPush *push = [[PFPush alloc] init];
    [push setChannel:@"foo"];
    [push setData:data];
    [push sendPushInBackground];

or in Android:

    JSONObject data = new JSONObject();
    try {
        data.put("alert", "myNotification");
        data.put("badge", "Increment");
	    data.put("sound", "soundfile.caf");
    } catch (JSONException e) {
        e.printStackTrace();
    }
	ParsePush push = new ParsePush();
	push.setChannel("foo");
	push.setData(data);
	push.sendInBackground();
