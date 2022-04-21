defmodule Portfolio.Pagination do
  import Ecto.Query
  alias Portfolio.Repo

  def fetch_records(query, rec_perpage, page_no) do
    min_id = rec_perpage*(page_no - 1) + 1
    query
      |> where([m], m.id >= ^min_id)
      |> limit(^rec_perpage)
      |> order_by(desc: :id)
      |> select([:id, :name, :email, :message])
      |> Repo.all()
  end

  def page(query, rec_perpage, page_no) do
    IO.inspect(fetch_records(query, rec_perpage, page_no))
    fetch_records(query, rec_perpage, page_no)
  end
end
