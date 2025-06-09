# uuigen 🧬 – UUID Generation & Parsing for Nim

**uuigen** is a comprehensive and standards-compliant UUID library for the Nim programming language. It supports generating, parsing, formatting, and inspecting UUIDs of all major versions, including newer drafts like UUIDv6, v7, and v8.

---

## ✨ Features
- 🆔 Full support for **UUID versions 1 through 8**
- 🔍 Robust parsing from multiple input formats (standard, braced, URN)
- 🧾 Conversion between UUIDs and `(high, low)` `uint64` pairs
- 🧰 Utility functions: `isZero`, `isMax`, `getVersionNum`, etc.
- 🔐 Name-based UUID generation (v3 and v5) with predefined namespaces
- 🔄 String formatting and round-trip validation
- 🧪 Thoroughly tested and ready for production use

## uuigen API Reference

```nim
# UUID Construction
proc initUuid(high: uint64, low: uint64): Uuid
proc getHighLow(uuid: Uuid): tuple[high, low: uint64]

# Parsing
proc parseStr(str: string): Uuid  # supports 36, 38 (braced), 45 (URN) formats
# raises InvalidUuid on failure

# Formatting
proc `$`(uuid: Uuid): string  # to standard 36-char hyphenated string

# Inspection
proc getVersionNum(uuid: Uuid): int
proc isZero(uuid: Uuid): bool
proc isMax(uuid: Uuid): bool

# Generation
proc newUuidv1(timestamp: Time, node: array[6, byte]): Uuid
proc newUuidv3(namespace: Uuid, name: seq[byte]): Uuid
proc newUuidv4(): Uuid
proc newUuidv5(namespace: Uuid, name: seq[byte]): Uuid
proc newUuidv6(timestamp: Time, node: array[6, byte]): Uuid
proc newUuidv7(timestamp: Time): Uuid
proc nowUuidv7(): Uuid
proc newUuidv8(data: array[16, byte]): Uuid

# Constants
const
  NAMESPACE_DNS: Uuid
  NAMESPACE_URL: Uuid
  NAMESPACE_OID: Uuid
  NAMESPACE_X500: Uuid

# Exceptions
type InvalidUuid = object of ValueError

# Usage Example
import uuigen

let uuid = newUuidv4()
echo $uuid

---
