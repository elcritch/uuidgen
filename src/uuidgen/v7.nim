import std/[times, sysrand]

proc newUuidv7*(ts: Time): Uuid = 
  if not urandom(dest=result):
    raise newException(OSError, "Failed to generate random bytes for Uuid")
  
  let timestamp = getMilliSinceUnixEpoch(ts)

  for i in 0..5:
    result[i] = byte((timestamp shr (8*(5-i))) and 0xFF)
  
  result.setVersion(UuidVersion.vSortRand)
  result.setVariant(UuidVariant.vRfc4122)

proc nowUuidv7*(): Uuid = 
  result = newUuidv7(now().toTime())


  





