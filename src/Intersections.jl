# Define a function to check if a BVH tree node intersects with a sphere
function intersects(aabb::AABB, sphere::Sphere{T}) where T

  # Compute the closest point on the bounding box to the sphere
  closest_point = Point3{T}([clamp(sphere.center[i],aabb.min[i],aabb.max[i]) for i in 1:length(sphere.center)])

  # Return true if the distance between the closest point and the sphere center is less than the sphere radius
  distance2 = norm(closest_point - sphere.center)^2
  return distance2 <= radius(sphere)^2
end

# Append list of triangles in an intersected leaf node
function intersects!(f_indices::FaceIndices, sphere::Sphere{T}, triangle_list::Vector{Int}) where T
  append!(triangle_list, f_indices.inds)
end

# Define a function to recursively search for intersections between BVH tree nodes and a sphere
function intersects!(bvh_tree::BVH, sphere::Sphere{T}, triangle_list::Vector{Int}) where T

  # Get the root node of the BVH tree
  aabb = bvh_tree.aabb
  children = BoundingVolumeHierarchies.children(bvh_tree)

  # Check if the bounding box of the node intersects with the sphere
  if intersects(aabb, sphere)
    # If the bounding box intersects with the sphere, recursively check its children
    intersects!(children[1], sphere, triangle_list)
    intersects!(children[2], sphere, triangle_list)
  end
end
