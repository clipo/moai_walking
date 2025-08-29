#!/usr/bin/env python
"""
Setup script for The Walking Moai Hypothesis - Python Analysis
This script sets up a reproducible Python environment similar to packrat for R
"""

import os
import sys
import subprocess
import platform
from pathlib import Path

def print_header():
    print("=" * 50)
    print("MOAI WALKING HYPOTHESIS - PYTHON SETUP")
    print("=" * 50)
    print()

def check_python_version():
    """Check if Python version is compatible"""
    version = sys.version_info
    print(f"Python version: {version.major}.{version.minor}.{version.micro}")
    
    if version.major < 3 or (version.major == 3 and version.minor < 7):
        print("ERROR: Python 3.7 or higher is required")
        sys.exit(1)
    
    if version.major == 3 and version.minor >= 12:
        print("Note: Python 3.12+ detected. Using compatible numpy version.")
    
    print("✓ Python version is compatible\n")

def create_virtual_environment():
    """Create a virtual environment for the project"""
    venv_path = Path("venv")
    
    if venv_path.exists():
        print(f"Virtual environment already exists at {venv_path}")
        response = input("Do you want to recreate it? (y/n): ").lower()
        if response != 'y':
            return venv_path
    
    print(f"Creating virtual environment at {venv_path}...")
    subprocess.run([sys.executable, "-m", "venv", str(venv_path)], check=True)
    print("✓ Virtual environment created\n")
    
    return venv_path

def get_pip_command(venv_path):
    """Get the pip command for the virtual environment"""
    if platform.system() == "Windows":
        pip_cmd = venv_path / "Scripts" / "pip"
    else:
        pip_cmd = venv_path / "bin" / "pip"
    return str(pip_cmd)

def get_python_command(venv_path):
    """Get the python command for the virtual environment"""
    if platform.system() == "Windows":
        python_cmd = venv_path / "Scripts" / "python"
    else:
        python_cmd = venv_path / "bin" / "python"
    return str(python_cmd)

def install_packages(venv_path, use_lock=True):
    """Install required packages"""
    pip_cmd = get_pip_command(venv_path)
    
    # Upgrade pip first
    print("Upgrading pip...")
    subprocess.run([pip_cmd, "install", "--upgrade", "pip"], check=True)
    print("✓ Pip upgraded\n")
    
    # Choose requirements file
    if use_lock and Path("requirements-lock.txt").exists():
        req_file = "requirements-lock.txt"
        print(f"Installing packages from {req_file} (locked versions)...")
    else:
        req_file = "requirements.txt"
        print(f"Installing packages from {req_file} (minimum versions)...")
    
    # Install packages
    subprocess.run([pip_cmd, "install", "-r", req_file], check=True)
    print(f"✓ All packages installed from {req_file}\n")

def create_activation_script():
    """Create helper activation script"""
    if platform.system() == "Windows":
        script_name = "activate_moai.bat"
        content = "@echo off\ncall venv\\Scripts\\activate\necho Moai environment activated!"
    else:
        script_name = "activate_moai.sh"
        content = "#!/bin/bash\nsource venv/bin/activate\necho 'Moai environment activated!'"
    
    with open(script_name, 'w') as f:
        f.write(content)
    
    if platform.system() != "Windows":
        os.chmod(script_name, 0o755)
    
    print(f"✓ Created activation helper: {script_name}\n")
    return script_name

def freeze_current_versions(venv_path):
    """Freeze current package versions to requirements-lock.txt"""
    pip_cmd = get_pip_command(venv_path)
    
    print("Freezing current package versions...")
    result = subprocess.run([pip_cmd, "freeze"], capture_output=True, text=True)
    
    # Filter out unnecessary packages
    lines = result.stdout.strip().split('\n')
    filtered_lines = []
    
    # Packages to include in lock file
    important_packages = {
        'trimesh', 'rtree', 'shapely', 'networkx', 'Pillow',
        'numpy', 'scipy', 'matplotlib', 'plotly', 'kaleido',
        'setuptools', 'cycler', 'fonttools', 'kiwisolver',
        'packaging', 'pyparsing', 'python-dateutil', 'six',
        'tenacity', 'contourpy', 'importlib-resources', 'zipp'
    }
    
    for line in lines:
        if '==' in line:
            package_name = line.split('==')[0].lower()
            if any(pkg in package_name for pkg in important_packages):
                filtered_lines.append(line)
    
    # Write new lock file
    with open("requirements-lock-new.txt", 'w') as f:
        f.write("# Locked package versions for reproducibility\n")
        f.write(f"# Generated: {subprocess.run(['date'], capture_output=True, text=True).stdout.strip()}\n")
        f.write(f"# Python version: {sys.version.split()[0]}\n")
        f.write("#\n")
        f.write("# To use: pip install -r requirements-lock-new.txt\n\n")
        f.write('\n'.join(sorted(filtered_lines)))
    
    print("✓ Created requirements-lock-new.txt with current versions\n")

def verify_installation(venv_path):
    """Verify that all required packages can be imported"""
    python_cmd = get_python_command(venv_path)
    
    print("Verifying package installation...")
    test_imports = [
        "import trimesh",
        "import numpy",
        "import scipy",
        "import matplotlib",
        "import plotly"
    ]
    
    for test in test_imports:
        result = subprocess.run(
            [python_cmd, "-c", test],
            capture_output=True,
            text=True
        )
        if result.returncode != 0:
            print(f"✗ Failed to import: {test.split()[1]}")
            print(f"  Error: {result.stderr}")
        else:
            print(f"✓ Successfully imported: {test.split()[1]}")
    
    print()

def print_instructions(activation_script):
    """Print usage instructions"""
    print("=" * 50)
    print("SETUP COMPLETE!")
    print("=" * 50)
    print()
    print("To activate the environment:")
    
    if platform.system() == "Windows":
        print(f"  .\\{activation_script}")
        print("  OR")
        print("  venv\\Scripts\\activate")
    else:
        print(f"  source {activation_script}")
        print("  OR")
        print("  source venv/bin/activate")
    
    print()
    print("To run the analysis:")
    print("  python moai_analyzer_final.py      # Generate Figure 4")
    print("  python moai_analyzer_plotly.py     # Interactive 3D visualization")
    print()
    print("To update package versions:")
    print("  1. Activate the environment")
    print("  2. pip install --upgrade [package_name]")
    print("  3. python setup_python.py --freeze")
    print()
    print("For reproducibility on another machine:")
    print("  1. Copy the entire python/ directory")
    print("  2. Run: python setup_python.py")
    print("  3. The exact same package versions will be installed")
    print()

def main():
    print_header()
    
    # Parse arguments
    freeze_only = "--freeze" in sys.argv
    use_lock = "--use-lock" in sys.argv or not "--use-latest" in sys.argv
    
    if freeze_only:
        venv_path = Path("venv")
        if not venv_path.exists():
            print("ERROR: Virtual environment does not exist. Run setup first.")
            sys.exit(1)
        freeze_current_versions(venv_path)
        return
    
    # Setup process
    check_python_version()
    venv_path = create_virtual_environment()
    install_packages(venv_path, use_lock)
    activation_script = create_activation_script()
    verify_installation(venv_path)
    print_instructions(activation_script)

if __name__ == "__main__":
    main()