---
layout: single
title:  "Crafting a Serverless Discord Bot with AWS Lambda"
---

![Preview](./../assets/img/serverless-discord-architecture.png)

As of 2022 discord supports slashes functionality [1], this means that you no longer are stuck to listenining for message events as discord forwards the events to your endpoint themselves.

With those changes it's possible to invoke lambda only when you recieve a request making it much cheaper to utilize AWS Lambda to perform bot actions.

This repository is just a proof of this concept, this code can be used in many new ways such as user authorization, admin managment, or automatic game servers initialization with benefits on both costs and scaling. Example use case would be to start the game servers in a user friendly way for when you require it to play with your friends.

https://github.com/maanisim/serverless-discord
