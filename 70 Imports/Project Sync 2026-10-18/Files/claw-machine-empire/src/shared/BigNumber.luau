-- Non-negative scientific values. ~15 significant digits, NOT exact accounting.
-- A bounded exponent avoids native float overflow; tiny addends may round away.
local Big = {}
local LIMIT = 1000000
function Big.valid(a)
    return type(a)=="table" and type(a.m)=="number" and type(a.e)=="number"
        and a.m==a.m and a.e==a.e and a.m>=0 and a.m<10
        and a.e%1==0 and a.e>=-LIMIT and a.e<=LIMIT
        and ((a.m==0 and a.e==0) or a.m>=1)
end
function Big.new(m, e)
    e = e or 0
    assert(type(m)=="number" and m==m and m>=0 and m<math.huge, "invalid mantissa")
    assert(type(e)=="number" and e==e and e%1==0 and math.abs(e)<=LIMIT, "invalid exponent")
    if m==0 then return {m=0,e=0} end
    local shift = math.floor(math.log10(m))
    if 10^shift==0 then shift+=1 end
    m, e = m / 10^shift, e+shift
    if m>=10 then m,e=m/10,e+1 end
    if m<1 then m,e=m*10,e-1 end
    assert(math.abs(e)<=LIMIT, "number range exceeded")
    return {m=m,e=e}
end
function Big.copy(a) return {m=a.m,e=a.e} end
function Big.compare(a,b)
    if a.m==0 then return if b.m==0 then 0 else -1 end
    if b.m==0 then return 1 end
    if a.e~=b.e then return if a.e>b.e then 1 else -1 end
    if math.abs(a.m-b.m)<1e-12 then return 0 end
    return if a.m>b.m then 1 else -1
end
function Big.add(a,b)
    if a.m==0 then return Big.copy(b) end
    if b.m==0 then return Big.copy(a) end
    if a.e<b.e then a,b=b,a end
    if a.e-b.e>15 then return Big.copy(a) end
    return Big.new(a.m + b.m*10^(b.e-a.e), a.e)
end
function Big.sub(a,b)
    assert(Big.compare(a,b)>=0, "insufficient balance")
    if b.m==0 or a.e-b.e>15 then return Big.copy(a) end
    return Big.new(math.max(0,a.m-b.m*10^(b.e-a.e)), a.e)
end
function Big.mul(a,n)
    assert(type(n)=="number" and n==n and n>=0 and n<math.huge, "invalid multiplier")
    local b=Big.new(n)
    return Big.new(a.m*b.m,a.e+b.e)
end
function Big.format(a)
    if a.m==0 then return "0" end
    if a.e<3 then return string.format("%.0f",a.m*10^a.e) end
    local suffix={"K","M","B","T","Qa","Qi","Sx","Sp","Oc","No","Dc"}
    local group=math.floor(a.e/3)
    if suffix[group] then return string.format("%.1f%s",a.m*10^(a.e%3),suffix[group]) end
    return string.format("%.2fe%d",a.m,a.e)
end
return Big
