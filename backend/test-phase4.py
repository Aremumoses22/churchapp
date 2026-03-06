#!/usr/bin/env python3
"""
Phase 4 — Community & Engagement  (test-phase4.py)
Comprehensive endpoint tests using only stdlib (urllib).

Endpoints tested: 29  (Groups 4, Community 10, Forum 10, Prayer 5)
"""

import json, sys, urllib.request, urllib.error, urllib.parse

BASE = "http://localhost:8080/api/v1"
passed = 0
failed = 0
total  = 0

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
ADMIN_AUTH = {"Authorization": f"Bearer {ADMIN_TOKEN}"}
ADMIN_ID = admin_resp["data"]["user"]["id"]

print(f"  Member: {USER_ID[:8]}…   Admin: {ADMIN_ID[:8]}…\n")

# Keep IDs discovered along the way
ids = {}

# ══════════════════════════════════════════════════════
# GROUPS  (4 tests)
# ══════════════════════════════════════════════════════
print("═══════════ GROUPS ═══════════")

def chk_list_groups(b):
    check(b["success"])
    check(len(b["data"]) >= 5, f"expected ≥5 groups, got {len(b['data'])}")
    g = b["data"][0]
    check("isMember" in g, "missing isMember flag")
    check("isOpen" in g, "missing isOpen flag")
    # Find a group the member is NOT yet a member of (and is not leader of)
    for g2 in b["data"]:
        if not g2["isMember"]:
            ids["join_group"] = g2["id"]
            break
    # Also grab one the member IS a leader of (to test leave protection)
    for g2 in b["data"]:
        if g2.get("memberRole") == "LEADER":
            ids["leader_group"] = g2["id"]
            break

test("List groups", "GET", "/groups?page=1&limit=20", headers=AUTH, check_fn=chk_list_groups)

def chk_group_detail(b):
    check(b["success"])
    d = b["data"]
    check("members" in d, "missing members array")
    check(d["name"], "missing name")

# Use first group
first_group = None

def get_first_group(b):
    global first_group
    first_group = b["data"][0]["id"] if b["data"] else None

# We already listed — use member's leader group (Berean Bible Study)
# Need to pick any group for detail — use first from list
_, groups_data = make_request("GET", f"{BASE.replace(BASE,'')}/groups?page=1&limit=20", headers=AUTH)
# Actually let's just call the detail endpoint with a known group
# Let me get the groups list again cleanly
status, groups_list = make_request("GET", "/groups?page=1&limit=20", headers=AUTH)
first_group_id = groups_list["data"][0]["id"]

test("Get group detail", "GET", f"/groups/{first_group_id}", headers=AUTH, check_fn=chk_group_detail)

# Join a group member is not part of
join_id = ids.get("join_group")
if join_id:
    def chk_join(b):
        check(b["success"])
        check(b["data"]["joined"] is True)
    test("Join group", "POST", f"/groups/{join_id}/join", headers=AUTH, check_fn=chk_join)

    # Now leave that group
    def chk_leave(b):
        check(b["success"])
        check(b["data"]["left"] is True)
    test("Leave group", "DELETE", f"/groups/{join_id}/leave", headers=AUTH, check_fn=chk_leave)
else:
    # Member is already in all groups — join Women of Grace with admin first
    test("Join group (fallback)", "POST", f"/groups/{first_group_id}/join", headers=AUTH, expected_status=409)
    test("Leave group (leader block)", "DELETE", f"/groups/{first_group_id}/leave", headers=AUTH, expected_status=400)

# ══════════════════════════════════════════════════════
# ANNOUNCEMENTS  (3 tests)
# ══════════════════════════════════════════════════════
print("\n═══════════ ANNOUNCEMENTS ═══════════")

def chk_announcements(b):
    check(b["success"])
    check(len(b["data"]) >= 3, f"expected ≥3 announcements, got {len(b['data'])}")
    a = b["data"][0]
    check("isRead" in a, "missing isRead flag")
    check("author" in a, "missing author")
    ids["announcement"] = a["id"]

test("List announcements", "GET", "/community/announcements?page=1&limit=20", headers=AUTH,
     check_fn=chk_announcements)

ann_id = ids.get("announcement")
if ann_id:
    def chk_ann_detail(b):
        check(b["success"])
        check(b["data"]["id"] == ann_id)
        check("isRead" in b["data"])
    test("Get announcement detail", "GET", f"/community/announcements/{ann_id}", headers=AUTH,
         check_fn=chk_ann_detail)

    def chk_mark_read(b):
        check(b["success"])
        check(b["data"]["read"] is True)
    test("Mark announcement read", "POST", f"/community/announcements/{ann_id}/read", headers=AUTH,
         check_fn=chk_mark_read)

# ══════════════════════════════════════════════════════
# TESTIMONIES  (3 tests)
# ══════════════════════════════════════════════════════
print("\n═══════════ TESTIMONIES ═══════════")

def chk_testimonies(b):
    check(b["success"])
    check(len(b["data"]) >= 2, f"expected ≥2 approved testimonies, got {len(b['data'])}")
    t = b["data"][0]
    check("likeCount" in t, "missing likeCount")
    check("prayerCount" in t, "missing prayerCount")
    ids["testimony"] = t["id"]

test("List testimonies", "GET", "/community/testimonies?page=1&limit=20", headers=AUTH,
     check_fn=chk_testimonies)

def chk_submit_testimony(b):
    check(b["success"])
    d = b["data"]
    check(d["title"] == "God provided a new car")
    check(d["status"] == "PENDING")
    ids["new_testimony"] = d["id"]

test("Submit testimony", "POST", "/community/testimonies",
     data={"title": "God provided a new car", "content": "After months of praying, God blessed me with a brand new car. I am so grateful for His provision and faithfulness."},
     headers=AUTH, expected_status=201, check_fn=chk_submit_testimony)

# React to an approved testimony
testimony_id = ids.get("testimony")
if testimony_id:
    def chk_react(b):
        check(b["success"])
        check("reacted" in b["data"])
        check(b["data"]["type"] == "LIKE")
    test("React to testimony (LIKE)", "POST", f"/community/testimonies/{testimony_id}/react",
         data={"type": "LIKE"}, headers=AUTH, check_fn=chk_react)

# ══════════════════════════════════════════════════════
# DIRECTORY  (1 test)
# ══════════════════════════════════════════════════════
print("\n═══════════ DIRECTORY ═══════════")

def chk_directory(b):
    check(b["success"])
    check(len(b["data"]) >= 1, "expected at least 1 directory member")
    m = b["data"][0]
    check("name" in m, "missing name")
    check("email" in m, "missing email")

test("Get church directory", "GET", "/community/directory?page=1&limit=20", headers=AUTH,
     check_fn=chk_directory)

# ══════════════════════════════════════════════════════
# INVITES  (3 tests)
# ══════════════════════════════════════════════════════
print("\n═══════════ INVITES ═══════════")

def chk_generate_invite(b):
    check(b["success"])
    d = b["data"]
    check("code" in d, "missing code")
    check("inviteUrl" in d, "missing inviteUrl")
    check("expiresAt" in d, "missing expiresAt")
    ids["invite_code"] = d["code"]

test("Generate invite link", "POST", "/community/invite/generate", headers=AUTH,
     expected_status=201, check_fn=chk_generate_invite)

# Validate invite (public endpoint)
invite_code = ids.get("invite_code")
if invite_code:
    def chk_validate_invite(b):
        check(b["success"])
        d = b["data"]
        check(d["valid"] is True)
        check("church" in d)
        check("invitedBy" in d)
    test("Validate invite link", "GET", f"/community/invite/{invite_code}",
         check_fn=chk_validate_invite)

def chk_invite_stats(b):
    check(b["success"])
    d = b["data"]
    check("totalInvitesSent" in d)
    check("invites" in d)
    check(isinstance(d["invites"], list))

test("Get invite stats", "GET", "/community/invite/stats", headers=AUTH,
     check_fn=chk_invite_stats)

# ══════════════════════════════════════════════════════
# FORUM  (10 tests)
# ══════════════════════════════════════════════════════
print("\n═══════════ FORUM ═══════════")

def chk_categories(b):
    check(b["success"])
    cats = b["data"]
    check(len(cats) >= 8, f"expected ≥8 categories, got {len(cats)}")
    ids["forum_cat"] = cats[0]["id"]  # General Discussion
    # Also find Bible Study category for creating a thread
    for c in cats:
        if "Bible" in c.get("name", ""):
            ids["bible_cat"] = c["id"]
            break
    if "bible_cat" not in ids:
        ids["bible_cat"] = cats[2]["id"]  # fallback to 3rd

test("List forum categories", "GET", "/forum/categories", headers=AUTH,
     check_fn=chk_categories)

def chk_trending(b):
    check(b["success"])
    check(isinstance(b["data"], list))
    if len(b["data"]) > 0:
        t = b["data"][0]
        check("title" in t, "missing title")
        check("isLiked" in t, "missing isLiked")
        ids["thread"] = t["id"]

test("Get trending threads", "GET", "/forum/trending", headers=AUTH,
     check_fn=chk_trending)

def chk_recent(b):
    check(b["success"])
    check(len(b["data"]) >= 1, "expected ≥1 recent thread")
    t = b["data"][0]
    check("category" in t, "missing category")
    check("author" in t, "missing author")
    if "thread" not in ids:
        ids["thread"] = t["id"]

test("Get recent threads", "GET", "/forum/recent?page=1&limit=20&sort=recent", headers=AUTH,
     check_fn=chk_recent)

# Category threads
cat_id = ids.get("forum_cat")
if cat_id:
    def chk_cat_threads(b):
        check(b["success"])
        # May have 0 or more threads in General
        check("data" in b)
        check("meta" in b)
    test("Get category threads", "GET", f"/forum/categories/{cat_id}/threads?page=1&limit=20&sort=recent",
         headers=AUTH, check_fn=chk_cat_threads)

# Thread detail
thread_id = ids.get("thread")
if thread_id:
    def chk_thread_detail(b):
        check(b["success"])
        d = b["data"]
        check("thread" in d, "missing thread key")
        check("replies" in d, "missing replies key")
        check("data" in d["replies"], "missing replies.data")
        check("meta" in d["replies"], "missing replies.meta")
    test("Get thread detail", "GET", f"/forum/threads/{thread_id}?page=1&limit=20",
         headers=AUTH, check_fn=chk_thread_detail)

# Create thread
def chk_create_thread(b):
    check(b["success"])
    d = b["data"]
    check(d["title"] == "How to study the Bible effectively?")
    check("id" in d)
    ids["new_thread"] = d["id"]

test("Create forum thread", "POST", "/forum/threads",
     data={
         "categoryId": ids.get("bible_cat", ids.get("forum_cat")),
         "title": "How to study the Bible effectively?",
         "content": "I want to develop a systematic Bible study habit. What methods have worked for you? SOAP? Inductive? Verse mapping?"
     },
     headers=AUTH, expected_status=201, check_fn=chk_create_thread)

# Create reply
reply_thread = ids.get("new_thread") or ids.get("thread")
if reply_thread:
    def chk_create_reply(b):
        check(b["success"])
        d = b["data"]
        check(d["content"] == "I love the SOAP method! It really helps me meditate on Scripture.")
        check("id" in d)
        ids["reply"] = d["id"]
    test("Create reply", "POST", f"/forum/threads/{reply_thread}/replies",
         data={"content": "I love the SOAP method! It really helps me meditate on Scripture."},
         headers=AUTH, expected_status=201, check_fn=chk_create_reply)

# Like thread
like_thread = ids.get("thread") or ids.get("new_thread")
if like_thread:
    def chk_like_thread(b):
        check(b["success"])
        check("liked" in b["data"])
    test("Toggle thread like", "POST", f"/forum/threads/{like_thread}/like",
         headers=AUTH, check_fn=chk_like_thread)

# Bookmark thread
if like_thread:
    def chk_bookmark(b):
        check(b["success"])
        check("bookmarked" in b["data"])
    test("Toggle thread bookmark", "POST", f"/forum/threads/{like_thread}/bookmark",
         headers=AUTH, check_fn=chk_bookmark)

# Like reply
reply_id = ids.get("reply")
if reply_id:
    def chk_like_reply(b):
        check(b["success"])
        check("liked" in b["data"])
    test("Toggle reply like", "POST", f"/forum/replies/{reply_id}/like",
         headers=AUTH, check_fn=chk_like_reply)

# ══════════════════════════════════════════════════════
# PRAYER REQUESTS  (5 tests)
# ══════════════════════════════════════════════════════
print("\n═══════════ PRAYER REQUESTS ═══════════")

def chk_list_prayer(b):
    check(b["success"])
    check(len(b["data"]) >= 3, f"expected ≥3 active prayer requests, got {len(b['data'])}")
    p = b["data"][0]
    check("hasPrayed" in p, "missing hasPrayed flag")
    check("isUrgent" in p, "missing isUrgent flag")
    # Find one the member hasn't prayed for yet
    for p2 in b["data"]:
        if not p2["hasPrayed"]:
            ids["prayer"] = p2["id"]
            break
    if "prayer" not in ids:
        ids["prayer"] = b["data"][0]["id"]

test("List prayer requests", "GET", "/prayer-requests?page=1&limit=20", headers=AUTH,
     check_fn=chk_list_prayer)

def chk_my_prayers(b):
    check(b["success"])
    check(len(b["data"]) >= 1, "expected ≥1 own prayer request")

test("Get my prayer requests", "GET", "/prayer-requests/my?page=1&limit=20", headers=AUTH,
     check_fn=chk_my_prayers)

def chk_create_prayer(b):
    check(b["success"])
    d = b["data"]
    check(d["title"] == "Pray for my job interview")
    check(d["isUrgent"] is True)
    ids["new_prayer"] = d["id"]

test("Create prayer request", "POST", "/prayer-requests",
     data={
         "title": "Pray for my job interview",
         "content": "I have a very important job interview next Monday. Please pray for favor, wisdom, and peace.",
         "isAnonymous": False,
         "isUrgent": True,
     },
     headers=AUTH, expected_status=201, check_fn=chk_create_prayer)

# Pray for a request (use admin to pray for member's request)
prayer_id = ids.get("prayer")
if prayer_id:
    def chk_pray(b):
        check(b["success"])
        check("prayed" in b["data"])
    test("Pray for request", "POST", f"/prayer-requests/{prayer_id}/pray",
         headers=ADMIN_AUTH, check_fn=chk_pray)

# Update status of newly created prayer
new_prayer_id = ids.get("new_prayer")
if new_prayer_id:
    def chk_update_status(b):
        check(b["success"])
        check(b["data"]["status"] == "ANSWERED")
    test("Update prayer status", "PUT", f"/prayer-requests/{new_prayer_id}/status",
         data={"status": "ANSWERED"}, headers=AUTH, check_fn=chk_update_status)

# ══════════════════════════════════════════════════════
# HOME FEED — Verify Phase 4 additions
# ══════════════════════════════════════════════════════
print("\n═══════════ HOME FEED (Phase 4 additions) ═══════════")

def chk_home_feed(b):
    check(b["success"])
    d = b["data"]
    check("announcements" in d, "missing announcements in home feed")
    check(len(d["announcements"]) >= 1, "expected ≥1 announcement in feed")
    check("urgentPrayerRequests" in d, "missing urgentPrayerRequests in home feed")

test("Home feed has announcements & prayer", "GET", "/home/feed", headers=AUTH,
     check_fn=chk_home_feed)

# ══════════════════════════════════════════════════════
# SUMMARY
# ══════════════════════════════════════════════════════
print(f"\n{'='*50}")
print(f"  Phase 4 Results:  {passed}/{total} passed,  {failed} failed")
print(f"{'='*50}\n")

sys.exit(0 if failed == 0 else 1)
