defmodule Portfolio.ChessPieces do
  @enforce_keys [:role, :position]
  defstruct  [:role, :position]

  alias Portfolio.ChessPieces

  def pieces(role: role, position: position) do
    %ChessPieces{role: role, position: position}
  end
end
