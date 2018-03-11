# RubyTwitchChatBot
A simple chatbot for Twitch. Used for handling commands and previewing chat.

----

## Preview
![alt text](https://i.imgur.com/VrAybD8.png "Preview of the chat bot")

----

I use this chatbot to preview chat without having a browser open so that I save CPU and RAM.
But as you can see in the preview image it's also able to handle custom commands including API commands.

----

## How To Use:
1. Open **"credentials.txt"** and replace OAUTH, BOTNAME and CHANNEL with the values you need.
2. Run **"TwitchBot.rb"**


**Adding Commands:**
1. Open **"TwitchBot.rb"** and go to line 42-44, add your commands.
2. If you're adding commands to the `commands` array, go to folder **"Responses"** and add the command as a text file in all lowercase. _Examples have been included_ 
