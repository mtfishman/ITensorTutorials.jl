using ITensors
using UnicodePlots

include("ising_model.jl")
include("orthogonalize_eigenvectors.jl")

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

# How close are our eigenvectors to eigenstates?
# We can use the energy variance:
#
# <psi|H^2|psi> - <psi|H|psi>^2
#
# to find out.
#
# Hints:
#
# 1. You can use `inner(psi', H, psi)` to compute `<psi|H|psi>`.
# 2. You can use `apply(H, psi)` to compute `H|psi>`.
for psi in psis
  Hpsi = apply(H, psi)
  @show inner(Hpsi, Hpsi) - inner(psi', H, psi)^2
end

# Which states did we find? The `expect` function
# computes the local expectation value of an operator
# on each site

# Use the UnicodePlots function `lineplot` to plot
# <Sz> and <Sx> for our eigenvectors
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

#
# Orthogonalize the eigenvectors by solving the generalized eigenvector
# equations:
#
# <psi_i|H|psi_j><psi_j|v> = lambda_i * <psi_j|v>
#
# See `orthogonalize_eigenvectors.jl` for details.
#
psis = orthogonalize_eigenvectors(H, psis)

# Replot <Sz> and <Sx> for our eigenvectors
for i in 1:nstates
  plt = lineplot(expect(psis[i], "Sz"); title="Ising model state $i from DMRG after orthogonalization", name="Sz", xlim=[1,10], ylim=[-0.5,0.5])
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
