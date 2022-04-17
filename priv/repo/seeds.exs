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
alias Portfolio.Hireme.Message


Repo.insert! %Message{}
  |> Message.changeset(%{
      name: "tester 1",
      email: "tester1@example.com",
      message: "this is a manual input database test connection second"})



Repo.insert! %Message{}
|> Message.changeset(%{
    name: "tester 2",
    email: "tester2@example.com",
    message: "this is a manual input database test connection second"})


Repo.insert! %Message{}
  |> Message.changeset(%{
      name: "tester 3",
      email: "tester3@example.com",
      message: "this is a manual input database test connection second"})
