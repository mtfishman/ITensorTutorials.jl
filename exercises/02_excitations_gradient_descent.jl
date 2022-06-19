using ITensors
using Zygote

include("ising_model.jl")
include("minimize.jl")

# Take a set of MPS eigenvectors {|psi_i>} and solve
# the generalized eigenvector equation:
#
# <psi_i|H|psi_j><psi_j|v> = lambda_i * <psi_j|v>
#
function orthogonalize_eigenvectors(H::MPO, psis::Vector{MPS})
  psis = normalize.(psis)
  Heff = [inner(psi_i', H, psi_j) for psi_i in psis, psi_j in psis]
  N = [inner(psi_i, psi_j) for psi_i in psis, psi_j in psis]
  D, V = eigen(Heff, N)
  phis = transpose(V) * psis
  return normalize.(phis)
end

# Define the sites of the Hilbert space
n = 10
i = [Index(2, "S=1/2") for j in 1:n];

# Define the Hamiltonian
h = 0.5 # field
H = MPO(ising(n; h), i);

#
# An example of a cost function for minimizing the energy
#
function E(psi::MPS)
  psiHpsi = inner(psi', H, psi)
  psipsi = inner(psi, psi)
  return psiHpsi / psipsi
end
gradE(psi) = gradient(E, psi)[1]

# Compute the ground state with gradient descent
psi_init = MPS(i, "Zp");
psi0 = minimize(E, gradE, psi_init; nsteps=50, gamma=0.1, cutoff=1e-5, maxdim=10);
psi0 /= norm(psi0);

@show E(psi_init), E(psi0)

w = 2.0 # Weight
function cost_function(psis::Vector{MPS})
  nstates = length(psis)
  N = [inner(psis[i], psis[j]) for i in 1:nstates, j in 1:nstates]

  energy = 0.0
  for i in 1:nstates
    energy += inner(psis[i]', H, psis[i]) / N[i, i]
  end

  off_diagonal_overlap = 0.0
  for i in 1:(nstates - 1), j in (i + 1):nstates
    if i != j
      off_diagonal_overlap += abs2(N[i, j]) / (N[i, i] * N[j, j])
    end
  end
  return energy + w * off_diagonal_overlap
end
grad_cost_function(psi) = gradient(cost_function, psi)[1]

nstates = 3
psis_init = [randomMPS(i; linkdims=2) for _ in 1:nstates]
psis = minimize(cost_function, grad_cost_function, psis_init; nsteps=50, gamma=0.1, cutoff=1e-5, maxdim=10);
psis ./= norm(psis);

@show E.(psis)

# Construct an effective Hamiltonian `Heff` for the states we found
Heff = [inner(psis[i]', H, psis[j]) for i in 1:nstates, j in 1:nstates]

# Construct the overlap matrix `N` for the states we found
N = [inner(psis[i], psis[j]) for i in 1:nstates, j in 1:nstates]

println("\nHeff = <psi_i|H|psi_j> from DMRG")
display(Heff)

println("\nN = <psi_i|psi_j> from DMRG")
display(N)

# Solve the generilized eigenvector equation
# Heff * V[:, i] = D[i] * N * V[:, i]
D, V = eigen(Heff, N)

println("\nEigenvalues of the reduced Hamiltonian")
display(D)

# Orthogonalized MPS in the new basis
psis = transpose(V) * psis
psis = normalize.(psis)

for i in 1:nstates
  plt = lineplot(expect(psis[i], "Sz"); title="Ising model state $i from gradient descient after orthogonalization", name="Sz", xlim=[1,10], ylim=[-0.5,0.5])
  lineplot!(plt, expect(psis[i], "Sx"); name="Sx")
  display(plt)
end
