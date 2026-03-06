#!/usr/bin/env python3
"""
Phase 3 — Giving & Finances: Comprehensive Endpoint Tests
Uses urllib (stdlib) — no external dependencies needed.
"""

import json
import sys
import urllib.request
import urllib.error

BASE = "http://localhost:8080/api/v1"
PASS = 0
FAIL = 0
TOTAL = 0

def make_request(method, path, data=None, headers=None, expect_json=True):
    """Make HTTP request using urllib"""
    url = f"{BASE}{path}"
    body = json.dumps(data).encode('utf-8') if data else None
    req = urllib.request.Request(url, data=body, method=method)
    req.add_header('Content-Type', 'application/json')
    if headers:
        for k, v in headers.items():
            req.add_header(k, v)

    try:
        resp = urllib.request.urlopen(req)
        raw = resp.read()
        status = resp.status
        ct = resp.headers.get('Content-Type', '')
        if expect_json and 'json' in ct:
            return status, json.loads(raw)
        return status, raw
    except urllib.error.HTTPError as e:
        raw = e.read()
        try:
            return e.code, json.loads(raw)
        except:
            return e.code, raw

def test(name, status, data, expected_status=200, check_fn=None):
    global PASS, FAIL, TOTAL
    TOTAL += 1
    try:
        status_ok = status == expected_status
        check_ok = True
        if check_fn and status_ok and isinstance(data, dict):
            check_ok = check_fn(data)

        if status_ok and check_ok:
            PASS += 1
            print(f"  ✅ {name}")
        else:
            FAIL += 1
            reason = f"status={status}" if not status_ok else "check failed"
            print(f"  ❌ {name} ({reason})")
            if not status_ok:
                print(f"     Expected {expected_status}, got {status}")
            if isinstance(data, dict):
                print(f"     Response: {json.dumps(data, indent=2)[:500]}")
    except Exception as e:
        FAIL += 1
        print(f"  ❌ {name} (Exception: {e})")

# ── Login ────────────────────────────────────────────
print("\n🔐 Authentication")
status, data = make_request("POST", "/auth/login", {
    "email": "john@example.com",
    "password": "Member@123"
})
assert status == 200, f"Login failed: {data}"
token = data["data"]["accessToken"]
auth = {"Authorization": f"Bearer {token}"}
print("  ✅ Logged in as john@example.com")

# ══════════════════════════════════════════════════════
# CATEGORIES
# ══════════════════════════════════════════════════════
print("\n📂 Categories")

status, data = make_request("GET", "/giving/categories", headers=auth)
test("GET /giving/categories", status, data, 200, lambda d: len(d["data"]) == 5)

categories = data["data"]
tithe_id = next(c["id"] for c in categories if c["name"] == "Tithe")
offering_id = next(c["id"] for c in categories if c["name"] == "Offering")

# ══════════════════════════════════════════════════════
# GIVING SUMMARY
# ══════════════════════════════════════════════════════
print("\n📊 Giving Summary")

status, data = make_request("GET", "/giving/summary", headers=auth)
test("GET /giving/summary", status, data, 200,
     lambda d: "yearToDate" in d["data"] and "recentDonations" in d["data"])

# ══════════════════════════════════════════════════════
# DONATION HISTORY
# ══════════════════════════════════════════════════════
print("\n📜 Donation History")

status, data = make_request("GET", "/giving/history?page=1&limit=10", headers=auth)
test("GET /giving/history", status, data, 200,
     lambda d: d["meta"]["total"] >= 9 and len(d["data"]) > 0)

status, data = make_request("GET", "/giving/history?page=1&limit=5&status=SUCCESS", headers=auth)
test("GET /giving/history?status=SUCCESS", status, data, 200,
     lambda d: all(item["status"] == "SUCCESS" for item in d["data"]))

# ══════════════════════════════════════════════════════
# RECEIPT DETAIL
# ══════════════════════════════════════════════════════
print("\n🧾 Receipts")

history_status, history_data = make_request("GET", "/giving/history?page=1&limit=1&status=SUCCESS", headers=auth)
donation_id = history_data["data"][0]["id"]

status, data = make_request("GET", f"/giving/receipts/{donation_id}", headers=auth)
test("GET /giving/receipts/:id", status, data, 200,
     lambda d: d["data"]["receiptNumber"] is not None and d["data"]["amount"] > 0)

# Download receipt PDF
status, pdf_data = make_request("GET", f"/giving/receipts/{donation_id}/download", headers=auth, expect_json=False)
is_pdf = isinstance(pdf_data, bytes) and pdf_data[:5] == b'%PDF-'
TOTAL += 1
if status == 200 and is_pdf:
    PASS += 1
    print(f"  ✅ GET /giving/receipts/:id/download (PDF) — {len(pdf_data)} bytes")
else:
    FAIL += 1
    print(f"  ❌ GET /giving/receipts/:id/download (PDF) — status={status}, is_pdf={is_pdf}")

# ══════════════════════════════════════════════════════
# DONATE (New donation)
# ══════════════════════════════════════════════════════
print("\n💰 Donate")

status, data = make_request("POST", "/giving/donate", {
    "amount": 25000,
    "currency": "NGN",
    "categoryId": tithe_id,
    "paymentMethod": "CARD",
    "paymentProvider": "PAYSTACK",
    "note": "Test donation from API"
}, headers=auth)
test("POST /giving/donate", status, data, 201,
     lambda d: d["data"]["donation"]["transactionRef"] is not None and d["data"]["payment"] is not None)

new_donation_ref = data["data"]["donation"]["transactionRef"] if status == 201 else None

# Verify the donation
if new_donation_ref:
    status, data = make_request("POST", "/giving/verify", {
        "reference": new_donation_ref,
        "provider": "PAYSTACK"
    }, headers=auth)
    test("POST /giving/verify", status, data, 200,
         lambda d: d["data"]["status"] == "SUCCESS")

# ══════════════════════════════════════════════════════
# PAYMENT METHODS
# ══════════════════════════════════════════════════════
print("\n💳 Payment Methods")

status, data = make_request("GET", "/giving/payment-methods", headers=auth)
test("GET /giving/payment-methods", status, data, 200,
     lambda d: len(d["data"]) >= 2)

# Add a new payment method
status, data = make_request("POST", "/giving/payment-methods", {
    "type": "CARD",
    "provider": "PAYSTACK",
    "last4": "1234",
    "brand": "Visa",
    "expiryMonth": 3,
    "expiryYear": 2029,
    "isDefault": False,
    "providerToken": "AUTH_test_new_card"
}, headers=auth)
test("POST /giving/payment-methods", status, data, 201,
     lambda d: d["data"]["last4"] == "1234")

new_pm_id = data["data"]["id"] if status == 201 else None

# Delete the new payment method
if new_pm_id:
    status, data = make_request("DELETE", f"/giving/payment-methods/{new_pm_id}", headers=auth)
    test("DELETE /giving/payment-methods/:id", status, data, 200,
         lambda d: d["data"]["deleted"] == True)

# ══════════════════════════════════════════════════════
# CAMPAIGNS
# ══════════════════════════════════════════════════════
print("\n🎯 Campaigns")

status, data = make_request("GET", "/giving/campaigns?page=1&limit=10", headers=auth)
test("GET /giving/campaigns", status, data, 200,
     lambda d: d["meta"]["total"] >= 2)

campaigns_list = data["data"]
campaign_id = campaigns_list[0]["id"]

status, data = make_request("GET", f"/giving/campaigns/{campaign_id}", headers=auth)
test("GET /giving/campaigns/:id", status, data, 200,
     lambda d: d["data"]["title"] is not None and "percentage" in d["data"] and "recentDonors" in d["data"])

# Donate to campaign
status, data = make_request("POST", f"/giving/campaigns/{campaign_id}/donate", {
    "amount": 50000,
    "paymentMethod": "CARD",
    "paymentProvider": "PAYSTACK"
}, headers=auth)
test("POST /giving/campaigns/:id/donate", status, data, 201,
     lambda d: d["data"]["donation"]["transactionRef"] is not None)

# ══════════════════════════════════════════════════════
# PLEDGES
# ══════════════════════════════════════════════════════
print("\n🤝 Pledges")

status, data = make_request("GET", "/giving/pledges?page=1&limit=10", headers=auth)
test("GET /giving/pledges", status, data, 200,
     lambda d: d["meta"]["total"] >= 1)

# Create a new pledge
status, data = make_request("POST", "/giving/pledges", {
    "title": "Test Offering Pledge",
    "totalAmount": 600000,
    "frequency": "MONTHLY",
    "startDate": "2026-03-01",
    "totalPayments": 6
}, headers=auth)
test("POST /giving/pledges", status, data, 201,
     lambda d: d["data"]["title"] == "Test Offering Pledge" and d["data"]["totalAmount"] == 600000)

new_pledge_id = data["data"]["id"] if status == 201 else None

# Make a pledge payment
if new_pledge_id:
    status, data = make_request("POST", f"/giving/pledges/{new_pledge_id}/pay", {
        "amount": 100000
    }, headers=auth)
    test("POST /giving/pledges/:id/pay", status, data, 200,
         lambda d: d["data"]["pledge"]["paidAmount"] == 100000)

# Cancel a pledge
if new_pledge_id:
    status, data = make_request("DELETE", f"/giving/pledges/{new_pledge_id}", headers=auth)
    test("DELETE /giving/pledges/:id (cancel)", status, data, 200,
         lambda d: d["data"]["cancelled"] == True)

# ══════════════════════════════════════════════════════
# RECURRING DONATIONS
# ══════════════════════════════════════════════════════
print("\n🔄 Recurring Donations")

status, data = make_request("GET", "/giving/recurring", headers=auth)
test("GET /giving/recurring", status, data, 200,
     lambda d: len(d["data"]) >= 1)

# Get payment methods for recurring setup
pm_status, pm_data = make_request("GET", "/giving/payment-methods", headers=auth)
default_pm_id = pm_data["data"][0]["id"]

status, data = make_request("POST", "/giving/recurring", {
    "categoryId": offering_id,
    "paymentMethodId": default_pm_id,
    "amount": 10000,
    "frequency": "WEEKLY"
}, headers=auth)
test("POST /giving/recurring", status, data, 201,
     lambda d: d["data"]["amount"] == 10000 and d["data"]["frequency"] == "WEEKLY")

new_recurring_id = data["data"]["id"] if status == 201 else None

# Update recurring
if new_recurring_id:
    status, data = make_request("PUT", f"/giving/recurring/{new_recurring_id}", {
        "amount": 15000,
        "status": "PAUSED"
    }, headers=auth)
    test("PUT /giving/recurring/:id", status, data, 200,
         lambda d: d["data"]["amount"] == 15000 and d["data"]["status"] == "PAUSED")

# Cancel recurring
if new_recurring_id:
    status, data = make_request("DELETE", f"/giving/recurring/{new_recurring_id}", headers=auth)
    test("DELETE /giving/recurring/:id (cancel)", status, data, 200,
         lambda d: d["data"]["cancelled"] == True)

# ══════════════════════════════════════════════════════
# WEBHOOKS
# ══════════════════════════════════════════════════════
print("\n🔔 Webhooks")

status, data = make_request("POST", "/giving/webhooks/paystack", {
    "event": "charge.success",
    "data": {"reference": "non_existent_ref", "id": 12345}
})
test("POST /giving/webhooks/paystack", status, data, 200,
     lambda d: d.get("received") == True)

status, data = make_request("POST", "/giving/webhooks/stripe", {
    "type": "payment_intent.succeeded",
    "data": {"object": {"id": "pi_test", "metadata": {"donationId": "non_existent"}}}
})
test("POST /giving/webhooks/stripe", status, data, 200,
     lambda d: d.get("received") == True)

# ══════════════════════════════════════════════════════
# HOME FEED (verify activeCampaign)
# ══════════════════════════════════════════════════════
print("\n🏠 Home Feed (Phase 3 additions)")

status, data = make_request("GET", "/home/feed", headers=auth)
test("GET /home/feed includes activeCampaign", status, data, 200,
     lambda d: d["data"].get("activeCampaign") is not None and d["data"]["activeCampaign"]["percentage"] >= 0)

# ══════════════════════════════════════════════════════
# RESULTS
# ══════════════════════════════════════════════════════
print(f"\n{'='*50}")
print(f"📊 RESULTS: {PASS}/{TOTAL} passed, {FAIL} failed")
print(f"{'='*50}")

if FAIL > 0:
    sys.exit(1)
else:
    print("🎉 ALL TESTS PASSED!")
    sys.exit(0)
