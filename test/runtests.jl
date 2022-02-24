using ITensorTutorials
using Suppressor
using Test

@testset "ITensorTutorials.jl" begin

  @testset "Run tutorials" begin
    tutorials_dir = joinpath(pkgdir(ITensorTutorials), "tutorials")

    is_tutorial(file) = endswith(file, ".jl")

    for file in readdir(tutorials_dir; join=true)
      if is_tutorial(file)
        @suppress include(file)
      end
    end

  end

end
