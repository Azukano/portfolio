defmodule PortfolioWeb.GamesLive do
  use PortfolioWeb, :live_view
  @doc """
  PRAGMATICSTUDIO PROGRAM LIVE VIEW MODULE LESSON 1 END
  SIMPLE LIFE CYCLE LIVE VIEW ~ LIGHT BULB
  """
  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, :brightness, 10)
    {:ok, socket}
  end

  def render(_params, _session, socket) do
    socket = assign(socket, brightness: 10)
    {:ok, socket}
  end

  @impl true
  def handle_event("on", _, socket) do
    socket = assign(socket, brightness: 100)
    {:noreply, socket}
  end

  def handle_event("up", _, socket) do
    socket = update(socket, :brightness, &(&1 + 10))
    {:noreply, socket}
  end

  def handle_event("down", _, socket) do
    socket = update(socket, :brightness, &(&1 - 10))
    {:noreply, socket}
  end

  def handle_event("off", _, socket) do
    socket = assign(socket, :brightness, 0)
    {:noreply, socket}
  end

  def handle_event("flash", _, socket) do
    IO.puts "FLASH"
    socket = put_flash(socket, :info, "It worked!")
    {:noreply, socket}
  end

end
