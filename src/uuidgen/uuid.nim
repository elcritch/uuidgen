import std/[options, strutils, sequtils, times]

type 
  Uuid* = array[0..15, byte]
  UuidVersion* = enum
    vZero = 0
    vMac = 1
    vDce = 2
    vMd5 = 3
    vRandom = 4
    vSha1 = 5
    vSortMac = 6
    vSortRand = 7
    vCustom = 8
    vMax = 0xff
  UuidVariant* = enum
    vNcs, vRfc4122, vMicrosoft, vFuture
  InvalidUuid* = object of ValueError

proc `$`*(uuid: Uuid): string =
  let hex = uuid.mapIt(it.toHex(2).toLower()).join("")
  result = hex[0..7] & "-" &
           hex[8..11] & "-" &
           hex[12..15] & "-" &
           hex[16..19] & "-" &
           hex[20..31]


proc initUuid*[T: SomeInteger](highBits: T, lowBits: T): Uuid =
  var tempHigh = highBits.uint64
  for i in countdown(7, 0): # Bytes 0 to 7
    result[i] = byte(tempHigh and 0xff'u64)
    tempHigh = tempHigh shr 8

  # Fill the next 8 bytes (least significant) with lowBits
  var tempLow = lowBits.uint64
  for i in countdown(15, 8): # Bytes 8 to 15
    result[i] = byte(tempLow and 0xff'u64)
    tempLow = tempLow shr 8


proc getHighBits*(id: Uuid): uint64 = 
  result = 0
  for i in 0..7:
    result = (result shl 8) or uint64(id[i])


proc getLowBits*(id: Uuid): uint64 =
  result = 0
  for i in 8..15:
    result = (result shl 8) or uint64(id[i])


proc getHighLow*(id: Uuid): tuple[high: uint64, low: uint64] =
  (high: id.getHighBits(), low: id.getLowBits)


proc isZero*(id: Uuid): bool =
  let val = id.getHighLow() 
  return val.high == 0 and val.low == 0


proc isMax*(id: Uuid): bool =
  let val = id.getHighLow() 
  return val.high == high(uint64) and val.low == high(uint64)


proc getVersionNum*(id: Uuid): int =
  (id[6] shr 4).int


proc getVersion*(id: Uuid): Option[UuidVersion] = 
  case id.getVersionNum:
  of 0: 
    if id.is_zero(): some(UuidVersion.vZero) else: none(UuidVersion)
  of 1: some(UuidVersion.vMac)
  of 2: some(UuidVersion.vDce)
  of 3: some(UuidVersion.vMd5)
  of 4: some(UuidVersion.vRandom)
  of 5: some(UuidVersion.vSha1)
  of 6: some(UuidVersion.vSortMac)
  of 7: some(UuidVersion.vSortRand)
  of 8: some(UuidVersion.vCustom)
  of 0xf: 
    if id.is_max(): some(UuidVersion.vMax) else: none(UuidVersion)
  else: none(UuidVersion)


proc setVersion*(id: var Uuid, version: UuidVersion) =
  id[6] = (id[6] and 0x0F) or (byte(version) shl 4)


proc setVariant*(id: var Uuid, variant: UuidVariant) =
  case variant
  of vNcs:
    id[8] = id[8] and 0x7F
  of vRfc4122:
    id[8] = (id[8] and 0x3F) or 0x80
  of vMicrosoft:
    id[8] = (id[8] and 0x1F) or 0xC0
  of vFuture:
    id[8] = (id[8] and 0x1F) or 0xE0


proc getNodeId*(id: Uuid): Option[array[6, byte]] = 
  let versionOpt = id.getVersion()
  if versionOpt.isSome():
    case versionOpt.get(): 
    of UuidVersion.vMac, UuidVersion.vSortMac:
      var nodeId: array[6, byte]
      for i in 0..5:
        nodeId[i] = id[10+i]
      some(nodeId)
    else:
      none(array[6, byte])
  else:
    none(array[6, byte]) 

proc hexPairToByte(a: char, b: char): byte = 
  let s = a & b
  try:
    result = parseHexInt(s).byte
  except:
    raise newException(InvalidUuid, "Invalid hex digit: " & s)

proc parseHyphenated(input: string): Uuid = 
  if not (input[8] == '-' and input[13] == '-' and 
          input[18] == '-' and input[23] == '-'):
    raise newException(InvalidUuid, "Hypens are in the wrong positions")
  
  var byteIdx = 0
  var idx = 0
  while idx < 36:
    if input[idx] == '-':
      inc(idx)
    else:
      result[byteIdx] = hexPairToByte(input[idx], input[idx+1])
      inc(byteIdx)
      inc(idx, 2)
      
proc parseSimple(input: string): Uuid = 
  for i in 0..<16:
    result[i] = hexPairToByte(input[i*2], input[i * 2 + 1])

proc parseBraced(input: string): Uuid = 
  if input[0] == '{' and input[^1] == '}':
    let inner = input[1..^2]
    result = parseHyphenated(inner)
  else:
    raise newException(InvalidUuid, "Invalid braced UUID format")

proc parseUrn(input: string): Uuid = 
  if input.startsWith("urn:uuid:"):
    let inner = input[9..^1]
    result = parseHyphenated(inner)
  else:
    raise newException(InvalidUuid, "Invalid URN UUID format")

proc parseStr*(input: string): Uuid = 
  case input.len:
  of 32:
    result = parseSimple(input)
  of 36:
    result = parseHyphenated(input)
  of 38:
    result = parseBraced(input)
  of 45:
    result = parseUrn(input)
  else:
    raise newException(InvalidUuid, "Invalid UUID string length")
    
    


    
    


