# Portfolio

Pre requisite:
  * install NPM dependencies `cd ./assets` `npm install`

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

## Pagination/Message
  * Modules
  ** pagination 

## Chess

  * Modules
  ** chess_board struct composed of ChessTiles.id? with values 
      [alpha: "a".."h", no: 1..8, color: :white \ :black \ :red, occupant: nil \ chess_piece/s_id]
      e.a. 
      %{
        :a1, 
        %ChessTiles{alpha: a, no: 1, color: :black, occupant: "w-r1"},
        :a2, 
        %ChessTiles{alpha: a, no: 2, color: :white, occupant: "w-p1"},
        :a3,
        %ChessTiles{alpha: a, no: 3, color: :black, occupant: nil}
      } 
  ** chess_pieces struct composed of ChessPieces.id? with values
      [alpha: "a".."h", no: 1..8, role: "pone", role_id: "w-p1"]
      e.a. 
      %{
        :a2, 
        %ChessTiles{alpha: a, no: 1, role: "pone", role_id: "w-p1"}, 
        :b2, 
        %ChessTiles{alpha: a, no: 2, role: "pone", role_id: "w-p2"},
        :a1,
        %ChessTiles{alpha: a, no: 3, role: "rook", role_id: "w-r1"}
      } 
  ** chess ~ the main module of chess app, logical decisions are here as well as the processes.
  **** tile_shade_red - makes an overlay chess_board shaded red upon passing its return value back to chess_live.
  **** tile_shade_red\counting available tiles mode - if toggled on counts the number of available tiles for every
  **** chess pieces using comprehension for x <- chess_pieces if this returns 0 means its a stale mate otherwise 
  **** continue.
  **** presume_tiles - this function is self explnatory it just presume the whole chess_pieces side its teritory of
  **** attack zone.
  **** map update section - here is the execution of map updating/deleting for every pieces/board tiles.
  **** helper functions - finding king/determining ches_pieces side is here.

  * **General Game FAQ**
    * Game can be accessed through http://localhost:4000/chess, https://localhost:4000/chess or web live app https://devmac.app/chess
    * 100% FIDE Rule Implemented which means first turn is white, clicking/selecting black piece will 
  result in nothing.
    * Key Enter/Click on piece to move it, a red shaded tile will be on assist to see available moves.
    * Drag and Drop is not currently supported.
    * Key press directional arrow on your keyboard to select a tile/piece.
    * During Pone/Pawn promotion event, mouse scroll can be used to select your desired piece, 
  keyboard press left/right arrow key will can also be used. Pressing up arrow will get back the pointer to
  1st index which is the Rook. The order of chess piece is: Rook > Bishop > Knight > Queen.
    * Pone promotion extention: exceeding the pointer index will get it back to 1(Rook) or (4)Queen if you 
  hit the bottom index pointer to negative value.
    * Game status nav bar is located just below the Chess Board.
    * Nav Bar consist of: Tile Selection monitor, Player Turn, Check Condition and finally a Check/Stale mate.

# Acknowledgement

## Chess Tile Survey
  * With/out border  - 7 dia, adan, jhon, risa, cyber28, santi, adam, michou
  * With border      - 3 wong, wency, mike
  * undecided        - 1 ayleen
  * w/o border ! lower exposure   - gerald
  * w/o border ! lower contrast   - jez

## Software Testers
  * Rudy Mulang 
  * vy of chess discord community
