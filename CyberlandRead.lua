--This file return two functions, read.showLast and read.showThreadTree used to read cyberland.club

local read = {}

local json = require('json')

function curl(board, thread, num)
    if not thread then
        thread = '' 
    else
        thread = 'thread='..thread..'&'
    end
    local c = io.popen('curl "https://cyberland.club/'..board..'/?'..thread..'num='..num..'" --silent',"r")
    local char = c:read(1)
    while char and char ~= '[' do char = c:read(1) end --we drop the 'kek' from the start
    local ret = '['..c:read("a")
    return ret
end

-- return an approximation of the number of posts in a board
function getNboard(board)
    return tonumber(json.decode(curl(board, nil, 1))[1].id)
end

function reverseTable(tab)
    local ret = {}
    for i=1,#tab do
        ret[i] = tab[#tab -i +1]
    end
    return ret
end

function getBoard(board)
    local n = getNboard(board)
    local str = curl(board, nil, n)
    return reverseTable(json.decode(str))
end

function getThreadBasic(board, thread)
    local n = getNboard(board)
    local str = curl(board, thread, n)
    return reverseTable(json.decode(str))
end

function displayMessage(entry)
    if not entry.prefix then -- a field custom to this reader
        entry.prefix = ''
    end
    local str = entry.prefix.."ID : "..entry.id.."\n"
    if tonumber(entry.replyTo) and tonumber(entry.replyTo) > 1 then
        str = str..entry.prefix.."reply to : "..entry.replyTo.."\n"
    end
    str = str..entry.content.."\n"
    io.stdout:write(str)
end

read.showLast = function(board,n)
    local b = getBoard(board)
    local max = n; if #b < n then max = #b end;
    for i=1,max do
        displayMessage(b[#b-i+1])
        io.stdout:write('\n')
    end
end

function showThread(board, n, thread)
    local b = reverseTable(getThreadBasic(board, thread))
    local max = n; if #b < n then max = #b end;
    for i=1,max do
        displayMessage(b[#b-i+1])
        io.stdout:write('\n')
    end
end

-- return a list of all the replies to a post
function fetchReplies(boardTab, thread)
    local ret = {}
    for i=1,#boardTab do
        if tonumber(boardTab[i].replyTo) == tonumber(thread) then
            ret[#ret+1] = boardTab[i]
        end
    end
    return ret
end

-- look at the last element of lst and append every replies to it in lst with a bigger prefix field
function threadTree(boardTab, lst)
    local entry = lst[#lst]
    if not entry.prefix then
        entry.prefix = ''
    end
    local replies = fetchReplies(boardTab, entry.id)
    if not replies or #replies == 0 then return end
    for i=1,#replies do
        replies[i].prefix = entry.prefix.."      "
        lst[#lst+1] = replies[i]
        threadTree(boardTab, lst)
    end
end

-- try to return a post with the right id
function fetchId(boardTab, id)
    for i=1,#boardTab do
        if tonumber(boardTab[i].id) == tonumber(id) then
            return boardTab[i]
        end
    end
    return nil
end

-- show a thread with all replies
read.showThreadTree = function(board, n, thread)
    boardTab = getBoard(board)
    local lst = {}
    lst[1] = fetchId(boardTab, thread)
    if not lst[1] then
        io.stderr:write("Error : thread number ",tostring(thread)," doesn't exists.\n")
        return
    end
    threadTree(boardTab, lst)
    local max = n; if #lst < n then max = #lst end;
    for i=1,max do
        displayMessage(lst[i])
        io.stdout:write('\n')
    end
end

return read

