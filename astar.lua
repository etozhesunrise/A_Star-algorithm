--creating A* module
module ( "astar", package.seeall )

----------------------------------------------------------------
--------------------setting local variables---------------------
----------------------------------------------------------------

local INF = 1/0
local MaxHeight = 0
local MaxWidth = 0

----------------------------------------------------------------
---------------------- module functions-------------------------
----------------------------------------------------------------

--set max height and max width of Maze
function setHW(H, W)
	MaxHeight = H
	MaxWidth = W
end


--get the Node with lowest f cost
function lowestF (Nodes)

	local lowestScore = INF
	local bestNode = nil
	for i = 1, #Nodes, 1 do
		local score = Nodes[i].f
		if score < lowestScore then
			lowestScore = score
			bestNode = Nodes[i]
		end
	end
	return bestNode
end


--calculate heuristic distance between two nodes
function heuristics ( Node1, Node2 )
	return math.sqrt ( math.pow ( Node2.x - Node1.x, 2 ) + math.pow ( Node2.y - Node2.y, 2 ) )
end


--delete node from a given set
function removeNode ( NodeSet, NodeToRemove )
	for i = 1, #NodeSet, 1 do
		if NodeSet[i] == NodeToRemove then
			table.remove(NodeSet, i)
			break
		end
	end	
	return NodeSet
end


--check if set contains the Node
function bSetContains ( NodeSet, Node )

	for i = 1, #NodeSet, 1 do
		if NodeSet[i] == Node then
			return true
		end
	end
	return false
end


--set neighbors for the given node if they are in appropriate range and if they are not walls
function setNeigbors(AllNodes, Node)
	if(Node.x < MaxHeight and AllNodes[Node.x+1][Node.y].iswalkable == true) then
		table.insert(Node.neighbors, AllNodes[Node.x + 1][Node.y]) end
	if(Node.x > 1  and AllNodes[Node.x - 1][Node.y].iswalkable == true) then
		table.insert(Node.neighbors, AllNodes[Node.x - 1][Node.y]) end
	if(Node.y < MaxWidth  and AllNodes[Node.x][Node.y + 1].iswalkable == true) then
		table.insert(Node.neighbors, AllNodes[Node.x][Node.y + 1]) end
	if(Node.y < 1  and AllNodes[Node.x][Node.y - 1].iswalkable == true) then
		table.insert(Node.neighbors, AllNodes[Node.x][Node.y - 1]) end
end


--retrieve a Maze with the optimal path
function MazeWithPath(Start, End, Nodes, Path)
	result = {}
	for i = 1, MaxHeight, 1 do
		result[i] = {}
		for j = 1, MaxWidth, 1 do
			if Nodes[i][j] == Start then result[i][j] = 'I'
			elseif Nodes[i][j] == End then result[i][j] = 'E'
			elseif Nodes[i][j].iswalkable == true and bSetContains(Path, Nodes[i][j]) then result[i][j] = '.'
			elseif Nodes[i][j].iswalkable == true then result[i][j] = ' '
			else result[i][j] = '0'
			end
		end
	end
	return result
end

----------------------------------------------------------------
-------------------  A* pathfinding algorithm ------------------
----------------------------------------------------------------

function astar ( Start, End, Nodes)

	local openSet = { Start }
	local closedSet = {}

	Start.g = 0
	Start.h = heuristics(Start, End)
	Start.f = Start.g + Start.h


	while #openSet > 0 do

		local Current = lowestF (openSet)

		if Current == End then
			local path = {}
			print("Shortest path found!")
			local temp = Current
			while temp.parent ~= nil do
				table.insert(path, temp)
				temp = temp.parent
			end
			if(#path == 0) then
				return nil
			end
			return MazeWithPath(Start, End, Nodes, path)
		end

		openSet = removeNode (openSet, Current)
		table.insert (closedSet, Current)

		setNeigbors(Nodes, Current)
		local neighbors = Current.neighbors

		for f = 1, #neighbors, 1 do 
			if not bSetContains( closedSet, neighbors[f]) and neighbors[f].iswalkable == true then
				local tentative_g = Current.g + heuristics ( Current, neighbors[f])
				if bSetContains( openSet, neighbors[f] ) then
					if tentative_g < neighbors[f].g then
						neighbors[f].g = tentative_g end
				else
					neighbors[f].g = tentative_g
					table.insert ( openSet, neighbors[f] )
				end
				neighbors[f].h = heuristics ( neighbors[f], End )
				neighbors[f].f = neighbors[f].g + neighbors[f].h
				neighbors[f].parent = Current
	 		end
		end
	end
	--path does not exist
	return nil 
end