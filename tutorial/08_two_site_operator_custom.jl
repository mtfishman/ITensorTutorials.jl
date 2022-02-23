include("07_two_site_operator.jl")

println("
#######################################################
# Tutorial 8                                          #
#                                                     #
# 2-site custom operator/gate definition              #
#######################################################
")

import ITensors: op

# Controlled-Ry rotation gate
function op(::OpName"CRy", ::SiteType"S=1/2"; θ)
  return [
    1 0 0           0
    0 1 0           0
    0 0 cos(θ / 2) -sin(θ / 2)
    0 0 sin(θ / 2)  cos(θ / 2)
  ]
end

# Controlled-Hadamard gate, CH = CRy(θ=π/2)
CH = op("CRy", i1, i2; θ=π/2)

# |10⟩ = |Z+Z-⟩
ZpZm = Zp1 * Zm2

CH_Xm = apply(CH, ZpZm)

# CH|Z+Z-⟩ = |Z+X-⟩
@show CH_Xm ≈ Zp1 * Xm2
