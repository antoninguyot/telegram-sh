case "${message[text]}" in
'/start')
post sendMessage chat_id="${message[chat.id]}" text="Your bot is working ! This a just a sample message that you can modify in the commands.sh file.
It allows multiline messages too (and is full UTF-8 compatible 😊)."
;;
esac