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
  closest_point = Point(0.0,0.0,0.0)#point
  min_dist = Inf

  nearby_triangles = find_nearby_triangles(mesh, bvh_tree, point, radius)
  if isempty(nearby_triangles)
    if verbose
      println("There is no close point around $point in a radius of $radius.")
    end
    return nothing
  end

  for (iface,face) in enumerate(nearby_triangles)

    # Get vertices of the face
    v1,v2,v3 = coordinates(face)

    # Compute the normal of the face
    normal = cross(v2 - v1, v3 - v1)
    normal /= norm(normal)

    # Compute the projection of the point onto the plane of the face
    v = point - v1
    d = dot(v, normal)
    projected_point = point - d * normal
    dist0 = dist(projected_point, point)
    # println("dist0: ", dist0, " radius: ", radius)
    # if dist0 > radius
    #   continue
    # end

    # Check if the projected point is inside the triangle
    d00 = dot(v2 - v1, v2 - v1)
    d01 = dot(v2 - v1, v3 - v1)
    d11 = dot(v3 - v1, v3 - v1)
    d20 = dot(projected_point - v1, v2 - v1)
    d21 = dot(projected_point - v1, v3 - v1)
    denom = d00 * d11 - d01 * d01
    s = (d00 * d21 - d01 * d20) / denom
    t = (d11 * d20 - d01 * d21) / denom
    α = 1 - s - t
    # println(s, " ", t, " ", s + t)

    # If the projected point is inside the triangle, return it
    if 0 <= s <= 1 && 0 <= t <= 1 && 0 <= α <= 1
      if dist0 < min_dist
        min_dist = dist0
        closest_point = projected_point
        continue
      end
    end

    # Check distance to edge v1-v2
    closest_point1 = closest_point_on_segment(projected_point, Point{N,T}(v1), Point{N,T}(v2))
    dist1 = dist(closest_point1, point)
    if dist1 < min_dist
        min_dist = dist1
        closest_point = closest_point1
    end

    # Check distance to edge v2-v3
    closest_point2 = closest_point_on_segment(projected_point, Point{N,T}(v2), Point{N,T}(v3))
    dist2 = dist(closest_point2, point)
    if dist2 < min_dist
        min_dist = dist2
        closest_point = closest_point2
    end

    # Check distance to edge v3-v1
    closest_point3 = closest_point_on_segment(projected_point, Point{N,T}(v3), Point{N,T}(v1))
    dist3 = dist(closest_point3, point)
    if dist3 < min_dist
        min_dist = dist3
        closest_point = closest_point3
    end

  end

  return closest_point
end

dist(a,b) = norm(a-b)
