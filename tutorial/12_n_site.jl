include("02_two_site.jl")

# Beyond full state, use approximations
N = 30
i = [Index(space, "S=1/2") for n in 1:N]

# Product state |Z+Z+Z+…Z+⟩
Zp = MPS(i, "Z+")

# Product state |Z-Z-Z-…Z-⟩
Zm = MPS(i, "Z-")

inner(Zp, Zp)
inner(Zm, Zp)

# Do some arithmatic with them, like tensors:
# TODO: fix this when PR is merged!
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
X_half = op("X", i[N ÷ 2])
apply(X_half, Zp)

# Make the Hamiltonian as a tensor network
function ising_mpo(i; h)
  N = length(i)

  # Abstract symbolic representation
  # of the Hamiltonian ("operator sum")
  H = OpSum()
  for n in 1:(N - 1)
    H -= "X", n, "X", n + 1
    H += h, "Z", n
  end
  H += h, "Z", N

  # Convert to a tensor network
  return MPO(H, i)
end

h = 0.5
H = ising_mpo(i; h=h)

# Performs a truncated MPO*MPS contraction,
# returns an MPS approximate up to some tolerance.
HZp = H * Zp
inner(Zp, HZp) # Does not work!
inner(Zp', H, Zp)

# Gradient energy minimization
# Already written above! New Hamiltonian.
function energy(H, v)
  vHv = inner(v', H, v)
  vv = inner(v, v)
  return vHv / vv
end

function minimize(f, x; nsteps, γ, cutoff, maxdim)
  g(x) = gradient(f, x)[1]
  for n in 1:nsteps
    println("n = ", n, ", f_x = ", f(x))
    x = -(x, γ * g(x); cutoff, maxdim=maxdim)
  end
  return x
end

# Random starting state
v0 = randomMPS(i, "Z+")
f(v) = energy(H, v)
v_min = minimize(f, v0; nsteps=80, γ=0.5, maxdim=10, cutoff=1e-5)

@show maxlinkdim(v_min)

e_dmrg, v_dmrg = dmrg(H, v0; nsweep=10, maxdim=10, cutoff=1e-5)

function layer(i, θ, p, r)
  return [op("U", i[n], i[n + 1]; θ1=θ[p+=1], θ2=θ[p+=1]) for n in r], p
end

# TODO: Finish this implementation
function circuit(i, θ, nlayers)
  ## # Circuit (single gate)
  ## θ1, θ2 = θ
  ## U_θ = op("U", i1, i2; θ1=θ1, θ2=θ2)
  p = 0
  ls = []
  for n in 1:nlayers
    l_odd, p = layer(i, θ, p, 1:2:(length(i) - 1))
    l_even, p = layer(i, θ, p, 2:2:(length(i) - 1))
    ls = [ls; l_odd]
    ls = [ls; l_even]
  end
  return ls
end

# TODO: Finish this implementation
# Example of preparing the ground state
# Find `U(θ)` that minimizes
#
# state_preparation(θ) = -|⟨y|U(θ)|x⟩|²
function state_preparation(θ; maxdim, cutoff)
  U_θ = circuit(i, θ, nlayers)
  Ux = apply(U_θ, x; maxdim, cutoff)
  yUx = inner(y, Ux)
  return -abs(yUx)^2
end

