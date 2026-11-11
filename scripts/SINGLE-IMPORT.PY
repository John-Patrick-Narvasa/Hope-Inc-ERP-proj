import os
import pandas as pd
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

# --- CONFIGURATION ---
EXCEL_FILE = "sprint_backlog.xlsx"
REPO_OWNER = "John-Patrick-Narvasa"
REPO_NAME = "scrum_3BSCS2"
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")

# Set this to a specific Task ID if you want to push/retry only one task (e.g., "S4-DBA-01")
# Set to None if you want it to process the whole sheet normally.
TARGET_TASK_ID = "S4-DBA-01"

MEMBER_MAPPING = {
    "John Patrick Narvasa": "John-Patrick-Narvasa",
    "Nathaniel Ashley Ellacer": "Nathaniel-Ellacer",
    "Keith Marlou Aldueza": "keithmr14",
    "Ivan Abduhadi": "ivansabduhadi",
    "Scrum Master": "John-Patrick-Narvasa",
    "UI/UX Designer": "Nathaniel-Ellacer",
    "DB Admin": "keithmr14",
    "Developer": "ivansabduhadi",
    "Tester": "ivansabduhadi"
}

# Setup resilient HTTP session
session = requests.Session()
retries = Retry(
    total=5,
    backoff_factor=2,
    status_forcelist=[429, 500, 502, 503, 504],
    raise_on_status=False
)
session.mount("https://", HTTPAdapter(max_retries=retries))
session.headers.update({
    "Authorization": f"Bearer {GITHUB_TOKEN}",
    "Accept": "application/vnd.github+json",
    "X-GitHub-Api-Version": "2022-11-28"
})

def create_github_issue(task_id, title, sprint, week, assignee):
    url = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/issues"
    issue_title = f"[{task_id}] {title}"
    
    github_user = MEMBER_MAPPING.get(assignee, None)
    assignees_list = [github_user] if github_user else []

    payload = {
        "title": issue_title,
        "body": f"### Context\n- **Sprint:** {sprint}\n- **Week:** {week}\n- **Assigned Team Member:** {assignee}",
        "assignees": assignees_list,
        "labels": ["task", f"sprint-{sprint}"]
    }

    try:
        response = session.post(url, json=payload, timeout=20)
        if response.status_code == 201:
            print(f"[SUCCESS] Created target issue: {issue_title} -> Assigned to: {github_user or 'Unassigned'}")
        elif response.status_code == 422:
            print(f"[SKIPPED] Issue already exists on GitHub: {issue_title}")
        else:
            print(f"[ERROR] Failed {issue_title} ({response.status_code}): {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"[NETWORK ERROR] Failed to push {issue_title}: {e}")

def main():
    if not GITHUB_TOKEN:
        raise ValueError("Error: GITHUB_TOKEN environment variable is not set.")

    print(f"Reading tasks from {EXCEL_FILE}...")
    df = pd.read_excel(EXCEL_FILE)

    if TARGET_TASK_ID:
        print(f"Filtering for single target task ID: {TARGET_TASK_ID}")
        df = df[df["Task ID"] == TARGET_TASK_ID]
        if df.empty:
            print(f"[ERROR] Task ID '{TARGET_TASK_ID}' not found in Excel spreadsheet.")
            return

    for _, row in df.iterrows():
        create_github_issue(
            task_id=row["Task ID"],
            title=row["Task (one PR)"],
            sprint=row["Sprint"],
            week=row["Week"],
            assignee=str(row["Assigned to (name)"])
        )

    print("\n[DONE] Target ingestion complete!")

if __name__ == "__main__":
    main()