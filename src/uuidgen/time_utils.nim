import std/times

proc getMilliSinceUnixEpoch(ts: Time): int = 
  let
    seconds = ts.toUnix()
    nanosecond = ts.nanosecond()
  
  result = (seconds * 1000) + (nanosecond div 1_000_000)



proc getTimestamp100ns(dt: DateTime): uint64 = 
  let
    unixTimeTicks = uint64(dt.toTime().toUnix()) * 10_000_000
    hundredNsFraction = uint64(dt.toTime().nanosecond() div 100)
    nanosecondTicks = unixTimeTicks + hundredNsFraction

  result = nanosecondTicks + UUID_TICKS_BETWEEN_EPOCHS

