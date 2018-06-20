export product!, product, *, divide, /


"""
    product!(expod, expod1)

    Add the `expod1` degree to `expod` inplace (equivalent to the monomial product)
"""
function product!(expod::Exponent, expod1::Exponent)
    for (var, deg) in expod1
        if !haskey(expod, var)
            expod.expo[var] = Degree(0,0)
        end
        expod.expo[var].explvar += deg.explvar
        expod.expo[var].conjvar += deg.conjvar
        if (expod.expo[var].explvar, expod.expo[var].conjvar) == (0,0)
            delete!(expod, var)
        end
    end
    update_degree!(expod)
    return expod
end

function product(exp1::Exponent, exp2::Exponent)
    expod = Exponent()
    product!(expod, exp1)
    product!(expod, exp2)
    return Exponent(expod)
end

## Polynomial
function product(p1::Polynomial, p2::Polynomial)
    p = Polynomial()
    for (expo1, λ1) in p1
        λ1 != 0 || continue
        for (expo2, λ2) in p2
            λ2 != 0 || continue
            expoprod = product(expo1, expo2)
            add_to_dict!(p.poly, expoprod, λ1 * λ2)
        end
    end
    p.degree.explvar = p1.degree.explvar+p2.degree.explvar
    p.degree.conjvar = p1.degree.conjvar+p2.degree.conjvar
    return p
end

function *(p1::T, p2::U) where T<:AbstractPolynomial where U<:AbstractPolynomial
    return product(convert(Polynomial, p1), convert(Polynomial, p2))
end
function *(p1::Number, p2::T) where T<:AbstractPolynomial
    return product(convert(Polynomial, p1), convert(Polynomial, p2))
end
function *(p1::T, p2::Number) where T<:AbstractPolynomial
    return product(convert(Polynomial, p1), convert(Polynomial, p2))
end


## Division
function divide(p1::Polynomial, p2::Polynomial)
    if length(p2) != 1
        error("/(::Polynomial, ::Polynomial): Only allowed for monomial divisor ($(length(p2))-monomial polynomial here).")
    end
    expo, λ = collect(p2)[1]
    if expo.degree != Degree(0,0)
        error("/(::Polynomial, ::Polynomial): Only allowed for constant divisor ($(expo.degree)-degree monomial here).")
    end
    if λ == 0
        error("/(::Polynomial, ::Polynomial): Only allowed for non null constant divisor.")
    end
    return p1 * (1/λ)
end

function /(p1::T, p2::U) where T<:AbstractPolynomial where U<:AbstractPolynomial
    return divide(convert(Polynomial, p1), convert(Polynomial, p2))
end
function /(p1::Number, p2::T) where T<:AbstractPolynomial
    return divide(convert(Polynomial, p1), convert(Polynomial, p2))
end
function /(p1::T, p2::Number) where T<:AbstractPolynomial
    return divide(convert(Polynomial, p1), convert(Polynomial, p2))
end


## Point
function *(pt1::Point, λ::Number)
  pt = Point()
  if λ == 0
    return pt
  end
  for (var, val) in pt1
    pt[var] = λ*val
  end
  return pt
end
*(λ::Number, pt1::Point) = pt1*λ

