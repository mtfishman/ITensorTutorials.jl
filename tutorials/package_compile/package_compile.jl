using PackageCompiler

tutorials_file = joinpath("..", "12_n_site.jl")
PackageCompiler.create_sysimage(
  ["ITensors", "ITensorUnicodePlots", "ITensorGLMakie", "Zygote"];
  sysimage_path="ITensor.so",
  precompile_execution_file=tutorials_file,
)

# Then make an alias like:
#
# alias julia-itensor='julia -J/home/mfishman/.julia/dev/ITensorTutorials/tutorials/package_compile/ITensor.so'
#
# and run `julia-itensor`.
