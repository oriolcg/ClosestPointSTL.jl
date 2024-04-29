function find_nearby_triangles(mesh::AbstractMesh, bvh_tree::BVH, point::Point{N,T}, radius::Float64) where {N,T}
   # Search for nearby triangles using BVH-tree
   nearby_triangles_list = Vector{Int}()
   intersects!(bvh_tree, Sphere(point,radius), nearby_triangles_list)
   mesh[nearby_triangles_list]
end

# Define a function to compute the closest point on a line segment to a given point
function closest_point_on_segment(point::Point{N,T}, segment_start::Point{N,T}, segment_end::Point{N,T}) where {N,T}
 segment_direction = segment_end - segment_start
 segment_length = norm(segment_direction)
 segment_direction = normalize(segment_direction)

 point_vector = point - segment_start
 t = dot(point_vector, segment_direction)
 if t <= 0
     return segment_start
 elseif t >= segment_length
     return segment_end
 else
     return segment_start + t * segment_direction
 end
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
    v1,v2,v3 = coordinates(face)

    # Compute the normal of the face
    normal = cross(v2 - v1, v3 - v1)
    normal /= norm(normal)

    # Compute the projection of the point onto the plane of the face
    v = point - v1
    d = dot(v, normal)
    projected_point = point - d * normal

    # Check if the projected point is inside the triangle
    u = dot(v2 - v1, v2 - v1)
    v = dot(v2 - v1, v3 - v1)
    w = dot(projected_point - v1, v2 - v1)
    uu = dot(v3 - v1, v3 - v1)
    vv = dot(v3 - v1, projected_point - v1)
    uv = dot(v3 - v1, v2 - v1)
    denom = u * vv - v * uv
    s = (vv * w - v * w) / denom
    t = (u * w - uv * w) / denom

    # If the projected point is inside the triangle, return it
    if 0 <= s <= 1 && 0 <= t <= 1 && s + t <= 1
        closest_point = projected_point
        continue
    end

    # Otherwise, find the closest point on the edges of the triangle
    min_dist = Inf
    closest_point = projected_point

    # Check distance to edge v1-v2
    edge_dist = dist(projected_point, v1) + dist(v1, v2)
    if edge_dist < min_dist
        min_dist = edge_dist
        closest_point = closest_point_on_segment(projected_point, v1, v2)
    end

    # Check distance to edge v2-v3
    edge_dist = dist(projected_point, v2) + dist(v2, v3)
    if edge_dist < min_dist
        min_dist = edge_dist
        closest_point = closest_point_on_segment(projected_point, v2, v3)
    end

    # Check distance to edge v3-v1
    edge_dist = dist(projected_point, v3) + dist(v3, v1)
    if edge_dist < min_dist
        closest_point = closest_point_on_segment(projected_point, v3, v1)
    end

    # # Check if the projected point is inside the triangle
    # if all(dot(cross(vertices[i] - vertices[i-1], vertices[i+1] - vertices[i-1]), projected_point - vertices[i-1]) > 0 for i in 2:length(vertices)-1)
    #   # Compute the distance between the point and the projected point
    #   dist = euclidean(point, projected_point)
    #   if dist < min_dist
    #     min_dist = dist
    #     closest_point = projected_point
    #   end
    # else
    #   # Compute the distance to each vertex
    #   for vertex in vertices
    #     dist = euclidean(point, vertex)
    #     if dist < min_dist
    #       min_dist = dist
    #       closest_point = vertex
    #     end
    #   end
    # end
  end

  return closest_point
end

dist(a,b) = norm(a-b)
