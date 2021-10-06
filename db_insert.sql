
-- heroku psql -a closer-temp < db_insert.sql;

-- populate database from temp tables;

-- 1. instruments;
\qecho '1. instruments';
INSERT INTO instruments (agency, version, prefix, Label, study, created_at, updated_at, slug)
(select 'www.closer.ac.uk',
        '1.0',
        a.Label,
        a.Label,
        'Study',
        current_timestamp,
        current_timestamp,
        a.Label
from temp_sequence a
where a.Parent_Name is Null);

-- 2. cc_sequences;
\qecho '2. cc_sequences';
INSERT INTO cc_sequences (instrument_id, created_at, updated_at)
(select id,
        current_timestamp,
        current_timestamp
from instruments i
cross join temp_sequence temp
where i.prefix = temp.Label
and temp.Parent_name is Null);


INSERT INTO cc_sequences (instrument_id, created_at, updated_at, Label, parent_id, parent_type, position, branch)
(select b.id,
        current_timestamp,
        current_timestamp,
        b.prefix,
        a.id,
        'CcSequence',
        1,
        0
from cc_sequences a
left join instruments b on b.id = a.instrument_id
cross join temp_sequence temp
where b.prefix = temp.Label
and temp.Parent_name is Null
and a.Label is null);


INSERT INTO cc_sequences (instrument_id, created_at, updated_at, Label, parent_id, parent_type, position, branch)
(select b.instrument_id,
        current_timestamp,
        current_timestamp,
        a.Label,
        b.id,
        'CcSequence',
        a.position,
        0
from temp_sequence a
cross join cc_sequences b
cross join temp_sequence temp
where b.Label= temp.Label
and temp.Parent_name is Null
and a.Parent_Name = temp.Label
);


INSERT INTO cc_sequences (instrument_id, created_at, updated_at, Label, parent_id, parent_type, position, branch)
(select b.instrument_id,
        current_timestamp,
        current_timestamp,
        a.Label,
        b.id,
        'CcSequence',
        a.position,
        0
from temp_sequence a
cross join cc_sequences b
cross join temp_sequence temp
where b.Label= a.Parent_name
and temp.Parent_name is Null
and a.Parent_Name != temp.Label );

SELECT pg_sleep(2);


-- 3. response_domain_numerics;
\qecho '3. response_domain_numerics';
INSERT INTO response_domain_numerics (numeric_type, Label, min, max, created_at, updated_at, instrument_id, response_domain_type)
(select a.Type2,
        a.Label,
        a.Min,
        a.Max,
        current_timestamp,
        current_timestamp,
        b.id,
        'ResponseDomainNumeric'
from temp_response a
cross join instruments b
cross join temp_sequence temp
where b.prefix = temp.Label
and temp.Parent_name is Null
and a.type = 'Numeric');

SELECT pg_sleep(2);


-- 4. response_domain_texts;
\qecho '4. response_domain_texts';
INSERT INTO response_domain_texts (Label, maxlen, created_at, updated_at, instrument_id, response_domain_type)
(select a.Label,
        a.max,
        current_timestamp,
        current_timestamp,
        b.id,
        'ResponseDomainText'
from temp_response a
cross join instruments b
cross join temp_sequence temp
where b.prefix = temp.Label
and temp.Parent_name is Null
and a.type = 'Text');

SELECT pg_sleep(2);


-- 5.response_domain_datetimes;
\qecho '5. response_domain_datetimes';
INSERT INTO response_domain_datetimes (datetime_type, Label, Format, created_at, updated_at, instrument_id, response_domain_type)
(select a.type2,
        a.Label,
        a.Format,
        current_timestamp,
        current_timestamp,
        b.id,
        'ResponseDomainDatetime'
from temp_response a
cross join instruments b
cross join temp_sequence temp
where b.prefix = temp.Label
and temp.Parent_name is Null
and a.type = 'Date');

SELECT pg_sleep(2);


-- 6. code_lists;
\qecho '6. code_lists';
INSERT INTO code_lists (Label, created_at, updated_at, instrument_id)
(select distinct a.Label,
                 current_timestamp,
                 current_timestamp,
                 b.id
from temp_codelist a
cross join instruments b
cross join temp_sequence temp
where b.prefix = temp.Label
and temp.Parent_name is Null);

SELECT pg_sleep(2);


-- 7. response_domain_codes;
\qecho '7. response_domain_codes';
INSERT INTO response_domain_codes (code_list_id, created_at, updated_at, response_domain_type, instrument_id, min_responses, max_responses)
(select a.id,
        current_timestamp,
        current_timestamp,
        'ResponseDomainCode',
        b.id,
        c.min_responses,
        c.max_responses
from code_lists a
join temp_question_item c on a.Label = c.Response
cross join instruments b
cross join temp_sequence temp
where b.prefix = temp.Label
and temp.Parent_name is Null
union
select a.id,
        current_timestamp,
        current_timestamp,
        'ResponseDomainCode',
        b.id,
        c.Horizontal_min_responses,
        c.Horizontal_max_responses
from code_lists a
join temp_question_grid c on a.Label = c.Response_domain
cross join instruments b
cross join temp_sequence temp
where b.prefix = temp.Label
and temp.Parent_name is Null
union
select a.id,
        current_timestamp,
        current_timestamp,
        'ResponseDomainCode',
        b.id,
        c.Vertical_min_responses,
        c.Vertical_max_responses
from code_lists a
join temp_question_grid c on a.Label = c.Vertical_Codelist_Name
cross join instruments b
cross join temp_sequence temp
where b.prefix = temp.Label
and temp.Parent_name is Null
union
select a.id,
        current_timestamp,
        current_timestamp,
        'ResponseDomainCode',
        b.id,
        1,
        1
from code_lists a
cross join instruments b
cross join temp_sequence temp
where b.prefix = temp.Label
and temp.Parent_name is Null
and a.Label = 'cs_dash');

SELECT pg_sleep(2);


-- 8. categories;
\qecho '8. categories';
INSERT INTO categories (Label, created_at, updated_at, instrument_id)
(select distinct a.category,
        current_timestamp,
        current_timestamp,
        b.id
from temp_codelist a
cross join instruments b
cross join temp_sequence temp
where b.prefix = temp.Label
and temp.Parent_name is Null
and a.category is not null);

SELECT pg_sleep(2);


-- 9. codes;
\qecho '9. codes';
INSERT INTO codes (value, "order", code_list_id, category_id, created_at, updated_at, instrument_id)
(select a.Code_Value as value,
        a.Code_Order as "order",
        b.id as code_lists_id,
        c.id as category_id,
        current_timestamp,
        current_timestamp,
        c.instrument_id
from temp_codelist a
left join code_lists b on a.Label = b.Label and b.instrument_id = (select id from instruments cross join temp_sequence temp
where instruments.prefix = temp.Label
and temp.Parent_name is Null)
left join categories c on a.category = c.Label and c.instrument_id = (select id from instruments cross join temp_sequence temp
where instruments.prefix = temp.Label
and temp.Parent_name is Null)
where c.id is not null);

SELECT pg_sleep(2);


-- 10. cc_conditions;
\qecho '10. cc_conditions';
INSERT INTO cc_conditions (instrument_id, Label, literal, logic, parent_id, parent_type, position, branch, created_at, updated_at)
(select b.id,
        a.Label,
        a.Literal,
        a.Logic,
        d.id,
        a.Parent_type,
        a.Position,
        a.Branch,
        current_timestamp,
        current_timestamp
from temp_condition a
cross join instruments b
left join cc_sequences d on a.Parent_name = d.Label and d.instrument_id = b.id
cross join temp_sequence temp
where b.prefix = temp.Label
and temp.Parent_name is Null);

SELECT pg_sleep(2);


-- 11. cc_loops;
\qecho '11. cc_loops';
INSERT INTO cc_loops (Label, start_val, end_val, loop_while, loop_var, parent_type, branch, position, created_at, updated_at, instrument_id)
(select a.Label,
        a.Start_Value,
        a.End_Value,
        a.Loop_While,
        a.Variable,
        a.Parent_type,
        a.Branch,
        a.Position,
        current_timestamp,
        current_timestamp,
        b.id
from temp_loop a
cross join instruments b
cross join temp_sequence temp
where b.prefix = temp.Label
and temp.Parent_name is Null);

SELECT pg_sleep(2);


-- 12. instructions;
\qecho '12. instructions';
INSERT INTO instructions (text, created_at, updated_at, instrument_id)
(select distinct a.instructions,
        current_timestamp,
        current_timestamp,
        b.id
from temp_question_item a
cross join instruments b
cross join temp_sequence temp
where b.prefix = temp.Label
and temp.Parent_name is Null
and a.instructions is not null);

INSERT INTO instructions (text, created_at, updated_at, instrument_id)
(select distinct a.instructions,
        current_timestamp,
        current_timestamp,
        b.id
from temp_question_grid a
cross join instruments b
cross join temp_sequence temp
where b.prefix = temp.Label
and temp.Parent_name is Null
and a.instructions is not null);

SELECT pg_sleep(2);


-- 13. question_items;
\qecho '13. question_items';
INSERT INTO question_items (Label, literal, instruction_id, created_at, updated_at, instrument_id, question_type)
(select a.Label,
        a.Literal,
        b.id,
        current_timestamp,
        current_timestamp,
        c.id,
        'QuestionItem'
from temp_question_item a
cross join instruments c
left join instructions b on a.instructions = b.text and b.instrument_id = c.id
cross join temp_sequence temp
where a.rd_order = 1
and c.prefix = temp.Label
and temp.Parent_name is Null);

SELECT pg_sleep(2);


-- 14. question_grids;
\qecho '14. question_grids';
INSERT INTO question_grids (label, literal, instruction_id, horizontal_code_list_id, vertical_code_list_id, created_at, updated_at, instrument_id, question_type)
(select a.Label,
        a.Literal,
        b.id,
        h.id,
        v.id,
        current_timestamp,
        current_timestamp,
        c.id,
        'QuestionGrid'
from temp_question_grid a
cross join instruments c
left join instructions b on a.instructions = b.text and b.instrument_id = c.id
left join code_lists h on h.label = 'cs_dash'
left join code_lists v on a.vertical_codelist_name = v.label
cross join temp_sequence temp
where c.prefix = temp.Label
and temp.Parent_name is Null
and h.id is not null
and v.id is not null);

SELECT pg_sleep(2);


-- 15. cc_questions;
\qecho '15. cc_questions';
INSERT INTO response_units (Label, created_at, updated_at, instrument_id)
(select distinct
       a.Interviewee,
       current_timestamp,
       current_timestamp,
       c.id
from (select distinct Interviewee from temp_question_item
      UNION
      select distinct Interviewee from temp_question_grid) a
cross join instruments c
cross join temp_sequence temp
where c.prefix = temp.Label
and temp.Parent_name is Null);select a.id,
        current_timestamp,
        current_timestamp,
        'ResponseDomainCode',
        b.id,
        c.min_responses,
        c.max_responses
from code_lists a
join temp_question_item c on a.Label = c.Response
cross join instruments b
cross join temp_sequence temp
where b.prefix = temp.Label
and temp.Parent_name is Null);

SELECT pg_sleep(2);


INSERT INTO cc_questions (instrument_id, question_id, question_type, response_unit_id, created_at, updated_at, Label, parent_id, parent_type, position, branch)
(select c.id,
        b.id as question_id,
        'QuestionItem',
        d.id,
        current_timestamp,
        current_timestamp,
        replace(a.Label, 'qi_', 'qc_'),
        f.id,
        a.Parent_Type,
        a.Position,
        a.Branch
from temp_question_item a
cross join instruments c
left join question_items b on a.Label = b.Label and b.instrument_id = c.id
left join response_units d on c.id = d.instrument_id and d.Label = a.Interviewee
join cc_sequences f on a.Parent_Name = f.Label and f.instrument_id = c.id
cross join temp_sequence temp
where c.prefix = temp.Label
and temp.Parent_name is Null
UNION
select c.id,
       b.id as question_id,
       'QuestionItem',
       d.id,
       current_timestamp,
       current_timestamp,
       replace(a.Label, 'qi_', 'qc_'),
       g.id,
       a.Parent_Type,
       a.Position,
       a.Branch
from temp_question_item a
cross join instruments c
left join question_items b on a.Label = b.Label and b.instrument_id = c.id
left join response_units d on c.id = d.instrument_id and d.Label = a.Interviewee
join cc_conditions g on a.Parent_Name = g.Label and g.instrument_id = c.id
cross join temp_sequence temp
where c.prefix = temp.Label
and temp.Parent_name is Null
UNION
select c.id,
       b.id as question_id,
       'QuestionItem',
       d.id,
       current_timestamp,
       current_timestamp,
       replace(a.Label, 'qi_', 'qc_'),
       h.id,
       a.Parent_Type,
       a.Position,
       a.Branch
from temp_question_item a
cross join instruments c
left join question_items b on a.Label = b.Label and b.instrument_id = c.id
left join response_units d on c.id = d.instrument_id and d.Label = a.Interviewee
join cc_loops h on a.Parent_Name = h.Label and h.instrument_id = c.id
cross join temp_sequence temp
where c.prefix = temp.Label
and temp.Parent_name is Null);

SELECT pg_sleep(2);


INSERT INTO cc_questions (instrument_id, question_id, question_type, response_unit_id, created_at, updated_at, label, parent_id, parent_type, position, branch)
(select c.id,
b.id as question_id,
'QuestionGrid',
d.id,
current_timestamp,
current_timestamp,
replace(a.label, 'qg_', 'qc_'),
f.id,
a.parent_type,
a.position,
a.branch
from temp_question_grid a
cross join instruments c
left join question_grids b on a.label = b.label and b.instrument_id = c.id
left join response_units d on c.id = d.instrument_id and d.Label = a.Interviewee
join cc_sequences f on a.Parent_Name = f.label and f.instrument_id = c.id
cross join temp_sequence temp
where c.prefix = temp.Label
and temp.Parent_name is Null
and b.id is not null
UNION
select c.id,
b.id as question_id,
'QuestionGrid',
d.id,
current_timestamp,
current_timestamp,
replace(a.label, 'qg_', 'qc_'),
g.id,
a.parent_type,
a.position,
a.branch
from temp_question_grid a
cross join instruments c
left join question_grids b on a.label = b.label and b.instrument_id = c.id
left join response_units d on c.id = d.instrument_id and d.Label = a.Interviewee
join cc_conditions g on a.Parent_Name = g.label and g.instrument_id = c.id
cross join temp_sequence temp
where c.prefix = temp.Label
and temp.Parent_name is Null
and b.id is not null
UNION
select c.id,
b.id as question_id,
'QuestionGrid',
d.id,
current_timestamp,
current_timestamp,
replace(a.label, 'qg_', 'qc_'),
h.id,
a.parent_type,
a.position,
a.branch
from temp_question_grid a
cross join instruments c
left join question_grids b on a.label = b.label and b.instrument_id = c.id
left join response_units d on c.id = d.instrument_id and d.Label = a.Interviewee
join cc_loops h on a.Parent_Name = h.label and h.instrument_id = c.id
cross join temp_sequence temp
where c.prefix = temp.Label
and temp.Parent_name is Null
and b.id is not null
);

SELECT pg_sleep(2);

-- 16. rds_qs
\qecho '16. rds_qs';
INSERT INTO rds_qs (instrument_id, question_id, question_type, code_id, response_domain_id, response_domain_type, created_at, updated_at, rd_order)
(
select ccq.instrument_id, ccq.question_id, ccq.question_type, f.id, b.id, b.response_domain_type, current_timestamp, current_timestamp, a.rd_order
from temp_question_item a
cross join instruments
join cc_questions ccq on replace(a.Label, 'qi_', 'qc_') = ccq.Label and ccq.instrument_id = instruments.id
join code_lists f on a.Response = f.Label and f.instrument_id = instruments.id
join response_domain_codes b on f.id = b.code_list_id and b.instrument_id = instruments.id
cross join temp_sequence temp
where instruments.prefix = temp.Label
and temp.Parent_name is Null
union
select ccq.instrument_id, ccq.question_id, ccq.question_type, null, c.id, c.response_domain_type, current_timestamp, current_timestamp, a.rd_order
from temp_question_item a
cross join instruments
join cc_questions ccq on replace(a.Label, 'qi_', 'qc_') = ccq.Label and ccq.instrument_id = instruments.id
join response_domain_datetimes c on a.response = c.Label and c.instrument_id = instruments.id
cross join temp_sequence temp
where instruments.prefix = temp.Label
and temp.Parent_name is Null
union
select ccq.instrument_id, ccq.question_id, ccq.question_type, null, d.id, d.response_domain_type, current_timestamp, current_timestamp, a.rd_order
from temp_question_item a
cross join instruments
join cc_questions ccq on replace(a.Label, 'qi_', 'qc_') = ccq.Label and ccq.instrument_id = instruments.id
join response_domain_numerics d on a.response = d.Label and d.instrument_id = instruments.id
cross join temp_sequence temp
where instruments.prefix = temp.Label
and temp.Parent_name is Null
union
select ccq.instrument_id, ccq.question_id, ccq.question_type, null, e.id, e.response_domain_type, current_timestamp, current_timestamp, a.rd_order
from temp_question_item a
cross join instruments
join cc_questions ccq on replace(a.Label, 'qi_', 'qc_') = ccq.Label and ccq.instrument_id = instruments.id
join response_domain_texts e on a.response = e.Label and e.instrument_id = instruments.id
cross join temp_sequence temp
where instruments.prefix = temp.Label
and temp.Parent_name is Null
);

SELECT pg_sleep(2);

INSERT INTO rds_qs (instrument_id, question_id, question_type, code_id, response_domain_id, response_domain_type, created_at, updated_at, rd_order)
(
select ccq.instrument_id, ccq.question_id, ccq.question_type, h.id, b.id, b.response_domain_type, current_timestamp, current_timestamp, 1
from temp_question_grid a
cross join instruments
join cc_questions ccq on replace(a.label, 'qg_', 'qc_') = ccq.label and ccq.instrument_id = instruments.id
join code_lists h on a.response_domain = h.label and h.instrument_id = instruments.id
join response_domain_codes b on h.id = b.code_list_id and b.instrument_id = instruments.id
cross join temp_sequence temp
where instruments.prefix = temp.Label
and temp.Parent_name is Null);


-- 17. cc_statements;
\qecho '17. cc_statements';
INSERT INTO cc_statements (label, literal, position, branch, parent_id, parent_type, created_at, updated_at, instrument_id)
(select distinct a.Label,
                 a.Literal,
                 a.Position,
                 a.Branch,
                 d.id,
                 a.Parent_Type,
                 current_timestamp,
                 current_timestamp,
                 c.id
from temp_statement a
cross join instruments c
join cc_sequences d on a.Parent_Name = d.Label and d.instrument_id = c.id
cross join temp_sequence temp
where c.prefix = temp.Label
and temp.Parent_name is Null
union
select distinct a.Label,
                 a.Literal,
                 a.Position,
                 a.Branch,
                 g.id,
                 a.Parent_Type,
                 current_timestamp,
                 current_timestamp,
                 c.id
from temp_statement a
cross join instruments c
join cc_conditions g on a.Parent_Name = g.label and g.instrument_id = c.id
cross join temp_sequence temp
where c.prefix = temp.Label
and temp.Parent_name is Null);

SELECT pg_sleep(2);


-- 18. update parent_id for cc_loops, cc_conditions;
\qecho '18. update parent_id for cc_loops, cc_conditions';
with t as (
    select old.id as row_id,
           COALESCE(s.id, c.id, l.id) as parent_id,
           a.Parent_Type as parent_type,
           a.Position as position,
           current_timestamp as updated_at
    from cc_loops old
    join temp_loop a on a.Label = old.Label
    cross join instruments b
    left join cc_sequences s on a.Parent_Name = s.Label and s.instrument_id = b.id
    left join cc_conditions c on a.Parent_Name = c.Label and c.instrument_id = b.id
    left join cc_loops l on a.Parent_Name = l.Label and l.instrument_id = b.id
    cross join temp_sequence temp
    where b.prefix = temp.Label
    and temp.Parent_name is Null
)
update cc_loops
set parent_id = t.parent_id,
    parent_type = t.parent_type,
    position = t.position,
    updated_at = t.updated_at
from t
where id = t.row_id;


with t as (
    select old.id as row_id,
           COALESCE(s.id, c.id, l.id) as parent_id,
           a.parent_type as parent_type,
           a.position as position,
           current_timestamp as updated_at
    from cc_conditions old
    join temp_condition a on a.Label = old.Label
    cross join instruments b
    left join cc_sequences s on a.Parent_Name = s.Label and s.instrument_id = b.id
    left join cc_conditions c on a.Parent_Name = c.Label and c.instrument_id = b.id
    left join cc_loops l on a.Parent_Name = l.Label and l.instrument_id = b.id
    cross join temp_sequence temp
    where b.prefix = temp.Label
    and temp.Parent_name is Null
)
update cc_conditions
set parent_id = t.parent_id,
    parent_type = t.parent_type,
    position = t.position,
    updated_at = t.updated_at
from t
where id = t.row_id;


