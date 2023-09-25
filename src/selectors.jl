# IndexSelector: select columns using indices
struct IndexSelector <: ColSelector
  inds::Vector{Int}
  function IndexSelector(inds)
    if isempty(inds)
      throw(ArgumentError("column selection cannot be empty"))
    end
    new(inds)
  end
end

Base.show(io::IO, selector::IndexSelector) = print(io, selector.inds)

colselector(inds::AbstractVector{<:Integer}) = IndexSelector(inds)
colselector(inds::NTuple{N,<:Integer}) where {N} = IndexSelector(collect(inds))

choose(selector::IndexSelector, names) = choose(selector, asvector(names))
choose(selector::IndexSelector, names::Vector{Symbol}) = names[selector.inds]

# NameSelector: select columns using names
struct NameSelector <: ColSelector
  names::Vector{Symbol}
  function NameSelector(names)
    if isempty(names)
      throw(ArgumentError("column selection cannot be empty"))
    end
    new(names)
  end
end

Base.show(io::IO, selector::NameSelector) = print(io, selector.names)

colselector(names::AbstractVector{Symbol}) = NameSelector(names)
colselector(names::AbstractVector{<:AbstractString}) = NameSelector(Symbol.(names))
colselector(names::NTuple{N,Symbol}) where {N} = NameSelector(collect(names))
colselector(names::NTuple{N,<:AbstractString}) where {N} = NameSelector(collect(Symbol.(names)))

choose(selector::NameSelector, names) = _choose(selector.names, names)

# RegexSelector: select columns than match with regex
struct RegexSelector <: ColSelector
  regex::Regex
end

Base.show(io::IO, selector::RegexSelector) = print(io, selector.regex)

colselector(regex::Regex) = RegexSelector(regex)

choose(selector::RegexSelector, names) = choose(selector, asvector(names))
function choose(selector::RegexSelector, names::Vector{Symbol})
  regex = selector.regex
  snames = filter(nm -> occursin(regex, String(nm)), names)
  @assert !isempty(snames) "regex doesn't match any names in input table"
  _choose(snames, names)
end

# AllSelector: select all columns
struct AllSelector <: ColSelector end

Base.show(io::IO, ::AllSelector) = print(io, "all")

colselector(::Colon) = AllSelector()

choose(::AllSelector, names) = asvector(names)
choose(::AllSelector, names::Vector{Symbol}) = names

# NoneSelector: select no column
struct NoneSelector <: ColSelector end

Base.show(io::IO, ::NoneSelector) = print(io, "none")

colselector(::Nothing) = NoneSelector()

choose(::NoneSelector, names) = Symbol[]

# helper functions
asvector(names) = asvector(collect(Symbol, names))
asvector(names::AbstractArray{Symbol}) = vec(names)
asvector(names::Vector{Symbol}) = names

function _choose(snames::Vector{Symbol}, names)
  # validate columns
  @assert snames ⊆ names "names not present in input table"
  return snames
end
