#!/usr/bin/env python
"""
Test script to verify Python 3D analysis integration
"""

import os
import sys

def test_imports():
    """Test that all required packages can be imported"""
    try:
        import trimesh
        print("✓ trimesh imported successfully")
    except ImportError as e:
        print(f"✗ Failed to import trimesh: {e}")
        return False
    
    try:
        import numpy
        print("✓ numpy imported successfully")
    except ImportError as e:
        print(f"✗ Failed to import numpy: {e}")
        return False
    
    try:
        import scipy
        print("✓ scipy imported successfully")
    except ImportError as e:
        print(f"✗ Failed to import scipy: {e}")
        return False
    
    try:
        import matplotlib
        print("✓ matplotlib imported successfully")
    except ImportError as e:
        print(f"✗ Failed to import matplotlib: {e}")
        return False
    
    return True

def test_data_access():
    """Test that data files can be accessed"""
    obj_path = "../data/SimplifiedMoai.obj"
    
    if os.path.exists(obj_path):
        print(f"✓ 3D model found at {obj_path}")
        
        # Try to load the mesh
        try:
            import trimesh
            mesh = trimesh.load(obj_path)
            print(f"✓ Mesh loaded: {len(mesh.vertices)} vertices, {len(mesh.faces)} faces")
            
            # Calculate center of mass
            com = mesh.center_mass
            print(f"✓ Center of mass calculated: {com}")
            
            return True
        except Exception as e:
            print(f"✗ Failed to load mesh: {e}")
            return False
    else:
        print(f"✗ 3D model not found at {obj_path}")
        return False

def main():
    print("=" * 50)
    print("Testing Python 3D Analysis Integration")
    print("=" * 50)
    print()
    
    print("1. Testing package imports...")
    imports_ok = test_imports()
    print()
    
    print("2. Testing data access...")
    data_ok = test_data_access()
    print()
    
    print("=" * 50)
    if imports_ok and data_ok:
        print("✓ ALL TESTS PASSED")
        print("Python 3D analysis is ready to use!")
    else:
        print("✗ SOME TESTS FAILED")
        print("Please install missing dependencies with:")
        print("  pip install -r requirements.txt")
    print("=" * 50)

if __name__ == "__main__":
    main()