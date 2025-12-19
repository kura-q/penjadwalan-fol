# Run:
# streamlit run app_inferensi_kebijakan.py

# Aplikasi GUI berbasis Streamlit untuk:
# - Menjalankan query Prolog
# - Menampilkan hasil inferensi FOL secara interaktif

import streamlit as st
from pyswip import Prolog
import os

KB_FILE = "prolog_kb.pl" # Nama file Knowledge Base Prolog

st.set_page_config(layout="wide") # Konfigurasi layout halaman Streamlit
st.title("🤖 Analisis Inferensi Penjadwalan Ujian (FOL + Prolog)") # Judul utama aplikasi

# --- Load Prolog KB ---

# Mengecek apakah Prolog sudah dimuat ke session
if "prolog" not in st.session_state:
    if not os.path.exists(KB_FILE): # Validasi keberadaan file KB
        st.error(f"File {KB_FILE} tidak ditemukan.")
        st.stop()

    try:
        prolog = Prolog() # Membuat instance Prolog
        prolog.consult(KB_FILE) # Memuat file KB Prolog
        st.session_state.prolog = prolog # Menyimpan Prolog ke session_state
        st.success("Knowledge Base berhasil dimuat.")
    except Exception as e:
        st.error("Gagal memuat SWI-Prolog / KB.")
        st.error(str(e))
        st.stop()

prolog = st.session_state.prolog

# --- Inferensi ---
inferensi_list = [
    ("Apakah ruangan bentrok? (ruang & waktu sama)", "bentrok_ruangan(X, Y)"),
    ("Apakah ruangan tidak bisa dipakai?", "ruang_tidak_dapat_dipakai(R, W)"),
    ("Apakah kekurangan ruangan (per prodi-tingkat)?", "kekurangan_ruang(P, T)"),
    ("Adakah potensi bentrok (kelas ditempatkan di ruang terpakai)?", "potensi_bentrok(K, R, W)"),
    ("Apakah pengawas tidak bisa hadir untuk kelas yang ditugaskan?", "pengawas_tidak_bisa(P, K)"),
    ("Apakah kelas bermasalah? (bentrok atau ruang invalid)", "kelas_bermasalah(K)"),
    ("Apakah jadwal bermasalah?", "jadwal_bermasalah(K)"),
    ("Perlukah penjadwalan ulang? (Rantai 3 Langkah)", "perlu_penjadwalan_ulang(K)"),
    ("Apakah butuh pengawas pengganti?", "butuh_pengawas_pengganti(K)")
]

def run_query(q: str) -> str:
    """
    Menjalankan query Prolog dan memformat output agar:
    - Menampilkan VALID / TIDAK VALID
    - Menampilkan binding variabel jika ada
    """
    try:
        results = list(prolog.query(q))

        if not results:
            return "❌ TIDAK VALID"

        output = ["✅ VALID"]

        # Jika query punya binding variabel
        if results != [{}]:
            output.append("Hasil binding variabel:")
            for i, r in enumerate(results, start=1):
                bindings = ", ".join(f"{k} = {v}" for k, v in r.items())
                output.append(f"{i}. {bindings}")

        return "\n".join(output)

    except Exception as e:
        return f"ERROR: {e}"

# Membagi halaman menjadi dua kolom:
# kiri = KB, kanan = inferensi
col_kb, col_inf = st.columns([1, 2])

with col_kb:
    st.subheader("📘 Knowledge Base (prolog_kb.pl)")
    try:
        with open(KB_FILE, "r", encoding="utf-8") as f:
            st.code(f.read(), language="prolog")
    except Exception as e:
        st.error(f"Gagal membaca KB: {e}")

with col_inf:
    st.subheader("🔍 Uji Inferensi")

    for i, (nama, query) in enumerate(inferensi_list):
        with st.expander(f"{i+1}. {nama}", expanded=False):
            st.code(query, language="prolog")
            if st.button(f"Uji: {nama}", key=f"btn{i}"):
                st.text(run_query(query))

    st.markdown("---")
    st.subheader("🧪 Query Kustom")
    custom = st.text_input("Masukkan query Prolog (contoh: kelas_di_ruang(K,R,W).)")
    if st.button("Jalankan Query Kustom"):
        if custom.strip():
            st.text(run_query(custom.strip()))
        else:
            st.warning("Query kosong.")