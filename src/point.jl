export Point, print

"""
    Point(coords::SortedDict{Variable, Number})

Define a mathematical point, that is a pairing of variables and numbers.

### Attributes
- `coords` : a dictionary associating a `Variable` to a a number.

### Exemple
```julia
julia > a, b = Variable("a", Complex), Variable("b", Complex)
julia > pt = Point(SortedDict(a=>π, b=>e+7im))
```
"""
struct Point
    coords::SortedDict{Variable, Number}
    isdense::Bool

    function Point(dict::SortedDict; isdense=false)
        dict_pt = SortedDict{Variable, Number}()
        for (var, val) in dict
            if !isa(var, Variable) || !isa(val, Number)
                error("Point(): Expected pair of (Variable, Number), got ($var, $val) of type ($typeof(var), $typeof(val)) instead.")
            end
            if isbool(var)
                booled = 0
                if val != 0
                    booled = Int((val/abs(val) + 1) / 2)
                end
                (booled ≠ val) && warn("Point(): $var is $(var.kind), provided value is $val, $booled stored.")
                add_to_dict!(dict_pt, var, booled, isdense = isdense)
            elseif isreal(var)
                realed = real(val)
                (realed ≠ val) && warn("Point(): $var is $(var.kind), provided value is $val, $realed stored.")
                add_to_dict!(dict_pt, var, realed, isdense = isdense)
            else
                add_to_dict!(dict_pt, var, val, isdense = isdense)
            end
        end
        return new(dict_pt, isdense)
    end
end

function setindex!(pt::Point, var::Variable, val::Number)
  if val != 0
    setindex!(pt.coords, var, val)
  end
  return
end

function setindex!(pt::Point, val::Number, var::Variable)
    pt.coords[var] = val
end

Point() = Point(SortedDict{Variable, Number}())

function Point(vars::Array{Variable}, vals::Array{<:Number})
  if length(vars) != length(vals)
    error("Point(): input arrays must have same size.")
  end

  pt = Point()
  for i=1:length(vars)
    var, val = vars[i], vals[i]
    if isreal(var) val = real(val) end
    if isbool(var) && val != 0
      val = Int((val/abs(val)+1)/2)
    end
    add_coord!(pt, vars[i], val)
  end
  return pt
end


#############################
## Print
#############################
function Base.print(io::IO, pt::Point)
  for (var, val) in pt
    println(io, var, " ", val)
  end
end
