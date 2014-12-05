defmodule BencodeTest do
  use ExUnit.Case

  import Bencode

  test "Parse integer" do
    assert decode!("i42e") === 42
  end

  test "Parse negative integer" do
    assert decode!("i-42e") === -42
  end

  test "Parse zero integer" do
    assert decode!("i0e") === 0
  end

  test "Parse integer with faulty tail" do
    assert decode("i123etest") === {:error, "test"}
  end

  test "Negative zero is not allowed" do
    assert catch_error(decode!("i-0e")) === {:badmatch, nil}
  end

  test "Chars in numbers is not allowed" do
    assert catch_error(decode!("i1a2e")) === {:badmatch, nil}
  end

  test "Parse string with faulty tail" do
    assert decode("4:spamtest") === {:error, "test"}
  end

  test "Parse empty string" do
    assert decode!("0:") === ""
  end

  test "Parse empty string with faulty tail" do
    assert decode("0:test") === {:error, "test"}
  end

  test "Parse bytes" do
    assert <<123, 2, 5>> == decode!("3:" <> <<123, 2, 5>>)
  end

  test "Parse list with strings" do
    assert ["ham", "spam"] === decode!("l3:ham4:spame")
  end

  test "Parse list with ints" do
    assert [12, 45] === decode!("li12ei45ee")
  end

  test "Parse list with string and int" do
    assert ["spam", 42] === decode!("l4:spami42ee")
  end

  test "Parse list with nested string and int" do
    assert ["spam", 42, ["ham", 56, ["clam", 89]]] === decode!("l4:spami42el3:hami56el4:clami89eeee")
  end

  test "Parse map with int key values" do
    assert %{1 => 2, 3 => 4} === decode!("di1ei2ei3ei4ee")
  end

  test "Parse map with mixed key values" do
    assert %{"spam" => 1, 2 => "ham"} === decode!("d4:spami1ei2e3:hame")
  end

  test "Parse nested map" do
    assert %{%{1 => 2} => %{"ab" => "cd"}} === decode!("ddi1ei2eed2:ab2:cdee")
  end

  test "Complex map structure" do
    assert %{[1,2] => "woot", "spam" => 1, 2 => ["spam", 42, ["ham", 56, ["clam", 89]]]} === decode!("dli1ei2ee4:woot4:spami1ei2el4:spami42el3:hami56el4:clami89eeeee")
  end

  test "Complex list structure" do
    assert [%{1 => 2, "ab" => "cd"}, %{1 => 2, "ab" => "cd"}] === decode!("ldi1ei2e2:ab2:cdedi1ei2e2:ab2:cdee")
  end
end
