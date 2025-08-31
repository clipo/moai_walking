import numpy as np
import trimesh
import plotly.graph_objects as go
from plotly.subplots import make_subplots

def load_and_analyze_moai(obj_file):
    """Load the moai mesh and analyze its center of mass"""
    
    # Load the mesh
    mesh = trimesh.load(obj_file)
    print(f"Loaded mesh with {len(mesh.vertices)} vertices and {len(mesh.faces)} faces")
    
    # Scaling factor for actual moai dimensions (7.35m tall)
    SCALE_FACTOR = 4.894  # 7.35m / 1.502m
    
    # Get mesh properties
    bounds = mesh.bounds
    print(f"\nMesh bounds (scaled to actual moai):")
    print(f"  X: {bounds[0][0]*SCALE_FACTOR:.3f}m to {bounds[1][0]*SCALE_FACTOR:.3f}m")
    print(f"  Y: {bounds[0][1]*SCALE_FACTOR:.3f}m to {bounds[1][1]*SCALE_FACTOR:.3f}m (vertical axis)")
    print(f"  Z: {bounds[0][2]*SCALE_FACTOR:.3f}m to {bounds[1][2]*SCALE_FACTOR:.3f}m")
    
    # Calculate center of mass
    center_of_mass = mesh.center_mass
    
    print(f"\nCenter of mass (scaled): ({center_of_mass[0]*SCALE_FACTOR:.3f}m, {center_of_mass[1]*SCALE_FACTOR:.3f}m, {center_of_mass[2]*SCALE_FACTOR:.3f}m)")
    
    # Calculate height from base
    base_y = bounds[0][1]
    height_from_base = center_of_mass[1] - base_y
    total_height = bounds[1][1] - bounds[0][1]
    height_percentage = (height_from_base / total_height) * 100
    
    print(f"\nHeight analysis (scaled):")
    print(f"  Base Y coordinate: {base_y*SCALE_FACTOR:.3f}m")
    print(f"  Center of mass height from base: {height_from_base*SCALE_FACTOR:.3f}m")
    print(f"  Total height: {total_height*SCALE_FACTOR:.3f}m")
    print(f"  Center of mass at {height_percentage:.1f}% of total height")
    
    return mesh, center_of_mass, SCALE_FACTOR

def create_simple_plotly_visualization(mesh, center_of_mass, scale_factor):
    """Create simple interactive 3D visualization using Plotly with scaled measurements"""
    
    # Create subplots
    fig = make_subplots(
        rows=1, cols=2,
        column_widths=[0.55, 0.45],
        specs=[[{'type': 'mesh3d'}, {'type': 'scatter'}]],
        subplot_titles=('3D Moai with Center of Mass', 'Top View: Base vs Center of Mass'),
        horizontal_spacing=0.12
    )
    
    # Prepare mesh data
    vertices = mesh.vertices
    faces = mesh.faces
    
    # Get vertex coordinates - scaled
    x, y, z = vertices[:, 0] * scale_factor, vertices[:, 1] * scale_factor, vertices[:, 2] * scale_factor
    
    # Get face indices
    i, j, k = faces[:, 0], faces[:, 1], faces[:, 2]
    
    # Calculate vertex colors based on height (normalized)
    vertex_colors = (vertices[:, 1] - vertices[:, 1].min()) / (vertices[:, 1].max() - vertices[:, 1].min())
    
    # Add mesh to 3D subplot with transparency
    fig.add_trace(
        go.Mesh3d(
            x=x, y=y, z=z,
            i=i, j=j, k=k,
            intensity=vertex_colors,
            colorscale='Viridis',
            showscale=True,
            colorbar=dict(
                title=f"Height (m)<br><sub>7.35m moai</sub>",
                x=0.55,
                thickness=15,
                tickmode='array',
                tickvals=np.linspace(vertex_colors.min(), vertex_colors.max(), 5),
                ticktext=[f"{(y.min() + (y.max()-y.min())*v)*scale_factor:.1f}" for v in np.linspace(0, 1, 5)]
            ),
            opacity=0.5,
            flatshading=True,
            lighting=dict(
                ambient=0.6,
                diffuse=0.8,
                roughness=0.5,
                specular=0.2,
                fresnel=0.2
            ),
            lightposition=dict(
                x=100,
                y=200,
                z=100
            ),
            name='Moai Mesh',
            hoverinfo='none'
        ),
        row=1, col=1
    )
    
    # Add center of mass point - scaled
    fig.add_trace(
        go.Scatter3d(
            x=[center_of_mass[0] * scale_factor],
            y=[center_of_mass[1] * scale_factor],
            z=[center_of_mass[2] * scale_factor],
            mode='markers',
            marker=dict(
                size=20,
                color='red',
                line=dict(color='darkred', width=3),
                symbol='diamond'
            ),
            name='Center of Mass',
            showlegend=True,
            text=[f'COM: ({center_of_mass[0]*scale_factor:.2f}m, {center_of_mass[1]*scale_factor:.2f}m, {center_of_mass[2]*scale_factor:.2f}m)'],
            hoverinfo='text'
        ),
        row=1, col=1
    )
    
    # Add vertical reference line - scaled
    base_y = mesh.bounds[0][1]
    base_center_x = (mesh.bounds[0][0] + mesh.bounds[1][0]) / 2
    base_center_z = (mesh.bounds[0][2] + mesh.bounds[1][2]) / 2
    
    fig.add_trace(
        go.Scatter3d(
            x=[base_center_x * scale_factor, base_center_x * scale_factor],
            y=[base_y * scale_factor, mesh.bounds[1][1] * scale_factor],
            z=[base_center_z * scale_factor, base_center_z * scale_factor],
            mode='lines',
            line=dict(color='black', width=4, dash='dot'),
            name='Vertical Reference',
            showlegend=True,
            hoverinfo='none'
        ),
        row=1, col=1
    )
    
    # Calculate lean angle
    z_offset = center_of_mass[2] - base_center_z
    y_offset = center_of_mass[1] - base_y
    lean_angle = np.degrees(np.arctan2(abs(z_offset), y_offset))
    
    # Add lean angle and height text
    height_m = (mesh.bounds[1][1] - mesh.bounds[0][1]) * scale_factor
    width_m = (mesh.bounds[1][0] - mesh.bounds[0][0]) * scale_factor
    com_height_m = (center_of_mass[1] - mesh.bounds[0][1]) * scale_factor
    fig.add_annotation(
        x=0.25,
        y=0.98,
        xref="paper",
        yref="paper",
        text=f"<b>Forward lean: {lean_angle:.1f}°</b><br>Height: {height_m:.2f}m<br>Width: {width_m:.2f}m<br>COM height: {com_height_m:.2f}m",
        showarrow=False,
        bgcolor="wheat",
        bordercolor="black",
        borderwidth=1,
        font=dict(size=14, color="black"),
        xanchor="center",
        yanchor="top"
    )
    
    # TOP VIEW (2D)
    # Get base vertices
    base_threshold = base_y + 0.05
    base_vertices = mesh.vertices[mesh.vertices[:, 1] < base_threshold]
    
    # Get slice for outline
    slice_height = base_y + 0.10
    slice_tolerance = 0.01
    slice_vertices = mesh.vertices[
        (mesh.vertices[:, 1] > slice_height - slice_tolerance) & 
        (mesh.vertices[:, 1] < slice_height + slice_tolerance)
    ]
    
    # Add gray base points - scaled
    fig.add_trace(
        go.Scatter(
            x=base_vertices[:, 0] * scale_factor,
            y=base_vertices[:, 2] * scale_factor,
            mode='markers',
            marker=dict(size=1, color='lightgray', opacity=0.3),
            showlegend=False
        ),
        row=1, col=2
    )
    
    # Create base outline - use simple convex hull
    if len(slice_vertices) > 10:
        from scipy.spatial import ConvexHull
        points_2d = slice_vertices[:, [0, 2]]
        hull = ConvexHull(points_2d)
        hull_points = points_2d[hull.vertices]
        # Close the polygon
        hull_points = np.vstack([hull_points, hull_points[0]])
        
        # Add base outline - scaled
        fig.add_trace(
            go.Scatter(
                x=hull_points[:, 0] * scale_factor,
                y=hull_points[:, 1] * scale_factor,
                mode='lines',
                line=dict(color='blue', width=4),
                fill='toself',
                fillcolor='rgba(173, 216, 230, 0.4)',
                name='Base Outline'
            ),
            row=1, col=2
        )
    
    # Add base center - scaled
    fig.add_trace(
        go.Scatter(
            x=[base_center_x * scale_factor],
            y=[base_center_z * scale_factor],
            mode='markers',
            marker=dict(size=15, color='blue', symbol='cross'),
            name='Base Center'
        ),
        row=1, col=2
    )
    
    # Add center of mass - scaled
    fig.add_trace(
        go.Scatter(
            x=[center_of_mass[0] * scale_factor],
            y=[center_of_mass[2] * scale_factor],
            mode='markers',
            marker=dict(size=20, color='red', line=dict(color='darkred', width=2)),
            name='Center of Mass'
        ),
        row=1, col=2
    )
    
    # Calculate scaled measurements for annotations
    base_width = (mesh.bounds[1][0] - mesh.bounds[0][0]) * scale_factor
    base_depth = (mesh.bounds[1][2] - mesh.bounds[0][2]) * scale_factor
    com_offset_x = abs(center_of_mass[0] - base_center_x) * scale_factor
    com_offset_z = abs(center_of_mass[2] - base_center_z) * scale_factor
    distance_to_front = (mesh.bounds[1][2] - center_of_mass[2]) * scale_factor
    
    # Update layout
    fig.update_layout(
        title_text="Moai Center of Mass Analysis (7.35m tall)",
        title_font_size=20,
        height=800,
        width=1400,
        showlegend=True,
        legend=dict(
            x=0.99,
            y=0.5,
            xanchor='right',
            yanchor='middle',
            bgcolor='rgba(255, 255, 255, 0.9)',
            bordercolor='black',
            borderwidth=1
        ),
        margin=dict(l=50, r=150, t=100, b=50)
    )
    
    # Update 3D scene
    fig.update_scenes(
        xaxis_title="X (width) [m]",
        yaxis_title="Y (height) [m]",
        zaxis_title="Z (depth) [m]",
        aspectmode='data',
        camera=dict(
            eye=dict(x=1.5, y=1.5, z=1.5)
        )
    )
    
    # Update 2D subplot
    fig.update_xaxes(title_text="X (width) [m]", row=1, col=2)
    fig.update_yaxes(title_text="Z (depth) [m]", row=1, col=2, scaleanchor="x", scaleratio=1)
    
    # Add measurement annotations to 2D plot
    fig.add_annotation(
        x=0.98,
        y=0.02,
        xref="x2 domain",
        yref="y2 domain",
        text=f"Base: {base_width:.2f}m × {base_depth:.2f}m<br>Distance to front edge: {distance_to_front*100:.0f}cm",
        showarrow=False,
        bgcolor="white",
        bordercolor="black",
        borderwidth=1,
        font=dict(size=11),
        xanchor="right",
        yanchor="bottom",
        align="left"
    )
    
    # Save as HTML
    html_file = 'moai_analysis_interactive.html'
    fig.write_html(html_file)
    print(f"\n✓ Saved interactive HTML: {html_file}")

def main():
    obj_file = "../data/SimplifiedMoai.obj"
    
    print("Simple Plotly Moai Analysis")
    print("=" * 50)
    
    try:
        mesh, center_of_mass, scale_factor = load_and_analyze_moai(obj_file)
        
        print("\n" + "=" * 50)
        print("Creating visualization with scaled measurements for 7.35m tall moai...")
        create_simple_plotly_visualization(mesh, center_of_mass, scale_factor)
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()