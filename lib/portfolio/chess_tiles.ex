defmodule Portfolio.ChessTiles do
  alias Portfolio.ChessTiles

  #@enforce_keys [:alpha,  :no, :color]
  defstruct  [:alpha,  :color, :no]

  def fill_tiles(alpha, color, no) do
    %ChessTiles{} = %{alpha: alpha, color: color, no: no}
  end

end
