using ColumnSelectors
using Test

@testset "ColumnSelectors.jl" begin
  vecnames = [:a, :b, :c, :d, :e, :f]
  tupnames = (:a, :b, :c, :d, :e, :f)

  # vector of integers
  selector = colselector([1, 3, 5])
  snames = choose(selector, vecnames)
  @test snames == [:a, :c, :e]
  snames = choose(selector, tupnames)
  @test snames == [:a, :c, :e]

  # tuple of integers
  selector = colselector((1, 3, 5))
  snames = choose(selector, vecnames)
  @test snames == [:a, :c, :e]
  snames = choose(selector, tupnames)
  @test snames == [:a, :c, :e]

  # vector of symbols
  selector = colselector([:a, :c, :e])
  snames = choose(selector, vecnames)
  @test snames == [:a, :c, :e]
  snames = choose(selector, tupnames)
  @test snames == [:a, :c, :e]

  # tuple of symbols
  selector = colselector((:a, :c, :e))
  snames = choose(selector, vecnames)
  @test snames == [:a, :c, :e]
  snames = choose(selector, tupnames)
  @test snames == [:a, :c, :e]

  # vector of strings
  selector = colselector(["a", "c", "e"])
  snames = choose(selector, vecnames)
  @test snames == [:a, :c, :e]
  snames = choose(selector, tupnames)
  @test snames == [:a, :c, :e]

  # tuple of strings
  selector = colselector(("a", "c", "e"))
  snames = choose(selector, vecnames)
  @test snames == [:a, :c, :e]
  snames = choose(selector, tupnames)
  @test snames == [:a, :c, :e]

  # regex
  selector = colselector(r"[ace]")
  snames = choose(selector, vecnames)
  @test snames == [:a, :c, :e]
  snames = choose(selector, tupnames)
  @test snames == [:a, :c, :e]

  # colon
  selector = colselector(:)
  snames = choose(selector, vecnames)
  @test snames == [:a, :b, :c, :d, :e, :f]
  snames = choose(selector, tupnames)
  @test snames == [:a, :b, :c, :d, :e, :f]

  # nothing
  selector = colselector(nothing)
  snames = choose(selector, vecnames)
  @test snames == Symbol[]
  snames = choose(selector, tupnames)
  @test snames == Symbol[]

  # single integer
  selector = colselector(3)
  snames = choose(selector, vecnames)
  @test snames == [:c]
  snames = choose(selector, tupnames)
  @test snames == [:c]

  # single symbol
  selector = colselector(:a)
  snames = choose(selector, vecnames)
  @test snames == [:a]
  snames = choose(selector, tupnames)
  @test snames == [:a]

  # single string
  selector = colselector("b")
  snames = choose(selector, vecnames)
  @test snames == [:b]
  snames = choose(selector, tupnames)
  @test snames == [:b]

  # throws
  # invalid selector
  @test_throws ArgumentError colselector(missing)
  # empty selection
  @test_throws ArgumentError colselector(())
  @test_throws ArgumentError colselector(Int[])
  @test_throws ArgumentError colselector(Symbol[])
  @test_throws ArgumentError colselector(String[])
  # regex doesn't match any names in input table
  selector = colselector(r"x")
  @test_throws AssertionError choose(selector, vecnames)
  @test_throws AssertionError choose(selector, tupnames)
  # names not present in input table
  selector = colselector([:x, :a])
  @test_throws AssertionError choose(selector, vecnames)
  @test_throws AssertionError choose(selector, tupnames)

  # type stability
  selector = colselector([1, 2])
  @inferred choose(selector, vecnames)
  @inferred choose(selector, tupnames)
  selector = colselector((1, 2))
  @inferred choose(selector, vecnames)
  @inferred choose(selector, tupnames)
  selector = colselector([:a, :b])
  @inferred choose(selector, vecnames)
  @inferred choose(selector, tupnames)
  selector = colselector((:a, :b))
  @inferred choose(selector, vecnames)
  @inferred choose(selector, tupnames)
  selector = colselector(["a", "b"])
  @inferred choose(selector, vecnames)
  @inferred choose(selector, tupnames)
  selector = colselector(("a", "b"))
  @inferred choose(selector, vecnames)
  @inferred choose(selector, tupnames)
  selector = colselector(r"[ab]")
  @inferred choose(selector, vecnames)
  @inferred choose(selector, tupnames)
  selector = colselector(:)
  @inferred choose(selector, vecnames)
  @inferred choose(selector, tupnames)
  selector = colselector(nothing)
  @inferred choose(selector, vecnames)
  @inferred choose(selector, tupnames)
  selector = colselector(3)
  @inferred choose(selector, vecnames)
  @inferred choose(selector, tupnames)
  selector = colselector(:a)
  @inferred choose(selector, vecnames)
  @inferred choose(selector, tupnames)
  selector = colselector("b")
  @inferred choose(selector, vecnames)
  @inferred choose(selector, tupnames)
end
