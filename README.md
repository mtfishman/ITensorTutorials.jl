# ITensorTutorials

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mtfishman.github.io/ITensorTutorials.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mtfishman.github.io/ITensorTutorials.jl/dev)
[![Build Status](https://github.com/mtfishman/ITensorTutorials.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mtfishman/ITensorTutorials.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/mtfishman/ITensorTutorials.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/mtfishman/ITensorTutorials.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

Currently this repository has tutorials for gate evolution and optimization using ITensors.jl and PastaQ.jl.

Tutorials can be found in the [tutorials](tutorials) directory. We recommend compiling the code before running since some of the dependencies like [Zygote.jl](https://github.com/FluxML/Zygote.jl), which is used for automatic differentiation of circuits, and [Makie.jl](https://github.com/JuliaPlots/Makie.jl), which is used for interactive visualization of tensor networks, can have long compilation times. To compile the tutorials, you can run the script in the [tutorials/package_compile](tutorials/package_compile) directory.

A presentation with a higher level summary of ITensor, PastaQ, and a simplified explanation of the code in the tutorials can be found [here](presentation/presentation.pdf), and the source code for the presentation can be found in the [presentation](presentation) directory.

Find out more at [itensor.org](https://itensor.org/), [github.com/GTorial/PastaQ.jl](https://github.com/GTorlai/PastaQ.jl), and [mtfishman.github.io](https://mtfishman.github.io/).
