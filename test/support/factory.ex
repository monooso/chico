defmodule Chico.Factory do
  use ExMachina.Ecto, repo: Chico.Repo
  alias ChicoSchemas, as: Schemas

  def journal_entry_factory do
    %Schemas.JournalEntry{
      check_in: sequence(:check_in, &"Top of the morning #{&1}"),
      check_out: sequence(:check_out, &"End of the evening #{&1}"),
      date: Date.add(Date.utc_today(), Enum.random(-100..0))
    }
  end

  def open_journal_entry_factory do
    struct!(journal_entry_factory(), %{check_out: nil})
  end
end
