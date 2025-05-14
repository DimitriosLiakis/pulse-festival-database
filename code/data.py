#!/usr/bin/env python3

import os, csv, random, math, warnings
from datetime import datetime, timedelta, time
from faker import Faker
import pandas as pd

OUT_DIR = "csv_data"
os.makedirs(OUT_DIR, exist_ok=True)

# ---------------------------- parameters ----------------------------
NUM_LOCATIONS, NUM_FESTIVALS, NUM_STAGES   = 10, 10, 30
NUM_EVENTS,    NUM_ARTISTS,  NUM_BANDS     = 50, 30, 20
NUM_PERFORMANCES, NUM_VISITORS             = 100, 200
NUM_TICKETS,  NUM_STAFF, NUM_RATINGS       = 300, 30, 400
NUM_RESALE,   MAX_TRIES                    = 50, 20

GENRES = {
    "rock":       ["hard rock", "indie rock", "alternative"],
    "jazz":       ["bebop", "smooth jazz", "fusion"],
    "pop":        ["synth-pop", "electro-pop", "dance-pop"],
    "hip-hop":    ["trap", "boom bap", "lo-fi"],
    "electronic": ["house", "techno", "drum&bass"]
}
GENRE_KEYS = list(GENRES.keys())

location_ids    = list(range(1, NUM_LOCATIONS+1))
festival_ids    = list(range(1, NUM_FESTIVALS+1))
stage_ids       = list(range(1, NUM_STAGES+1))
event_ids       = list(range(1, NUM_EVENTS+1))
artist_ids      = list(range(1, NUM_ARTISTS+1))
band_ids        = list(range(1, NUM_BANDS+1))
performance_ids = list(range(1, NUM_PERFORMANCES+1))
visitor_ids     = list(range(1, NUM_VISITORS+1))
staff_ids       = list(range(1, NUM_STAFF+1))

fake = Faker()
Faker.seed(42)
random.seed(42)
warnings.filterwarnings("ignore", category=FutureWarning)

def rnd_time(h_from=10, h_to=23):
    return time(random.randint(h_from, h_to),
                random.choice([0, 15, 30, 45]), 0)

def ean13():
    base = [random.randint(0, 9) for _ in range(12)]
    total = sum((3 if i % 2 else 1) * d for i, d in enumerate(base))
    check = (10 - total % 10) % 10
    return ''.join(map(str, base+[check]))

# -- 1) LOCATION
with open(f"{OUT_DIR}/Location.csv", "w", newline="", encoding="utf‑8") as f:
    w = csv.writer(f)
    w.writerow(["location_id","address","city","country","continent",
                "coordinates","location_image","location_image_alt"])
    for lid in location_ids:
        lat, lon = fake.latitude(), fake.longitude()
        w.writerow([lid, fake.street_address(), fake.city(), fake.country(),
                    random.choice(["Europe","Asia","Africa","North America",
                                   "South America","Australia"]),
                    f"POINT({lon:.4f} {lat:.4f})",
                    f"https://example.com/location_{lid}.jpg",
                    f"https://example.com/location_{lid}_alt.jpg"])

# -- 2) FESTIVAL
YEAR_POOL = list(range(2017, 2027))
festival_dates = {}
with open(f"{OUT_DIR}/Festival.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow([
        "festival_id","festival_name","festival_year","start_date",
        "end_date","location_id_FK","festival_image","festival_image_alt"
    ])
    for fid, yr in zip(festival_ids, YEAR_POOL):
        # 1:1 mapping: festival i → location_ids[i-1]
        sd = datetime(yr, random.randint(5, 8), random.randint(1, 5)).date()
        ed = sd + timedelta(days=random.randint(1, 4))
        festival_dates[fid] = (sd, ed)
        loc_id = location_ids[fid - 1]
        w.writerow([
            fid, f"PulseFestival_{yr}", yr, sd, ed,
            loc_id,
            f"https://example.com/fest_{fid}.jpg",
            f"https://example.com/fest_{fid}_alt.jpg"
        ])


# -- 3) STAGE
with open(f"{OUT_DIR}/Stage.csv", "w", newline="", encoding="utf‑8") as f:
    w = csv.writer(f)
    w.writerow(["stage_id","stage_name","building_name","capacity",
                "tech_equipment","stage_image","stage_image_alt","stage_description"])
    for sid in stage_ids:
        w.writerow([sid, f"Stage_{sid}", f"{fake.word().capitalize()} Hall",
                    random.randint(100, 2000), "Lights,Speakers,Microphones",
                    f"https://example.com/stage_{sid}.jpg",
                    f"https://example.com/stage_{sid}_alt.jpg",
                    fake.sentence(nb_words=8)])

# -- 4) EVENT   
events = []
with open(f"{OUT_DIR}/Event.csv", "w", newline="", encoding="utf‑8") as f:
    w = csv.writer(f)
    w.writerow(["event_id","festival_id_FK","stage_id_FK","event_name",
                "event_date","start_time","end_time",
                "event_image","event_image_alt"])

    eid = 0
    MIN_EVENTS_F1 = 3  

    for _ in range(MIN_EVENTS_F1):
        eid += 1
        fid = 1
        sd, ed = festival_dates[fid]
        day = sd + timedelta(days=random.randint(0, (ed-sd).days))
        dur_h = random.randint(2, 6)
        st = rnd_time(10, 23-dur_h)
        et = (datetime.combine(day, st)+timedelta(hours=dur_h)).time()
        sid = random.choice(stage_ids)
        events.append((eid, fid, sid, datetime.combine(day, st),
                       datetime.combine(day, et)))
        w.writerow([eid, fid, sid, f"Event_{eid}", day, st, et,
                    f"https://example.com/event_{eid}.jpg",
                    f"https://example.com/event_{eid}_alt.jpg"])

    while eid < NUM_EVENTS:
        eid += 1
        fid = random.choice(festival_ids)
        sd, ed = festival_dates[fid]
        day = sd + timedelta(days=random.randint(0, (ed-sd).days))
        dur_h = random.randint(2, 6)
        st = rnd_time(10, 23-dur_h)
        et = (datetime.combine(day, st)+timedelta(hours=dur_h)).time()
        sid = random.choice(stage_ids)
        events.append((eid, fid, sid, datetime.combine(day, st),
                       datetime.combine(day, et)))
        w.writerow([eid, fid, sid, f"Event_{eid}", day, st, et,
                    f"https://example.com/event_{eid}.jpg",
                    f"https://example.com/event_{eid}_alt.jpg"])

# -- 5) ARTIST
with open(f"{OUT_DIR}/Artist.csv", "w", newline="", encoding="utf‑8") as f:
    w = csv.writer(f)
    w.writerow(["artist_id","real_name","pseudonym","birth_date",
                "music_genre","sub_genre","website","instagram",
                "artist_image","artist_image_alt"])
    for aid in artist_ids:
        real = fake.name().replace("'", "")
        stage = fake.user_name() if random.random()<0.3 else ""
        main  = random.choice(GENRE_KEYS)
        sub   = random.choice(GENRES[main])
        slug  = (stage or real.replace(" ","").lower())
        w.writerow([aid, real, stage, fake.date_of_birth(minimum_age=18, maximum_age=70),
                    main, sub, f"https://www.{slug}.com",
                    f"https://instagram.com/{slug}",
                    f"https://example.com/artist_{aid}.jpg",
                    f"https://example.com/artist_{aid}_alt.jpg"])

# -- 6) BAND
with open(f"{OUT_DIR}/Band.csv", "w", newline="", encoding="utf‑8") as f:
    w = csv.writer(f)
    w.writerow(["band_id","band_name","formation_date","music_genre","sub_genre",
                "website","instagram","band_image","band_image_alt"])
    for bid in band_ids:
        name = f"{fake.word().capitalize()} Band"
        main = random.choice(GENRE_KEYS)
        sub  = random.choice(GENRES[main])
        slug = name.replace(" ","").lower()
        w.writerow([bid, name, fake.date_between("-20y","-1y"),
                    main, sub, f"https://www.{slug}.com",
                    f"https://instagram.com/{slug}",
                    f"https://example.com/band_{bid}.jpg",
                    f"https://example.com/band_{bid}_alt.jpg"])

# -- 6a) Artist_Band
with open(f"{OUT_DIR}/Artist_Band.csv", "w", newline="", encoding="utf‑8") as f:
    w = csv.writer(f)
    w.writerow(["artist_id_FK","band_id_FK","join_date"])
    for aid in artist_ids:
        if random.random() < .4:
            for bid in random.sample(band_ids, k=random.randint(1,2)):
                w.writerow([aid, bid, fake.date_between("-5y","-1d")])

# -- 7) PERFORMANCE 
artist_sched, band_sched, perf_map = {aid:[] for aid in artist_ids}, \
                                     {bid:[] for bid in band_ids}, []
with open(f"{OUT_DIR}/Performance.csv","w",newline="",encoding="utf‑8") as f:
    w = csv.writer(f)
    w.writerow(["performance_id","event_id_FK","performance_type",
                "start_time","end_time","performance_image","performance_image_alt"])
    for pid in performance_ids:
        placed, tries = False, 0
        while not placed and tries < MAX_TRIES:
            tries += 1
            eid, _, _, ev_start, ev_end = random.choice(events)
            dur = random.randint(30,180)
            latest_start = ev_end - timedelta(minutes=dur)
            if latest_start <= ev_start: continue
            sdt = ev_start + timedelta(minutes=random.randint(
                   0, int((latest_start-ev_start).total_seconds()//60)))
            edt = sdt + timedelta(minutes=dur)
            if random.random() < .5:
                ent_id, sched, kind = random.choice(artist_ids), artist_sched, "artist"
            else:
                ent_id, sched, kind = random.choice(band_ids), band_sched, "band"
            if all(edt <= s or sdt >= e for s,e in sched[ent_id]):
                sched[ent_id].append((sdt,edt)); placed = True
        if not placed:     
            eid, _, _, ev_start, _ = events[0]
            ent_id, kind = artist_ids[0], "artist"
            sdt, edt = ev_start, ev_start+timedelta(minutes=60)
            artist_sched[ent_id].append((sdt,edt))
        w.writerow([pid, eid, random.choice(["warm up","headline","special guest","main act"]),
                    sdt.time(), edt.time(),
                    f"https://example.com/perf_{pid}.jpg",
                    f"https://example.com/perf_{pid}_alt.jpg"])
        perf_map.append((pid, ent_id, kind))

with open(f"{OUT_DIR}/Performance_Artist.csv","w",newline="",encoding="utf‑8") as fa, \
     open(f"{OUT_DIR}/Performance_Band.csv","w",newline="",encoding="utf‑8") as fb:
    wa, wb = csv.writer(fa), csv.writer(fb)
    wa.writerow(["performance_id_FK","artist_id_FK","band_id_FK"])
    wb.writerow(["performance_id_FK","band_id_FK","artist_id_FK"])
    for pid, ent, kind in perf_map:
        if kind=="artist":
            wa.writerow([pid, ent, r"\N"])
        else:
            wb.writerow([pid, ent, r"\N"])

# -- 8) VISITOR
with open(f"{OUT_DIR}/Visitor.csv","w",newline="",encoding="utf‑8") as f:
    w = csv.writer(f)
    w.writerow(["visitor_id","first_name","last_name","contact_info","visitor_age"])
    for vid in visitor_ids:
        w.writerow([vid, fake.first_name(), fake.last_name(),
                    f"{fake.phone_number()} | {fake.email()}",
                    random.randint(18,70)])

# -- 9) TICKET
stage_df = pd.read_csv(f"{OUT_DIR}/Stage.csv")
event_df = pd.read_csv(f"{OUT_DIR}/Event.csv", parse_dates=['event_date'])
cap_lookup = stage_df.set_index("stage_id")["capacity"].to_dict()
event_df["cap"]  = event_df.stage_id_FK.map(cap_lookup)
event_df["year"] = event_df.event_date.dt.year
vip_used, seen_tv = {eid:0 for eid in event_ids}, set()
with open(f"{OUT_DIR}/Ticket.csv","w",newline="",encoding="utf‑8") as f:
    w = csv.writer(f)
    w.writerow(["ticket_id","event_id_FK","visitor_id_FK","ticket_category",
                "purchase_date","ticket_cost","purchase_method",
                "ean_code","is_activated"])
    tid = 0
    while tid < NUM_TICKETS:
        eid, vid = random.choice(event_ids), random.choice(visitor_ids)
        if (vid,eid) in seen_tv: continue
        seen_tv.add((vid,eid)); tid += 1
        cap = int(event_df.loc[event_df.event_id==eid,"cap"])
        cat = ("VIP" if random.random()<0.1 and
               vip_used[eid] < math.ceil(cap*0.1) else
               random.choice(["general","backstage"]))
        if cat=="VIP": vip_used[eid] += 1
        yr = int(event_df.loc[event_df.event_id==eid,"year"])
        pd_start, pd_end = datetime(yr,1,1), datetime(yr,12,31,23,59,59)
        w.writerow([tid, eid, vid, cat,
                    fake.date_time_between(pd_start, pd_end),
                    random.randint(15,100),
                    random.choice(["credit_card","debit_card","bank_transfer","other"]),
                    ean13(), random.choice([0,1])])

# --10) STAFF & STAGE_STAFF
with open(f"{OUT_DIR}/Staff.csv","w",newline="",encoding="utf‑8") as fs, \
     open(f"{OUT_DIR}/Stage_Staff.csv","w",newline="",encoding="utf‑8") as fss:
    ws, wss = csv.writer(fs), csv.writer(fss)
    ws.writerow(["staff_id","staff_name","staff_age","staff_role",
                 "experience_level","staff_image","staff_image_alt"])
    wss.writerow(["stage_id_FK","staff_id_FK","start_date","end_date"])
    for sid in staff_ids:
        role = random.choice(["tech","security","support"])
        exp  = random.choice(["intern","beginner","average","experienced","expert"])
        ws.writerow([sid, fake.name(), random.randint(20,60), role, exp,
                     f"https://example.com/staff_{sid}.jpg",
                     f"https://example.com/staff_{sid}_alt.jpg"])
        fid = random.choice(festival_ids); sd, ed = festival_dates[fid]
        stage_pool = [s for (_,ff,s,_,_) in events if ff==fid]
        if stage_pool:
            stg = random.choice(stage_pool)
            s_date = sd + timedelta(days=random.randint(0,(ed-sd).days))
            e_date = s_date + timedelta(days=random.randint(0,(ed-s_date).days))
            wss.writerow([stg, sid, s_date, e_date])

# --11) RATING
with open(f"{OUT_DIR}/Rating.csv","w",newline="",encoding="utf‑8") as fr:
    w = csv.writer(fr)
    w.writerow(["rating_id","visitor_id_FK","performance_id_FK",
                "rating_interpretation","rating_sound_light",
                "rating_stage_presence","rating_organization",
                "rating_overall","rating_date"])
    rid, seen_r = 0, set()
    while rid < NUM_RATINGS:
        vid, pid = random.choice(visitor_ids), random.choice(performance_ids)
        if (vid,pid) in seen_r: continue
        seen_r.add((vid,pid)); rid += 1
        w.writerow([rid,vid,pid]+[random.randint(1,5) for _ in range(5)] +
                   [fake.date_between("-2y","today")])

# --12) Resale_queue 
ticket_df = pd.read_csv(f"{OUT_DIR}/Ticket.csv", parse_dates=["purchase_date"])
with open(f"{OUT_DIR}/Resale_queue.csv","w",newline="",encoding="utf‑8") as f:
    w = csv.writer(f)
    w.writerow(["queue_id","ticket_id_FK","visitor_id_FK","event_id_FK",
                "interest_type","interest_date"])
    for qid in range(1, NUM_RESALE+1):
        tk = ticket_df.sample(1, random_state=qid).iloc[0]
        w.writerow([qid, int(tk.ticket_id), int(tk.visitor_id_FK),
                    int(tk.event_id_FK),
                    random.choice(["seller","buyer"]),
                    fake.date_time_between_dates(tk.purchase_date,
                                                 tk.purchase_date+timedelta(days=200))])

perf_df   = pd.read_csv(f"{OUT_DIR}/Performance.csv")
pa_df     = pd.read_csv(f"{OUT_DIR}/Performance_Artist.csv")
evt_df    = pd.read_csv(f"{OUT_DIR}/Event.csv", parse_dates=["event_date"])
staff_df  = pd.read_csv(f"{OUT_DIR}/Staff.csv")
ss_df     = pd.read_csv(f"{OUT_DIR}/Stage_Staff.csv", parse_dates=["start_date","end_date"])
artist_df = pd.read_csv(f"{OUT_DIR}/Artist.csv")

# Seed 3
evs1 = evt_df[evt_df.festival_id_FK==1].head(3)
next_pid = perf_df.performance_id.max()+1
for idx, ev in evs1.iterrows():
    st = datetime.combine(ev.event_date, time(12+idx))
    perf_df.loc[len(perf_df)] = [next_pid, ev.event_id, "warm up",
                                 st.time(), (st+timedelta(minutes=30)).time(),
                                 f"https://example.com/seed_wu_{next_pid}.jpg",
                                 f"https://example.com/seed_wu_{next_pid}_alt.jpg"]
    pa_df.loc[len(pa_df)]    = [next_pid, 1, ""]
    next_pid += 1

# Seed 7
tech_ids = staff_df[staff_df.staff_role=="tech"].staff_id.tolist()
for fid,(sd,ed) in festival_dates.items():
    stg = evt_df[evt_df.festival_id_FK==fid].stage_id_FK.iloc[0]
    if ss_df[(ss_df.stage_id_FK==stg)&(ss_df.staff_id_FK.isin(tech_ids))].empty:
        ss_df.loc[len(ss_df)] = [stg, tech_ids[0], sd, ed]

# Seed 9
first_year = evt_df.event_date.dt.year.min()
evs_year = evt_df[evt_df.event_date.dt.year==first_year].event_id.sample(4, random_state=1)
for vis in [1,2]:
    for k, eid in enumerate(evs_year):
        st = datetime.combine(evt_df.loc[evt_df.event_id==eid,'event_date'].iloc[0],
                              time(14+k))
        perf_df.loc[len(perf_df)] = [next_pid, eid, "headline",
                                     st.time(), (st+timedelta(minutes=45)).time(),
                                     f"https://example.com/seed9_{next_pid}.jpg",
                                     f"https://example.com/seed9_{next_pid}_alt.jpg"]
        pa_df.loc[len(pa_df)]    = [next_pid, artist_ids[0], ""]
        next_pid += 1

# Seed 14
perf_tmp = (perf_df.merge(pa_df, left_on="performance_id",
                          right_on="performance_id_FK", how="left")
                    .merge(artist_df[['artist_id','music_genre']],
                           left_on="artist_id_FK", right_on="artist_id",
                           how="left")
                    .merge(evt_df[['event_id','event_date']],
                           left_on="event_id_FK", right_on="event_id",
                           how="left"))
perf_tmp['year'] = pd.to_datetime(perf_tmp.event_date).dt.year
cnt = (perf_tmp[perf_tmp.music_genre=="rock"]
       .groupby("year").size().reindex([2023,2024], fill_value=0))
target = max(3, cnt.max())
rock_id = artist_df[artist_df.music_genre=="rock"].artist_id.iloc[0]
for year in [2023, 2024]:
    missing = target - cnt.get(year,0)
    if missing <= 0: continue
    ev_id = evt_df[evt_df.event_date.dt.year==year].event_id.iloc[0]
    for i in range(missing):
        st = time(18, i*15)
        ed = (datetime.combine(datetime.today(), st) +
              timedelta(minutes=60)).time()
        perf_df.loc[len(perf_df)] = [next_pid, ev_id, "main act", st, ed,
                                     f"https://example.com/seed14_{next_pid}.jpg",
                                     f"https://example.com/seed14_{next_pid}_alt.jpg"]
        pa_df.loc[len(pa_df)] = [next_pid, rock_id, ""]
        next_pid += 1

# -- SELF‑TEST
def _self_test():
    p_artist = perf_df.merge(pa_df, left_on="performance_id",
                             right_on="performance_id_FK")
    p_full = p_artist.merge(evt_df[['event_id','festival_id_FK','event_date']],
                            left_on="event_id_FK", right_on="event_id")
    assert len(p_full[(p_full.performance_type=="warm up") &
                      (p_full.festival_id_FK==1) &
                      (p_full.artist_id_FK==1)]) >= 3, \
           "Seed 3 failed"
    for fid in festival_ids:
        stg_ids = evt_df[evt_df.festival_id_FK==fid].stage_id_FK.unique()
        ok = ss_df[(ss_df.stage_id_FK.isin(stg_ids)) &
                   (ss_df.staff_id_FK.isin(
                       staff_df[staff_df.staff_role=="tech"].staff_id))]
        assert not ok.empty, f"Seed 7 failed for festival {fid}"
    year0 = evt_df.event_date.dt.year.min()
    for vid in [1,2]:
        cnt = len(p_full[(p_full.artist_id_FK==1) &
                         (p_full.event_date.dt.year==year0)])
        assert cnt >= 4, f"Seed 9 failed for visitor {vid}"
    rock = p_artist.merge(artist_df[['artist_id','music_genre']],
                          left_on="artist_id_FK", right_on="artist_id") \
                   .merge(evt_df[['event_id','event_date']],
                          left_on="event_id_FK", right_on="event_id")
    rock['year'] = rock.event_date.dt.year
    cnt = rock[rock.music_genre=="rock"].groupby('year').size()
    for y in [2023, 2024]:
        assert cnt.get(y,0) >= 3, f"Seed 14 failed for {y}"

_self_test()
print("✅  Self‑test passed – all seed scenarios satisfied.")

perf_df.to_csv(f"{OUT_DIR}/Performance.csv", index=False)
pa_df.to_csv(f"{OUT_DIR}/Performance_Artist.csv", index=False)
ss_df.to_csv(f"{OUT_DIR}/Stage_Staff.csv", index=False)

print("✅ New‑schema CSVs generated (with seeded cases 3, 7, 9, 14).")
