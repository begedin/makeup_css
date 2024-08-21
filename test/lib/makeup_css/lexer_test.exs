defmodule MakeupCSS.LexerTest do
  use ExUnit.Case

  import MakeupCSS.Testing, only: [lex: 1]

  test "whitespace" do
    assert lex("   ") == [{:whitespace, %{}, "   "}]
  end

  test "comment" do
    assert lex("/* comment */") == [{:comment, %{}, "/* comment */"}]
  end

  test "multi line comment" do
    assert lex("""
           /*
            Multiline comment
           */
           """) == [
             {:comment, %{}, "/*\n Multiline comment\n*/"},
             {:whitespace, %{}, "\n"}
           ]
  end

  test "integers" do
    assert lex("10") == [{:number_integer, %{}, "10"}]
    assert lex("1000") == [{:number_integer, %{}, "1000"}]
    assert lex("0888") == [{:number_integer, %{}, "0888"}]
    assert lex("0777") == [{:number_integer, %{}, "0777"}]
  end

  test "floats" do
    assert lex("1.440") == [{:number_float, %{}, "1.440"}]
    assert lex("1050.95") == [{:number_float, %{}, "1050.95"}]
  end

  test "functions" do
    assert lex("calc()") == [
             {:name_function, %{}, "calc"},
             {:punctuation, %{}, "("},
             {:punctuation, %{}, ")"}
           ]
  end

  test "rule" do
    assert lex("color: red;") == [
             {:keyword_constant, %{}, "color:"},
             {:whitespace, %{}, " "},
             {:name_builtin, %{}, "red"},
             {:punctuation, %{}, ";"}
           ]
  end

  test "pseudoselectords" do
    assert lex(":hover") == [{:name_constant, %{}, ":hover"}]
    assert lex("::first-of-type") == [{:name_constant, %{}, "::first-of-type"}]

    assert lex("a:hover") == [
             {:name_builtin, %{}, "a"},
             {:name_constant, %{}, ":hover"}
           ]
  end

  test "tag selector" do
    assert lex("div") == [{:name_builtin, %{}, "div"}]
    assert lex("*") == [{:name_builtin, %{}, "*"}]
  end

  test "class selector" do
    assert lex(".foo") == [{:name_class, %{}, ".foo"}]
    assert lex(".foo-bar") == [{:name_class, %{}, ".foo-bar"}]
    assert lex("div.foo") == [{:name_builtin, %{}, "div"}, {:name_class, %{}, ".foo"}]
  end

  test "id selector" do
    assert lex("#foo") == [{:name_constant, %{}, "#foo"}]
    assert lex("#foo-bar") == [{:name_constant, %{}, "#foo-bar"}]
    assert lex("div#foo") == [{:name_builtin, %{}, "div"}, {:name_constant, %{}, "#foo"}]
  end

  test "attribute selector" do
    assert lex("[foo=bar]") == [{:name_attribute, %{}, "[foo=bar]"}]
    assert lex("[foo='bar']") == [{:name_attribute, %{}, "[foo='bar']"}]
  end

  test "at-rule" do
    assert lex("@import") == [{:keyword_type, %{}, "@import"}]
  end
end
