using ITensors
using ITensorGLMakie

include(joinpath("..", "src", "visualize_dangling.jl"))

i = Index(2, "i")

Zp = ITensor(i)
Zm = ITensor(i)
Xp = ITensor(i)
Xm = ITensor(i)

fig_Zp = visualize_dangling(Zp; vertex_labels="Z+", tags=true)
fig_Zm = visualize_dangling(Zm; vertex_labels="Z-", tags=true)
fig_Xp = visualize_dangling(Xp; vertex_labels="X+", tags=true)
fig_Xm = visualize_dangling(Xm; vertex_labels="X-", tags=true)

fig_ZpXp = visualize_dangling([Zp, Xp]; vertex_labels=["Z+", "X+"], tags=true)

Z = ITensor(i', i)
fig_ZXp = visualize_dangling([Z, Xp]; vertex_labels=["Z+", "X+"], tags=true)


# using Makie
# save("figure.png", fig)
