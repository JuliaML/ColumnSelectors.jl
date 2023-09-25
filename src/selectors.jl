# IndexSelector: select columns using indices
struct IndexSelector <: ColumnSelector
  inds::Vector{Int}
  function IndexSelector(inds)
    if isempty(inds)
      throw(ArgumentError("column selection cannot be empty"))
    end
    new(inds)
  end
end

Base.show(io::IO, selector::IndexSelector) = print(io, selector.inds)

selector(inds::AbstractVector{<:Integer}) = IndexSelector(inds)
selector(inds::NTuple{N,<:Integer}) where {N} = IndexSelector(collect(inds))

select(selector::IndexSelector, names) = select(selector, _asvector(names))
select(selector::IndexSelector, names::Vector{Symbol}) = names[selector.inds]

# NameSelector: select columns using names
struct NameSelector <: ColumnSelector
  names::Vector{Symbol}
  function NameSelector(names)
    if isempty(names)
      throw(ArgumentError("column selection cannot be empty"))
    end
    new(names)
  end
end

Base.show(io::IO, selector::NameSelector) = print(io, selector.names)

selector(names::AbstractVector{Symbol}) = NameSelector(names)
selector(names::AbstractVector{<:AbstractString}) = NameSelector(Symbol.(names))
selector(names::NTuple{N,Symbol}) where {N} = NameSelector(collect(names))
selector(names::NTuple{N,<:AbstractString}) where {N} = NameSelector(collect(Symbol.(names)))

select(selector::NameSelector, names) = _select(selector.names, names)

# RegexSelector: select columns than match with regex
struct RegexSelector <: ColumnSelector
  regex::Regex
end

Base.show(io::IO, selector::RegexSelector) = print(io, selector.regex)

selector(regex::Regex) = RegexSelector(regex)

select(selector::RegexSelector, names) = select(selector, _asvector(names))
function select(selector::RegexSelector, names::Vector{Symbol})
  regex = selector.regex
  snames = filter(nm -> occursin(regex, String(nm)), names)
  @assert !isempty(snames) "regex doesn't match any names in input table"
  _select(snames, names)
end

# AllSelector: select all columns
struct AllSelector <: ColumnSelector end

Base.show(io::IO, ::AllSelector) = print(io, "all")

selector(::Colon) = AllSelector()

select(::AllSelector, names) = _asvector(names)
select(::AllSelector, names::Vector{Symbol}) = names

# NoneSelector: select no column
struct NoneSelector <: ColumnSelector end

Base.show(io::IO, ::NoneSelector) = print(io, "none")

selector(::Nothing) = NoneSelector()

select(::NoneSelector, names) = Symbol[]

#-------------------------
# SINGLE COLUMN SELECTION
#-------------------------

# SingleIndexSelector: select a single column using a index
struct SingleIndexSelector <: SingleColumnSelector
  ind::Int  
end

Base.show(io::IO, selector::SingleIndexSelector) = show(io, selector.ind)

selector(ind::Integer) = SingleIndexSelector(ind)

selectsingle(selector::SingleIndexSelector, names) = selectsingle(selector, _asvector(names))
selectsingle(selector::SingleIndexSelector, names::Vector{Symbol}) = names[selector.ind]

# SingleNameSelector: select a single column using a name
struct SingleNameSelector <: SingleColumnSelector
  name::Symbol 
end

Base.show(io::IO, selector::SingleNameSelector) = show(io, selector.name)

selector(name::Symbol) = SingleNameSelector(name)
selector(name::AbstractString) = SingleNameSelector(Symbol(name))

function selectsingle(selector::SingleNameSelector, names)
  sname = selector.name
  # validate selection
  @assert sname ∈ names "name not present in input table"
  sname
end

#-----------
# UTILITIES
#-----------

_asvector(names) = _asvector(collect(Symbol, names))
_asvector(names::AbstractArray{Symbol}) = vec(names)
_asvector(names::Vector{Symbol}) = names

function _select(snames::Vector{Symbol}, names)
  # validate columns
  @assert snames ⊆ names "names not present in input table"
  snames
end
