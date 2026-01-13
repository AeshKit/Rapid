<p align="center">
  <img 
    src="https://raw.githubusercontent.com/AeshKit/Rapid/v1.0/resources/drawables/ClockModern.png"
    width="112"
    style="image-rendering: pixelated;">
</p>

# Rapid

A FIDE-Style* Fischer chess clock for Garmin watches

Inspired by the FOSS Android application [Blitz](https://github.com/ldeso/blitz)

## -- Features --

* Variable starting time and increment

* Pausing and changing side time and increment mid-game

* Smooth animations

* Different interfaces for watches that don't support certain features

* Support for the Spanish language

**Button Controls**

* **Start / Stop**: Starts the game or switches sides
* **Back**: Stops the game. Double-clicking exits the application
* **Up / Menu**: Holding opens the settings menu
* **Down**: Pauses the game if pressed while running
* **Up / Down**: Changes the time or increment if in changing mode [ Accessable in the settings menu ]

**Touchscreen Controls**

* Any touch or swipe will switch sides while the game is running
* **Tap**: Starts the game, switches sides or verifies time / increment change
* **Sliding / Swiping** Changes time or increment depending on direction
* **Double-Swipe Left-to-Right**: Exits the application

**Touchscreen Controls for Watches without Gestures**

While the game is paused, the screen is split into four quadrants as such

<p>
  <img 
    src="https://raw.githubusercontent.com/AeshKit/Rapid/v1.0/resources/drawables/CircleCross.png"
    width="100"
    style="image-rendering: pixelated;">
</p>


Assuming the text is facing upright, then:

* **Left / Right Tap**: Changes the starting time

* **Top / Bottom Tap**: Changes the increment

* **Tap During Game**: Switches sides

Just like in the full app, you can switch one side's time or increment in the settings menu after the game has started. Button controls remain unchanged


## -- Technical --
- *Why can't I use this app in official settings ?*

*Fide has [strict rules](https://handbook.fide.com/files/handbook/C02Standards.pdf) as to what qualities a digital clock must have to be considered for tournament use. Even if we made the perfect application, the limitations of Monkey C and the Garmin watches still make it impossible to be completely FIDE-Compliant. Here are some standards that Rapid could realistically never achieve:

* **5.4.3.3**: The displays must be legible from a distance of at least 3 meters.
* **5.4.3.11**: It must be impossible to erase or change the data in display with a simple manipulation.
* **5.4.3.12**: Clocks must have a brief user manual on the clock.
* **5.4.3.14**: Electronic chess clocks used for FIDE events must be endorsed by the FIDE Technical Commission.

And, due to the limitations of the hardware, the timer can be inaccurate by up to 98ms in some scenarios.

- *If there's a system event that pauses the app timer [ E.G. notification ], how does that affect the app ?*

This will make the current time displayed incorrect until the user switches sides. This is because while the timer is dynamically changing, the app uses System.getTimer() to keep track of the time. This function outputs the amount of milliseconds that the watch has been on for.

## -- Liscense --

```
Copyright (C) 2026  Kaiden Santos

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, see
<https://www.gnu.org/licenses/>.
```