import numpy as np
import trimesh
import plotly.graph_objects as go
from output_helper import get_output_path

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
    
    # Calculate center of mass
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
    
    return mesh, center_of_mass

def create_plotly_visualization(mesh, center_of_mass):
    """Create interactive 3D visualization using Plotly"""
    
    # Calculate scale factor to match 7.35m tall moai
    SCALE_FACTOR = 7.35 / (mesh.bounds[1][1] - mesh.bounds[0][1])
    print(f"Scale factor: {SCALE_FACTOR}")
    
    # Create single 3D plot
    fig = go.Figure()
    
    # Prepare mesh data
    vertices = mesh.vertices
    faces = mesh.faces
    
    # Get vertex coordinates
    x, y, z = vertices[:, 0], vertices[:, 1], vertices[:, 2]
    
    # Get face indices (Plotly uses vertex indices for faces)
    i, j, k = faces[:, 0], faces[:, 1], faces[:, 2]
    
    # Calculate vertex colors based on height
    vertex_heights = y
    vertex_colors = (vertex_heights - vertex_heights.min()) / (vertex_heights.max() - vertex_heights.min())
    
    # Add mesh
    fig.add_trace(
        go.Mesh3d(
            x=x * SCALE_FACTOR,
            y=y * SCALE_FACTOR,
            z=z * SCALE_FACTOR,
            i=i, j=j, k=k,
            intensity=vertex_colors,
            colorscale='Viridis',
            showscale=True,
            colorbar=dict(
                title="Height<br>(normalized)",
                thickness=15,
                len=0.7,
                y=0.5
            ),
            opacity=0.7,
            flatshading=True,
            lighting=dict(
                ambient=0.5,
                diffuse=0.8,
                roughness=0.5,
                specular=0.3,
                fresnel=0.2
            ),
            lightposition=dict(
                x=100,
                y=200,
                z=100
            ),
            name='Moai Mesh',
            hoverinfo='none'
        )
    )
    
    # Add center of mass point
    fig.add_trace(
        go.Scatter3d(
            x=[center_of_mass[0] * SCALE_FACTOR],
            y=[center_of_mass[1] * SCALE_FACTOR],
            z=[center_of_mass[2] * SCALE_FACTOR],
            mode='markers+text',
            marker=dict(
                size=15,
                color='red',
                line=dict(color='darkred', width=3),
                symbol='diamond'
            ),
            text=['Center of Mass'],
            textposition='top center',
            textfont=dict(size=12, color='darkred'),
            name='Center of Mass',
            showlegend=True,
            hovertemplate='COM<br>X: %{x:.2f}m<br>Y: %{y:.2f}m<br>Z: %{z:.2f}m<extra></extra>'
        )
    )
    
    # Add COM projection on base
    base_y = mesh.bounds[0][1]
    fig.add_trace(
        go.Scatter3d(
            x=[center_of_mass[0] * SCALE_FACTOR],
            y=[base_y * SCALE_FACTOR],
            z=[center_of_mass[2] * SCALE_FACTOR],
            mode='markers',
            marker=dict(
                size=10,
                color='red',
                symbol='x',
                line=dict(color='darkred', width=2)
            ),
            name='COM Ground Projection',
            showlegend=True,
            hovertemplate='Ground Projection<br>X: %{x:.2f}m<br>Y: %{y:.2f}m<br>Z: %{z:.2f}m<extra></extra>'
        )
    )
    
    # Add vertical line from base to COM
    fig.add_trace(
        go.Scatter3d(
            x=[center_of_mass[0] * SCALE_FACTOR, center_of_mass[0] * SCALE_FACTOR],
            y=[base_y * SCALE_FACTOR, center_of_mass[1] * SCALE_FACTOR],
            z=[center_of_mass[2] * SCALE_FACTOR, center_of_mass[2] * SCALE_FACTOR],
            mode='lines',
            line=dict(color='red', width=8, dash='dash'),
            name='COM Height',
            showlegend=False,
            hoverinfo='skip'
        )
    )
    
    # Add vertical reference line from base center
    base_center_x = (mesh.bounds[0][0] + mesh.bounds[1][0]) / 2
    base_center_z = (mesh.bounds[0][2] + mesh.bounds[1][2]) / 2
    
    fig.add_trace(
        go.Scatter3d(
            x=[base_center_x * SCALE_FACTOR, base_center_x * SCALE_FACTOR],
            y=[base_y * SCALE_FACTOR, mesh.bounds[1][1] * SCALE_FACTOR],
            z=[base_center_z * SCALE_FACTOR, base_center_z * SCALE_FACTOR],
            mode='lines',
            line=dict(color='black', width=4, dash='dot'),
            name='Vertical Reference',
            showlegend=True,
            hoverinfo='skip'
        )
    )
    
    # Add base outline at ground level
    base_threshold = base_y + 0.05
    base_vertices = mesh.vertices[mesh.vertices[:, 1] < base_threshold]
    if len(base_vertices) > 0:
        # Get hull of base points
        from scipy.spatial import ConvexHull
        base_points_2d = base_vertices[:, [0, 2]]
        try:
            hull = ConvexHull(base_points_2d)
            hull_points = base_points_2d[hull.vertices]
            # Close the loop
            hull_points = np.vstack([hull_points, hull_points[0]])
            
            # Add base outline
            fig.add_trace(
                go.Scatter3d(
                    x=hull_points[:, 0] * SCALE_FACTOR,
                    y=[base_y * SCALE_FACTOR] * len(hull_points),
                    z=hull_points[:, 1] * SCALE_FACTOR,
                    mode='lines',
                    line=dict(color='blue', width=3),
                    name='Base Outline',
                    showlegend=True,
                    hoverinfo='skip'
                )
            )
        except:
            pass  # Skip if hull fails
    
    # Calculate lean angle
    z_offset = center_of_mass[2] - base_center_z
    y_offset = center_of_mass[1] - base_y
    lean_angle = np.degrees(np.arctan2(abs(z_offset), y_offset))
    
    # Calculate additional metrics
    com_height = (center_of_mass[1] - base_y) * SCALE_FACTOR
    total_height = (mesh.bounds[1][1] - mesh.bounds[0][1]) * SCALE_FACTOR
    base_width = (mesh.bounds[1][0] - mesh.bounds[0][0]) * SCALE_FACTOR
    base_depth = (mesh.bounds[1][2] - mesh.bounds[0][2]) * SCALE_FACTOR
    distance_to_front = (mesh.bounds[1][2] - center_of_mass[2]) * SCALE_FACTOR
    
    # Update layout with informative title
    fig.update_layout(
        title={
            'text': f"Moai Center of Mass Analysis<br>" +
                   f"<sub>Forward lean: {lean_angle:.1f}° | " +
                   f"COM height: {com_height:.2f}m ({com_height/total_height*100:.1f}% of {total_height:.2f}m) | " +
                   f"Base: {base_width:.2f}m × {base_depth:.2f}m | " +
                   f"Distance to front edge: {distance_to_front*100:.0f}cm</sub>",
            'x': 0.5,
            'xanchor': 'center',
            'font': {'size': 20}
        },
        scene=dict(
            xaxis_title="X (width) [m]",
            yaxis_title="Y (height) [m]",
            zaxis_title="Z (depth) [m]",
            aspectmode='data',
            camera=dict(
                eye=dict(x=1.5, y=1.0, z=1.5),
                center=dict(x=0, y=-0.1, z=0)
            )
        ),
        showlegend=True,
        legend=dict(
            x=0.02,
            y=0.98,
            xanchor='left',
            yanchor='top',
            bgcolor='rgba(255, 255, 255, 0.9)',
            bordercolor='black',
            borderwidth=1
        ),
        height=900,
        margin=dict(l=0, r=0, t=100, b=0)
    )
    
    # Add annotation box with key measurements
    annotation_text = (
        f"<b>Key Measurements:</b><br>" +
        f"Forward lean angle: {lean_angle:.1f}°<br>" +
        f"COM height: {com_height:.2f}m<br>" +
        f"Total height: {total_height:.2f}m<br>" +
        f"COM at {com_height/total_height*100:.1f}% of height<br>" +
        f"Base width: {base_width:.2f}m<br>" +
        f"Base depth: {base_depth:.2f}m<br>" +
        f"Distance to front: {distance_to_front*100:.0f}cm"
    )
    
    fig.add_annotation(
        text=annotation_text,
        xref="paper", yref="paper",
        x=0.98, y=0.5,
        xanchor='right', yanchor='middle',
        showarrow=False,
        bordercolor="black",
        borderwidth=1,
        bgcolor="rgba(255, 255, 255, 0.95)",
        font=dict(size=11, family="monospace"),
        align="left"
    )
    
    # Save as HTML
    html_file = get_output_path('Figure_4_moai_analysis_interactive.html')
    fig.write_html(html_file)
    print(f"\n✓ Saved interactive HTML: {html_file}")
    
    # Save static images (these will just show the 3D view)
    try:
        # High resolution PNG
        png_file = get_output_path("Figure_4_moai_analysis_plotly_600dpi.png")
        fig.write_image(png_file, width=1400, height=900, scale=2)
        print(f"✓ Saved high-resolution PNG: {png_file}")
        
        # SVG
        svg_file = get_output_path("Figure_4_moai_analysis_plotly.svg")
        fig.write_image(svg_file, width=1400, height=900)
        print(f"✓ Saved SVG: {svg_file}")
    except Exception as e:
        print(f"Note: Could not save static images. Install kaleido for static export: pip install kaleido")
        print(f"Error: {e}")
    
    return fig

def main():
    obj_file = "../data/SimplifiedMoai.obj"
    
    print("Plotly-based Moai Analysis (3D Interactive Only)")
    print("=" * 50)
    
    try:
        mesh, center_of_mass = load_and_analyze_moai(obj_file)
        
        print("\n" + "=" * 50)
        print("Creating interactive 3D visualization...")
        fig = create_plotly_visualization(mesh, center_of_mass)
        
        # Show the figure
        fig.show()
        
        print("\nNote: The matplotlib version (Figure_4_moai_analysis_600dpi.png)")
        print("contains both 3D and top-down views for static publication.")
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()