include("02_one_site_state_predefined.jl")

println("
#######################################################
# Tutorial 3                                          #
#                                                     #
# 1-site custom state definitions                     #
#######################################################
")

# Customizable:
import ITensors: state

function state(::StateName"iX-", ::SiteType"S=1/2", i::Index)
  iXm = ITensor(i)
  iXm[i => 1] = im / √2
  iXm[i => 2] = -im / √2
  return iXm
end

function state(::StateName"iX-", ::SiteType"S=1/2")
  return [im -im] / √2
end

iXm = state("iX-", i)

@show inner(Zp, iXm)
@show inner(Zm, iXm)
