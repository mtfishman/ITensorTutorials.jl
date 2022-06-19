using ITensors
using ITensorUnicodePlots
using PastaQ
using Zygote

import ITensors: op

function op(
  ::OpName"CRy",
  ::SiteType"S=1/2"; θ)
  c = cos(θ/2)
  s = sin(θ/2)
  return [
  1 0 0 0
  0 1 0 0
  0 0 c -s
  0 0 s c]
end

i1 = Index(2, "S=1/2,i1")
i2 = Index(2, "S=1/2,i2")

Xp1 = state("Xp", i1)
Xm1 = state("Xm", i1)
Xp2 = state("Xp", i2)
Xm2 = state("Xm", i2)
Zp1 = state("Zp", i1)
Zm1 = state("Zm", i1)
Zp2 = state("Zp", i2)
Zm2 = state("Zm", i2)

Id1 = op("Id", i1)
Z1 = op("Z", i1)
X1 = op("X", i1)
Id2 = op("Id", i2)
Z2 = op("Z", i2)
X2 = op("X", i2)

i1 != i2

ZpZm = ITensor(i1, i2)
ZpZm[i1=>1, i2=>2] = 1

Zp1 = state("Zp", i1)
Zp2 = state("Zp", i2)
Zm1 = state("Zm", i1)
Zm2 = state("Zm", i2)

ZpZm = Zp1 * Zm2

ψ = ITensor(i1, i2)
ψ[i1=>1, i2=>2] = 1/√2
ψ[i1=>2, i2=>1] = 1/√2

ψ = (Zp1 * Zm2 + Zm1 * Zp2)/√2

inner(ZpZm, ψ) == 1/√2

_, S, _ = svd(ZpZm, i1);
diag(S) == [1, 0]

_, S, _ = svd(ψ, i1);
diag(S) == [1/√2, 1/√2]

H = ITensor(i1', i2',
i1, i2)
H[i1'=>2, i2'=>1,
i1=>2, i2=>1] = -1
# …

apply(X1, Zp1 * Zm2) ≈ Zm1 * Zm2

@visualize X1 * ZpZm

ZZ = Z1 * Z2
XI = X1 * Id2
IX = Id1 * X2
h = 0.5
H = -ZZ + h * (XI + IX)

inner(Zp1' * Zp2', H, Zp1 * Zp2)

D, _ = eigen(H);
diag(D) ≈ [-√2, -1, 1, √2]

CRy = op("CRy", i1, i2; θ=π/2)

apply(CRy, Zm1 * Zp2) ≈ Zm1 * Xp2

# Optimization
function minimize(f, ∂f, x; nsteps, γ)
  for n in 1:nsteps
    x = x - γ * ∂f(x)
    println("Step = $(n), f(x) = $(f(x))")
  end
  return x
end

# State optimization
function E(ψ)
  ψHψ = inner(ψ', H, ψ)
  ψψ = inner(ψ, ψ)
  return ψHψ / ψψ
end
∂E(ψ) = gradient(E, ψ)[1]

ψ0 = (Zp1 * Zp2 + Zm1 * Zm2)/√2
E(ψ0) == -1
norm(∂E(ψ0)) == 2

ψ = minimize(E, ∂E, ψ0; nsteps=10, γ=0.1)
E(ψ0) == -1
E(ψ) # ≈ -1.4142131 ≈ -√2

# Circuit optimization
U(θ,i1,i2) = [
  op("Ry",i1;θ=θ[1]),
  op("Ry",i2;θ=θ[2]),
  op("CX",i1,i2),
  op("Ry",i1;θ=θ[3]),
  op("Ry",i2;θ=θ[4])]

u(θ) = [
  ("Ry",1,(;θ=θ[1])),
  ("Ry",2,(;θ=θ[2])),
  ("CNOT",1,2),
  ("Ry",1,(;θ=θ[3])),
  ("Ry",2,(;θ=θ[4]))]

U(θ,i1,i2) = buildcircuit([i1,i2],u(θ))

ψ0 = Zp1 * Zp2
function E(θ)
  ψθ = apply(U(θ,i1,i2),ψ0)
  return inner(ψθ',H,ψθ)
end
∂E(ψ) = gradient(E, ψ)[1]

θ0 = [0, 0, 0, 0]
θ = minimize(E, ∂E, θ0; nsteps=40, γ=0.5)
E(θ0) == -1
E(θ) # ≈ -1.4142077 ≈ -√2

# Fidelity optimization
ψ0 = Zp1 * Zp2
ψ = (Zp1 * Zp2 + Zm1 * Zm2) / √2

function F(θ)
  ψθ = apply(U(θ,i1,i2),ψ0)
  return -abs2(inner(ψ,ψθ))
end
∂F(θ) = gradient(F, θ)[1]

θ0 = [0, 0, 0, 0]
θ = minimize(F, ∂F, θ0; nsteps=50, γ=0.1)
F(θ0) == -0.5
F(θ) # ≈ -0.9938992 ≈ -1
