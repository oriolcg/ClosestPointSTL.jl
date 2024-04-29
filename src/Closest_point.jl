function find_nearby_triangles(mesh::AbstractMesh, bvh_tree::BVH, point::Point{N,T}, radius::Float64) where {N,T}
   # Search for nearby triangles using BVH-tree
   nearby_triangles_list = Vector{Int}()
   intersects!(bvh_tree, Sphere(point,radius), nearby_triangles_list)
   nearby_triangles = mesh[nearby_triangles_list]

end

# Function to compute the closest point projection
function closest_point_projection(mesh::AbstractMesh, bvh_tree::BVH, point::Point{N,T}, radius::Float64, verbose::Bool=false) where {N,T}
  closest_point = point
  min_dist = radius

  nearby_triangles = find_nearby_triangles(mesh, bvh_tree, point, radius)
  if isempty(nearby_triangles) && verbose
    println("There is no close point around $point in a radius of $radius.")
    return nothing
  end

  for face in nearby_triangles

    # Get vertices of the face
    vertices = coordinates(face)

    # Compute the normal of the face
    normal = cross(vertices[2] - vertices[1], vertices[3] - vertices[1])
    normal /= norm(normal)

    # Compute the projection of the point onto the plane of the face
    v = point - vertices[1]
    d = dot(v, normal)
    projected_point = point - d * normal

    # Check if the projected point is inside the triangle
    if all(dot(cross(vertices[i] - vertices[i-1], vertices[i+1] - vertices[i-1]), projected_point - vertices[i-1]) > 0 for i in 2:length(vertices)-1)
      # Compute the distance between the point and the projected point
      dist = euclidean(point, projected_point)
      if dist < min_dist
        min_dist = dist
        closest_point = projected_point
      end
    else
      # Compute the distance to each vertex
      for vertex in vertices
        dist = euclidean(point, vertex)
        if dist < min_dist
          min_dist = dist
          closest_point = vertex
        end
      end
    end
  end

  return closest_point
end
