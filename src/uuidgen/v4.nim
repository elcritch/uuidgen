import std/sysrand

proc newUuidv4*(): Uuid =
  let success = urandom(dest=result)
  if success:
    result.setVersion(UuidVersion.vRandom)
    result.setVariant(UuidVariant.vRfc4122)


