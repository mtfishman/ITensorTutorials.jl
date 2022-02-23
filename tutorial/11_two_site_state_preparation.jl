include("10_two_site_circuit_optimization.jl")

println("
#######################################################
# Tutorial 11                                         #
#                                                     #
# 2-site state preparation via gradient               #
# optimization                                        #
#######################################################
")

#
# State preparation
#

# Starting/reference state `|v0⟩ = |Z+Z+⟩`
v0 = Zp1 * Zp2

# Target state `|x⟩ = (|Z+Z+⟩ + |Z-Z-⟩) / √2`
x = (ZpZp + ZmZm) / √2

# Find `U(θ)` that minimizes
#
# state_preparation(θ) = -|⟨x|U(θ)|0⟩|² = -|⟨x|θ⟩|²
function state_preparation(θ)
  # Circuit (single gate)
  θ1, θ2 = θ
  U_θ = op("U", i1, i2; θ1=θ1, θ2=θ2)

  # |θ⟩ = U(θ)|0⟩
  vθ = apply(U_θ, v0)

  # ⟨x|θ⟩
  x_vθ = inner(x, vθ)

  # -|⟨x|θ⟩|²
  return -abs(x_vθ)^2
end

println("Circuit optimization")
θ1, θ2 = 0, 0
θ_min = minimize(state_preparation, [θ1, θ2]; nsteps=20, γ=0.1)

@show θ_min, [π/4, 0]
