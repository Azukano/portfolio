

# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Portfolio.Repo.insert!(%Portfolio.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Portfolio.Repo
alias Portfolio.Message.Seeds

  for n <- 1..100 do
    Repo.insert! %Seeds{}
    |> Seeds.changeset(%{
        name: "tester #{n}",
        email: "tester#{n}@example.com",
        message: "this is a manual seed input database test connection #{n}"})
    end
