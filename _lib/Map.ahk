﻿#Include Extend_Merged.ahk

class GenericMap extends Map {
  __New(keyT, valT) {
    this.keyType := keyT
    this.valType := valT
    super.__New()
  }

  Set(k, v) {
    if not k is this.keyType
      throw TypeError('bad key type: ' type(k))
    if not v is this.valType
      throw TypeError('bad value type:' type(v))
    super.Set(k, v)
  }
}