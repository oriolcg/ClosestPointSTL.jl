module Benchmark
using MeshIO
using FileIO
using ClosestPointSTL
using GeometryBasics
using BoundingVolumeHierarchies
using BoundingVolumeHierarchies: BVHParam
using TimerOutputs

const to = TimerOutput()

# Load the STL file
@timeit to "load mesh" mesh = load(joinpath(@__DIR__,"Stanford_Bunny.stl"))

# Build BVH-tree for the mesh
bp = BVHParam(1000.0)
@timeit to "build tree" bvh_tree = buildBVH(coordinates(mesh),GeometryBasics.faces(mesh),bp)

# Nearby triangles to original
@timeit to "nearby triangles" nearby_triangles = find_nearby_triangles(mesh, bvh_tree, Point(0.0,0.0,0.0), 8.0)
vertices = Point{3,Float64}[]
for triangle in nearby_triangles
  face_vertices = []
  for vertex in coordinates(triangle)
    push!(vertices,GeometryBasics.Point(vertex))
  end
end
faces = [TriangleFace(collect(face_ids)) for face_ids in Iterators.partition(1:length(vertices), 3)]
new_mesh = Mesh(vertices,faces)
save("nearby_triangles.stl", new_mesh)

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
