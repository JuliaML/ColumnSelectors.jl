import ColumnSelectors as CS
using Test

@testset "ColumnSelectors.jl" begin
  vecnames = [:a, :b, :c, :d, :e, :f]
  tupnames = (:a, :b, :c, :d, :e, :f)

  # vector of integers
  selector = CS.selector([1, 3, 5])
  snames = selector(vecnames)
  @test snames == [:a, :c, :e]
  snames = selector(tupnames)
  @test snames == [:a, :c, :e]

  # tuple of integers
  selector = CS.selector((1, 3, 5))
  snames = selector(vecnames)
  @test snames == [:a, :c, :e]
  snames = selector(tupnames)
  @test snames == [:a, :c, :e]

  # vector of symbols
  selector = CS.selector([:a, :c, :e])
  snames = selector(vecnames)
  @test snames == [:a, :c, :e]
  snames = selector(tupnames)
  @test snames == [:a, :c, :e]

  # tuple of symbols
  selector = CS.selector((:a, :c, :e))
  snames = selector(vecnames)
  @test snames == [:a, :c, :e]
  snames = selector(tupnames)
  @test snames == [:a, :c, :e]

  # vector of strings
  selector = CS.selector(["a", "c", "e"])
  snames = selector(vecnames)
  @test snames == [:a, :c, :e]
  snames = selector(tupnames)
  @test snames == [:a, :c, :e]

  # tuple of strings
  selector = CS.selector(("a", "c", "e"))
  snames = selector(vecnames)
  @test snames == [:a, :c, :e]
  snames = selector(tupnames)
  @test snames == [:a, :c, :e]

  # regex
  selector = CS.selector(r"[ace]")
  snames = selector(vecnames)
  @test snames == [:a, :c, :e]
  snames = selector(tupnames)
  @test snames == [:a, :c, :e]

  # colon
  selector = CS.selector(:)
  snames = selector(vecnames)
  @test snames == [:a, :b, :c, :d, :e, :f]
  snames = selector(tupnames)
  @test snames == [:a, :b, :c, :d, :e, :f]

  # nothing
  selector = CS.selector(nothing)
  snames = selector(vecnames)
  @test snames == Symbol[]
  snames = selector(tupnames)
  @test snames == Symbol[]

  # single integer
  selector = CS.selector(1)
  sname = CS.selectsingle(selector, vecnames)
  snames = CS.select(selector, vecnames)
  @test sname == :a
  @test snames == [:a]
  sname = CS.selectsingle(selector, tupnames)
  snames = CS.select(selector, tupnames)
  @test sname == :a
  @test snames == [:a]

  # single symbol
  selector = CS.selector(:b)
  sname = CS.selectsingle(selector, vecnames)
  snames = CS.select(selector, vecnames)
  @test sname == :b
  @test snames == [:b]
  sname = CS.selectsingle(selector, tupnames)
  snames = CS.select(selector, tupnames)
  @test sname == :b
  @test snames == [:b]

  # single string
  selector = CS.selector("c")
  sname = CS.selectsingle(selector, vecnames)
  snames = CS.select(selector, vecnames)
  @test sname == :c
  @test snames == [:c]
  sname = CS.selectsingle(selector, tupnames)
  snames = CS.select(selector, tupnames)
  @test sname == :c
  @test snames == [:c]

  # shows
  selector = CS.selector([1, 2, 3])
  @test sprint(show, selector) == "[1, 2, 3]"
  selector = CS.selector((:a, :b, :c))
  @test sprint(show, selector) == "[:a, :b, :c]"
  selector = CS.selector(["a", "b", "c"])
  @test sprint(show, selector) == "[:a, :b, :c]"
  selector = CS.selector(r"[abc]")
  @test sprint(show, selector) == "r\"[abc]\""
  selector = CS.selector(:)
  @test sprint(show, selector) == "all"
  selector = CS.selector(nothing)
  @test sprint(show, selector) == "none"
  selector = CS.selector(1)
  @test sprint(show, selector) == "1"
  selector = CS.selector(:b)
  @test sprint(show, selector) == ":b"
  selector = CS.selector("c")
  @test sprint(show, selector) == ":c"

  # throws
  # invalid selector
  @test_throws ArgumentError CS.selector(missing)
  # empty selection
  @test_throws ArgumentError CS.selector(())
  @test_throws ArgumentError CS.selector(Int[])
  @test_throws ArgumentError CS.selector(Symbol[])
  @test_throws ArgumentError CS.selector(String[])
  # regex doesn't match any names in input table
  selector = CS.selector(r"x")
  @test_throws AssertionError CS.select(selector, vecnames)
  @test_throws AssertionError CS.select(selector, tupnames)
  # names not present in input table
  selector = CS.selector([:x, :a])
  @test_throws AssertionError CS.select(selector, vecnames)
  @test_throws AssertionError CS.select(selector, tupnames)

  # type stability
  selector = CS.selector([1, 2])
  @inferred CS.select(selector, vecnames)
  @inferred CS.select(selector, tupnames)
  selector = CS.selector((1, 2))
  @inferred CS.select(selector, vecnames)
  @inferred CS.select(selector, tupnames)
  selector = CS.selector([:a, :b])
  @inferred CS.select(selector, vecnames)
  @inferred CS.select(selector, tupnames)
  selector = CS.selector((:a, :b))
  @inferred CS.select(selector, vecnames)
  @inferred CS.select(selector, tupnames)
  selector = CS.selector(["a", "b"])
  @inferred CS.select(selector, vecnames)
  @inferred CS.select(selector, tupnames)
  selector = CS.selector(("a", "b"))
  @inferred CS.select(selector, vecnames)
  @inferred CS.select(selector, tupnames)
  selector = CS.selector(r"[ab]")
  @inferred CS.select(selector, vecnames)
  @inferred CS.select(selector, tupnames)
  selector = CS.selector(:)
  @inferred CS.select(selector, vecnames)
  @inferred CS.select(selector, tupnames)
  selector = CS.selector(nothing)
  @inferred CS.select(selector, vecnames)
  @inferred CS.select(selector, tupnames)
  selector = CS.selector(3)
  @inferred CS.select(selector, vecnames)
  @inferred CS.select(selector, tupnames)
  selector = CS.selector(:a)
  @inferred CS.select(selector, vecnames)
  @inferred CS.select(selector, tupnames)
  selector = CS.selector("b")
  @inferred CS.select(selector, vecnames)
  @inferred CS.select(selector, tupnames)
end
