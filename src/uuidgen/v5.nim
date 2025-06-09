import checksums/sha1

proc newUuidv5*(namespace: Uuid, name: seq[byte]): Uuid =
  var dataToHash = cast[string](namespace[0..<16] & name)
  var digest = cast[Sha1Digest](sha1.secureHash(dataToHash))
  for i in 0..15:
    result[i] = byte(digest[i])

  result.setVersion(UuidVersion.vSha1)
  result.setVariant(UuidVariant.vRfc4122)


