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
i = [Index(space, "S=1/2") for j in 1:n]

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
function energy(H, ψ)
  ψHψ = inner(ψ', H, ψ)
  ψψ = inner(ψ, ψ)
  return ψHψ / ψψ
end

function minimize(f, x; nsteps, γ, cutoff, maxdim)
  g(x) = gradient(f, x)[1]
  for n in 1:nsteps
    println("n = ", n, ", f_x = ", f(x))
    x = -(x, γ * g(x); cutoff, maxdim=maxdim)
  end
  return x
end

ψ0 = MPS(i, "Z+")
f(ψ) = energy(H, ψ)
ψ_min = minimize(f, ψ0; nsteps=50, γ=0.1, maxdim=20, cutoff=1e-5)

@show maxlinkdim(ψ_min)

e_dmrg, ψ_dmrg = dmrg(H, ψ0; nsweep=10, maxdim=10, cutoff=1e-5)

## function layer(i, θ, p, r)
##   return [op("U", i[n], i[n + 1]; θ1=θ[p+=1], θ2=θ[p+=1]) for n in r], p
## end
## 
## # TODO: Finish this implementation
## function circuit(i, θ, nlayers)
##   ## # Circuit (single gate)
##   ## θ1, θ2 = θ
##   ## U_θ = op("U", i1, i2; θ1=θ1, θ2=θ2)
##   p = 0
##   ls = []
##   for n in 1:nlayers
##     l_odd, p = layer(i, θ, p, 1:2:(length(i) - 1))
##     l_even, p = layer(i, θ, p, 2:2:(length(i) - 1))
##     ls = [ls; l_odd]
##     ls = [ls; l_even]
##   end
##   return ls
## end
## 
## # TODO: Finish this implementation
## # Example of preparing the ground state
## # Find `U(θ)` that minimizes
## #
## # state_preparation(θ) = -|⟨y|U(θ)|x⟩|²
## function state_preparation(θ; maxdim, cutoff)
##   U_θ = circuit(i, θ, nlayers)
##   Ux = apply(U_θ, x; maxdim, cutoff)
##   yUx = inner(y, Ux)
##   return -abs(yUx)^2
## end

