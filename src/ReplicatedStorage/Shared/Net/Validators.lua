local Validators = {}

local function is(t: string)
  return function(v): boolean
    return typeof(v) == t
  end
end

Validators.string = is("string")
Validators.number = is("number")
Validators.Vector3 = is("Vector3")
Validators.CFrame = is("CFrame")

function Validators.integer(v): boolean
  return typeof(v) == "number" and v % 1 == 0
end

function Validators.boolean(v): boolean
  return type(v) == "boolean"
end

function Validators.table(v): boolean
  return type(v) == "table"
end

function Validators.any(_v): boolean
  return true
end

function Validators.optional(pred)
  return function(v)
    if v == nil then
      return true
    end
    return pred(v)
  end
end

function Validators.union(...)
  local predicates = { ... }
  return function(v)
    for _, pred in ipairs(predicates) do
      if pred(v) then
        return true
      end
    end
    return false
  end
end

function Validators.array(ofPredicate)
  return function(arr)
    if type(arr) ~= "table" then
      return false
    end
    for _, value in ipairs(arr) do
      if not ofPredicate(value) then
        return false
      end
    end
    return true
  end
end

function Validators.shape(spec)
  return function(obj)
    if type(obj) ~= "table" then
      return false
    end
    for key, predicate in pairs(spec) do
      if not predicate(obj[key]) then
        return false
      end
    end
    return true
  end
end

return Validators
