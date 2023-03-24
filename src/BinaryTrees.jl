module BinaryTrees

using AbstractTrees

import AbstractTrees: nodevalue,
                      children,
                      parent,
                      nodetype,
                      NodeType,
                      ParentLinks

export BinaryNode, left!, right!

include("simple.jl")

end
