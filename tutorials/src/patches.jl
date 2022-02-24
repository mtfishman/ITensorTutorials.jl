using ITensors

######################################################################
# ITensors
# PR #1: add keyword argument syntax to `dmrg` to circumvent `Sweeps` object.
#

import ITensors: dmrg

function _dmrg_sweeps(; nsweep, maxdim, mindim=1, cutoff=1e-8, noise=0.0)
  sweeps = Sweeps(nsweep)
  setmaxdim!(sweeps, maxdim)
  setmindim!(sweeps, mindim)
  setcutoff!(sweeps, cutoff)
  setnoise!(sweeps, noise)
  return sweeps
end

function dmrg(x1, x2, psi0::MPS; kwargs...)
  return dmrg(x1, x2, psi0, _dmrg_sweeps(; kwargs...); kwargs...)
end

function dmrg(x1, psi0::MPS; kwargs...)
  return dmrg(x1, psi0, _dmrg_sweeps(; kwargs...); kwargs...)
end

######################################################################
# ITensors
# PR: define `inner(::ITensor, ::ITensor)` and related functions.
#

import ITensors: inner

inner(y::ITensor, A::ITensor, x::ITensor) = (dag(y) * A * x)[]
inner(y::ITensor, x::ITensor) = (dag(y) * x)[]

######################################################################
# ITensors
# PR: add more support for ITensor indexing with strings.
#

using ITensors: Indices

import Base: getindex, setindex!

function _vals(is::Indices, I::String...)
  return val.(is, I)
end

function _vals(T::ITensor, I::String...)
  return _vals(inds(T), I...)
end

function getindex(T::ITensor, I1::String, Is::String...)
  return T[_vals(T, I1, Is...)...]
end

function setindex!(T::ITensor, x::Number, I1::String, Is::String...)
  T[_vals(T, I1, Is...)...] = x
  return T
end

######################################################################
# ITensors
# PR: fix the `rrule` for `inner(::MPS, ::MPS)` for complex/QNs.
#

import ChainRulesCore: rrule

function rrule(::typeof(inner), x1::MPS, x2::MPS; kwargs...)
  y = inner(x1, x2; kwargs...)
  function inner_pullback(ȳ::Number)
    x̄1 = dag(ȳ) * x2
    # `dag` of `x1` gets reversed by `inner`
    x̄2 = x1 * ȳ
    return (NoTangent(), x̄1, x̄2)
  end
  return y, inner_pullback
end

######################################################################
# ITensors
# PR: improve `rrule` for converting between ITensor and Tensor.
#

using ChainRulesCore
using ITensors.NDTensors

using ITensors.NDTensors: setinds

import ChainRulesCore: rrule

function rrule(::typeof(setinds), x::Tensor, a...)
  y = setinds(x, a...)
  function setinds_pullback(ȳ)
    x̄ = setinds(ȳ, inds(x))
    return (NoTangent(), x̄, map(Returns(NoTangent()), a))
  end
  return y, setinds_pullback
end

function rrule(::typeof(itensor), x::ITensor)
  y = x
  function itensor_pullback(ȳ)
    x̄ = ȳ
    return (NoTangent(), x̄)
  end
  return y, itensor_pullback
end

function rrule(::typeof(itensor), x::Tensor)
  y = itensor(x)
  function itensor_pullback(ȳ)
    x̄ = tensor(ȳ)
    return (NoTangent(), x̄)
  end
  return y, itensor_pullback
end

function rrule(::Type{ITensor}, x::Tensor)
  y = ITensor(x)
  function ITensor_pullback(ȳ)
    x̄ = Tensor(ȳ)
    return (NoTangent(), x̄)
  end
  return y, ITensor_pullback
end

function rrule(::Type{ITensor}, x::ITensor)
  y = copy(x)
  function ITensor_pullback(ȳ)
    x̄ = copy(ȳ)
    return (NoTangent(), x̄)
  end
  return y, ITensor_pullback
end

function rrule(::typeof(tensor), x::ITensor)
  y = tensor(x)
  function tensor_pullback(ȳ)
    x̄ = itensor(ȳ)
    return (NoTangent(), x̄)
  end
  return y, tensor_pullback
end

function rrule(::typeof(tensor), x::Tensor)
  y = x
  function tensor_pullback(ȳ)
    x̄ = ȳ
    return (NoTangent(), x̄)
  end
  return y, tensor_pullback
end

function rrule(::Type{Tensor}, x::ITensor)
  y = Tensor(x)
  function Tensor_pullback(ȳ)
    x̄ = ITensor(ȳ)
    return (NoTangent(), x̄)
  end
  return y, Tensor_pullback
end

function rrule(::Type{Tensor}, x::Tensor)
  y = copy(x)
  function Tensor_pullback(ȳ)
    x̄ = copy(ȳ)
    return (NoTangent(), x̄)
  end
  return y, Tensor_pullback
end

## ######################################################################
## # ITensors
## # PR: make `map` of `AbstractMPS` differentiable
## #
## 
## using ITensors: AbstractMPS, data
## 
## import ITensors: MPS, MPO
## import Base: map
## import ChainRulesCore: rrule
## 
## function map(f::Function, M::AbstractMPS; set_limits::Bool=true)
##   new_ortho_lims = set_limits ? eachindex(M) : ortho_lims(M)
##   return typeof(M)(map(f, data(M)); ortho_lims=new_ortho_lims)
## end
## 
## function rrule(::Type{MPS}, x::Vector{ITensor}, a1::Int, a2::Int)
##   y = MPS(x, a1, a2)
##   function MPS_rrule(ȳ)
##     x̄ = data(ȳ)
##     ā1 = NoTangent()
##     ā2 = NoTangent()
##     return (NoTangent(), x̄, ā1, ā2)
##   end
##   return y, MPS_rrule
## end
## 
## function rrule(::Type{MPS}, x::Vector{ITensor}; kwargs...)
##   y = MPS(x; kwargs...)
##   function MPS_rrule(ȳ)
##     x̄ = ȳ.data
##     return (NoTangent(), x̄)
##   end
##   return y, MPS_rrule
## end
## 
## function rrule(::Type{MPO}, x::Vector{ITensor}, a1::Int, a2::Int)
##   y = MPO(x, a1, a2)
##   function MPO_rrule(ȳ)
##     x̄ = data(ȳ)
##     ā1 = NoTangent()
##     ā2 = NoTangent()
##     return (NoTangent(), x̄, ā1, ā2)
##   end
##   return y, MPO_rrule
## end
## 
## function rrule(::Type{MPO}, x::Vector{ITensor}; kwargs...)
##   y = MPO(x; kwargs...)
##   function MPO_rrule(ȳ)
##     x̄ = data(ȳ)
##     return (NoTangent(), x̄)
##   end
##   return y, MPO_rrule
## end
## 
## function rrule(::typeof(getindex), x::MPS, I::Int)
##   @show I
##   y = getindex(x, I)
##   function getindex_pullback(ȳ)
##     x̄ = MPS([ITensor(inds(x[i])) for i in eachindex(x)])
##     x̄[I] = ȳ
##     return (NoTangent(), x̄, NoTangent())
##   end
##   return y, getindex_pullback
## end
## 
## # XXX: This may be a bad definition! Maybe should be `x1 + x1`?
## Zygote.accum(x1::MPS, x2::MPS) = x1 .+ x2

######################################################################
# ITensors
# PR: define `ITensor(::ITensor)` and related functions.
#

import ITensors: itensor, ITensor, tensor, Tensor

itensor(T::ITensor) = T
ITensor(T::ITensor) = copy(T)
tensor(T::Tensor) = T
Tensor(T::Tensor) = copy(T)

######################################################################
# ITensors
# PR: allow more flexible `state` syntax.
#

import ITensors: state

state(sn::String, i::Index) = state(i, sn)

######################################################################
# ITensors
# PR: define "S=1/2" operators with matrix syntax to improve
# differentiability.
#

import ITensors: op

function op(::OpName"Id", ::SiteType"S=1/2")
  return [
    1 0
    0 1
  ]
end

function op(::OpName"X", ::SiteType"S=1/2")
  return [
    0 1
    1 0
  ]
end

function op(::OpName"Z", ::SiteType"S=1/2")
  return [
    1 0
    0 -1
  ]
end

######################################################################
# ITensors
# PR: introduce `ITensor / ITensor` for scalar ITensor
#

import Base: /

(T1::ITensor / T2::ITensor) = T1 / T2[]

######################################################################
# NDTensors/ITensors
# PR: introduce `diag(::ITensor)` and `diag(::Tensor)`
#

using LinearAlgebra

import LinearAlgebra: diag
import Base: similar

diag(T::ITensor) = diag(tensor(T))

function similar(
  T::Tensor,
  ::Type{ElT},
  dims::Tuple{Int}
) where {ElT,N}
  # TODO: Specialize this to the Tensor type, for example
  # block sparse?
  return Vector{ElT}(undef, dims)
end

######################################################################
# ITensorVisualizationBase
# PR: improve `visualize` for single ITensor input
#

using ITensorVisualizationBase.MetaGraphs

import ITensorVisualizationBase: visualize

# Special case single ITensor
function visualize(t::ITensor, sequence=nothing; vertex_labels_prefix, kwargs...)
  tn = [t]
  vertex_labels = [vertex_labels_prefix]
  return visualize(MetaDiGraph(tn), sequence; vertex_labels=vertex_labels, kwargs...)
end

# Special case single ITensor
function visualize(tn::Tuple{ITensor}, args...; kwargs...)
  return visualize(only(tn), args...; kwargs...)
end

######################################################################
# ITensorVisualizationBase
# PR: show plevs by default
#

using ITensorVisualizationBase: Backend

import ITensorVisualizationBase: default_plevs

default_plevs(b::Backend) = true

######################################################################
# ITensors
# PR: commontags with no inputs
#

import ITensors: commontags

commontags() = TagSet()

######################################################################
# ITensors
# PR: get AD through `apply` working
#

using ITensors: filter_inds_set_function

@non_differentiable filter_inds_set_function(::Function, ::Function, ::Any...)
@non_differentiable filter_inds_set_function(::Function, ::Any...)
