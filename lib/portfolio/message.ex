defmodule Portfolio.Message do
  alias Portfolio.Repo
  alias Portfolio.Message.Send
  alias Portfolio.Message.Messages
  @moduledoc """
  context for sending data to database messages
  """
  def list_messages do
    Repo.all(Messages)
  end

  def send_message(attrs \\ %{}) do
    %Send{}
    |> Send.changeset(attrs)
    |> Repo.insert()
  end

end
