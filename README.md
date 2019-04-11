## RubyTwitch

Twitch chatbot written in Ruby.

---

### Features

* Threading

* Global ban protection

* Easy command management

* Color output

---

### Setup

Create a file called **credentials.txt**, add the following three lines to it:

```
oauth:some_long_token_here
botname
channel
```

_Of course you're going to replace the oauth token, botname and channel with your own values._

That's it! Now you can run it, either by double clicking `main.rb` or by running `ruby main.rb` from the console.

---

### Configuration

The first couple of lines in `configurator.rb` contains two global variables. `prefix` and `max_messages`.

`prefix` is the symbol a person in chat uses to trigger a command.

`max_messages` is the max amount of messages to keep in the queue which the chat bot is going to respond to.

---

### To-Do

- [x] Add API commands

- [x] Add delay between requests

- [x] Add response loading from files
