include("06_two_site_state.jl")

println("
#######################################################
# Tutorial 7                                          #
#                                                     #
# 2-site operators                                    #
#######################################################
")

#
# Make a Hamiltonian (transverse field Ising)
#

H = ITensor(i1', i2', dag(i1), dag(i2))
# Could set individual elements...
H[2, 1, 2, 1] = -1.0
# etc.

# Easier to build from single-site operator basis
Id1 = op("Id", i1)
Id2 = op("Id", i2)
X1 = op("X", i1)
X2 = op("X", i2)
Z1 = op("Z", i1)
Z2 = op("Z", i2)

XX = X1 * X2
ZI = Z1 * Id2
IZ = Id1 * Z2

h = 1.0
H = -XX + h * (ZI + IZ)

# Compute some expectation values/matrix elements:
# |0⟩ = |Z+Z+⟩
ZpZp = Zp1 * Zp2

# ⟨H⟩ = ⟨0|H|0⟩ = ⟨Z+Z+|H|Z+Z+⟩
@show (dag(ZpZp)' * H * ZpZp)[]
@show inner(ZpZp', H, ZpZp)
@show inner(ZpZp, apply(H, ZpZp))

# Diagonalize
D, U = eigen(H; ishermitian=true)
@show diag(D)
