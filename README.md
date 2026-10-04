<div align="center">

# 🛒 Analisis Perilaku dan Loyalitas Pelanggan SuryaHub

**Dari 500 transaksi menjadi rekomendasi strategi yang diuji secara statistik**

![SQL](https://img.shields.io/badge/SQL-BigQuery-4285F4?style=flat-square&logo=googlebigquery&logoColor=white)
![Python](https://img.shields.io/badge/Python-pandas%20%7C%20scipy-3776AB?style=flat-square&logo=python&logoColor=white)
![Dashboard](https://img.shields.io/badge/Dashboard-HTML%20interaktif-E9B44C?style=flat-square)
![Studi Kasus](https://img.shields.io/badge/Studi%20Kasus-Harisenin%20Bootcamp-1F3A5F?style=flat-square)

[📊 Lihat Dashboard](https://mmufaah.github.io/Dasboard_SuryaHub/) · [📄 Laporan Analis](Laporan_Analis_SuryaHub.pdf) · [🎞️ Slide Deck](Slide_Deck_SuryaHub.pptx) · [🧾 Query SQL](queries_suryahub.sql)

</div>

<!-- Ganti USERNAME dan NAMA-REPO pada link dashboard di atas dengan milik Anda. -->
<!-- Opsional: tambahkan tangkapan layar dashboard di folder images lalu hapus tanda komentar baris di bawah.
![Dashboard SuryaHub](images/dashboard.png)
-->

---

## 📌 Ringkasan

SuryaHub adalah platform e-commerce dengan pelanggan di enam kota. Proyek ini menjawab pertanyaan:

> **Bagaimana meningkatkan pembelian berulang dan nilai belanja per pelanggan?**

Saya menjawab **7 pertanyaan bisnis** dengan SQL di Google BigQuery, membuat dashboard interaktif, lalu memvalidasi temuan dengan **uji statistik di Python**. Hasilnya dirangkum dalam laporan analis dan slide deck.

| | |
|---|---|
| **Transaksi** | 500 (499 pelanggan unik) |
| **Total nilai belanja** | Rp 2.118.220.545 |
| **Rata-rata per transaksi** | Rp 4.236.441 |
| **Kolom data** | 15 |

## 🔑 Temuan Utama

| # | Temuan | Bukti |
|---|---|---|
| 1 | Non-anggota program loyalitas belanja sedikit lebih besar, tetapi **tidak signifikan** | Rp 4,38 jt vs Rp 4,10 jt (p = 0,14) |
| 2 | **4 dari 10** top spender memiliki Brand Loyalty terendah (skala 1) | Termasuk peringkat 1 dan 2 |
| 3 | Brand Loyalty hampir tidak berhubungan dengan belanja | Korelasi 0,015 |
| 4 | Planned tertinggi dan Impulsive terendah, tetapi selisihnya kecil | Rp 4,34 jt vs Rp 4,14 jt (p = 0,84) |
| 5 | Penggunaan diskon seimbang | 250 dengan diskon, 250 tanpa diskon |

> 💡 **Kesimpulan:** perilaku belanja relatif seragam di semua segmen yang tersedia. Strategi sebaiknya diuji lewat eksperimen A/B, bukan disusun dari selisih kecil antar segmen.

## 📑 Daftar Isi

1. [Data](#-data)
2. [Analisis SQL](#-analisis-sql)
3. [Validasi Statistik](#-validasi-statistik)
4. [Dashboard, Laporan, dan Slide Deck](#-dashboard-laporan-dan-slide-deck)
5. [Rekomendasi dan Roadmap](#-rekomendasi-dan-roadmap)
6. [Keterbatasan](#-keterbatasan)
7. [Struktur Repositori](#-struktur-repositori)

## 🗂️ Data

- **Sumber:** dataset studi kasus SuryaHub dari Harisenin Data Analyst Bootcamp (skenario evaluasi Juni 2025 dan perencanaan uji coba Juli 2025).
- **Tabel:** `Surya_Hub.Data_suryahub` di Google BigQuery.
- **Catatan:** file mentah tidak disertakan di repositori ini.

**Kualitas data**

| Pemeriksaan | Hasil |
|---|---|
| Customer_ID ganda | 1 (19-933-8095, Jakarta) muncul 2 kali dengan channel dan niat membeli berbeda |
| `Social_Media_Influence` | Kategori High / Medium / Low, 118 data kosong (23,6%) |
| `Frequency_of_Purchase` | 1 data kosong |
| Baris identik | Tidak ada |

## 🧮 Analisis SQL

Klik tiap pertanyaan untuk melihat query dan hasilnya. Semua query ada di [`sql/queries_suryahub.sql`](queries_suryahub.sql).

<details>
<summary><b>1. Berapa total transaksi pelanggan perempuan?</b></summary>

```sql
SELECT
  Gender,
  COUNT(*) AS Jumlah_Total_Transaksi
FROM `Surya_Hub.Data_suryahub`
WHERE Gender = 'Female'
GROUP BY Gender;
```

**Temuan:** 265 transaksi (53,0% dari 500). Selisih belanja perempuan (4,38 jt) dan laki-laki (4,07 jt) tidak signifikan (p = 0,09).
</details>

<details>
<summary><b>2. Lima kota dengan pelanggan terbanyak</b></summary>

```sql
SELECT
  Location,
  COUNT(DISTINCT Customer_ID) AS Total_Customers
FROM `Surya_Hub.Data_suryahub`
GROUP BY Location
ORDER BY Total_Customers DESC
LIMIT 5;
```

| Kota | Pelanggan unik |
|---|---|
| Makassar | 95 |
| Jakarta | 89 |
| Bandung | 82 |
| Surabaya | 78 |
| Medan | 78 |

**Insight:** selisih antarkota kecil (Papua 77 tepat di bawahnya), sehingga pelanggan tersebar merata.
</details>

<details>
<summary><b>3. Pelanggan Brand Loyalty 5: apakah memakai diskon?</b></summary>

```sql
SELECT
  Discount_Used,
  COUNT(*) AS Total
FROM `Surya_Hub.Data_suryahub`
WHERE Brand_Loyalty = 5
GROUP BY Discount_Used;
```

**Temuan:** dari 106 transaksi, 60 tanpa diskon (56,6%) dan 46 dengan diskon (43,4%). Pada seluruh data, penggunaan diskon seimbang (250 vs 250).
</details>

<details>
<summary><b>4. Niat membeli: siapa yang belanja lebih besar dan lebih sering?</b></summary>

```sql
SELECT
  Purchase_Intent,
  AVG(Purchase_Amount) AS avg_amount,
  AVG(Frequency_of_Purchase) AS avg_frequency
FROM `Surya_Hub.Data_suryahub`
GROUP BY Purchase_Intent
ORDER BY avg_amount DESC;
```

| Niat membeli | Rata-rata belanja | Rata-rata frekuensi |
|---|---|---|
| Planned | 4,34 jt | 6,94 |
| Need-based | 4,30 jt | 6,87 |
| Wants-based | 4,17 jt | 6,83 |
| Impulsive | 4,14 jt | 6,68 |

**Insight:** selisih kecil dan tidak signifikan (p = 0,84).
</details>

<details>
<summary><b>5. Perbandingan channel pembelian</b></summary>

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
| Mixed | 4,46 jt | 6,56 |
| In-Store | 4,14 jt | 7,14 |
| Online | 4,10 jt | 6,81 |

**Insight:** Mixed tertinggi dalam belanja dan In-Store dalam frekuensi, tetapi tidak signifikan (p = 0,20 dan 0,22).
</details>

<details>
<summary><b>6. Anggota vs non-anggota program loyalitas</b></summary>

```sql
SELECT
  Customer_Loyalty_Program_Member,
  AVG(Purchase_Amount) AS avg_amount,
  AVG(Frequency_of_Purchase) AS avg_frequency
FROM `Surya_Hub.Data_suryahub`
GROUP BY Customer_Loyalty_Program_Member;
```

| Kelompok | Rata-rata belanja | Rata-rata frekuensi |
|---|---|---|
| Non-anggota | 4,38 jt | 6,99 |
| Anggota | 4,10 jt | 6,68 |

**Insight:** program loyalitas saat ini belum terbukti mendorong belanja anggotanya.
</details>

<details>
<summary><b>7. Sepuluh pelanggan dengan total belanja tertinggi</b></summary>

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
**Insight:** pelanggan bernilai tertinggi belum tentu loyal, sehingga berisiko berpindah ke kompetitor.
</details>

## 🧪 Validasi Statistik

Hasil SQL divalidasi ulang dengan Python (pandas dan scipy) melalui [`uji_statistik_suryahub.py`](uji_statistik_suryahub.py).

| Perbandingan | p-value | Kesimpulan |
|---|---|---|
| Anggota vs non-anggota (belanja) | 0,137 | Tidak signifikan |
| Anggota vs non-anggota (frekuensi) | 0,260 | Tidak signifikan |
| Perempuan vs laki-laki (belanja) | 0,092 | Tidak signifikan |
| Antar niat membeli (belanja) | 0,838 | Tidak signifikan |
| Antar channel (belanja) | 0,202 | Tidak signifikan |
| Antar channel (frekuensi) | 0,221 | Tidak signifikan |

## 📊 Dashboard, Laporan, dan Slide Deck

| Hasil kerja | Isi |
|---|---|
| [Dashboard interaktif](https://mmufaah.github.io/Dasboard_SuryaHub/) | Filter gender, lokasi, dan channel; KPI, enam grafik, dan 10 pelanggan teratas |
| [Laporan analis](Laporan_Analis_SuryaHub.pdf) | Ringkasan eksekutif, profil pelanggan, loyalitas, channel, top spender, roadmap |
| [Slide deck](Slide_Deck_SuryaHub.pptx) | Tujuh slide presentasi untuk tim marketing dan manajemen |

## 🚀 Rekomendasi dan Roadmap

Karena tidak ada segmen yang jelas unggul, setiap rekomendasi dijalankan sebagai **eksperimen dengan grup uji dan grup kontrol**.

| Minggu | Fokus | Eksperimen | Target hipotesis |
|---|---|---|---|
| 1 | Restrukturisasi loyalitas | Manfaat non-diskon untuk sebagian anggota | +15% registrasi member baru |
| 2 | Pembeli impulsif | Flash sale terbatas waktu pada sampel acak | +20% conversion rate |
| 3 | Dorongan geografis | Gratis ongkir di Makassar, pengiriman cepat di Jakarta | +12% repeat order di Makassar |
| 4 | Planned dan channel Mixed | Bundling mingguan dan insentif ambil di toko | +10% nilai belanja Planned |

Target di atas adalah **hipotesis untuk diuji**, bukan hasil dari data historis. Rekomendasi tambahan: layanan khusus untuk top spender berloyalitas rendah dan uji loyalty cashback sebagai pengganti potongan harga langsung.

**Metrik keberhasilan**
- Revenue per Customer = Total Revenue / Total Unique Customers
- Repeat Purchase Rate (%) = (Pelanggan belanja lebih dari 1 kali / Total pelanggan) × 100%

## ⚠️ Keterbatasan

- Data tidak memuat waktu transaksi, data pembelian berulang, atau biaya promosi, sehingga repeat purchase dan ROI belum dapat dihitung.
- `Social_Media_Influence` memiliki 23,6% data kosong dan tidak dipakai untuk kesimpulan.
- Target KPI pada roadmap belum didasarkan pada data historis.
- Langkah lanjutan: versi Tableau atau Power BI dan uji A/B nyata jika data eksperimen tersedia.

## 📁 Struktur Repositori

```
.
├── README.md
├── Dashboard_SuryaHub.html
├── uji_statistik_suryahub.py
├── sql/
│   └── queries_suryahub.sql
└── docs/
    ├── Laporan_Analis_SuryaHub.pdf
    └── Slide_Deck_SuryaHub.pptx
```

---

<div align="center">

**Muhamad Fahrudin** · Aspiring Data Analyst
[LinkedIn](https://www.linkedin.com/in/mmufaah) · mufa290300@gmail.com

</div>
