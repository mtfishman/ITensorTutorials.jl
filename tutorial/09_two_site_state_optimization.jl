include("08_two_site_operator_custom.jl")

println("
#######################################################
# Tutorial 9                                          #
#                                                     #
# 2-site energy minimization via gradient             #
# optimization                                        #
#######################################################
")

# Used for computing gradients "automatically".
# Julia's source-to-source reverse mode AD library.
using Zygote

# Energy function to minimize with gradient descent.
function energy(H, v)
  vHv = inner(v', H, v)

  # Alternative:
  # Hv = apply(H, v)
  # vHv = inner(v, Hv)

  vv = inner(v, v)
  return vHv / vv
end

# Extremely simple gradient descent.
# Better to use a library like `OptimKit.jl` in general.
function minimize(f, x; nsteps, γ)
  # Compute the gradient at the current point
  # with AD using Zygote.jl
  g(x) = gradient(f, x)[1]

  for n in 1:nsteps
    println("n = ", n, ", f_x = ", f(x))

    # Gradient descent step with step size `γ`
    x = x - γ * g(x)
  end
  return x
end

# Use the cat state as a starting state
v0 = (Zp1 * Zm2 + Zm1 * Zp2) / √2

# Function to minimize, only a function of the state
# (depends implicitly on the Hamiltonian).
f(v) = energy(H, v)

# Minimize the energy!
v_min = minimize(f, v0; nsteps=10, γ=0.1)

## # Circuit optimization
## # Bonus: this is a Matchgate, we could do this
## # with free fermions (correlation matrix formalism)
## function op(::OpName"U", ::SiteType"S=1/2"; θ1, θ2)
##   c1 = cos(θ1)
##   s1 = sin(θ1)
##   c2 = cos(θ2)
##   s2 = sin(θ2)
##   return [
##     c1  0   0 -s1
##     0  c2 -s2   0
##     0  s2  c2   0
##     s1  0   0  c1
##   ]
## end
## 
## # Starting state `|0⟩ = |Z+Z+⟩`
## v0 = ZpZp
## 
## # Find `U(θ)` that minimizes
## #
## # energy_circuit(θ) = ⟨0|U(θ)† H U(θ)|0⟩
## function energy_circuit(θ)
##   # Circuit (single gate)
##   θ1, θ2 = θ
##   U_θ = op("U", i1, i2; θ1=θ1, θ2=θ2)
## 
##   Uv0 = U_θ * v0
## 
##   # Map back to the labels of the original
##   # Hilbert space.
##   Uv0 = replaceprime(Uv0, 1 => 0)
## 
##   vHv = dag(Uv0)' * H * Uv0
##   return vHv[]
## end
## 
## println("Circuit optimization")
## θ1, θ2 = randn(), randn()
## θ_min = minimize(energy_circuit, [θ1, θ2]; nsteps=10, γ=0.1)
## 
## @show θ_min
## 
## θ_min_energy = θ_min
## 
## #
## # State preparation
## #
## 
## # Starting state `|x⟩ = |Z+Z+⟩`
## x = ZpZp
## 
## # Target state `|y⟩ = (|Z+Z+⟩ + |Z-Z-⟩) / √2`
## y = (ZpZp + ZmZm) / √2
## 
## # Find `U(θ)` that minimizes
## #
## # state_preparation(θ) = -|⟨y|U(θ)|x⟩|²
## function state_preparation(θ)
##   # Circuit (single gate)
##   θ1, θ2 = θ
##   U_θ = op("U", i1, i2; θ1=θ1, θ2=θ2)
## 
##   #yUx = (dag(y)' * U_θ * x)[]
##   yUx = inner(y', U_θ, x)
##   return -abs(yUx)^2
## end
## 
## println("Circuit optimization")
## θ1, θ2 = 0, 0
## θ_min = minimize(state_preparation, [θ1, θ2]; nsteps=20, γ=0.1)
## 
## @show θ_min, [π/4, 0]
