using ITensors
using ITensorUnicodePlots
using PastaQ
using Zygote

function ising(n; h)
  H = OpSum()
  for j in 1:(n - 1)
    H -= "Z", j, "Z", j + 1
  end
  for j in 1:n
    H += h, "X", j
  end
  return H
end

n = 30
i = [Index(2, "S=1/2") for j in 1:n];

Zp = MPS(i, "Zp");
Zm = MPS(i, "Zm");

maxlinkdim(Zp) == 1 # product state

ψ = (Zp + Zm)/√2;
maxlinkdim(ψ) == 2 # entangled state

inner(Zp, Zp) ≈ 1
inner(Zp, ψ) ≈ 1/√2

j = n ÷ 2
Xj = op("X", i[j])
XjZp = apply(Xj, Zp);
st = [k == j ? "Zm" : "Zp" for k in 1:n];
XjZp = MPS(i, st);

maxlinkdim(XjZp) == 1
inner(Zp, XjZp) == 0

h = 0.5 # field
H = MPO(ising(n; h), i);
maxlinkdim(H) == 3

Zp = MPS(i, "Zp");
inner(Zp', H, Zp) ≈ -(n-1)

# Optimize
# kwargs allow for approximate arithmatic
function minimize(f, ∂f, x; nsteps, γ, kwargs...)
  for n in 1:nsteps
  x = -(x, γ * ∂f(x); kwargs...)
  println("Step = $(n), f(x) = $(f(x))")
  end
  return x
end

# Optimize energy
function E(ψ)
  ψHψ = inner(ψ', H, ψ)
  ψψ = inner(ψ, ψ)
  return ψHψ / ψψ
end
∂E(ψ) = gradient(E, ψ)[1]

ψ0 = MPS(i, "Zp");
ψ = minimize(E, ∂E, ψ0; nsteps=50, γ=0.1, cutoff=1e-5);
ψ /= norm(ψ);

Edmrg, ψdmrg = dmrg(H, ψ0; nsweeps=10, cutoff=1e-5);

inner(ψ, ψdmrg)

maxlinkdim(ψ0) == 1
maxlinkdim(ψ) == 3
maxlinkdim(ψdmrg) == 3
E(ψ0) # ≈ -29
E(ψ) # ≈ -31.0317917
E(ψdmrg) # ≈ -31.0356110

Ry_layer(θ, i) = [op("Ry", i[j]; θ=θ[j]) for j in 1:n]
CX_layer(i) = [op("CX", i[j], i[j+1]) for j in 1:2:(n-1)]

function U(θ, i; nlayers)
  n = length(i)
  Uθ = ITensor[]
  for l in 1:(nlayers-1)
    θl = θ[(1:n) .+ l*n]
    Uθ = [Uθ; Ry_layer(θl, i)]
    Uθ = [Uθ; CX_layer(i)]
  end
  return Uθ
end

# Optimize energy
ψ0 = MPS(i, "Zp");
nlayers = 6
function E(θ)
  ψθ = apply(U(θ, i; nlayers),ψ0)
  return inner(ψθ',H,ψθ)
end
∂E(θ) = gradient(E, θ)[1]

θ0 = zeros(nlayers * n);
θ = minimize(E, ∂E, θ0; nsteps=20, γ=0.1);

ψθ = apply(U(θ, i; nlayers), ψ0);
maxlinkdim(ψ0) == 1
maxlinkdim(ψθ) == 3
E(θ0) # ≈ -29
E(θ) # ≈ -31.017062

# Optimize fidelity
ψ0 = MPS(i, "Zp");
nlayers = 6
function F(θ)
  ψθ = apply(U(θ, i; nlayers),ψ0)
  return -abs2(inner(ψ,ψθ))
end
∂F(θ) = gradient(F, θ)[1]

θ0 = zeros(nlayers * n);
θ = minimize(F, ∂F, θ0; nsteps=20, γ=0.1);

maxlinkdim(ψ0) == 1
maxlinkdim(ψθ) == 2
F(θ0) # ≈ -0.556066
F(θ) # ≈ -0.989336
