#!/bin/bash
set -euo pipefail

echo "🔧 Starting Cell Ranger reference build for mouse genome (mm10)..."

# Genome metadata
genome="mm10"
version="2020-A"

# Set up source and build directories
build="mm10-2020-A_build"
echo "📁 Creating build directory: $build"
mkdir -p "$build"

source="reference_sources"
echo "📁 Creating source directory: $source"
mkdir -p "$source"

# File URLs and targets
fasta_url="http://ftp.ensembl.org/pub/release-98/fasta/mus_musculus/dna/Mus_musculus.GRCm38.dna.primary_assembly.fa.gz"
fasta_in="${source}/Mus_musculus.GRCm38.dna.primary_assembly.fa"
gtf_url="http://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M23/gencode.vM23.primary_assembly.annotation.gtf.gz"
gtf_in="${source}/gencode.vM23.primary_assembly.annotation.gtf"

# Download FASTA
if [ ! -f "$fasta_in" ]; then
    echo "⬇️ Downloading mouse FASTA from $fasta_url"
    curl -sS "$fasta_url" | zcat > "$fasta_in"
else
    echo "✅ FASTA already exists: $fasta_in"
fi

# Download GTF
if [ ! -f "$gtf_in" ]; then
    echo "⬇️ Downloading mouse GTF from $gtf_url"
    curl -sS "$gtf_url" | zcat > "$gtf_in"
else
    echo "✅ GTF already exists: $gtf_in"
fi

# Modify FASTA headers
fasta_modified="$build/$(basename "$fasta_in").modified"
echo "🧬 Modifying FASTA headers..."
cat "$fasta_in" \
    | sed -E 's/^>(\S+).*/>\1 \1/' \
    | sed -E 's/^>([0-9]+|[XY]) />chr\1 /' \
    | sed -E 's/^>MT />chrM /' \
    > "$fasta_modified"
echo "✅ Modified FASTA saved to $fasta_modified"

# Modify GTF IDs
gtf_modified="$build/$(basename "$gtf_in").modified"
ID="(ENS(MUS)?[GTE][0-9]+)\.([0-9]+)"
echo "🧬 Cleaning version numbers from GTF IDs..."
cat "$gtf_in" \
    | sed -E 's/gene_id "'"$ID"'";/gene_id "\1"; gene_version "\3";/' \
    | sed -E 's/transcript_id "'"$ID"'";/transcript_id "\1"; transcript_version "\3";/' \
    | sed -E 's/exon_id "'"$ID"'";/exon_id "\1"; exon_version "\3";/' \
    > "$gtf_modified"
echo "✅ Modified GTF saved to $gtf_modified"

# Define filtering patterns
BIOTYPE_PATTERN="(protein_coding|lncRNA|IG_C_gene|IG_D_gene|IG_J_gene|IG_LV_gene|IG_V_gene|IG_V_pseudogene|IG_J_pseudogene|IG_C_pseudogene|TR_C_gene|TR_D_gene|TR_J_gene|TR_V_gene|TR_V_pseudogene|TR_J_pseudogene)"
GENE_PATTERN="gene_type \"${BIOTYPE_PATTERN}\""
TX_PATTERN="transcript_type \"${BIOTYPE_PATTERN}\""
READTHROUGH_PATTERN="tag \"readthrough_transcript\""

# Create gene allowlist
echo "📋 Building gene allowlist..."
cat "$gtf_modified" \
    | awk '$3 == "transcript"' \
    | grep -E "$GENE_PATTERN" \
    | grep -E "$TX_PATTERN" \
    | grep -Ev "$READTHROUGH_PATTERN" \
    | sed -E 's/.*(gene_id "[^"]+").*/\1/' \
    | sort \
    | uniq \
    > "${build}/gene_allowlist"
echo "✅ Gene allowlist created at ${build}/gene_allowlist"

# Filter GTF by gene allowlist
gtf_filtered="${build}/$(basename "$gtf_in").filtered"
echo "🧹 Filtering GTF to include only allowed genes..."
grep -E "^#" "$gtf_modified" > "$gtf_filtered"
grep -Ff "${build}/gene_allowlist" "$gtf_modified" >> "$gtf_filtered"
echo "✅ Filtered GTF saved to $gtf_filtered"

# Build Cell Ranger reference
echo "🛠️ Running cellranger mkref..."
cellranger mkref --ref-version="$version" \
    --genome="$genome" --fasta="$fasta_modified" --genes="$gtf_filtered"

echo "🎉 Cell Ranger reference build for mm10 completed successfully!"

