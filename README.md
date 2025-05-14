# Pulse Festival Database  
Εξαμηνιαία Εργασία Βάσεων Δεδομένων (NTUA 2024‑2025) 
**Φοιτητής:** Δημήτριος Λιάκης · ΑΜ 03120846

## 1 . Overview

Η βάση **Pulse Festival** υποστηρίζει:

* Διαχείριση τοποθεσιών, φεστιβάλ, σκηνών, εκδηλώσεων, παραστάσεων 
* Καλλιτέχνες & μπάντες, προσωπικό ασφαλείας/υποστήριξης/τεχνικούς 
* Επισκέπτες, εισιτήρια, βαθμολογίες παραστάσεων, ουρά μεταπώλησης

---

## 2 . Υποθέσεις Σχεδίασης

| ID | Περιγραφή | Οντότητες που επηρεάζονται |
| -- | --------- | ------------------------- |
| **A1** | Οι κωδικοί EAN‑13 είναι μοναδικοί 13‑ψήφιοι χαρακτήρες. | `Ticket.ean_code` |
| **A2** | Τα VIP εισιτήρια ≤ 10 % της χωρητικότητας σκηνής. | `Ticket` |
| **A3** | Σταθερή τιμή εισιτηρίου ανά ημέρα & κατηγορία. | `Ticket` |
| **A4** | Υποχρεωτικό διάλειμμα 5–30 min μεταξύ παραστάσεων. | `Event`, `Performance` |
| **A5** | Καλλιτέχνες/μπάντες δεν επιτρέπεται να επικαλύπτονται χρονικά (ελέγχεται εφαρμογιακά). | `Performance_*` |
| **A6** | Καλλιτέχνης/μπάντα ≤ 3 συνεχόμενα έτη εμφανίσεων (business rule, όχι trigger). | `Festival`, `Artist_Band` |
| **A7** | “Μελλοντικά” φεστιβάλ: `festival_year > 2025`, δείγματα 2026‑2027. | `Festival` |
| **A8** | Συντεταγμένες φυλάσσονται ως `POINT(lon lat)` string. | `Location.coordinates` |
| **A9** | Ποσοστά quota staff στρογγυλοποιούνται προς τα πάνω (`CEIL`). | Trigger `trg_staff_quota` |
| **A10** | Ουρά μεταπώλησης εξυπηρετείται αυστηρά FIFO βάσει `interest_date`. | `Resale_queue` |

---

## 3 . Mock Data

| Οντότητα | Πλήθος | Σχόλιο |
| -------- | ------ | ------ |
| Locations | 10 | Ευρώπη, Ασία, κ.λπ. |
| Festivals | 10 | 2017‑2026 |
| Stages | 30 | Χωρητικότητα 100‑2 000 |
| Events | 50 | ≥ 3 στο Festival #1 |
| Performances | 100 | 30‑180 min |
| Artists / Bands | 30 / 20 | Γένη από 5 είδη |
| Visitors | 200 | 18‑70 ετών |
| Tickets | 300 | VIP ≤ 10 % |
| Staff | 30 | tech / security / support |
| Ratings | 400 | 5 κριτήρια (1‑5) |
| Resale queue | 50 | buyers & sellers |

`data.py` εγγυάται ειδικές “seed” περιπτώσεις για τα ερωτήματα 3, 7, 9, 14 και τερματίζει με **AssertionError** αν αποτύχουν.

---

## 4 . Εγκατάσταση

```bash
# Δημιουργία mock δεδομένων
python data.py

# Δημιουργία schema
mysql -u root -p < sql/install.sql

# Φόρτωση CSV
mysql -u root -p music_festival < sql/load_new.sql
```

---

## 5 . Εκτέλεση Ερωτημάτων

```bash
# Παράδειγμα: Query 4
mysql -u root -p music_festival < sql/Q04.sql

# Query 6 με trace
mysql -u root -p music_festival < sql/Q06b.sql > sql/Q06_out.txt
```

---

## 6 . Δείκτες & Βελτιστοποίηση

* `idx_event_schedule (event_date, start_time)` 
* `idx_performance_by_event (event_id_FK, start_time)` 
* `uk_visitor_performance` 
* `idx_staff_role` 

Πλήρης ανάλυση στις § 2.2, § 4 της αναφοράς.

---

## 7 . Άδειες

* Κώδικας: **MIT**.
* Mock δεδομένα: παράγονται με [Faker](https://faker.readthedocs.io/) (MIT).
* Εικόνες: εικονικά URLs – καμία πραγματική εικόνα δεν περιλαμβάνεται.

---

*Pulse Festival Database · NTUA DB Course 2024‑2025*
