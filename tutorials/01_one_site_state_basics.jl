# TODO: remove once changes are merged
include(joinpath("src", "patches.jl"))

using ITensors

# Text visualization, prints to screen
using ITensorUnicodePlots

# Visualization in an interactive window
using ITensorGLMakie

ITensorVisualizationBase.set_backend!("UnicodePlots")

println("
#######################################################
# Tutorial 1                                          #
#                                                     #
# 1-site state basics                                 #
#######################################################
")

#space = [QN("P", 1, 2) => 1, QN("P", 0, 2) => 1]
space = 2

i = Index(space)

#
# Making states
#

# Make an "up" state (+1 eigenvalue of `Z`),
# denoted as `|Z+⟩`.

# Define through setting elements
Zp = ITensor(i)
Zp[i => 1] = 1.0

# Alternative syntax, construct from a Vector
Zp = ITensor([1 0], i)

# Make an "down" state (-1 eigenvalue of `Z`),
# denoted as `|Z-⟩`.

# Define through setting elements
Zm = ITensor(i)
Zm[i => 2] = 1.0

# Alternative syntax, construct from a Vector
Zm = ITensor([0 1], i)

@visualize Zm

# Can do algebra, inner products, etc:
@show (Zp + Zm) / √2
@show dag(Zp) * Zm
