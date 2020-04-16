# cyberland.lua

My cyberland.club client.

![Alt text](https://i.imgur.com/aoqvUbF.png "Reading a thread")

## User manual

To read the last 10 messages from the board /t/ do
```
cyberland read t 10
```


To read the fist 20 posts from the thread 720 on the board /t/ do
```
cyberland read t 20 720
```
Note: the replies to a thread are fetched recursively so you will see the replie to replies, the replies to replies to replies and so on.


To see a catalog of the 13 last OP on the board /o/ do
```
cyberland catalog o 13
```
Note: OP are posts replying to 0 or null


To post "Hitler was kind of a bad guy." to /n/ do
```
cyberland post n "Hitler was kind of a bad guy."
```


To reply "Cute" to the thread 1730 on the board /o/ do
```
cyberland post o "Cute" 1730
```

If you want to post a picture of the file cute.png to /i/ with the caption "How cute is it?" do
```
cyberland picture i cute.png "How cute is it?"
```
Note: You need to have viu (https://github.com/atanunq/viu) installed ans in your $PATH.
You can also reply to a post with an image by adding the ID of the post you reply to after the message. The message can be an empty string if you only wish to post a picture.


To know the OP from the thread 113 from the board /t/ do
```
cyberland OP t 113
```


To read the full context of the thread 456 from the board /t/ starting from the OP and with all answers do
```
cyberland fullThread t 456
```


You should now have all the info you need to use this client.

### Board selection

If you want to post to cyberland2.club simply put the letter of the board in the board field of your commands. Example: `i` for the image board. If you want yo post to cyberland.digital put a `d` besore the letter of the board. Example: `dc` for the client testing board. If you want to post to http://landcyber.herokuapp.com put a `l` before the letter of the board. Example: `lt` for the technology board. If you want to use an other text board you should put the full URL of the board. 

### Filters

To filter the content of some spammers, you can choose to ignore some posts by putting their content in the file `~/.config/cyberland.lua/filter`. A post will be filtered out only if it matches exactly one of the lines of the file.

### Instalation
You need to have lua 5.3 installed to your machine.

Doing `sudo make install` should install it. I assume that you have a lua interpreter to the path `/usr/local/bin/lua`. If it is not the case, you should correct the first line of cyberland.lua.

## Librairy
This program uses and includes the json.lua librairy made by github user rxi and published under the MIT licence.
https://github.com/rxi/json.lua

