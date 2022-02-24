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
# Depends implicitly on the Hamiltonian.
function E(ψ)
  ψHψ = inner(ψ', H, ψ)

  # Alternative:
  # Hψ = apply(H, ψ)
  # ψHψ = inner(ψ, Hψ)

  ψψ = inner(ψ, ψ)
  return ψHψ / ψψ
end

# Extremely simple gradient descent.
# Better to use a library like `OptimKit.jl` in general.
function minimize(f, ∂f, x; nsteps, γ)
  for n in 1:nsteps
    println("n = ", n, ", f_x = ", f(x))

    # Gradient descent step with step size `γ`
    x = x - γ * ∂f(x)
  end
  return x
end

# Use the cat state as a starting state
ψ₀ = (Zp1 * Zp2 + Zm1 * Zm2) / √2

# Minimize the energy!
∂E(ψ) = gradient(E, ψ)[1]
ψ = minimize(E, ∂E, ψ₀; nsteps=10, γ=0.1)

@show E(ψ₀), norm(∂E(ψ₀))
@show E(ψ), norm(∂E(ψ))
