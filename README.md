# Analisis Perilaku dan Loyalitas Pelanggan SuryaHub

**Tools:** SQL, Google BigQuery, Looker Studio, Python (validasi)
**Hasil kerja:** query SQL, dashboard interaktif Looker Studio, laporan analis, slide deck rekomendasi
**Link dashboard:** [https://mufa290300.github.io/Dasboard_SuryaHub/](https://mmufaah.github.io/Dasboard_SuryaHub/)
**Penulis:** Muhamad Fahrudin

## Ringkasan

Proyek ini menganalisis data transaksi pelanggan SuryaHub untuk memahami pola loyalitas dan perilaku pembelian. Saya menjawab 7 pertanyaan bisnis dengan SQL di Google BigQuery, membuat dashboard di Looker Studio, lalu memvalidasi hasilnya dengan uji statistik di Python.

**Temuan utama**
- Pelanggan **non-anggota** program loyalitas belanja lebih besar (rata-rata 4,38M vs 4,10M) dan lebih sering (6,99x vs 6,68x), tetapi selisihnya **tidak signifikan secara statistik** (p = 0,14 dan 0,26).
- **4 dari 10** pelanggan dengan total belanja tertinggi memiliki skor Brand Loyalty terendah (skala 1), termasuk peringkat 1 dan 2.
- Brand Loyalty hampir tidak berhubungan dengan nilai belanja (korelasi 0,015) maupun frekuensi (-0,011).
- Segmen Planned memiliki rata-rata belanja tertinggi (4,34M) dan Impulsive terendah (4,14M), tetapi selisih antar segmen **tidak signifikan** (p = 0,84).
- Penggunaan diskon seimbang: 250 transaksi dengan diskon dan 250 tanpa diskon.

**Kesimpulan:** perilaku belanja pelanggan relatif seragam di semua segmen yang tersedia. Strategi sebaiknya diuji lewat eksperimen A/B, bukan didasarkan pada perbedaan segmen yang kecil.

## Latar Belakang dan Tujuan

SuryaHub memiliki data pembelian pelanggan dari berbagai kota, channel, dan tingkat loyalitas. Tujuan analisis:
1. Mengenali segmen dan wilayah dengan potensi terbesar.
2. Memahami hubungan antara loyalitas, diskon, dan perilaku belanja.
3. Merumuskan strategi untuk meningkatkan frekuensi dan nilai pembelian.

## Data

- **Sumber:** dataset studi kasus SuryaHub dari Harisenin Data Analyst Bootcamp (skenario evaluasi Juni 2025 dan perencanaan uji coba Juli 2025).
- **Ukuran:** 500 baris (transaksi), 15 kolom, 499 pelanggan unik.
- **Tabel:** `Surya_Hub.Data_suryahub` di Google BigQuery.
- **Total nilai belanja:** Rp 2.118.220.545, rata-rata Rp 4.236.441 per transaksi.

**Kualitas data**
- Satu Customer_ID (19-933-8095, Jakarta) muncul dua kali dengan channel dan niat membeli berbeda.
- `Social_Media_Influence` berisi High, Medium, Low, dengan 118 data kosong (23,6%). Kolom ini kategori, bukan angka.
- `Frequency_of_Purchase` kosong pada 1 baris.
- Tidak ada baris yang identik sepenuhnya.

## Analisis SQL

### 1. Berapa total transaksi pelanggan perempuan?

```sql
SELECT
  Gender,
  COUNT(*) AS Jumlah_Total_Transaksi
FROM `Surya_Hub.Data_suryahub`
WHERE Gender = 'Female'
GROUP BY Gender;
```

**Temuan:** 265 transaksi (53,0% dari 500). Rata-rata belanja perempuan 4,38M dan laki-laki 4,07M, selisih tidak signifikan (p = 0,09).

### 2. Lima kota dengan pelanggan terbanyak

```sql
SELECT
  Location,
  COUNT(DISTINCT Customer_ID) AS Total_Customers
FROM `Surya_Hub.Data_suryahub`
GROUP BY Location
ORDER BY Total_Customers DESC
LIMIT 5;
```

**Temuan:** Makassar (95), Jakarta (89), Bandung (82), Surabaya (78), Medan (78). Papua (77) tepat di bawahnya.
**Insight:** Selisih antarkota kecil (77–95), sehingga pelanggan tersebar cukup merata.

### 3. Pelanggan dengan Brand Loyalty 5: apakah memakai diskon?

```sql
SELECT
  Discount_Used,
  COUNT(*) AS Total
FROM `Surya_Hub.Data_suryahub`
WHERE Brand_Loyalty = 5
GROUP BY Discount_Used;
```

**Temuan:** Dari 106 transaksi (105 pelanggan), 60 tanpa diskon (56,6%) dan 46 dengan diskon (43,4%). Pada seluruh data, penggunaan diskon seimbang (250 vs 250).
**Insight:** Pelanggan paling loyal sedikit lebih jarang memakai diskon, tetapi secara keseluruhan diskon tidak membedakan perilaku.

### 4. Segmen niat membeli: siapa yang belanja lebih besar dan lebih sering?

```sql
SELECT
  Purchase_Intent,
  AVG(Purchase_Amount) AS avg_amount,
  AVG(Frequency_of_Purchase) AS avg_frequency
FROM `Surya_Hub.Data_suryahub`
GROUP BY Purchase_Intent
ORDER BY avg_amount DESC;
```

| Segmen | Rata-rata belanja | Rata-rata frekuensi |
|---|---|---|
| Planned | 4,34M | 6,94 |
| Need-based | 4,30M | 6,87 |
| Wants-based | 4,17M | 6,83 |
| Impulsive | 4,14M | 6,68 |

**Insight:** Planned tertinggi dan Impulsive terendah, tetapi selisihnya kecil dan tidak signifikan (p = 0,84).

### 5. Perbandingan channel pembelian

```sql
SELECT
  Purchase_Channel,
  AVG(Purchase_Amount) AS avg_amount,
  AVG(Frequency_of_Purchase) AS avg_frequency
FROM `Surya_Hub.Data_suryahub`
GROUP BY Purchase_Channel;
```

| Channel | Rata-rata belanja | Rata-rata frekuensi |
|---|---|---|
| Mixed | 4,46M | 6,56 |
| In-Store | 4,14M | 7,14 |
| Online | 4,10M | 6,81 |

**Insight:** Mixed memiliki belanja tertinggi dan In-Store frekuensi tertinggi, tetapi selisih antar channel tidak signifikan (p = 0,20 untuk belanja, 0,22 untuk frekuensi).

### 6. Anggota vs non-anggota program loyalitas

```sql
SELECT
  Customer_Loyalty_Program_Member,
  AVG(Purchase_Amount) AS avg_amount,
  AVG(Frequency_of_Purchase) AS avg_frequency
FROM `Surya_Hub.Data_suryahub`
GROUP BY Customer_Loyalty_Program_Member;
```

**Temuan:** Non-anggota belanja 4,38M vs 4,10M dan 6,99x vs 6,68x.
**Insight:** Program loyalitas saat ini belum terbukti mendorong belanja anggotanya.

### 7. Sepuluh pelanggan dengan total belanja tertinggi

```sql
SELECT
  Customer_ID,
  SUM(Purchase_Amount) AS total_spent,
  MAX(Location) AS Location,
  MAX(Purchase_Channel) AS Channel,
  MAX(Brand_Loyalty) AS Brand_Loyalty
FROM `Surya_Hub.Data_suryahub`
GROUP BY Customer_ID
ORDER BY total_spent DESC
LIMIT 10;
```

**Temuan:** 4 dari 10 top spender (termasuk peringkat 1 dan 2) memiliki Brand Loyalty 1.
**Insight:** Pelanggan bernilai tertinggi belum tentu loyal, sehingga berisiko berpindah ke kompetitor.

## Validasi Statistik (Python)

Hasil SQL saya validasi ulang dengan Python (pandas dan scipy). Skrip: `uji_statistik_suryahub.py`.

| Perbandingan | p-value | Kesimpulan |
|---|---|---|
| Anggota vs non-anggota (belanja) | 0,137 | Tidak signifikan |
| Anggota vs non-anggota (frekuensi) | 0,260 | Tidak signifikan |
| Perempuan vs laki-laki (belanja) | 0,092 | Tidak signifikan |
| Antar Purchase Intent (belanja) | 0,838 | Tidak signifikan |
| Antar channel (belanja) | 0,202 | Tidak signifikan |
| Antar channel (frekuensi) | 0,221 | Tidak signifikan |

## Dashboard dan Laporan

- **Dashboard Looker Studio:** filter gender, lokasi, dan channel, dengan visual distribusi income, 5 kota teratas, anggota vs non-anggota, penggunaan diskon, niat membeli, channel, dan 10 pelanggan teratas.
- **Laporan analis:** ringkasan eksekutif, profil demografi dan geografis, evaluasi program loyalitas, analisis channel, top spender, rekomendasi, dan roadmap uji coba.
- **Slide deck:** versi presentasi laporan untuk tim marketing dan manajemen.

## Perspektif Marketing Analytics

**Segmentasi pelanggan**
- **Gender:** perempuan 265 (53,0%), laki-laki 235 (47,0%).
- **Income:** Middle 251 dan High 249, hampir seimbang.
- **Lokasi:** 6 kota dengan sebaran merata (77–95 pelanggan).
- **Niat membeli:** Planned, Need-based, Wants-based, Impulsive (123, 130, 126, 121 transaksi).
- **Loyalitas:** anggota 256 dan non-anggota 244 transaksi.

**Pemetaan ide promo ke segmen (hipotesis untuk diuji)**
| Segmen | Ide promo |
|---|---|
| Planned | Product bundling dan notifikasi stok |
| Impulsive | Flash sale terbatas waktu (uji A/B) |
| Top spender berloyalitas rendah | Layanan VIP dan apresiasi personal |
| Kota dengan pelanggan terbanyak | Pilot kampanye di Makassar dan Jakarta |
| Anggota program loyalitas | Loyalty cashback dan tier non-diskon |

**Metrik yang diusulkan**
- Revenue per Customer = Total Revenue / Total Unique Customers
- Repeat Purchase Rate (%) = (Pelanggan belanja lebih dari 1 kali / Total pelanggan) x 100%

## Perspektif Business Analysis

**Masalah bisnis:** bagaimana meningkatkan repeat purchase dan revenue per customer pada uji coba Juli 2025.

**Pendekatan:** pertanyaan bisnis → analisis data (SQL) → validasi statistik → insight → rekomendasi → roadmap eksperimen 4 minggu → metrik keberhasilan.

**Roadmap eksperimen 4 minggu** (grup uji vs grup kontrol)
| Minggu | Fokus | Eksperimen | Target hipotesis |
|---|---|---|---|
| 1 | Restrukturisasi loyalitas | Poin berlipat dan benefit baru untuk sebagian anggota | +15% registrasi member baru |
| 2 | Pembeli impulsif | Flash sale terbatas waktu untuk sampel acak | +20% conversion rate flash sale |
| 3 | Dorongan geografis | Gratis ongkir di Makassar, pengiriman cepat di Jakarta | +12% repeat order di Makassar |
| 4 | Planned dan channel Mixed | Weekly bundles dan insentif ambil di toko | +10% AOV pada pembelian terencana |

Target di atas adalah **hipotesis untuk diuji**, bukan hasil perhitungan dari data historis.

## Insight dan Rekomendasi

| Insight | Rekomendasi |
|---|---|
| Tidak ada segmen (gender, intent, channel, keanggotaan) yang berbeda signifikan | Jangan menyusun strategi dari selisih kecil. Gunakan eksperimen A/B untuk menguji efek promo |
| Program loyalitas belum mendorong belanja (soal 6) | Desain ulang tier dengan manfaat non-diskon, lalu uji pada sebagian anggota |
| Brand Loyalty hampir tidak berhubungan dengan belanja (korelasi 0,015) | Ukur loyalitas dengan metrik perilaku seperti repeat purchase, bukan hanya skor |
| Pelanggan bernilai tertinggi belum tentu loyal (soal 7) | Beri layanan khusus dan apresiasi personal untuk top spender berloyalitas rendah |
| Pelanggan loyal sedikit lebih jarang memakai diskon (soal 3) | Uji loyalty cashback sebagai pengganti potongan harga langsung |
| Pelanggan tersebar merata antarkota (soal 2) | Mulai pilot di Makassar dan Jakarta, lalu perluas |

## Keterbatasan dan Langkah Lanjutan

- Data tidak memuat waktu transaksi, data pembelian berulang, atau biaya promosi, sehingga repeat purchase dan ROI tidak bisa dihitung.
- `Social_Media_Influence` memiliki 23,6% data kosong dan tidak dipakai untuk kesimpulan.
- Target KPI pada roadmap belum didasarkan pada data historis.
- Langkah lanjutan: dashboard di Tableau atau Power BI, uji A/B nyata jika ada data eksperimen, dan penambahan data waktu transaksi.
