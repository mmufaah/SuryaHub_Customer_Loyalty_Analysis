"""Validasi angka dan uji statistik untuk proyek SuryaHub.

Cara pakai:
1. Simpan file CSV dataset di folder yang sama dengan script ini.
2. Ubah nama file di variabel FILE di bawah jika perlu.
3. Jalankan: python uji_statistik_suryahub.py
"""
import pandas as pd
from scipy import stats

FILE = "Data_SuryaHub_-_HSB_Data_Analyst_-_Mission_Intermediate_1_-_Data_SuryaHub.csv"
df = pd.read_csv(FILE)

# 1. Kualitas data
print("Jumlah baris (transaksi):", len(df))
print("Pelanggan unik:", df["Customer_ID"].nunique())
print("Customer_ID yang muncul lebih dari sekali:",
      df.loc[df["Customer_ID"].duplicated(keep=False), "Customer_ID"].unique().tolist())
print("\nNilai kosong per kolom:")
print(df.isna().sum()[df.isna().sum() > 0])
print("\nTotal nilai belanja:", f"{df['Purchase_Amount'].sum():,}")
print("Rata-rata per transaksi:", f"{df['Purchase_Amount'].mean():,.0f}")

# 2. Ringkasan per segmen (rata-rata, bukan jumlah kumulatif)
def ringkas(kolom):
    return df.groupby(kolom).agg(
        transaksi=("Customer_ID", "count"),
        rata_belanja=("Purchase_Amount", "mean"),
        rata_frekuensi=("Frequency_of_Purchase", "mean"),
    ).round(2)

for kolom in ["Purchase_Intent", "Purchase_Channel",
              "Customer_Loyalty_Program_Member", "Gender"]:
    print(f"\n=== {kolom} ===")
    print(ringkas(kolom))

# 3. Diskon
print("\nPenggunaan diskon (semua transaksi):", df["Discount_Used"].value_counts().to_dict())
loyal5 = df[df["Brand_Loyalty"] == 5]
print("Brand Loyalty = 5:", loyal5["Discount_Used"].value_counts().to_dict())

# 4. Uji statistik (p-value < 0,05 berarti selisih signifikan)
member = df[df["Customer_Loyalty_Program_Member"]]
non = df[~df["Customer_Loyalty_Program_Member"]]
female = df[df["Gender"] == "Female"]
male = df[df["Gender"] == "Male"]

def p(hasil):
    return round(float(hasil.pvalue), 3)

print("\n=== Uji statistik ===")
print("Anggota vs non-anggota (belanja):",
      p(stats.ttest_ind(member["Purchase_Amount"], non["Purchase_Amount"], equal_var=False)))
print("Anggota vs non-anggota (frekuensi):",
      p(stats.ttest_ind(member["Frequency_of_Purchase"].dropna(),
                        non["Frequency_of_Purchase"].dropna(), equal_var=False)))
print("Perempuan vs laki-laki (belanja):",
      p(stats.ttest_ind(female["Purchase_Amount"], male["Purchase_Amount"], equal_var=False)))
print("Antar Purchase Intent (belanja):",
      p(stats.f_oneway(*[g["Purchase_Amount"] for _, g in df.groupby("Purchase_Intent")])))
print("Antar channel (belanja):",
      p(stats.f_oneway(*[g["Purchase_Amount"] for _, g in df.groupby("Purchase_Channel")])))
print("Antar channel (frekuensi):",
      p(stats.f_oneway(*[g["Frequency_of_Purchase"].dropna() for _, g in df.groupby("Purchase_Channel")])))
print("Korelasi Brand Loyalty vs belanja:",
      round(df["Brand_Loyalty"].corr(df["Purchase_Amount"]), 3))
print("Korelasi Brand Loyalty vs frekuensi:",
      round(df["Brand_Loyalty"].corr(df["Frequency_of_Purchase"]), 3))
