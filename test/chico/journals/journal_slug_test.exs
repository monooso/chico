defmodule Chico.Journals.JournalSlugTest do
  use Chico.DataCase, async: true
  alias Chico.Journals.JournalSlug

  describe "generate/0" do
    test "it generates a unique slug" do
      slugs =
        Enum.reduce(1..100_000, MapSet.new(), fn _counter, slugs ->
          MapSet.put(slugs, JournalSlug.generate())
        end)

      assert 100_000 = MapSet.size(slugs)
    end
  end
end
