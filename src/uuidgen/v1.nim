import std/times, atomics
import std/random

var clockSequenceV1: Atomic[uint16]

proc ensureInitV1() =
  once:
    randomize()
    clockSequenceV1.store(rand(uint16))


proc newUuidv1*(dt: DateTime, nodeId: array[6, byte]): Uuid = 
  ensureInitV1()
  let ticks = getTimestamp100ns(dt)
  let counter = fetchAdd(clockSequenceV1, 1) and 0x3FFF'u64
  let timeLow = (ticks and 0xFFFF_FFFF'u64)
  let timeMid = ((ticks shr 32) and 0xFFFF'u64) 
  let timeHigh = ((ticks shr 48) and 0x0FFF'u64)
  result[0] = byte(timeLow shr 24)
  result[1] = byte(timeLow shr 16)
  result[2] = byte(timeLow shr 8)
  result[3] = byte(timeLow)
  result[4] = byte(timeMid shr 8)
  result[5] = byte(timeMid)
  result[6] = byte(timeHigh shr 8)
  result[7] = byte(timeHigh)
  result[8] = byte((counter and 0x3F00) shr 8)
  result[9] = byte(counter and 0xFF)

  for i in 0..<6:
    result[10 + i] = nodeId[i]
  
  result.setVersion(UuidVersion.vMac)
  result.setVariant(UuidVariant.vRfc4122)


proc nowUuidv1*(nodeId: array[6, byte]): Uuid =
  result = newUUidv1(now(), nodeId)




  
