TASK:        S3-DBA-06
GOAL:        Indexes and backup/restore script
DUE DAY:     Sprint Day 9
CONTEXT:     <paste existing DDL for touched tables, existing helper functions, migration list>
CONSTRAINTS: Additive migration NNN_name.sql; RLS enabled; no DELETE grants; derived data as view/function.
ACCEPTANCE:  <Given/When/Then, including a negative case per role>
OUTPUT:      1) migration SQL 2) pgTAP tests 3) supabase commands to verify 4) risks
ASK FIRST:   <ambiguity>
