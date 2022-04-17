defmodule Portfolio.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :name, :string, null: false, size: 30
      add :email, :string, null: false, size: 30
      add :message, :string, null: false, size: 120

      timestamps()
    end
    create unique_index(:messages, [:name])
  end
end
