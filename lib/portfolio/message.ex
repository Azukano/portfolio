defmodule Portfolio.Message do
  alias Portfolio.Repo
  alias Portfolio.Message.Send

  def list_messages do
    Repo.all(Message)
  end

  def send_message(attrs \\ %{}) do
    %Send{}
    |> Send.changeset(attrs)
    |> Repo.insert()
  end

end
