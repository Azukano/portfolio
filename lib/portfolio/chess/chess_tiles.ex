defmodule Portfolio.ChessTiles do
  @enforce_keys [:coordinate_alpha, :color, :coordinate_no, :occupant]
  defstruct  [:coordinate_alpha, :color, :coordinate_no, :occupant]

  alias Portfolio.ChessTiles

  def tiles(
    coordinate_alpha: coordinate_alpha,
    color: color,
    coordinate_no: coordinate_no,
    occupant: occupant) do
      %ChessTiles{
        coordinate_alpha: coordinate_alpha,
        color: color,
        coordinate_no: coordinate_no,
        occupant: occupant}
  end

end
