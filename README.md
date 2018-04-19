# TwitchChatbot
A simple chatbot for Twitch written in Ruby. Used for handling commands and previewing chat so that you don't need to have the browser open and can avoid using a lot of RAM and CPU.

----

## Preview
![alt text](https://i.imgur.com/QOuqtfS.png "Preview of the chat bot")

----

I use this chatbot to preview chat without having a browser open so that I save CPU and RAM.
But as you can see in the preview image it's also able to handle custom commands including API commands.

----

## How To Use:
1. Open **"credentials.txt"** and replace OAUTH, BOTNAME and CHANNEL with the values you need.
2. Run **"TwitchBot.rb"**


**Adding Commands:**
1. Open **"CommandsHandler.rb"** and scroll down to the `commands` array and add your own.
2. Go to folder **"Responses"** and add the command as a text file in all lowercase. _Examples have been included_  
  
If you are adding admin commands add a custom response next to it. There you'll be able to add commands that gives data to the socket instead of a chat message as a response. Example:  
    `admin_commands = {
		"disconnect" => "PART ##{CHANNEL}"
		}`  
  
When the command `"!disconnect"` has been typed in chat by the channel owner it will send a request to disconnect from the current Twitch channel._   
  
![alt text](https://i.imgur.com/iYtSvaG.png "Prefix, commands and admin commands")  

----

## Extras:
_**The response files in the Responses folder have 3 arguments available**_ (You can add your own)  

![alt text](https://i.imgur.com/Pb6JPz8.png "Preview of command arguments")

In the template the arguments USER, CHANNEL, COMMANDS are available. _(COMMANDS shows all available commands)_  
  
![alt text](https://i.imgur.com/7oRcLvw.png "Here you can add your replacements")  
