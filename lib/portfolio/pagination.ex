defmodule Portfolio.Pagination do
  import Ecto.Query
  alias Portfolio.Repo
  alias Portfolio.Message

  def count_record do
    Message.list_messages()
  end
end
