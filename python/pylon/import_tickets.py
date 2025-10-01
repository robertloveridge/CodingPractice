import requests
import random
import csv
import datetime
from datetime import timezone

API_KEY = "pylon_api_key"
BASE_URL = "https://api.usepylon.com/issues"

headers = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}

ASSIGNEES = [
    "fdbe8ccb-2e01-4a21-b50e-0166e62fbe37", #rob
]

REPORTER_EMAIL = "robert.loveridge+reporter@robertloveridge.co.uk"
PRIORITIES = ["low", "medium", "high", "urgent"]
STATES = ["new", "waiting_on_you", "waiting_on_customer", "on_hold", "closed"]

# Date range for created_at
start_date = datetime.datetime(2025, 8, 1, tzinfo=timezone.utc)
end_date = datetime.datetime(2025, 9, 30, 23, 59, 59, tzinfo=timezone.utc)

def random_date(start, end):
    delta = end - start
    total_seconds = int(delta.total_seconds())
    if total_seconds <= 0:
        return start
    random_seconds = random.randrange(total_seconds)
    return start + datetime.timedelta(seconds=random_seconds)

def to_rfc3339(dt):
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    # RFC3339
    return dt.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")

with open("tickets.csv", newline='', encoding="utf-8") as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        assignee_id = random.choice(ASSIGNEES)
        priority = random.choice(PRIORITIES)
        state = random.choice(STATES)

        created_dt = random_date(start_date, end_date)
        created_at = to_rfc3339(created_dt)

        data = {
            "title": row["title"],
            "body_html": row["description"],
            "priority": priority,
            "assignee_id": assignee_id,
            "requester_email": REPORTER_EMAIL,
            "state": state,
            "created_at": created_at
        }

        # If closed, add resolution time
        if state == "closed":
            resolution_dt = random_date(created_dt, end_date)
            resolution_time = to_rfc3339(resolution_dt)
            data["resolution_time"] = resolution_time

        response = requests.post(BASE_URL, headers=headers, json=data)

        if response.status_code in (200, 201):
            issue = response.json().get("data", {})
            issue_id = issue.get("id")
            print(f"Created '{row['title']}' "
                  f"(state: {state}, assignee: {assignee_id}, priority: {priority})")
        else:
            print(f"Failed to create '{row['title']}': {response.status_code}, {response.text}")
