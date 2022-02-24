include("05_one_site_operator_custom.jl")

println("
#######################################################
# Tutorial 6                                          #
#                                                     #
# 2-site state                                        #
#######################################################
")

i1 = Index(2, "S=1/2")
i2 = Index(2, "S=1/2")

@show i1 ≠ i2

# Uninitialized ITensor
ZpZm = ITensor(i1, i2)

# State |Z+⟩₁|Z-⟩₂ ≡ |Z+Z-⟩
ZpZm[i1 => 1, i2 => 2] = 1

# Order doesn't matter!
ZpZm[i2 => 2, i1 => 1] = 1

# Or construct from single site basis states:
# State |Z+⟩₁
Zp1 = state("Z+", i1)
# State |Z+⟩₂
Zp2 = state("Z+", i2)

# State |Z-⟩₁
Zm1 = state("Z-", i1)
# State |Z-⟩₂
Zm2 = state("Z-", i2)

# State |Z+Z-⟩ = |Z+⟩₁|Z-⟩₂
ZpZm = Zp1 * Zm2

# State |Z+Z-⟩ = |Z-⟩₂|Z+⟩₁ = |Z+⟩₁|Z-⟩₂
# Order doesn't matter!
ZpZm = Zm2 * Zp1

# State |Z-Z+⟩
ZmZp = Zm1 * Zp2

# State |Z+Z+⟩
ZpZp = Zp1 * Zp2

Xp1 = state("X+", i1)
Xp2 = state("X+", i2)

Xm1 = state("X-", i1)
Xm2 = state("X-", i2)

# State |Z-⟩|Z-⟩
ZmZm = Zm1 * Zm2

# Cat state (|Z+⟩|Z-⟩ + |Z-⟩|Z+⟩) / √2

# With element setting:
Cat = ITensor(i1, i2)
Cat[i1 => 1, i2 => 2] = 1 / √2
Cat[i1 => 2, i2 => 1] = 1 / √2

# Or build from single site basis states:
Cat = (Zp1 * Zm2 + Zm1 * Zp2) / √(2)
@show (dag(Cat) * Cat)[]
@show inner(Cat, Cat)
@show norm(Cat)

entanglement_entropy(s) = sum(sn -> iszero(sn) ? zero(sn) : -sn^2 * log(sn^2), s)

# Compact syntax for matrix decompositions like SVD,
# which reveal the rank/entanglement:
_, S, _ = svd(ZmZp, i1)
s = diag(S)
@show s
@show entanglement_entropy(s)

_, S, _ = svd(Cat, i1)
s = diag(S)
@show s
@show entanglement_entropy(s)
