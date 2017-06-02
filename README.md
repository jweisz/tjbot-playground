# tjbot-playground

> Swift Playground for interacting with TJBot! 🤖

<img src="images/playground.png" width="75%"/>

Interact with TJBot in this Swift Playground! This project showcases how Swift can be used to control IoT devices such as TJBot. Learn how to program TJBot and make him come to life using IBM Watson services such as [Speech to Text](https://www.ibm.com/watson/developercloud/speech-to-text.html), [Visual Recognition](https://www.ibm.com/watson/developercloud/visual-recognition.html), [Language Translator](https://www.ibm.com/watson/developercloud/language-translator.html), and more!

The TJBot Playground communciates with your TJBot using Bluetooth Low Energy (BLE), so you can program your TJBot just by sitting next to him!

# Installation

The easiest way to get this playground on your iPad is to [download this repository](https://github.com/jweisz/tjbot-playground/archive/master.zip) to your Mac and then use AirDrop to copy the playground to your iPad. After downloading, right click the “TJBot.playgroundbook” file, and choose “Share > AirDrop.” A list will open up which should show your iPad. Click your iPad to transfer the Playground.

> Note: Make sure AirDrop on your iPad is turned on first!

In addition to this Playground, you will need to install the [tjbot-daemon](https://github.com/jweisz/tjbot-daemon) project on your TJBot. Please refer to the [installation instructions](https://github.com/jweisz/tjbot-daemon/blob/master/README.md) to learn how to set up your TJBot with the daemon.

>  🤖 No robot, no problem! You can still explore the first two chapters of this playground without a physical TJBot.

# Usage

There are three chapters in the Playground.

1. **Tinker and Rebus** tells the story of Tinker the TJBot and his pal Rebus the Bee. Tinker is a virtual TJBot who lives in the screen of your iPad (physical TJBot not required!). Teach Tinker how to shine, wave, understand emotions, and translate languages in order to perform the Secret Dance of the TJBot and transform him into a real TJBot!
2. **Building TJBot** walks you through how to obtain your very own TJBot and set up its hardware and software.
3. **TJBot Explores the World** showcases the full functionality of your physical TJBot by listening, speaking, and seeing! Learn TJBot’s life story, tell him to change the color of his LED, ask him what he is looking at, and play a game of Rock Paper Scissors!

> Need solutions? We've included a separate playground called “TJBot (Solutions).playgroundbook” with solutions to all the exercises.

# Troubleshooting

#### The Playground doesn’t find my TJBot!

The TJBot playground communicates with the tjbot-daemon via Bluetooth LE (BLE). We have noticed in some cases that the Playground fails to find the TJBot. Try these steps to alleviate the problem.

1. Verify the name of your TJBot is entered correctly on Chapter 3 Page 1, and re-run the page to update the name of your TJBot.
2. Try leaving the name blank to search for the closest TJBot.
3. In rare instances, we have noticed Core Bluetooth failing to establish a connection to the TJBot. Rebooting the iPad is the only method we’ve found that resolves this issue.

#### My Playground code stopped working!

It is possible the tjbot daemon has crashed. If you are handy with  Terminal, you can run `tjbot-daemon.js` manually and look at the logs to determine where it crashed (and please, [open an issue](https://github.com/jweisz/tjbot-daemon/issues)!). If you’re not handy with Terminal, we recommend rebooting your Raspberry Pi to re-launch the daemon (which assumes that the daemon is set to run at startup, which is the default).

#### I don’t see any images when calling `tj.see()` or `tj.read()`

Images have a lot of data, and it’s too much to transmit over Bluetooth LE. Thus, in order for your iPad to load images from your TJBot, they both need to be on the same Wifi network.

> Note: The iPad will attempt to resolve your TJBot on the local network using its MDNS address. For example, if your TJBot is named “tinker”, then images are loaded from the base URL “http://tinker.local”. If your Wifi network (such as some Enterprise networks) drops MDNS packets, then you may not be able to load images from your TJBot. If you do not understand what MDNS is, don’t worry! Most home networking gear supports it. 😃

#### I have another problem that isn’t listed here.

Please  [open an issue](https://github.com/jweisz/tjbot-playground/issues) and we will do our best to address it.

# License
This project uses the [Apache License Version 2.0](LICENSE) software license.
