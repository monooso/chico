defmodule Chico.Journals.JournalSlug do
  @moduledoc """
  Functions for generating a short, unique journal slug.
  """

  @alphabet "abcdefghijklmnopqrstuvwxyz"
  @encoder Hashids.new(alphabet: @alphabet, salt: "sixteen saltine crackers")
  @year_zero 1_658_747_700

  @doc """
  Generates a unique slug.
  """
  @spec generate() :: String.t()
  def generate() do
    seed = System.os_time(:second) + System.unique_integer([:monotonic, :positive]) - @year_zero

    Hashids.encode(@encoder, seed)
  end
end
