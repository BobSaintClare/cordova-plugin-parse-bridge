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


cordova-plugin-parse-bridge
---------------------------

This cordova / phonegap plugin allows to use Parse' Push Notification services (https://www.parse.com/products/push) as follow: <br>
 * register a device <br>
 * set a channel <br>
 * send / push a message to a channel <br>

This is intended to work -and is being tested- with Phonegap / Cordova 3.4.0.

To deploy into your Cordova project: <br>
`cordova plugin add https://github.com/BobSaintClare/cordova-plugin-parse-bridge.git`

**This is work in progress, at this only a dummy "echo" function is implemented**

To invoke in your javascript: <br>
1) Declare the echo function:

         window.echo = function(str, callback) {
             cordova.exec(callback, function(err) {
                 callback('Nothing to echo.');
             }, "ParseBridge", "echo", [str]);
         };

2) Invoke the echo function:

         window.echo("echome", function(echoValue) {
             alert(echoValue == "echome"); // should alert true.
         };

