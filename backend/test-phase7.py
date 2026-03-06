#!/usr/bin/env python3
"""
Phase 7 — Polish, Jobs & Testing  (test-phase7.py)
Comprehensive endpoint tests using only stdlib (urllib).

Endpoints tested: 18
  Attendance:    5  (record, get-history, get-streak, delete, get-stats)
  Milestones:    4  (list, summary, create, delete)
  Saved Items:   4  (save, list, check, remove)
  Users Profile: 5  (attendance, milestones, saved-items, add-saved, remove-saved)
"""

import json, sys, urllib.request, urllib.error, urllib.parse, subprocess, time

BASE = "http://localhost:8080/api/v1"
passed = 0
failed = 0
total  = 0

# ── Flush Redis rate-limit keys before running ───────
print("🧹 Flushing Redis rate-limit keys…")
subprocess.run(
    'redis-cli KEYS "rl:*" | xargs redis-cli DEL',
    shell=True, capture_output=True,
)
time.sleep(0.3)

# ── Helpers ──────────────────────────────────────────
def make_request(method, path, data=None, headers=None, expect_json=True):
    url = f"{BASE}{path}"
    body = json.dumps(data).encode() if data else None
    hdrs = headers or {}
    if data and "Content-Type" not in hdrs:
        hdrs["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=body, headers=hdrs, method=method)
    try:
        with urllib.request.urlopen(req) as resp:
            raw = resp.read().decode()
            return resp.status, json.loads(raw) if expect_json else raw
    except urllib.error.HTTPError as e:
        raw = e.read().decode()
        try:
            return e.code, json.loads(raw)
        except Exception:
            return e.code, raw

def test(name, method, path, data=None, expected_status=200, check_fn=None, headers=None):
    global passed, failed, total
    total += 1
    status, body = make_request(method, path, data, headers)
    ok = status == expected_status
    if ok and check_fn:
        try:
            check_fn(body)
        except AssertionError as e:
            ok = False
            print(f"  ❌  #{total} {name}  →  check failed: {e}")
        except Exception as e:
            ok = False
            print(f"  ❌  #{total} {name}  →  exception: {e}")
    if ok:
        passed += 1
        print(f"  ✅  #{total} {name}")
    else:
        failed += 1
        if not (not ok and check_fn):
            print(f"  ❌  #{total} {name}  →  expected {expected_status}, got {status}")
            if isinstance(body, dict):
                print(f"       {json.dumps(body, indent=2)[:300]}")
    return body

class AssertionError(Exception):
    pass

def check(cond, msg=""):
    if not cond:
        raise AssertionError(msg)

# ── Auth ──────────────────────────────────────────────
print("\n🔑 Authenticating…")
_, login_resp = make_request("POST", "/auth/login", {
    "email": "john@example.com", "password": "Member@123"
})
TOKEN = login_resp["data"]["accessToken"]
USER_ID = login_resp["data"]["user"]["id"]
AUTH = {"Authorization": f"Bearer {TOKEN}"}

_, admin_resp = make_request("POST", "/auth/login", {
    "email": "admin@gracecommunity.app", "password": "Admin@123"
})
ADMIN_TOKEN = admin_resp["data"]["accessToken"]
ADMIN_ID = admin_resp["data"]["user"]["id"]
ADMIN_AUTH = {"Authorization": f"Bearer {ADMIN_TOKEN}"}

print(f"   Member  : {USER_ID}")
print(f"   Admin   : {ADMIN_ID}")

# Track IDs for cleanup/reference
ATTENDANCE_ID = None
ATTENDANCE_ID_2 = None
MILESTONE_ID = None
MILESTONE_ID_2 = None
SAVED_ITEM_ID = None

# ══════════════════════════════════════════════════════
#  ATTENDANCE  (5 endpoints)
# ══════════════════════════════════════════════════════
print("\n📋 ATTENDANCE")

# 1. Record attendance (field is `serviceDate`)
body = test(
    "Record attendance",
    "POST", "/attendance",
    data={
        "serviceDate": "2025-01-15",
        "serviceType": "SUNDAY",
        "checkinMethod": "MANUAL",
        "notes": "Phase 7 test attendance",
    },
    expected_status=201,
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"], "response not successful"),
        check(b["data"]["serviceType"] == "SUNDAY", "serviceType mismatch"),
        check(b["data"]["checkinMethod"] == "MANUAL", "checkinMethod mismatch"),
    ),
)
if body and body.get("data"):
    ATTENDANCE_ID = body["data"]["id"]

# 2. Record attendance — duplicate should fail 409
test(
    "Record attendance (duplicate → 409)",
    "POST", "/attendance",
    data={
        "serviceDate": "2025-01-15",
        "serviceType": "SUNDAY",
        "checkinMethod": "MANUAL",
    },
    expected_status=409,
    headers=AUTH,
)

# 3. Record second attendance (different date for history)
body2 = test(
    "Record second attendance (different date)",
    "POST", "/attendance",
    data={
        "serviceDate": "2025-01-22",
        "serviceType": "MIDWEEK",
        "checkinMethod": "QR",
    },
    expected_status=201,
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check(b["data"]["serviceType"] == "MIDWEEK"),
    ),
)
if body2 and body2.get("data"):
    ATTENDANCE_ID_2 = body2["data"]["id"]

# 4. Get attendance history → {attendances: [...], pagination: {...}}
test(
    "Get attendance history",
    "GET", "/attendance",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check("attendances" in b["data"], "data should have attendances key"),
        check(isinstance(b["data"]["attendances"], list), "attendances should be list"),
        check(len(b["data"]["attendances"]) >= 2, "should have at least 2 records"),
        check("pagination" in b["data"], "should have pagination"),
    ),
)

# 5. Get attendance history with serviceType filter
test(
    "Get attendance history (serviceType filter)",
    "GET", "/attendance?serviceType=SUNDAY",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check(isinstance(b["data"]["attendances"], list)),
        check(all(r["serviceType"] == "SUNDAY" for r in b["data"]["attendances"]), "all should be SUNDAY"),
    ),
)

# 6. Get attendance history with date range
test(
    "Get attendance history (date range)",
    "GET", "/attendance?startDate=2025-01-01&endDate=2025-01-20",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check(isinstance(b["data"]["attendances"], list)),
    ),
)

# 7. Get attendance history with pagination
test(
    "Get attendance history (pagination)",
    "GET", "/attendance?page=1&limit=1",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check(isinstance(b["data"]["attendances"], list)),
        check(len(b["data"]["attendances"]) <= 1, "should respect limit"),
        check(b["data"]["pagination"]["limit"] == 1),
    ),
)

# 8. Get attendance streak → {currentStreak, totalAttendances}
test(
    "Get attendance streak",
    "GET", "/attendance/streak",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check("currentStreak" in b["data"], "should have currentStreak"),
        check("totalAttendances" in b["data"], "should have totalAttendances"),
        check(isinstance(b["data"]["currentStreak"], int)),
        check(isinstance(b["data"]["totalAttendances"], int)),
        check(b["data"]["totalAttendances"] >= 2, "should have at least 2 total"),
    ),
)

# 9. Get attendance stats (admin only)
test(
    "Get attendance stats (admin)",
    "GET", "/attendance/stats",
    headers=ADMIN_AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check(isinstance(b["data"], dict), "stats should be a dict"),
    ),
)

# 10. Get attendance stats (member → 403)
test(
    "Get attendance stats (member → 403)",
    "GET", "/attendance/stats",
    expected_status=403,
    headers=AUTH,
)

# 11. Delete attendance
if ATTENDANCE_ID_2:
    test(
        "Delete attendance record",
        "DELETE", f"/attendance/{ATTENDANCE_ID_2}",
        headers=AUTH,
        check_fn=lambda b: check(b["success"]),
    )

# 12. Delete attendance — non-existent → 404
test(
    "Delete attendance (not found → 404)",
    "DELETE", "/attendance/00000000-0000-0000-0000-000000000000",
    expected_status=404,
    headers=AUTH,
)

# 13. Attendance without auth → 401
test(
    "Record attendance without auth → 401",
    "POST", "/attendance",
    data={"serviceDate": "2025-02-01", "serviceType": "SUNDAY"},
    expected_status=401,
)

# ══════════════════════════════════════════════════════
#  MILESTONES  (4 endpoints)
# ══════════════════════════════════════════════════════
print("\n🏅 MILESTONES")

# 14. Create milestone (admin)
body = test(
    "Create milestone (admin)",
    "POST", "/milestones",
    data={
        "userId": USER_ID,
        "type": "BAPTISM",
        "title": "Baptism Day",
        "description": "Baptized in the Holy Spirit!",
        "earnedAt": "2025-01-20T10:00:00.000Z",
    },
    expected_status=201,
    headers=ADMIN_AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check(b["data"]["type"] == "BAPTISM", "type should be BAPTISM"),
        check(b["data"]["title"] == "Baptism Day"),
        check(b["data"]["userId"] == USER_ID),
    ),
)
if body and body.get("data"):
    MILESTONE_ID = body["data"]["id"]

# 15. Create milestone — duplicate type → 409
test(
    "Create milestone (duplicate type → 409)",
    "POST", "/milestones",
    data={
        "userId": USER_ID,
        "type": "BAPTISM",
        "title": "Second Baptism",
    },
    expected_status=409,
    headers=ADMIN_AUTH,
)

# 16. Create milestone (member → 403)
test(
    "Create milestone (member → 403)",
    "POST", "/milestones",
    data={
        "userId": USER_ID,
        "type": "SALVATION",
        "title": "Salvation",
    },
    expected_status=403,
    headers=AUTH,
)

# 17. Create second milestone for listing
body_m2 = test(
    "Create second milestone (admin)",
    "POST", "/milestones",
    data={
        "userId": USER_ID,
        "type": "SALVATION",
        "title": "Day of Salvation",
        "description": "Accepted Christ",
    },
    expected_status=201,
    headers=ADMIN_AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check(b["data"]["type"] == "SALVATION"),
    ),
)
if body_m2 and body_m2.get("data"):
    MILESTONE_ID_2 = body_m2["data"]["id"]

# 18. List milestones → {milestones: [...], pagination: {...}}
test(
    "List milestones",
    "GET", "/milestones",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check("milestones" in b["data"], "data should have milestones key"),
        check(isinstance(b["data"]["milestones"], list)),
        check(len(b["data"]["milestones"]) >= 2, "should have at least 2 milestones"),
    ),
)

# 19. List milestones with type filter
test(
    "List milestones (filter by type)",
    "GET", "/milestones?type=BAPTISM",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check(isinstance(b["data"]["milestones"], list)),
        check(all(m["type"] == "BAPTISM" for m in b["data"]["milestones"]), "all should be BAPTISM"),
    ),
)

# 20. Get milestone summary
test(
    "Get milestone summary",
    "GET", "/milestones/summary",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check(b["data"] is not None, "should have data"),
    ),
)

# 21. Delete milestone (admin)
if MILESTONE_ID_2:
    test(
        "Delete milestone (admin)",
        "DELETE", f"/milestones/{MILESTONE_ID_2}",
        headers=ADMIN_AUTH,
        check_fn=lambda b: check(b["success"]),
    )

# 22. Delete milestone (member → 403)
if MILESTONE_ID:
    test(
        "Delete milestone (member → 403)",
        "DELETE", f"/milestones/{MILESTONE_ID}",
        expected_status=403,
        headers=AUTH,
    )

# 23. Milestones without auth → 401
test(
    "List milestones without auth → 401",
    "GET", "/milestones",
    expected_status=401,
)

# ══════════════════════════════════════════════════════
#  SAVED ITEMS  (4 endpoints)
# ══════════════════════════════════════════════════════
print("\n💾 SAVED ITEMS")

# We need a real sermon ID to save. Fetch one.
_, sermons_resp = make_request("GET", "/sermons?limit=1", headers=AUTH)
SERMON_ID = None
if sermons_resp and sermons_resp.get("data"):
    sd = sermons_resp["data"]
    if isinstance(sd, list) and len(sd) > 0:
        SERMON_ID = sd[0]["id"]
    elif isinstance(sd, dict):
        for k in ["sermons", "items", "data"]:
            if k in sd and len(sd[k]) > 0:
                SERMON_ID = sd[k][0]["id"]
                break
print(f"   Sermon to save: {SERMON_ID}")

# 24. Save an item (sermon)
if SERMON_ID:
    body = test(
        "Save item (sermon)",
        "POST", "/saved-items",
        data={"entityType": "SERMON", "entityId": SERMON_ID},
        expected_status=201,
        headers=AUTH,
        check_fn=lambda b: (
            check(b["success"]),
            check(b["data"]["entityType"] == "SERMON"),
            check(b["data"]["entityId"] == SERMON_ID),
        ),
    )
    if body and body.get("data"):
        SAVED_ITEM_ID = body["data"]["id"]

# 25. Save item — duplicate → 409
if SERMON_ID:
    test(
        "Save item (duplicate → 409)",
        "POST", "/saved-items",
        data={"entityType": "SERMON", "entityId": SERMON_ID},
        expected_status=409,
        headers=AUTH,
    )

# 26. Save item — invalid entity → 404
test(
    "Save item (entity not found → 404)",
    "POST", "/saved-items",
    data={"entityType": "SERMON", "entityId": "00000000-0000-0000-0000-000000000000"},
    expected_status=404,
    headers=AUTH,
)

# 27. Save item — invalid entity type → 400
test(
    "Save item (bad entity type → 400)",
    "POST", "/saved-items",
    data={"entityType": "INVALID_TYPE", "entityId": "00000000-0000-0000-0000-000000000000"},
    expected_status=400,
    headers=AUTH,
)

# 28. List saved items
test(
    "List saved items",
    "GET", "/saved-items",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check(b["data"] is not None, "should have data"),
    ),
)

# 29. List saved items with entityType filter
test(
    "List saved items (filter by SERMON)",
    "GET", "/saved-items?entityType=SERMON",
    headers=AUTH,
    check_fn=lambda b: check(b["success"]),
)

# 30. Check if item is saved → {saved: true/false}
if SERMON_ID:
    test(
        "Check if item is saved (yes)",
        "GET", f"/saved-items/check?entityType=SERMON&entityId={SERMON_ID}",
        headers=AUTH,
        check_fn=lambda b: (
            check(b["success"]),
            check(b["data"]["saved"] == True, "should be saved"),
        ),
    )

# 31. Check if item is NOT saved
test(
    "Check if item is saved (no)",
    "GET", "/saved-items/check?entityType=SERMON&entityId=00000000-0000-0000-0000-000000000000",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check(b["data"]["saved"] == False, "should not be saved"),
    ),
)

# 32. Remove saved item
if SAVED_ITEM_ID:
    test(
        "Remove saved item",
        "DELETE", f"/saved-items/{SAVED_ITEM_ID}",
        headers=AUTH,
        check_fn=lambda b: check(b["success"]),
    )
    SAVED_ITEM_ID = None  # Already cleaned up

# 33. Remove saved item — not found → 404
test(
    "Remove saved item (not found → 404)",
    "DELETE", "/saved-items/00000000-0000-0000-0000-000000000000",
    expected_status=404,
    headers=AUTH,
)

# 34. Saved items without auth → 401
test(
    "List saved items without auth → 401",
    "GET", "/saved-items",
    expected_status=401,
)

# ══════════════════════════════════════════════════════
#  USER PROFILE SUB-DATA  (5 endpoints)
# ══════════════════════════════════════════════════════
print("\n👤 USER PROFILE SUB-DATA")

# 35. Get user's attendance → {attendances, pagination, streak, totalAttendances}
test(
    "Get user attendance via profile",
    "GET", "/users/me/attendance",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check("attendances" in b["data"], "should have attendances key"),
        check(isinstance(b["data"]["attendances"], list), "attendances should be list"),
    ),
)

# 36. Get user's milestones → milestone summary
test(
    "Get user milestones via profile",
    "GET", "/users/me/milestones",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check(b["data"] is not None, "should have data"),
    ),
)

# 37. Get user's saved items
test(
    "Get user saved items via profile",
    "GET", "/users/me/saved-items",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check(b["data"] is not None, "should have data"),
    ),
)

# 38. Add saved item via user profile
if SERMON_ID:
    body = test(
        "Add saved item via user profile",
        "POST", "/users/me/saved-items",
        data={"itemType": "SERMON", "itemId": SERMON_ID},
        expected_status=201,
        headers=AUTH,
        check_fn=lambda b: (
            check(b["success"]),
            check(b["data"]["entityType"] == "SERMON"),
        ),
    )
    PROFILE_SAVED_ID = body["data"]["id"] if body and body.get("data") else None

    # 39. Remove saved item via user profile
    if PROFILE_SAVED_ID:
        test(
            "Remove saved item via user profile",
            "DELETE", f"/users/me/saved-items/{PROFILE_SAVED_ID}",
            headers=AUTH,
            check_fn=lambda b: check(b["success"]),
        )

# ══════════════════════════════════════════════════════
#  VALIDATION TESTS
# ══════════════════════════════════════════════════════
print("\n🔒 VALIDATION")

# 40. Record attendance — missing serviceDate → 400
test(
    "Record attendance (missing serviceDate → 400)",
    "POST", "/attendance",
    data={"serviceType": "SUNDAY"},
    expected_status=400,
    headers=AUTH,
)

# 41. Record attendance — invalid serviceType → 400
test(
    "Record attendance (invalid serviceType → 400)",
    "POST", "/attendance",
    data={"serviceDate": "2025-03-01", "serviceType": "INVALID"},
    expected_status=400,
    headers=AUTH,
)

# 42. Create milestone — missing required fields → 400
test(
    "Create milestone (missing fields → 400)",
    "POST", "/milestones",
    data={"type": "SALVATION"},
    expected_status=400,
    headers=ADMIN_AUTH,
)

# 43. Create milestone — invalid type → 400
test(
    "Create milestone (invalid type → 400)",
    "POST", "/milestones",
    data={"userId": USER_ID, "type": "INVALID", "title": "Test"},
    expected_status=400,
    headers=ADMIN_AUTH,
)

# 44. Save item — missing entityId → 400
test(
    "Save item (missing entityId → 400)",
    "POST", "/saved-items",
    data={"entityType": "SERMON"},
    expected_status=400,
    headers=AUTH,
)

# ══════════════════════════════════════════════════════
#  CLEANUP — remove remaining test data
# ══════════════════════════════════════════════════════
print("\n🧹 CLEANUP")

if ATTENDANCE_ID:
    test(
        "Cleanup: delete first attendance",
        "DELETE", f"/attendance/{ATTENDANCE_ID}",
        headers=AUTH,
        check_fn=lambda b: check(b["success"]),
    )

if MILESTONE_ID:
    test(
        "Cleanup: delete remaining milestone",
        "DELETE", f"/milestones/{MILESTONE_ID}",
        headers=ADMIN_AUTH,
        check_fn=lambda b: check(b["success"]),
    )

# ══════════════════════════════════════════════════════
#  SUMMARY
# ══════════════════════════════════════════════════════
print("\n" + "═" * 54)
print(f"  Phase 7 Results:  {passed}/{total} passed,  {failed} failed")
print("═" * 54)
if failed:
    sys.exit(1)
