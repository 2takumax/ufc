import streamlit as st
import numpy as np
import pandas as pd
from PIL import Image
import time
import snowflake.connector


def fetch_data_as_dataframe(conn, sql_query):
    """
    SQLクエリを実行し、結果をPandas DataFrameとして返す。
    
    引数:
    conn : Snowflakeのコネクションオブジェクト
    sql_query : 実行するSQLクエリの文字列
    
    戻り値:
    df : クエリ結果（Pandas DataFrame）
    """
    cur = conn.cursor()
    try:
        cur.execute(sql_query)
        df = cur.fetch_pandas_all()
        return df
    finally:
        cur.close()

conn = snowflake.connector.connect(
    user=st.secrets.user,
    password=st.secrets.password,
    account=st.secrets.account,
    warehouse=st.secrets.warehouse,
    database=st.secrets.database,
    schema=st.secrets.schema
)

# SQLクエリ
sql_query_fighters = "SELECT * FROM UFC.DEV.DIM_FIGHTERS"
# sql_query_fight_results = "SELECT * FROM UFC.DEV.FCT_FIGHT_RESULTS"
# sql_query_fight_stats = "SELECT * FROM UFC.DEV.FCT_FIGHT_STATS"

# データフレームの取得
fighters_df = fetch_data_as_dataframe(conn, sql_query_fighters)
# fight_results_df = fetch_data_as_dataframe(conn, sql_query_fight_results)
# fight_stats_df = fetch_data_as_dataframe(conn, sql_query_fight_stats)

# 接続のクローズ
conn.close()

# データを読み込む
# df = pd.read_csv('ufc_fighter_tott.csv')

# # 誕生日を条件付きでdate型に変換（無効な日付はNaTになる）
# df['DOB'] = pd.to_datetime(df['DOB'], errors='coerce')

# # 誕生日をdate型に変換
# df['DOB'] = pd.to_datetime(df['DOB'])

# # タイムスタンプ型から日付型に変換
# df['DOB'] = df['DOB'].dt.date

# Streamlit アプリケーションのタイトル
st.title('UFC Fighter Stats')

# ユーザー入力を受け取る
user_input = st.text_input('Search for a Fighter', '')

# 入力に基づいて DataFrame から選手を検索
# case=False で大文字小文字を区別しない
filtered_df = fighters_df[fighters_df['FIGHTER_NAME'].str.contains(user_input, case=False, na=False)]

# 検索結果を表示
if not filtered_df.empty:
    st.write(filtered_df)
else:
    st.write("No matching fighters found")


# st.title('Streamlit 超入門')

# st.write('Display Image')
# 'Start!!'

# latest_iteration = st.empty()
# bar = st.progress(0)

# for i in range(100):
#     latest_iteration.text(f'Iteration {i+1}')
#     bar.progress(i + 1)
#     time.sleep(0.1)

# left_column, right_column = st.columns(2)
# button = left_column.button('右カラムに文字を表示')

# if button:
#     right_column.write('右カラムです')

# expander = st.expander('問い合わせ')
# expander.write('問い合わせ内容を書く')
# option = st.selectbox(
#     'あなたが好きな数字を教えて下さい、',
#     list(range(1, 11))
# )

# text = st.text_input('あなたの趣味を教えて下さい。')
# 'あなたの趣味', text, 'です。'

# condition = st.slider('あなたの今の調子は？', 0, 100, 50)
# 'コンディション：', condition

# if st.checkbox('Show Image'):
#     img = Image.open('sample.jpeg')
#     st.image(img, caption='Taira Tatsuro', use_column_width=True)

# df = pd.DataFrame(
#     np.random.rand(100, 2)/[50, 50] + [35.69, 139.70],
#     columns=['lat', 'lon']
# )

# st.table(df.style.highlight_max(axis=1))
# st.line_chart(df)
# st.area_chart(df)
# st.bar_chart(df)
# st.map(df)
