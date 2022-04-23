defmodule PortfolioWeb.HiremeController do
  alias Portfolio.Message.Send
  alias Portfolio.Message

  use PortfolioWeb, :controller

  def index(conn, _) do
    changeset = Send.changeset(%Send{}, %{})
    render(conn, "index.html", changeset: changeset)
  end

  def create(conn, %{"send" => message_params}) do
    case Message.send_message(message_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Message Sent!")
        |> redirect(to: Routes.hireme_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        conn = put_flash(conn, :error, "Error Sending!")
        render(conn, "index.html", changeset: changeset)
    end
  end

  #main function must all get params /messages?page=x&rec_perpage=y
  def show(conn, %{"page" => page, "rec_perpage" => rec_perpage}) do
    messages = Portfolio.Pagination.page("messages", rec_perpage, page)
    page = Enum.reverse(Portfolio.Pagination.count_pages([1, ], String.to_integer(rec_perpage)))
    render(conn, "show.html", messages: messages, page: page, rec_perpage: [6, 10, 20])
  end

  #sub function page got params, rec_perpage null /messages?page=x&rec_perpage=nil
  def show(conn, %{"page" => page}) do
    messages = Portfolio.Pagination.page("messages", 6, page)
    page = Enum.reverse(Portfolio.Pagination.count_pages([1, ], 1))
    render(conn, "show.html", messages: messages, page: page, rec_perpage: [6, 10, 20])
  end

  #sub function page got params, rec_perpage null /messages?page=x=nil&rec_perpage=y
  def show(conn, %{"rec_perpage" => rec_perpage}) do
    IO.puts("rec_perpage")
    messages = Portfolio.Pagination.page("messages", rec_perpage, 1)
    page = Enum.reverse(Portfolio.Pagination.count_pages([1, ], String.to_integer(rec_perpage)))
    render(conn, "show.html", messages: messages, page: page, rec_perpage: [6, 10, 20])
  end

  #sub function page got params, rec_perpage null base /messages
  def show(conn, %{}) do
    messages = Portfolio.Pagination.page("messages", 6, 1)
    page = Enum.reverse(Portfolio.Pagination.count_pages([1, ], 2))
    render(conn, "show.html", messages: messages, page: page, rec_perpage: [6, 10, 20])
  end


end

#%{"rec_perpage" => rec_perpage}
#pages = Enum.reverse(Portfolio.Pagination.count_pages([1, ], 2))

  # def show(conn, %{}) do
  #   messages = Portfolio.Pagination.page("messages", 6, 1)
  #   page = Enum.reverse(Portfolio.Pagination.count_pages([1, ], 2))
  #   records_per_page = [6, 10, 20]
  #   render(conn, "show.html", messages: messages, page: page, records_per_page: records_per_page)
  # end
