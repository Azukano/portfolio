defmodule PortfolioWeb.HiremeController do
  alias Portfolio.Message.Send
  alias Portfolio.Message

  use PortfolioWeb, :controller

  def index(conn, _) do
    changeset = Send.changeset(%Send{}, %{})
    render(conn, "index.html", changeset: changeset)
  end

  def create(conn, %{"send" => message_params}) do
    IO.inspect message_params
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

  def show(conn, %{"page" => page, "records_per_page" => records_per_page}) do
    messages = Portfolio.Pagination.page("messages", 6, page)
    page = Enum.reverse(Portfolio.Pagination.count_pages([1, ], 2))
    records_per_page = [6, 10, 20]
    render(conn, "show.html", messages: messages, page: page, records_per_page: records_per_page)
  end

  def show(conn, %{}) do
    messages = Portfolio.Pagination.page("messages", 6, 1)
    page = Enum.reverse(Portfolio.Pagination.count_pages([1, ], 2))
    records_per_page = [6, 10, 20]
    render(conn, "show.html", messages: messages, page: page, records_per_page: records_per_page)
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
