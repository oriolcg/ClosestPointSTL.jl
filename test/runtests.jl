using ClosestPointSTL
using GeometryBasics
using BoundingVolumeHierarchies
using Test

@testset "ClosestPointSTL.jl" begin
    include("nearby_triangles_test.jl")
    include("closest_point_test.jl")
end
