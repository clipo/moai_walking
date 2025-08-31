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
    
    # Get mesh properties
    bounds = mesh.bounds
    print(f"\nMesh bounds:")
    print(f"  X: {bounds[0][0]:.3f} to {bounds[1][0]:.3f}")
    print(f"  Y: {bounds[0][1]:.3f} to {bounds[1][1]:.3f} (vertical axis)")
    print(f"  Z: {bounds[0][2]:.3f} to {bounds[1][2]:.3f}")
    
    # Calculate center of mass (assuming uniform density)
    center_of_mass = mesh.center_mass
    
    print(f"\nCenter of mass: ({center_of_mass[0]:.3f}, {center_of_mass[1]:.3f}, {center_of_mass[2]:.3f})")
    
    # Calculate height from base
    base_y = bounds[0][1]
    height_from_base = center_of_mass[1] - base_y
    total_height = bounds[1][1] - bounds[0][1]
    height_percentage = (height_from_base / total_height) * 100
    
    print(f"\nHeight analysis:")
    print(f"  Base Y coordinate: {base_y:.3f}")
    print(f"  Center of mass height from base: {height_from_base:.3f}")
    print(f"  Total height: {total_height:.3f}")
    print(f"  Center of mass at {height_percentage:.1f}% of total height")
    
    # Find the base vertices
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
        
        com_within_base_x = base_x_min <= center_of_mass[0] <= base_x_max
        com_within_base_z = base_z_min <= center_of_mass[2] <= base_z_max
        
        print(f"\nStability analysis:")
        print(f"  Center of mass X: {center_of_mass[0]:.3f} ({'within' if com_within_base_x else 'outside'} base X range)")
        print(f"  Center of mass Z: {center_of_mass[2]:.3f} ({'within' if com_within_base_z else 'outside'} base Z range)")
        
        base_center_x = (base_x_min + base_x_max) / 2
        base_center_z = (base_z_min + base_z_max) / 2
        
        offset_x = center_of_mass[0] - base_center_x
        offset_z = center_of_mass[2] - base_center_z
        
        print(f"\nCenter of mass offset from base center:")
        print(f"  X offset: {offset_x:.3f} ({'forward' if offset_x > 0 else 'backward'})")
        print(f"  Z offset: {offset_z:.3f} ({'right' if offset_z > 0 else 'left'})")
    
    return mesh, center_of_mass

def create_simple_visualization(mesh, center_of_mass):
    """Create a simpler 3D visualization using only matplotlib"""
    
    fig = plt.figure(figsize=(16, 10))
    
    # Create 3D plot
    ax = fig.add_subplot(121, projection='3d')
    
    # Sample vertices for faster rendering
    vertices = mesh.vertices
    if len(vertices) > 5000:
        indices = np.random.choice(len(vertices), 5000, replace=False)
        vertices_sample = vertices[indices]
    else:
        vertices_sample = vertices
    
    # Create scatter plot colored by height
    heights = vertices_sample[:, 1]
    scatter = ax.scatter(vertices_sample[:, 0], vertices_sample[:, 1], vertices_sample[:, 2], 
                        c=heights, cmap='copper', s=2, alpha=0.6)
    
    # Plot center of mass
    ax.scatter(center_of_mass[0], center_of_mass[1], center_of_mass[2], 
               c='red', s=500, marker='o', edgecolors='black', linewidth=3,
               label='Center of Mass')
    
    # Plot COM projection
    base_y = mesh.bounds[0][1]
    ax.scatter(center_of_mass[0], base_y, center_of_mass[2], 
               c='red', s=200, marker='x', linewidth=4,
               label='COM projection on base')
    
    # Draw vertical line
    ax.plot([center_of_mass[0], center_of_mass[0]], 
            [base_y, center_of_mass[1]], 
            [center_of_mass[2], center_of_mass[2]], 
            'r--', linewidth=3)
    
    ax.set_xlabel('X (width)', fontsize=12)
    ax.set_ylabel('Y (height)', fontsize=12)
    ax.set_zlabel('Z (depth)', fontsize=12)
    ax.set_title('Moai 3D View with Center of Mass', fontsize=14)
    ax.view_init(elev=20, azim=45)
    ax.legend()
    
    # Create top-down view
    ax2 = fig.add_subplot(122)
    
    # Plot base vertices
    base_threshold = base_y + 0.05
    base_vertices = mesh.vertices[mesh.vertices[:, 1] < base_threshold]
    
    if len(base_vertices) > 0:
        ax2.scatter(base_vertices[:, 0], base_vertices[:, 2], c='gray', s=1, alpha=0.5)
        
        base_x_min, base_x_max = base_vertices[:, 0].min(), base_vertices[:, 0].max()
        base_z_min, base_z_max = base_vertices[:, 2].min(), base_vertices[:, 2].max()
        
        # Draw base rectangle
        from matplotlib.patches import Rectangle
        rect = Rectangle((base_x_min, base_z_min), 
                        base_x_max - base_x_min, 
                        base_z_max - base_z_min,
                        fill=False, edgecolor='blue', linewidth=2, linestyle='--',
                        label='Base bounds')
        ax2.add_patch(rect)
        
        # Mark base center
        base_center_x = (base_x_min + base_x_max) / 2
        base_center_z = (base_z_min + base_z_max) / 2
        ax2.scatter(base_center_x, base_center_z, c='blue', s=100, marker='+', 
                   linewidth=3, label='Base center')
    
    # Plot center of mass
    ax2.scatter(center_of_mass[0], center_of_mass[2], c='red', s=200, marker='o', 
               edgecolors='black', linewidth=2, label='Center of Mass')
    
    ax2.set_xlabel('X (width)', fontsize=12)
    ax2.set_ylabel('Z (depth)', fontsize=12)
    ax2.set_title('Top-down View: Center of Mass vs Base', fontsize=14)
    ax2.axis('equal')
    ax2.grid(True, alpha=0.3)
    ax2.legend()
    
    plt.tight_layout()
    
    # Save figures
    png_filename = 'Figure_4_moai_analysis_headless_600dpi.png'
    fig.savefig(png_filename, dpi=600, bbox_inches='tight', format='png')
    print(f"\n✓ Saved high-resolution PNG: {png_filename}")
    
    svg_filename = 'Figure_4_moai_analysis_headless.svg'
    fig.savefig(svg_filename, bbox_inches='tight', format='svg')
    print(f"✓ Saved SVG: {svg_filename}")
    
    plt.close()

def main():
    obj_file = "../data/SimplifiedMoai.obj"
    
    print("Analyzing Moai mesh...")
    print("=" * 50)
    
    try:
        mesh, center_of_mass = load_and_analyze_moai(obj_file)
        
        print("\n" + "=" * 50)
        print("Creating visualization...")
        create_simple_visualization(mesh, center_of_mass)
        
        print("\nVisualization complete! Check the saved files:")
        print("  - Figure_4_moai_analysis_headless_600dpi.png (high-resolution raster image)")
        print("  - Figure_4_moai_analysis_headless.svg (scalable vector graphics)")
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()