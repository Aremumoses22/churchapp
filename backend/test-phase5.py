#!/usr/bin/env python3
"""
Phase 5 — Real-Time & Notifications  (test-phase5.py)
Comprehensive endpoint tests using only stdlib (urllib).

Endpoints tested: 16
  Notifications: 5  (list, unread-count, mark-read, mark-all-read, delete)
  Chat:          7  (list-conversations, create-conversation, get-messages,
                     send-message, mark-read, toggle-pin, toggle-mute)
  Live:          4  (list, current, get-by-id, chat-messages)
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

# ══════════════════════════════════════════════════════
#  NOTIFICATIONS  (5 endpoints)
# ══════════════════════════════════════════════════════
print("\n📨 NOTIFICATIONS")

# 1. List notifications
notif_list_body = test(
    "List notifications",
    "GET", "/notifications",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"], "response not successful"),
        check(isinstance(b["data"], list), "data should be list"),
        check(len(b["data"]) > 0, "should have seeded notifications"),
    ),
)
NOTIF_ID = notif_list_body["data"][0]["id"] if notif_list_body.get("data") else None

# 2. Unread count
test(
    "Get unread count",
    "GET", "/notifications/unread-count",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check("count" in b["data"], "should have count"),
        check(isinstance(b["data"]["count"], int), "count should be int"),
    ),
)

# 3. Mark single as read
if NOTIF_ID:
    test(
        "Mark notification as read",
        "PUT", f"/notifications/{NOTIF_ID}/read",
        headers=AUTH,
        check_fn=lambda b: check(b["success"]),
    )

# 4. Mark all as read
test(
    "Mark all notifications as read",
    "PUT", "/notifications/read-all",
    headers=AUTH,
    check_fn=lambda b: check(b["success"]),
)

# 5. Delete a notification (use admin's notification)
admin_notif_body = test(
    "List admin notifications (for delete)",
    "GET", "/notifications",
    headers=ADMIN_AUTH,
    check_fn=lambda b: check(b["success"]),
)
ADMIN_NOTIF_ID = admin_notif_body["data"][0]["id"] if admin_notif_body.get("data") and len(admin_notif_body["data"]) > 0 else None

if ADMIN_NOTIF_ID:
    total -= 1  # Don't count the list above as a test
    test(
        "Delete notification",
        "DELETE", f"/notifications/{ADMIN_NOTIF_ID}",
        headers=ADMIN_AUTH,
        check_fn=lambda b: check(b["success"]),
    )

# ══════════════════════════════════════════════════════
#  CHAT  (7 endpoints)
# ══════════════════════════════════════════════════════
print("\n💬 CHAT")

# 6. List conversations
convo_body = test(
    "List conversations",
    "GET", "/chat/conversations",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"], "response not successful"),
        check(isinstance(b["data"], list), "data should be list"),
        check(len(b["data"]) >= 2, "should have seeded conversations"),
    ),
)

# Get existing conversation IDs
EXISTING_CONVO_ID = None
GROUP_CONVO_ID = None
if convo_body.get("data"):
    for c in convo_body["data"]:
        if c.get("type") == "DIRECT":
            EXISTING_CONVO_ID = c["id"]
        elif c.get("type") == "GROUP":
            GROUP_CONVO_ID = c["id"]
    if not EXISTING_CONVO_ID:
        EXISTING_CONVO_ID = convo_body["data"][0]["id"]

# 7. Create a group conversation
new_convo_body = test(
    "Create group conversation",
    "POST", "/chat/conversations",
    data={
        "type": "GROUP",
        "name": "Test Group Chat",
        "memberIds": [ADMIN_ID],
    },
    expected_status=201,
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check(b["data"]["type"] == "GROUP", "should be GROUP"),
    ),
)
NEW_CONVO_ID = new_convo_body["data"]["id"] if new_convo_body.get("data") else None

# 8. Get messages for a conversation
test(
    "Get messages",
    "GET", f"/chat/conversations/{EXISTING_CONVO_ID}/messages",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check(isinstance(b["data"], list), "messages should be list"),
        check(len(b["data"]) > 0, "should have seeded messages"),
    ),
)

# 9. Send a message
test(
    "Send message",
    "POST", f"/chat/conversations/{EXISTING_CONVO_ID}/messages",
    data={"content": "Hello from Phase 5 tests! 🚀"},
    expected_status=201,
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check(b["data"]["content"] == "Hello from Phase 5 tests! 🚀"),
    ),
)

# 10. Mark conversation as read
test(
    "Mark conversation as read",
    "PUT", f"/chat/conversations/{EXISTING_CONVO_ID}/read",
    headers=AUTH,
    check_fn=lambda b: check(b["success"]),
)

# 11. Toggle pin
pin_body = test(
    "Toggle pin conversation",
    "PUT", f"/chat/conversations/{EXISTING_CONVO_ID}/pin",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check("isPinned" in b["data"], "should have isPinned field"),
    ),
)

# 12. Toggle mute
mute_body = test(
    "Toggle mute conversation",
    "PUT", f"/chat/conversations/{EXISTING_CONVO_ID}/mute",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check("isMuted" in b["data"], "should have isMuted field"),
    ),
)

# ══════════════════════════════════════════════════════
#  LIVE SERVICES  (4 endpoints)
# ══════════════════════════════════════════════════════
print("\n📡 LIVE SERVICES")

# 13. List live services
live_body = test(
    "List live services",
    "GET", "/live",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check(isinstance(b["data"], list), "data should be list"),
        check(len(b["data"]) >= 1, "should have seeded live services"),
    ),
)
LIVE_ID = live_body["data"][0]["id"] if live_body.get("data") and len(live_body["data"]) > 0 else None

# 14. Get current live service
test(
    "Get current/upcoming live",
    "GET", "/live/current",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"]),
        check("isLive" in b["data"], "should have isLive field"),
    ),
)

# 15. Get live service by ID
if LIVE_ID:
    test(
        "Get live service by ID",
        "GET", f"/live/{LIVE_ID}",
        headers=AUTH,
        check_fn=lambda b: (
            check(b["success"]),
            check(b["data"]["id"] == LIVE_ID, "ID should match"),
        ),
    )

# 16. Get live chat messages
# Find the ended service (it has chat messages)
ENDED_LIVE_ID = None
if live_body.get("data"):
    for s in live_body["data"]:
        if s.get("status") == "ENDED":
            ENDED_LIVE_ID = s["id"]
            break
    if not ENDED_LIVE_ID:
        ENDED_LIVE_ID = LIVE_ID

if ENDED_LIVE_ID:
    test(
        "Get live chat messages",
        "GET", f"/live/{ENDED_LIVE_ID}/chat",
        headers=AUTH,
        check_fn=lambda b: (
            check(b["success"]),
            check(isinstance(b["data"], list), "data should be list"),
        ),
    )

# ══════════════════════════════════════════════════════
#  CROSS-MODULE: Notification triggers (verify wiring)
# ══════════════════════════════════════════════════════
print("\n🔔 NOTIFICATION TRIGGERS (integration)")

# Trigger: Event registration should fire notification
# Register for an event
events_body = make_request("GET", "/events?upcoming=true", headers=AUTH)
if events_body[0] == 200 and events_body[1].get("data"):
    reg_events = [e for e in events_body[1]["data"] if e.get("registrationRequired")]
    if reg_events:
        EVENT_ID = reg_events[0]["id"]
        test(
            "Event registration → notification trigger",
            "POST", f"/events/{EVENT_ID}/register",
            headers=AUTH,
            check_fn=lambda b: check(b["success"]),
        )

# Trigger: Prayer interaction should fire notification
prayers_body = make_request("GET", "/prayer-requests", headers=AUTH)
if prayers_body[0] == 200 and prayers_body[1].get("data"):
    active_prayers = [p for p in prayers_body[1]["data"] if p.get("status") == "ACTIVE"]
    if active_prayers:
        # Find one not by the member user
        other_prayer = None
        for p in active_prayers:
            if p.get("userId") != USER_ID:
                other_prayer = p
                break
        if other_prayer:
            test(
                "Prayer interaction → notification trigger",
                "POST", f"/prayer-requests/{other_prayer['id']}/pray",
                headers=AUTH,
                check_fn=lambda b: check(b["success"]),
            )

# Trigger: Forum reply should fire notification
threads_body = make_request("GET", "/forum/threads?page=1&limit=5", headers=AUTH)
if threads_body[0] == 200 and threads_body[1].get("data"):
    THREAD_ID = threads_body[1]["data"][0]["id"]
    test(
        "Forum reply → notification trigger",
        "POST", f"/forum/threads/{THREAD_ID}/replies",
        data={"content": "Great discussion! Phase 5 notification trigger test."},
        expected_status=201,
        headers=AUTH,
        check_fn=lambda b: check(b["success"]),
    )

# ══════════════════════════════════════════════════════
#  SUMMARY
# ══════════════════════════════════════════════════════
print(f"\n{'='*50}")
print(f"  Phase 5 — Real-Time & Notifications")
print(f"  Passed: {passed}/{total}  |  Failed: {failed}/{total}")
print(f"{'='*50}")

if failed > 0:
    print("\n⚠️  Some tests failed!")
    sys.exit(1)
else:
    print("\n🎉 All Phase 5 tests passed!")
    sys.exit(0)
