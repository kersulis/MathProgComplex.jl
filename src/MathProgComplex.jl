module MathProgComplex

using DataStructures

import Base: ==, !=, <<, >>, isless, isconst, isreal, isnull, isequal
import Base: +, -, *, /, ^, conj, conj!, abs2, norm, real, imag
import Base: show, print, convert, copy, hash, merge
import Base: start, next, done, length, setindex!, getindex, haskey, keys, values, deepcopy


abstract type  AbstractPolynomial end


include("variable.jl")
include("exponent.jl")
include("polynomial.jl")

include("constraint.jl")
include("problem.jl")
include("point.jl")

include("cplx2real.jl")
include("evaluate.jl")
include("iterators.jl")
include("utils_internal.jl")
include("utils_Poly.jl")
include("problem_accessors.jl")

## algebra
include(joinpath("algebra", "add_algebra.jl"))
include(joinpath("algebra", "mult_algebra.jl"))
include(joinpath("algebra", "order.jl"))
include(joinpath("algebra", "unaries.jl"))

## export dat
## export JuMP

# include("utils_dat_compare.jl")
# include("utils_dat_export.jl")
# include("utils_dat_import.jl")

# include("utils_jump.jl")

# include("utils_Poly.jl")

end
