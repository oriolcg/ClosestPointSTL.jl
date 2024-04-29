module Benchmark
using MeshIO
using FileIO
using GeometryBasics
using Distances
using LinearAlgebra
using BoundingVolumeHierarchies
import BoundingVolumeHierarchies: PointT, _normal, children, FaceIndices
using TimerOutputs

include("Intersections.jl")
include("Closest_point.jl")

const to = TimerOutput()

# Load the STL file
@timeit to "load mesh" mesh = load("Stanford_Bunny.stl")

# Build BVH-tree for the mesh
@timeit to "build tree" bvh_tree = buildBVH(coordinates(mesh),GeometryBasics.faces(mesh))

# Define the points you want to project
points = []
for ipoint in 1:100000
  push!(points, Point(rand(-10.0:10.0),rand(-10.0:10.0),rand(-10.0:10.0)))  # Coordinates of the point
end

# Compute the closest point projection
for point in points
  @timeit to "closest point" closest_point = closest_point_projection(mesh, bvh_tree, point,10.0)
  # if closest_point != nothing
  #   println("Distance to closest point: ", euclidean(point, closest_point))
  # end
end

show(to)

end
