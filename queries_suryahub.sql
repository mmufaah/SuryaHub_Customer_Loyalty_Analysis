-- Analisis Perilaku dan Loyalitas Pelanggan SuryaHub
-- Platform: Google BigQuery
-- Tabel: `Surya_Hub.Data_suryahub` (500 baris, 15 kolom)
-- Penulis: Muhamad Fahrudin

-- ============================================================
-- A. Pemeriksaan kualitas data
-- ============================================================

-- A1. Jumlah transaksi, pelanggan unik, total dan rata-rata belanja
SELECT
  COUNT(*) AS total_transaksi,
  COUNT(DISTINCT Customer_ID) AS pelanggan_unik,
  SUM(Purchase_Amount) AS total_belanja,
  AVG(Purchase_Amount) AS rata_rata_belanja
FROM `Surya_Hub.Data_suryahub`;

-- A2. Customer_ID yang muncul lebih dari sekali
SELECT
  Customer_ID,
  COUNT(*) AS jumlah_baris
FROM `Surya_Hub.Data_suryahub`
GROUP BY Customer_ID
HAVING COUNT(*) > 1;

-- A3. Jumlah nilai kosong pada kolom yang dipakai analisis
SELECT
  COUNTIF(Frequency_of_Purchase IS NULL) AS kosong_frekuensi,
  COUNTIF(Social_Media_Influence IS NULL) AS kosong_social_media
FROM `Surya_Hub.Data_suryahub`;

-- ============================================================
-- B. Tujuh pertanyaan bisnis
-- ============================================================

-- 1. Berapa total transaksi pelanggan perempuan?
SELECT
  Gender,
  COUNT(*) AS Jumlah_Total_Transaksi
FROM `Surya_Hub.Data_suryahub`
WHERE Gender = 'Female'
GROUP BY Gender;

-- 2. Lima kota dengan jumlah pelanggan terbanyak
SELECT
  Location,
  COUNT(DISTINCT Customer_ID) AS Total_Customers
FROM `Surya_Hub.Data_suryahub`
GROUP BY Location
ORDER BY Total_Customers DESC
LIMIT 5;

-- 3. Pelanggan dengan Brand Loyalty 5: apakah memakai diskon?
SELECT
  Discount_Used,
  COUNT(*) AS Total
FROM `Surya_Hub.Data_suryahub`
WHERE Brand_Loyalty = 5
GROUP BY Discount_Used;

-- 4. Segmen niat membeli: siapa yang belanja lebih besar dan lebih sering?
SELECT
  Purchase_Intent,
  AVG(Purchase_Amount) AS avg_amount,
  AVG(Frequency_of_Purchase) AS avg_frequency
FROM `Surya_Hub.Data_suryahub`
GROUP BY Purchase_Intent
ORDER BY avg_amount DESC;

-- 5. Perbandingan channel pembelian
SELECT
  Purchase_Channel,
  AVG(Purchase_Amount) AS avg_amount,
  AVG(Frequency_of_Purchase) AS avg_frequency
FROM `Surya_Hub.Data_suryahub`
GROUP BY Purchase_Channel;

-- 6. Anggota vs non-anggota program loyalitas
SELECT
  Customer_Loyalty_Program_Member,
  AVG(Purchase_Amount) AS avg_amount,
  AVG(Frequency_of_Purchase) AS avg_frequency
FROM `Surya_Hub.Data_suryahub`
GROUP BY Customer_Loyalty_Program_Member;

-- 7. Sepuluh pelanggan dengan total belanja tertinggi
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
