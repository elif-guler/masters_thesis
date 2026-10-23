#!/bin/bash
# Kullanım: bash run_before.sh <dataset> <pool_col> <outdir>
# örnek:    bash run_before.sh clo 3 before_labels/clo/pool_100

DATASET=$1
SAMPLE_COL=$2
OUTDIR=$3
ACC_FILE="3taxa/${DATASET}/acc.txt"   # kendi acc.txt yolunla değiştir

mkdir -p "$OUTDIR"
cd "$OUTDIR" || exit 1

# 1. Havuza dahil genomların accession'larını çıkar
awk -F '\t' -v col="$SAMPLE_COL" '
NR>1 && $col=="TRUE" {print $1}
' "../../../$ACC_FILE" > accessions.txt

# 2. Genomları dehydrated indir
datasets download genome accession \
    --inputfile accessions.txt \
    --dehydrated

unzip -o ncbi_dataset.zip
datasets rehydrate --directory .

# 3. Tüm genomları tek klasöre topla
mkdir -p all
find ncbi_dataset/data -name "*_genomic.fna" | while read -r f; do
    acc=$(basename "$(dirname "$f")")
    ln -sf "$(realpath "$f")" "all/${acc}.fasta"
done

# 4. HAM (taksonomiye dayalı) etiketlerle targets/neighbors kur
#    Burada ikinci sütun (target/neighbor etiketi) SENİN acc.txt sıranıza göre değişebilir —
#    kontrol et: "Is target" sütunu genelde 2. sütun.
mkdir -p targets neighbors
awk -F '\t' -v col="$SAMPLE_COL" '
NR>1 && $col=="TRUE" {
    print $1 "\t" $2
}
' "../../../$ACC_FILE" | while IFS=$'\t' read -r acc target; do
    if [ "$target" = "TRUE" ]; then
        ln -sf "$(pwd)/all/${acc}.fasta" "targets/${acc}.fasta"
    else
        ln -sf "$(pwd)/all/${acc}.fasta" "neighbors/${acc}.fasta"
    fi
done

# 5. Fur veritabanını kur ve çalıştır
/usr/bin/time -v -o makeFurDb.res \
makeFurDb -T 1 -t targets -n neighbors -o -d target.db

/usr/bin/time -v -o fur.res \
fur -m -d target.db > markers.fasta

# 6. Marker sayısını raporla
echo "===== $DATASET (col $SAMPLE_COL) ====="
echo "targets: $(ls targets | wc -l)"
echo "neighbors: $(ls neighbors | wc -l)"
echo "markers: $(grep -c '^>' markers.fasta)"
