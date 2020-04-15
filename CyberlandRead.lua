--This file return two functions, read.showLast and read.showThreadTree used to read cyberland.club

local read = {}

local json = require('json')

--open the file and each line of this file is a post whose content will be filtered
local filter = {}
read.filter = function(filename)
    local f = io.open(filename, "r")
    filter = {}
    if not f then return end
    local str = f:read()
    filter[#filter+1] = str
    while str do
        str = f:read()
        filter[#filter+1] = str
    end
    f:close()
end

local function curl(board, thread, num)
    if not thread then
        thread = '' 
    else
        thread = 'thread='..thread..'&'
    end
    local command = 'curl "'..board..'?'..thread..'num='..tostring(math.tointeger(tonumber(num)))..'" --silent'
    local c = io.popen(command, "r")
    print(command)
    local char = c:read(1)
    while char and char ~= '[' do char = c:read(1) end --we drop the 'kek' from the start
    local ret = '['..c:read("a")
    return ret
end

-- return an approximation of the number of posts in a board
local function getNboard(board)
    return math.tointeger(tonumber(json.decode(curl(board, nil, 1))[1].id))
end

local function reverseTable(tab)
    local ret = {}
    for i=1,#tab do
        ret[i] = tab[#tab -i +1]
    end
    return ret
end

-- Bubble sort the tab by the ID of the field of tab
local function sortTable(tab)
    local tmp
    for i=1,#tab do
        for j=1,#tab-1 do
            if tonumber(tab[j].id) > tonumber(tab[j+1].id) then
                tmp = tab[j+1]
                tab[j+1] = tab[j]
                tab[j] = tmp
            end
        end
    end
    return tab
end

local function getBoard(board)
    local n = getNboard(board)
    -- if n < 1000 then n = 1000 end -- uncomment if the result are not sorted by decreasing ID
    local str = curl(board, nil, n)
    return sortTable(json.decode(str))
end

local function getThreadBasic(board, thread)
    local n = getNboard(board)
    local str = curl(board, thread, n)
    return reverseTable(json.decode(str))
end

--Display a post in a pretty way. Return true if the post is displayed and false otherwise
local function displayMessage(entry)
    for i=1,#filter do
        if entry.content == filter[i] then
            return false
        end
    end
    if not entry.prefix then -- a field custom to this reader
        entry.prefix = ''
    end
    local str = entry.prefix.."ID : "..entry.id.."\n"
    if entry.time then
        str = str..entry.prefix.."Time : "..entry.time..'\n'
    end
    if tonumber(entry.replyTo) and tonumber(entry.replyTo) > 1 then
        str = str..entry.prefix.."reply to : "..entry.replyTo.."\n"
    end
    str = str..entry.content.."\n"
    io.stdout:write(str)
    return true
end

read.showLast = function(board,n)
    local b = getBoard(board)
    local max = n; if #b < n then max = #b end;
    local i = 1
    while i <= max and i <= #b do
        if not displayMessage(b[#b-i+1]) then
            max = max+1
        else
            io.stdout:write('\n')
        end
        i = i+1
    end
end

--like showLast but doesn't download the entire board
read.showLastLmt = function(board, n)
    local b = reverseTable(sortTable(json.decode(curl(board, nil, n))))
    for i=1,#b do
        if displayMessage(b[i]) then
            io.stdout:write("\n")
        end
    end
end

--depreciated
read.showThread = function(board, n, thread)
    local b = getThreadBasic(board, thread)
    local max = n; if #b < n then max = #b end;
    local i = 1
    while i <= max and i <= #b do
        if not displayMessage(b[#b-i+1]) then
            max = max+1
        else
            io.stdout:write('\n')
        end
        i = i+1
    end
end

-- return a list of all the replies to a post
local function fetchReplies(boardTab, thread)
    local ret = {}
    for i=1,#boardTab do
        if tonumber(boardTab[i].replyTo) == tonumber(thread) then
            ret[#ret+1] = boardTab[i]
        end
    end
    return ret
end

-- look at the last element of lst and append every replies to it in lst with a bigger prefix field
local function threadTree(boardTab, lst)
    local entry = lst[#lst]
    if not entry.prefix then
        entry.prefix = ''
    end
    local replies = fetchReplies(boardTab, entry.id)
    if not replies or #replies == 0 then return end
    for i=1,#replies do
        if replies[i].id ~= entry.id then
            replies[i].prefix = entry.prefix.."      "
            lst[#lst+1] = replies[i]
            threadTree(boardTab, lst)
        end
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
    local postToFetch = getNboard(board) - thread + 1
    local boardTab = sortTable(json.decode(curl(board, nil, postToFetch)))
    local lst = {}
    lst[1] = fetchId(boardTab, thread)
    if tonumber(thread) == 0 then --We want a catalog
        lst[1] = {content = "catalog", id = "0", replyTo = "null"}
    end
    if thread == "null" then --We want a catalog
        lst[1] = {content = "catalog", id = "null", replyTo = "null"}
    end
    if not lst[1] then
        io.stderr:write("Error : thread number ",tostring(thread)," doesn't exists.\n")
        return
    end
    threadTree(boardTab, lst)
    lst = reverseTable(lst)
    local max = n; if #lst < n then max = #lst end;
    local i = 1
    while i <= max and i <= #lst do
        if not displayMessage(lst[#lst-i+1]) then
            max = max+1
        else
            io.stdout:write('\n')
        end
        i = i+1
    end
end

--Return the OP of a thread, we assume that the thread given in argument is a number if there is an error return true as a second argument
local function getOp(boardTab, thread)
    local entry = fetchId(boardTab, thread), true
    if not entry then return thread end
    if entry.replyTo == "0" or entry.replyTo == "null" then 
        return thread, false
    end
    return getOp(boardTab, tonumber(entry.replyTo))
end

--display the original OP of a given thread
read.printOp = function(board, thread)
    local boardTab = getBoard(board)
    local OP,error = getOp(boardTab, tonumber(thread))
    if error then
        io.stdout:write("The post ",tostring(OP)," reply to a thread not existing")
    else
        io.stdout:write(tostring(OP))
    end
    io.stdout:write('\n')
end

return read

