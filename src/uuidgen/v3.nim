import checksums/md5

proc newUuidv3*(namespace: Uuid, name: seq[byte]): Uuid = 
  var dataToHash = cast[string](namespace[0..<16] & name)
  result = md5.toMD5(dataToHash)
  result.setVersion(UuidVersion.vMd5)
  result.setVariant(UuidVariant.vRfc4122)


