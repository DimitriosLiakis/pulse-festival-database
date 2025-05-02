#!/usr/bin/env python3
# ==========================================================
# generate_csv.py – Pulse‑University Music‑Festival DB
#   compatible with ENUM‑free install_v3.sql  (2025‑05‑02)
# ----------------------------------------------------------
#  ‑ Event: event_start / event_end (DATETIME)
#  ‑ Artist: now HAS main_genre & sub_genre
#  ‑ Ticket.purchase_date and Resale_queue.interest_date
#      are constrained to the year of the festival event
#  ‑ Location.coordinates in WKT POINT(lon lat)
#  ‑ Creates ≥ 2 future festivals (up to +6 months)
#  ‑ VIP ≤ 10 % of tickets per event
# ==========================================================

import os, csv, random, math
from faker import Faker
from datetime import datetime, timedelta
import pandas as pd

fake = Faker()
Faker.seed(42)
random.seed(42)

OUT_DIR = "csv_data"
os.makedirs(OUT_DIR, exist_ok=True)

# ---------------- parameters ---------------------------------
NUM_LOCATIONS     = 5
NUM_FESTIVALS     = 10
NUM_STAGES        = 30
NUM_EVENTS        = 50
NUM_ARTISTS       = 30
NUM_BANDS         = 20
NUM_PERFORMANCES  = 100
NUM_VISITORS      = 200
NUM_TICKETS       = 300
NUM_STAFF         = 30
NUM_RATINGS       = 400
NUM_RESALE        = 50
MAX_TRIES         = 20          # to place performances without overlap

# ---------------- genres -------------------------------------
GENRES = {
    "rock":       ["hard rock", "indie rock", "alternative"],
    "jazz":       ["bebop", "smooth jazz", "fusion"],
    "pop":        ["synth‑pop", "electro‑pop", "dance‑pop"],
    "hip‑hop":    ["trap", "boom bap", "lo‑fi"],
    "electronic": ["house", "techno", "drum&bass"]
}
GENRE_KEYS = list(GENRES.keys())

# ---------------- ID pools -----------------------------------
location_ids    = list(range(1, NUM_LOCATIONS+1))
festival_ids    = list(range(1, NUM_FESTIVALS+1))
stage_ids       = list(range(1, NUM_STAGES+1))
event_ids       = list(range(1, NUM_EVENTS+1))
artist_ids      = list(range(1, NUM_ARTISTS+1))
band_ids        = list(range(1, NUM_BANDS+1))
performance_ids = list(range(1, NUM_PERFORMANCES+1))
visitor_ids     = list(range(1, NUM_VISITORS+1))
staff_ids       = list(range(1, NUM_STAFF+1))

# -------------------------------------------------------------
# 1) LOCATION
# -------------------------------------------------------------
with open(f"{OUT_DIR}/Location.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["location_id","address","city","country","continent",
                "coordinates","location_image"])
    for lid in location_ids:
        lat, lon = fake.latitude(), fake.longitude()
        w.writerow([
            lid,
            fake.street_address().replace("\n"," "),
            fake.city(), fake.country(),
            random.choice(["Europe","Asia","Africa","North America",
                           "South America","Australia"]),
            f"POINT({lon:.4f} {lat:.4f})",
            f"https://example.com/location_{lid}.jpg"
        ])

# -------------------------------------------------------------
# 2) FESTIVAL  (one per year 2017‑2026)
# -------------------------------------------------------------
YEAR_LIST = list(range(2017, 2027))          # inclusive 2017‑2026
festival_ids = list(range(1, len(YEAR_LIST)+1))
fest_dates = {}

with open(f"{OUT_DIR}/Festival.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["festival_id","festival_name","festival_year",
                "start_date","end_date","location_id_FK","festival_image"])

    for fid, year in zip(festival_ids, YEAR_LIST):
        # ensure present/future festivals are at least +30 days away if same year
        if year == datetime.now().year and datetime.now().month < 12:
            date_start = datetime.now() + timedelta(days=30)
            date_end   = datetime(year, 12, 31)
        elif year > datetime.now().year:
            date_start = datetime(year, 1, 1)
            date_end   = datetime(year, 12, 31)
        else:  # past
            date_start = datetime(year, 1, 1)
            date_end   = datetime(year, 12, 31)

        sd = fake.date_between_dates(date_start=date_start,
                                     date_end=date_end)
        ed = sd + timedelta(days=random.randint(1, 4))
        fest_dates[fid] = (sd, ed)

        w.writerow([
            fid, f"PulseFestival_{year}", year,
            sd, ed, random.choice(location_ids),
            f"https://example.com/fest_{fid}.jpg"
        ])

# -------------------------------------------------------------
# 3) STAGE
# -------------------------------------------------------------
with open(f"{OUT_DIR}/Stage.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["stage_id","stage_name","stage_description",
                "capacity","tech_equipment","stage_image"])
    for sid in stage_ids:
        w.writerow([
            sid, f"Stage_{sid}",
            fake.sentence(nb_words=8).replace("'",""),
            random.randint(100, 2000),
            "Lights, Speakers, Microphones",
            f"https://example.com/stage_{sid}.jpg"
        ])

# -------------------------------------------------------------
# 4) EVENT  (ensure ≥1 per festival)
# -------------------------------------------------------------
events = []   # (event_id, festival_id, stage_id, start_dt, end_dt)
def add_event(fid, eid, writer):
    sd, ed = fest_dates[fid]
    ev_day = sd + timedelta(days=random.randint(0, (ed-sd).days))
    start_dt = datetime.combine(ev_day, datetime.min.time()) \
               + timedelta(hours=random.randint(12, 22))
    end_dt = start_dt + timedelta(hours=random.randint(2, 8))
    sid = random.choice(stage_ids)
    events.append((eid, fid, sid, start_dt, end_dt))
    writer.writerow([
        eid, f"Event_{eid}", fid, sid,
        start_dt, end_dt, f"https://example.com/event_{eid}.jpg"
    ])

with open(f"{OUT_DIR}/Event.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["event_id","event_name","festival_id_FK","stage_id_FK",
                "event_start","event_end","event_image"])
    eid = 0
    # Pass A: one event per festival
    for fid in festival_ids:
        eid += 1
        add_event(fid, eid, w)
    # Pass B: the rest
    while eid < NUM_EVENTS:
        eid += 1
        add_event(random.choice(festival_ids), eid, w)

evt_times = {e[0]: (e[3], e[4]) for e in events}

# -------------------------------------------------------------
# 5) ARTIST
# -------------------------------------------------------------
with open(f"{OUT_DIR}/Artist.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["artist_id","name","pseudonym","birth_date",
                "main_genre","sub_genre",
                "website","instagram","image_url"])
    for aid in artist_ids:
        name = fake.name().replace("'","")
        pseudo = fake.user_name() if random.random() < 0.3 else ""
        bd = fake.date_of_birth(minimum_age=18, maximum_age=70)
        slug = (pseudo or name.replace(" ","").lower())
        main = random.choice(GENRE_KEYS)
        sub  = random.choice(GENRES[main])
        w.writerow([
            aid, name, pseudo, bd, main, sub,
            f"https://www.{slug}.com",
            f"https://instagram.com/{slug}",
            f"https://example.com/artist_{aid}.jpg"
        ])

# -------------------------------------------------------------
# 6) BAND
# -------------------------------------------------------------
with open(f"{OUT_DIR}/Band.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["band_id","band_name","formation_date",
                "website","instagram","image_url"])
    for bid in band_ids:
        bn = f"{fake.word().capitalize()}Band_{bid}"
        slug = bn.lower()
        w.writerow([
            bid, bn,
            fake.date_between(start_date="-20y", end_date="-1y"),
            f"https://www.{slug}.com",
            f"https://instagram.com/{slug}",
            f"https://example.com/band_{bid}.jpg"
        ])

# -------------------------------------------------------------
# 6a) ARTIST_BAND
# -------------------------------------------------------------
with open(f"{OUT_DIR}/Artist_Band.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["artist_id","band_id","join_date"])
    for aid in artist_ids:
        if random.random() < 0.4:
            for bid in random.sample(band_ids, k=random.randint(1, 2)):
                w.writerow([
                    aid, bid,
                    fake.date_between(start_date="-5y", end_date="today")
                ])

# -------------------------------------------------------------
# 7) PERFORMANCE
# -------------------------------------------------------------
performance_map = []
artist_sched = {aid: [] for aid in artist_ids}
band_sched   = {bid: [] for bid in band_ids}

with open(f"{OUT_DIR}/Performance.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["performance_id","event_id_FK","performance_type",
                "start_time","duration_minutes","performance_image"])

    for pid in performance_ids:
        placed = False; tries = 0
        while not placed and tries < MAX_TRIES:
            tries += 1
            eid, fid, sid, ev_start, ev_end = random.choice(events)
            dur = random.randint(30, 180)
            last = ev_end - timedelta(minutes=dur)
            if last <= ev_start:
                continue
            start_time = ev_start + timedelta(
                minutes=random.randint(0, int((last-ev_start).total_seconds()//60))
            )
            end_time = start_time + timedelta(minutes=dur)

            if random.random() < 0.5:
                ent, sched, kind = random.choice(artist_ids), artist_sched, "artist"
            else:
                ent, sched, kind = random.choice(band_ids), band_sched, "band"

            if all(end_time + timedelta(minutes=5) <= s or
                   start_time >= e + timedelta(minutes=5) for s,e in sched[ent]):
                sched[ent].append((start_time, end_time))
                placed = True

        if not placed:  # fallback
            eid, _, _, ev_start, _ = events[0]
            ent, kind = artist_ids[0], "artist"
            start_time = ev_start; dur = 60
            end_time = start_time + timedelta(minutes=dur)
            artist_sched[ent].append((start_time, end_time))

        w.writerow([pid, eid,
                    random.choice(["warm up","headline","special guest","main act"]),
                    start_time, dur,
                    f"https://example.com/performance_{pid}.jpg"])
        performance_map.append((pid, ent, kind))

with open(f"{OUT_DIR}/Performance_Artist.csv", "w", newline="", encoding="utf-8") as fa, \
     open(f"{OUT_DIR}/Performance_Band.csv", "w", newline="", encoding="utf-8") as fb:
    wa, wb = csv.writer(fa), csv.writer(fb)
    wa.writerow(["performance_id","artist_id"])
    wb.writerow(["performance_id","band_id"])
    for pid, ent, kind in performance_map:
        (wa if kind=="artist" else wb).writerow([pid, ent])

# -------------------------------------------------------------
# 8) VISITOR
# -------------------------------------------------------------
with open(f"{OUT_DIR}/Visitor.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["visitor_id","first_name","last_name","age","phone","email"])
    for vid in visitor_ids:
        w.writerow([
            vid, fake.first_name(), fake.last_name(),
            random.randint(18, 70), fake.phone_number(), fake.email()
        ])

# -------------------------------------------------------------
# 9) TICKET (purchase_date constrained to festival year)
# -------------------------------------------------------------
stage_df = pd.read_csv(f"{OUT_DIR}/Stage.csv")
event_df = pd.read_csv(f"{OUT_DIR}/Event.csv")

cap_lookup = dict(stage_df.set_index("stage_id")["capacity"])
evt2cap    = {row.event_id: cap_lookup[row.stage_id_FK] for _, row in event_df.iterrows()}
evt2year   = {row.event_id: int(str(row.event_start)[:4]) for _, row in event_df.iterrows()}

vip_count = {eid: 0 for eid in event_ids}
seen = set()

with open(f"{OUT_DIR}/Ticket.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["ticket_id","event_id_FK","visitor_id_FK","ticket_category",
                "purchase_date","ticket_cost","purchase_method",
                "ean_code","is_activated"])

    tid = 0
    while tid < NUM_TICKETS:
        ev  = random.choice(event_ids)
        vis = random.choice(visitor_ids)
        if (vis, ev) in seen:
            continue
        seen.add((vis, ev))

        cap = evt2cap[ev]
        if random.random() < 0.10 and vip_count[ev] < math.ceil(cap * 0.10):
            cat = "VIP"; vip_count[ev] += 1
        else:
            cat = random.choice(["general", "backstage"])

        yr = evt2year[ev]
        pd_start = datetime(yr, 1, 1)
        pd_end   = datetime(yr, 12, 31, 23, 59, 59)
        purchase_dt = fake.date_time_between_dates(pd_start, pd_end)

        tid += 1
        w.writerow([
            tid, ev, vis, cat, purchase_dt,
            random.randint(15, 100),
            random.choice(["credit_card","debit_card","bank_transfer","other"]),
            fake.random_number(digits=13, fix_len=True),
            random.choice([0, 1])
        ])

# -------------------------------------------------------------
# 10) STAFF & STAGE_STAFF
# -------------------------------------------------------------
with open(f"{OUT_DIR}/Staff.csv", "w", newline="", encoding="utf-8") as fs, \
     open(f"{OUT_DIR}/Stage_Staff.csv", "w", newline="", encoding="utf-8") as fss:
    ws, wss = csv.writer(fs), csv.writer(fss)
    ws.writerow(["staff_id","staff_name","age","role","experience_level"])
    wss.writerow(["stage_id","staff_id","start_date","end_date"])
    for sid in staff_ids:
        role = random.choice(["tech","security","support"])
        exp  = random.choice(["intern","beginner","average","experienced","expert"])
        ws.writerow([sid, fake.name(), random.randint(20, 60), role, exp])

        fid = random.choice(festival_ids)
        f_sd, f_ed = fest_dates[fid]
        stage_candidates = [st for (_, ff, st, _, _) in events if ff == fid]
        if not stage_candidates: continue
        stg = random.choice(stage_candidates)
        a_sd = f_sd + timedelta(days=random.randint(0, (f_ed-f_sd).days))
        a_ed = a_sd + timedelta(days=random.randint(0, (f_ed-a_sd).days))
        wss.writerow([stg, sid, a_sd, a_ed])

# -------------------------------------------------------------
# 11) RATING
# -------------------------------------------------------------
with open(f"{OUT_DIR}/Rating.csv", "w", newline="", encoding="utf-8") as fr:
    w = csv.writer(fr)
    w.writerow(["rating_id","visitor_id_FK","performance_id_FK",
                "rating_interpretation","rating_sound_light",
                "rating_stage_presence","rating_organization","rating_overall"])
    rid = 0; seen = set()
    while rid < NUM_RATINGS:
        vis = random.choice(visitor_ids)
        perf = random.choice(performance_ids)
        if (vis, perf) in seen: continue
        seen.add((vis, perf)); rid += 1
        w.writerow([rid, vis, perf, *[random.randint(1, 5) for _ in range(5)]])

# -------------------------------------------------------------
# 12) RESALE_QUEUE (interest_date within ticket year)
# -------------------------------------------------------------
ticket_df   = pd.read_csv(f"{OUT_DIR}/Ticket.csv")
ticket_year = ticket_df.set_index("ticket_id")["purchase_date"].str.slice(0,4).astype(int).to_dict()
ticket_vis  = ticket_df.set_index("ticket_id")["visitor_id_FK"].to_dict()
ticket_ids  = list(ticket_df["ticket_id"])

with open(f"{OUT_DIR}/Resale_queue.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["resale_id","ticket_id_FK","visitor_id_FK",
                "interest_type","interest_date"])
    for rid in range(1, NUM_RESALE + 1):
        tid = random.choice(ticket_ids)
        yr  = ticket_year[tid]
        d_start = datetime(yr, 1, 1)
        d_end   = datetime(yr, 12, 31, 23, 59, 59)
        int_dt  = fake.date_time_between_dates(d_start, d_end)
        w.writerow([
            rid, tid, ticket_vis[tid],
            random.choice(["seller","buyer"]), int_dt
        ])

print("✅ CSV generated")
