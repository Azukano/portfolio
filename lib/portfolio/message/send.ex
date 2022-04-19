defmodule Portfolio.Message.Send do
  use Ecto.Schema
  import Ecto.Changeset
  alias Portfolio.Message.Send

  schema "messages" do
    field :name, :string
    field :email, :string
    field :message, :string

    timestamps()
  end

  def changeset(%Send{} = message, attrs) do
    message
    |> cast(attrs, [:name, :email, :message])
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> validate_length(:name, min: 3, max: 30)
    |> validate_length(:email, min: 3, max: 30)
    |> validate_length(:message, min: 6, max: 120)
  end
end
