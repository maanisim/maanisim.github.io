---
layout: single
title:  "Crafting a Serverless Discord Bot with AWS Lambda"
---

![Preview](./../assets/img/serverless-discord-architecture.png)

As of 2021 [discord supports slashes functionality](https://discord.com/blog/slash-commands-are-here), this means that you no longer are stuck to listenining for message events as discord will forward the events to your endpoint.

With those changes it's possible to invoke lambda only when you recieve a request making it possible to utilize AWS Lambda to perform bot actions which saves you computing power and also scale as much as you require.

This [repository is a proof of this concept](https://github.com/maanisim/serverless-discord), this code can be used in many new ways such as:
- User verification based on your criteria of choice
- Game servers initialization
