#!/usr/local/bin/lua

local post = {}

--make a post and return true or false depending on the succes
local function send(board, message, replyTo)
    if not replyTo then
        replyTo = 0
    end
    local cmd = 'curl -d "content='..message..'&replyTo='..replyTo..'" -X POST "'..board..'" --silent'
    local c = io.popen(cmd,"r")
    if not c then return false end
    local ret = c:read("a")
    if board:sub(1,25) == "https://cyberland.digital" then --cyberland.digital responses are a bit weird so I do this to try and interprete it
        if ret:sub(1,1) == '<' then
            return false
        else
            print(ret)
            return true
        end
    elseif board:sub(1,31) == "http://landcyber.herokuapp.com/" then
        if ret == "OK" then
            return true
        else
            print(ret)
            return false
        end
    else
        if ret == "OK" then
            return true
        else
            print(ret)
            return false
        end
    end
end

post.post = function(board, message, replyTo)
    if send(board, message, replyTo) then
        io.stdout:write("Message send successfully.\n")
    else
        io.stdout:write("Error : message not send.\n")
    end
end

-- Generate a picture out of ANSII escpe code from a file
-- assume that viu is installed and in your $PATH
local function genPicture(filename, size)
    local viu = io.popen("viu '"..filename.."' -t -w "..size,"r")
    return viu:read("a")
end

post.picture = function(board, filename, message, replyTo)
    local size = 120
    local success = false
    for i=1,110 do
        local pic = genPicture(filename, size)
        success = send(board, pic..message, replyTo)
        if success then
            io.stdout:write("Message send successfully.\n")
            break
        end
        size = size - 1
        os.execute('sleep 1.2') --to try and not overload servers
    end
    if not success then
        io.stdout:write("Error : message not send.\n")
    end
end

return post

