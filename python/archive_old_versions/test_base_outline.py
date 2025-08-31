import numpy as np
import trimesh
import plotly.graph_objects as go

# Load mesh
mesh = trimesh.load("../data/SimplifiedMoai.obj")
base_y = mesh.bounds[0][1]

# Get base vertices
base_vertices = mesh.vertices[mesh.vertices[:, 1] < base_y + 0.05]

# Get slice vertices
slice_height = base_y + 0.10
slice_tolerance = 0.01
slice_vertices = mesh.vertices[
    (mesh.vertices[:, 1] > slice_height - slice_tolerance) & 
    (mesh.vertices[:, 1] < slice_height + slice_tolerance)
]

print(f"Base vertices: {len(base_vertices)}")
print(f"Slice vertices: {len(slice_vertices)}")

# Create simple plot
fig = go.Figure()

# Add base points
fig.add_trace(
    go.Scatter(
        x=base_vertices[:, 0],
        y=base_vertices[:, 2],
        mode='markers',
        marker=dict(size=2, color='gray'),
        name='Base Points'
    )
)

# Add slice outline
if len(slice_vertices) > 10:
    from scipy.spatial import ConvexHull
    slice_points = slice_vertices[:, [0, 2]]
    hull = ConvexHull(slice_points)
    hull_points = slice_points[hull.vertices]
    hull_points = np.vstack([hull_points, hull_points[0]])
    
    fig.add_trace(
        go.Scatter(
            x=hull_points[:, 0],
            y=hull_points[:, 1],
            mode='lines',
            line=dict(color='blue', width=4),
            fill='toself',
            fillcolor='rgba(173, 216, 230, 0.4)',
            name='Base Outline'
        )
    )

# Add center of mass
center_of_mass = mesh.center_mass
fig.add_trace(
    go.Scatter(
        x=[center_of_mass[0]],
        y=[center_of_mass[2]],
        mode='markers',
        marker=dict(size=20, color='red'),
        name='Center of Mass'
    )
)

fig.update_layout(
    title="Test: Base Outline Visibility",
    xaxis_title="X",
    yaxis_title="Z",
    width=800,
    height=800
)

fig.update_yaxis(scaleanchor="x", scaleratio=1)

fig.write_html("test_base_outline.html")
print("Saved test_base_outline.html")