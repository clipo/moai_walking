import numpy as np
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
    # For a triangulated mesh, the center of mass is the weighted average of triangle centroids
    # weighted by their areas
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
    
    # Determine front/back orientation
    # We'll need to identify which direction is front by analyzing the mesh shape
    # For a moai, the front typically has more protruding features (nose, chin)
    
    # Find the base vertices (those near the minimum Y value)
    base_threshold = base_y + 0.05  # vertices within 5cm of base
    base_vertices = mesh.vertices[mesh.vertices[:, 1] < base_threshold]
    
    if len(base_vertices) > 0:
        # Calculate the base outline
        base_x_min = base_vertices[:, 0].min()
        base_x_max = base_vertices[:, 0].max()
        base_z_min = base_vertices[:, 2].min()
        base_z_max = base_vertices[:, 2].max()
        
        print(f"\nBase dimensions:")
        print(f"  X range: {base_x_min:.3f} to {base_x_max:.3f} (width: {base_x_max - base_x_min:.3f})")
        print(f"  Z range: {base_z_min:.3f} to {base_z_max:.3f} (depth: {base_z_max - base_z_min:.3f})")
        
        # Check if center of mass is within the base footprint
        com_within_base_x = base_x_min <= center_of_mass[0] <= base_x_max
        com_within_base_z = base_z_min <= center_of_mass[2] <= base_z_max
        
        print(f"\nStability analysis:")
        print(f"  Center of mass X: {center_of_mass[0]:.3f} ({'within' if com_within_base_x else 'outside'} base X range)")
        print(f"  Center of mass Z: {center_of_mass[2]:.3f} ({'within' if com_within_base_z else 'outside'} base Z range)")
        
        # Calculate distance from center of base
        base_center_x = (base_x_min + base_x_max) / 2
        base_center_z = (base_z_min + base_z_max) / 2
        
        offset_x = center_of_mass[0] - base_center_x
        offset_z = center_of_mass[2] - base_center_z
        
        print(f"\nCenter of mass offset from base center:")
        print(f"  X offset: {offset_x:.3f} ({'forward' if offset_x > 0 else 'backward'})")
        print(f"  Z offset: {offset_z:.3f} ({'right' if offset_z > 0 else 'left'})")
    
    return mesh, center_of_mass

def visualize_moai_with_com(mesh, center_of_mass, save_figures=True):
    """Create 3D visualization of the moai with center of mass marked"""
    
    fig = plt.figure(figsize=(16, 10))
    
    # Create 3D plot
    ax = fig.add_subplot(121, projection='3d')
    
    # Plot the mesh surface using triangles
    vertices = mesh.vertices
    faces = mesh.faces
    
    # Create a collection of triangles
    triangles = vertices[faces]
    
    # Calculate face normals for shading
    face_normals = mesh.face_normals
    
    # Calculate lighting (simple directional light from above-front)
    light_direction = np.array([0.2, 0.5, 0.7])
    light_direction = light_direction / np.linalg.norm(light_direction)
    
    # Calculate shading based on dot product with light direction
    shading = np.dot(face_normals, light_direction)
    shading = np.clip(shading, 0, 1)  # Only positive values (front-facing)
    
    # Create color map based on height and shading
    face_centers = triangles.mean(axis=1)
    heights = face_centers[:, 1]
    height_normalized = (heights - heights.min()) / (heights.max() - heights.min())
    
    # Combine height coloring with shading
    colors = cm.copper(height_normalized)
    colors[:, :3] *= shading[:, np.newaxis]  # Apply shading to RGB, not alpha
    
    # Create the 3D polygon collection
    poly3d = Poly3DCollection(triangles, facecolors=colors, edgecolors='none', alpha=0.9)
    ax.add_collection3d(poly3d)
    
    # Add subtle wireframe for better shape definition
    # Sample faces to avoid too dense wireframe
    if len(faces) > 2000:
        face_indices = np.random.choice(len(faces), size=2000, replace=False)
        wireframe_faces = faces[face_indices]
    else:
        wireframe_faces = faces
    
    wireframe_triangles = vertices[wireframe_faces]
    wireframe = Poly3DCollection(wireframe_triangles, 
                                facecolors='none', 
                                edgecolors='gray', 
                                alpha=0.3, 
                                linewidths=0.5)
    ax.add_collection3d(wireframe)
    
    # Plot center of mass as a large red sphere
    ax.scatter(center_of_mass[0], center_of_mass[1], center_of_mass[2], 
               c='red', s=500, marker='o', edgecolors='black', linewidth=3,
               label='Center of Mass', zorder=1000)
    
    # Plot projection of COM onto base plane
    base_y = mesh.bounds[0][1]
    ax.scatter(center_of_mass[0], base_y, center_of_mass[2], 
               c='red', s=200, marker='x', linewidth=4,
               label='COM projection on base')
    
    # Draw a vertical line from base to COM
    ax.plot([center_of_mass[0], center_of_mass[0]], 
            [base_y, center_of_mass[1]], 
            [center_of_mass[2], center_of_mass[2]], 
            'r--', linewidth=3, alpha=0.8)
    
    # Set the aspect ratio and limits
    ax.set_xlim(mesh.bounds[0][0], mesh.bounds[1][0])
    ax.set_ylim(mesh.bounds[0][1], mesh.bounds[1][1])
    ax.set_zlim(mesh.bounds[0][2], mesh.bounds[1][2])
    
    # Set labels
    ax.set_xlabel('X (width)', fontsize=12)
    ax.set_ylabel('Y (height)', fontsize=12)
    ax.set_zlabel('Z (depth)', fontsize=12)
    ax.set_title('Moai 3D View with Center of Mass', fontsize=14)
    
    # Adjust viewing angle for better visibility
    ax.view_init(elev=15, azim=45)
    
    # Set aspect ratio to be equal
    ax.set_box_aspect([1, 
                       (mesh.bounds[1][1] - mesh.bounds[0][1]) / (mesh.bounds[1][0] - mesh.bounds[0][0]),
                       (mesh.bounds[1][2] - mesh.bounds[0][2]) / (mesh.bounds[1][0] - mesh.bounds[0][0])])
    
    ax.legend(loc='upper left', fontsize=10)
    
    # Create top-down view
    ax2 = fig.add_subplot(122)
    
    # Plot base outline
    base_threshold = base_y + 0.05
    base_vertices = mesh.vertices[mesh.vertices[:, 1] < base_threshold]
    
    if len(base_vertices) > 0:
        # Create a scatter plot of base vertices
        ax2.scatter(base_vertices[:, 0], base_vertices[:, 2], c='gray', s=1, alpha=0.5)
        
        # Plot the convex hull of the base
        from scipy.spatial import ConvexHull
        try:
            if len(base_vertices) > 3:
                hull = ConvexHull(base_vertices[:, [0, 2]])
                for simplex in hull.simplices:
                    ax2.plot(base_vertices[simplex, 0], base_vertices[simplex, 2], 'k-', alpha=0.3)
        except Exception as e:
            print(f"Warning: Could not compute convex hull: {e}")
        
        # Mark the edges of the base
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
    
    # Plot center of mass projection
    ax2.scatter(center_of_mass[0], center_of_mass[2], c='red', s=200, marker='o', 
               edgecolors='black', linewidth=2, label='Center of Mass', zorder=5)
    
    # Mark base center
    if len(base_vertices) > 0:
        base_center_x = (base_x_min + base_x_max) / 2
        base_center_z = (base_z_min + base_z_max) / 2
        ax2.scatter(base_center_x, base_center_z, c='blue', s=100, marker='+', 
                   linewidth=3, label='Base center', zorder=4)
    
    ax2.set_xlabel('X (width)', fontsize=12)
    ax2.set_ylabel('Z (depth)', fontsize=12)
    ax2.set_title('Top-down View: Center of Mass vs Base', fontsize=14)
    ax2.axis('equal')
    ax2.grid(True, alpha=0.3)
    ax2.legend(fontsize=10)
    
    plt.tight_layout()
    
    if save_figures:
        # Save as high-resolution PNG
        png_filename = 'moai_analysis_600dpi.png'
        fig.savefig(png_filename, dpi=600, bbox_inches='tight', format='png')
        print(f"\nSaved high-resolution PNG: {png_filename}")
        
        # Save as SVG
        svg_filename = 'moai_analysis.svg'
        fig.savefig(svg_filename, bbox_inches='tight', format='svg')
        print(f"Saved SVG: {svg_filename}")
    
    plt.show()

def main():
    obj_file = "../data/SimplifiedMoai.obj"
    
    print("Analyzing Moai mesh...")
    print("=" * 50)
    
    try:
        mesh, center_of_mass = load_and_analyze_moai(obj_file)
        
        print("\n" + "=" * 50)
        print("Creating visualization...")
        visualize_moai_with_com(mesh, center_of_mass)
        
    except Exception as e:
        print(f"Error: {e}")
        print("Make sure you have trimesh, numpy, matplotlib, and scipy installed:")
        print("pip install trimesh numpy matplotlib scipy")

if __name__ == "__main__":
    main()