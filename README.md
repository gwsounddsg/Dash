# Dash

![](https://app.bitrise.io/app/0314e875da278a91/status.svg?token=IITYTwRrMOh3YL0XZfSF9g)


## Description

The TL;DR of this app is it listens to two sets of data, and outputs one.

The two types of data it listens to is raw [RTTrP] packets from [BlackTrax], and a prerecorded set of data in [OSC]. The user can toggle between these two data sets and the program will output [OSC] data to redundant [d&b][db] DS100 matrices using [Soundscape].


## Setup

Configure all the ports and IP addresses in the preferences menu.
  * Input port from BlackTrax
  * Input port from the prerecorded
  * Output IP address and port for the recorded data
  * Output IP address and port for both DS100's.


## Author

[GW Rodriguez](https://github.com/gwsounddsg)

## License

Dash is available under the MIT license. See the LICENSE file for more info.



[RTTrP]: (https://rttrp.github.io/RTTrP-Wiki/RTTrPM.html)
[BlackTrax]: (https://blacktrax.cast-soft.com/)
[OSC]: (http://opensoundcontrol.org/)
[db]: (https://www.dbaudio.com/global/en/)
[Soundscape]: (https://www.dbsoundscape.com/global/en/)
