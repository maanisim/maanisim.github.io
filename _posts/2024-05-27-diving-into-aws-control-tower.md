---
layout: single
title:  "Dive deep into AWS Control Tower"
---

I want you to imagine AWS Organizations as a kingdom that you have to manage, with the AWS accounts as the royal subjects whom you govern, AWS Control Tower is akin to a wise advisor of your kingdom.

While AWS Organizations allows for your kingdom to exists on the other hand AWS Control Tower is an extension of it, it helps in establishing rules on what you cannot do (via guardrails) establishing a set of best practices (via blueprints) and simplifies the process of creating additional royal subjects (AWS accounts via account factory)

We can see the whole account enrollement process below:

{% include figure popup=true image_path="./../assets/img/control-tower-account-enrollment-process.png" alt="Control Tower enrollment process" caption="Graphic by Control Tower guru [Vardan Kaushik](https://www.linkedin.com/in/vardankaushik)
" %}

- First AWS Control Tower relies on Service Catalog Provision Product to add new accounts, this works by provisioning (by default 13* can be more) CloudFormation stacksets in each new account, those StacksSets are consolidated into a block in step (6) 

- When a new AWS account gets created as part of Organization by default it assumes the same CloudTrail log paths as the managment account, this is intended default behaviour and can be disabled only on creation of the Control Tower
