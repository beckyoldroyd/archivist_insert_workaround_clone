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


