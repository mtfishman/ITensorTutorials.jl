using PackageCompiler

tutorials_file = joinpath("..", "12_n_site.jl")
PackageCompiler.create_sysimage(
  ["ITensors", "ITensorUnicodePlots", "ITensorGLMakie"];
  sysimage_path="ITensorTutorials.so",
  precompile_execution_file=tutorials_file,
)
