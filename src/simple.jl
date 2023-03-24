mutable struct BinaryNode{T}
    data::T
    parent::Union{Nothing,BinaryNode{T}}
    left::Union{Nothing,BinaryNode{T}}
    right::Union{Nothing,BinaryNode{T}}

    function BinaryNode{T}(data, parent=nothing, l=nothing, r=nothing) where {T}
        new{T}(data, parent, l, r)
    end
end

BinaryNode(data) = BinaryNode{typeof(data)}(data)

value(node::BinaryNode) = node.data
left(node::BinaryNode) = node.left
parent(node::BinaryNode) = node.parent
right(node::BinaryNode) = node.right

"""

    left!(node, data)

Returns a new node with value `data` linked to the left of `node`.

"""
function left!(node::BinaryNode, data)
    isnothing(left(node)) ||
        error("left child is already assigned")
    node.left = typeof(node)(data, node)
end

"""

    right!(node, data)

Returns a new node with value `data` linked to the right of `node`.

"""
function right!(node::BinaryNode, data)
    isnothing(right(node)) ||
        error("right child is already assigned")
    node.right = typeof(node)(data, node)
end

_children(::Nothing, ::Nothing) = ()
_children(::Nothing, r::BinaryNode) = (r,)
_children(l::BinaryNode, ::Nothing) = (l,)
_children(l::BinaryNode, r::BinaryNode) = (l, r)

children(node::BinaryNode) =
    _children(left(node), right(node))
#
#ParentLinks(::Type{<:BinaryNode}) = StoredParents()
#
#NodeType(::Type{<:BinaryNode}) = HasNodeType()
#nodetype(::Type{<:BinaryNode{T}}) where {T} = BinaryNode{T}

"""

Inorder walk.

"""
function walk(f, node::BinaryNode)
    walk(f, left(node))
    f(value(node))
    walk(f, right(node))
    nothing
end

walk(f, ::Nothing) = nothing
