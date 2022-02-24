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

# Starting/reference state `|0⟩ = |Z+Z+⟩`
ψ⁰ = Zp1 * Zp2

# Target state `|ψ⟩ = (|Z+Z+⟩ + |Z-Z-⟩) / √2`
ψ = (ZpZp + ZmZm) / √2

# Find `U(θ)` that minimizes
#
# F(θ) = -|⟨ψ|U(θ)|0⟩|² = -|⟨ψ|θ⟩|²
function F(θ)
  # |θ⟩ = U(θ)|0⟩
  ψᶿ = apply(U(θ, i1, i2), ψ⁰)

  # -|⟨ψ|θ⟩|²
  return -abs(inner(ψ, ψᶿ))^2
end

println("Circuit optimization")
θ⁰ = [0, 0, 0, 0]
∂F(θ) = gradient(F, θ)[1]
θ = minimize(F, ∂F, θ⁰; nsteps=50, γ=0.1)

@show θ
@show F(θ⁰), norm(∂F(θ⁰))
@show F(θ), norm(∂F(θ))
