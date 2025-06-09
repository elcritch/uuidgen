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
# UUID type & exceptions
type
  Uuid* = array[0..15, byte]
  InvalidUuid* = object of ValueError

# Construction & conversion
proc initUuid*(high, low: uint64): Uuid
proc getHighLow*(id: Uuid): (high: uint64, low: uint64)

# Parsing & formatting
proc parseStr*(input: string): Uuid              # Supports 32, 36, 38 (braced), 45 (URN) length inputs
proc `$`*(id: Uuid): string                      # Formats UUID to hyphenated lowercase string

# Inspection
proc getVersionNum*(id: Uuid): int
proc getVersion*(id: Uuid): Option[UuidVersion]
proc isZero*(id: Uuid): bool
proc isMax*(id: Uuid): bool

# Generation
proc newUuidv1*(timestamp: Time, node: array[6, byte]): Uuid
proc nowUuidv1*(): Uuid
proc newUuidv3*(namespace: Uuid, name: seq[byte]): Uuid
proc newUuidv4*(): Uuid
proc newUuidv5*(namespace: Uuid, name: seq[byte]): Uuid
proc newUuidv6*(timestamp: Time, node: array[6, byte]): Uuid
proc newUuidv7*(timestamp: Time): Uuid
proc nowUuidv7*(): Uuid
proc newUuidv8*(data: array[16, byte]): Uuid

# Constants
const
  NAMESPACE_DNS*: Uuid
  NAMESPACE_URL*: Uuid
  NAMESPACE_OID*: Uuid
  NAMESPACE_X500*: Uuid

# Exceptions
type
  InvalidUuid* = object of ValueError

# Usage Example
import uuigen

let uuid = newUuidv4()
echo $uuid

---
