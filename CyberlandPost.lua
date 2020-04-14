#!/usr/local/bin/lua

local post = {}

post.post = function(board, message, replyTo)
    if not replyTo then
        replyTo = 0
    end
    local cmd = 'curl -d "content='..message..'&replyTo='..replyTo..'" -X POST "https://cyberland2.club/'..board..'/" '
    os.execute(cmd)
end

-- Generate a picture out of ANSII escpe code from a file
-- assume that viu is installed and in your $PATH
local function genPicture(filename)
    local viu = io.popen("viu '"..filename.."' -w 86","r")
    return viu:read("a")
end

post.picture = function(board, filename, message, replyTo)
    local pic = genPicture(filename)
    post.post(board, pic..message, replyTo)
end

return post

