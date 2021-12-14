--This file contains function that are not reading or writing posts. They are
--related to the other behaviors of the server.

local status = {}

local json = require('json')

--------------------------- Number of posts in a board -------------------------

--opens a file and if the file does not exists, create a directory for it
--and retry
local function open_or_mkdir(dir, name, rw_mode)
    local full_path = dir.."/"..name
    local f = io.open(full_path, rw_mode)
    if f then
        return f
    end
    os.execute('mkdir -p '..dir)
    os.execute("touch "..full_path)
    f = io.open(full_path, rw_mode)
    return f
end

--returns a name suitable for the data file. It's path is <data>/cyberland.lua
local function data_path()
    local config_dir = os.getenv("XDG_DATA_HOME")
    if config_dir then
        return config_dir.."/cyberland.lua"
    end
    local home_dir = os.getenv("HOME")
    if home_dir then
        return home_dir..".local/share/cyberland.lua"
    end
    io.stderr:write("Error, unable to find suitable directory to store data.\n")
    io.stderr:write("Defaulting to working directory.\n")
    return "cyberland.lua"
end

--returns the content of the database file.
local function db_read(server)
    local f = open_or_mkdir(data_path(), server..".db.json", "r")
    local db = f:read()
    f:close()
    if not db or #db < 2 then
        return {}
    end
    local ret = json.decode(db)
    return ret
end

--writes a table to the database file
local function db_write(tab, server)
    local f = open_or_mkdir(data_path(), server..".db.json", "w")
    local j = json.encode(tab)
    f:write(j)
    f:close()
end

--Taking as input two tables with integer value, returns a table with
--the difference of the value of second table to the values of the
--first
local function diff_table(tab1, tab2)
    local ret = {}
    for k,v in pairs(tab2) do
        ret[k] = 0
    end
    for k,v in pairs(tab1) do
        ret[k] = v
    end
    for k,v in pairs(tab2) do
        ret[k] = ret[k] - v
    end
    return ret
end

--Taking the result of the get of the URI `boards`, return a table with
--boards names as keys and number of post as value
local function format_board_report(board_report)
    local ret = {}
    for i=1,#board_report do
        k = board_report[i]["slug"]
        v = board_report[i]["post"]
        ret[k] = v
    end
    return ret
end

--Taking the table generated with the diff_table function, prints a report
--on possible new post, or lack of thereof
local function print_report(diff)
    local no_new_post = true
    for k,v in pairs(diff) do
        if v ~= 0 then
            no_new_post = false
            if v == 1 then 
                print("There is one new post on the board /"..k.."/." )
            else
                print("There is "..tostring(v).." new posts on the board /"..k.."/.")
            end
        end
    end
    if no_new_post then
        print("There is no new posts on the server.")
    end
end

--This function manages the local cache for the number of post in a server and
--prints nice results to inform if new post have been posted since the last time
--this function have been run
--Note: the argument server should be the server's URL without http:// or https://
--in front of it.
status.updated_posts = function(server)
    --Reading remote data
    local cmd = 'curl --silent '..server..'/boards'
    local c = io.popen(cmd, "r")
    local server_ret = c:read("a")
    local server_table = json.decode(server_ret)
    local server_fmt = format_board_report(server_table)
    --Reading local data
    local local_fmt = db_read(server)
    --Printing report
    print_report(diff_table(server_fmt, local_fmt))
    --Updating db
    db_write(server_fmt, server)
end

return status

