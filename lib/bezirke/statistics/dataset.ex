defmodule Bezirke.Statistics.Dataset do
  @derive {Jason.Encoder, only: [:label, :ticket_counts]}
  defstruct [
    label: "",
    ticket_counts: []
  ]
end
