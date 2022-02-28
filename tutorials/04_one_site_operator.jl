include("03_one_site_state_custom.jl")

println("
#######################################################
# Tutorial 4                                          #
#                                                     #
# 1-site operator                                     #
#######################################################
")

#
# Priming basics
#

# Operator as a linear map:
#
# O: ℂᴺ → ℂᴺ
#
# Consider ℂ² → ℂ²
#
# Decorations and labels of the Hilbert space
# like primes help label the input and output spaces
# to make them unique.
#
# Convenient way to specify a copy
# of an Index that lives in contravariant/
# covariant (bra and ket) spaces.
@show prime(i) ≠ i
# `i'` is just compact notation for `prime(i)`
@show prime(i) == i'
@show i' ≠ i

#
# Making operators
#

Z = ITensor(i', dag(i))
Z[i' => 1, i => 1] = 1
Z[i' => 2, i => 2] = -1

Z = ITensor([1 0; 0 -1], i', dag(i))

X = ITensor([0 1; 1 0], i', dag(i))

# Predefined operators:
Z = op("Z", i)

X = op("X", i)

# Apply the operator as a map
XZp = X * Zp

@visualize X * Zp

# Apply the operator as a map
# of the input vector.
XZp = X * Zp


# Take an inner product?
# dag(Zm) * XZp
# No, outer product!

@show XZp ≠ Zm
@show XZp == Zm'

# Take an inner product:
# Need to prime with:
@show (dag(Zm)' * XZp)[]
@show inner(Zm', XZp)
@show inner(Zp', XZp)

# Take an inner product
# We can also use `noprime`:
@show (dag(Zm) * noprime(XZp))[]
@show inner(Zm, noprime(XZp))
@show inner(Zp, noprime(XZp))

# `apply` is shorthand for applying the operator
# and mapping it back to the original space:
XZp = apply(X, Zp)

# Same as `noprime(X * Zp)`:
@show XZp == noprime(X * Zp)

@show inner(Zm, apply(X, Zp))

# Compute expectation values/matrix elements
@show (dag(Zm)' * X * Zp)[]
@show inner(Zm', X, Zp)

@visualize dag(Zm)' * X * Zp

@visualize dag(Zm)' * X * Zp backend="Makie"

@show inner(Zp', X, Zm)

@visualize dag(Zp)' * X * Zm

# More matrix elements
@show inner(Xp', X, Xp)
@show inner(Xm', X, Xm)
