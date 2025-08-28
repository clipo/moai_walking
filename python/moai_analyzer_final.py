import numpy as np
import matplotlib
matplotlib.use('Agg')  # Use non-interactive backend
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
from matplotlib import cm
import trimesh
import os
from scipy.spatial import Delaunay
from matplotlib.patches import Polygon
from collections import defaultdict
from output_helper import get_output_path

def load_and_analyze_moai(obj_file):
    """Load the moai mesh and analyze its center of mass"""
    
    # Load the mesh
    mesh = trimesh.load(obj_file)
    print(f"Loaded mesh with {len(mesh.vertices)} vertices and {len(mesh.faces)} faces")
    
    # Scaling factor for actual moai dimensions (7.35m tall)
    SCALE_FACTOR = 4.894  # 7.35m / 1.502m
    
    # In the OBJ file: Y is vertical (height), X is width, Z is depth
    bounds = mesh.bounds
    print(f"\nMesh bounds (scaled to actual moai):")
    print(f"  X (width): {bounds[0][0]*SCALE_FACTOR:.3f}m to {bounds[1][0]*SCALE_FACTOR:.3f}m")
    print(f"  Y (height): {bounds[0][1]*SCALE_FACTOR:.3f}m to {bounds[1][1]*SCALE_FACTOR:.3f}m")
    print(f"  Z (depth): {bounds[0][2]*SCALE_FACTOR:.3f}m to {bounds[1][2]*SCALE_FACTOR:.3f}m")
    
    # Calculate center of mass
    center_of_mass = mesh.center_mass
    
    print(f"\nCenter of mass (scaled): X={center_of_mass[0]*SCALE_FACTOR:.3f}m, Y={center_of_mass[1]*SCALE_FACTOR:.3f}m, Z={center_of_mass[2]*SCALE_FACTOR:.3f}m")
    
    # Calculate height from base (Y is vertical)
    base_y = bounds[0][1]  # minimum Y is the base
    height_from_base = center_of_mass[1] - base_y
    total_height = bounds[1][1] - bounds[0][1]
    height_percentage = (height_from_base / total_height) * 100
    
    print(f"\nHeight analysis (scaled):")
    print(f"  Base Y coordinate: {base_y*SCALE_FACTOR:.3f}m")
    print(f"  Center of mass height from base: {height_from_base*SCALE_FACTOR:.3f}m")
    print(f"  Total height: {total_height*SCALE_FACTOR:.3f}m")
    print(f"  Center of mass at {height_percentage:.1f}% of total height")
    
    # Find the base vertices (those near minimum Y)
    base_threshold = base_y + 0.05
    base_vertices = mesh.vertices[mesh.vertices[:, 1] < base_threshold]
    
    if len(base_vertices) > 0:
        base_x_min = base_vertices[:, 0].min()
        base_x_max = base_vertices[:, 0].max()
        base_z_min = base_vertices[:, 2].min()
        base_z_max = base_vertices[:, 2].max()
        
        print(f"\nBase dimensions (scaled):")
        print(f"  X range: {base_x_min*SCALE_FACTOR:.3f}m to {base_x_max*SCALE_FACTOR:.3f}m (width: {(base_x_max - base_x_min)*SCALE_FACTOR:.3f}m)")
        print(f"  Z range: {base_z_min*SCALE_FACTOR:.3f}m to {base_z_max*SCALE_FACTOR:.3f}m (depth: {(base_z_max - base_z_min)*SCALE_FACTOR:.3f}m)")
        
        # Check if center of mass projects within the base
        com_within_base_x = base_x_min <= center_of_mass[0] <= base_x_max
        com_within_base_z = base_z_min <= center_of_mass[2] <= base_z_max
        
        print(f"\nStability analysis:")
        print(f"  Center of mass X: {center_of_mass[0]:.3f} ({'within' if com_within_base_x else 'outside'} base X range)")
        print(f"  Center of mass Z: {center_of_mass[2]:.3f} ({'within' if com_within_base_z else 'outside'} base Z range)")
        
        # Calculate offset from base center
        base_center_x = (base_x_min + base_x_max) / 2
        base_center_z = (base_z_min + base_z_max) / 2
        
        offset_x = center_of_mass[0] - base_center_x
        offset_z = center_of_mass[2] - base_center_z
        
        print(f"\nCenter of mass offset from base center (scaled):")
        print(f"  X offset: {offset_x*SCALE_FACTOR:.3f}m ({abs(offset_x*SCALE_FACTOR)*100:.1f}cm {'right' if offset_x > 0 else 'left'} when viewed from front)")
        print(f"  Z offset: {offset_z*SCALE_FACTOR:.3f}m ({abs(offset_z*SCALE_FACTOR)*100:.1f}cm {'forward' if offset_z > 0 else 'backward'})")
        
        # Determine front edge
        front_edge_z = base_z_max
        distance_to_front = front_edge_z - center_of_mass[2]
        
        print(f"\nFront edge analysis (scaled):")
        print(f"  Front edge Z: {front_edge_z*SCALE_FACTOR:.3f}m")
        print(f"  COM distance from front edge: {distance_to_front*SCALE_FACTOR:.3f}m ({abs(distance_to_front*SCALE_FACTOR)*100:.1f}cm)")
        print(f"  COM is {'over' if distance_to_front < 0 else 'behind'} the front edge")
    
    return mesh, center_of_mass, SCALE_FACTOR

def find_boundary_points(points_2d, resolution=50):
    """Find boundary points of a 2D point cloud using grid-based edge detection"""
    
    # Create a grid
    x_min, x_max = points_2d[:, 0].min(), points_2d[:, 0].max()
    z_min, z_max = points_2d[:, 1].min(), points_2d[:, 1].max()
    
    # Add padding
    padding = 0.02
    x_min -= padding
    x_max += padding
    z_min -= padding
    z_max += padding
    
    # Create grid
    x_bins = np.linspace(x_min, x_max, resolution)
    z_bins = np.linspace(z_min, z_max, resolution)
    
    # Create occupancy grid
    grid = np.zeros((resolution-1, resolution-1), dtype=bool)
    
    # Fill grid
    for point in points_2d:
        x_idx = np.searchsorted(x_bins, point[0]) - 1
        z_idx = np.searchsorted(z_bins, point[1]) - 1
        if 0 <= x_idx < resolution-1 and 0 <= z_idx < resolution-1:
            grid[z_idx, x_idx] = True
    
    # Find boundary cells (cells that are occupied and have at least one empty neighbor)
    boundary_cells = []
    for i in range(resolution-1):
        for j in range(resolution-1):
            if grid[i, j]:
                # Check if this is a boundary cell
                is_boundary = False
                for di in [-1, 0, 1]:
                    for dj in [-1, 0, 1]:
                        if di == 0 and dj == 0:
                            continue
                        ni, nj = i + di, j + dj
                        if 0 <= ni < resolution-1 and 0 <= nj < resolution-1:
                            if not grid[ni, nj]:
                                is_boundary = True
                                break
                        else:
                            is_boundary = True
                            break
                    if is_boundary:
                        break
                
                if is_boundary:
                    # Get center of cell
                    x_center = (x_bins[j] + x_bins[j+1]) / 2
                    z_center = (z_bins[i] + z_bins[i+1]) / 2
                    boundary_cells.append([x_center, z_center])
    
    return np.array(boundary_cells)

def order_boundary_points(boundary_points):
    """Order boundary points to form a continuous outline"""
    if len(boundary_points) < 3:
        return boundary_points
    
    # Start with the leftmost point
    ordered = []
    remaining = list(range(len(boundary_points)))
    
    # Find leftmost point
    start_idx = np.argmin(boundary_points[:, 0])
    current_idx = start_idx
    ordered.append(current_idx)
    remaining.remove(current_idx)
    
    # Order points by nearest neighbor
    while remaining:
        current_point = boundary_points[current_idx]
        distances = [np.linalg.norm(boundary_points[idx] - current_point) for idx in remaining]
        nearest_idx = remaining[np.argmin(distances)]
        ordered.append(nearest_idx)
        remaining.remove(nearest_idx)
        current_idx = nearest_idx
    
    return boundary_points[ordered]

def smooth_boundary(boundary_points, window_size=5):
    """Smooth boundary points using moving average"""
    if len(boundary_points) < window_size:
        return boundary_points
    
    # Pad the array for circular smoothing
    padded = np.vstack([boundary_points[-window_size//2:], 
                        boundary_points, 
                        boundary_points[:window_size//2]])
    
    # Apply moving average
    smoothed = np.zeros_like(boundary_points)
    for i in range(len(boundary_points)):
        start = i
        end = i + window_size
        smoothed[i] = padded[start:end].mean(axis=0)
    
    return smoothed

def visualize_moai_final(mesh, center_of_mass, scale_factor):
    """Create final visualization with accurate base outline and scaled measurements"""
    
    fig = plt.figure(figsize=(16, 10))
    
    # Create 3D plot
    ax = fig.add_subplot(121, projection='3d')
    
    # Sample vertices for visualization
    vertices = mesh.vertices
    if len(vertices) > 5000:
        indices = np.random.choice(len(vertices), 5000, replace=False)
        vertices_sample = vertices[indices]
    else:
        vertices_sample = vertices
    
    # Plot vertices colored by height (Y coordinate) - scale for display
    scatter = ax.scatter(vertices_sample[:, 0] * scale_factor,  # X
                        vertices_sample[:, 2] * scale_factor,  # Z (depth)
                        vertices_sample[:, 1] * scale_factor,  # Y (height)
                        c=vertices_sample[:, 1] * scale_factor, cmap='copper', s=3, alpha=0.6)
    
    # Plot center of mass - scaled
    ax.scatter(center_of_mass[0] * scale_factor, center_of_mass[2] * scale_factor, center_of_mass[1] * scale_factor, 
               c='red', s=500, marker='o', edgecolors='black', linewidth=3,
               label='Center of Mass', zorder=1000)
    
    # Plot COM projection on base - scaled
    base_y = mesh.bounds[0][1]
    ax.scatter(center_of_mass[0] * scale_factor, center_of_mass[2] * scale_factor, base_y * scale_factor, 
               c='red', s=200, marker='X', linewidth=4,
               label='COM ground projection')
    
    # Draw vertical line from base to COM - scaled
    ax.plot([center_of_mass[0] * scale_factor, center_of_mass[0] * scale_factor], 
            [center_of_mass[2] * scale_factor, center_of_mass[2] * scale_factor], 
            [base_y * scale_factor, center_of_mass[1] * scale_factor], 
            'r--', linewidth=3, alpha=0.8)
    
    # Add vertical reference line from base center - scaled
    base_center_x = (mesh.bounds[0][0] + mesh.bounds[1][0]) / 2
    base_center_z = (mesh.bounds[0][2] + mesh.bounds[1][2]) / 2
    ax.plot([base_center_x * scale_factor, base_center_x * scale_factor], 
            [base_center_z * scale_factor, base_center_z * scale_factor], 
            [base_y * scale_factor, mesh.bounds[1][1] * scale_factor], 
            'k:', linewidth=2, alpha=0.5, label='Vertical reference')
    
    # Calculate and display lean angle
    z_offset = center_of_mass[2] - base_center_z
    y_offset = center_of_mass[1] - base_y
    lean_angle = np.degrees(np.arctan2(abs(z_offset), y_offset))
    
    # Add angle arc to show lean
    from matplotlib.patches import Arc
    angle_radius = 0.2
    # Draw arc at base height
    angle_arc = Arc((base_center_x, base_center_z), 
                   angle_radius*2, angle_radius*2,
                   angle=0, theta1=90-lean_angle, theta2=90,
                   color='green', linewidth=2)
    
    # Add lean angle text
    lean_text = f'Forward lean: {lean_angle:.1f}°'
    ax.text2D(0.05, 0.95, lean_text, 
              transform=ax.transAxes, fontsize=12, 
              bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8),
              verticalalignment='top')
    
    # Add dimensions info separately
    height_m = (mesh.bounds[1][1] - mesh.bounds[0][1])*scale_factor
    width_m = (mesh.bounds[1][0] - mesh.bounds[0][0])*scale_factor
    dims_text = f'Height: {height_m:.2f}m\nWidth: {width_m:.2f}m\nCOM height: {(center_of_mass[1] - mesh.bounds[0][1])*scale_factor:.2f}m'
    ax.text2D(0.05, 0.82, dims_text, 
              transform=ax.transAxes, fontsize=11, 
              bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.8),
              verticalalignment='top')
    
    # Add coordinate axes at COM for reference - scaled
    axis_length = 0.3  # Increased for better visibility at scale
    ax.quiver(center_of_mass[0] * scale_factor, center_of_mass[2] * scale_factor, center_of_mass[1] * scale_factor,
              axis_length, 0, 0, color='red', alpha=0.7, linewidth=2)
    ax.quiver(center_of_mass[0] * scale_factor, center_of_mass[2] * scale_factor, center_of_mass[1] * scale_factor,
              0, axis_length, 0, color='blue', alpha=0.7, linewidth=2)
    ax.quiver(center_of_mass[0] * scale_factor, center_of_mass[2] * scale_factor, center_of_mass[1] * scale_factor,
              0, 0, axis_length, color='green', alpha=0.7, linewidth=2)
    
    # Set labels
    ax.set_xlabel('X (width) [m]', fontsize=12)
    ax.set_ylabel('Z (depth) [m]', fontsize=12)
    ax.set_zlabel('Y (height) [m]', fontsize=12)
    ax.set_title('Moai 3D View with Center of Mass', fontsize=14)
    
    # Set viewing angle - show front of moai
    ax.view_init(elev=20, azim=-135)
    
    # Set aspect ratio
    ax.set_box_aspect([1,
                       (mesh.bounds[1][2] - mesh.bounds[0][2]) / (mesh.bounds[1][0] - mesh.bounds[0][0]),
                       (mesh.bounds[1][1] - mesh.bounds[0][1]) / (mesh.bounds[1][0] - mesh.bounds[0][0])])
    
    # Set axis limits to scaled values
    ax.set_xlim([mesh.bounds[0][0] * scale_factor, mesh.bounds[1][0] * scale_factor])
    ax.set_ylim([mesh.bounds[0][2] * scale_factor, mesh.bounds[1][2] * scale_factor])
    ax.set_zlim([mesh.bounds[0][1] * scale_factor, mesh.bounds[1][1] * scale_factor])
    
    ax.legend(loc='upper left')
    
    # Create top-down view (looking down Y-axis)
    ax2 = fig.add_subplot(122)
    
    # Get base vertices
    base_threshold = base_y + 0.05
    base_vertices = mesh.vertices[mesh.vertices[:, 1] < base_threshold]
    
    # Get slice vertices at 10cm above base for cleaner outline
    slice_height = base_y + 0.10  # 10cm above base
    slice_tolerance = 0.01  # 1cm tolerance
    slice_vertices = mesh.vertices[
        (mesh.vertices[:, 1] > slice_height - slice_tolerance) & 
        (mesh.vertices[:, 1] < slice_height + slice_tolerance)
    ]
    
    if len(base_vertices) > 0:
        # Plot all base points (no legend entry) - scaled
        ax2.scatter(base_vertices[:, 0] * scale_factor, base_vertices[:, 2] * scale_factor, 
                   c='lightgray', s=2, alpha=0.3)
        
        # Use slice vertices for boundary if available, otherwise use base
        outline_vertices = slice_vertices if len(slice_vertices) > 10 else base_vertices
        print(f"Using {len(outline_vertices)} vertices for outline (slice: {len(slice_vertices)}, base: {len(base_vertices)})")
        
        # Find boundary points using grid method with lower resolution for smoother outline
        points_2d = outline_vertices[:, [0, 2]]  # X and Z coordinates
        boundary_points = find_boundary_points(points_2d, resolution=25)
        
        if len(boundary_points) > 0:
            # Order boundary points
            ordered_boundary = order_boundary_points(boundary_points)
            
            # Smooth the boundary for cleaner D-shape
            smoothed_boundary = smooth_boundary(ordered_boundary, window_size=7)
            
            # Close the loop
            closed_boundary = np.vstack([smoothed_boundary, smoothed_boundary[0]])
            
            # Scale boundary for display
            scaled_boundary = closed_boundary * scale_factor
            
            # Plot boundary as a polygon
            boundary_polygon = Polygon(scaled_boundary, 
                                     fill=True, facecolor='lightblue', 
                                     edgecolor='blue', linewidth=2.5,
                                     alpha=0.3, label='Base outline')
            ax2.add_patch(boundary_polygon)
            
            # Also plot the boundary line
            ax2.plot(scaled_boundary[:, 0], scaled_boundary[:, 1], 
                    'b-', linewidth=2.5, alpha=0.8)
        
        # Get base bounds for reference
        base_x_min, base_x_max = base_vertices[:, 0].min(), base_vertices[:, 0].max()
        base_z_min, base_z_max = base_vertices[:, 2].min(), base_vertices[:, 2].max()
        
        # Mark base center - scaled
        base_center_x = (base_x_min + base_x_max) / 2
        base_center_z = (base_z_min + base_z_max) / 2
        ax2.scatter(base_center_x * scale_factor, base_center_z * scale_factor, c='blue', s=150, marker='+', 
                   linewidth=3, label='Base center', zorder=4)
        
        # Draw line from base center to COM with arrow - scaled
        # Stop arrow short of COM so arrowhead is visible
        dx = center_of_mass[0] - base_center_x
        dz = center_of_mass[2] - base_center_z
        length = np.sqrt(dx**2 + dz**2)
        # Stop 0.05 units before COM (scaled)
        scale_arrow = (length - 0.05) / length
        arrow_end_x = base_center_x + dx * scale_arrow
        arrow_end_z = base_center_z + dz * scale_arrow
        
        ax2.annotate('', 
                    xy=(arrow_end_x * scale_factor, arrow_end_z * scale_factor),  # arrow stops just before COM
                    xytext=(base_center_x * scale_factor, base_center_z * scale_factor),      # arrow starts at base center
                    arrowprops=dict(arrowstyle='->', color='black', 
                                  linewidth=2.5, alpha=0.9,
                                  linestyle='-', 
                                  shrinkA=0, shrinkB=0,
                                  mutation_scale=30))
        
        # Removed front edge line per user request
        
        # Add arrow showing lean direction (from base center toward COM) - scaled
        # Normalize the direction vector
        dx = center_of_mass[0] - base_center_x
        dz = center_of_mass[2] - base_center_z
        length = np.sqrt(dx**2 + dz**2)
        dx_norm = dx / length
        dz_norm = dz / length
        
        # Scale for arrow (in real units)
        arrow_scale = 0.3  # 30cm arrow
        ax2.annotate('', 
                    xy=((base_center_x + dx_norm * arrow_scale) * scale_factor, 
                        (base_center_z + dz_norm * arrow_scale) * scale_factor), 
                    xytext=(base_center_x * scale_factor, base_center_z * scale_factor),
                    arrowprops=dict(arrowstyle='->', color='darkgreen', lw=3))
        
        # Place text along the lean direction
        text_offset = 0.15  # 15cm offset
        ax2.text((base_center_x + dx_norm * text_offset) * scale_factor, 
                (base_center_z + dz_norm * text_offset + 0.05) * scale_factor, 
                'Lean\ndirection', fontsize=9, color='darkgreen', 
                ha='center', va='bottom')
    
    # Plot center of mass - scaled
    ax2.scatter(center_of_mass[0] * scale_factor, center_of_mass[2] * scale_factor, 
               c='red', s=300, marker='o', 
               edgecolors='darkred', linewidth=2.5, 
               label='Center of Mass', zorder=5)
    
    # Add grid and labels
    ax2.grid(True, alpha=0.3, linestyle=':')
    ax2.set_xlabel('X (width) [m]', fontsize=12)
    ax2.set_ylabel('Z (depth) [m]', fontsize=12)
    ax2.set_title('Top-down View: Center of Mass vs Base', fontsize=14)
    ax2.axis('equal')
    ax2.legend(loc='upper left', fontsize=10)
    
    # Add annotations with scaled measurements
    base_width = (mesh.bounds[1][0] - mesh.bounds[0][0]) * scale_factor
    base_depth = (mesh.bounds[1][2] - mesh.bounds[0][2]) * scale_factor
    distance_to_front = (mesh.bounds[1][2] - center_of_mass[2]) * scale_factor
    
    info_text = f'Base: {base_width:.2f}m × {base_depth:.2f}m\nDistance to front edge: {distance_to_front*100:.0f}cm'
    ax2.text(0.98, 0.02, info_text, 
            transform=ax2.transAxes, fontsize=10, ha='right', va='bottom', 
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    
    plt.tight_layout()
    
    # Save figures
    png_file = get_output_path('Figure_4_moai_analysis_600dpi.png')
    fig.savefig(png_file, dpi=600, bbox_inches='tight', format='png',
               facecolor='white', edgecolor='none')
    print(f"\n✓ Saved high-resolution PNG: {png_file}")
    
    svg_file = get_output_path('Figure_4_moai_analysis.svg')
    fig.savefig(svg_file, bbox_inches='tight', format='svg',
               facecolor='white', edgecolor='none')
    print(f"✓ Saved SVG: {svg_file}")
    
    plt.close()

def main():
    obj_file = "../data/SimplifiedMoai.obj"
    
    print("Final Moai Analysis with Accurate Base Outline")
    print("=" * 50)
    
    try:
        mesh, center_of_mass, scale_factor = load_and_analyze_moai(obj_file)
        
        print("\n" + "=" * 50)
        print("Creating visualization with scaled measurements for 7.35m tall moai...")
        visualize_moai_final(mesh, center_of_mass, scale_factor)
        
        print("\nVisualization complete! Check the saved files:")
        print("  - Figure_4_moai_analysis_600dpi.png")
        print("  - Figure_4_moai_analysis.svg")
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()