import sys
import csv
import json
import requests

API_KEY = "pylon_api_key"
BASE_URL = "https://api.usepylon.com/accounts"

headers = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}

DRY_RUN = False

# ------------------------
# Helper functions
# ------------------------
def find_account_by_domain(domain):
    """Search accounts via POST /accounts/search using domains filter."""
    url = f"{BASE_URL}/search"
    payload = {
        "filter": {"field": "domains", "operator": "contains", "value": domain},
        "limit": 1
    }
    resp = requests.post(url, headers=headers, json=payload)
    if resp.status_code == 200:
        resp_json = resp.json()
        accounts = resp_json.get("data", [])
        if accounts:
            return accounts[0]
        else:
            print(f"No account found matching domain {domain}")
    else:
        print(f"Search failed: {resp.status_code} {resp.text}")
    return None


def update_account(account_id, custom_fields):
    """PATCH account with a list of custom_fields."""
    if DRY_RUN:
        print(f"[DRY RUN] Would update account {account_id} with fields: {custom_fields}")
        return None

    url = f"{BASE_URL}/{account_id}"
    payload = {"custom_fields": custom_fields}
    resp = requests.patch(url, headers=headers, json=payload)
    if resp.status_code in (200, 201):
        print(f"Updated account {account_id} with {len(custom_fields)} fields")
        return resp.json()
    else:
        print(f"Failed to update account {account_id}: {resp.status_code}, {resp.text}")
        return None


def update_from_csv(csv_file):
    """
    Process a CSV where:
      - 'domain' is required
      - all other columns are custom field slugs with their values
    """
    with open(csv_file, newline='', encoding="utf-8") as f:
        reader = csv.DictReader(f)
        if "domain" not in reader.fieldnames:
            print("CSV must have a 'domain' column")
            return

        for row in reader:
            domain = row.pop("domain").strip()
            if not domain:
                continue

            # Filter out empty cells
            fields = {k: v.strip() for k, v in row.items() if v and v.strip()}
            if not fields:
                continue

            custom_fields = [{"slug": k, "value": v} for k, v in fields.items()]
            account = find_account_by_domain(domain)
            if account:
                account_id = account["id"]
                print(f"Found account {account_id} for domain {domain}")
                update_account(account_id, custom_fields)


# ------------------------
# Main program
# ------------------------
if __name__ == "__main__":
    args = sys.argv[1:]

    if not args:
        print("Usage:")
        print("  python update_accounts.py <domain> '{\"slug\":\"value\", ...}' [--dry-run]")
        print("  python update_accounts.py accounts.csv [--dry-run]")
        sys.exit(1)

    # Handle --dry-run flag
    if "--dry-run" in args:
        DRY_RUN = True
        args.remove("--dry-run")
        print("Running in DRY RUN mode (no API updates will be made)\n")

    # --- Option 1: single domain + JSON payload ---
    if len(args) == 2:
        domain = args[0]
        json_arg = args[1]

        try:
            updates = json.loads(json_arg)
            if not isinstance(updates, dict):
                raise ValueError("The JSON argument must be an object")
        except json.JSONDecodeError as e:
            print(f"Invalid JSON: {e}")
            sys.exit(1)

        custom_fields = [{"slug": k, "value": v} for k, v in updates.items()]
        account = find_account_by_domain(domain)
        if account:
            account_id = account["id"]
            print(f"Found account {account_id} for domain {domain}")
            update_account(account_id, custom_fields)

    # --- Option 2: CSV mode ---
    elif len(args) == 1:
        csv_file = args[0]
        update_from_csv(csv_file)

    else:
        print("Invalid arguments. See usage above.")
