-- heroku psql -a closer-temp < db_drop.sql;

-- sequence;
\qecho 'Drop Temp Sequence';
DROP TABLE temp_sequence;

-- statement;
\qecho 'Drop Temp Statement';
DROP TABLE temp_statement;

-- question_item;
\qecho 'Drop Temp Question Item';
DROP TABLE temp_question_item;

-- question_grid;
\qecho 'Drop Temp Question Grid';
DROP TABLE temp_question_grid;

-- response_domain;
\qecho 'Drop Temp Response Domain';
DROP TABLE temp_response;

-- codelist;
\qecho 'Drop Temp Code list';
DROP TABLE temp_codelist;

-- condition;
\qecho 'Drop Temp Condition';
DROP TABLE temp_condition;

-- loop;
\qecho 'Drop Temp Loop';
DROP TABLE temp_loop;
