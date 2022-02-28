##using ITensors

## ######################################################################
## # XXX: Is this needed anywhere?
## # ITensors
## # PR: commontags with no inputs
## #
## 
## import ITensors: commontags
## 
## commontags() = TagSet()

## ######################################################################
## # XXX: Is this needed anywhere?
## # ITensors
## # PR: improve `rrule` for `setinds`.
## #
## 
## using ChainRulesCore
## using ITensors.NDTensors
## 
## using ITensors.NDTensors: setinds
## 
## import ChainRulesCore: rrule
## 
## function rrule(::typeof(setinds), x::Tensor, a...)
##   y = setinds(x, a...)
##   function setinds_pullback(ȳ)
##     x̄ = setinds(ȳ, inds(x))
##     return (NoTangent(), x̄, map(Returns(NoTangent()), a))
##   end
##   return y, setinds_pullback
## end

## ######################################################################
## # XXX: Is this needed anywhere?
## # ITensors
## # PR: define `ITensor(::ITensor)` and related functions.
## #
## 
## using ChainRulesCore
## using ITensors.NDTensors
## 
## import ITensors: itensor, ITensor, tensor, Tensor
## 
## itensor(T::ITensor) = T
## ITensor(T::ITensor) = copy(T)
## tensor(T::Tensor) = T
## Tensor(T::Tensor) = copy(T)
## 
## function rrule(::typeof(itensor), x::ITensor)
##   y = x
##   function itensor_pullback(ȳ)
##     x̄ = ȳ
##     return (NoTangent(), x̄)
##   end
##   return y, itensor_pullback
## end
## 
## function rrule(::typeof(itensor), x::Tensor)
##   y = itensor(x)
##   function itensor_pullback(ȳ)
##     x̄ = tensor(ȳ)
##     return (NoTangent(), x̄)
##   end
##   return y, itensor_pullback
## end
## 
## function rrule(::Type{ITensor}, x::Tensor)
##   y = ITensor(x)
##   function ITensor_pullback(ȳ)
##     x̄ = Tensor(ȳ)
##     return (NoTangent(), x̄)
##   end
##   return y, ITensor_pullback
## end
## 
## function rrule(::Type{ITensor}, x::ITensor)
##   y = copy(x)
##   function ITensor_pullback(ȳ)
##     x̄ = copy(ȳ)
##     return (NoTangent(), x̄)
##   end
##   return y, ITensor_pullback
## end
## 
## function rrule(::typeof(tensor), x::ITensor)
##   y = tensor(x)
##   function tensor_pullback(ȳ)
##     x̄ = itensor(ȳ)
##     return (NoTangent(), x̄)
##   end
##   return y, tensor_pullback
## end
## 
## function rrule(::typeof(tensor), x::Tensor)
##   y = x
##   function tensor_pullback(ȳ)
##     x̄ = ȳ
##     return (NoTangent(), x̄)
##   end
##   return y, tensor_pullback
## end
## 
## function rrule(::Type{Tensor}, x::ITensor)
##   y = Tensor(x)
##   function Tensor_pullback(ȳ)
##     x̄ = ITensor(ȳ)
##     return (NoTangent(), x̄)
##   end
##   return y, Tensor_pullback
## end
## 
## function rrule(::Type{Tensor}, x::Tensor)
##   y = copy(x)
##   function Tensor_pullback(ȳ)
##     x̄ = copy(ȳ)
##     return (NoTangent(), x̄)
##   end
##   return y, Tensor_pullback
## end

## ######################################################################
## # XXX: This is WIP to improve differentiability of priming/tagging MPS/MPO.
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
