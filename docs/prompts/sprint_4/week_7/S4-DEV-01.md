TASK:        S4-DEV-01
GOAL:        Sales list with search
DUE DAY:     Sprint Day 2
CONTEXT:     <paste relevant DDL/types, existing service/action files, the UI component to connect>
CONSTRAINTS: Layers page->action->service->supabase; requireRight('CODE') in the service; Zod in the action; rpc() for multi-row writes; no float money.
ACCEPTANCE:  <Given/When/Then per role>
OUTPUT:      files changed, code, manual test steps per role, tests for Tester, commit message(s)
ASK FIRST:   <missing table/function? ask the DB Admin, do not invent it>
