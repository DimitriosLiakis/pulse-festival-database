#!/usr/bin/env python3

import os
import csv
import random
import math
from faker import Faker
from datetime import datetime, timedelta
import pandas as pd
import warnings

# -----------------------------------
# Configuration & Parameters
# -----------------------------------
OUT_DIR = "csv_data"
os.makedirs(OUT_DIR, exist_ok=True)

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
MAX_TRIES         = 20

GENRES = {
    "rock":       ["hard rock", "indie rock", "alternative"],
    "jazz":       ["bebop", "smooth jazz", "fusion"],
    "pop":        ["synth-pop", "electro-pop", "dance-pop"],
    "hip-hop":    ["trap", "boom bap", "lo-fi"],
    "electronic": ["house", "techno", "drum&bass"]
}
GENRE_KEYS = list(GENRES.keys())

# ID pools
location_ids    = list(range(1, NUM_LOCATIONS+1))
festival_ids    = list(range(1, NUM_FESTIVALS+1))
stage_ids       = list(range(1, NUM_STAGES+1))
event_ids       = list(range(1, NUM_EVENTS+1))
artist_ids      = list(range(1, NUM_ARTISTS+1))
band_ids        = list(range(1, NUM_BANDS+1))
performance_ids = list(range(1, NUM_PERFORMANCES+1))
visitor_ids     = list(range(1, NUM_VISITORS+1))
staff_ids       = list(range(1, NUM_STAFF+1))

# Faker initialization
fake = Faker()
Faker.seed(42)
random.seed(42)

# Utility: generate valid EAN-13
def generate_ean13():
    base = [random.randint(0, 9) for _ in range(12)]
    total = sum((3 if i % 2 == 0 else 1) * d for i, d in enumerate(base))
    check = (10 - (total % 10)) % 10
    return ''.join(str(d) for d in base) + str(check)

# -----------------------------------
# 1) LOCATION
# -----------------------------------
with open(f"{OUT_DIR}/Location.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["location_id","address","city","country","continent","coordinates","location_image"])
    for lid in location_ids:
        lat, lon = fake.latitude(), fake.longitude()
        w.writerow([
            lid,
            fake.street_address(),
            fake.city(),
            fake.country(),
            random.choice(["Europe","Asia","Africa","North America","South America","Australia"]),
            f"POINT({lon:.4f} {lat:.4f})",
            f"https://example.com/location_{lid}.jpg"
        ])

# -----------------------------------
# 2) FESTIVAL
# -----------------------------------
YEAR_LIST = list(range(2017, 2027))
festival_ids = list(range(1, len(YEAR_LIST)+1))
fest_dates = {}
today = datetime.now()

with open(f"{OUT_DIR}/Festival.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow([
        "festival_id","festival_name","festival_year",
        "start_date","end_date","location_id_FK","festival_image"
    ])
    for fid, year in zip(festival_ids, YEAR_LIST):
        if year == today.year and today.month < 12:
            date_start = today + timedelta(days=30)
            date_end   = datetime(year, 12, 31)
        elif year > today.year:
            date_start = datetime(year, 1, 1)
            date_end   = datetime(year, 12, 31)
        else:
            date_start = datetime(year, 1, 1)
            date_end   = datetime(year, 12, 31)

        sd = fake.date_between_dates(date_start=date_start, date_end=date_end)
        ed = sd + timedelta(days=random.randint(1, 4))
        fest_dates[fid] = (sd, ed)
        w.writerow([
            fid,
            f"PulseFestival_{year}",
            year,
            sd,
            ed,
            random.choice(location_ids),
            f"https://example.com/fest_{fid}.jpg"
        ])

# -----------------------------------
# 3) STAGE
# -----------------------------------
with open(f"{OUT_DIR}/Stage.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow([
        "stage_id","stage_name","stage_description",
        "capacity","tech_equipment","stage_image"
    ])
    for sid in stage_ids:
        w.writerow([
            sid,
            f"Stage_{sid}",
            fake.sentence(nb_words=8),
            random.randint(100, 2000),
            "Lights, Speakers, Microphones",
            f"https://example.com/stage_{sid}.jpg"
        ])

# -----------------------------------
# 4) EVENT
# -----------------------------------
events = []
def add_event(fid, eid, writer):
    sd, ed = fest_dates[fid]
    ev_day = sd + timedelta(days=random.randint(0, (ed - sd).days))
    start_dt = datetime.combine(ev_day, datetime.min.time()) + timedelta(hours=random.randint(12, 22))
    end_dt = start_dt + timedelta(hours=random.randint(2, 8))
    sid = random.choice(stage_ids)
    events.append((eid, fid, sid, start_dt, end_dt))
    writer.writerow([
        eid,
        f"Event_{eid}",
        fid,
        sid,
        start_dt,
        end_dt,
        f"https://example.com/event_{eid}.jpg"
    ])

with open(f"{OUT_DIR}/Event.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow([
        "event_id","event_name","festival_id_FK",
        "stage_id_FK","event_start","event_end","event_image"
    ])
    eid = 0
    for fid in festival_ids:
        eid += 1
        add_event(fid, eid, w)
    while eid < NUM_EVENTS:
        eid += 1
        add_event(random.choice(festival_ids), eid, w)

# -----------------------------------
# 5) ARTIST
# -----------------------------------
with open(f"{OUT_DIR}/Artist.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow([
        "artist_id","name","pseudonym","birth_date",
        "main_genre","sub_genre","website","instagram","image_url"
    ])
    for aid in artist_ids:
        name = fake.name().replace("'", "")
        pseudo = fake.user_name() if random.random() < 0.3 else ""
        bd = fake.date_of_birth(minimum_age=18, maximum_age=70)
        main = random.choice(GENRE_KEYS)
        sub  = random.choice(GENRES[main])
        slug = (pseudo or name.replace(" ", "").lower())
        w.writerow([
            aid,
            name,
            pseudo,
            bd,
            main,
            sub,
            f"https://www.{slug}.com",
            f"https://instagram.com/{slug}",
            f"https://example.com/artist_{aid}.jpg"
        ])

# -----------------------------------
# 6) BAND
# -----------------------------------
with open(f"{OUT_DIR}/Band.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow([
        "band_id","band_name","formation_date",
        "website","instagram","image_url"
    ])
    for bid in band_ids:
        bn = f"{fake.word().capitalize()}Band_{bid}"
        slug = bn.lower()
        w.writerow([
            bid,
            bn,
            fake.date_between(start_date="-20y", end_date="-1y"),
            f"https://www.{slug}.com",
            f"https://instagram.com/{slug}",
            f"https://example.com/band_{bid}.jpg"
        ])

# -----------------------------------
# 6a) ARTIST_BAND
# -----------------------------------
with open(f"{OUT_DIR}/Artist_Band.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["artist_id","band_id","join_date"])
    for aid in artist_ids:
        if random.random() < 0.4:
            for bid in random.sample(band_ids, k=random.randint(1, 2)):  
                w.writerow([aid, bid, fake.date_between(start_date="-5y", end_date="today")])

# -----------------------------------
# 7) PERFORMANCE & Performance_Artist/Band
# -----------------------------------
artist_sched = {aid: [] for aid in artist_ids}
band_sched   = {bid: [] for bid in band_ids}
perf_map     = []

with open(f"{OUT_DIR}/Performance.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow([
        "performance_id","event_id_FK","performance_type",
        "start_time","duration_minutes","performance_image"
    ])
    for pid in performance_ids:
        placed = False
        tries = 0
        while not placed and tries < MAX_TRIES:
            tries += 1
            eid, fid, sid, st, ed = random.choice(events)
            dur = random.randint(30, 180)
            last = ed - timedelta(minutes=dur)
            if last <= st:
                continue
            start = st + timedelta(minutes=random.randint(0, int((last-st).total_seconds()//60)))
            end   = start + timedelta(minutes=dur)
            if random.random() < 0.5:
                ent, sched, kind = random.choice(artist_ids), artist_sched, "artist"
            else:
                ent, sched, kind = random.choice(band_ids), band_sched, "band"
            if all(end + timedelta(minutes=5) <= s or start >= e + timedelta(minutes=5)
                   for s, e in sched[ent]):
                sched[ent].append((start, end))
                placed = True
        if not placed:
            eid, _, _, st, _ = events[0]
            ent, kind = artist_ids[0], "artist"
            start = st
            dur = 60
            end = start + timedelta(minutes=dur)
            artist_sched[ent].append((start, end))
        w.writerow([
            pid,
            eid,
            random.choice(["warm up","headline","special guest","main act"]),
            start,
            dur,
            f"https://example.com/performance_{pid}.jpg"
        ])
        perf_map.append((pid, ent, kind))

with open(f"{OUT_DIR}/Performance_Artist.csv", "w", newline="", encoding="utf-8") as fa, \
     open(f"{OUT_DIR}/Performance_Band.csv",   "w", newline="", encoding="utf-8") as fb:
    wa, wb = csv.writer(fa), csv.writer(fb)
    wa.writerow(["performance_id","artist_id"])
    wb.writerow(["performance_id","band_id"])
    for pid, ent, kind in perf_map:
        if kind == "artist":
            wa.writerow([pid, ent])
        else:
            wb.writerow([pid, ent])

# -----------------------------------
# 8) VISITOR
# -----------------------------------
with open(f"{OUT_DIR}/Visitor.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["visitor_id","first_name","last_name","age","phone","email"])
    for vid in visitor_ids:
        w.writerow([
            vid,
            fake.first_name(),
            fake.last_name(),
            random.randint(18, 70),
            fake.phone_number(),
            fake.email()
        ])

# -----------------------------------
# 9) TICKET
# -----------------------------------
stage_df = pd.read_csv(f"{OUT_DIR}/Stage.csv")
event_df = pd.read_csv(f"{OUT_DIR}/Event.csv", parse_dates=['event_start','event_end'])
cap_lookup = dict(stage_df.set_index("stage_id")["capacity"])
evt2cap    = {r.event_id: cap_lookup[r.stage_id_FK] for _, r in event_df.iterrows()}
evt2year   = {r.event_id: r.event_start.year for _, r in event_df.iterrows()}
vip_count  = {eid: 0 for eid in event_ids}
seen = set()

with open(f"{OUT_DIR}/Ticket.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow([
        "ticket_id","event_id_FK","visitor_id_FK","ticket_category",
        "purchase_date","ticket_cost","purchase_method",
        "ean_code","is_activated"
    ])
    tid = 0
    while tid < NUM_TICKETS:
        ev  = random.choice(event_ids)
        vis = random.choice(visitor_ids)
        if (vis, ev) in seen:
            continue
        seen.add((vis, ev))
        cap = evt2cap[ev]
        if random.random() < 0.10 and vip_count[ev] < math.ceil(cap * 0.10):
            cat = "VIP"
            vip_count[ev] += 1
        else:
            cat = random.choice(["general","backstage"])
        yr = evt2year[ev]
        pd_start = datetime(yr, 1, 1)
        pd_end   = datetime(yr, 12, 31, 23, 59, 59)
        purchase_dt = fake.date_time_between_dates(pd_start, pd_end)
        tid += 1
        w.writerow([
            tid,
            ev,
            vis,
            cat,
            purchase_dt,
            random.randint(15, 100),
            random.choice(["credit_card","debit_card","bank_transfer","other"]),
            generate_ean13(),
            random.choice([0, 1])
        ])

# -----------------------------------
# 10) STAFF & STAGE_STAFF
# -----------------------------------
with open(f"{OUT_DIR}/Staff.csv", "w", newline="", encoding="utf-8") as fs, \
     open(f"{OUT_DIR}/Stage_Staff.csv", "w", newline="", encoding="utf-8") as fss:
    ws, wss = csv.writer(fs), csv.writer(fss)
    ws.writerow(["staff_id","staff_name","age","role","experience"])
    wss.writerow(["stage_id","staff_id","start_date","end_date"])
    for sid in staff_ids:
        role = random.choice(["tech","security","support"])
        exp  = random.choice(["intern","beginner","average","experienced","expert"])
        ws.writerow([sid, fake.name(), random.randint(20, 60), role, exp])
        fid = random.choice(festival_ids)
        sd, ed = fest_dates[fid]
        stages = [s for (_, ff, s, _, _) in events if ff == fid]
        if stages:
            stg = random.choice(stages)
            a_sd = sd + timedelta(days=random.randint(0, (ed - sd).days))
            a_ed = a_sd + timedelta(days=random.randint(0, (ed - a_sd).days))
            wss.writerow([stg, sid, a_sd, a_ed])

# -----------------------------------
# 11) RATING
# -----------------------------------
with open(f"{OUT_DIR}/Rating.csv", "w", newline="", encoding="utf-8") as fr:
    w = csv.writer(fr)
    w.writerow([
        "rating_id","visitor_id_FK","performance_id_FK",
        "rating_interpretation","rating_sound_light",
        "rating_stage_presence","rating_organization","rating_overall"
    ])
    rid = 0
    seen_r = set()
    while rid < NUM_RATINGS:
        vis  = random.choice(visitor_ids)
        perf = random.choice(performance_ids)
        if (vis, perf) in seen_r:
            continue
        seen_r.add((vis, perf))
        rid += 1
        w.writerow([rid, vis, perf] + [random.randint(1, 5) for _ in range(5)])

# -----------------------------------
# 12) RESALE_QUEUE
# -----------------------------------
ticket_df   = pd.read_csv(f"{OUT_DIR}/Ticket.csv", parse_dates=['purchase_date'])
ticket_year = ticket_df.purchase_date.dt.year.to_dict()
ticket_vis  = ticket_df.set_index("ticket_id")["visitor_id_FK"].to_dict()

with open(f"{OUT_DIR}/Resale_queue.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["resale_id","ticket_id_FK","visitor_id_FK","interest_type","interest_date"])
    for rid in range(1, NUM_RESALE+1):
        tid_fk = random.choice(ticket_df["ticket_id"])
        yr     = ticket_year[tid_fk]
        d_start= datetime(yr, 1, 1)
        d_end  = datetime(yr, 12, 31, 23, 59, 59)
        int_dt = fake.date_time_between_dates(d_start, d_end)
        w.writerow([rid, tid_fk, ticket_vis[tid_fk], random.choice(["seller","buyer"]), int_dt])

# -----------------------------------
# Seeded cases: queries 3, 7, 9 & 14
# -----------------------------------
perf_df   = pd.read_csv(f"{OUT_DIR}/Performance.csv", parse_dates=['start_time'])
pa_df     = pd.read_csv(f"{OUT_DIR}/Performance_Artist.csv")
evt_df    = pd.read_csv(f"{OUT_DIR}/Event.csv", parse_dates=['event_start','event_end'])
staff_df  = pd.read_csv(f"{OUT_DIR}/Staff.csv")
ss_df     = pd.read_csv(f"{OUT_DIR}/Stage_Staff.csv", parse_dates=['start_date','end_date'])
artist_df = pd.read_csv(f"{OUT_DIR}/Artist.csv")

# Query 3: ensure artist_id=1 has 3 'warm up' in festival_id=1
evs1   = evt_df[evt_df.festival_id_FK == 1].event_id.iloc[:3].tolist()
pid0   = perf_df.performance_id.max() + 1
for idx, eid in enumerate(evs1):
    row = {
        'performance_id': pid0 + idx,
        'event_id_FK': eid,
        'performance_type': 'warm up',
        'start_time': evt_df.loc[evt_df.event_id==eid, 'event_start'].iloc[0] + timedelta(hours=2+idx),
        'duration_minutes': 30,
        'performance_image': f"https://example.com/seed_warmup_{pid0+idx}.jpg"
    }
    perf_df.loc[len(perf_df)] = row
    pa_df.loc[len(pa_df)] = {'performance_id': pid0 + idx, 'artist_id': 1}

# Query 7: ensure at least one 'tech' staff per festival
for fid in festival_ids:
    stgs  = evt_df[evt_df.festival_id_FK == fid].stage_id_FK.unique()
    techs = staff_df[staff_df.role=='tech'].staff_id.tolist()
    subset = ss_df[(ss_df.stage_id.isin(stgs)) & (ss_df.staff_id.isin(techs))]
    if subset.empty:
        ss_df.loc[len(ss_df)] = {
            'stage_id': stgs[0],
            'staff_id': techs[0],
            'start_date': fest_dates[fid][0],
            'end_date':   fest_dates[fid][1]
        }

# Query 9: ensure visitors 1 & 2 each attend >3 performances same year
year0   = evt_df.event_start.dt.year.iloc[0]
evs_y   = evt_df[evt_df.event_start.dt.year==year0].event_id.sample(4, random_state=1).tolist()
pid1    = perf_df.performance_id.max() + 1
for j, vis in enumerate([1,2]):
    for k, eid in enumerate(evs_y):
        pid = pid1 + j*10 + k
        row = {
            'performance_id': pid,
            'event_id_FK':    eid,
            'performance_type':'headline',
            'start_time':     evt_df.loc[evt_df.event_id==eid,'event_start'].iloc[0] + timedelta(hours=1+k),
            'duration_minutes':45,
            'performance_image':f"https://example.com/seed9_{pid}.jpg"
        }
        perf_df.loc[len(perf_df)] = row
        pa_df.loc[len(pa_df)]    = {'performance_id': pid, 'artist_id': 1}

# ——————————————————————————————
# Query 14: balance rock performances for 2023 & 2024
# ——————————————————————————————
# Merge to count current rock performances per year
perf_merged = (
    perf_df
    .merge(pa_df, on="performance_id")
    .merge(artist_df[['artist_id','main_genre']], on="artist_id")
)
perf_merged['year'] = perf_merged['start_time'].dt.year

cnt23 = len(perf_merged[(perf_merged.year == 2023) & (perf_merged.main_genre == 'rock')])
cnt24 = len(perf_merged[(perf_merged.year == 2024) & (perf_merged.main_genre == 'rock')])

# Target = at least 3, or the larger of the two counts
T = max(3, cnt23, cnt24)
del23 = T - cnt23
del24 = T - cnt24

# Pick one existing rock artist
rock_artist = artist_df[artist_df.main_genre == 'rock'].artist_id.iloc[0]

# Pick one event in each year (falling back to first found)
ev23 = evt_df[evt_df.event_start.dt.year == 2023].event_id.iloc[0]
ev24 = evt_df[evt_df.event_start.dt.year == 2024].event_id.iloc[0]

# Append the needed number of performances to each year
next_pid = perf_df.performance_id.max() + 1
for year, delta, ev in [(2023, del23, ev23), (2024, del24, ev24)]:
    for i in range(delta):
        pid = next_pid
        next_pid += 1
        start = (
            evt_df.loc[evt_df.event_id == ev, 'event_start']
            .iloc[0]
            + timedelta(hours=4 + i)
        )
        # add performance row
        perf_df.loc[len(perf_df)] = {
            'performance_id': pid,
            'event_id_FK':    ev,
            'performance_type':'main act',
            'start_time':     start,
            'duration_minutes': 60,
            'performance_image': f"https://example.com/seed14_{pid}.jpg"
        }
        # link to rock artist
        pa_df.loc[len(pa_df)] = {'performance_id': pid, 'artist_id': rock_artist}


# Write back seeded data
perf_df.to_csv(f"{OUT_DIR}/Performance.csv", index=False)
pa_df.to_csv(f"{OUT_DIR}/Performance_Artist.csv", index=False)
ss_df.to_csv(f"{OUT_DIR}/Stage_Staff.csv", index=False)

print("✅ CSV generated with all seeded cases for queries 3, 7, 9, and 14.")
