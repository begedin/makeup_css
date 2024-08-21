defmodule MakeupCss.Application do
  @moduledoc false
  use Application

  alias Makeup.Registry

  def start(_type, _args) do
    Registry.register_lexer(MakeupCss.Lexer,
      options: [],
      names: ["css"],
      extensions: ["css"]
    )

    Supervisor.start_link([], strategy: :one_for_one)
  end
end
