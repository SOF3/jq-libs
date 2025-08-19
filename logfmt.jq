def find_quoted_len:
  index("\"") as $quote |
  if ($quote | type == "null") then
    error("unclosed string, no matching close \"")
  else
    index("\\") as $bs |
    if ($bs | type == "null") then
      $quote + 1
    else
      .[$bs+2:] | find_quoted_len + $bs+2
    end
  end
;

def parse_line:
  rtrimstr("\n ") |
  index("=") as $keyLen |
  if length == 0 then
    {}
  elif $keyLen | type == "null" then
    error("no \"=\" in remaining string")
  else
    .[:$keyLen] as $key |
    .[$keyLen+1:] |
    if .[0:1] == "\"" then
      (.[1:] | find_quoted_len + 1) as $valueLen |
      (.[:$valueLen] | fromjson) as $value |
      .[$valueLen+1:] |
      {$key: $value} + parse_line
    else
      index(" ") as $valueLen |
      if $valueLen | type == "null" then
        {$key: .}
      else
        .[:$valueLen] as $value |
        .[$valueLen+1:] |
        {$key: $value} + parse_line
      end
    end
  end
;

# For klog output, we have to assume that keys do not contain spaces and values do not contain equal sign
def parse_unquoted_line:
  rtrimstr("\n ") |
  rindex("=") as $splitIndex |
  if length == 0 then
    {}
  elif $splitIndex | type == "null" then
    error("no \"=\" in remaining string")
  else
    .[$splitIndex+1:] as $value |
    .[:$splitIndex] |
    rindex(" ") as $keySplit |
    (if $keySplit | type == "null" then
      [{}, .]
    elif index("=") | type == "null" then
      [{_msg: .[:$keySplit]}, .[$keySplit+1:]]
    else
      [(.[:$keySplit] | parse_unquoted_line), .[$keySplit+1:]]
    end) as $prev |
    $prev[0] + {($prev[1]): $value}
  end
;
