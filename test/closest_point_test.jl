# Create mesh from vertices and faces
vertices = [Point(1.0,0.0,0.0), Point(0.0,1.0,0.0), Point(0.0,0.0,1.0)]
faces = [TriangleFace(1,2,3)]
mesh = Mesh(vertices, faces)

# Build BVH-tree for the mesh
bvh_tree = buildBVH(coordinates(mesh),GeometryBasics.faces(mesh))

# Define the point you want to project
point = Point(10.0,1.0,1.0)

nearby_triangles1 = find_nearby_triangles(mesh, bvh_tree, point, 10.0)
@test length(nearby_triangles1) == 1

closest_point = closest_point_projection(mesh, bvh_tree, point, 10.0)
@test closest_point == Point(1.0,0.0,0.0)
