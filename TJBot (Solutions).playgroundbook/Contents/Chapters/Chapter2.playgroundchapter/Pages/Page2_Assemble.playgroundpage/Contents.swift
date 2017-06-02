//#-hidden-code
/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

//#-end-hidden-code
/*:
 # Assembling TJBot
 
 Step-by-step instructions for assembling your TJBot can be found in the following guides online.
 
 - [Assembling a 3D printed TJBot](http://www.instructables.com/id/Build-a-3D-Printed-TJBot/)
 
 - [Assembling a laser cut TJBot](http://www.instructables.com/id/Build-TJ-Bot-Out-of-Cardboard/)
 
 Watch how to fold the laser cut cardboard into TJBot.
 ![Assembly Video](assembly.mp4)
 
 * Important:
 As you assemble your TJBot, pay close attention to when you need to install the servo motor. If you have a servo motor, you must insert it after you attach the base of TJBot's body to the legs, and *before* you add the first internal layer. See the section on the servo motor below for specific insturctions for how to attach the servo.
 
 - - - 
 
 # Wiring the electronics
 
 The diagram below shows how the different hardware components are mounted in TJBot's body and connected to the Raspberry Pi.
 
 ![image](wiring.png)
 
 * Callout(💡Tip):
 Check out [Pinout.xyz](http://pinout.xyz) for an interactive diagram of pin numbers for your Raspberry Pi.
 
 ## Hooking up the LED
 
 The LED is mounted in the thin slit of the top-most internal layer. Insert the LED with the flat side facing to the right. After inserting the LED, spread out the individual pins to make it easier to attach the female-to-female jumper wires. Route the jumper wires through the small circular hole in the second internal layer to get them to the Raspberry Pi.
 
 - The left-most pin on the LED is the data pin and it connects to PIN 12 (BCM 18) on the Raspberry Pi.
 - The second pin from the left is for power (+3.3v) and it connects to PIN 1.
 - The third pin from the left is for ground and may connect to any of the ground pins on your Raspberry Pi. We recommend PIN 6.
 - The rightmost pin is unused.
 
 * Important:
 Be careful when connecting the LED! If it is connected the wrong way, you may burn it out. The LED has a flat notch on one side that you can use for orienting it with the wiring diagram.
 
 ## Installing the Servo
 
 The servo sits inside TJBot's body. It needs to be inserted after the legs are attached to the base, and before the first internal layer is slid down. Insert the servo such that the wires are closest to the base of TJBot's body. Then, slide down the first internal layer, locking the servo into place.
 
 - The brown wire is for ground and may be connected to any of the ground pins on your Raspberry Pi. We recommend PIN 14.
 - The red (middle) wire is for power (+5v) and it connects to PIN 2.
 - The orange wire is the data pin and it connects to PIN 26 (BCM 7).
 
 * Callout(💡 Tip):
 Use the female-to-male jumper wires to make it easier to connect the servo wires to the Raspberry Pi, but pay attention to the different colors!

 ## Installing the Camera
 
 The camera sits in the mounting bracket behind TJBot's eye. To connect the camera, insert the mounting rails into the mounting holes. Then, make sure the ribbon cable is attached to the camera, slide the ribbon cable through the slit in the body, and pull it upward toward the camera connector on the Raspberry Pi. Then, slide the camera in between the mounting rails and lock it into place with the remaining camera mount pieces. Finally, connect the ribbon cable to the Raspberry Pi such that the metal contacts on the ribbon are facing upwards.
 
 * Callout(💡Tip):
 The correct orientation of the camera is with the ribbon cable connector facing downward. However, on some 3D printed bots, the camera mounting bracket may be difficult to assemble because of the mounted electronics on the camera board. In this case, you may reverse the orientation of the camera so the ribbon cable connector is facing upward. If you do this, you can set `tj.configuration.see.camera.verticalFlip` to `true` in your tjbot-daemon configuration to fix the orientation.
 
 
 - - -
 
 [Next step: Install TJBot's software](@next)
 */
//#-code-completion(everything, hide)
