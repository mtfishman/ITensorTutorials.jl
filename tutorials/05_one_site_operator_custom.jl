include("04_one_site_operator.jl")

println("
#######################################################
# Tutorial 5                                          #
#                                                     #
# 1-site custom operator/gate definition              #
#######################################################
")

# Define your own `op`:
import ITensors: op

function op(::OpName"iX", ::SiteType"S=1/2", i::Index)
  iX = ITensor(i', dag(i))
  iX[i' => 2, i => 1] = im
  iX[i' => 1, i => 2] = im
  return iX
end

# Alternative shorthand with matrices:
function op(::OpName"iX", ::SiteType"S=1/2")
  return [
    0 im
    im 0
  ]
end

iX = ITensor(i', dag(i))
iX[i' => 2, i => 1] = im
iX[i' => 1, i => 2] = im

@show iX == op("iX", i)

@show inner(Xp', iX, Xp)
@show inner(Xp, apply(iX, Xp))
