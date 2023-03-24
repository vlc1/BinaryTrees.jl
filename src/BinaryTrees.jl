module BinaryTrees

#using AbstractTrees
#
#import AbstractTrees: nodevalue,
#                      children,
#                      parent,
#                      nodetype,
#                      NodeType,
#                      ParentLinks
#
import Base: setproperty!,
             parent,
             length,
             getindex,
             haskey,
             in,
             push!,
             insert!,
             delete!

export children
export BinaryNode, left!, right!, walk

export RBTree, search_node, minimum_node

include("simple.jl")
include("redblack.jl")

end
