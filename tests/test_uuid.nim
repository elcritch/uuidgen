import unittest
import uuidgen
import times
import sequtils
import strutils
import options

test "round-trip conversion between two uint64s and Uuid":
  let originalHigh: uint64 = 0x123456789ABCDEF0'u64
  let originalLow: uint64 = 0x1122334455667788'u64
  var uuid = initUuid(originalHigh, originalLow)
  var roundTrip = uuid.getHighLow()
  check roundTrip.high == originalHigh
  check roundTrip.low == originalLow

test "Uuid to string conversion (`$` operator)":
  # Test case 1: A general UUID
  let uuid1High: uint64 = 0x123456789ABCDEF0'u64
  let uuid1Low: uint64  = 0x1122334455667788'u64
  let uuid1 = initUuid(uuid1High, uuid1Low)
  let expectedStr1 = "12345678-9abc-def0-1122-334455667788"
  check($uuid1 == expectedStr1)

  # Test case 2: All-zero UUID
  let zeroUuid = initUuid(0'u64, 0'u64)
  let expectedZeroStr = "00000000-0000-0000-0000-000000000000"
  check($zeroUuid == expectedZeroStr)

  # Test case 3: All-max UUID (all F's)
  let maxUuid = initUuid(high(uint64), high(uint64))
  let expectedMaxStr = "ffffffff-ffff-ffff-ffff-ffffffffffff"
  check($maxUuid == expectedMaxStr)

test "isZero and isMax":
  let zeroUuid = initUuid(0, 0)
  check(zeroUuid.isZero() == true)
  check(zeroUuid.isMax() == false)

  let nonZeroUuid = initUuid(1, 0)
  check(nonZeroUuid.isZero() == false)
  check(nonZeroUuid.isMax() == false)

  let maxUuid = initUuid(high(uint64), high(uint64))
  check(maxUuid.isMax() == true)
  check(maxUuid.isZero() == false)

  let nonMaxUuid = initUuid(high(uint64) - 1, high(uint64))
  check(nonMaxUuid.isMax() == false)
  check(nonMaxUuid.isZero() == false)

suite "UUID Parsing Tests":
  var uuidStr = "550e8400-e29b-41d4-a716-446655440000"
  test "Parse simple (32-char) UUID":
    let uuid = parseStr(uuidStr)
    check uuid.len == 16
    check $uuid == uuidStr

  test "Parse hyphenated (36-char) UUID":
    let uuid = parseStr("550e8400-e29b-41d4-a716-446655440000")
    check uuid.len == 16
    check $uuid == uuidStr

  test "Parse braced (38-char) UUID":
    let uuid = parseStr("{550e8400-e29b-41d4-a716-446655440000}")
    check uuid.len == 16
    check $uuid == uuidStr

  test "Parse URN (45-char) UUID":
    let uuid = parseStr("urn:uuid:550e8400-e29b-41d4-a716-446655440000")
    check uuid.len == 16
    check $uuid == uuidStr

  test "Invalid UUID (wrong hyphen positions)":
    expect InvalidUuid:
      discard parseStr("550e8400e29b-41d4-a716-446655440000")  # malformed

  test "Invalid UUID (bad hex digit)":
    expect InvalidUuid:
      discard parseStr("550e8400-e29b-41d4-a716-44665544000z")  # 'z' is not hex

  test "Invalid UUID (wrong length)":
    expect InvalidUuid:
      discard parseStr("550e8400e29b41d4a71644665544")  # too short

  test "Invalid UUID (bad URN prefix)":
    expect InvalidUuid:
      discard parseStr("urn:uuidd:550e8400-e29b-41d4-a716-446655440000")

suite "UUIDv1 Tests":
  test "Generated UUIDv1 is valid":
    let now = now()
    let nodeId = [byte 0x00, 0x1A, 0x2B, 0x3C, 0x4D, 0x5E]
    let uuid = newUuidv1(now, nodeId)
    check uuid.len == 16

  test "UUIDv1 uniqueness check":
    let now = now()
    let nodeId = [byte 0x01, 0x23, 0x45, 0x67, 0x89, 0xAB]
    let uuid1 = newUuidv1(now, nodeId)
    let uuid2 = newUuidv1(now, nodeId)
    check uuid1 != uuid2

test "UUIDv3 produces correct results":
  let fixtures = [
    (NAMESPACE_DNS, "example.org", "04738bdf-b25a-3829-a801-b21a1d25095b"),
    (NAMESPACE_DNS, "42", "5aab6e0c-b7d3-379c-92e3-2bfbb5572511"),
    (NAMESPACE_DNS, "lorem ipsum", "4f8772e9-b59c-3cc9-91a9-5c823df27281"),
    (NAMESPACE_URL, "example.org", "39682ca1-9168-3da2-a1bb-f4dbcde99bf9"),
    (NAMESPACE_URL, "42", "08998a0c-fcf4-34a9-b444-f2bfc15731dc"),
    (NAMESPACE_URL, "lorem ipsum", "e55ad2e6-fb89-34e8-b012-c5dde3cd67f0"),
    (NAMESPACE_OID, "example.org", "f14eec63-2812-3110-ad06-1625e5a4a5b2"),
    (NAMESPACE_OID, "42", "ce6925a5-2cd7-327b-ab1c-4b375ac044e4"),
    (NAMESPACE_OID, "lorem ipsum", "5dd8654f-76ba-3d47-bc2e-4d6d3a78cb09"),
    (NAMESPACE_X500, "example.org", "64606f3f-bd63-363e-b946-fca13611b6f7"),
    (NAMESPACE_X500, "42", "c1073fa2-d4a6-3104-b21d-7a6bdcf39a23"),
    (NAMESPACE_X500, "lorem ipsum", "02f09a3f-1624-3b1d-8409-44eff7708208"),
  ]
  for (namespace, name, expectedStr) in fixtures:
    let bytesSeq = name.mapIt(byte(it))
    let uuid = newUuidv3(namespace, bytesSeq)
    check($uuid == expectedStr)

test "newUuidv4 produces correct results":
  let uuid1 = newUuidv4()
  check(uuid1.getVersionNum() == 4)
  let uuid2 = newUuidv4()
  check(uuid1 != uuid2)


test "UUIDv5 produces correct results":
  let fixtures = [
    (NAMESPACE_DNS, "example.org", "aad03681-8b63-5304-89e0-8ca8f49461b5"),
    (NAMESPACE_DNS, "42", "7c411b5e-9d3f-50b5-9c28-62096e41c4ed"),
    (NAMESPACE_DNS, "lorem ipsum", "97886a05-8a68-5743-ad55-56ab2d61cf7b"),
    (NAMESPACE_URL, "example.org", "54a35416-963c-5dd6-a1e2-5ab7bb5bafc7"),
    (NAMESPACE_URL, "42", "5c2b23de-4bad-58ee-a4b3-f22f3b9cfd7d"),
    (NAMESPACE_URL, "lorem ipsum", "15c67689-4b85-5253-86b4-49fbb138569f"),
    (NAMESPACE_OID, "example.org", "34784df9-b065-5094-92c7-00bb3da97a30"),
    (NAMESPACE_OID, "42", "ba293c61-ad33-57b9-9671-f3319f57d789"),
    (NAMESPACE_OID, "lorem ipsum", "6485290d-f79e-5380-9e64-cb4312c7b4a6"),
    (NAMESPACE_X500, "example.org", "e3635e86-f82b-5bbc-a54a-da97923e5c76"),
    (NAMESPACE_X500, "42", "e4b88014-47c6-5fe0-a195-13710e5f6e27"),
    (NAMESPACE_X500, "lorem ipsum", "b11f79a5-1e6d-57ce-a4b5-ba8531ea03d0"),
  ]
  for (namespace, name, expectedStr) in fixtures:
    let bytesSeq = name.mapIt(byte(it))
    let uuid = newUuidv5(namespace, bytesSeq)
    check($uuid == expectedStr)

suite "UUIDv6 Tests":
  test "Generated UUIDv6 is valid":
    let now = now()
    let nodeId = [byte 0x00, 0x1A, 0x2B, 0x3C, 0x4D, 0x5E]
    let uuid = newUuidv6(now, nodeId)
    check uuid.len == 16

    check nodeId == uuid.getNodeId().get()
    check now == uuid.getTime().get().utc()

  test "UUIDv6 uniqueness check":
    let now = now()
    let nodeId = [byte 0x01, 0x23, 0x45, 0x67, 0x89, 0xAB]
    let uuid1 = newUuidv6(now, nodeId)
    let uuid2 = newUuidv6(now, nodeId)
    check uuid1 != uuid2

suite "newUuidv7 Tests":
  test "Generates correct Uuid":
    let ts = 1645557742000
    let timestamp = initTime(ts div 1000, 0)
    let uuid = newUuidv7(timestamp)
    let uuidStr = $uuid
    check(uuidStr.startsWith("017f22e2-79b0-7"))
    check timestamp == uuid.getTime().get()
    
  test "Correct Timestamp Encoding":
    var uuid = nowUuidv7()
    check(uuid.getVersionNum() == 7)

test "newUuidv8 produces correct results":
  var input: array[0..15, byte] = [0x00, 0x11, 0x22, 0x33,
                                   0x44, 0x55, 0x66, 0x77,
                                   0x88, 0x99, 0xAA, 0xBB,
                                   0xCC, 0xDD, 0xEE, 0xFF]
  var uuid = newUuidv8(input)
  check(uuid.getVersionNum() == 8)





