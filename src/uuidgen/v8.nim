proc newUuidv8*(buf: array[0..15, byte]): Uuid =  
  result = buf
  result.setVersion(UuidVersion.vCustom)
  result.setVariant(UuidVariant.vRfc4122)

