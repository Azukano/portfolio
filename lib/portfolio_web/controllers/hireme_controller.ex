defmodule PortfolioWeb.HiremeController do
  alias Portfolio.Hireme.Message
  alias Portfolio.Hireme

  use PortfolioWeb, :controller

  def index(conn, _params) do
    changeset = Message.changeset(%Message{}, %{})
    render(conn, "index.html", changeset: changeset)
  end

  def create(conn, %{"message" => message_params}) do
    case Hireme.create_message(message_params) do
      {:ok, message} ->
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

end
