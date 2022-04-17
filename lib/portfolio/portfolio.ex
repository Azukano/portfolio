defmodule Portfolio.Hireme do
  alias Portfolio.Repo
  alias Portfolio.Hireme.Message

  def list_rooms do
    Repo.all(Message)
  end

  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

end
