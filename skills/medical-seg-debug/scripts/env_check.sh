#!/usr/bin/env bash
set -euo pipefail

echo "== conda =="
conda env list || true
echo "== python =="
which python || true
python -c "import sys; print(sys.executable)" || true
echo "== gpu =="
nvidia-smi || true
echo "== torch =="
python -c "import torch; print(torch.__version__); print(torch.cuda.is_available()); print(torch.version.cuda); print(torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'no cuda')" || true
echo "== packages =="
python -m pip list | grep -E "torch|monai|nibabel|SimpleITK|numpy|matplotlib" || true

