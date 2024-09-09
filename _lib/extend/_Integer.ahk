#Include _Base.ahk

DefProp(0.base, "BitCount", { call: _BitCount })
DefProp(0.base, "ToBase", { call: _ToBase })
DefProp(0.base, "Between", { call: _Between })

_BitCount(this) {
  n := this
  n := (n >> 1 & 0x55555555) + (n & 0x55555555)
  n := (n >> 2 & 0x33333333) + (n & 0x33333333)
  n := (n >> 4 & 0x0F0F0F0F) + (n & 0x0F0F0F0F)
  n := (n >> 8 & 0xff00ff) + (n & 0xff00ff)
  n := (n >> 16 & 0xffff) + (n & 0xffff)
  return n
}

_ToBase(this, b) => (this < b ? "" : _ToBase(this // b, b)) . ((d := Mod(this, b)) < 10 ? d : Chr(d + 55))
_Between(this, l, r) => this >= l && this <= r