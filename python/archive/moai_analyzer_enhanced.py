import numpy as np
import matplotlib
matplotlib.use('TkAgg')  # Use interactive backend
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

def visualize_moai_enhanced(mesh, center_of_mass, save_figures=True):
    """Create enhanced 3D visualization with mesh surface"""
    
    fig = plt.figure(figsize=(18, 10))
    
    # Create 3D plot with mesh surface
    ax = fig.add_subplot(121, projection='3d')
    
    # Use full mesh or subsample faces for visualization
    vertices = mesh.vertices
    faces = mesh.faces
    
    if len(faces) > 5000:
        print("Subsampling faces for visualization...")
        # Randomly sample faces for visualization
        face_indices = np.random.choice(len(faces), 5000, replace=False)
        faces = faces[face_indices]
    
    # Create triangles for surface rendering
    triangles = vertices[faces]
    
    # Calculate lighting
    face_normals = np.cross(
        triangles[:, 1] - triangles[:, 0],
        triangles[:, 2] - triangles[:, 0]
    )
    face_normals = face_normals / np.linalg.norm(face_normals, axis=1, keepdims=True)
    
    # Light from front-above
    light_dir = np.array([0.3, 0.5, 0.7])
    light_dir = light_dir / np.linalg.norm(light_dir)
    
    # Calculate shading
    shading = np.dot(face_normals, light_dir)
    shading = np.clip(shading, 0.2, 1.0)  # Keep minimum brightness
    
    # Color by height with shading
    face_centers = triangles.mean(axis=1)
    heights = face_centers[:, 1]
    height_norm = (heights - heights.min()) / (heights.max() - heights.min())
    
    # Create colors
    base_colors = cm.copper(height_norm)
    colors = base_colors.copy()
    colors[:, :3] *= shading[:, np.newaxis]
    
    # Plot mesh surface
    mesh_collection = Poly3DCollection(triangles, 
                                      facecolors=colors, 
                                      edgecolors='none',
                                      alpha=0.95)
    ax.add_collection3d(mesh_collection)
    
    # Add edge highlighting for better shape definition
    edge_collection = Poly3DCollection(triangles[::10],  # Every 10th face
                                      facecolors='none', 
                                      edgecolors='darkgray',
                                      linewidths=0.3,
                                      alpha=0.5)
    ax.add_collection3d(edge_collection)
    
    # Plot center of mass
    ax.scatter(center_of_mass[0], center_of_mass[1], center_of_mass[2], 
               c='red', s=800, marker='o', edgecolors='darkred', linewidth=3,
               label='Center of Mass', zorder=1000)
    
    # Add coordinate axes at COM
    axis_length = 0.1
    ax.quiver(center_of_mass[0], center_of_mass[1], center_of_mass[2],
              axis_length, 0, 0, color='red', alpha=0.7, linewidth=2)
    ax.quiver(center_of_mass[0], center_of_mass[1], center_of_mass[2],
              0, axis_length, 0, color='green', alpha=0.7, linewidth=2)
    ax.quiver(center_of_mass[0], center_of_mass[1], center_of_mass[2],
              0, 0, axis_length, color='blue', alpha=0.7, linewidth=2)
    
    # Plot COM projection
    base_y = mesh.bounds[0][1]
    ax.scatter(center_of_mass[0], base_y, center_of_mass[2], 
               c='red', s=300, marker='X', linewidth=3,
               label='COM ground projection')
    
    # Vertical line
    ax.plot([center_of_mass[0], center_of_mass[0]], 
            [base_y, center_of_mass[1]], 
            [center_of_mass[2], center_of_mass[2]], 
            'r--', linewidth=2.5, alpha=0.7)
    
    # Set proper aspect ratio and limits
    ax.set_xlim(mesh.bounds[0][0], mesh.bounds[1][0])
    ax.set_ylim(mesh.bounds[0][1], mesh.bounds[1][1])
    ax.set_zlim(mesh.bounds[0][2], mesh.bounds[1][2])
    
    # Labels and title
    ax.set_xlabel('X (width)', fontsize=12, labelpad=10)
    ax.set_ylabel('Y (height)', fontsize=12, labelpad=10)
    ax.set_zlabel('Z (depth)', fontsize=12, labelpad=10)
    ax.set_title('Moai 3D Surface with Center of Mass', fontsize=14, pad=20)
    
    # Set viewing angle
    ax.view_init(elev=15, azim=-60)
    
    # Equal aspect ratio
    ax.set_box_aspect([1,
                       (mesh.bounds[1][1] - mesh.bounds[0][1]) / (mesh.bounds[1][0] - mesh.bounds[0][0]),
                       (mesh.bounds[1][2] - mesh.bounds[0][2]) / (mesh.bounds[1][0] - mesh.bounds[0][0])])
    
    ax.legend(loc='upper right', fontsize=10)
    
    # Create top-down view
    ax2 = fig.add_subplot(122)
    
    # Get base outline
    base_threshold = base_y + 0.05
    base_vertices = mesh.vertices[mesh.vertices[:, 1] < base_threshold]
    
    if len(base_vertices) > 0:
        # Plot base points
        ax2.scatter(base_vertices[:, 0], base_vertices[:, 2], 
                   c='lightgray', s=2, alpha=0.5, label='Base points')
        
        # Get base bounds
        base_x_min, base_x_max = base_vertices[:, 0].min(), base_vertices[:, 0].max()
        base_z_min, base_z_max = base_vertices[:, 2].min(), base_vertices[:, 2].max()
        
        # Draw base rectangle
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
        
        # Draw COM to base center line
        ax2.plot([base_center_x, center_of_mass[0]], 
                [base_center_z, center_of_mass[2]], 
                'k:', linewidth=1.5, alpha=0.5)
    
    # Plot center of mass
    ax2.scatter(center_of_mass[0], center_of_mass[2], 
               c='red', s=300, marker='o', 
               edgecolors='darkred', linewidth=2.5, 
               label='Center of Mass', zorder=5)
    
    # Add grid
    ax2.grid(True, alpha=0.3, linestyle=':')
    ax2.set_xlabel('X (width)', fontsize=12)
    ax2.set_ylabel('Z (depth)', fontsize=12)
    ax2.set_title('Top View: Center of Mass Position', fontsize=14)
    ax2.axis('equal')
    ax2.legend(loc='best', fontsize=10)
    
    plt.tight_layout()
    
    if save_figures:
        # Save high-res PNG
        png_file = 'moai_analysis_enhanced_600dpi.png'
        fig.savefig(png_file, dpi=600, bbox_inches='tight', format='png',
                   facecolor='white', edgecolor='none')
        print(f"\n✓ Saved high-resolution PNG: {png_file}")
        
        # Save SVG
        svg_file = 'moai_analysis_enhanced.svg'
        fig.savefig(svg_file, bbox_inches='tight', format='svg',
                   facecolor='white', edgecolor='none')
        print(f"✓ Saved SVG: {svg_file}")
    
    plt.show()

def main():
    obj_file = "../data/SimplifiedMoai.obj"
    
    print("Enhanced Moai Analysis")
    print("=" * 50)
    
    try:
        mesh, center_of_mass = load_and_analyze_moai(obj_file)
        
        print("\n" + "=" * 50)
        print("Creating enhanced visualization...")
        visualize_moai_enhanced(mesh, center_of_mass)
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()