using ITensors

# Text visualization, prints to screen
using ITensorUnicodePlots

# Visualization in an interactive window
using ITensorGLMakie

using LinearAlgebra

ITensorVisualizationBase.set_backend!("UnicodePlots")

println("
#######################################################
# Tutorial 1                                          #
#                                                     #
# 1-site state basics                                 #
#######################################################
")

i = Index(2)

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
