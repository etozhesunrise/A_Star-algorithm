--include the A* pathfinding algorithm
--and set names of input and output files
astar = require 'astar'
MazeFileName = "Maze.txt"
EndFileName = "Output.txt"

--height and width of Maze we do not know yet
H, W = 1, 1

--prints maze with solved path to end file
function printPath(Maze, OutputFile)
    Output = io.open(OutputFile, "w+")
    io.output(Output)
    for i = 1, H, 1 do
        for j = 1, W, 1 do
            io.write(Maze[i][j])
            end
        io.write('\n')
    end
    io.close(Output)
end

--defining the Node class and its new() function

Node = {}

function Node:new(x,y, iswalkable, f,g,h, neighbors, parent)
    local obj = {}
    obj.x = x or 0
    obj.y = y or 0
    obj.iswalkable = iswalkable or false
    obj.f = f or 0
    obj.g = g or 0
    obj.h = h or 0
    obj.neighbors = {}
    obj.parent = nil
    setmetatable(obj, self)
    self.__index = self
    return obj
end

--open the file with Maze and read from it
File = io.open(MazeFileName, "r")
io.input(File)
local Line = File:read()

--creating 2D array of nodes + defining start and end points
--for this, each line is read one by one and then each symbol of current line is read one by one

W = #Line
local Nodes = {}
local StartNode = nil
local EndNode = nil
local i = 1
while(Line ~= nil) do
    H = i
    Nodes[i] = {}
    for j = 1, #Line, 1 do

        --the widest line is set to be global width variable
        if(#Line > W) then
            W = #Line
        end
        --if the char is 0, this node's iswalkable property is set to false
        if(string.sub(Line, j, j) == '0') then
            Nodes[i][j] = Node:new(i,j,false)

        --otherwise, iswalkable = true
        else 
            Nodes[i][j] = Node:new(i,j,true)
            if (string.sub(Line, j, j) == 'I') then
                StartNode = Nodes[i][j]
            elseif (string.sub(Line, j, j) == 'E') then
                EndNode = Nodes[i][j]
            end
        end
    end
    i = i + 1
    Line = File:read()
end

io.close(File)

--setting global height and width for A* algorithm
astar.setHW(H, W)

--get the path from A* algorithm
local path = astar.astar(StartNode, EndNode, Nodes)

--notify about an error or print the Maze to chosen file
if path == nil then print("Unfortunately, path cannot be retrieved")
else printPath(path, EndFileName) end

