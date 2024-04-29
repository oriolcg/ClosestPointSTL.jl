module ClosestPointSTL

using BoundingVolumeHierarchies
import BoundingVolumeHierarchies: PointT, _normal, children, FaceIndices
using DataStructures
using Distances
using FileIO
using GeometryBasics
using MeshIO
using Nearestneighbors
using Rotations
using StaticArrays
using TimerOutputs

export closest_point_projection
export intersects

include("Intersections.jl")
include("Closest_point.jl")

end
