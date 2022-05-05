# Portfolio

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

## Chess

  * Tiles Module
  ** struct will be composed of ChessTiles.id? with values 
      [:alpha => "A..H", :no => "1..8", :color => "black/white could be boolean"]
      %Portfolio.ChessTiles{alpha: "A", color: :BLACK/:WHITE, no: 1} done 
  ** make another module in here I save another map that will order the tiles. done
  ** render maps structure to html

____ GET THE KEYS: a1 
____ GET THE COLOR: BLACK
_____________________ PUT THEM IN LIST*