defmodule MakeupCSS.Application do
  @moduledoc false
  use Application

  alias Makeup.Registry

  def start(_type, _args) do
    Registry.register_lexer(MakeupCSS.Lexer,
      options: [],
      names: ["css"],
      extensions: ["css"]
    )

    Supervisor.start_link([], strategy: :one_for_one)
  end
end
