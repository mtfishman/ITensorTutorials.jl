using ITensors

# TODO: Add this to ITensors.jl.
# This helps with matrix multiplications.
Base.zero(psi::MPS) = 0 * psi

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
