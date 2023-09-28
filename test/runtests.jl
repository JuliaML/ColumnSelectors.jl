import ColumnSelectors as CS
using Test

@testset "ColumnSelectors.jl" begin
  vecnames = [:a, :b, :c, :d, :e, :f]
  tupnames = (:a, :b, :c, :d, :e, :f)

  # index selector: vector of integers
  selector = CS.selector([1, 3, 5])
  @test selector isa CS.IndexSelector
  snames = selector(vecnames)
  @test snames == [:a, :c, :e]
  snames = selector(tupnames)
  @test snames == [:a, :c, :e]

  # index selector: tuple of integers
  selector = CS.selector((1, 3, 5))
  @test selector isa CS.IndexSelector
  snames = selector(vecnames)
  @test snames == [:a, :c, :e]
  snames = selector(tupnames)
  @test snames == [:a, :c, :e]

  # name selector: vector of symbols
  selector = CS.selector([:a, :c, :e])
  @test selector isa CS.NameSelector
  snames = selector(vecnames)
  @test snames == [:a, :c, :e]
  snames = selector(tupnames)
  @test snames == [:a, :c, :e]

  # name selector: tuple of symbols
  selector = CS.selector((:a, :c, :e))
  @test selector isa CS.NameSelector
  snames = selector(vecnames)
  @test snames == [:a, :c, :e]
  snames = selector(tupnames)
  @test snames == [:a, :c, :e]

  # name selector: vector of strings
  selector = CS.selector(["a", "c", "e"])
  @test selector isa CS.NameSelector
  snames = selector(vecnames)
  @test snames == [:a, :c, :e]
  snames = selector(tupnames)
  @test snames == [:a, :c, :e]

  # name selector: tuple of strings
  selector = CS.selector(("a", "c", "e"))
  @test selector isa CS.NameSelector
  snames = selector(vecnames)
  @test snames == [:a, :c, :e]
  snames = selector(tupnames)
  @test snames == [:a, :c, :e]

  # regex selector: regex
  selector = CS.selector(r"[ace]")
  @test selector isa CS.RegexSelector
  snames = selector(vecnames)
  @test snames == [:a, :c, :e]
  snames = selector(tupnames)
  @test snames == [:a, :c, :e]

  # all selector: colon
  selector = CS.selector(:)
  @test selector isa CS.AllSelector
  snames = selector(vecnames)
  @test snames == [:a, :b, :c, :d, :e, :f]
  snames = selector(tupnames)
  @test snames == [:a, :b, :c, :d, :e, :f]

  # none selector: nothing
  selector = CS.selector(nothing)
  @test selector isa CS.NoneSelector
  snames = selector(vecnames)
  @test snames == Symbol[]
  snames = selector(tupnames)
  @test snames == Symbol[]

  # single index selector: integer
  selector = CS.selector(1)
  @test selector isa CS.SingleIndexSelector
  sname = CS.selectsingle(selector, vecnames)
  snames = CS.select(selector, vecnames)
  @test sname == :a
  @test snames == [:a]
  sname = CS.selectsingle(selector, tupnames)
  snames = CS.select(selector, tupnames)
  @test sname == :a
  @test snames == [:a]

  # single name selector: symbol
  selector = CS.selector(:b)
  @test selector isa CS.SingleNameSelector
  sname = CS.selectsingle(selector, vecnames)
  snames = CS.select(selector, vecnames)
  @test sname == :b
  @test snames == [:b]
  sname = CS.selectsingle(selector, tupnames)
  snames = CS.select(selector, tupnames)
  @test sname == :b
  @test snames == [:b]

  # single name selector: string
  selector = CS.selector("c")
  @test selector isa CS.SingleNameSelector
  sname = CS.selectsingle(selector, vecnames)
  snames = CS.select(selector, vecnames)
  @test sname == :c
  @test snames == [:c]
  sname = CS.selectsingle(selector, tupnames)
  snames = CS.select(selector, tupnames)
  @test sname == :c
  @test snames == [:c]

  # fallback: another selector
  selector = CS.selector(CS.NoneSelector())
  @test selector isa CS.NoneSelector

  # shows
  selector = CS.selector([1, 2, 3])
  @test sprint(show, selector) == "[1, 2, 3]"
  selector = CS.selector((1, 2, 3))
  @test sprint(show, selector) == "[1, 2, 3]"
  selector = CS.selector([:a, :b, :c])
  @test sprint(show, selector) == "[:a, :b, :c]"
  selector = CS.selector((:a, :b, :c))
  @test sprint(show, selector) == "[:a, :b, :c]"
  selector = CS.selector(["a", "b", "c"])
  @test sprint(show, selector) == "[:a, :b, :c]"
  selector = CS.selector(("a", "b", "c"))
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
  # column indices must be unique
  @test_throws ArgumentError CS.selector([1, 2, 2])
  @test_throws ArgumentError CS.selector((1, 2, 2))
  # column names must be unique
  @test_throws ArgumentError CS.selector([:a, :b, :b])
  @test_throws ArgumentError CS.selector((:a, :b, :b))
  @test_throws ArgumentError CS.selector(["a", "b", "b"])
  @test_throws ArgumentError CS.selector(("a", "b", "b"))
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
  selector = CS.selector(1)
  @inferred CS.select(selector, vecnames)
  @inferred CS.select(selector, tupnames)
  @inferred CS.selectsingle(selector, vecnames)
  @inferred CS.selectsingle(selector, tupnames)
  selector = CS.selector(:b)
  @inferred CS.select(selector, vecnames)
  @inferred CS.select(selector, tupnames)
  @inferred CS.selectsingle(selector, vecnames)
  @inferred CS.selectsingle(selector, tupnames)
  selector = CS.selector("c")
  @inferred CS.select(selector, vecnames)
  @inferred CS.select(selector, tupnames)
  @inferred CS.selectsingle(selector, vecnames)
  @inferred CS.selectsingle(selector, tupnames)
end
