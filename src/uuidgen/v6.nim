import std/times, atomics
import std/random

var clockSequenceV6: Atomic[uint16]

proc ensureInitV6() =
  once:
    randomize()
    clockSequenceV6.store(rand(uint16))


proc newUuidv6*(dt: DateTime, nodeId: array[6, byte]): Uuid = 
  ensureInitV1()
  let ticks = getTimestamp100ns(dt)
  let counter = fetchAdd(clockSequenceV1, 1) and 0x3FFF'u64
  let timeHigh = ((ticks shr 28) and 0xFFFF_FFFF'u64)
  let timeMid = ((ticks shr 12) and 0xFFFF'u64)
  let timeLow = (ticks and 0x0FFF'u64)
  result[0] = byte(timeHigh shr 24)
  result[1] = byte(timeHigh shr 16)
  result[2] = byte(timeHigh shr 8)
  result[3] = byte(timeHigh)
  result[4] = byte(timeMid shr 8)
  result[5] = byte(timeMid)
  result[6] = byte(timeLow shr 8)
  result[7] = byte(timeLow)
  result[8] = byte((counter and 0x3F00) shr 8)
  result[9] = byte(counter and 0xFF)

  for i in 0..<6:
    result[10 + i] = nodeId[i]
  
  result.setVersion(UuidVersion.vSortMac)
  result.setVariant(UuidVariant.vRfc4122)


proc nowUuidv6*(nodeId: array[6, byte]): Uuid =
  result = newUUidv6(now(), nodeId)




 
