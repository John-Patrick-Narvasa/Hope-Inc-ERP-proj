import os
import time
import pandas as pd
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

# --- CONFIGURATION ---
EXCEL_FILE = "sprint_backlog.xlsx"
REPO_OWNER = "John-Patrick-Narvasa"
REPO_NAME = "scrum_3BSCS2"
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")

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

# Setup resilient HTTP session with connection pooling & auto-retries
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

def get_existing_issues():
    """Fetches existing issue titles from GitHub to prevent duplicates on re-run."""
    url = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/issues?state=all&per_page=100"
    existing_titles = set()
    try:
        response = session.get(url, timeout=15)
        if response.status_code == 200:
            for issue in response.json():
                existing_titles.add(issue["title"])
    except Exception as e:
        print(f"[WARNING] Could not fetch existing issues for duplicate check: {e}")
    return existing_titles

def create_github_issue(task_id, title, sprint, week, assignee, existing_titles):
    issue_title = f"[{task_id}] {title}"
    
    # Skip if already exists on GitHub
    if issue_title in existing_titles:
        print(f"[SKIPPED] Already exists: {issue_title}")
        return

    url = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/issues"
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
            print(f"[SUCCESS] Created: {issue_title} -> Assigned to: {github_user or 'Unassigned'}")
        elif response.status_code == 422:
            print(f"[SKIPPED] Validation error / already exists: {issue_title}")
        else:
            print(f"[ERROR] Failed {issue_title} ({response.status_code}): {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"[NETWORK TIMEOUT/ERROR] Failed to push {issue_title}: {e}. Continuing pipeline...")

def main():
    if not GITHUB_TOKEN:
        raise ValueError("Error: GITHUB_TOKEN environment variable is not set. Run '$env:GITHUB_TOKEN=\"your_token\"' first.")

    print(f"Reading tasks from {EXCEL_FILE}...")
    df = pd.read_excel(EXCEL_FILE)
    df = df.sort_values(by=["Sprint", "Week"])

    print("Fetching existing GitHub issues to prevent duplicates...")
    existing_titles = get_existing_issues()
    print(f"Found {len(existing_titles)} existing issues on GitHub.")

    print(f"Found {len(df)} total tasks in Excel. Starting resilient ingestion...")

    for _, row in df.iterrows():
        create_github_issue(
            task_id=row["Task ID"],
            title=row["Task (one PR)"],
            sprint=row["Sprint"],
            week=row["Week"],
            assignee=str(row["Assigned to (name)"]),
            existing_titles=existing_titles
        )
        time.sleep(1.0)  # Gentle 1-second pacing to keep GitHub's gateway happy

    print("\n[DONE] Issue ingestion pipeline completed!")

if __name__ == "__main__":
    main()