using ITensors
using ITensorGLMakie

include(joinpath("..", "src", "visualize_dangling.jl"))

i = Index(2, "i")
j = Index(2, "j")
k = Index(2, "k")

V = ITensor(i)
M = ITensor(i, j)
T = ITensor(i, j, k)

fig_V = visualize_dangling(V; vertex_labels="V")
fig_M = visualize_dangling(M; vertex_labels="M")
fig_T = visualize_dangling(T; vertex_labels="T")

fig_MV = visualize_dangling([M, V]; vertex_labels=["M", "V"])
fig_MM = visualize_dangling([M, M]; vertex_labels=["M", "M"])
fig_TV = visualize_dangling([T, V]; vertex_labels=["T", "V"])
fig_TM = visualize_dangling([T, M]; vertex_labels=["T", "M"])

# using Makie
# save("figure.png", fig)
