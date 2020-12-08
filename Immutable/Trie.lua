--!strict

--[[Persistent trie structure implementation
    Note: Currently in base10 rather than the typical base32
]]

local Trie = {}

type Node = {
    nodes: {Node},
    value: any,
}

Trie.newNode = function() : Node
    local node : Node = {
        nodes = {},
        value = nil,
    }
    return node
end


local function shallowNodeCopy(node : Node) : Node
    local copiedNodes = {}

    for key, value in pairs(node.nodes) do
        copiedNodes[key] = value
    end

    local newNode : Node = {
        nodes = copiedNodes,
        value = node.value, --unsure about this
    }
    return newNode
end


---Generate a new trie with value set at index. New trie is
---persistent with the previous trie, shares node references
---when possible.
function Trie.setNode(root: Node, index: number, value)
    local newRoot : Node = shallowNodeCopy(root)

    local head : Node = root
    local newHead = newRoot

    local iterableBase10 = tostring(index):gmatch(".")

    --Traverse down trie paths for both new and old tries
    for digit in iterableBase10 do
        digit = tonumber(digit)

        local node = head.nodes[digit]

        if node then
            newHead.nodes[digit] = shallowNodeCopy(node)

            --Use head like an enumerator to continue copying from original
            head = head.nodes[digit]
        else
            --Original trie does not have node, so head no longer needed
            newHead.nodes[digit] = Trie.newNode()
        end

        newHead = newHead.nodes[digit]
    end
    
    newHead.value = value

    return newRoot
end

---Get node value at index from the trie at root
function Trie.getNode(root: Node, index: number)
    --Converts index into an iterable string
    local iterableBase10 = tostring(index):gmatch(".")
    local head : Node = root

    for digit in iterableBase10 do
        digit = tonumber(digit) --unsure if this is beneficial yet

        local node = head.nodes[digit]

        if node then
            head = node
        else
            warn("Node at index ".. index .. " does not exist")
            return nil
        end
         
    end
    return head.value
end

---Generate a persistent trie from a table.
function Trie.buildTree(luaTable)
    local root = Trie.newNode()

    local head
    for index, value in pairs(luaTable) do

        head = root
        local iterableBase10 = tostring(index):gmatch(".")

        --Traverse down trie along iterable with head
        --Trie not in use yet, so don't need immutability
        for digit in iterableBase10 do
            digit = tonumber(digit)

            local node = head.nodes[digit]
            if node then
                head = node
            else
                local newNode = Trie.newNode()
                head.nodes[digit] = newNode
                head = newNode
            end
        end

        head.value = value
    end

    return root
end


return Trie