import streamlit as st
from pyswip import Prolog
import os

KB_FILE = "prolog_kb.pl"

st.set_page_config(layout="wide")
st.title("🤖 Analisis Inferensi Penjadwalan Ujian (FOL + Prolog)")

if "prolog" not in st.session_state:
    if not os.path.exists(KB_FILE):
        st.error(f"File {KB_FILE} tidak ditemukan.")
        st.stop()

    prolog = Prolog()
    prolog.consult(KB_FILE)
    st.session_state.prolog = prolog
    st.success("Knowledge Base berhasil dimuat.")

prolog = st.session_state.prolog

inferensi_list = [
    ("Bentrok Ruangan", "bentrok_ruangan(X,Y)"),
    ("Ruang Tidak Bisa Dipakai", "ruang_tidak_dapat_dipakai(R,W)"),
    ("Kekurangan Ruang", "kekurangan_ruang(P,T)"),
    ("Potensi Bentrok", "potensi_bentrok(K,R,W)"),
    ("Pengawas Tidak Bisa", "pengawas_tidak_bisa(P,K)"),
    ("Kelas Bermasalah", "kelas_bermasalah(K)"),
    ("Jadwal Bermasalah", "jadwal_bermasalah(K)"),
    ("Perlu Penjadwalan Ulang (Rantai 3 Langkah)", "perlu_penjadwalan_ulang(K)")
]

def run_query(q):
    try:
        result = list(prolog.query(q))
        if not result:
            return "❌ TIDAK VALID (False)"
        if result == [{}]:
            return "✅ VALID (True)"
        return "\n".join(str(r) for r in result)
    except Exception as e:
        return f"ERROR: {e}"

col_kb, col_inf = st.columns([1, 2])

with col_kb:
    st.subheader("📘 Knowledge Base (prolog_kb.pl)")
    with open(KB_FILE) as f:
        st.code(f.read(), language="prolog")

with col_inf:
    st.subheader("🔍 Uji Inferensi Wajib")

    for i, (nama, query) in enumerate(inferensi_list):
        with st.expander(f"{i+1}. {nama}"):
            st.code(query, language="prolog")
            if st.button(f"Uji {nama}", key=f"btn{i}"):
                st.text(run_query(query))

    st.markdown("---")
    st.subheader("🧪 Query Kustom")
    custom = st.text_input("Masukkan query Prolog")
    if st.button("Jalankan Query"):
        st.text(run_query(custom))
