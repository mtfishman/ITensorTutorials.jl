include("01_one_site_state_basics.jl")

println("
#######################################################
# Tutorial 2                                          #
#                                                     #
# 1-site states                                       #
#######################################################
")

# "S=1/2" defines a state and operator basis:
# a set of predefined states and operators.
# Additionally: "Qubit", "Qudit", "Fermion", "Electron", etc.
i = Index(space, "S=1/2")

# Same as before
Zp = ITensor([1 0], i)

# Predefined (extensible) state definitions
Zp = state("Z+", i)

# Make a "down" state (-1 eigenvalue of `Z`),
# denoted as `|Z-⟩`.
Zm = ITensor([0 1], i)

# Predefined definition
Zm = state("Z-", i)

@visualize Zm

# Some more complicated states:
# |X+⟩ = (|Z+⟩ + |Z-⟩) / √2

# Define through setting elements
Xp = ITensor(i)
Xp[i => 1] = 1 / √2
Xp[i => 2] = 1 / √2

# Define in terms of |Z+⟩, |Z-⟩
Xp = (Zp + Zm) / √2

# Use predefined definition
Xp = state("X+", i)

# |X-⟩ = (|Z+⟩ - |Z-⟩) / √2
Xm = (Zp - Zm) / √2

# Or:
Xm = state("X-", i)

# Perform some inner products:
@show dag(Zp) * Zp

# Convert from order-0 tensor to Number:
@show (dag(Zp) * Zp)[]

# Shorthand:
#
# inner(x, y) = (dag(x) * y)[]
#
# norm(x) = √(inner(x, x))
@show inner(Zp, Zp)
@show norm(Zp)
@show inner(Zp, Zp)
@show inner(Zp, Xm)
@show inner(Zm, Xm)

@visualize dag(Zp) * Xm
