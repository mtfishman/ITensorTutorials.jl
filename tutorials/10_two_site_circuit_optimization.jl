include("09_two_site_state_optimization.jl")

println("
#######################################################
# Tutorial 10                                         #
#                                                     #
# 2-site circuit minimization via gradient            #
# optimization                                        #
#######################################################
")

# References state `|0⟩ = |Z+Z+⟩`
ψ⁰ = Zp1 * Zp2

# Form the circuit from parameters
U(θ, i1, i2) = [
  op("Ry", i1; θ=θ[1]),
  op("Ry", i2; θ=θ[2]),
  op("CX", i1, i2),
  op("Ry", i1; θ=θ[3]),
  op("Ry", i2; θ=θ[4]),
]

# Find the circuit `U(θ)` that minimizes:
# energy_circuit(θ) = ⟨0|U(θ)† H U(θ)|0⟩ = ⟨θ|H|θ⟩
function E(θ)
  # Apply the circuit:
  # |θ⟩ = U(θ)|0⟩
  ψᶿ = apply(U(θ, i1, i2), ψ⁰)

  # Compute the expecation value: ⟨θ|H|θ⟩
  # No need to normalize!
  return inner(ψᶿ', H, ψᶿ)
end

println("Circuit optimization")
θ⁰ = zeros(4)
∂E(ψ) = gradient(E, ψ)[1]
θ = minimize(E, ∂E, θ⁰; nsteps=40, γ=0.5)

@show θ⁰, E(θ⁰), norm(∂E(θ⁰))
@show θ, E(θ), norm(∂E(θ))
