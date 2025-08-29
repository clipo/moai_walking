# Python Reproducibility Guide

## Overview

Similar to R's packrat, we provide multiple options for creating reproducible Python environments. Each approach ensures that the exact same package versions can be installed on any machine, guaranteeing consistent results.

## Comparison of Methods

| Method | Similar To | Lock File | Pros | Cons |
|--------|-----------|-----------|------|------|
| **setup_python.py** | packrat::init() | requirements-lock.txt | Automated, simple | Python-only |
| **pip + venv** | install.packages() | requirements-lock.txt | Standard, built-in | Manual setup |
| **Conda** | packrat + R version | environment.yml | Includes Python version | Large, slower |
| **Pipenv** | packrat | Pipfile.lock | Automatic locking | Extra tool needed |
| **Poetry** | packrat + devtools | poetry.lock | Modern, powerful | Learning curve |

## Method 1: setup_python.py (Recommended)

This custom script provides the most packrat-like experience:

```bash
# Initial setup (like packrat::init())
python setup_python.py

# Activate environment
source activate_moai.sh  # Linux/Mac
activate_moai.bat        # Windows

# Update snapshot (like packrat::snapshot())
python setup_python.py --freeze

# Use latest versions instead of locked
python setup_python.py --use-latest
```

### Features:
- Creates isolated virtual environment
- Installs exact package versions from lock file
- Provides activation helpers
- Verifies installation automatically
- Can freeze current state to new lock file

## Method 2: Manual venv with requirements-lock.txt

Traditional Python approach with manual steps:

```bash
# Create virtual environment
python -m venv venv

# Activate
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# Install locked versions
pip install -r requirements-lock.txt

# Freeze current state
pip freeze > requirements-lock-new.txt
```

## Method 3: Conda (environment.yml)

Best for scientific computing with non-Python dependencies:

```bash
# Create environment
conda env create -f environment.yml

# Activate
conda activate hotuiti

# Export current environment
conda env export > environment-snapshot.yml

# Update packages
conda update --all
conda env update -f environment.yml
```

### Advantages:
- Includes Python version (3.10.13)
- Can include system libraries
- Works well with Jupyter notebooks

## Method 4: Pipenv

Modern dependency management with automatic locking:

```bash
# Install pipenv
pip install pipenv

# Install from Pipfile
pipenv install

# Activate shell
pipenv shell

# Or run directly
pipenv run python moai_analyzer_final.py

# Update lock file (like packrat::snapshot())
pipenv lock

# Install including dev dependencies
pipenv install --dev
```

### Features:
- Automatic virtual environment management
- Pipfile.lock for exact reproducibility
- Separates dev and production dependencies
- Hash verification for security

## Method 5: Poetry

Most advanced option with dependency resolution:

```bash
# Install poetry
pip install poetry

# Install dependencies
poetry install

# Run scripts
poetry run python moai_analyzer_final.py

# Add new dependency
poetry add pandas

# Update lock file
poetry lock

# Export to requirements.txt
poetry export -f requirements.txt > requirements.txt
```

### Advantages:
- Sophisticated dependency resolver
- Built-in packaging support
- Semantic versioning
- Can publish to PyPI

## Choosing the Right Method

### For R Users Familiar with packrat:
- **setup_python.py** - Most similar workflow
- **Pipenv** - Similar lock file concept

### For Quick Setup:
- **setup_python.py** - One command setup
- **requirements-lock.txt** - Simple and standard

### For Cross-platform with System Dependencies:
- **Conda** - Best for complex scientific stacks
- **Docker** - Ultimate reproducibility

### For Modern Python Projects:
- **Poetry** - Best practices and tooling
- **Pipenv** - Good balance of features

## Ensuring Reproducibility

Regardless of method, always:

1. **Commit lock files to version control:**
   - requirements-lock.txt
   - Pipfile.lock
   - poetry.lock
   - environment.yml

2. **Document Python version:**
   - Specify in README
   - Include in pyproject.toml or Pipfile

3. **Test on clean system:**
   - Use Docker or fresh virtual machine
   - Verify all scripts run correctly

4. **Provide clear instructions:**
   - Step-by-step setup guide
   - Troubleshooting section
   - Expected outputs

## Converting Between Formats

```bash
# Pipenv to requirements.txt
pipenv requirements > requirements.txt

# Poetry to requirements.txt
poetry export -f requirements.txt > requirements.txt

# Conda to pip
conda list --export > conda-packages.txt

# requirements.txt to Pipfile
pipenv install -r requirements.txt
```

## Verification

After setting up any environment, verify with:

```bash
# Check Python version
python --version

# List installed packages
pip list

# Test imports
python -c "import trimesh, numpy, scipy, matplotlib, plotly; print('All packages imported successfully')"

# Run test script
python test_integration.py
```

## Troubleshooting

### Common Issues:

1. **numpy version conflicts with Python 3.12:**
   - Use numpy>=1.26.0 for Python 3.12+
   - Or use Python 3.10 for exact reproducibility

2. **Missing system libraries:**
   - Linux: `sudo apt-get install libspatialindex-dev libgeos-dev`
   - Mac: `brew install spatialindex geos`
   - Or use conda/Docker

3. **Package conflicts:**
   - Delete venv/conda env and recreate
   - Use `--force-reinstall` flag
   - Check for incompatible versions

## Docker as Ultimate Reproducibility

For guaranteed reproducibility across all systems:

```bash
# Build image
docker build -t moai-3d-analysis .

# Run with docker-compose
docker-compose up

# Or run interactively
docker run -it --rm \
  -v $(pwd)/../data:/data:ro \
  -v $(pwd)/../figures:/figures \
  moai-3d-analysis bash
```

Docker provides:
- Exact OS version
- All system dependencies
- Isolated environment
- Consistent behavior

## Summary

The Python ecosystem offers multiple approaches to reproducibility, each with trade-offs. The `setup_python.py` script provides the most packrat-like experience, while Poetry and Pipenv offer modern dependency management. Choose based on your team's needs and familiarity with the tools.