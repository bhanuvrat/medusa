defmodule MedusaWeb.MagicLiveView do
  use MedusaWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>

    nodes:
    <%= for node <- @nodes do %>
    <%= node %>
    <% end %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:nodes, nodes())}
  end
  defp nodes() do
    Node.list()
  end

end
