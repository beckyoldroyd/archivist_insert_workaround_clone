from pytest import raises
import pandas as pd
import os
from pathlib import Path


# run "pytest" on command line (maybe "pytest-3" on older computers)

# template
template_dir = Path("template")
template_files = [template_dir / f for f in os.listdir(template_dir) if os.path.isfile(os.path.join(template_dir, f))]

# list of template file names
valid_names = ['question_item', 'codelist', 'loop', 'condition', 'sequence', 'statement', 'response', 'question_grid']

tables_dir = Path("archivist_tables_utf8")
allfiles = [tables_dir / f for f in os.listdir(tables_dir) if (tables_dir / f).is_file() and (tables_dir / f).name.lower() != "readme.txt"]


def test_same_type():
    """
    All input files should have the same suffix.
    """
    t = [f.suffix for f in allfiles]
    assert len(set(t)) == 1


def test_names_subset():
    """
    All input files should have valid names
    """
    names = [f.stem for f in allfiles]
    for name in names:
        assert name in valid_names


def test_headers_match_template():
    """
    All input files should have valid headers
    """
    for f in allfiles:
        g = template_dir / f.with_suffix(".csv").name
        df_input = pd.read_csv(f, sep=None)
        df_template = pd.read_csv(g, sep=None)
        assert df_input.columns.to_list() == df_template.columns.to_list()


def test_unique_label():
    """
    All input files (except codelist) should not have duplicated lables
    """
    for f in allfiles:
        if not f.stem == "codelist":
            df_input = pd.read_csv(f, sep=None)
            assert df_input["Label"].nunique() == len(df_input["Label"])


def test_special_characters():
    """
    All Lable columns should not have non-standard characters
    """
    for f in allfiles:
        df_input = pd.read_csv(f, sep=None)
        for item in ["(", ")", " "]:
            assert item not in df_input["Label"]


def test_code_response():
    """
    Same codelist should have same min/max response
    """

    # read question grid file
    qg_file = tables_dir / 'question_grid.csv'
    if Path.exists(qg_file):
        df_qg = pd.read_csv(qg_file, sep=None, engine='python')
    else:
        df_qg = pd.DataFrame(columns = ['Horizontal_Codelist_Name', 'Horizontal_min_responses', 'Horizontal_max_responses',
                                        'Vertical_Codelist_Name', 'Vertical_min_responses', 'Vertical_max_responses'])

    # read question item file
    qi_file = tables_dir / 'question_item.csv'
    if Path.exists(qi_file):
        df_qi = pd.read_csv(qi_file, sep=None, engine='python')
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

    # duplicated row
    df_dup = df_qi_qg_response[df_qi_qg_response.duplicated('Label')]

    assert df_dup.empty, "same code list needs to have same min/max"
