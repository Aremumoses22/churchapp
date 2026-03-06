#!/usr/bin/env python3
"""
Phase 6 — Volunteering, Kids Check-In, Media & Search  (test-phase6.py)
Comprehensive endpoint tests using only stdlib (urllib).

Endpoints tested: 22
  Volunteer: 5  (list-opportunities, signup, list-roster, checkin, swap-shift)
  Kids:      5  (list-children, register-child, checkin, checkout, list-rooms)
  Media:    10  (list-albums, create-album, get-album, add-photo,
                 list-podcasts, get-podcast, update-progress,
                 list-songs, get-song)
  Search:    2  (search, trending)
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
#  VOLUNTEERING  (5 endpoints)
# ══════════════════════════════════════════════════════
print("\n🤝 VOLUNTEERING")

# 1. List volunteer opportunities
opps_body = test(
    "List volunteer opportunities",
    "GET", "/volunteer/opportunities",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"], "response not successful"),
        check(isinstance(b["data"], list), "data should be list"),
        check(len(b["data"]) > 0, "should have seeded opportunities"),
    ),
)
# Get an opportunity that user hasn't signed up for
ALL_OPP_IDS = [o["id"] for o in opps_body.get("data", [])]
ACTIVE_OPP_IDS = [o["id"] for o in opps_body.get("data", []) if o.get("isActive")]

# 2. List opportunities with department filter
test(
    "List opportunities (dept=Worship)",
    "GET", "/volunteer/opportunities?department=Worship",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"], "response not successful"),
        check(len(b["data"]) >= 1, "should have worship opportunities"),
    ),
)

# 3. List opportunities - active filter
test(
    "List opportunities (active=true)",
    "GET", "/volunteer/opportunities?active=true",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"], "response not successful"),
        check(len(b["data"]) >= 1, "should have active opportunities"),
    ),
)

# 4. Signup for a volunteer opportunity (pick active one user hasn't signed up for)
# Seed signups are non-deterministic due to Promise.all, so probe to find a free slot
SIGNUP_OPP_ID = None
for opp_id in ACTIVE_OPP_IDS:
    status, body = make_request("POST", "/volunteer/signup",
                                data={"opportunityId": opp_id}, headers=AUTH)
    if status == 201:
        SIGNUP_OPP_ID = opp_id
        break

total += 1
if SIGNUP_OPP_ID:
    passed += 1
    print(f"  ✅  #{total} Signup for volunteer opportunity")
else:
    failed += 1
    print(f"  ❌  #{total} Signup for volunteer opportunity  →  no free active opportunity found")

# 5. Signup conflict (same opportunity again)
if SIGNUP_OPP_ID:
    test(
        "Signup conflict (duplicate)",
        "POST", "/volunteer/signup",
        data={"opportunityId": SIGNUP_OPP_ID},
        expected_status=409,
        headers=AUTH,
    )
else:
    # If #4 failed, just pick any active opp and try (user is already signed up → 409)
    total += 1
    SIGNUP_OPP_ID = ACTIVE_OPP_IDS[0] if ACTIVE_OPP_IDS else ALL_OPP_IDS[0]
    status, _ = make_request("POST", "/volunteer/signup",
                             data={"opportunityId": SIGNUP_OPP_ID}, headers=AUTH)
    if status == 409:
        passed += 1
        print(f"  ✅  #{total} Signup conflict (duplicate)")
    else:
        failed += 1
        print(f"  ❌  #{total} Signup conflict (duplicate)  →  expected 409, got {status}")

# 6. List roster (upcoming shifts)
roster_body = test(
    "List roster (upcoming)",
    "GET", "/volunteer/roster?upcoming=true",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"], "response not successful"),
        check(isinstance(b["data"], list), "data should be list"),
    ),
)
SHIFT_IDS = [s["id"] for s in roster_body.get("data", [])]

# 7. List roster (past shifts)
test(
    "List roster (past)",
    "GET", "/volunteer/roster?upcoming=false",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"], "response not successful"),
        check(isinstance(b["data"], list), "data should be list"),
    ),
)

# 8. Check-in for shift — this will fail if not today's shift, expected
# We still test the endpoint works (might be 400 if not today)
if SHIFT_IDS:
    checkin_body = test(
        "Check-in for shift (may fail if not today)",
        "POST", f"/volunteer/roster/{SHIFT_IDS[0]}/checkin",
        expected_status=400,  # Shifts are scheduled for next Sunday, not today
        headers=AUTH,
    )

# 9. Swap shift — swap to admin user
if SHIFT_IDS:
    swap_body = test(
        "Swap shift to admin user",
        "POST", f"/volunteer/roster/{SHIFT_IDS[0]}/swap",
        data={"targetUserId": ADMIN_ID},
        headers=AUTH,
        check_fn=lambda b: (
            check(b["success"], "response not successful"),
            check("shift" in b.get("message", "").lower() or b.get("data") is not None, "should succeed"),
        ),
    )


# ══════════════════════════════════════════════════════
#  KIDS CHECK-IN  (5 endpoints)
# ══════════════════════════════════════════════════════
print("\n👶 KIDS CHECK-IN")

# 1. List rooms
rooms_body = test(
    "List rooms",
    "GET", "/kids/rooms",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"], "response not successful"),
        check(isinstance(b["data"], list), "data should be list"),
        check(len(b["data"]) >= 4, "should have 4 rooms from seed"),
    ),
)
ROOM_ID = rooms_body["data"][0]["id"] if rooms_body.get("data") else None

# 2. List children
children_body = test(
    "List children",
    "GET", "/kids/children",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"], "response not successful"),
        check(isinstance(b["data"], list), "data should be list"),
        check(len(b["data"]) >= 2, "should have 2 children from seed"),
    ),
)
CHILD_ID = children_body["data"][0]["id"] if children_body.get("data") else None

# 3. Register a new child
register_body = test(
    "Register a new child",
    "POST", "/kids/children",
    data={
        "firstName": "Grace",
        "lastName": "Doe",
        "dateOfBirth": "2022-03-10",
        "allergies": "None",
    },
    expected_status=201,
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"], "response not successful"),
        check(b["data"]["firstName"] == "Grace", "firstName mismatch"),
    ),
)
NEW_CHILD_ID = register_body["data"]["id"] if register_body.get("data") else None

# 4. Check-in a child
CHECKIN_BODY = None
if CHILD_ID and ROOM_ID:
    checkin_body = test(
        "Check in a child",
        "POST", "/kids/checkin",
        data={"childId": CHILD_ID, "roomId": ROOM_ID},
        expected_status=201,
        headers=AUTH,
        check_fn=lambda b: (
            check(b["success"], "response not successful"),
            check("qrCode" in b["data"], "should have QR code"),
            check(b["data"]["childId"] == CHILD_ID, "childId mismatch"),
        ),
    )
    CHECKIN_BODY = checkin_body

# 5. Check-in conflict (same child already checked in)
if CHILD_ID and ROOM_ID:
    test(
        "Check-in conflict (already checked in)",
        "POST", "/kids/checkin",
        data={"childId": CHILD_ID, "roomId": ROOM_ID},
        expected_status=409,
        headers=AUTH,
    )

# 6. Checkout with wrong security code
CHECKIN_ID = CHECKIN_BODY["data"]["id"] if CHECKIN_BODY and CHECKIN_BODY.get("data") else None
if CHECKIN_ID:
    test(
        "Checkout with wrong code",
        "POST", "/kids/checkout",
        data={"checkInId": CHECKIN_ID, "securityCode": "000000"},
        expected_status=403,
        headers=AUTH,
    )

# 7. Checkout with correct security code
SECURITY_CODE = CHECKIN_BODY["data"]["securityCode"] if CHECKIN_BODY and CHECKIN_BODY.get("data") else None
if CHECKIN_ID and SECURITY_CODE:
    test(
        "Checkout with correct code",
        "POST", "/kids/checkout",
        data={"checkInId": CHECKIN_ID, "securityCode": SECURITY_CODE},
        headers=AUTH,
        check_fn=lambda b: (
            check(b["success"], "response not successful"),
            check(b["data"]["status"] == "CHECKED_OUT", "should be checked out"),
        ),
    )


# ══════════════════════════════════════════════════════
#  MEDIA — PHOTO ALBUMS  (4 endpoints)
# ══════════════════════════════════════════════════════
print("\n📸 MEDIA — PHOTO ALBUMS")

# 1. List albums
albums_body = test(
    "List photo albums",
    "GET", "/media/albums",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"], "response not successful"),
        check(isinstance(b["data"], list), "data should be list"),
        check(len(b["data"]) >= 2, "should have 2 albums from seed"),
    ),
)
ALBUM_ID = albums_body["data"][0]["id"] if albums_body.get("data") else None

# 2. Create album
create_album_body = test(
    "Create photo album",
    "POST", "/media/albums",
    data={"title": "Test Album", "description": "A test album"},
    expected_status=201,
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"], "response not successful"),
        check(b["data"]["title"] == "Test Album", "title mismatch"),
    ),
)
NEW_ALBUM_ID = create_album_body["data"]["id"] if create_album_body.get("data") else None

# 3. Get album by ID
if ALBUM_ID:
    test(
        "Get album by ID",
        "GET", f"/media/albums/{ALBUM_ID}",
        headers=AUTH,
        check_fn=lambda b: (
            check(b["success"], "response not successful"),
            check(b["data"]["id"] == ALBUM_ID, "id mismatch"),
            check(isinstance(b["data"]["photos"], list), "should have photos"),
        ),
    )

# 4. Add photo to album
if NEW_ALBUM_ID:
    test(
        "Add photo to album",
        "POST", f"/media/albums/{NEW_ALBUM_ID}/photos",
        data={
            "imageUrl": "https://picsum.photos/seed/test1/800/600",
            "caption": "Test photo",
        },
        expected_status=201,
        headers=AUTH,
        check_fn=lambda b: (
            check(b["success"], "response not successful"),
            check(b["data"]["albumId"] == NEW_ALBUM_ID, "albumId mismatch"),
        ),
    )


# ══════════════════════════════════════════════════════
#  MEDIA — PODCASTS  (3 endpoints)
# ══════════════════════════════════════════════════════
print("\n🎙️ MEDIA — PODCASTS")

# 1. List podcasts
pods_body = test(
    "List podcast episodes",
    "GET", "/media/podcasts",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"], "response not successful"),
        check(isinstance(b["data"], list), "data should be list"),
        check(len(b["data"]) >= 3, "should have 3 podcast episodes"),
    ),
)
PODCAST_ID = pods_body["data"][0]["id"] if pods_body.get("data") else None

# 2. Get podcast episode (also increments play count)
if PODCAST_ID:
    test(
        "Get podcast episode (increments playCount)",
        "GET", f"/media/podcasts/{PODCAST_ID}",
        headers=AUTH,
        check_fn=lambda b: (
            check(b["success"], "response not successful"),
            check(b["data"]["id"] == PODCAST_ID, "id mismatch"),
        ),
    )

# 3. Update podcast progress
if PODCAST_ID:
    test(
        "Update podcast progress",
        "PUT", f"/media/podcasts/{PODCAST_ID}/progress",
        data={"position": 600, "completed": False},
        headers=AUTH,
        check_fn=lambda b: (
            check(b["success"], "response not successful"),
            check(b["data"]["position"] == 600, "position mismatch"),
        ),
    )


# ══════════════════════════════════════════════════════
#  MEDIA — WORSHIP SONGS  (2 endpoints)
# ══════════════════════════════════════════════════════
print("\n🎵 MEDIA — WORSHIP SONGS")

# 1. List worship songs
songs_body = test(
    "List worship songs",
    "GET", "/media/songs",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"], "response not successful"),
        check(isinstance(b["data"], list), "data should be list"),
        check(len(b["data"]) >= 3, "should have 3 songs from seed"),
    ),
)
SONG_ID = songs_body["data"][0]["id"] if songs_body.get("data") else None

# 2. List songs with key filter
test(
    "List songs (key=G)",
    "GET", "/media/songs?key=G",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"], "response not successful"),
        check(len(b["data"]) >= 1, "should have songs in key G"),
    ),
)

# 3. Search songs
test(
    "Search songs (search=Amazing)",
    "GET", "/media/songs?search=Amazing",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"], "response not successful"),
        check(len(b["data"]) >= 1, "should find Amazing Grace"),
    ),
)

# 4. Get worship song with full lyrics
if SONG_ID:
    test(
        "Get song with sections & lyrics",
        "GET", f"/media/songs/{SONG_ID}",
        headers=AUTH,
        check_fn=lambda b: (
            check(b["success"], "response not successful"),
            check(b["data"]["id"] == SONG_ID, "id mismatch"),
            check(isinstance(b["data"]["sections"], list), "should have sections"),
            check(len(b["data"]["sections"]) > 0, "should have at least 1 section"),
            check(isinstance(b["data"]["sections"][0]["lines"], list), "sections should have lines"),
        ),
    )


# ══════════════════════════════════════════════════════
#  SEARCH  (2 endpoints)
# ══════════════════════════════════════════════════════
print("\n🔍 SEARCH")

# 1. Unified search (all types)
test(
    "Search all types (q=Grace)",
    "GET", "/search?q=Grace",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"], "response not successful"),
        check(isinstance(b["data"], list), "data should be list"),
        check(len(b["data"]) > 0, "should find results for 'Grace'"),
    ),
)

# 2. Search with type filter — sermons
test(
    "Search sermons only (q=faith)",
    "GET", "/search?q=faith&type=sermons",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"], "response not successful"),
        check(isinstance(b["data"], list), "data should be list"),
    ),
)

# 3. Search with type filter — people
test(
    "Search people (q=john)",
    "GET", "/search?q=john&type=people",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"], "response not successful"),
        check(isinstance(b["data"], list), "data should be list"),
    ),
)

# 4. Search with type filter — media
test(
    "Search media (q=worship)",
    "GET", "/search?q=worship&type=media",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"], "response not successful"),
        check(isinstance(b["data"], list), "data should be list"),
    ),
)

# 5. Trending
test(
    "Get trending items",
    "GET", "/search/trending",
    headers=AUTH,
    check_fn=lambda b: (
        check(b["success"], "response not successful"),
        check(isinstance(b["data"], list), "data should be list"),
        check(len(b["data"]) > 0, "should have trending items"),
    ),
)


# ══════════════════════════════════════════════════════
#  EDGE CASES & VALIDATION
# ══════════════════════════════════════════════════════
print("\n🛡️ EDGE CASES & VALIDATION")

# 1. Unauthenticated access
test(
    "Volunteer — no auth → 401",
    "GET", "/volunteer/opportunities",
    expected_status=401,
)

# 2. Kids — no auth → 401
test(
    "Kids — no auth → 401",
    "GET", "/kids/rooms",
    expected_status=401,
)

# 3. Media — no auth → 401
test(
    "Media — no auth → 401",
    "GET", "/media/albums",
    expected_status=401,
)

# 4. Search — no auth → 401
test(
    "Search — no auth → 401",
    "GET", "/search?q=test",
    expected_status=401,
)

# 5. Search — missing query param
test(
    "Search — missing q param → 400",
    "GET", "/search",
    expected_status=400,
    headers=AUTH,
)

# 6. Volunteer signup — invalid UUID
test(
    "Volunteer signup — invalid opportunityId → 400",
    "POST", "/volunteer/signup",
    data={"opportunityId": "not-a-uuid"},
    expected_status=400,
    headers=AUTH,
)

# 7. Kids register — missing required fields
test(
    "Register child — missing fields → 400",
    "POST", "/kids/children",
    data={"firstName": "Only"},
    expected_status=400,
    headers=AUTH,
)

# 8. Inactive opportunity signup
# Find the inactive opportunity
INACTIVE_OPP = None
for o in opps_body.get("data", []):
    if not o.get("isActive", True):
        INACTIVE_OPP = o["id"]
        break

if INACTIVE_OPP:
    test(
        "Signup for inactive opportunity → 400",
        "POST", "/volunteer/signup",
        data={"opportunityId": INACTIVE_OPP},
        expected_status=400,
        headers=AUTH,
    )


# ══════════════════════════════════════════════════════
#  SUMMARY
# ══════════════════════════════════════════════════════
print(f"\n{'═'*55}")
print(f"  Phase 6 Results:  {passed}/{total} passed,  {failed} failed")
print(f"{'═'*55}")

if failed > 0:
    print("\n⚠️  Some tests failed. See details above.")
    sys.exit(1)
else:
    print("\n🎉 All Phase 6 tests passed!")
    sys.exit(0)
