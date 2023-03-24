using BinaryTrees

# inserting values
t = RBTree{Int}()
for i in 1:100
    insert!(t, i)
end

@assert length(t) == 100

for i in 1:100
    @assert haskey(t, i)
end

for i = 101:200
    @assert !haskey(t, i)
end

# deleting values
t = RBTree{Int}()
for i in 1:100
    insert!(t, i)
end
for i in 1:2:100
    delete!(t, i)
end

@assert length(t) == 50

for i in 1:100
    if iseven(i)
        @assert haskey(t, i)
    else
        @assert !haskey(t, i)
    end
end

for i in 1:2:100
    insert!(t, i)
end

@assert length(t) == 100

# handling different cases of delete!
t2 = RBTree()
for i in 1:100000
    insert!(t2, i)
end

@assert length(t2) == 100000

nums = rand(1:100000, 8599)
visited = Set()
for num in nums 
    if !(num in visited)
        delete!(t2, num)
        push!(visited, num) 
    end
end

for i in visited
    @assert !haskey(t2, i)
end
@assert (length(t2) + length(visited)) == 100000

# handling different cases of insert!
nums = rand(1:100000, 1000)
t3 = RBTree()
uniq_nums = Set(nums)
for num in nums
    insert!(t3, num)
end
@assert length(t3) == length(uniq_nums)

# in
t4 = RBTree{Char}()
push!(t4, 'a')
push!(t4, 'b')
@assert length(t4) == 2
@assert in('a', t4)
@assert !in('c', t4)

# search_node
t5 = RBTree()
for i in 1:32
    push!(t5, i)
end
n1 = search_node(t5, 21)
@assert n1.data == 21
n2 = search_node(t5, 35)
@assert n2 === t5.nil
n3 = search_node(t5, 0)
@assert n3 === t5.nil

# getindex
t6 = RBTree{Int}()
for i in 1:10
    push!(t6, i)
end
for i in 1:10
    @assert getindex(t6, i) == i
end

# key conversion in push!
t7 = RBTree{Int}()
push!(t7, Int8(1))
@assert length(t7) == 1
@assert haskey(t7, 1)

#=
# minimum_node
t8 = RBTree()
for i in 1:32
    push!(t8, i)
end
m1 = minimum_node(t8, t8.root)
@assert m1.data == 1
node = t8.root
while node.leftChild != t8.nil
    m = minimum_node(t8, node.leftChild)
    @assert m == m1
    node = node.leftChild
end

@assert minimum_node(t8, t8.nil) === t8.nil
=#
