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

package com.tinkomatic.cordova;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import org.apache.cordova.CordovaActivity;
import com.parse.ParsePush;
import com.parse.PushService;


public class ParseBridge extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
      if (action.equals("echo")) {
        String message = args.getString(0);
        this.echo(message, callbackContext);
        return true;
      }
      if (action.equals("setParseChannel")) {
        String channelName = args.getString(0);
        this.setParseChannel(channelName, callbackContext);
        return true;
      }
      if (action.equals("sendParseNotification")) {
        String notificationMessage = args.getString(0);
        String channelName = args.getString(1);
        String soundFileName = args.getString(2);
        this.sendParseNotification(notificationMessage, channelName, soundFileName, callbackContext);
        return true;
      }
      return false;
    }

    private void echo(String message, CallbackContext callbackContext) {
      if (message != null && message.length() > 0) {
        callbackContext.success(message);
      } else {
        callbackContext.error("Expected one non-empty string argument.");
      }
    }

    private void setParseChannel(String channelName, CallbackContext callbackContext) {
      if (channelName != null && channelName.length() > 0) {
        PushService.subscribe(this.cordova.getActivity().getApplicationContext(), channelName, CordovaActivity.class);
        callbackContext.success("Channel saved.");
      } else {
        callbackContext.error("Expected channelName argument.");
      }
    }

    //
    private void sendParseNotification(String notificationMessage, String channelName, 
    								String soundFileName, CallbackContext callbackContext) {

      if (notificationMessage != null && notificationMessage.length() > 0
        		&& channelName != null && channelName.length() > 0) {
        JSONObject data = new JSONObject();
        try {
            data.put("alert", notificationMessage);
            data.put("badge", "Increment");
          if (soundFileName != null && soundFileName.length() > 0) {
            data.put("sound", soundFileName);
          }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        ParsePush push = new ParsePush();
        push.setChannel(channelName);
        push.setData(data);
        push.sendInBackground();

        callbackContext.success("Notification sent.");
      } else {
        callbackContext.error("Expected argument.");
      }
    }
}
