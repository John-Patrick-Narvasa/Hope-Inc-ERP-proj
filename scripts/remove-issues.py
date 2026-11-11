import subprocess
import json

# Fetch list of issue numbers
result = subprocess.run(
    ["gh", "issue", "list", "--limit", "1000", "--json", "number"],
    capture_output=True,
    text=True,
    shell=True,
)

if result.returncode != 0:
  print("Error fetching issues. Ensure GitHub CLI is authenticated.")
  print(result.stderr)
  exit(1)

issues = json.loads(result.stdout)

if not issues:
  print("No open issues found.")
  exit(0)

# Loop and delete each issue
for issue in issues:
  issue_num = issue["number"]
  print(f"Deleting issue #{issue_num}...")
  subprocess.run(
      ["gh", "issue", "delete", str(issue_num), "--yes"], shell=True
  )

print("All issues deleted successfully!")