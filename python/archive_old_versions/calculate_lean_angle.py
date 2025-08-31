import numpy as np
import trimesh

def calculate_lean_angle(obj_file):
    """Calculate the forward/backward lean angle of the moai"""
    
    # Load the mesh
    mesh = trimesh.load(obj_file)
    
    # Get center of mass
    center_of_mass = mesh.center_mass
    
    # Get base information
    base_y = mesh.bounds[0][1]  # minimum Y is the base
    
    # Find base vertices
    base_threshold = base_y + 0.05
    base_vertices = mesh.vertices[mesh.vertices[:, 1] < base_threshold]
    
    # Calculate base center
    base_x_min, base_x_max = base_vertices[:, 0].min(), base_vertices[:, 0].max()
    base_z_min, base_z_max = base_vertices[:, 2].min(), base_vertices[:, 2].max()
    
    base_center_x = (base_x_min + base_x_max) / 2
    base_center_z = (base_z_min + base_z_max) / 2
    base_center_y = base_y
    
    # Calculate vectors
    # Vertical vector (straight up from base center)
    vertical_vector = np.array([0, 1, 0])
    
    # Vector from base center to COM
    base_to_com = np.array([
        center_of_mass[0] - base_center_x,
        center_of_mass[1] - base_center_y,
        center_of_mass[2] - base_center_z
    ])
    
    # Normalize the base_to_com vector
    base_to_com_normalized = base_to_com / np.linalg.norm(base_to_com)
    
    # Calculate angle between vertical and base-to-COM vector
    dot_product = np.dot(vertical_vector, base_to_com_normalized)
    angle_radians = np.arccos(np.clip(dot_product, -1, 1))
    angle_degrees = np.degrees(angle_radians)
    
    # Calculate the lean components in XZ plane
    # Project the base-to-COM vector onto the XZ plane
    horizontal_offset = np.array([
        center_of_mass[0] - base_center_x,
        0,
        center_of_mass[2] - base_center_z
    ])
    horizontal_distance = np.linalg.norm(horizontal_offset)
    
    # Calculate the angle in the XZ plane (forward/backward direction)
    # The moai faces toward larger Z values (front is at max Z)
    # If COM Z < base center Z, it's leaning backward
    # If COM Z > base center Z, it's leaning forward
    z_offset = center_of_mass[2] - base_center_z
    y_offset = center_of_mass[1] - base_center_y
    
    # Calculate angle from vertical
    # Positive angle means leaning forward (toward face)
    forward_backward_angle = np.degrees(np.arctan2(
        z_offset,  # Z component (forward/back)
        y_offset   # Y component (height)
    ))
    
    # Also calculate side-to-side angle
    left_right_angle = np.degrees(np.arctan2(
        center_of_mass[0] - base_center_x,  # X component (left/right)
        center_of_mass[1] - base_center_y   # Y component (height)
    ))
    
    print("Moai Lean Analysis")
    print("=" * 50)
    print(f"\nBase center: X={base_center_x:.3f}, Y={base_center_y:.3f}, Z={base_center_z:.3f}")
    print(f"Center of mass: X={center_of_mass[0]:.3f}, Y={center_of_mass[1]:.3f}, Z={center_of_mass[2]:.3f}")
    # The D-shaped curve is the FRONT (face), flat side is BACK
    # So lower Z values are front, higher Z values are back
    print(f"\nZ-axis orientation: Front of moai (curved/face) is at Z={base_z_min:.3f}, Back (flat) is at Z={base_z_max:.3f}")
    # Since front is at min Z and back is at max Z:
    # If COM Z < base center Z, it's toward front (face)
    # If COM Z > base center Z, it's toward back
    print(f"COM Z offset from base center: {z_offset:.3f} ({'toward front/face' if z_offset < 0 else 'toward back'})")
    
    # Debug: Let's check our understanding
    print(f"\nDouble-checking positions:")
    print(f"  Base center Z: {base_center_z:.3f}")
    print(f"  COM Z: {center_of_mass[2]:.3f}")
    print(f"  Front edge Z: {base_z_max:.3f}")
    print(f"  Back edge Z: {base_z_min:.3f}")
    print(f"  Distance from COM to front edge: {base_z_max - center_of_mass[2]:.3f}")
    print(f"  Distance from COM to back edge: {center_of_mass[2] - base_z_min:.3f}")
    
    print(f"\nOffsets from base center:")
    print(f"  Horizontal offset: {horizontal_distance:.3f}m")
    print(f"  Vertical height: {center_of_mass[1] - base_center_y:.3f}m")
    
    print(f"\nLean angles:")
    print(f"  Total lean from vertical: {angle_degrees:.1f}°")
    # Since negative z_offset means toward front, negative angle means forward lean
    print(f"  Forward/backward lean: {abs(forward_backward_angle):.1f}° ({'forward' if forward_backward_angle < 0 else 'backward'})")
    print(f"  Left/right lean: {abs(left_right_angle):.1f}° ({'left' if left_right_angle < 0 else 'right'})")
    
    # For a more intuitive "base angle", calculate the angle of the base-to-COM line
    # projected onto the Z-Y plane (front view)
    front_view_angle = 90 - abs(forward_backward_angle)
    print(f"\nBase angle from ground (front view): {front_view_angle:.1f}°")
    print(f"  (90° = perfectly vertical, <90° = leaning)")
    
    # Calculate how far forward the top would be if the moai was this height
    total_height = mesh.bounds[1][1] - mesh.bounds[0][1]
    lean_at_top = total_height * np.tan(np.radians(abs(forward_backward_angle)))
    print(f"\nIf extended to full height ({total_height:.3f}m):")
    print(f"  Top would be {lean_at_top:.3f}m {'ahead of' if forward_backward_angle < 0 else 'behind'} the base")
    
    return angle_degrees, forward_backward_angle, left_right_angle

if __name__ == "__main__":
    obj_file = "../data/SimplifiedMoai.obj"
    calculate_lean_angle(obj_file)