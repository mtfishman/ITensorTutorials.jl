include("11_two_site_state_preparation.jl")

println("
#######################################################
# Tutorial 12                                         #
#                                                     #
# n-site circuit optimization with MPS                #
#######################################################
")

# Beyond full state, use approximations
n = 30
i = [Index(2, "S=1/2") for j in 1:n]

# Product state |Z+Z+Z+…Z+⟩
Zp = MPS(i, "Z+")

# Product state |Z-Z-Z-…Z-⟩
Zm = MPS(i, "Z-")

inner(Zp, Zp)
inner(Zm, Zp)

# Do some arithmatic with them, like tensors:
# TODO: fix this when normalize PR is merged!
#Cat = (Zp + Zm) / √2
#
# Performs a truncated MPS addition,
# returns an MPS approximate up to some tolerance.
Cat = (Zp + Zm) * (1 / √2)
@show maxlinkdim(Zp)
@show maxlinkdim(Zm)
@show maxlinkdim(Cat)
@show norm(Cat)
@show inner(Cat, Zp)
@show inner(Cat, Zm)

# Apply operators:
j = n ÷ 2
Xⱼ = op("X", i[j])
XⱼZp = apply(Xⱼ, Zp)

XⱼZp = MPS(i, [k == j ? "Z-" : "Z+" for k in 1:n])
@show inner(XⱼZp, apply(Xⱼ, Zp))

function ising(n; h)
  # Symbolic representation
  # of the Hamiltonian ("operator sum")
  H = OpSum()
  for j in 1:(n - 1)
    H -= "Z", j, "Z", j + 1
  end
  for j in 1:n
    H += h, "X", j
  end
  return H
end

h = 0.5
H = MPO(ising(n; h=h), i)

# Performs a truncated MPO*MPS contraction,
# returns an MPS approximate up to some tolerance.
HZp = H * Zp
@show inner(Zp', HZp)
@show inner(Zp', H, Zp)

# Gradient energy minimization
# Already written above! New Hamiltonian.
function E(ψ)
  ψHψ = inner(ψ', H, ψ)
  ψψ = inner(ψ, ψ)
  return ψHψ / ψψ
end

function minimize(f, ∂f, x; nsteps, γ, kwargs...)
  for n in 1:nsteps
    println("n = ", n, ", f_x = ", f(x))
    x = -(x, γ * ∂f(x); kwargs...)
  end
  return x
end

ψ⁰ = MPS(i, "Z+")
∂E(x) = gradient(E, x)[1]
ψ = minimize(E, ∂E, ψ⁰; nsteps=50, γ=0.1, maxdim=10, cutoff=1e-5)

# TODO: change to:
# ψ /= norm(ψ)
ψ *= inv(norm(ψ))

Eᵈᵐʳᵍ, ψᵈᵐʳᵍ = dmrg(H, ψ⁰; nsweeps=10, maxdim=10, cutoff=1e-5)

@show maxlinkdim(ψ⁰)
@show maxlinkdim(ψ)
@show maxlinkdim(ψᵈᵐʳᵍ)
@show E(ψ⁰), norm(∂E(ψ⁰))
@show E(ψ), norm(∂E(ψ))
@show E(ψᵈᵐʳᵍ), norm(∂E(ψᵈᵐʳᵍ))

#
# Circuit optimization
#

# Form the circuit from parameters
Ry_layer(θ, i) = [op("Ry", i[j]; θ=θ[j]) for j in 1:n]
CX_layer(i) = [op("CX", i[j], i[j+1]) for j in 1:2:(n-1)]

function U(θ, i; nlayers)
  n = length(i)
  Uᶿ = Ry_layer(θ[1:n], i)
  for l in 1:(nlayers - 1)
    Uᶿ = [Uᶿ; CX_layer(i)]
    Uᶿ = [Uᶿ; Ry_layer(θ[(1:n) .+ l * n], i)]
  end
  return Uᶿ
end

nlayers = 6
maxdim = 10
cutoff = 1e-5

# Find the circuit `U(θ)` that minimizes:
# E(θ) = ⟨0|U(θ)† H U(θ)|0⟩ = ⟨θ|H|θ⟩
function E(θ)
  # Apply the circuit:
  # |θ⟩ = U(θ)|0⟩
  ψᶿ = apply(U(θ, i; nlayers=nlayers), ψ⁰; maxdim=maxdim, cutoff=cutoff)

  # Compute the expecation value: ⟨θ|H|θ⟩
  # No need to normalize!
  return inner(ψᶿ', H, ψᶿ)
end

println()
println("Circuit optimization")
θ⁰ = zeros(nlayers * n)
∂E(ψ) = gradient(E, ψ)[1]
θ = minimize(E, ∂E, θ⁰; nsteps=20, γ=0.1)

ψᶿ = apply(U(θ, i; nlayers=nlayers), ψ⁰; maxdim=maxdim, cutoff=cutoff)

@show maxlinkdim(ψ⁰)
@show maxlinkdim(ψᶿ)
@show E(θ⁰), norm(∂E(θ⁰))
@show E(θ), norm(∂E(θ))

# TODO: Finish this implementation
# Example of preparing the ground state
# Find `U(θ)` that minimizes
#
# F(θ) = -|⟨ψ|U(θ)|0⟩|²
function F(θ)
  # Apply the circuit:
  # |θ⟩ = U(θ)|0⟩
  ψᶿ = apply(U(θ, i; nlayers=nlayers), ψ⁰; maxdim=maxdim, cutoff=cutoff)

  # -|⟨ψ|θ⟩|²
  return -abs(inner(ψ, ψᶿ))^2
end

println()
println("State preparation")
θ⁰ = zeros(nlayers * n)
∂F(ψ) = gradient(F, ψ)[1]
θ = minimize(F, ∂F, θ⁰; nsteps=20, γ=0.1)

ψᶿ = apply(U(θ, i; nlayers=nlayers), ψ⁰; maxdim=maxdim, cutoff=cutoff)

@show maxlinkdim(ψ⁰)
@show maxlinkdim(ψᶿ)
@show F(θ⁰), norm(∂F(θ⁰))
@show F(θ), norm(∂F(θ))
