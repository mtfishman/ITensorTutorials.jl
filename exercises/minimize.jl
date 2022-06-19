subtract(x, y; kwargs...) = -(x, y; kwargs...)
subtract(x::Vector, y::Vector; kwargs...) = [subtract(x[i], y[i]; kwargs...) for i in 1:length(x)]

# Simple gradient descent to minimize the function `f`
# given the gradient `gradf`.
function minimize(f, gradf, x; nsteps, gamma, print_frequency=10, kwargs...)
  for n in 1:nsteps
    x = subtract(x, gamma * gradf(x); kwargs...)
    if n % print_frequency == 0
      println("Step = $(n), f(x) = $(f(x))")
    end
  end
  return x
end
