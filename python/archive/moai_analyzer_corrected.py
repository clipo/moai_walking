import numpy as np
import matplotlib
matplotlib.use('Agg')  # Use non-interactive backend
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
from matplotlib import cm
import trimesh
import os

def load_and_analyze_moai(obj_file):
    """Load the moai mesh and analyze its center of mass"""
    
    # Load the mesh
    mesh = trimesh.load(obj_file)
    print(f"Loaded mesh with {len(mesh.vertices)} vertices and {len(mesh.faces)} faces")
    
    # In the OBJ file: Y is vertical (height), X is width, Z is depth
    # We'll keep this orientation for analysis
    bounds = mesh.bounds
    print(f"\nMesh bounds:")
    print(f"  X (width): {bounds[0][0]:.3f} to {bounds[1][0]:.3f}")
    print(f"  Y (height): {bounds[0][1]:.3f} to {bounds[1][1]:.3f}")
    print(f"  Z (depth): {bounds[0][2]:.3f} to {bounds[1][2]:.3f}")
    
    # Calculate center of mass
    center_of_mass = mesh.center_mass
    
    print(f"\nCenter of mass: X={center_of_mass[0]:.3f}, Y={center_of_mass[1]:.3f}, Z={center_of_mass[2]:.3f}")
    
    # Calculate height from base (Y is vertical)
    base_y = bounds[0][1]  # minimum Y is the base
    height_from_base = center_of_mass[1] - base_y
    total_height = bounds[1][1] - bounds[0][1]
    height_percentage = (height_from_base / total_height) * 100
    
    print(f"\nHeight analysis:")
    print(f"  Base Y coordinate: {base_y:.3f}")
    print(f"  Center of mass height from base: {height_from_base:.3f}")
    print(f"  Total height: {total_height:.3f}")
    print(f"  Center of mass at {height_percentage:.1f}% of total height")
    
    # Find the base vertices (those near minimum Y)
    base_threshold = base_y + 0.05
    base_vertices = mesh.vertices[mesh.vertices[:, 1] < base_threshold]
    
    if len(base_vertices) > 0:
        base_x_min = base_vertices[:, 0].min()
        base_x_max = base_vertices[:, 0].max()
        base_z_min = base_vertices[:, 2].min()
        base_z_max = base_vertices[:, 2].max()
        
        print(f"\nBase dimensions:")
        print(f"  X range: {base_x_min:.3f} to {base_x_max:.3f} (width: {base_x_max - base_x_min:.3f})")
        print(f"  Z range: {base_z_min:.3f} to {base_z_max:.3f} (depth: {base_z_max - base_z_min:.3f})")
        
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
        
        print(f"\nCenter of mass offset from base center:")
        print(f"  X offset: {offset_x:.3f} ({'right' if offset_x > 0 else 'left'} when viewed from front)")
        print(f"  Z offset: {offset_z:.3f} ({'forward' if offset_z > 0 else 'backward'})")
        
        # Determine which edge is likely the front
        # Moai typically lean forward, so max Z is likely the front
        front_edge_z = base_z_max
        distance_to_front = front_edge_z - center_of_mass[2]
        
        print(f"\nFront edge analysis:")
        print(f"  Front edge Z: {front_edge_z:.3f}")
        print(f"  COM distance from front edge: {distance_to_front:.3f}")
        print(f"  COM is {'over' if distance_to_front < 0 else 'behind'} the front edge")
    
    return mesh, center_of_mass

def visualize_moai_corrected(mesh, center_of_mass):
    """Create corrected 3D visualization with proper orientation"""
    
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
    
    # Plot vertices colored by height (Y coordinate)
    scatter = ax.scatter(vertices_sample[:, 0],  # X
                        vertices_sample[:, 2],  # Z (depth)
                        vertices_sample[:, 1],  # Y (height)
                        c=vertices_sample[:, 1], cmap='copper', s=3, alpha=0.6)
    
    # Plot center of mass
    ax.scatter(center_of_mass[0], center_of_mass[2], center_of_mass[1], 
               c='red', s=500, marker='o', edgecolors='black', linewidth=3,
               label='Center of Mass', zorder=1000)
    
    # Plot COM projection on base
    base_y = mesh.bounds[0][1]
    ax.scatter(center_of_mass[0], center_of_mass[2], base_y, 
               c='red', s=200, marker='X', linewidth=4,
               label='COM ground projection')
    
    # Draw vertical line from base to COM
    ax.plot([center_of_mass[0], center_of_mass[0]], 
            [center_of_mass[2], center_of_mass[2]], 
            [base_y, center_of_mass[1]], 
            'r--', linewidth=3, alpha=0.8)
    
    # Add coordinate axes at COM for reference
    axis_length = 0.1
    # X-axis (red)
    ax.quiver(center_of_mass[0], center_of_mass[2], center_of_mass[1],
              axis_length, 0, 0, color='red', alpha=0.7, linewidth=2)
    # Z-axis (blue) - pointing forward
    ax.quiver(center_of_mass[0], center_of_mass[2], center_of_mass[1],
              0, axis_length, 0, color='blue', alpha=0.7, linewidth=2)
    # Y-axis (green) - pointing up
    ax.quiver(center_of_mass[0], center_of_mass[2], center_of_mass[1],
              0, 0, axis_length, color='green', alpha=0.7, linewidth=2)
    
    # Set labels with correct mapping
    ax.set_xlabel('X (width)', fontsize=12)
    ax.set_ylabel('Z (depth)', fontsize=12)
    ax.set_zlabel('Y (height)', fontsize=12)
    ax.set_title('Moai 3D View with Center of Mass', fontsize=14)
    
    # Set viewing angle - rotate to show front of moai
    ax.view_init(elev=20, azim=-135)  # Negative azimuth to view from front
    
    # Set aspect ratio
    ax.set_box_aspect([1,
                       (mesh.bounds[1][2] - mesh.bounds[0][2]) / (mesh.bounds[1][0] - mesh.bounds[0][0]),
                       (mesh.bounds[1][1] - mesh.bounds[0][1]) / (mesh.bounds[1][0] - mesh.bounds[0][0])])
    
    ax.legend(loc='upper left')
    
    # Create top-down view (looking down Y-axis)
    ax2 = fig.add_subplot(122)
    
    # Get base vertices
    base_threshold = base_y + 0.05
    base_vertices = mesh.vertices[mesh.vertices[:, 1] < base_threshold]
    
    if len(base_vertices) > 0:
        # Plot base points
        ax2.scatter(base_vertices[:, 0], base_vertices[:, 2], 
                   c='lightgray', s=2, alpha=0.5, label='Base points')
        
        # Get base bounds
        base_x_min, base_x_max = base_vertices[:, 0].min(), base_vertices[:, 0].max()
        base_z_min, base_z_max = base_vertices[:, 2].min(), base_vertices[:, 2].max()
        
        # Draw actual base outline using convex hull
        from scipy.spatial import ConvexHull
        try:
            if len(base_vertices) > 3:
                # Get convex hull of base points
                hull = ConvexHull(base_vertices[:, [0, 2]])  # X and Z coordinates
                
                # Plot hull outline
                for simplex in hull.simplices:
                    ax2.plot(base_vertices[hull.vertices[simplex], 0], 
                            base_vertices[hull.vertices[simplex], 2], 
                            'b-', linewidth=2.5, alpha=0.8)
                
                # Fill the hull with a light color
                hull_points = base_vertices[hull.vertices]
                from matplotlib.patches import Polygon
                hull_polygon = Polygon(hull_points[:, [0, 2]], 
                                     fill=True, facecolor='lightblue', 
                                     edgecolor='blue', linewidth=2.5,
                                     alpha=0.2, label='Base outline')
                ax2.add_patch(hull_polygon)
        except:
            # Fallback to rectangle if hull fails
            from matplotlib.patches import Rectangle
            base_rect = Rectangle((base_x_min, base_z_min), 
                                 base_x_max - base_x_min, 
                                 base_z_max - base_z_min,
                                 fill=False, edgecolor='blue', linewidth=2.5, 
                                 linestyle='--', label='Base boundary')
            ax2.add_patch(base_rect)
        
        # Mark base center
        base_center_x = (base_x_min + base_x_max) / 2
        base_center_z = (base_z_min + base_z_max) / 2
        ax2.scatter(base_center_x, base_center_z, c='blue', s=150, marker='+', 
                   linewidth=3, label='Base center')
        
        # Draw line from base center to COM
        ax2.plot([base_center_x, center_of_mass[0]], 
                [base_center_z, center_of_mass[2]], 
                'k:', linewidth=1.5, alpha=0.5)
        
        # Mark front edge (max Z)
        ax2.axhline(y=base_z_max, color='green', linestyle=':', alpha=0.7, 
                   label='Front edge')
    
    # Plot center of mass
    ax2.scatter(center_of_mass[0], center_of_mass[2], 
               c='red', s=300, marker='o', 
               edgecolors='darkred', linewidth=2.5, 
               label='Center of Mass', zorder=5)
    
    # Add grid and labels
    ax2.grid(True, alpha=0.3, linestyle=':')
    ax2.set_xlabel('X (width)', fontsize=12)
    ax2.set_ylabel('Z (depth)', fontsize=12)
    ax2.set_title('Top-down View: Center of Mass vs Base', fontsize=14)
    ax2.axis('equal')
    ax2.legend(loc='best', fontsize=10)
    
    # Add annotations with arrows
    ax2.annotate('Back', xy=(0.95, 0.05), xycoords='axes fraction', 
                fontsize=10, ha='right', va='bottom', style='italic')
    ax2.annotate('Front', xy=(0.95, 0.95), xycoords='axes fraction',
                fontsize=10, ha='right', va='top', style='italic')
    ax2.annotate('Left', xy=(0.05, 0.5), xycoords='axes fraction',
                fontsize=10, ha='left', va='center', style='italic', rotation=90)
    ax2.annotate('Right', xy=(0.95, 0.5), xycoords='axes fraction',
                fontsize=10, ha='right', va='center', style='italic', rotation=-90)
    
    plt.tight_layout()
    
    # Save figures
    png_file = 'moai_analysis_corrected_600dpi.png'
    fig.savefig(png_file, dpi=600, bbox_inches='tight', format='png',
               facecolor='white', edgecolor='none')
    print(f"\n✓ Saved high-resolution PNG: {png_file}")
    
    svg_file = 'moai_analysis_corrected.svg'
    fig.savefig(svg_file, bbox_inches='tight', format='svg',
               facecolor='white', edgecolor='none')
    print(f"✓ Saved SVG: {svg_file}")
    
    plt.close()

def main():
    obj_file = "../data/SimplifiedMoai.obj"
    
    print("Corrected Moai Analysis")
    print("=" * 50)
    
    try:
        mesh, center_of_mass = load_and_analyze_moai(obj_file)
        
        print("\n" + "=" * 50)
        print("Creating corrected visualization...")
        visualize_moai_corrected(mesh, center_of_mass)
        
        print("\nVisualization complete! Check the saved files:")
        print("  - moai_analysis_corrected_600dpi.png")
        print("  - moai_analysis_corrected.svg")
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()