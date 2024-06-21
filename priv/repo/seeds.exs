# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Bezirke.Repo.insert!(%Bezirke.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

seasons = [
  {"23/24"}, #1
  {"24/25"}, #2
]

for {name} <- seasons do
  Bezirke.Repo.insert!(%Bezirke.Tour.Season{
    name: name,
    uuid: Bezirke.Repo.generate_uuid(),
  })
end

productions = [
  {"Frankenstein", "A monster", 1}, #1
  {"Amadeus", "A production about Mozart", 1}, #2
  {"39 Stufen", "Something about stairs", 2}, #3
  {"Electra", "Not Carmen", 2}, #4
  {"Der kleine Prinz", "Ein Kinderstueck", 2}, #5
]

for {title, description, season_id} <- productions do
  Bezirke.Repo.insert!(%Bezirke.Tour.Production{
    title: title,
    description: description,
    season_id: season_id,
    uuid: Bezirke.Repo.generate_uuid(),
  })
end

venues = [
  {"VHS Floridsdorf", "1210 Oida", 400}, #1
  {"VHS Meidling", "LLLL", 300}, #2
  {"VHS Doebling", "Bling Bling", 250}, #3
  {"VHS Favoriten", "1100", 350}, #4
  {"Urania", "Kasperl", 200}, #5
]

for {name, description, capacity} <- venues do
  Bezirke.Repo.insert!(%Bezirke.Venues.Venue{
    name: name,
    description: description,
    capacity: capacity,
    uuid: Bezirke.Repo.generate_uuid(),
  })
end

performances = [
  {400, ~U[2024-01-16 18:30:00Z], 1, 1}, #1
  {400, ~U[2024-01-20 18:30:00Z], 2, 1}, #2
  {400, ~U[2024-01-22 18:30:00Z], 3, 1}, #3
  {400, ~U[2024-01-24 18:30:00Z], 4, 1}, #4
  {300, ~U[2024-01-27 18:30:00Z], 1, 2}, #5
  {300, ~U[2024-01-29 18:30:00Z], 2, 2}, #6
  {300, ~U[2024-01-31 18:30:00Z], 3, 2}, #7
  {300, ~U[2024-02-03 18:30:00Z], 4, 2}, #8
  {250, ~U[2024-02-06 18:30:00Z], 1, 3}, #9
  {250, ~U[2024-02-08 18:30:00Z], 2, 3}, #10
  {250, ~U[2024-02-11 18:30:00Z], 3, 3}, #11
  {250, ~U[2024-02-14 18:30:00Z], 4, 3}, #12
  {350, ~U[2024-02-16 18:30:00Z], 1, 4}, #13
  {350, ~U[2024-02-19 18:30:00Z], 2, 4}, #14
  {350, ~U[2024-02-21 18:30:00Z], 3, 4}, #15
  {350, ~U[2024-02-24 18:30:00Z], 4, 4}, #16
  {200, ~U[2024-02-27 18:30:00Z], 1, 5}, #17
  {200, ~U[2024-02-29 18:30:00Z], 2, 5}, #18
  {200, ~U[2024-03-02 18:30:00Z], 3, 5}, #19
  {200, ~U[2024-03-04 18:30:00Z], 4, 5}, #20
  {500, ~U[2024-03-07 18:30:00Z], 5, 1}, #21
  {400, ~U[2024-03-10 18:30:00Z], 5, 2}, #22
  {300, ~U[2024-03-14 18:30:00Z], 5, 3}, #23
  {400, ~U[2024-03-17 18:30:00Z], 5, 4}, #24
  {300, ~U[2024-03-20 18:30:00Z], 5, 5}, #25
]

for {capacity, played_at, production_id, venue_id} <- performances do
  Bezirke.Repo.insert!(%Bezirke.Tour.Performance{
    capacity: capacity,
    played_at: played_at,
    uuid: Bezirke.Repo.generate_uuid(),
    production_id: production_id,
    venue_id: venue_id,
  })
end

sales_figures = [
  {~U[2023-10-16 18:30:00Z], 100, 1},
  {~U[2023-11-23 18:30:00Z], 50, 1},
  {~U[2023-12-28 18:30:00Z], 50, 1},
  {~U[2023-10-16 18:30:00Z], 20, 2},
  {~U[2023-11-30 18:30:00Z], 30, 2},
  {~U[2024-01-16 18:30:00Z], 40, 2},
  {~U[2023-11-05 18:30:00Z], 100, 3},
  {~U[2023-12-28 18:30:00Z], 20, 3},
  {~U[2024-01-20 18:30:00Z], 20, 3},
  {~U[2023-11-30 18:30:00Z], 150, 4},
  {~U[2023-12-28 18:30:00Z], 10, 4},
  {~U[2024-01-24 18:30:00Z], 30, 4},
  {~U[2023-10-16 18:30:00Z], 10, 5},
  {~U[2023-10-20 18:30:00Z], 50, 5},
  {~U[2024-01-16 18:30:00Z], 50, 5},
  {~U[2023-11-16 18:30:00Z], 50, 6},
  {~U[2024-01-16 18:30:00Z], 50, 6},
  {~U[2023-10-22 18:30:00Z], 50, 6},
  {~U[2023-12-16 18:30:00Z], 30, 7},
  {~U[2024-01-16 18:30:00Z], 30, 7},
  {~U[2024-01-29 18:30:00Z], 30, 7},
  {~U[2023-12-28 18:30:00Z], 100, 8},
  {~U[2024-01-20 18:30:00Z], 10, 8},
  {~U[2024-01-29 18:30:00Z], 100, 8},
  {~U[2023-12-26 18:30:00Z], 100, 9},
  {~U[2024-01-22 18:30:00Z], 10, 9},
  {~U[2024-01-29 18:30:00Z], 10, 9},
  {~U[2023-12-26 18:30:00Z], 40, 10},
  {~U[2024-01-16 18:30:00Z], 100, 10},
  {~U[2024-01-31 18:30:00Z], 10, 10},
  {~U[2024-01-16 18:30:00Z], 20, 11},
  {~U[2024-01-20 18:30:00Z], 40, 11},
  {~U[2024-01-26 18:30:00Z], 80, 11},
  {~U[2024-01-06 18:30:00Z], 50, 12},
  {~U[2024-01-20 18:30:00Z], 50, 12},
  {~U[2024-01-24 18:30:00Z], 100, 12},
  {~U[2024-01-26 18:30:00Z], 50, 13},
  {~U[2024-01-31 18:30:00Z], 100, 13},
  {~U[2024-02-05 18:30:00Z], 200, 13},
  {~U[2024-01-22 18:30:00Z], 30, 14},
  {~U[2024-01-31 18:30:00Z], 30, 14},
  {~U[2024-02-05 18:30:00Z], 30, 14},
  {~U[2024-01-26 18:30:00Z], 40, 15},
  {~U[2024-02-05 18:30:00Z], 40, 15},
  {~U[2024-02-10 18:30:00Z], 20, 15},
  {~U[2024-01-31 18:30:00Z], 90, 16},
  {~U[2024-02-10 18:30:00Z], 10, 16},
  {~U[2024-02-10 18:30:00Z], 100, 17},
  {~U[2024-02-21 18:30:00Z], 10, 17},
  {~U[2024-02-25 18:30:00Z], 70, 17},
  {~U[2024-02-06 18:30:00Z], 50, 18},
  {~U[2024-02-10 18:30:00Z], 100, 18},
  {~U[2024-02-15 18:30:00Z], 70, 18},
  {~U[2024-02-10 18:30:00Z], 50, 19},
  {~U[2024-02-19 18:30:00Z], 60, 19},
  {~U[2024-02-25 18:30:00Z], 70, 19},
  {~U[2024-02-10 18:30:00Z], 20, 20},
  {~U[2024-02-19 18:30:00Z], 50, 20},
  {~U[2024-02-25 18:30:00Z], 150, 20},
  {~U[2024-02-15 18:30:00Z], 40, 21},
  {~U[2024-02-20 18:30:00Z], 80, 21},
  {~U[2024-02-28 18:30:00Z], 40, 21},
  {~U[2024-02-16 18:30:00Z], 10, 22},
  {~U[2024-02-23 18:30:00Z], 10, 22},
  {~U[2024-02-28 18:30:00Z], 10, 22},
  {~U[2024-02-16 18:30:00Z], 50, 23},
  {~U[2024-02-22 18:30:00Z], 50, 23},
  {~U[2024-02-28 18:30:00Z], 50, 23},
  {~U[2024-02-19 18:30:00Z], 20, 24},
  {~U[2024-02-28 18:30:00Z], 100, 24},
  {~U[2024-03-05 18:30:00Z], 100, 24},
  {~U[2024-02-23 18:30:00Z], 50, 25},
  {~U[2024-03-01 18:30:00Z], 100, 25},
  {~U[2024-03-15 18:30:00Z], 150, 25},
]

for {recurded_at, ticket_count, performance_id} <- sales_figures do
  Bezirke.Repo.insert!(%Bezirke.Sales.SalesFigures{
    record_date: recurded_at,
    tickets_count: ticket_count,
    uuid: Bezirke.Repo.generate_uuid(),
    performance_id: performance_id,
  })
end

events = [
  {"Event1", "First Event", ~D[2023-11-12], nil},
  {"Event2", "Second Event", ~D[2023-11-28], nil},
  {"Event3", "Thirs Event", ~D[2023-12-22], ~D[2023-12-28]},
  {"Event4", "Fourth Event", ~D[2024-01-11], ~D[2024-01-14]},
  {"Event5", "Fifth Event", ~D[2024-01-12], nil},
  {"Event6", "Sixth Event", ~D[2024-01-31], nil},
  {"Event7", "Seventh Event", ~D[2024-02-02], ~D[2024-02-23]},
]

for {label, description, started_at, ended_at} <- events do
  Bezirke.Repo.insert!(%Bezirke.Events.Event{
    label: label,
    description: description,
    started_at: started_at,
    ended_at: ended_at,
    uuid: Bezirke.Repo.generate_uuid(),
  })
end
