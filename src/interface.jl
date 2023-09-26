"""
    Column

Union of types used to select a column.
"""
const Column = Union{Integer,Symbol,AbstractString}

"""
    ColumnSelector

`ColumnSelector` is the parent type of all selector types used to select columns.
The `ColumnSelector` abstract type together with the `Column` union type, 
the `selector` trait function, the `select` and `selectsingle` functions
form the ColumnSelector interface.

All selectors can be called as functors, this is equivalent to calling the `select` function,
that is, `selector(names)` is equivalent to `select(selector, names)`.
"""
abstract type ColumnSelector end

"""
    SingleColumnSelector <: ColumnSelector

`SingleColumnSelector` is a `ColumnSelector` that selects only one column
defined by the `Column` union type.
"""
abstract type SingleColumnSelector <: ColumnSelector end

"""
    selector(obj) -> ColumnSelector

Trait function that converts the `obj` argument to a `ColumnSelector` object.

# Examples

```julia
selector(1:10) # IndexSelector
selector((1, 2, 3)) # IndexSelector
selector([:a, :b, :c]) # NameSelector
selector((:a, :b, :c)) # NameSelector
selector(["a", "b", "c"]) # NameSelector
selector(("a", "b", "c")) # NameSelector
selector(r"[abc]") # RegexSelector
selector(:) # AllSelector
selector(nothing) # NoneSelector
# single column selection
selector(1) # SingleIndexSelector
selector(:a) # SingleNameSelector
selector("a") # SingleNameSelector
# if the argument is a selector, return it
selector(NoneSelector()) # NoneSelector
```
"""
function selector end

"""
    select(selector::ColumnSelector, names) -> Vector{Symbol}

Select column `names` using a `selector`.

Calling the `select` function directly is not necessary because
all selectors, when called as functors, call this function.

# Examples

```julia
julia> names = (:a, :b, :c, :d, :e, :f);

julia> select(selector((1, 3, 5)), names)
3-element Vector{Symbol}:
 :a
 :c
 :e

julia> selector([1, 3, 5])(names) # calls the select function
3-element Vector{Symbol}:
 :a
 :c
 :e

julia> select(selector([:a, :c, :e]), names)
3-element Vector{Symbol}:
 :a
 :c
 :e

julia> select(selector(["a", "c", "e"]), names)
3-element Vector{Symbol}:
 :a
 :c
 :e

julia> select(RegexSelector(r"[ace]"), names)
3-element Vector{Symbol}:
 :a
 :c
 :e

julia> select(AllSelector(), names)
6-element Vector{Symbol}:
 :a
 :b
 :c
 :d
 :e
 :f

julia> select(NoneSelector(), names)
Symbol[]

julia> select(selector(1), names)
1-element Vector{Symbol}:
 :a

julia> select(selector(:c), names)
1-element Vector{Symbol}:
 :c

julia> select(selector("e"), names)
1-element Vector{Symbol}:
 :e
```
"""
function select end

"""
    selectsingle(selector::SingleColumnSelector, names) -> Symbol

Select a single column name using a `selector`.

# Examples

```julia
julia> names = [:a, :b, :c, :d, :e, :f];

julia> selectsingle(selector(1), names)
:a

julia> selectsingle(selector(:c), names)
:c

julia> selectsingle(selector("e"), names)
:e
```
"""
function selectsingle end

# fallbacks
(selector::ColumnSelector)(names) = select(selector, names)

selector(s::ColumnSelector) = s
selector(::Any) = throw(ArgumentError("invalid column selection"))
selector(::Tuple{}) = throw(ArgumentError("column selection cannot be empty"))

select(selector::SingleColumnSelector, names) = [selectsingle(selector, names)]
