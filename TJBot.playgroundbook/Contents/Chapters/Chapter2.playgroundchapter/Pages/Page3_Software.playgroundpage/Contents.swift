//#-hidden-code
/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

//#-end-hidden-code
/*:
 Installing TJBot's software is easy! We have handy bootstrap scripts you can run on your Raspberry Pi to install everything you need to get your TJBot up and running.
 
 - - -
 
 # Install TJBot software
 
 1. Open a Terminal on your Raspberry Pi. If you have hooked up a monitor and keyboard to your Pi, you can click the terminal icon (![Terminal](terminal.png)) in the menu bar. If you have SSH set up, you can SSH into your Pi.
 
 2. Type the following command into the Terminal and press return.
 
 ```
 curl -sL http://ibm.biz/tjbot-bootstrap | bash -
 ```
 
 The script will ask you a series of questions about how to configure your Raspberry Pi. If you don't understand any of the questions, it's okay to use the default.
 
 * Important:
 The first question the script will ask is about naming your TJBot. The name that you pick is used as the hostname for your Raspberry Pi. This is how you will find your Raspberry Pi on your network. For example, if you name your TJBot "tinker", then your Raspberry Pi will be accessible on your local network as "tinker.local" and as a Bluetooth device named "tinker". Keep note of the name you give your TJBot — it will be needed in the next chapter.
 
 After the bootstrap script runs, you will find a "tjbot" folder on your Desktop (or in the location you specified). If you would like to run tests to make sure your TJBot's hardware is working, you can run the `runTests.sh` script in the bootstrap folder.
 
 ```
 cd ~/Desktop/tjbot/bootstrap
 ./runTests.sh
 ```
 
 - - -
 
 # Install TJBot daemon software
 
 The TJBot daemon will enable your TJBot to listen for commands via Bluetooth Low Energy (BLE).
 
 1. Install the TJBot daemon by running the following command in the Terminal.
 
 ```
 curl -sL http://ibm.biz/tjbot-daemon | bash -
 ```
 
 * Callout(😈 What's a "daemon"?):
 A daemon is a computer program that runs as a background process, rather than being under the direct control of the user. The TJBot daemon runs in the background on your TJBot listening for commands from your iPad.
 
 2. Log in to your [IBM Bluemix](https://bluemix.net) account and create instances of the following Watson services: Conversation, Language Translator, Speech to Text, Text to Speech, Tone Analyzer, and Visual Recognition.
 
 3. Copy the authentication credentials for each service into the `config.js` file in tjbot-daemon folder. The default location for this folder is on your Desktop.
 
 * Callout(🤖 TJBot and Watson):
 TJBot uses a number of [Watson services](https://www.ibm.com/watson/developercloud/services-catalog.html) to come to life. Each service requires an authentication credential, which you can obtain from [IBM Bluemix](https://bluemix.net). The TJBot bootstrap script provides instructions for how to create a Bluemix account, how to create instances of the Watson services needed by TJBot, and how to obtain the authentication credentials for each service. These authentication credentials are needed for the TJBot daemon and are stored on your TJBot in the `tjbot-daemon/config.js` file, not in this Playground.
 
 If you run into trouble with the tests and can't figure out what's wrong, please [open an issue on GitHub](https://github.com/ibmtjbot/tjbot/issues) and we'll do our best to help you out!
 
 
 - - -
 
 [Next chapter: Exploring the World](@next)
 */
//#-code-completion(everything, hide)

