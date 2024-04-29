module ClosestPointSTL

using GeometryBasics
using Distances
using LinearAlgebra
using BoundingVolumeHierarchies
import BoundingVolumeHierarchies: PointT, _normal, children, FaceIndices

export closest_point_projection
export find_nearby_triangles

include("Intersections.jl")
include("Closest_point.jl")

end
