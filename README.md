# Chessy

## Table of contents
- [Description](#description)
- [General info](#general-info)
- [Usage](#usage)
- [Technologies](#technologies)

## Description
This project is simple chess application in glassmorphism style for iOS where you can play locally with human opponent (bots, puzzles and online games are in todo list), below you can see some UI images of app running on iPhone 14 Pro (iOS 16.4).

<img src="./resources/app1.png" alt="app screen 1" width="250px"> <img src="./resources/app2.png" alt="app screen 2" width="250px"> <img src="./resources/app3.png" alt="app screen 3" width="250px">


## General info
You can play with some other player locally on your device using taps or drag gestures, additionally you can input FEN position to start playing from any position you want. You can also undo moves and add time by clicking on timer (although timer not really working because when its reaching 0 seconds nothing happens, will fix it later), also you can choose to rotate board pieces and time for second player. Btw game state and time saves when you close application. If you want to start new game just shake your phone or input empty FEN string in field.

## Usage
For installation and usage just clone this git repo and open it via xcode, choose device destination, build and run application.
```
git clone https://github.com/yasha424/Chessy
```

## Technologies
Project is created with:
* Swift: 5.9
* SwiftUI
* Combine
