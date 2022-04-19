defmodule Portfolio.Message.Seeds do
  use Ecto.Schema
  import Ecto.Changeset
  alias Portfolio.Message.Seeds

  schema "messages" do
    field :name, :string
    field :email, :string
    field :message, :string

    timestamps()
  end

  def changeset(%Seeds{} = message, attrs) do
    message
    |> cast(attrs, [:name, :email, :message])
  end
end
