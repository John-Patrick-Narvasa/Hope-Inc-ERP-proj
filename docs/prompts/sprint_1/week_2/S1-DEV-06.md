TASK:        S1-DEV-06
GOAL:        Superadmin: approve pending users and designate admins; block removing or disabling the last remaining superadmin
DUE DAY:     Sprint Day 8
CONTEXT:     <paste relevant DDL/types, existing service/action files, the UI component to connect>
CONSTRAINTS: Layers page->action->service->supabase; requireRight('CODE') in the service; Zod in the action; rpc() for multi-row writes; no float money.
ACCEPTANCE:  <Given/When/Then per role>
OUTPUT:      files changed, code, manual test steps per role, tests for Tester, commit message(s)
ASK FIRST:   <missing table/function? ask the DB Admin, do not invent it>
