---
name: medical-seg-debug
description: Debug PyTorch/MONAI medical image segmentation environments and training runs on remote Linux servers, especially CUDA, conda, NIfTI readers, pretrained checkpoints, DataLoader/cache issues, and training logs. Use for segmentation-related import errors, CUDA visibility, MONAI warnings, checkpoint path errors, DataLoader stalls, or failed training commands. Not for clinical interpretation or unrelated application debugging.
---

# Medical Seg Debug

Use this skill for medical segmentation debugging across local Windows, WSL, a laboratory workstation, SSH hosts, containers, and mounted or persistent storage.

## Work Style

Explain the purpose of diagnostic steps briefly. Use available authorized tools directly; ask the user to run commands only when their terminal is inaccessible. Treat screenshots as partial evidence and request the last relevant log lines only when needed. Keep commands read-only until the failure domain and host boundary are clear. Separate observed facts, candidate causes and proposed fixes; test a candidate cause before changing the environment.

Identify where each command is running: local Windows, WSL, laboratory workstation, SSH host, or container. Distinguish host-local storage, container overlay, network mounts, and confirmed persistent project storage.

## Standard Checks

Choose checks relevant to the failure; the commands below target Bash on Linux/WSL. Adapt them for native Windows. The optional `scripts/env_check.sh` collects best-effort environment diagnostics without installing packages; its successful exit does not mean all checks passed. Inspect its output. Avoid sharing hostnames, usernames, private paths or patient identifiers in public reports.

Environment:

```bash
conda env list
which python
which pip
python -c "import sys; print(sys.executable)"
python -m pip list | grep -E "torch|monai|nibabel|SimpleITK|numpy|matplotlib"
```

GPU:

```bash
nvidia-smi
python -c "import torch; print(torch.__version__); print(torch.cuda.is_available()); print(torch.version.cuda); print(torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'no CUDA visible to this interpreter')"
```

System and storage:

```bash
hostname
whoami
pwd
uname -a
ldd --version | head -1
df -hT
mount
```

Inspect important directories and mount information read-only first. Use a disposable probe for an authorized write check. A restart test needs separate authorization when it could interrupt work; do not restart a server or container solely to inspect persistence. An empty but mounted path is not evidence that old data recovered.

NIfTI readers:

```bash
python -c "import nibabel as nib; print('nibabel ok')"
python -c "import SimpleITK as sitk; print('SimpleITK ok')"
```

## Protect working environments

Treat remembered GPU, driver, package, and environment versions as historical until measured live. Before installing or upgrading anything:

1. capture Python, pip/conda, package, CUDA, driver, GLIBC, and code versions;
2. prefer a new isolated environment over mutating a working one;
3. check the upstream project's supported versions;
4. install the smallest required change;
5. verify the affected layer first; use CUDA tensor, forward/backward or checkpoint-resume checks only when relevant and within available compute and task scope;
6. save an environment manifest and checksum.

## Common Errors

- `ModuleNotFoundError`: first identify the interpreter running the failing process and inspect its dependency specification. Install the missing package into that interpreter only if it is genuinely required and absent; do not use an unrelated `pip` or upgrade the whole environment by default.
- `FileNotFoundError ... VoCo_B_SSL_head.pt`: inspect the resolved checkpoint path, selected model branch and actual argparse definition. A non-empty string `"False"` is one possible cause in the historical VoCo template, not a diagnosis for every missing file. An empty-string workaround applies only to the verified legacy string parser; a real boolean parser needs its documented syntax.
- MONAI `CropForegroundd allow_smaller` warning: distinguish a warning from the actual stopping exception. Check the installed version, transform configuration and expected crop shape. Do not suppress it blindly or assume a change of default is harmless; set the intended value explicitly when justified by the protocol.
- Download timeout: determine whether the cause is connectivity, proxy, DNS, authentication, certificate validation or the download client. Prefer the official source and supported client. A third-party mirror is an optional alternative only when the user accepts that source; do not silently change endpoints, send credentials to a new host, or disable TLS verification. Verify the resulting artifact against an authoritative checksum when available.
- `Stale file handle`: stop writing to the affected mount, verify the mount from a fresh shell, and confirm with the administrator. Reconnecting an SSH session alone does not repair missing storage.

## Triage Training Output

Illustrative VoCo-style log milestones (other trainers use different messages). A printed message alone does not prove successful weight loading, valid metrics or a usable saved checkpoint:

```text
Using VoCo pretrained backbone weights !!!!!!!
Total parameters count ...
Writing Tensorboard logs ...
Epoch: 0
loss: ...
Val ...
Saving checkpoint ...
Training Finished
```

If validation is poor after very short training, do not overinterpret. A 2-epoch run is a smoke test only.

## Audit residues safely

When a transfer, download, extraction, or run fails, perform a read-only inventory first. Classify artifacts as active, complete, partial, duplicated, historical, or unknown. Compare size, timestamps, manifests, and hashes where available. Do not recursively delete, overwrite, or move ambiguous artifacts without explicit user authorization and a verified absolute target path.
