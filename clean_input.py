#!/bin/env python3

"""
Python 3
    clean input files:
    - should be utf-8 inputs
    - used to be 1-1 relationship between code and question, now change to same code can be used more than one time

"""

from shutil import copyfile
import pandas as pd
import csv
import os
import re


def guess_delimiter(text_file):
    """
        Guess delimiter in a text file
    """
    with open(text_file, 'r') as csvfile: 
        dialect = csv.Sniffer().sniff(csvfile.readline()) 
        d = dialect.delimiter
    return d


def get_new_label(df):
    """
    Go though codes table, find re-used codes
    """
    label_dict = {}
    codes_dict = {}

    for old_label in df['Label'].unique():
        # print(old_label)
        df_codes = df.loc[(df.Label == old_label), ['Code_Order', 'Code_Value', 'Category', 'min_responses', 'max_responses']].reset_index(drop=True)

        # two values and each value is one word only
        if (df_codes.shape[0] == 2) and ( all([ not pd.isnull(s) and len(s.split()) == 1 for s in df_codes['Category'].tolist()])):
            #print("TWO")
            new_label = 'cs_' + ('_').join(df_codes['Category'].tolist()) 

        elif not bool(codes_dict):
            #print("empty dict")
            new_label = old_label

        # already in codes value, no need to add again
        else:
            new_label = old_label
            for dict_label, dict_df in codes_dict.items():
                if df_codes.equals(dict_df):
                    new_label =  dict_label

        label_dict[old_label] = new_label

        if not new_label in codes_dict.keys():
            codes_dict[new_label] = df_codes

    return label_dict, codes_dict


def main():
    input_dir = 'archivist_tables_utf8'
    output_dir = 'archivist_tables_clean'
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    input_files = [f for f in os.listdir(input_dir) if f.split('.')[0].lower() != 'readme']  
    ordered_list = ['codelist', 'question_grid', 'question_item', 'loop', 'condition', 'response', 'sequence', 'statement']
    ordered_input_files = sorted(input_files, key = lambda x: ordered_list.index(x.split('.')[0]))

    for f in ordered_input_files:

        # question grid
        if os.path.splitext(f)[0].lower() == 'question_grid':
            qg_file = os.path.join(input_dir, f)
            if os.path.isfile(qg_file):
                d_qg = guess_delimiter(qg_file)

                df_qg = pd.read_csv(qg_file, sep=d_qg, dtype=object)
                df_qg['Horizontal_Codelist_Name'] = df_qg['Horizontal_Codelist_Name'].map(label_dict).fillna(df_qg['Horizontal_Codelist_Name'])
                df_qg['Vertical_Codelist_Name'] = df_qg['Vertical_Codelist_Name'].map(label_dict).fillna(df_qg['Vertical_Codelist_Name'])
                df_qg['Response_domain'] = df_qg['Response_domain'].map(label_dict).fillna(df_qg['Response_domain'])
                df_qg.to_csv(os.path.join(output_dir, 'question_grid.csv'), encoding='utf-8', sep='\t', index=False)


        # question item
        elif os.path.splitext(f)[0].lower() == 'question_item':
            qi_file = os.path.join(input_dir, f)
            if os.path.isfile(qi_file):
                d_qi = guess_delimiter(qi_file)

                df_qi = pd.read_csv(qi_file, sep=d_qi, dtype=object)
                df_qi['Response'] = df_qi['Response'].map(label_dict).fillna(df_qi['Response'])
                df_qi.to_csv(os.path.join(output_dir, 'question_item.csv'), encoding='utf-8', sep='\t', index=False)


        # code list
        elif os.path.splitext(f)[0].lower() == 'codelist':
            # guess delimiter
            d_code = guess_delimiter(os.path.join(input_dir, f))

            df_codes = pd.read_csv(os.path.join(input_dir, f), sep=d_code, dtype=object)

            # read question grid file
            qg_file = os.path.join(input_dir, 'question_grid.csv')
            if os.path.isfile(qg_file):
                d_qg = guess_delimiter(qg_file)
                df_qg = pd.read_csv(qg_file, sep=d_qg, dtype=object)
            else:
                df_qg = pd.DataFrame(columns = ['Horizontal_Codelist_Name', 'Horizontal_min_responses', 'Horizontal_max_responses',
                                                'Vertical_Codelist_Name', 'Vertical_min_responses', 'Vertical_max_responses'])

            # read question item file
            qi_file = os.path.join(input_dir, 'question_item.csv')
            if os.path.isfile(qi_file):
                d_qi = guess_delimiter(qi_file)
                df_qi = pd.read_csv(qi_file, sep=d_qi, dtype=object)
            else:
                df_qi = pd.DataFrame(columns = ['Response', 'min_responses', 'max_responses'])

            # get min/max response from question item file
            df_qi_response = df_qi.loc[(df_qi.Response != None), ['Response', 'min_responses', 'max_responses']] 
            df_qi_response.rename(columns={'Response': 'Label'}, inplace=True)

            # get min/max response from question grid file
            df_qg_horizontal = df_qg.loc[(df_qg.Horizontal_Codelist_Name != None), ['Horizontal_Codelist_Name', 'Horizontal_min_responses', 'Horizontal_max_responses']]
            df_qg_horizontal.rename(columns={'Horizontal_Codelist_Name': 'Label',
                                             'Horizontal_min_responses': 'min_responses',
                                             'Horizontal_max_responses': 'max_responses'}, inplace=True)

            df_qg_vertical = df_qg.loc[(df_qg.Vertical_Codelist_Name != None), ['Vertical_Codelist_Name', 'Vertical_min_responses', 'Vertical_max_responses']]
            df_qg_vertical.rename(columns={'Vertical_Codelist_Name': 'Label',
                                           'Vertical_min_responses': 'min_responses',
                                           'Vertical_max_responses': 'max_responses'}, inplace=True)
            df_gq_response = df_qg_horizontal.append(df_qg_vertical)

            # combine all codes from qi and qg
            df_qi_qg_response= df_qi_response.append(df_gq_response).drop_duplicates(keep='first').reset_index()

            # merge min/max response with codelist
            df_codes_all = df_codes.merge(df_qi_qg_response, how='left')

            label_dict, codes_dict = get_new_label(df_codes_all)

            df_codes_dict = pd.concat(codes_dict, axis=0).reset_index().drop('level_1', 1)
            df_codes_dict.rename(columns={'level_0': 'Label'}, inplace=True)
            df_codes_dict.drop(['min_responses', 'max_responses'], axis=1, inplace=True)

            df_codes_dict.to_csv(os.path.join(output_dir, 'codelist.csv'), encoding='utf-8', sep='\t', index=False)


        # loop
        elif os.path.splitext(f)[0].lower() == 'loop':
            loop_file = os.path.join(input_dir, f)
            if os.path.isfile(loop_file):
                d_loop = guess_delimiter(loop_file)

                df_loop = pd.read_csv(loop_file, sep=d_loop, dtype=object)
                df_loop.to_csv(os.path.join(output_dir, 'loop.csv'), encoding='utf-8', sep='\t', index=False)

        # condition
        elif os.path.splitext(f)[0].lower() == 'condition':
            condition_file = os.path.join(input_dir, f)
            if os.path.isfile(condition_file):
                d_condition = guess_delimiter(condition_file)

                df_condition = pd.read_csv(condition_file, sep=d_condition, dtype=object)
                df_condition.to_csv(os.path.join(output_dir, 'condition.csv'), encoding='utf-8', sep='\t', index=False)

        # response
        elif os.path.splitext(f)[0].lower() == 'response':
            response_file = os.path.join(input_dir, f)
            if os.path.isfile(response_file):
                d_response = guess_delimiter(response_file)

                df_response = pd.read_csv(response_file, sep=d_response, dtype=object)
                df_response.to_csv(os.path.join(output_dir, 'response.csv'), encoding='utf-8', sep='\t', index=False)

        # sequence
        elif os.path.splitext(f)[0].lower() == 'sequence':
            sequence_file = os.path.join(input_dir, f)
            if os.path.isfile(sequence_file):
                d_sequence = guess_delimiter(sequence_file)

                df_sequence = pd.read_csv(sequence_file, sep=d_sequence, dtype=object)
                df_sequence.to_csv(os.path.join(output_dir, 'sequence.csv'), encoding='utf-8', sep='\t', index=False)

        # statement
        elif os.path.splitext(f)[0].lower() == 'statement':
            statement_file = os.path.join(input_dir, f)
            if os.path.isfile(statement_file):
                d_statement = guess_delimiter(statement_file)

                df_statement = pd.read_csv(statement_file, sep=d_statement, dtype=object)
                df_statement.to_csv(os.path.join(output_dir, 'statement.csv'), encoding='utf-8', sep='\t', index=False)


if __name__ == '__main__':
    main()
