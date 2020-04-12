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


You should now have all the info you need to use this client.

### Filters

To filter the content of some spammers, you can choose to ignore some posts by putting their content in the `filter` table, at the beginning of CyberlandRead.lua. A post will be filtered out only if it matches exactly one of the entries of the table.

### Instalation
You need to have lua 5.3 installed to your machine.

Doing `sudo make install` should install it. I assume that you have a lua interpreter to the path `/usr/local/bin/lua`. If it is not the case, you should correct the first line of cyberland.lua.

## Librairy
This program uses and includes the json.lua librairy made by github user rxi and published under the MIT licence.
https://github.com/rxi/json.lua

