TASK:        S1-DBA-06
GOAL:        Make audit_user() record the logged-in user in audit_log; test it
DUE DAY:     Sprint Day 8
CONTEXT:     <paste existing DDL for touched tables, existing helper functions, migration list>
CONSTRAINTS: Additive migration NNN_name.sql; RLS enabled; no DELETE grants; derived data as view/function.
ACCEPTANCE:  <Given/When/Then, including a negative case per role>
OUTPUT:      1) migration SQL 2) pgTAP tests 3) supabase commands to verify 4) risks
ASK FIRST:   <ambiguity>
