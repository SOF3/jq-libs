def rpad($with; $length):
  until(length == $length; . + $with)
;

def time:
  strftime("%H:%M:%S.")
  + (fmod(.; 1) | tostring | split(".")[1])
;

def time($precision):
  strftime("%H:%M:%S.")
  + (
    fmod(.; 1) |
    tostring |
    split(".")[1] |
    .[:([$precision, length] | min)] |
    rpad("0"; $precision)
  )
;

def current_time:
  now | time
;

def current_time($precision):
  now | time($precision)
;
