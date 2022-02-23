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
  c1 = cos(θ1)
  s1 = sin(θ1)
  c2 = cos(θ2)
  s2 = sin(θ2)
  return [
    c1  0   0 -s1
    0  c2 -s2   0
    0  s2  c2   0
    s1  0   0  c1
  ]
end

# References state `|0⟩ = |Z+Z+⟩`
v0 = Zp1 * Zp2

# Find `U(θ)` that minimizes
#
# energy_circuit(θ) = ⟨0|U(θ)† H U(θ)|0⟩ = ⟨θ|H|θ⟩
function energy_circuit(θ)
  # Circuit: for now just a single gate:
  # U(θ)
  θ1, θ2 = θ
  U_θ = op("U", i1, i2; θ1=θ1, θ2=θ2)

  # Apply the gate to the circuit:
  # |θ⟩ = U(θ)|0⟩
  #
  # Same as `noprime(U_θ * v0)`:
  vθ = apply(U_θ, v0)

  # Compute the expecation value: ⟨θ|H|θ⟩
  # No need to normalize!
  return inner(vθ', H, vθ)
end

println("Circuit optimization")
θ1, θ2 = randn(), randn()
θ_min = minimize(energy_circuit, [θ1, θ2]; nsteps=10, γ=0.1)

@show θ_min
