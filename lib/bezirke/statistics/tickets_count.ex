defmodule Bezirke.Statistics.TicketsCount do
  @derive {Jason.Encoder, only: [:date, :tickets_count]}
  defstruct [
    date: nil,
    tickets_count: 0
  ]
end
