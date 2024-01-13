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
  {1, "23/24"},
  {2, "24/25"},
]

for {id, name} <- seasons do
  Bezirke.Repo.insert!(%Bezirke.Tour.Season{
    id: id,
    name: name,
    uuid: Bezirke.Repo.generate_uuid(),
  })
end

productions = [
  {1, "Frankenstein", "A monster", 1},
  {2, "Amadeus", "A production about Mozart", 1},
  {3, "39 Stufen", "Something about stairs", 2},
  {4, "Electra", "Not Carmen", 2},
  {5, "Der kleine Prinz", "Ein Kinderstueck", 2},
]

for {id, title, description, season_id} <- productions do
  Bezirke.Repo.insert!(%Bezirke.Tour.Production{
    id: id,
    title: title,
    description: description,
    season_id: season_id,
    uuid: Bezirke.Repo.generate_uuid(),
  })
end

venues = [
  {1, "VHS Floridsdorf", "1210 Oida", 400},
  {2, "VHS Meidling", "LLLL", 300},
  {3, "VHS Doebling", "Bling Bling", 250},
  {4, "VHS Favoriten", "1100", 350},
  {5, "Urania", "Kasperl", 200},
]

for {id, name, description, capacity} <- venues do
  Bezirke.Repo.insert!(%Bezirke.Venues.Venue{
    id: id,
    name: name,
    description: description,
    capacity: capacity,
    uuid: Bezirke.Repo.generate_uuid(),
  })
end

performances = [
  {1, 400, ~U[2024-01-16 18:30:00Z], 1, 1},
  {2, 400, ~U[2024-01-20 18:30:00Z], 2, 1},
  {3, 400, ~U[2024-01-22 18:30:00Z], 3, 1},
  {4, 400, ~U[2024-01-24 18:30:00Z], 4, 1},
  {5, 300, ~U[2024-01-27 18:30:00Z], 1, 2},
  {6, 300, ~U[2024-01-29 18:30:00Z], 2, 2},
  {7, 300, ~U[2024-01-31 18:30:00Z], 3, 2},
  {8, 300, ~U[2024-02-03 18:30:00Z], 4, 2},
  {9, 250, ~U[2024-02-06 18:30:00Z], 1, 3},
  {10, 250, ~U[2024-02-08 18:30:00Z], 2, 3},
  {11, 250, ~U[2024-02-11 18:30:00Z], 3, 3},
  {12, 250, ~U[2024-02-14 18:30:00Z], 4, 3},
  {13, 350, ~U[2024-02-16 18:30:00Z], 1, 4},
  {14, 350, ~U[2024-02-19 18:30:00Z], 2, 4},
  {15, 350, ~U[2024-02-21 18:30:00Z], 3, 4},
  {16, 350, ~U[2024-02-24 18:30:00Z], 4, 4},
  {17, 200, ~U[2024-02-27 18:30:00Z], 1, 5},
  {18, 200, ~U[2024-02-29 18:30:00Z], 2, 5},
  {19, 200, ~U[2024-03-02 18:30:00Z], 3, 5},
  {20, 200, ~U[2024-03-04 18:30:00Z], 4, 5},
  {21, 500, ~U[2024-03-07 18:30:00Z], 5, 1},
  {22, 400, ~U[2024-03-10 18:30:00Z], 5, 2},
  {23, 300, ~U[2024-03-14 18:30:00Z], 5, 3},
  {24, 400, ~U[2024-03-17 18:30:00Z], 5, 4},
  {25, 300, ~U[2024-03-20 18:30:00Z], 5, 5},
]

for {id, capacity, played_at, venue_id, production_id} <- performances do
  Bezirke.Repo.insert!(%Bezirke.Tour.Performance{
    id: id,
    capacity: capacity,
    played_at: played_at,
    uuid: Bezirke.Repo.generate_uuid(),
    production_id: production_id,
    venue_id: venue_id,
  })
end

sales_figures = [
  {~U[2023-10-16 18:30:00Z], 100, 1},
  {~U[2023-10-16 18:30:00Z], 50, 1},
  {~U[2023-10-16 18:30:00Z], 50, 1},
  {~U[2023-10-16 18:30:00Z], 20, 2},
  {~U[2023-10-16 18:30:00Z], 30, 2},
  {~U[2023-10-16 18:30:00Z], 40, 2},
  {~U[2023-10-16 18:30:00Z], 100, 3},
  {~U[2023-10-16 18:30:00Z], 20, 3},
  {~U[2023-10-16 18:30:00Z], 20, 3},
  {~U[2023-10-16 18:30:00Z], 150, 4},
  {~U[2023-10-16 18:30:00Z], 10, 4},
  {~U[2023-10-16 18:30:00Z], 30, 4},
  {~U[2023-10-16 18:30:00Z], 10, 5},
  {~U[2023-10-16 18:30:00Z], 50, 5},
  {~U[2023-10-16 18:30:00Z], 50, 5},
  {~U[2023-10-16 18:30:00Z], 50, 6},
  {~U[2023-10-16 18:30:00Z], 50, 6},
  {~U[2023-10-16 18:30:00Z], 50, 6},
  {~U[2023-10-16 18:30:00Z], 30, 7},
  {~U[2023-10-16 18:30:00Z], 30, 7},
  {~U[2023-10-16 18:30:00Z], 30, 7},
  {~U[2023-10-16 18:30:00Z], 100, 8},
  {~U[2023-10-16 18:30:00Z], 10, 8},
  {~U[2023-10-16 18:30:00Z], 100, 8},
  {~U[2023-10-16 18:30:00Z], 100, 9},
  {~U[2023-10-16 18:30:00Z], 10, 9},
  {~U[2023-10-16 18:30:00Z], 10, 9},
  {~U[2023-10-16 18:30:00Z], 40, 10},
  {~U[2023-10-16 18:30:00Z], 100, 10},
  {~U[2023-10-16 18:30:00Z], 10, 10},
  {~U[2023-10-16 18:30:00Z], 20, 11},
  {~U[2023-10-16 18:30:00Z], 40, 11},
  {~U[2023-10-16 18:30:00Z], 80, 11},
  {~U[2023-10-16 18:30:00Z], 50, 12},
  {~U[2023-10-16 18:30:00Z], 50, 12},
  {~U[2023-10-16 18:30:00Z], 100, 12},
  {~U[2023-10-16 18:30:00Z], 50, 13},
  {~U[2023-10-16 18:30:00Z], 100, 13},
  {~U[2023-10-16 18:30:00Z], 200, 13},
  {~U[2023-10-16 18:30:00Z], 30, 14},
  {~U[2023-10-16 18:30:00Z], 30, 14},
  {~U[2023-10-16 18:30:00Z], 30, 14},
  {~U[2023-10-16 18:30:00Z], 40, 15},
  {~U[2023-10-16 18:30:00Z], 40, 15},
  {~U[2023-10-16 18:30:00Z], 20, 15},
  {~U[2023-10-16 18:30:00Z], 90, 16},
  {~U[2023-10-16 18:30:00Z], 10, 16},
  {~U[2023-10-16 18:30:00Z], 100, 17},
  {~U[2023-10-16 18:30:00Z], 10, 17},
  {~U[2023-10-16 18:30:00Z], 70, 17},
  {~U[2023-10-16 18:30:00Z], 50, 18},
  {~U[2023-10-16 18:30:00Z], 100, 18},
  {~U[2023-10-16 18:30:00Z], 70, 18},
  {~U[2023-10-16 18:30:00Z], 50, 19},
  {~U[2023-10-16 18:30:00Z], 60, 19},
  {~U[2023-10-16 18:30:00Z], 70, 19},
  {~U[2023-10-16 18:30:00Z], 20, 20},
  {~U[2023-10-16 18:30:00Z], 50, 20},
  {~U[2023-10-16 18:30:00Z], 150, 20},
  {~U[2023-10-16 18:30:00Z], 40, 21},
  {~U[2023-10-16 18:30:00Z], 80, 21},
  {~U[2023-10-16 18:30:00Z], 40, 21},
  {~U[2023-10-16 18:30:00Z], 10, 22},
  {~U[2023-10-16 18:30:00Z], 10, 22},
  {~U[2023-10-16 18:30:00Z], 10, 22},
  {~U[2023-10-16 18:30:00Z], 50, 23},
  {~U[2023-10-16 18:30:00Z], 50, 23},
  {~U[2023-10-16 18:30:00Z], 50, 23},
  {~U[2023-10-16 18:30:00Z], 20, 24},
  {~U[2023-10-16 18:30:00Z], 100, 24},
  {~U[2023-10-16 18:30:00Z], 100, 24},
  {~U[2023-10-16 18:30:00Z], 50, 25},
  {~U[2023-10-16 18:30:00Z], 100, 25},
  {~U[2023-10-16 18:30:00Z], 150, 25},
]

for {recurded_at, ticket_count, performance_id} <- sales_figures do
  Bezirke.Repo.insert!(%Bezirke.Sales.SalesFigures{
    record_date: recurded_at,
    tickets_count: ticket_count,
    uuid: Bezirke.Repo.generate_uuid(),
    performance_id: performance_id,
  })
end

