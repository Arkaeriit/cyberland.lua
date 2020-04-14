#!/usr/local/bin/lua

local read = require('CyberlandRead')
local post = require('CyberlandPost')
read.filter("~/.config/cyberland.lua/filter")

if arg[1] and arg[1] == "read" then
    if #arg == 3 and tonumber(arg[3]) then
        read.showLastLmt(arg[2],tonumber(arg[3]))
    elseif #arg == 4 and tonumber(arg[3]) and tonumber(arg[4]) then
        read.showThreadTree(arg[2],tonumber(arg[3]),arg[4])
    else
        io.stderr:write("Usage : cyberland read [board] [number of posts] [thread]\n")
    end
elseif arg[1] and arg[1] == "post" then
    if #arg == 3 or #arg == 4 then
        post.post(arg[2], arg[3], arg[4])
    else
        io.stderr:write("Usage : cyberland post [board] [message] [replyTo]\n")
    end
elseif arg[1] and arg[1] == "picture" then
    if #arg == 4 or #arg == 5 then
        post.picture(arg[2], arg[3], arg[4], arg[5])
    else
        io.stderr:write("Usage : cyberland picture [board] [picture] [message] [replyTo]\n")
    end
elseif arg[1] and arg[1] == "catalog" then
    if #arg == 3 then
        read.showThread(arg[2], tonumber(arg[3]), "0")
        read.showThread(arg[2], tonumber(arg[3]), "null")
    else
        io.stderr:write("Usage : cyberland catalog [board] [number of posts]\n")
    end
elseif arg[1] and arg[1] == "OP" then
    if #arg == 3 and tonumber(arg[3]) then
        read.printOp(arg[2], arg[3])
    else
        io.stderr:write("Usage : cyberland op [board] [thread]\n")
    end
else  
        io.stderr:write("Usage : cyberland read [board] [number of posts] [thread]\n")
        io.stderr:write(" or   : cyberland post [board] [message] [replyTo]\n")
        io.stderr:write(" or   : cyberland picture [board] [picture] [message] [replyTo]\n")
        io.stderr:write(" or   : cyberland catalog [board] [number of posts]\n")
        io.stderr:write(" or   : cyberland op [board] [thread]\n")
end

