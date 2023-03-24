using BinaryTrees
using Test

@testset "BinaryNode" begin
    n₀ = BinaryNode(0)
    l₁ = left!(n₀, 1)
    r₁ = right!(n₀, 2)
    r₂ = right!(l₁, 3)

    n₀
end
