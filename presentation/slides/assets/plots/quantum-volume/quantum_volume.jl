using GLMakie

x_max = 4
δ = 0.02
x = inv(x_max):δ:x_max
y = inv.(x)
axis = (;
  xlabel="Number of qubits",
  xlabelsize=50,
  ylabel="Circuit depth/time",
  ylabelsize=50,
  xticks=[0],
  yticks=[0],
)

f = lines(x, y;
  axis=axis,
  linewidth=10,
)

xlims!(f.axis, 0, x_max)
ylims!(f.axis, 0, x_max)

textsize = 50

text!(f.axis, "Classical"; position=Point2f(0.3, 0.3), textsize=textsize)
text!(f.axis, "Quantum"; position=Point2f(0.5x_max, 0.5x_max), textsize=textsize)
text!(f.axis, "Full state"; position=Point2f(0.3, 0.5x_max), rotation=π/2, textsize=textsize)
text!(f.axis, "Tensor networks"; position=Point2f(0.5x_max, 0.01), textsize=textsize)

arrows!(f.axis, [0.5x_max], [0.3], [0.0], [0.5]; linewidth=15, arrowsize=50)
text!(f.axis, "Noise"; position=Point2f(0.53x_max, 0.5), textsize=textsize, align=(:left, :bottom))

display(f)

#save("test.png", f)
