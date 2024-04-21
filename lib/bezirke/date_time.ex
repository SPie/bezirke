defmodule Bezirke.DateTime do

  def format_datetime(datetime), do: Calendar.strftime(datetime, "%d.%m.%Y %H:%M")

  def format_date(datetime), do: Calendar.strftime(datetime, "%d.%m.%Y")

end
