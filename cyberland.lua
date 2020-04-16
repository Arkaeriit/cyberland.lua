#!/usr/local/bin/lua

local read = require('CyberlandRead')
local post = require('CyberlandPost')
read.filter("~/.config/cyberland.lua/filter")

function main()
    if arg[1] and arg[1] == "read" then
        if #arg == 3 and tonumber(arg[3]) then
            read.showLastLmt(genURL(arg[2]),tonumber(arg[3]))
        elseif #arg == 4 and tonumber(arg[3]) and tonumber(arg[4]) then
            read.showThreadTree(genURL(arg[2]),tonumber(arg[3]),arg[4])
        else
            io.stderr:write("Usage : cyberland read [board] [number of posts] [thread]\n")
        end
    elseif arg[1] and arg[1] == "post" then
        if #arg == 3 or #arg == 4 then
            post.post(genURL(arg[2]), arg[3], arg[4])
        else
            io.stderr:write("Usage : cyberland post [board] [message] [replyTo]\n")
        end
    elseif arg[1] and arg[1] == "picture" then
        if #arg == 4 or #arg == 5 then
            post.picture(genURL(arg[2]), arg[3], arg[4], arg[5])
        else
            io.stderr:write("Usage : cyberland picture [board] [picture] [message] [replyTo]\n")
        end
    elseif arg[1] and arg[1] == "catalog" then
        if #arg == 3 then
            read.showThread(genURL(arg[2]), tonumber(arg[3]), "0")
            read.showThread(genURL(arg[2]), tonumber(arg[3]), "null")
        else
            io.stderr:write("Usage : cyberland catalog [board] [number of posts]\n")
        end
    elseif arg[1] and arg[1] == "OP" then
        if #arg == 3 and tonumber(arg[3]) then
            read.printOp(genURL(arg[2]), arg[3])
        else
            io.stderr:write("Usage : cyberland OP [board] [thread]\n")
        end
    elseif arg[1] and arg[1] == "fullThread" then
        if #arg == 3 and tonumber(arg[3]) then
            local OP = read.fullThread(genURL(arg[2]), arg[3])
        else
            io.stderr:write("Usage : cyberland fullThread [board] [thread]\n")
        end
    else  
            io.stderr:write("Usage : cyberland read [board] [number of posts] [thread]\n")
            io.stderr:write(" or   : cyberland post [board] [message] [replyTo]\n")
            io.stderr:write(" or   : cyberland picture [board] [picture] [message] [replyTo]\n")
            io.stderr:write(" or   : cyberland catalog [board] [number of posts]\n")
            io.stderr:write(" or   : cyberland OP [board] [thread]\n")
            io.stderr:write(" or   : cyberland fullThread [board] [thread]\n")
    end
end

--generate a url depending on the name of the board
--for exemple i became https://cyberland2.club/i/
--dn became https://cyberland.digital/n/
function genURL(board) 
    if #board == 1 then
        return "https://cyberland2.club/"..board.."/"
    elseif #board == 2 then
        if board:sub(1,1) == "d" then
            return "https://cyberland.digital/"..board:sub(2,2).."/"
        elseif board:sub(1,1) == "l" then
            return "http://landcyber.herokuapp.com/"..board:sub(2,2).."/"
        else
            error("Error : unknown message board")
        end
    else
        return board
    end
end

main()

