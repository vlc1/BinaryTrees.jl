# search_data <-> find
# it has unique keys
# left has keys which are less than the node
# right has keys which are greater than the node
# color is true if it's a Red Node, else it's false
# Think of it as a pointer or 0d array.
mutable struct RedBlackNode{T}
    color::Bool
    data::Union{Nothing,T}
    parent::Union{Nothing,RedBlackNode{T}}
    left::Union{Nothing,RedBlackNode{T}}
    right::Union{Nothing,RedBlackNode{T}}

    RedBlackNode{T}() where {T} = new{T}(true, nothing, nothing, nothing, nothing)

    RedBlackNode{T}(d::T) where {T} = new{T}(true, d, nothing, nothing, nothing)
end

const RBNode = RedBlackNode
#
#RBNode() = RBNode{Any}()
#RBNode(d) = RBNode{Any}(d)

setproperty!(x::RBNode, f::Symbol, v) =
    setfield!(x, f, v)

color(node::RBNode) = node.color
###
# eltype(::RBNode{T}) where {T} = T
getindex(node::RBNode) = node.data
parent(node::RBNode) = node.parent
left(node::RBNode) = node.left
right(node::RBNode) = node.right

children(node::RBNode) = (left(node), right(node))
###


"""

Color a node red (`bool == true`) or black (`bool = false`).

"""
color!(node::RBNode, bool) = (node.color = bool; node)
parent!(node::RBNode, parent::Union{Nothing,RBNode}) = (node.parent = parent)
left!(node::RBNode, child::Union{Nothing,RBNode}) = (node.left = child)
right!(node::RBNode, child::Union{Nothing,RBNode}) = (node.right = child)

isred(node::RBNode) = color(node)
isblack(node::RBNode) = !color(node)

red!(node::RBNode) = color!(node, true)
black!(node::RBNode) = color!(node, false)

"""

Create a black sentinel.

"""
nil(T::Type) = black!(RBNode{T}())

"""

Includes sentinel. Should field `nil` be annotated with `const`?

"""
mutable struct RedBlackTree{T}
    root::RBNode{T}
    nil::RBNode{T}
    count::Int

    function RedBlackTree{T}() where {T}
        rb = new()
        rb.nil = nil(T)
        rb.root = rb.nil
        rb.count = 0
        return rb
    end
end

const RBTree = RedBlackTree

RBTree() = RBTree{Any}()

# eltype(::RBTree{T}) where {T} = T
root(tree::RBTree) = tree.root
nil(tree::RBTree) = tree.nil
length(tree::RBTree) = tree.count

eachindex(tree::RBTree) = Base.OneTo(length(tree))

root!(tree::RBTree, node::RBNode) = (tree.root = node; tree)

isnilof(node::RBNode, tree::RBTree) = isequal(node, nil(tree))
isrootof(node::RBNode, tree::RBTree) = isequal(node, root(tree))


"""

    search_node(tree, key)

Returns the last visited node, while traversing through in binary-search-tree fashion looking for `key`.

"""
search_node(tree, key)

function search_node(tree::RBTree, data)
    node = root(tree)

    while !isnilof(node, tree) && !isequal(data, getindex(node))
        node = if data < getindex(node)
            left(node)
        else
            right(node)
        end
    end

    node
end

"""

    haskey(tree, key)

Returns `true` if `key` is present in the `tree`, else returns `false`.

!!! note

    Sentinel is useful here because `getindex(nil(tree))` is defined..

"""
function haskey(tree::RBTree, data)
    node = search_node(tree, data)
    isequal(getindex(node),  data)
end

"""

    insert_node!(tree::RBTree, node::RBNode)

Inserts `node` at proper location by traversing through the `tree` in a binary-search-tree fashion.

"""
function insert_node!(tree::RBTree, x::RBNode)
    y, z = root(tree), nothing

    while !isnilof(y, tree)
        z = y
        y = if getindex(x) < getindex(y)
            left(y)
        else
            right(y)
        end
    end

    parent!(x, z)

    if isnothing(z)
        root!(tree, x)
    elseif getindex(x) < getindex(z)
        left!(z, x)
    else
        right!(z, x)
    end

    nothing
end

"""

    left_rotate!(tree::RBTree, x::RBNode)

Performs a left-rotation on `x` and updates `root(tree)`, if required.

"""
function left_rotate!(tree::RBTree, x::RBNode)
    y = right(x)
    right!(x, left(y))

    if !isnilof(left(y), tree)
        parent!(left(y), x)
    end

    parent!(y, parent(x))

    if isnothing(parent(x))
        root!(tree, y)
    elseif isequal(x, left(parent(x)))
        left!(parent(x), y)
    else
        right!(parent(x), y)
    end

    left!(y, x)
    parent!(x, y)

    nothing
end

"""

    right_rotate!(tree::RBTree, x::RBNode)

Performs a right-rotation on `x` and updates `root(tree)`, if required.

"""
function right_rotate!(tree::RBTree, x::RBNode)
    y = left(x)
    left!(x, right(y))

    if !isnilof(right(y), tree)
        parent!(right(y), x)
    end

    parent!(y, parent(x))

    if isnothing(parent(x))
        root!(tree, y)
    elseif isequal(x, left(parent(x)))
        left!(parent(x), y)
    else
        right!(parent(x), y)
    end

    right!(y, x)
    parent!(x, y)

    nothing
end

"""

   fix_insert!(tree::RBTree, node::RBNode)

This method is called to fix the property of having no two adjacent nodes of red color in the `tree`.

"""
function fix_insert!(tree::RBTree, node::RBNode)
    mum = nothing
    nan = nothing

    # for root node, we need to change the color to black
    # other nodes, we need to maintain the property such that
    # no two adjacent nodes are red in color
    while !isrootof(node, tree) && isred(parent(node))
        mum = parent(node)
        nan = parent(mum)

        # parent is the left of grand-parent
        if isequal(mum, left(nan))
            aunt = right(nan)

            # aunt is red
            if isred(aunt)
                red!(nan)
                black!(mum)
                black!(aunt)
                node = nan
            # aunt is black
            else
                # node is right of its parent
                if isequal(node, right(mum))
                    node = mum
                    left_rotate!(tree, node)
                end
                # node is left of its parent
                black!(parent(node))
                red!(parent(parent(node)))
                right_rotate!(tree, parent(parent(node)))
            end

        # parent is the right of grand_parent
        else
            aunt = left(nan)

            # aunt is red in color
            if isred(aunt)
                red!(nan)
                black!(mum)
                black!(aunt)
                node = nan
            # aunt is black in color
            else
                # node is left of its parent
                if isequal(node, left(mum))
                    node = mum
                    right_rotate!(tree, node)
                end
                # node is right of its parent
                black!(parent(node))
                red!(parent(parent(node)))
                left_rotate!(tree, parent(parent(node)))
            end
        end
    end

    black!(root(tree))

    nothing
end

"""
    insert!(tree, key)

Inserts `key` in the `tree` if it is not present.
"""
function insert!(tree::RBTree{T}, data::T) where {T}
    # if the key exists in the tree, no need to insert
    haskey(tree, data) && return tree

    # insert, if not present in the tree
    node = RBNode{T}(data)
    left!(node, nil(tree))
    right!(node, nil(tree))

    insert_node!(tree, node)

    if isnothing(parent(node))
        black!(node)
    elseif isnothing(parent(parent(node)))
        ;
    else
        fix_insert!(tree, node)
    end

    tree.count += 1

    tree
end

"""

    push!(tree, key)

Inserts `key` in the `tree` if it is not present.
"""
function push!(tree::RBTree{T}, key0) where {T}
    key = convert(T, key0)
    insert!(tree, key)
end

"""

    delete_fix(tree::RBTree, node::Union{RBNode, Nothing})

This method is called when a black node is deleted because it violates the black depth property of the RBTree.

"""
function delete_fix(tree::RBTree, node::Union{RBNode, Nothing})
    while !isrootof(node, tree) && isblack(node)
        if isequal(node, left(parent(node)))
            sibling = right(parent(node))

            if isred(sibling)
                black!(sibling)
                red!(parent(node))
                left_rotate!(tree, parent(node))
                sibling = right(parent(node))
            end

            if all(isblack, children(sibling))
                red!(sibling)
                node = parent(node)
            else
                if isblack(right(sibling))
                    black!(left(sibling))
                    red!(sibling)
                    right_rotate!(tree, sibling)
                    sibling = right(parent(node))
                end

                color!(sibling, color(parent(node)))
                black!(parent(node))
                black!(right(sibling))
                left_rotate!(tree, parent(node))
                node = root(tree)
            end

        else
            sibling = left(parent(node))

            if isred(sibling)
                black!(sibling)
                red!(parent(node))
                right_rotate!(tree, parent(node))
                sibling = left(parent(node))
            end

            if all(isblack, children(sibling))
                red!(sibling)
                node = parent(node)
            else
                if isblack(left(sibling))
                    black!(right(sibling))
                    red!(sibling)
                    left_rotate!(tree, sibling)
                    sibling = left(parent(node))
                end

                color!(sibling, color(parent(node)))
                black!(parent(node))
                black!(left(sibling))
                right_rotate!(tree, parent(node))
                node = root(tree)
            end
        end
    end

    black!(node)

    nothing
end

"""

    transplant(tree::RBTree, u::Union{RBNode, Nothing}, v::Union{RBNode, Nothing})

Replaces `u` by `v` in the `tree` and updates the `tree` accordingly.

"""
function transplant(tree::RBTree, u::Union{RBNode, Nothing}, v::Union{RBNode, Nothing})
    if isnothing(parent(u))
        root!(tree, v)
    elseif isequal(u, left(parent(u)))
        left!(parent(u), v)
    else
        right!(parent(u), v)
    end

    parent!(v, parent(u))
end

"""

   minimum_node(tree::RBTree, node::RBNode)

Returns the `RBNode` with minimum value in subtree of `node`.

"""
function minimum_node(tree::RBTree, node::RBNode)
    isnilof(node, tree) && return node

    while !isnilof(left(node), tree)
        node = left(node)
    end

    return node
end

"""

    delete!(tree::RBTree, key)

Deletes `key` from `tree`, if present, else returns the unmodified tree.

"""
function delete!(tree::RBTree{T}, data::T) where {T}
    z = nil(tree)
    node = root(tree)

    while !isnilof(node, tree)
        if isequal(getindex(node), data)
            z = node
        end

        node = if data < getindex(node)
            left(node)
        else
            right(node)
        end
    end

    isnilof(z, tree) && return tree

    y = z
    ywasred = isred(y)
    x = RBNode{T}()

    if isnilof(left(z), tree)
        x = right(z)
        transplant(tree, z, right(z))
    elseif isnilof(right(z), tree)
        x = left(z)
        transplant(tree, z, left(z))
    else
        y = minimum_node(tree, right(z))
        ywasred = isred(y)
        x = right(y)

        if isequal(parent(y), z)
            parent!(x, y)
        else
            transplant(tree, y, right(y))
            right!(y, right(z))
            parent!(right(y), y)
        end

        transplant(tree, z, y)
        left!(y, left(z))
        parent!(left(y), y)
        color!(y, color(z))
    end

    ywasred || delete_fix(tree, x)
    tree.count -= 1

    tree
end

in(key, tree::RBTree) = haskey(tree, key)

"""

    getindex(tree, ind)

Gets the key present at index `ind` of the tree. Indexing is done in increasing order of key.

"""
function getindex(tree::RBTree{T}, ind) where {T}
    @boundscheck in(ind, eachindex(tree)) ||
        throw(ArgumentError("$ind should be in between 1 and $(length(tree))"))

    function traverse_tree_inorder(node::RBNode{T}) where {T}
        if !isnilof(node, tree)
            l = traverse_tree_inorder(left(node))
            r = traverse_tree_inorder(right(node))
            append!(push!(l, getindex(node)), r)
        else
            return T[]
        end
    end

    arr = traverse_tree_inorder(root(tree))

    @inbounds arr[ind]
end
