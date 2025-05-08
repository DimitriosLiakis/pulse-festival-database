# DatabasesNTUA24-25
This repository is hosting the solution of the project for the course Databases of National Technical University of Athens for the academic year 2024-2025. 
# Pulse University Festival Database

## Overview

This repository contains the schema definition (DDL) and sample data for the Pulse University annual music festival management system. The database supports managing locations, festivals, stages, events, performances, artists, bands, visitors, tickets, staff, ratings, and resale queues.

## Assumptions

Below is a table of assumptions made to fill gaps in the specification and to ensure all required queries and constraints operate correctly.

| Assumption ID | Description                                                                                           | Affected Entities                      |
| ------------- | ----------------------------------------------------------------------------------------------------- | -------------------------------------- |
| A1            | EAN‑13 codes are 13-digit numeric strings, unique per ticket.                                         | Ticket.ean\_code                       |
| A2            | VIP tickets are capped at 10% of a stage's capacity for each event.                                   | Ticket                                 |
| A3            | Ticket pricing varies by day and category but is fixed per combination.                               | Ticket                                 |
| A4            | Mandatory break between consecutive performances is enforced to be between 5 and 30 minutes.          | Event, Performance                     |
| A5            | Artists and bands cannot have overlapping performances; schedule validation is application‑level.     | Performance\_Artist, Performance\_Band |
| A6            | Artists/bands may not perform more than three consecutive years at the festival; enforced externally. | Festival, Artist\_Band                 |
| A7            | Future festivals are those with festival\_year > 2025; sample data includes years up to 2027.         | Festival                               |
| A8            | Geographic coordinates are stored as a single string in 'latitude,longitude' format.                  | Location.coordinates                   |
| A9            | Staff quota percentages (5% security, 2% support) are rounded up to the nearest integer.              | Stage\_Staff trigger                   |
| A10           | Resale queue processes buyers and sellers in strict FIFO order based on interest\_date.               | Resale\_queue                          |

## Data Population

* **Artists & Bands**: 50 entries combined, with artists linked to bands where applicable.
* **Stages**: 30 distinct stages with varied capacities and equipment lists.
* **Events & Performances**: 100 performances scheduled across 10 festival editions (including 2 future years).
* **Visitors & Tickets**: 200 tickets covering general, VIP, and backstage categories.

## Usage

1. Run `schema.sql` to create the database and all tables.
2. Run `data.sql` to insert sample data.
3. Use the provided queries in `/sql` to test constraints, availability, scheduling, and reporting.

---

*Pulse University Festival Database — Semestrial Assignment 2024-2025*
