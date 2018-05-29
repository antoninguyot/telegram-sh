# telegram-sh
telegram-sh is a lightweight and fast telegram bot that you can fully customize to your needs. It is written in such a way that it almost doesn't interact with your request so that it doesn't need to be updated everytime telegram adds something to their API.

## Setting it up

**Dependencies** :  
- jq  
- bash >= 4

To start your bot (and thus update polling), just start the script with bash : `bash telegram.sh`. You should get a message like `"Started long polling..."`.  

It is recommanded to use `tmux` or `screen` to keep the script running in the background.

## Getting data

You can see at the top of `telegram.sh` the following line : `path="commands.sh"`. This represent the script files that will be executed everytime someone sends a message to the bot.  
It supports wildcards, for example you could set it to `functions/*.func.sh` to execute every script ending with `.func.sh` in `functions`.  

The script files executed will be allowed to access variables related to the message sent to the bot. The variable structure uses an associative array (that requires bash 4) and is formatted in the following way :  

`${UPDATE_OBJECT[FIELD_NAME.OBJECT.VALUE]}`  

For instance, if you want to get the chat id of a message, the variable storing it will be `${message[chat.id]}`. If you need the message_id attribute of an edited message, then the variable will be `${edited_message[message_id]}`.

This can be a little tricky to use at first, but it's very logic when you get used to it. You can get the full Telegram API data structure by looking at [Bot API types](https://core.telegram.org/bots/api#available-types) on the bot API docs.

## Sending data

To send data to Telegram (messages to users for instance), you'll need to use the `post` function in your scripts. `post` accepts the following syntax :  

`post METHOD param1="some data" param2="some data"`

For example, here's a line that answer a message containing `Hello world` to anyone who sent a message to the bot :  
`post sendMessage chat_id="${message[from.id]}" text="Hello world"`  

You can get the full list of available methods on telegram [bots methods doc page](https://core.telegram.org/bots/api#available-methods). You must use the exact same name as described on the documentation with the post function (case-insensitive). You must also use the same arguments as described in the doc, passing them to `post` in the order that you want.  
Example :  
`post deleteMessage chat_id="xxx" message_id="xxx"` is the same as `post deleteMessage message_id="xxx" chat_id="xxx" `

## Example

You can find the default `commands.sh` that contains a sample program that sends an `Hello world` message to everyone that sends `/start`. You can take a look at it :  
```
case "${message[text]}" in
'/start')
post sendMessage chat_id="${message[chat.id]}" text="Your bot is working ! This a just a sample message that you can modify in the commands.sh file.
It allows multiline messages too (and is full UTF-8 compatible 😊)."
;;
esac
```
You can of course do much more advanced message proccessing after this.

Enjoy ! 😊