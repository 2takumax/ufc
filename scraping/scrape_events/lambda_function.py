import pandas as pd
import yaml
config = yaml.safe_load(open('scrape_ufc_stats_config.yaml'))

import scrape_ufc_stats_library as LIB


def lambda_handler(event, context):
    # バケットとファイル名を指定
    bucket_name = 'my-test-terraform-bucket-202504'
    
    # 定義されたURLからイベントの詳細を解析
    events_url = config['completed_events_all_url']
    soup = LIB.get_soup(events_url)
    all_event_details_df = LIB.parse_event_details(soup)
    
    # 既存のイベント詳細CSVファイルを読み込む
    try:
        existing_event_details_df = LIB.read_csv_from_s3(bucket=bucket_name, key='ufc_event_details.csv')
    except FileNotFoundError:
        existing_event_details_df = pd.DataFrame(columns=config['fight_events_column_names'])
    
    # 新しく追加されたイベントのみを抽出
    new_events_df = all_event_details_df[~all_event_details_df['URL'].isin(existing_event_details_df['URL'])]

    # 加工したデータを S3 に保存
    LIB.write_df_to_s3(df=all_event_details_df, bucket=bucket_name, key='ufc_event_details.csv')
    
    # 戦闘の詳細を格納する空のDataFrameを作成
    all_fight_details_df = pd.DataFrame(columns=config['fight_details_column_names'])
    
    # 新しいイベントに対してのみループを実行
    for index, row in new_events_df.iterrows():
        soup = LIB.get_soup(row['URL'])
        fight_details_df = LIB.parse_fight_details(soup)
        
        fight_details_df['DATE'] = row['DATE']
        fight_details_df['LOCATION'] = row['LOCATION']
        
        # 戦闘の詳細を結合
        all_fight_details_df = pd.concat([all_fight_details_df, fight_details_df])
    
    # create empty df to store fight results
    all_fight_results_df = pd.DataFrame(columns=config['fight_results_column_names'] + ['DATE', 'LOCATION'])
    # create empty df to store fight stats
    all_fight_stats_df = pd.DataFrame(columns=config['fight_stats_column_names'] + ['DATE', 'LOCATION'])
    
    # loop through each fight and parse fight results and stats
    for index, row in all_fight_details_df.iterrows():
    
        # get soup
        soup = LIB.get_soup(row['URL'])
    
        # parse fight results and fight stats
        fight_results_df, fight_stats_df = LIB.parse_organise_fight_results_and_stats(
            soup,
            row['URL'],
            config['fight_results_column_names'],
            config['totals_column_names'],
            config['significant_strikes_column_names']
            )
    
        fight_results_df['DATE'] = row['DATE']
        fight_results_df['LOCATION'] = row['LOCATION']
    
        fight_stats_df['DATE'] = row['DATE']
        fight_stats_df['LOCATION'] = row['LOCATION']
        
        # concat fight results
        all_fight_results_df = pd.concat([all_fight_results_df, fight_results_df])
        # concat fight stats
        all_fight_stats_df = pd.concat([all_fight_stats_df, fight_stats_df])
    
    #DATEカラムを'2030-01-01'形式に変換
    all_fight_results_df['DATE'] = pd.to_datetime(all_fight_results_df['DATE'], errors='coerce')
    all_fight_stats_df['DATE'] = pd.to_datetime(all_fight_stats_df['DATE'], errors='coerce')

    #過去分と最新分を合わせて保存する
    existing_fight_results_df = LIB.read_csv_from_s3(bucket=bucket_name, key='ufc_fight_results.csv')
    existing_fight_stats_df = LIB.read_csv_from_s3(bucket=bucket_name, key='ufc_fight_stats.csv')

    all_fight_results_df = pd.concat([all_fight_results_df, existing_fight_results_df])
    all_fight_stats_df = pd.concat([all_fight_stats_df, existing_fight_stats_df])
    
    LIB.write_df_to_s3(df=all_fight_results_df, bucket=bucket_name, key='ufc_fight_results.csv')   
    LIB.write_df_to_s3(df=all_fight_results_df, bucket=bucket_name, key='ufc_fight_stats.csv') 
    
    
    return {
        'statusCode': 200,
        'body': 'File processed and saved successfully'
    }
