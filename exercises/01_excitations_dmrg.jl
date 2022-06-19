using ITensors
using UnicodePlots

include("ising_model.jl")

#
# Compute excitations of the Ising model with DMRG
#

# Define the sites of the Hilbert space
n = 10
i = [Index(2, "S=1/2") for j in 1:n];

# Define the Hamiltonian as an MPO
h = 0.5 # field
H = MPO(ising(n; h), i);

# Define the initial state
psi_init = randomMPS(i; linkdims=2)

# Use DMRG as a reference
println("\nComputing ground state with DMRG")
E0, psi0 = dmrg(H, psi_init; weight=4, nsweeps=10, cutoff=1e-5);

println("\nComputing first excited state with DMRG")
E1, psi1 = dmrg(H, [psi0], psi_init; weight=4, nsweeps=10, cutoff=1e-5, maxdim=10);

println("\nComputing second excited state with DMRG")
E2, psi2 = dmrg(H, [psi0, psi1], psi_init; weight=4, nsweeps=10, cutoff=1e-5, maxdim=10);

# Collect the ground state and excited states in a vector
psis = [psi0, psi1, psi2]
nstates = length(psis)

# Which states did we find? The `expect` function
# computes the local expectation value of an operator
# on each site
for i in 1:nstates
  plt = lineplot(expect(psis[i], "Sz"); title="Ising model state $i from DMRG", name="Sz", xlim=[1,10], ylim=[-0.5,0.5])
  lineplot!(plt, expect(psis[i], "Sx"); name="Sx")
  display(plt)
end

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
phis = transpose(V) * psis
normalize!.(phis)

for i in 1:nstates
  plt = lineplot(expect(phis[i], "Sz"); title="Ising model state $i from DMRG after orthogonalization", name="Sz", xlim=[1,10], ylim=[-0.5,0.5])
  lineplot!(plt, expect(phis[i], "Sx"); name="Sx")
  display(plt)
end

