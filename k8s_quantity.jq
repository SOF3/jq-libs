def parse_quantity:
  {n: -3, u: -2, m: -1, k: 1, M: 2, G: 3} as $units |
  if .[-1:] == "i" then
    {base: 1024, str: .[:-1]}
  else
    {base: 1000, str: .}
  end |
  .str[-1:] as $unit |
  if $units | has($unit) then
    pow(10; $units[$unit]) * (.str[:-1] | tonumber)
  elif .base == 1000 then
    tonumber
  else
    error("unknown unit in \(.str)")
  end
;
