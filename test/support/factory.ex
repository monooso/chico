defmodule Chico.Factory do
  use ExMachina.Ecto, repo: Chico.Repo

  def journal_entry_factory do
    %Chico.Journals.JournalEntry{
      check_in: sequence(:check_in, &"Top of the morning #{&1}"),
      check_out: sequence(:check_out, &"End of the evening #{&1}"),
      date: Date.add(Date.utc_today(), Enum.random(-100..0)),
      user: build(:user)
    }
  end

  def open_journal_entry_factory do
    struct!(journal_entry_factory(), %{check_out: nil})
  end

  def user_factory do
    password = "i-am-so-secure"

    %Chico.Accounts.User{
      email: sequence(:email, &"john.doe.#{&1}@example.com"),
      hashed_password: Bcrypt.hash_pwd_salt(password),
      password: password
    }
  end
end
