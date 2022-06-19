using ITensors
using ITensorVisualizationBase: visualize

_fill_or_identity(v::Vector, n) = v
_fill_or_identity(v, n) = fill(v, n)

function n_edges(A::Vector{ITensor})
  n_edges = 0
  for i in 1:length(A)
    for j in (i + 1):length(A)
      if hascommoninds(A[i], A[j])
        n_edges += 1
      end
    end
  end
  return n_edges
end

function _visualize_kwargs(A::Vector{ITensor};
  vertex_labels="",
  tags=true,
  plevs=true,
  textsize=60,
  vertex_size=100,
  edge_widths=10,
)
  # Number of tensors
  nt = length(A)

  # Number of dangling
  nd = length(noncommoninds(A...))

  # Number of internal edges
  ne_t = n_edges(A)

  # Number of total vertices, including the
  # tensors and dangling
  nv = nt + nd

  # Number of total edges, including between
  # tensors and dangling
  ne = ne_t + nd

  vertex_labels = _fill_or_identity(vertex_labels, nt)
  vertex_textsize = _fill_or_identity(textsize, nt)
  vertex_size = _fill_or_identity(vertex_size, nt)
  edge_textsize = _fill_or_identity(textsize, ne)
  edge_widths = _fill_or_identity(edge_widths, ne)
  return (;
    vertex_labels=[n in 1:nt ? vertex_labels[n] : "" for n in 1:nv],
    vertex_textsize=[n in 1:nt ? vertex_textsize[n] : 0 for n in 1:nv],
    vertex_size=[n in 1:nt ? vertex_size[n] : 5 for n in 1:nv],
    edge_labels=(; plevs=plevs, dims=false, tags=tags),
    edge_textsize=edge_textsize,
    edge_widths=edge_widths,
  )
end

function visualize_dangling(A::Vector{ITensor}; kwargs...)
  is = noncommoninds(A...)
  vs = [ITensor(i) for i in is]
  Av = [A; vs]
  visualize_kwargs = _visualize_kwargs(A; kwargs...)
  return visualize(Av; visualize_kwargs...)
end

visualize_dangling(A::ITensor; kwargs...) = visualize_dangling([A]; kwargs...)
