"""
    ColIndex

Union of types used to select a column.
"""
const ColIndex = Union{Integer,Symbol,AbstractString}

"""
    ColSelector

`ColSelector` is the parent type of all selector types used to choose columns.
The `ColSelector` abstract type together with the `ColIndex` union type, the `colSelector` function
and the `choose` function form the ColSelector interface.
"""
abstract type ColSelector end

"""
    colselector(selector) -> ColSelector

Converts the `selector` argument to a `ColSelector` object.

    colselector(col::ColIndex)

Converts the `col` to a single column selection,
this is equivalent to calling `colselector([col])`.

# Examples

```julia
colselector(1:10) # IndexSelector
colselector((1, 2, 3)) # IndexSelector
colselector([:a, :b, :c]) # NameSelector
colselector((:a, :b, :c)) # NameSelector
colselector(["a", "b", "c"]) # NameSelector
colselector(("a", "b", "c")) # NameSelector
colselector(r"[abc]") # RegexSelector
colselector(:) # AllSelector
colselector(nothing) # NoneSelector
# if the argument is a colselector, return it
colselector(NoneSelector()) # NoneSelector
# single column selection
colselector(1) # IndexSelector
colselector(:a) # NameSelector
colselector("a") # NameSelector
```
"""
function colselector end

"""
    choose(selector::ColSelector, names) -> Vector{Symbol}

Choose column `names` using a `selector`.

# Examples

```julia
julia> names = (:a, :b, :c, :d, :e, :f);

julia> choose(colselector((1, 3, 5)), names)
3-element Vector{Symbol}:
 :a
 :c
 :e

julia> choose(colselector([:a, :c, :e]), names)
3-element Vector{Symbol}:
 :a
 :c
 :e

julia> choose(colselector(["a", "c", "e"]), names)
3-element Vector{Symbol}:
 :a
 :c
 :e

julia> choose(RegexSelector(r"[ace]"), names)
3-element Vector{Symbol}:
 :a
 :c
 :e

julia> choose(AllSelector(), names)
6-element Vector{Symbol}:
  :a
  :b
  :c
  :d
  :e
  :f

julia> choose(NoneSelector(), names)
Symbol[]
```
"""
function choose end

# fallbacks
colselector(selector::ColSelector) = selector
colselector(col::ColIndex) = colselector([col])

# argument errors
colselector(::Any) = throw(ArgumentError("invalid column selection"))
colselector(::Tuple{}) = throw(ArgumentError("column selection cannot be empty"))
