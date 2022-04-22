defmodule Portfolio.Pagination do
  import Ecto.Query
  alias Portfolio.Repo

  def fetch_records(query, rec_perpage, page_no) when is_bitstring(rec_perpage) do
    rec_perpage = String.to_integer(rec_perpage)
    IO.inspect rec_perpage
    fetch_records(query, rec_perpage, page_no)
  end

  def fetch_records(query, rec_perpage, page_no) when is_bitstring(page_no) do
    if is_nil(page_no) do
      page_no = 1
      fetch_records(query, rec_perpage, page_no)
    else
      page_no = String.to_integer(page_no)
      fetch_records(query, rec_perpage, page_no)
    end
  end

  def fetch_records(query, rec_perpage, page_no) when page_no < 1 do
    page_no = 1
    fetch_records(query, rec_perpage, page_no)
  end

  def fetch_records(query, rec_perpage, page_no) do
    min_id = rec_perpage*(page_no - 1) + 1
    query
      |> where([m], m.id >= ^min_id)
      |> limit(^rec_perpage)
      |> order_by(:id)
      |> select([:id, :name, :email, :message])
      |> Repo.all()
  end

  def page(query, rec_perpage, page_no) do
    fetch_records(query, rec_perpage, page_no)
  end

  def count_records do
    query = "messages"
    query
      |> order_by(:id)
      |> Repo.aggregate(:count, :id)
  end

  def count_pages([i | lists], pages) when i > pages do
    lists = [i | lists]
  end

  #to do pages params will be
  def count_pages([i | lists], pages) do
    pages = div(count_records(), 6)
    lists = [i | lists]
    count_pages([i + 1 | lists], pages)
  end

end


  # old function for guarding the map params
  # def fetch_records(query, rec_perpage, page_no) when is_map(page_no) do
  #   page_no = Map.get(page_no, "page")
  #   if is_nil(page_no) or page_no < 1 do
  #     page_no = 1
  #     fetch_records(query, rec_perpage, page_no)
  #   else
  #     page_no = String.to_integer(page_no)
  #     fetch_records(query, rec_perpage, page_no)
  #   end
  # end
