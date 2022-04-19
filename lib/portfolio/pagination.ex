defmodule Portfolio.Pagination do
  import Ecto.Query
  alias Portfolio.Repo

  def fetch_records(query, rec_perpage, page_no) do
    min_id = rec_perpage*(page_no - 1) + 1
    max_id = rec_perpage*page_no
    query
      |> where([m], m.id >= ^min_id)
      |> where([m], m.id <= ^max_id)
      |> select([m], %{name: m.name, email: m.email, message: m.message})
      |> Repo.all()
  end

  def page(query, rec_perpage, page_no) do
    fetch_records(query, rec_perpage, page_no)
  end

  # def count_records do

  # end
end
