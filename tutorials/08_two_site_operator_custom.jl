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
    0 0 sin(θ / 2) cos(θ / 2)
  ]
end

# CRy(θ=π/2)
θ = π / 2
CRyθ = op("CRy", i1, i2; θ)

# |10⟩ = |Z-Z+⟩
ZmZp = Zm1 * Zp2

# CRyθ|Z-Z+⟩ = |Z-X+⟩
@show apply(CRyθ, ZmZp) ≈ Zm1 * Xp2
