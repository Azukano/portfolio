defmodule Portfolio.Contact do
  alias Portfolio.Repo
  alias Portfolio.Hireme.Message

  def list_rooms do
    Repo.all(Message)
  end
end
