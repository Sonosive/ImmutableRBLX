--!strict
--Vector module. Implements Trie structure
local Trie = require(script.Parent.Trie)


local Vector = {}
Vector.__index = Vector


function Vector.new(luaTable)
    local self = {}

    self._luaTable = luaTable
    self._root = Trie.buildTree(luaTable)
     
    setmetatable(self, Vector)
    return self
end

function Vector:of(...)
    local args = {...}
    return self.new(args)
end


---Insert value at index in the Vector
---O(log10 n)
function Vector:set(index, value)
    self._root = Trie.setNode(self._root, index, value)
    return self
end


function Vector:get(index)
    return Trie.getNode(self._root, index)
end




setmetatable(Vector, {

    __call = function(_, luaTable)
        return Vector.new(luaTable)
    end,
})


return Vector