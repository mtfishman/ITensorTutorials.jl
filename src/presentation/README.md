# ITensor and PastaQ tutorial presentation

This directory has the source code for a presentation about circuit evolution and optimization with [ITensors.jl](https://github.com/ITensor/ITensors.jl/) and [PastaQ.jl](https://github.com/GTorlai/PastaQ.jl/). The PDF of the presentation can be found [here](presentation.pdf).

You can build your won PDF of the presentation by cloning the repository, entering [this](.) directory, and compiling the PDF with:
```
$ lualatex presentation
```

Note that this requires [LuaTeX](http://luatex.org/), since [Julia Mono listings](https://github.com/mossr/julia-mono-listings) requires LuaTeX.

The beamer code is based on [Tufte beamer](https://github.com/ViniciusBRodrigues/simple-tufte-beamer). Julia syntax styling makes use of the [Julia Mono font](https://juliamono.netlify.app/) and [Julia Mono listings](https://github.com/mossr/julia-mono-listings). I've included that code in this repository so the repository is self-contained.
