#!/usr/bin/env python3
"""Phase 2 endpoint tester"""
import json, urllib.request, sys

BASE = "http://localhost:8080/api/v1"
results = []

def req(method, path, token=None, body=None):
    url = f"{BASE}{path}"
    data = json.dumps(body).encode() if body else None
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    r = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(r) as resp:
            return json.loads(resp.read()), resp.status
    except urllib.error.HTTPError as e:
        return json.loads(e.read()), e.code

def test(label, method, path, token=None, body=None, check=None):
    try:
        d, status = req(method, path, token, body)
        ok = d.get("success", False)
        extra = ""
        if check and ok:
            extra = check(d)
        symbol = "✅" if ok else "❌"
        results.append((label, ok))
        print(f"  {symbol} {label} [{status}] {extra}")
    except Exception as e:
        results.append((label, False))
        print(f"  ❌ {label} ERROR: {e}")

# Login
print("\n🔐 Authenticating...")
d, _ = req("POST", "/auth/login", body={"email": "john@example.com", "password": "Member@123"})
TOKEN = d["data"]["accessToken"]
print(f"  ✅ Got token\n")

# ═══════════════════════════════════════
# SERMONS
# ═══════════════════════════════════════
print("📖 SERMONS")
test("List sermons", "GET", "/sermons?page=1&limit=5", TOKEN,
     check=lambda d: f'total={d.get("meta",{}).get("total","?")}, count={len(d["data"])}')
test("Featured sermons", "GET", "/sermons/featured", TOKEN,
     check=lambda d: f"count={len(d['data'])}")

# Get first sermon ID
d, _ = req("GET", "/sermons?page=1&limit=1", TOKEN)
sermon_id = d["data"][0]["id"]
test("Get sermon by ID", "GET", f"/sermons/{sermon_id}", TOKEN,
     check=lambda d: f"title={d['data']['title'][:30]}")
test("Get stream URL", "GET", f"/sermons/{sermon_id}/stream", TOKEN)
test("Save progress", "POST", f"/sermons/{sermon_id}/progress", TOKEN,
     body={"position": 120, "completed": False})
test("Toggle save", "POST", f"/sermons/{sermon_id}/save", TOKEN)
test("Get saved sermons", "GET", "/sermons/saved", TOKEN,
     check=lambda d: f"count={len(d['data'])}")
test("Get notes", "GET", f"/sermons/{sermon_id}/notes", TOKEN)
test("Save notes", "PUT", f"/sermons/{sermon_id}/notes", TOKEN,
     body={"content": "Test note from endpoint tester"})
test("List series", "GET", "/sermons/series/all", TOKEN,
     check=lambda d: f"count={len(d['data'])}")

# Get first series ID
d, _ = req("GET", "/sermons/series/all", TOKEN)
series_id = d["data"][0]["id"]
test("Get series by ID", "GET", f"/sermons/series/{series_id}", TOKEN,
     check=lambda d: f"title={d['data']['title'][:30]}")

# ═══════════════════════════════════════
# EVENTS
# ═══════════════════════════════════════
print("\n📅 EVENTS")
test("List events (upcoming)", "GET", "/events?page=1&limit=5&upcoming=true", TOKEN,
     check=lambda d: f'total={d.get("meta",{}).get("total","?")}, count={len(d["data"])}')
test("Featured events", "GET", "/events/featured", TOKEN,
     check=lambda d: f'count={len(d["data"])}')

# Get first event ID
d, _ = req("GET", "/events?page=1&limit=1&upcoming=true", TOKEN)
if d["data"]:
    event_id = d["data"][0]["id"]
    test("Get event by ID", "GET", f"/events/{event_id}", TOKEN,
         check=lambda d: f"title={d['data']['title'][:30]}")
    test("My events", "GET", "/events/my", TOKEN,
         check=lambda d: f"count={len(d['data'])}")
else:
    print("  ⚠️  No upcoming events found, skipping detail tests")

# ═══════════════════════════════════════
# BIBLE
# ═══════════════════════════════════════
print("\n📖 BIBLE")
test("Get books", "GET", "/bible/books", TOKEN,
     check=lambda d: f"count={len(d['data'])}")

# Get first book ID
d, _ = req("GET", "/bible/books", TOKEN)
book_id = d["data"][0]["id"]
book_chapters = d["data"][0]["chapterCount"]
test("Get chapter", "GET", f"/bible/{book_id}/1", TOKEN,
     check=lambda d: f"verses={len(d['data']['verses'])}")
test("Search verses", "GET", "/bible/search?q=love&limit=5", TOKEN,
     check=lambda d: f"count={len(d['data'])}")
test("Get highlights", "GET", "/bible/highlights", TOKEN)

# Get a verse ID for highlighting
d, _ = req("GET", "/bible/search?q=God&limit=1", TOKEN)
if d["data"]:
    verse_id = d["data"][0]["id"]
    test("Add highlight", "POST", "/bible/highlights", TOKEN,
         body={"verseId": verse_id, "color": "blue", "note": "Test highlight"})

# ═══════════════════════════════════════
# DEVOTIONALS
# ═══════════════════════════════════════
print("\n🙏 DEVOTIONALS")
test("Today's devotional", "GET", "/bible/devotionals/today", TOKEN)
test("Devotional by date", "GET", f"/bible/devotionals/{sys.argv[1] if len(sys.argv) > 1 else __import__('datetime').date.today().isoformat()}", TOKEN)
test("Devotional streak", "GET", "/bible/devotionals/streak", TOKEN,
     check=lambda d: f"streak={d['data']['currentStreak']}")

# Mark a devotional as read
d, _ = req("GET", "/bible/devotionals/today", TOKEN)
if d.get("data") and d["data"]:
    dev_id = d["data"]["id"]
    test("Mark devotional read", "POST", f"/bible/devotionals/{dev_id}/read", TOKEN)

# ═══════════════════════════════════════
# READING PLANS
# ═══════════════════════════════════════
print("\n📚 READING PLANS")
test("Browse plans", "GET", "/bible/reading-plans", TOKEN,
     check=lambda d: f"count={len(d['data'])}")
test("My plans", "GET", "/bible/reading-plans/my", TOKEN,
     check=lambda d: f"count={len(d['data'])}")

d, _ = req("GET", "/bible/reading-plans", TOKEN)
if d["data"]:
    plan_id = d["data"][0]["id"]
    test("Get plan by ID", "GET", f"/bible/reading-plans/{plan_id}", TOKEN,
         check=lambda d: f"title={d['data']['title'][:30]}")

# ═══════════════════════════════════════
# CHURCH INFO
# ═══════════════════════════════════════
print("\n⛪ CHURCH INFO")
test("About", "GET", "/church/about", TOKEN,
     check=lambda d: f"name={d['data']['name'][:30]}")
test("Staff", "GET", "/church/staff", TOKEN,
     check=lambda d: f"count={len(d['data'])}")
test("Campuses", "GET", "/church/campuses", TOKEN,
     check=lambda d: f"count={len(d['data'])}")
test("FAQs", "GET", "/church/faqs", TOKEN,
     check=lambda d: f"count={len(d['data'])}")
test("Submit contact", "POST", "/church/contact", TOKEN,
     body={"subject": "Test inquiry", "message": "Hello from the test script!", "category": "general"})

# ═══════════════════════════════════════
# HOME FEED
# ═══════════════════════════════════════
print("\n🏠 HOME FEED")
test("Home feed", "GET", "/home/feed", TOKEN,
     check=lambda d: f"church={d['data']['church']['name'][:20]}, sermons={len(d['data']['featuredSermons'])}, events={len(d['data']['upcomingEvents'])}")

# ═══════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════
passed = sum(1 for _, ok in results if ok)
failed = sum(1 for _, ok in results if not ok)
print(f"\n{'='*50}")
print(f"📊 RESULTS: {passed} passed, {failed} failed, {len(results)} total")
if failed:
    print("Failed tests:")
    for label, ok in results:
        if not ok:
            print(f"  ❌ {label}")
else:
    print("🎉 ALL TESTS PASSED!")
print()
