defmodule PortfolioWeb.HiremeController do
  alias Portfolio.Message.Send
  alias Portfolio.Message

  use PortfolioWeb, :controller

  def index(conn, _params) do
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
        render(conn, "index.html", changeset: changeset)
      # _ ->
      #   conn
      #   |> put_flash(:info, "Message Sent!")
      #   |> redirect(to: Routes.hireme_path(conn, :index))
    end
  end

  def show(conn, _) do
    messages = Portfolio.Message.list_messages()
    render(conn, "show.html", messages: messages)
  end
end
