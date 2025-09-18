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
      let timeHigh = (timeBits shr 16) and 0xFFFF_FFFF_FFFF'u64
      let timeLow  =  timeBits         and 0x0FFF'u64
      let gregorianTicks = (timeHigh shl 12) or timeLow

      let ticks: int64 = cast[int64](gregorianTicks - UUID_TICKS_BETWEEN_EPOCHS)
      let secs = ticks div 10_000_000'i64
      let remNs = (ticks - secs * 10_000_000'i64) * 100'i64

      let t = fromUnix(secs) + initDuration(nanoseconds = remNs)
      some(t.utc())

    of UuidVersion.vSortRand:
      none(DateTime)
    else:
      none(DateTime)
  else:
    none(DateTime)
