# Cell Ranger Reference Package build guide

This guide explains how to manually
install [10x Genomics Cell Ranger 9.0.1](https://www.10xgenomics.com/support/software/cell-ranger/downloads#download-links)
on a Linux-based virtual machine or server.

---

## General Information

This guide consists of step-by-step instructions to install Cell Ranger 9.0.1 on a Linux VM, and 2 scripts to build the
reference data
for [GRCh38](https://www.10xgenomics.com/support/software/cell-ranger/downloads/cr-ref-build-steps#ref-2020-a)
and [mm10](https://www.10xgenomics.com/support/software/cell-ranger/downloads/cr-ref-build-steps#mouse-ref-2020-a)
reference packages. The scripts you can find in `build_grch38_reference.sh` and `build_mm10_reference.sh`. (These are
exactly the same scripts copied from 10X official website with additional logging).

## Prerequisites

- A 64-bit Linux VM (e.g., Ubuntu 20.04 or later)
- `sudo` access
- Internet connection
- Approximately 6 GB of free disk space

---

## Step 1: Download Cell Ranger

Access the link [for Cell Ranger](https://www.10xgenomics.com/support/software/cell-ranger/downloads#download-links)

Navigate to the download section and copy wget command for Cell Ranger 9.0.1 (it should look like this):

```bash
wget -O cellranger-9.0.1.tar.gz "https://cf.10xgenomics.com/releases/cell-exp/cellranger-9.0.1.tar.gz?Expires=1748429361&Key-Pair-Id=SomeTokenBLuhBluh"
```

---

## Step 2: Install Cell Ranger to `/opt`

```bash
# Move the archive to /opt
sudo mv cellranger-9.0.1.tar.gz /opt/

# Extract the archive in /opt
sudo tar -xzf /opt/cellranger-9.0.1.tar.gz -C /opt

# (Optional) Remove the archive to free up space
sudo rm /opt/cellranger-9.0.1.tar.gz
```

---

## Step 3: Create a Symlink to `cellranger`

This allows you to run `cellranger` from anywhere:

```bash
sudo ln -s /opt/cellranger-9.0.1/cellranger /usr/local/bin/cellranger
```

---

## Step 4: Verify the Installation

```bash
which cellranger
cellranger --version
```

Expected output:

```
/usr/local/bin/cellranger
cellranger 9.0.1
```

## Step 5: Building the Reference Data

After installing Cell Ranger, you can build the reference data for GRCh38 or mm10 by exectuing the scripts:

```bash
./build_grch38_reference.sh
```

**Output:** will be placed in `{reference_name}_build` directory such as `GRCh38-2020-A_build`. To see the gene list
access `gene_allowlist` file.

---

## Notes

- Cell Ranger is only supported on Linux (x86_64 architecture).
- This setup is ideal for personal servers, academic compute nodes, or cloud-based VMs.
- See the official reference download page:  
  https://www.10xgenomics.com/support/software/cell-ranger/downloads
