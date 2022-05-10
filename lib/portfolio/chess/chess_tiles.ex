defmodule Portfolio.ChessTiles do
  @enforce_keys [:coordinate_alpha, :color, :coordinate_no]
  defstruct  [:coordinate_alpha, :color, :coordinate_no]

  alias Portfolio.ChessTiles

  def tiles(coordinate_alpha: coordinate_alpha, color: color, coordinate_no: no) do
    %ChessTiles{coordinate_alpha: coordinate_alpha, color: color, coordinate_no: no}
  end

end
