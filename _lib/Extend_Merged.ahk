#Requires AutoHotkey v2.0
DefProp := {}.DefineProp
Noop(*) => {}
IsMap(_obj) => _obj is Map
IsArray(_obj) => _obj is Array
IsString(_obj) => _obj is String
IsVarRef(_obj) => _obj is VarRef
IsComObj(_obj) => _obj is ComObject
IsFunction(_obj) => _obj is Func
IsPrimitive(_obj) => _obj is Primitive
TypeIsObj(_obj) => Type(_obj) = 'object'
IsTrue(var) => var != '' && var != 0
IsFalse(var) => !IsTrue(var)
IsEmpty(var) => IsFalse(var)
  || IsArray(var) and var.Length = 0
  || IsMap(var) and var.Count = 0
  || TypeIsObj(var) and ObjOwnPropCount(var) = 0
DefProp("".base, "At", { call: _At_String })
DefProp("".base, "CharAt", { call: _CharAt })
DefProp("".base, "CharCodeAt", { call: _CharCodeAt })
DefProp("".base, "ToChs", { call: StrSplit })
DefProp("".base, "ToCharArray", { call: StrSplit })
DefProp("".base, "Concat", { call: _Concat_String })
DefProp("".base, "BeginWith", { call: _BeginWith })
DefProp("".base, "EndWith", { call: _EndWith })
DefProp("".base, "Repeat", { call: _Repeat })
DefProp("".base, "RTrim", { call: RTrim })
DefProp("".base, "Replace", { call: StrReplace })
DefProp("".base, "LTrim", { call: LTrim })
DefProp("".base, "Trim", { call: Trim })
DefProp("".base, "ToLowerCase", { call: StrLower })
DefProp("".base, "ToUpperCase", { call: StrUpper })
DefProp("".base, "ToTitleCase", { call: StrTitle })
DefProp("".base, "Split", { call: StrSplit })
DefProp("".base, "SubString", { call: _SubStr })
DefProp("".base, "Length", { get: StrLen })
DefProp("".base, "PadStart", { call: _padStart })
DefProp("".base, "PadEnd", { call: _padEnd })
DefProp("".base, "__item", { get: __item_String })
DefProp("".base, "__Enum", { call: String_Enum })
String_Enum(this, paramCnt) => this.tocharArray().__Enum()
__item_String(this, index) => this.CharAt(index)
_At_String(this, index) => this.ToCharArray()[index]
_CharAt(this, index) {
  charArr := StrSplit(this)
  return index > 0 ? charArr[index] : charArr[charArr.Length + index + 1]
}
_CharCodeAt(this, index) {
  char := this.CharAt(index)
  return Ord(char)
}
_Concat_String(this, str*) {
  r := this
  for v in str {
    r .= v
  }
  return r
}
_BeginWith(this, searchString, caseSense := false) {
  flag := caseSense ? '' : 'i)'
  return this ~= flag '^' searchString
}
_EndWith(this, searchString, endPostion?) {
  sl := searchString.Length
  if IsSet(endPostion) {
    if sl < endPostion {
      target := SubStr(this, endPostion - sl + 1, sl)
      if target = searchString
        return true
    }
    return false
  } else {
    return searchString = SubStr(this, this.Length - sl + 1)
  }
}
_SubStr(this, startPos, length?) {
  if IsSet(length) && length > startPos
    length := length - startPos
  return SubStr(this, startpos, length?)
}
_Repeat(this, count) {
  if count < 0
    throw Error('RangeError')
  else if count = 0
    return ''
  else if count = 1
    return this
  count := Floor(count)
  loop count {
    r .= this
  }
  return r
}
_padStart(this, len, str) {
  if this.Length >= len
    return this
  len := len >> 0, l := len - this.length, str := str.Length ? str : '0'
  if (l > str.length)
    str .= str.repeat(l / str.length)
  return (SubStr(str, 1, l) this)
}
_padEnd(this, len, str) {
  if this.Length >= len
    return this
  len := len >> 0, l := len - this.length, str := str.Length ? str : '0'
  if (l > str.length)
    str .= str.repeat(l / str.length)
  return (this SubStr(str, 1, l))
}
Array.DefineProp('From', { call: _From })
arrProto := Array.Prototype
arrProto.DefineProp("Concat", { call: _Concat_Array })
arrProto.DefineProp("Peek", { call: _Peek })
arrProto.DefineProp("At", { call: _At_Array })
arrProto.DefineProp("Every", { call: _Every })
arrProto.DefineProp("Fill", { call: _Fill })
arrProto.DefineProp("Flat", { call: _Flat })
arrProto.DefineProp("Filter", { call: _Filter })
arrProto.DefineProp("Find", { call: _Find })
arrProto.DefineProp("FindIndex", { call: _FindIndex })
arrProto.DefineProp("FindLast", { call: _FindLast })
arrProto.DefineProp("FindLastIndex", { call: _FindLastIndex })
arrProto.DefineProp("ForEach", { call: _ForEach })
arrProto.DefineProp("DeepClone", { call: _DeepClone })
arrProto.DefineProp("Includes", { call: _Includes })
arrProto.DefineProp("Join", { call: _Join })
arrProto.DefineProp("Map", { call: _Map })
arrProto.DefineProp("Reduce", { call: _Reduce })
arrProto.DefineProp("Reverse", { call: _Reverse })
arrProto.DefineProp("ToReverse", { call: _ToReverse })
arrProto.DefineProp("Shift", { call: _Shift })
arrProto.DefineProp("Max", { call: _Max })
_From(this, arrayLike, mapFn?) {
  if not (IsArray(arrayLike) or IsString(arrayLike))
    throw Error('invalid param')
  if IsSet(mapFn) {
    switch mapFn.MaxParams {
      case 1: _fn := (v, *) => mapFn(v)
      case 2: _fn := (v, index, *) => mapFn(v, index)
      default: throw Error('invalid callback function')
    }
  } else _fn := (v, *) => v
  arr := []
  if arrayLike is Array {
    for v in arrayLike
      arr.Push(_fn(v, A_Index))
  } else arr := arrayLike.ToCharArray()
  return arr
}
_Concat_Array(this, value*) {
  r := this.DeepClone()
  for v in value
    IsArray(v) ? r.Push(v*) : r.Push(v)
  return r
}
_Peek(this) => this[this.Length]
_At_Array(this, index) => index > 0 ? this[index] : this[this.Length + index + 1]
_Every(this, cb) {
  copy := this
  switch cb.MaxParams {
    case 1: _fn := (v, *) => cb(v)
    case 2: _fn := (v, index, *) => cb(v, index)
    case 3: _fn := (v, index, arr) => cb(v, index, arr)
    default: throw Error('invalid callback function')
  }
  for v in copy {
    if !_fn(v, A_Index, copy)
      return false
  }
  return true
}
_Fill(this, value, start?, end?) {
  l := this.Length
  if IsSet(start) {
    if IsSet(end) {
      end := end > l ? l : end
      start := start > end ? end : start
      d := end - start
    } else d := start > l ? l : l - start
    loop d + 1
      this[start + A_Index - 1] := value
  } else loop l
    this[A_Index] := value
}
_Flat(this, depth) {
  stack := [this.map(item => [item, depth])*], res := []
  while (stack.Length > 0) {
    sub := stack.Pop(), _item := sub[1], _depth := sub[2]
    if (IsArray(_item) && (_depth > 0 || depth = -1))
      stack.Push(_item.map(el => [el, _depth - 1])*)
    else res.Push(_item)
  }
  return res.reverse()
}
_Filter(this, cb) {
  r := []
  switch cb.MaxParams {
    case 1: _fn := (v, *) => cb(v)
    case 2: _fn := (v, index, *) => cb(v, index)
    case 3: _fn := (v, index, arr) => cb(v, index, arr)
    default: throw Error('invalid callback function')
  }
  for v in this {
    if _fn(v, A_Index, this)
      r.Push(v)
  }
  return r
}
_Find(this, cb) {
  for v in this {
    if cb(v)
      return v
  }
}
_FindIndex(this, cb) {
  for v in this {
    if cb(v)
      return A_Index
  }
}
_FindLast(this, cb) {
  loop l := this.Length {
    if cb(v := this[l - A_Index + 1])
      return v
  }
}
_FindLastIndex(this, cb) {
  loop l := this.Length {
    if cb(this[l - A_Index + 1])
      return l - A_Index + 1
  }
}
_ForEach(this, cb) {
  switch cb.MaxParams {
    case 1: _fn := (v, *) => cb(v)
    case 2: _fn := (v, index, *) => cb(v, index)
    case 3: _fn := (v, index, arr) => cb(v, index, arr)
    default: throw Error('invalid callback function')
  }
  for v in this
    _fn(v, A_Index, this)
}
_DeepClone(this) {
  arr := []
  for v in this
    arr.Push(v)
  return arr
}
_Join(this, separator := ',') {
  if this.Length {
    for v in this {
      if IsSet(v)
        r .= v (A_Index != this.Length ? separator : '')
    }
    return r || ''
  }
}
_Includes(this, searchElement, fromIndex?) {
  if IsSet(fromIndex) {
    l := this.Length
    if fromIndex > 0 {
      if fromIndex > l
        return false
      i := fromIndex
    } else {
      if fromIndex < -l || fromIndex = 0
        return this.FindIndex((v) => v = searchElement) != -1
      i := l + fromIndex + 1
    }
    c := l - i + 1
    loop c {
      if this[i + A_Index - 1] = searchElement
        return true
    }
    return false
  } else {
    return this.FindIndex((v) => v = searchElement) != -1
  }
}
_Map(this, cb) {
  switch cb.MaxParams {
    case 1: _fn := (v, *) => cb(v)
    case 2: _fn := (v, index, *) => cb(v, index)
    case 3: _fn := (v, index, arr) => cb(v, index, arr)
    default: throw Error('invalid callback function')
  }
  res := []
  for v in this
    res.push(_fn(v, A_Index, this))
  return res
}
_Reduce(this, cb, initialValue?) {
  if !this.Length and !IsSet(initialValue)
    throw TypeError('Reduce of empty array with no initial value')
  switch cb.MaxParams {
    case 1: _fn := (accumulator, *) => cb(accumulator)
    case 2: _fn := (accumulator, curVal, *) => cb(accumulator, curVal)
    case 3: _fn := (accumulator, curVal, index, *) => cb(accumulator, curVal, index)
    case 4: _fn := (accumulator, curVal, index, arr) => cb(accumulator, curVal, index, arr)
    default: throw Error('invalid callback function')
  }
  accumulator := initialValue ?? this[1], i := IsSet(initialValue) ? 1 : 2
  loop this.Length - i + 1
    accumulator := _fn(accumulator, this[i], i, this), i++
  return accumulator
}
_Reverse(this) {
  l := this.Length
  loop l / 2 {
    temp := this[A_Index]
    this[A_Index] := this[l - A_Index + 1]
    this[l - A_Index + 1] := temp
  }
  return this
}
_ToReverse(this) {
  l := this.Length, arr := []
  loop l
    arr.Push(this[l - A_Index + 1])
  return arr
}
_Shift(this) => this.RemoveAt(1)
_Max(this) {
  if !this.Length
    return
  ans := this[1]
  for v in this
    ans := Max(v, ans)
  return ans
}
_Min(this) {
  if !this.Length
    return
  ans := this[1]
  for v in this
    ans := Min(v, ans)
  return ans
}
_DeepEquals(this, other) {
  if this.Length != other.Length {
    return false
  }
}
defProp({}.base, "__item", { get: item_obj_get, set: item_obj_set })
defProp({}.base, "Keys", { get: _Obj_Keys })
defProp({}.base, "Length", { get: ObjOwnPropCount })
defProp({}.base, "Count", { get: ObjOwnPropCount })
item_obj_get(this, key) => this.HasProp(key) ? this.%key% : ''
item_obj_set(this, key, value) => this.%value% := key
_Obj_Keys(this) {
  ks := []
  for k in this.OwnProps()
    ks.Push(k)
  return ks
}
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
mapProto := Map.Prototype
mapProto.DefineProp('OwnProps', { call: _Map_OwnProps })
mapProto.DefineProp("Length", { get: (this) => this.Count })
mapProto.DefineProp('Keys', { get: _Map_Keys })
_Map_OwnProps(this) => this.__Enum()
_Map_Keys(this) {
  ks := []
  for k in this
    ks.Push(k)
  return ks
}
GetWinTransparent(_) => WinGetTransparent(_) || 255
CentreCtrl(g, ctrl, skewX := 0, skewY := 0) {
  g.GetPos(&x, &y, &w, &h), ctrl.GetPos(, , &tw, &th)
  ctrl.Move((w - tw) // 2 + x + skewX, h // 2 + y + skewY)
}
DobuleClick(key, action) {
  KeyWait(key)
  if KeyWait(key, "D T0.3") {
    action()
  }
}
HotKeysOff(hks*) {
  loop hks.Length {
    try Hotkey hks[A_Index], 'Off'
  }
}
IfThen(condition, action, params*) {
  if condition {
    try execRes := action(params*)
    catch
      MsgBox 'error occu when exec func:' action.Name
    return true & IsTrue(execRes)
  } else return false
}
JoinStr(splitor := '', strs*) => strs.Join(splitor)
Deconstruction(target, vars*) {
  if IsArray(target) {
    for i, v in target {
      if not IsVarRef(vars[i]) {
        throw TypeError('array deconstructing need varRef')
      }
      %vars[i]% := v
    }
  } else if IsObject(target) {
    for i, v in vars {
      if not IsVarRef(vars[i]) {
        throw TypeError('object deconstructing need varRef')
      }
      key := %vars[i]%
      %vars[i]% := target.%key%
    }
  } else if IsPrimitive(target) {
    if not IsVarRef(vars[1]) {
      throw TypeError('primitive deconstructing need varRef')
    }
    %vars[1]% := target
  } else throw TypeError('target error')
}
DCon(params*) => Deconstruction(params*)
IfOrElse(condition, trueAction, falsyAction) => condition ? trueAction() : falsyAction()
Lambda(name, params*) => (*) => name(params*)
SurroundWith(str, chars) => chars str chars
IsSurroundWith(str, chars) => !chars || str.substring(1, chars.Length + 1) = chars && str.substring(str.Length - chars.Length + 1) = chars
T_(s, e := [], c := '\') => e.concat(['`vv', '`ff', '`bb', '`nn', '`rr', '`tt']).reduce((r, v) => r.replace(v[1], c v[2]), s)
ToString(o, q := false, esc := false, expandLevel := unset, space := '  ') {
  expandLevel := IsSet(expandLevel) ? Abs(expandlevel) : 10000000
  if IsPrimitive(o)
    return o
  return Trim(_convert(o, expandLevel))
  _convert(o, el := 0, l := 0, _ := '') {
    static cb := '{}', sb := '[]', nc := '`n', cc := ',', sc := ':'
    if IsArray(o) {
      s := !l ? '[' : ''
      for k, v in o {
        b := IsArray(v) ? sb : (IsMap(v) or IsObject(v)) ? cb : '', r := !IsPrimitive(v) && !IsEmpty(v)
        s .= (el > l ? nc _getIndent(l + 2) : '') (b ? (b[1] (r ? _convert(v, el, l + 1, b) : '') b[2]) : _escape(v))
          . (IsArray(o) && o.Length = A_Index ? '' : cc)
      }
    } else {
      s := !l ? '{' : ''
      for k, v in o.OwnProps() {
        b := IsArray(v) ? sb : (IsMap(v) or IsObject(v)) ? cb : '', r := !IsPrimitive(v) && !IsEmpty(v)
        s .= (el > l ? nc _getIndent(l + 2) : '') (_ = sb && A_Index = 1 ? cb : '') _escape(k) sc
          . (b ? (b[1] (r ? _convert(v, el, l + 1, b) : '') b[2]) : _escape(v)) (_ = sb && A_Index = o.Count ? '}' : '')
          . (el != 0 || l ? (A_Index = O.count ? '' : cc) : '')
        if el = 0 and !l
          s .= (A_Index < o.Count ? cc : '')
      }
    }
    if el > l
      s .= nc _getIndent(l + 1)
    return !l ? RegExReplace(s, '^\R+') (IsArray(o) ? ']' : '}') : s
  }
  _escape(_s) {
    if !esc
      return q ? IsString(_s) ? ('"' _s '"') : _s : _s
    switch {
      case IsFloat(_s):
        if (_v := '', _d := InStr(_s, 'e'))
          _v := SubStr(_s, _d), _s := SubStr(_s, 1, _d - 1)
        if ((StrLen(_s) > 17) && (_d := RegExMatch(_s, "(99999+|00000+)\d{0,3}$")))
          _s := Round(_s, Max(1, _d - InStr(_s, ".") - 1))
        return _s _v
      case IsInteger(_s): return _s
      case IsString(_s): return q ? '"' T_(_s, ['\\', '""']) '"' : T_(_s, ['\\', '""'])
      default: return _s
    }
  }
  _getIndent(_l) => space.repeat(_l - 1)
}
IsHan(char) => (_c := '0x' Ord(char).toBase(16)) >= 0x4e00 && _c <= 0x9fff
MToString(o) => MsgBox(ToString(o))
MTToString(o) => MsgBox(T_(ToString(o)))
Assert(express, expect) {
  if express != expect
    throw Error('Assertion Error: The expect value is not ' expect)
}
