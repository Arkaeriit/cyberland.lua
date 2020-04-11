#!/usr/local/bin/lua

local post = {}

post.post = function(board, message, replyTo)
    if not replyTo then
        replyTo = 0
    end
    os.execute('curl -d "content='..message..'&replyTo='..replyTo..'" -X POST "https://cyberland.club/'..board..'/" --silent')
end

return post

