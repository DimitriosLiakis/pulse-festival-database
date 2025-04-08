import csv
import random
from faker import Faker
from datetime import timedelta

fake = Faker()

# Πλήθος εγγραφών ανά πίνακα (μπορείς να προσαρμόσεις τις τιμές)
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

# Λίστες που θα κρατήσουν τα IDs για να επιλέγουμε FKs πιο ρεαλιστικά
location_ids    = []
festival_ids    = []
stage_ids       = []
event_ids       = []
artist_ids      = []
band_ids        = []
performance_ids = []
visitor_ids     = []
staff_ids       = []

# 1. LOCATION
with open("Location.csv", mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    # Γράφουμε header (προσαρμόστε ανάλογα με τις στήλες σας)
    writer.writerow(["location_id", "address", "city", "country", "continent", "coordinates", "location_image"])

    for i in range(1, NUM_LOCATIONS + 1):
        address = fake.street_address().replace("\n"," ")
        city = fake.city()
        country = fake.country()
        continent = random.choice(["Europe","Asia","Africa","North America","South America","Australia"])
        coords = f"{fake.latitude():.4f}, {fake.longitude():.4f}"
        # Προαιρετικά, μπορεί να έχετε image_url
        image_url = f"https://example.com/loc_{i}.jpg"

        writer.writerow([i, address, city, country, continent, coords, image_url])
        location_ids.append(i)

# 2. FESTIVAL
with open("Festival.csv", mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["festival_id","festival_name","festival_year","start_date","end_date","location_id_FK","festival_image"])

    for i in range(1, NUM_FESTIVALS + 1):
        loc_id = random.choice(location_ids)
        festival_name = f"PulseFestival_{2020 + i}"
        start_date = fake.date_between("-2y","today")
        # Κάνουμε το end_date λίγες μέρες μετά το start_date
        end_date = start_date + timedelta(days=random.randint(1,4))
        festival_year = start_date.year
        festival_image = f"https://example.com/fest_{i}.jpg"

        writer.writerow([i, festival_name, festival_year, start_date, end_date, loc_id, festival_image])
        festival_ids.append(i)

# 3. STAGE
with open("Stage.csv", mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["stage_id","stage_name","stage_description","capacity","tech_equipment","stage_image"])

    for i in range(1, NUM_STAGES + 1):
        stage_name = f"Stage_{i}"
        description = fake.sentence(nb_words=8).replace("'","")
        capacity = random.randint(100, 2000)
        tech_equipment = "Lights, Speakers, Microphones"
        stage_image = f"https://example.com/stage_{i}.jpg"
        writer.writerow([i, stage_name, description, capacity, tech_equipment, stage_image])
        stage_ids.append(i)

# 4. EVENT
with open("Event.csv", mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["event_id","event_name","festival_id_FK","stage_id_FK","event_date","event_image"])

    for i in range(1, NUM_EVENTS + 1):
        f_id = random.choice(festival_ids)
        s_id = random.choice(stage_ids)
        date_ = fake.date_this_year()
        event_name = f"Event_{i}"
        event_image = f"https://example.com/event_{i}.jpg"
        writer.writerow([i, event_name, f_id, s_id, date_, event_image])
        event_ids.append(i)

# 5. ARTIST
with open("Artist.csv", mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["artist_id","name","pseudonym","birth_date","music_genres","music_subgenres","website","instagram","image_url"])

    for i in range(1, NUM_ARTISTS + 1):
        name_ = fake.name().replace("'","")
        pseudonym = fake.user_name() if random.random() < 0.3 else ""
        bdate = fake.date_of_birth(minimum_age=18, maximum_age=70)
        genre = random.choice(["Rock","Jazz","Pop","Metal","HipHop","Electronic"])
        subgenre = random.choice(["Hard Rock","Bebop","Alternative","Trance","Folk","RnB"])
        website = f"https://www.{pseudonym if pseudonym else name_.replace(' ','')}.com".lower().replace("'","").replace(",","")
        instagram = f"https://instagram.com/{pseudonym if pseudonym else name_.split()[0]}".lower()
        image_url = f"https://example.com/artist_{i}.jpg"

        writer.writerow([i, name_, pseudonym, bdate, genre, subgenre, website, instagram, image_url])
        artist_ids.append(i)

# 6. BAND
with open("Band.csv", mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["band_id","band_name","formation_date","music_genres","music_subgenres","website","instagram","image_url"])

    for i in range(1, NUM_BANDS + 1):
        band_name = f"{fake.word().capitalize()}Band_{i}"
        formation_date = fake.date_between("-20y","-1y")
        bgenre = random.choice(["Rock","Jazz","Pop","Metal","HipHop","Electronic"])
        bsub = random.choice(["Hard Rock","Bebop","Alternative","Trance","Folk","RnB"])
        website = f"https://www.{band_name.lower()}.com"
        instagram = f"https://instagram.com/{band_name.lower()}"
        image_url = f"https://example.com/band_{i}.jpg"

        writer.writerow([i, band_name, formation_date, bgenre, bsub, website, instagram, image_url])
        band_ids.append(i)

# 6a. ARTIST_BAND (M:N)
with open("Artist_Band.csv", mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["artist_id","band_id","join_date"])

    for a_id in artist_ids:
        # 40% πιθανότητα ο artist να ανήκει σε (1 ή 2) bands
        if random.random() < 0.4:
            how_many = random.randint(1,2)
            chosen_bands = random.sample(band_ids, min(how_many, len(band_ids)))
            for b_id in chosen_bands:
                join_date = fake.date_between("-5y", "today")
                writer.writerow([a_id, b_id, join_date])

# 7. PERFORMANCE
with open("Performance.csv", mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["performance_id","event_id_FK","performance_type","start_time","duration_minutes","performance_image"])

    for i in range(1, NUM_PERFORMANCES + 1):
        ev_id = random.choice(event_ids)
        perf_type = random.choice(["warm up","headline","special guest","main act"])
        start_dt = fake.date_time_this_year()
        duration = random.randint(30, 180)  # έως 3 ώρες
        image_url = f"https://example.com/performance_{i}.jpg"
        writer.writerow([i, ev_id, perf_type, start_dt, duration, image_url])
        performance_ids.append(i)

# 7a. PERFORMANCE_ARTIST
with open("Performance_Artist.csv", mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["performance_id","artist_id"])

    for p_id in performance_ids:
        # π.χ. 50% πιθανότητα να έχει σόλο καλλιτέχνη
        if random.random() < 0.5:
            a_id = random.choice(artist_ids)
            writer.writerow([p_id, a_id])

# 7b. PERFORMANCE_BAND
with open("Performance_Band.csv", mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["performance_id","band_id"])

    for p_id in performance_ids:
        # π.χ. 50% πιθανότητα να έχει band
        if random.random() < 0.5:
            b_id = random.choice(band_ids)
            writer.writerow([p_id, b_id])

# 8. VISITOR
with open("Visitor.csv", mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["visitor_id","first_name","last_name","age","phone","email"])

    for i in range(1, NUM_VISITORS + 1):
        fname = fake.first_name().replace("'","")
        lname = fake.last_name().replace("'","")
        age = random.randint(18,70)
        phone = fake.phone_number()
        email = fake.email()
        writer.writerow([i, fname, lname, age, phone, email])
        visitor_ids.append(i)

# 9. TICKET
with open("Ticket.csv", mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["ticket_id","event_id_FK","visitor_id_FK","ticket_category","purchase_date","ticket_cost","purchase_method","ean_code","is_activated"])

    payment_methods = ["credit_card","debit_card","bank_transfer","other"]
    categories = ["general","VIP","backstage"]
    for i in range(1, NUM_TICKETS + 1):
        v_id = random.choice(visitor_ids)
        ev_id = random.choice(event_ids)
        cat = random.choice(categories)
        cost = random.randint(15,100)
        p_method = random.choice(payment_methods)
        ean_code = random.randint(1000000000000,9999999999999)  # 13-digit
        purchase_dt = fake.date_time_this_year()
        is_activated = random.choice(["true","false"])
        writer.writerow([i, ev_id, v_id, cat, purchase_dt, cost, p_method, ean_code, is_activated])

# 10. STAFF
with open("Staff.csv", mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["staff_id","staff_name","age","role","experience_level"])

    exp_levels = ["intern","beginner","average","experienced","expert"]
    roles = ["tech","security","support"]
    for i in range(1, NUM_STAFF + 1):
        s_name = fake.name().replace("'","")
        s_age = random.randint(20,60)
        role_ = random.choice(roles)
        exp_ = random.choice(exp_levels)
        writer.writerow([i, s_name, s_age, role_, exp_])
        staff_ids.append(i)

# 10a. STAGE_STAFF
with open("Stage_Staff.csv", mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["stage_id","staff_id","start_date","end_date"])

    for stf_id in staff_ids:
        # 50% πιθανότητα να εργάζεται σε κάποια stage
        if random.random() < 0.5:
            st_id = random.choice(stage_ids)
            d1 = fake.date_between("-1y","today")
            d2 = d1 + timedelta(days=random.randint(1,10))
            writer.writerow([st_id, stf_id, d1, d2])

# 11. RATING
with open("Rating.csv", mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "rating_id","visitor_id_FK","performance_id_FK",
        "rating_interpretation","rating_sound_light","rating_stage_presence","rating_organization","rating_overall"
    ])

    for i in range(1, NUM_RATINGS + 1):
        vis = random.choice(visitor_ids)
        perf = random.choice(performance_ids)
        # 1-5 Likert
        r1 = random.randint(1,5)
        r2 = random.randint(1,5)
        r3 = random.randint(1,5)
        r4 = random.randint(1,5)
        r5 = random.randint(1,5)
        writer.writerow([i, vis, perf, r1, r2, r3, r4, r5])

# 12. RESALE_QUEUE (προαιρετικό)
with open("Resale_queue.csv", mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["resale_id","ticket_id_FK","visitor_id_FK","interest_type","interest_date"])

    for i in range(1, NUM_RESALE + 1):
        t_id = random.randint(1, NUM_TICKETS)
        v_id = random.choice(visitor_ids)
        interest_type = random.choice(["seller","buyer"])
        interest_date = fake.date_time_this_year()
        writer.writerow([i, t_id, v_id, interest_type, interest_date])

print("Η δημιουργία CSV ολοκληρώθηκε. Ελέγξτε τα αρχεία *.csv στο τρέχον directory.")
