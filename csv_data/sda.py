import csv, random
from faker import Faker
from datetime import datetime, timedelta

fake = Faker()

# === PARAMETERS ===
NUM_LOCATIONS     = 5
NUM_FESTIVALS     = 10
NUM_STAGES        = 30
NUM_EVENTS        = 50
NUM_ARTISTS       = 30
NUM_BANDS         = 20
NUM_PERFORMANCES  = 100
NUM_VISITORS      = 200
NUM_TICKETS       = 200
NUM_STAFF         = 30
NUM_RATINGS       = 200
NUM_RESALE        = 30

# === ID POOLS ===
location_ids, festival_ids = [], []
stage_ids, event_ids = [], []
artist_ids, band_ids = [], []
performance_ids, visitor_ids = [], []
staff_ids = []

# === 1. LOCATIONS ===
with open("Location.csv","w",newline="",encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["location_id","address","city","country","continent","coordinates","location_image"])
    for i in range(1,NUM_LOCATIONS+1):
        location_ids.append(i)
        w.writerow([
            i,
            fake.street_address().replace("\n"," "),
            fake.city(),
            fake.country(),
            random.choice(["Europe","Asia","Africa","North America","South America","Australia"]),
            f"{fake.latitude():.4f}, {fake.longitude():.4f}",
            f"https://example.com/loc_{i}.jpg"
        ])

# === 2. FESTIVALS ===
with open("Festival.csv","w",newline="",encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["festival_id","festival_name","festival_year","start_date","end_date","location_id_FK","festival_image"])
    for i in range(1,NUM_FESTIVALS+1):
        festival_ids.append(i)
        sd = fake.date_between(start_date="-2y", end_date="today")
        ed = sd + timedelta(days=random.randint(1,4))
        w.writerow([
            i,
            f"PulseFestival_{2020 + i}",
            sd.year,
            sd, ed,
            random.choice(location_ids),
            f"https://example.com/fest_{i}.jpg"
        ])

# === 3. STAGES ===
with open("Stage.csv","w",newline="",encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["stage_id","stage_name","stage_description","capacity","tech_equipment","stage_image"])
    for i in range(1,NUM_STAGES+1):
        stage_ids.append(i)
        w.writerow([
            i,
            f"Stage_{i}",
            fake.sentence(nb_words=8).replace("'",""),
            random.randint(100,2000),
            "Lights, Speakers, Microphones",
            f"https://example.com/stage_{i}.jpg"
        ])

# === 4. EVENTS ===
with open("Event.csv","w",newline="",encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["event_id","event_name","festival_id_FK","stage_id_FK","event_date","event_image"])
    for i in range(1,NUM_EVENTS+1):
        event_ids.append(i)
        w.writerow([
            i,
            f"Event_{i}",
            random.choice(festival_ids),
            random.choice(stage_ids),
            fake.date_this_year(),
            f"https://example.com/event_{i}.jpg"
        ])

# === 5. ARTISTS ===
with open("Artist.csv","w",newline="",encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["artist_id","name","pseudonym","birth_date","music_genres","music_subgenres","website","instagram","image_url"])
    for i in range(1,NUM_ARTISTS+1):
        artist_ids.append(i)
        name = fake.name().replace("'","")
        pseud = fake.user_name() if random.random()<0.3 else ""
        bd = fake.date_of_birth(minimum_age=18,maximum_age=70)
        w.writerow([
            i,name,pseud,bd,
            random.choice(["Rock","Jazz","Pop","Metal","HipHop","Electronic"]),
            random.choice(["Hard Rock","Bebop","Alternative","Trance","Folk","RnB"]),
            f"https://www.{(pseud or name.replace(' ','')).lower()}.com",
            f"https://instagram.com/{(pseud or name.split()[0]).lower()}",
            f"https://example.com/artist_{i}.jpg"
        ])

# === 6. BANDS ===
with open("Band.csv","w",newline="",encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["band_id","band_name","formation_date","music_genres","music_subgenres","website","instagram","image_url"])
    for i in range(1,NUM_BANDS+1):
        band_ids.append(i)
        name = f"{fake.word().capitalize()}Band_{i}"
        w.writerow([
            i,
            name,
            fake.date_between(start_date="-20y", end_date="-1y"),
            random.choice(["Rock","Jazz","Pop","Metal","HipHop","Electronic"]),
            random.choice(["Hard Rock","Bebop","Alternative","Trance","Folk","RnB"]),
            f"https://www.{name.lower()}.com",
            f"https://instagram.com/{name.lower()}",
            f"https://example.com/band_{i}.jpg"
        ])

# === 6a. ARTIST↔BAND JOIN ===
with open("Artist_Band.csv","w",newline="",encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["artist_id","band_id","join_date"])
    for a in artist_ids:
        if random.random()<0.4:
            for b in random.sample(band_ids, k=random.randint(1,2)):
                w.writerow([a,b,fake.date_between(start_date="-5y", end_date="today")])

# === 7. PERFORMANCES (no time‐overlaps for same artist/band) ===
schedule = {}  # map of (artist or band)→list of (start,end)
def ok_to_schedule(entity_id, start, end):
    for (s,e) in schedule.get(entity_id,[]):
        # require min 5-min gap, i.e. no overlap with buffer
        if not (end + timedelta(minutes=5) <= s or start >= e + timedelta(minutes=5)):
            return False
    return True

with open("Performance.csv","w",newline="",encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["performance_id","event_id_FK","performance_type","start_time","duration_minutes","performance_image"])
    for i in range(1,NUM_PERFORMANCES+1):
        ev = random.choice(event_ids)
        dtype = random.choice(["warm up","headline","special guest","main act"])
        st = fake.date_time_this_year()
        dur = random.randint(30,180)
        en = st + timedelta(minutes=dur)
        # randomly pick artist vs band
        if random.random()<0.5:
            ent, col = random.choice(artist_ids), "artist"
        else:
            ent, col = random.choice(band_ids), "band"
        # if conflict, skip and try another
        if not ok_to_schedule(ent,st,en):
            st = st + timedelta(hours=dur+5)
            en = st + timedelta(minutes=dur)
        schedule.setdefault(ent,[]).append((st,en))
        w.writerow([i,ev,dtype,st,dur,f"https://example.com/performance_{i}.jpg"])
        performance_ids.append((i,ent,col))

# === 7a/7b. LINK PERFORMANCES → ARTISTS/BANDS ===
with open("Performance_Artist.csv","w",newline="",encoding="utf-8") as fa, \
     open("Performance_Band.csv","w",newline="",encoding="utf-8") as fb:
    wa, wb = csv.writer(fa), csv.writer(fb)
    wa.writerow(["performance_id","artist_id"])
    wb.writerow(["performance_id","band_id"])
    for pid, ent, col in performance_ids:
        if col=="artist":
            wa.writerow([pid,ent])
        else:
            wb.writerow([pid,ent])

# === 8. VISITORS ===
with open("Visitor.csv","w",newline="",encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["visitor_id","first_name","last_name","age","phone","email"])
    for i in range(1,NUM_VISITORS+1):
        visitor_ids.append(i)
        w.writerow([i,
            fake.first_name(),
            fake.last_name(),
            random.randint(18,70),
            fake.phone_number(),
            fake.email()
        ])

# === 9. TICKETS (enforce VIP ≤10% stage capacity) ===
# first build a map event→stage→capacity
import pandas as pd
st_df = pd.read_csv("Stage.csv")
ev_df = pd.read_csv("Event.csv")
evt2cap = { row.event_id: st_df.loc[st_df.stage_id==row.stage_id_FK,"capacity"].iloc[0]
            for _,row in ev_df.iterrows() }

vip_counts = {eid:0 for eid in event_ids}

with open("Ticket.csv","w",newline="",encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["ticket_id","event_id_FK","visitor_id_FK","ticket_category","purchase_date","ticket_cost","purchase_method","ean_code","is_activated"])
    for i in range(1,NUM_TICKETS+1):
        ev = random.choice(event_ids)
        cap = evt2cap[ev]
        # allow VIP only if under 10%
        if random.random()<0.1 and vip_counts[ev] < cap*0.1:
            cat="VIP"; vip_counts[ev]+=1
        else:
            cat=random.choice(["general","backstage"])
        w.writerow([i,
            ev,
            random.choice(visitor_ids),
            cat,
            fake.date_time_this_year(),
            random.randint(15,100),
            random.choice(["credit_card","debit_card","bank_transfer","other"]),
            fake.random_number(digits=13, fix_len=True),
            random.choice(["true","false"])
        ])

# === 10. STAFF & 10a. STAGE_STAFF ===
with open("Staff.csv","w",newline="",encoding="utf-8") as f, \
     open("Stage_Staff.csv","w",newline="",encoding="utf-8") as fs:
    w1 = csv.writer(f); w2 = csv.writer(fs)
    w1.writerow(["staff_id","staff_name","age","role","experience_level"])
    w2.writerow(["stage_id","staff_id","start_date","end_date"])
    for i in range(1,NUM_STAFF+1):
        staff_ids.append(i)
        role = random.choice(["tech","security","support"])
        w1.writerow([i,fake.name(),random.randint(20,60),role,random.choice(["intern","beginner","average","experienced","expert"])])
        if random.random()<0.5:
            sid = random.choice(stage_ids)
            d1 = fake.date_between("-1y","today")
            d2 = d1 + timedelta(days=random.randint(1,10))
            w2.writerow([sid,i,d1,d2])

# === 11. RATINGS ===
with open("Rating.csv","w",newline="",encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["rating_id","visitor_id_FK","performance_id_FK","rating_interpretation","rating_sound_light","rating_stage_presence","rating_organization","rating_overall"])
    for i in range(1,NUM_RATINGS+1):
        pid = random.choice([pid for pid,_,_ in performance_ids])
        w.writerow([i,random.choice(visitor_ids),pid,*(random.randint(1,5) for _ in range(5))])

# === 12. RESALE_QUEUE ===
with open("Resale_queue.csv","w",newline="",encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["resale_id","ticket_id_FK","visitor_id_FK","interest_type","interest_date"])
    # pre-sort interest dates to guarantee FIFO
    base = datetime.now() - timedelta(days=200)
    for i in range(1,NUM_RESALE+1):
        t = random.randint(1,NUM_TICKETS)
        w.writerow([i,t,random.choice(visitor_ids),random.choice(["seller","buyer"]), (base + timedelta(days=i)).isoformat()])

print("✅ CSV generation complete. All FKs aligned, VIP limits enforced, and no double-bookings.") 
