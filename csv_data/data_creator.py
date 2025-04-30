import os, csv, random
from faker import Faker
from datetime import datetime, timedelta
import pandas as pd

fake = Faker()

# Output directory
OUT_DIR = "csv_data"
os.makedirs(OUT_DIR, exist_ok=True)

# === PARAMETERS ===
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

# === ID POOLS ===
location_ids    = list(range(1, NUM_LOCATIONS+1))
festival_ids    = list(range(1, NUM_FESTIVALS+1))
stage_ids       = list(range(1, NUM_STAGES+1))
event_ids       = list(range(1, NUM_EVENTS+1))
artist_ids      = list(range(1, NUM_ARTISTS+1))
band_ids        = list(range(1, NUM_BANDS+1))
performance_ids = list(range(1, NUM_PERFORMANCES+1))
visitor_ids     = list(range(1, NUM_VISITORS+1))
staff_ids       = list(range(1, NUM_STAFF+1))

# 1) LOCATIONS
with open(f"{OUT_DIR}/Location.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["location_id","address","city","country","continent","coordinates","location_image"])
    for i in location_ids:
        w.writerow([i,
                    fake.street_address().replace("\n"," "),
                    fake.city(),
                    fake.country(),
                    random.choice(["Europe","Asia","Africa","North America","South America","Australia"]),
                    f"{fake.latitude():.4f}, {fake.longitude():.4f}",
                    f"https://example.com/loc_{i}.jpg"])

# 2) FESTIVALS
fest_dates = {}
with open(f"{OUT_DIR}/Festival.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["festival_id","festival_name","festival_year","start_date","end_date","location_id_FK","festival_image"])
    for i in festival_ids:
        sd = fake.date_between(start_date="-2y", end_date="today")
        ed = sd + timedelta(days=random.randint(1,4))
        fest_dates[i] = (sd, ed)
        w.writerow([i, f"PulseFestival_{2020+i}", sd.year, sd, ed,
                    random.choice(location_ids),
                    f"https://example.com/fest_{i}.jpg"])

# 3) STAGES
with open(f"{OUT_DIR}/Stage.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["stage_id","stage_name","stage_description","capacity","tech_equipment","stage_image"])
    for i in stage_ids:
        w.writerow([i, f"Stage_{i}", fake.sentence(nb_words=8).replace("'",""),
                    random.randint(100,2000),
                    "Lights, Speakers, Microphones",
                    f"https://example.com/stage_{i}.jpg"])

# 4) EVENTS
events = []
with open(f"{OUT_DIR}/Event.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["event_id","event_name","festival_id_FK","stage_id_FK","event_date","event_image"])
    for i in event_ids:
        fid = random.choice(festival_ids)
        sd, ed = fest_dates[fid]
        ev_date = sd + timedelta(days=random.randint(0, (ed-sd).days))
        sid = random.choice(stage_ids)
        events.append((i, fid, sid))
        w.writerow([i, f"Event_{i}", fid, sid, ev_date,
                    f"https://example.com/event_{i}.jpg"])

# 5) ARTISTS
genres    = ["Rock","Jazz","Pop","Metal","HipHop","Electronic"]
subgenres = ["Hard Rock","Bebop","Alternative","Trance","Folk","RnB"]
with open(f"{OUT_DIR}/Artist.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["artist_id","name","pseudonym","birth_date","music_genres","music_subgenres","website","instagram","image_url"])
    for i in artist_ids:
        name   = fake.name().replace("'","")
        pseudo = fake.user_name() if random.random()<0.3 else ""
        bd     = fake.date_of_birth(minimum_age=18, maximum_age=70)
        g      = random.choice(genres)
        sg     = random.choice(subgenres)
        w.writerow([i, name, pseudo, bd, g, sg,
                    f"https://www.{(pseudo or name.replace(' ','')).lower()}.com",
                    f"https://instagram.com/{(pseudo or name.split()[0]).lower()}",
                    f"https://example.com/artist_{i}.jpg"])

# 6) BANDS
with open(f"{OUT_DIR}/Band.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["band_id","band_name","formation_date","music_genres","music_subgenres","website","instagram","image_url"])
    for i in band_ids:
        bn = f"{fake.word().capitalize()}Band_{i}"
        w.writerow([i, bn,
                    fake.date_between(start_date="-20y", end_date="-1y"),
                    random.choice(genres),
                    random.choice(subgenres),
                    f"https://www.{bn.lower()}.com",
                    f"https://instagram.com/{bn.lower()}",
                    f"https://example.com/band_{i}.jpg"])

# 6a) ARTIST_BAND
with open(f"{OUT_DIR}/Artist_Band.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["artist_id","band_id","join_date"])
    for a in artist_ids:
        if random.random() < 0.4:
            for b in random.sample(band_ids, k=random.randint(1,2)):
                w.writerow([a, b, fake.date_between(start_date="-5y", end_date="today")])

# 7) PERFORMANCES
sched = {}
performance_map = []
with open(f"{OUT_DIR}/Performance.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["performance_id","event_id_FK","performance_type","start_time","duration_minutes","performance_image"])
    for i in performance_ids:
        pid, fid, sid = random.choice(events)
        sd, ed = fest_dates[fid]
        st = datetime.combine(sd, datetime.min.time()) + timedelta(hours=random.randint(12,22))
        dur = random.randint(30,180)
        en = st + timedelta(minutes=dur)
        if random.random()<0.5:
            ent, kind = random.choice(artist_ids), "artist"
        else:
            ent, kind = random.choice(band_ids), "band"
        # avoid overlap
        prev = sched.get((kind,ent),[])
        if any(not (en + timedelta(minutes=5) <= s or st >= e + timedelta(minutes=5)) for s,e in prev):
            st = en + timedelta(minutes=5)
            en = st + timedelta(minutes=dur)
        sched.setdefault((kind,ent),[]).append((st,en))
        w.writerow([i, pid, random.choice(["warm up","headline","special guest","main act"]),
                    st, dur, f"https://example.com/performance_{i}.jpg"])
        performance_map.append((i, ent, kind))

# 7a/7b) PERFORMANCE_ARTIST / PERFORMANCE_BAND
with open(f"{OUT_DIR}/Performance_Artist.csv", "w", newline="", encoding="utf-8") as fa, \
     open(f"{OUT_DIR}/Performance_Band.csv",  "w", newline="", encoding="utf-8") as fb:
    wa, wb = csv.writer(fa), csv.writer(fb)
    wa.writerow(["performance_id","artist_id"])
    wb.writerow(["performance_id","band_id"])
    for pid, ent, kind in performance_map:
        if kind=="artist":
            wa.writerow([pid, ent])
        else:
            wb.writerow([pid, ent])

# 8) VISITORS
with open(f"{OUT_DIR}/Visitor.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["visitor_id","first_name","last_name","age","phone","email"])
    for i in visitor_ids:
        w.writerow([i, fake.first_name(), fake.last_name(),
                    random.randint(18,70), fake.phone_number(), fake.email()])

# 9) TICKETS (VIP ≤10%)
stage_df = pd.read_csv(f"{OUT_DIR}/Stage.csv")
event_df = pd.read_csv(f"{OUT_DIR}/Event.csv")
evt2cap  = {row.event_id: stage_df.loc[stage_df.stage_id==row.stage_id_FK,"capacity"].iloc[0]
            for _, row in event_df.iterrows()}
vip_count = {eid:0 for eid in event_ids}
with open(f"{OUT_DIR}/Ticket.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["ticket_id","event_id_FK","visitor_id_FK","ticket_category",
                "purchase_date","ticket_cost","purchase_method","ean_code","is_activated"])
    for i in range(1, NUM_TICKETS+1):
        ev = random.choice(event_ids)
        cap = evt2cap[ev]
        if random.random()<0.1 and vip_count[ev]<cap*0.1:
            cat="VIP"; vip_count[ev]+=1
        else:
            cat=random.choice(["general","backstage"])
        w.writerow([i, ev, random.choice(visitor_ids), cat,
                    fake.date_time_this_year(), random.randint(15,100),
                    random.choice(["credit_card","debit_card","bank_transfer","other"]),
                    fake.random_number(digits=13, fix_len=True),
                    random.choice(["true","false"])])

# 10) STAFF & STAGE_STAFF (overlap guaranteed)
with open(f"{OUT_DIR}/Staff.csv", "w", newline="", encoding="utf-8") as f, \
     open(f"{OUT_DIR}/Stage_Staff.csv", "w", newline="", encoding="utf-8") as fs:
    wf = csv.writer(f); wfs = csv.writer(fs)
    wf.writerow(["staff_id","staff_name","age","role","experience_level"])
    wfs.writerow(["stage_id","staff_id","start_date","end_date"])
    for i in staff_ids:
        role = random.choice(["tech","security","support"])
        exp  = random.choice(["intern","beginner","average","experienced","expert"])
        wf.writerow([i, fake.name(), random.randint(20,60), role, exp])

        # pick a festival and a stage in it
        fid = random.choice(festival_ids)
        sd, ed = fest_dates[fid]
        valid_stages = [sid for (_, f2, sid) in events if f2==fid]
        if not valid_stages:
            continue
        sid = random.choice(valid_stages)
        a_sd = sd + timedelta(days=random.randint(0,(ed-sd).days))
        a_ed = sd + timedelta(days=random.randint(0,(ed-sd).days))
        if a_ed < a_sd:
            a_ed = a_sd
        wfs.writerow([sid, i, a_sd, a_ed])

# 11) RATINGS
with open(f"{OUT_DIR}/Rating.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["rating_id","visitor_id_FK","performance_id_FK",
                "rating_interpretation","rating_sound_light",
                "rating_stage_presence","rating_organization","rating_overall"])
    for i in range(1, NUM_RATINGS+1):
        w.writerow([i, random.choice(visitor_ids),
                    random.choice(performance_ids),
                    *(random.randint(1,5) for _ in range(5))])

# 12) RESALE_QUEUE
with open(f"{OUT_DIR}/Resale_queue.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["resale_id","ticket_id_FK","visitor_id_FK","interest_type","interest_date"])
    base = datetime.now() - timedelta(days=NUM_RESALE)
    for i in range(1, NUM_RESALE+1):
        w.writerow([i,
                    random.randint(1, NUM_TICKETS),
                    random.choice(visitor_ids),
                    random.choice(["seller","buyer"]),
                    (base + timedelta(days=i)).isoformat()])

print("✅ All CSVs generated in", OUT_DIR)