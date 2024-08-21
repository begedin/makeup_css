defmodule MakeupCss.RegistryTest do
  use ExUnit.Case, async: true

  alias Makeup.Registry
  alias MakeupCss.Lexer

  describe "the Js lexer has successfully registered itself:" do
    test "language name" do
      assert {:ok, {Lexer, []}} == Registry.fetch_lexer_by_name("css")
    end

    test "file extension" do
      assert {:ok, {Lexer, []}} == Registry.fetch_lexer_by_extension("css")
    end
  end
end
