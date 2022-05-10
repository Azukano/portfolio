defmodule Portfolio.Chess.PieceMovesets do

  @doc """
  piece_id: 'P/N/B/R/Q/K-1.2/..8'
  legal_moves: {coordinate_alpha, coordinate_no}
  """
  @enforce_keys [:piece_id, :legal_moves]
  defstruct [:piece_id, :legal_moves]


  alias Portfolio.Chess.PieceMovesets

  def move(piece_id: piece_id, legal_moves: legal_moves) do
    %PieceMovesets{piece_id: piece_id, legal_moves: legal_moves}
  end
end
