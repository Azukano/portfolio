defmodule Portfolio.ChessTiles do
  @enforce_keys [:alpha, :color, :no]
  defstruct  [:alpha, :color, :no]

  alias Portfolio.ChessTiles

  def tiles(alpha: alpha, color: color, no: no) do
    %ChessTiles{alpha: alpha, color: color, no: no}
  end

end
