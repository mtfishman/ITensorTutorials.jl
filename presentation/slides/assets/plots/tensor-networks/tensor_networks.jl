using ITensors
using ITensorGLMakie

using ITensorVisualizationBase: visualize

_string(ts::TagSet) = chop(string(ts); head=1, tail=1)

function ITensorVisualizationBase.label_string(i::Index; tags, kwargs...)
  str = ""
  if tags
    str *= _string(ITensors.tags(i))
  end
  return str
end

function _visualize_kwargs(A::ITensor;
  vertex_labels="",
  ne=order(A),
  tags=false,
  textsize=60,
  vertex_size=100,
  edge_widths=10,
)
  nv = ne + 1
  return (;
    vertex_labels = [isone(n) ? vertex_labels : "" for n in 1:nv],
    vertex_textsize = [isone(n) ? textsize : 0 for n in 1:nv],
    vertex_size = [isone(n) ? vertex_size : 5 for n in 1:nv],
    edge_labels = (; plevs=false, dims=false, tags=tags),
    edge_textsize = fill(textsize, ne),
    edge_widths = fill(edge_widths, ne),
  )
end

function _visualize_dangling(A::ITensor; kwargs...)
  is = inds(A)
  vs = [ITensor(i) for i in is]
  Av = [[A]; vs]
  visualize_kwargs = _visualize_kwargs(A; kwargs...)
  return visualize(Av; visualize_kwargs...)
end

i = Index(2, "i")
j = Index(2, "j")
k = Index(2, "k")

V = ITensor(i)
M = ITensor(i, j)
T = ITensor(i, j, k)

fig_V = _visualize_dangling(V; vertex_labels="V", tags=true)
fig_M = _visualize_dangling(M; vertex_labels="M", tags=true)
fig_T = _visualize_dangling(T; vertex_labels="T", tags=true)

# using Makie
# save("figure.png", fig)
