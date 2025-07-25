import string
import pandas as pd
import datetime
import argparse

import utils
import scrape_ufc_stats_library as LIB

# import config
import yaml
config = yaml.safe_load(open('scrape_ufc_stats_config.yaml'))

def lambda_handler(event, context):
    bucket_name = "ufc-scraped-data"

    parsed_event_details_df = utils.read_s3_csv(bucket=bucket_name, key="event_details.csv")
    list_of_parsed_events = list(parsed_event_details_df['EVENT'])

    # get soup
    soup = LIB.get_soup(config['completed_events_all_url'])
    # parse event details
    updated_event_details_df = LIB.parse_event_details(soup)
    # get list of all event names
    list_of_all_events = list(updated_event_details_df['EVENT'])

    # find list event names that have not been parsed
    list_of_unparsed_events = [event for event in list_of_all_events if event not in list_of_parsed_events]

    # check if there are any unparsed events
    unparsed_events = False
    # if list_of_unparsed_events is empty then all available events have been parsed
    if not list_of_unparsed_events:
        print('All available events have been parsed.')
    else:
        # set unparsed_events to true
        unparsed_events = True
        # show list of unparsed events
        print(list_of_unparsed_events)
        # write event details to file
        utils.write_df_to_s3(df=updated_event_details_df, bucket=bucket_name, key="event_details.csv")



    ### parse all missing events ###
    # if unparsed_events = True
    # the code below continues to run to parse all missing events
    # new data is added to existing data and is written to file

    if unparsed_events == True:
        # read existing data files
        parsed_fight_details_df = utils.read_s3_csv(bucket=bucket_name, key="fight_details.csv")
        parsed_fight_results_df = utils.read_s3_csv(bucket=bucket_name, key="fight_results.csv")
        parsed_fight_stats_df = utils.read_s3_csv(bucket=bucket_name, key="fight_stats.csv")

        ### parse fight details ###

        # define list of urls of missing fights to parse
        list_of_unparsed_events_urls = list(updated_event_details_df['URL'].loc[(updated_event_details_df['EVENT'].isin(list_of_unparsed_events))])

        # create empty df to store fight details
        unparsed_fight_details_df = pd.DataFrame(columns=config['fight_details_column_names'])

        # loop through each event and parse fight details
        for url in list_of_unparsed_events_urls:

            # get soup
            soup = LIB.get_soup(url)

            # parse fight links
            fight_details_df = LIB.parse_fight_details(soup)
            
            # concat fight details to parsed fight details
            # concat update fight details to the top of existing df
            unparsed_fight_details_df = pd.concat([unparsed_fight_details_df, fight_details_df])

        # concat unparsed and parsed fight details
        parsed_fight_details_df = pd.concat([unparsed_fight_details_df, parsed_fight_details_df])

        # write fight details to file
        utils.write_df_to_s3(df=parsed_fight_details_df, bucket=bucket_name, key="fight_details.csv")

        ### parse fight results and fight stats

        # define list of urls of fights to parse
        list_of_unparsed_fight_details_urls = list(unparsed_fight_details_df['URL'])

        # create empty df to store fight results
        unparsed_fight_results_df = pd.DataFrame(columns=config['fight_results_column_names'])
        # create empty df to store fight stats
        unparsed_fight_stats_df = pd.DataFrame(columns=config['fight_stats_column_names'])

        # loop through each fight and parse fight results and stats
        for url in list_of_unparsed_fight_details_urls:

            # get soup
            soup = LIB.get_soup(url)

            # parse fight results and fight stats
            fight_results_df, fight_stats_df = LIB.parse_organise_fight_results_and_stats(
                soup, 
                url,
                config['fight_results_column_names'],
                config['totals_column_names'],
                config['significant_strikes_column_names']
                )

            # concat fight results
            unparsed_fight_results_df = pd.concat([unparsed_fight_results_df, fight_results_df])
            # concat fight stats
            unparsed_fight_stats_df = pd.concat([unparsed_fight_stats_df, fight_stats_df])

        # concat unparsed fight results and fight stats to parsed fight results and fight stats
        parsed_fight_results_df = pd.concat([unparsed_fight_results_df, parsed_fight_results_df])
        parsed_fight_stats_df = pd.concat([unparsed_fight_stats_df, parsed_fight_stats_df])

        # write to file
        utils.write_df_to_s3(df=parsed_fight_details_df, bucket=bucket_name, key="fight_results.csv")
        # write to file
        utils.write_df_to_s3(df=parsed_fight_details_df, bucket=bucket_name, key="fight_stats.csv")
