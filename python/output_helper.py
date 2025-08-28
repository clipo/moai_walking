"""
Helper module to determine output directory for figures
Handles both local and Docker environments
"""

import os

def get_output_dir():
    """
    Determine the appropriate output directory for saving figures.
    
    Returns:
        str: Path to output directory
    """
    # Check if we're in Docker (figures mounted at /figures)
    if os.path.exists('/figures'):
        return '/figures'
    # Check if local figures directory exists
    elif os.path.exists('../figures'):
        return '../figures'
    # Default to current directory
    else:
        return '.'

def get_output_path(filename):
    """
    Get the full output path for a file.
    
    Args:
        filename (str): Name of the file to save
        
    Returns:
        str: Full path to save the file
    """
    output_dir = get_output_dir()
    return os.path.join(output_dir, filename)