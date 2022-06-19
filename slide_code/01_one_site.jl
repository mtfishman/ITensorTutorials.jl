using ITensors
using ITensorUnicodePlots

import ITensors: state, op

function state(
  ::StateName"iXm",
  ::SiteType"S=1/2")
  return [im,-im]/√2
end

function op(
  ::OpName"iX",
  ::SiteType"S=1/2")
  return [0 im; im 0]
end

# Index with site type
i = Index(2, "S=1/2")

Zp = state("Zp", i)
Zm = state("Zm", i)
Xp = state("Xp", i)
Xm = state("Xm", i)

Z = op("Z", i)
X = op("X", i)

@visualize dag(Zp) * Xp

iXm = state("iXm", i)
inner(Zm, iXm)

Z = ITensor(i', i)
Z[i'=>1, i=>1] = 1
Z[i'=>2, i=>2] = -1

z = [1 0; 0 -1]
Z = ITensor(z, i', i)
Z = op("Z", i)

Zp = state("Zp", i)
Zm = state("Zm", i)

X * Zp == Zm'
noprime(X * Zp) == Zm

(dag(Zm)' * X * Zp)[]
inner(Zm', X, Zp)

apply(X, Zp) == noprime(X * Zp)
inner(Zm, apply(X, Zp))

op("iX", i)
X * im
