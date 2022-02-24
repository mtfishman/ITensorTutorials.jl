include("09_two_site_state_optimization.jl")

println("
#######################################################
# Tutorial 10                                         #
#                                                     #
# 2-site circuit minimization via gradient            #
# optimization                                        #
#######################################################
")

# Circuit optimization
# Bonus: this is a Matchgate, we could do this
# with free fermions (correlation matrix formalism)
function op(::OpName"U", ::SiteType"S=1/2"; θ1, θ2)
  c1 = cos(θ1/2)
  s1 = sin(θ1/2)
  c2 = cos(θ2/2)
  s2 = sin(θ2/2)
  return [
    c1  0   0 -s1
    0  c2 -s2   0
    0  s2  c2   0
    s1  0   0  c1
  ]
end

# References state `|0⟩ = |Z+Z+⟩`
ψ⁰ = Zp1 * Zp2

# Find `U(θ)` that minimizes
#
# energy_circuit(θ) = ⟨0|U(θ)† H U(θ)|0⟩ = ⟨θ|H|θ⟩
function E(θ)
  # Circuit: for now just a single gate:
  # U(θ)
  θ1, θ2 = θ
  Uᶿ = op("U", i1, i2; θ1=θ1, θ2=θ2)

  # Apply the gate to the circuit:
  # |θ⟩ = U(θ)|0⟩
  #
  # Same as `noprime(Uᶿ * ψ0)`:
  ψᶿ = apply(Uᶿ, ψ⁰)

  # Compute the expecation value: ⟨θ|H|θ⟩
  # No need to normalize!
  return inner(ψᶿ', H, ψᶿ)
end

println("Circuit optimization")
θ⁰ = [π/2, 0]
∂E(ψ) = gradient(E, ψ)[1]
θ = minimize(E, ∂E, θ⁰; nsteps=30, γ=0.1)

@show θ⁰, E(θ⁰), norm(∂E(θ⁰))
@show θ, E(θ), norm(∂E(θ))
