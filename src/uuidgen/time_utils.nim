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

proc getDateTime*[T: Uuid](id: T): Option[DateTime] =
  ## Convert UUID time to UTC DateTime
  let versionOpt = id.getVersion()
  if versionOpt.isSome():
    case versionOpt.get(): 
    of UuidVersion.vSortMac:
      let timeBits = id.getHighBits()
      # UUIDv6 time layout in the high 64 bits:
      # [0..31]=timeHigh, [32..47]=timeMid, [48..51]=version, [52..63]=timeLow (12 bits)
      # Reconstruct 60-bit tick count (100ns units since 1582-10-15).
      let timeHigh = (timeBits shr 32) and 0xFFFF_FFFF'u64
      let timeMid  = (timeBits shr 16) and 0xFFFF'u64
      let timeLow  =  timeBits         and 0x0FFF'u64
      let ticks = (timeHigh shl 28) or (timeMid shl 12) or timeLow

      let diff: int64 =
        (if ticks >= UUID_TICKS_BETWEEN_EPOCHS:
          int64(ticks - UUID_TICKS_BETWEEN_EPOCHS)
        else:
          -int64(UUID_TICKS_BETWEEN_EPOCHS - ticks))
      let secs = diff div 10_000_000'i64
      let remTicks = diff - secs * 10_000_000'i64
      let remNs = remTicks * 100'i64

      let t = fromUnix(secs) + initDuration(nanoseconds = remNs)
      some(t.utc())

    of UuidVersion.vSortRand:
      none(DateTime)
    else:
      none(DateTime)
  else:
    none(DateTime)
