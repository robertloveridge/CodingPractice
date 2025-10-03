import requests
import sys
import csv

API_KEY = "pylon_api_key"
BASE_URL = "https://api.usepylon.com/accounts"

headers = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}

def find_account_by_domain(domain):
    """Search accounts via POST /accounts/search using domains filter."""
    url = f"{BASE_URL}/search"
    payload = {
        "filter": {
            "field": "domains",
            "operator": "contains",
            "value": domain
        },
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

def update_account(account_id, new_value):
    """Patch account's phocas_sql_db field"""
    url = f"{BASE_URL}/{account_id}"
    payload = {
        "custom_fields": [
            {
                "slug": "phocas_sql_db",
                "value": new_value
            }
        ]
    }
    resp = requests.patch(url, headers=headers, json=payload)
    if resp.status_code in (200, 201):
        print(f"Updated account {account_id}, set phocas_sql_db = {new_value}")
        return resp.json()
    else:
        print(f"Failed to update account {account_id}: {resp.status_code}, {resp.text}")
        return None

def update_from_csv(csv_file):
    """Process a CSV with columns: domain,new_value"""
    with open(csv_file, newline='', encoding="utf-8") as f:
        reader = csv.DictReader(f)
        if "domain" not in reader.fieldnames or "new_value" not in reader.fieldnames:
            print("CSV must have 'domain' and 'new_value' columns")
            return
        for row in reader:
            domain = row["domain"].strip()
            new_value = row["new_value"].strip()
            if not domain or not new_value:
                continue
            account = find_account_by_domain(domain)
            if account:
                account_id = account["id"]
                print(f"Found account {account_id} for domain {domain}")
                update_account(account_id, new_value)

if __name__ == "__main__":
    if len(sys.argv) == 3:
        # Single domain + value
        domain = sys.argv[1]
        new_value = sys.argv[2]
        account = find_account_by_domain(domain)
        if account:
            account_id = account["id"]
            print(f"Found account {account_id} for domain {domain}")
            update_account(account_id, new_value)
    elif len(sys.argv) == 2:
        # CSV mode
        csv_file = sys.argv[1]
        update_from_csv(csv_file)
    else:
        print("Usage:")
        print("  python update_accounts.py <domain> <new_phocas_sql_db_value>")
        print("  python update_accounts.py accounts.csv # a CSV with 2 columns domain,new_value")
