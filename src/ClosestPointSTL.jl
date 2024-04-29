module ClosestPointSTL

using MeshIO
using FileIO
using GeometryBasics
using Distances
using LinearAlgebra
using BoundingVolumeHierarchies
import BoundingVolumeHierarchies: PointT, _normal, children, FaceIndices

export closest_point_projection
export intersects

include("Intersections.jl")
include("Closest_point.jl")


end
