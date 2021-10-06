-- heroku psql -a closer-temp < db_temp.sql;

-- sequence;
\qecho 'Temp Sequence';
DROP TABLE temp_sequence;
CREATE TABLE temp_sequence (
  Label varchar,
  Parent_Type varchar,
  Parent_Name varchar,
  Branch int,
  Position int
);
\COPY temp_sequence FROM 'archivist_tables_clean/sequence.csv' DELIMITER E'\t' CSV HEADER;


-- statement;
\qecho 'Temp Statement';
DROP TABLE temp_statement;
CREATE TABLE temp_statement (
  Label varchar,
  Literal varchar,
  Parent_Type varchar,
  Parent_Name varchar,
  Branch int,
  Position int
);
\COPY temp_statement FROM 'archivist_tables_clean/statement.csv' DELIMITER E'\t' CSV HEADER;


-- question_item;
\qecho 'Temp Question Item';
DROP TABLE temp_question_item;
CREATE TABLE temp_question_item (
  Label varchar,
  Literal varchar,
  Instructions varchar,
  Response varchar,
  Parent_Type varchar,
  Parent_Name varchar,
  Branch int,
  Position int,
  min_responses int,
  max_responses int,
  rd_order int,
  Interviewee varchar
);
\COPY temp_question_item FROM 'archivist_tables_clean/question_item.csv' DELIMITER E'\t' CSV HEADER;


-- question_grid;
\qecho 'Temp Question Grid';
DROP TABLE temp_question_grid;
CREATE TABLE temp_question_grid (
  Label varchar,
  Literal varchar,
  Instructions varchar,
  Horizontal_Codelist_Name varchar,
  Vertical_Codelist_Name varchar,
  Response_domain varchar,
  Parent_Type varchar,
  Parent_Name varchar,
  Branch int,
  Position int,
  Horizontal_min_responses int,
  Horizontal_max_responses int,
  Vertical_min_responses int,
  Vertical_max_responses int,
  Interviewee varchar
);
\COPY temp_question_grid FROM 'archivist_tables_clean/question_grid.csv' DELIMITER E'\t' CSV HEADER;


-- response_domain;
\qecho 'Temp Response Domain';
DROP TABLE temp_response;
CREATE TABLE temp_response (
  Label varchar,
  Type varchar,
  Type2 varchar,
  Format varchar,
  Min FLOAT,
  Max FLOAT
);
\COPY temp_response FROM 'archivist_tables_clean/response.csv' DELIMITER E'\t' CSV HEADER;


-- codelist;
\qecho 'Temp Code list';
DROP TABLE temp_codelist;
CREATE TABLE temp_codelist (
  Label varchar,
  Code_Order int,
  Code_Value varchar,
  Category varchar
);
\COPY temp_codelist FROM 'archivist_tables_clean/codelist.csv' DELIMITER E'\t' CSV HEADER;


-- condition;
\qecho 'Temp Condition';
DROP TABLE temp_condition;
CREATE TABLE temp_condition (
  Label varchar,
  Literal varchar,
  Logic varchar,
  Parent_Type varchar,
  Parent_Name varchar,
  Branch int,
  Position int
);
\COPY temp_condition FROM 'archivist_tables_clean/condition.csv' DELIMITER E'\t' CSV HEADER;


-- loop;
\qecho 'Temp Loop';
DROP TABLE temp_loop;
CREATE TABLE temp_loop (
  Label varchar,
  Loop_While varchar,
  Start_Value int,
  End_Value int,
  Variable varchar,
  Parent_Type varchar,
  Parent_Name varchar,
  Branch int,
  Position int
);
\COPY temp_loop FROM 'archivist_tables_clean/loop.csv' DELIMITER E'\t' CSV HEADER;
