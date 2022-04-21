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

  def show(conn, pages) do
    messages = Portfolio.Pagination.page("messages", 10, pages)
    pages = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    render(conn, "show.html", messages: messages, pages: pages)
  end

end

#%{"rec_perpage" => rec_perpage}
