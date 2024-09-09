#Requires AutoHotkey v2.0

#Include Extend_Merged.ahk

class Path {
  static delimiter := '\'

  __New(_path) => Path.Parse(_path)

  static Parse(_path) {
    if !Path or !IsString(_path)
      throw TypeError('Path must be a string.')
    _path := Path.Normalize(_path)
    SplitPath(_path, &name, &dir, &ext, &nameNoExt, &root)
    return { fullPath: _path, name: name, dir: dir, ext: ext, nameNoExt: nameNoExt, root: root }
  }

  static Basename(_path, ext := unset) {
    ext := ext ?? '', bn := Path.Parse(_path).name
    if (el := ext.Length) > (bl := bn.Length)
      throw Error('extension error')
    return ext ? bn.substring(bl - el + 1) == ext ? bn.substring(1, bl - el + 1) : bn : bn
  }

  static Dir(_path) => Path.Parse(_path).dir

  static Normalize(_path) {
    if !_path or !IsString(_path)
      throw TypeError('Path must be a string.')
    _path := StrReplace(_path, Path.delimiter = '\' ? '/' : '\', Path.delimiter)
    stack := [], segs := _path.Split(Path.delimiter)
    for v in segs {
      if stack.Length && stack.peek() != '..' && '..' == v
        stack.Pop()
      else if '.' != v && '' != v
        stack.Push(v)
    }
    return _path ~= '^[\\/]' ? Path.delimiter stack.Join(Path.delimiter) : stack.Join(Path.delimiter)
  }

  static IsStandard(_path) {
    if !_path or !IsString(_path)
      return false
    return InStr(_path, Path.delimiter '.') or InStr(_path, Path.delimiter '..')
  }

  static IsAbsolute(_path) {
    if !_path or !IsString(_path)
      return false
    return _path ~= '^(?:\w:)?[\\/]' || _path ~= '^\w:'
  }

  static Join(params*) {
    if !params.Length
      return
    for s in params {
      if IsString(s)
        _path .= Path.delimiter s
      else throw TypeError('Path must be a string. Received ' s)
    }
    stack := [], segs := Path.Normalize(_path).Split(Path.delimiter)
    for v in segs {
      if stack.Length && '..' == v
        stack.Pop()
      else if '.' != v && '' != v
        stack.Push(v)
    }
    return stack.Join(Path.delimiter)
  }

  static Format(pathObj) {
    if pathObj.HasProp('dir')
      _path .= pathObj.dir
    else if pathObj.HasProp('root')
      _path .= pathObj.root
    if pathObj.HasProp('basename')
      _path .= Path.delimiter pathObj.basename
    else if pathObj.HasProp('name') {
      _path .= Path.delimiter pathObj.name
      if pathObj.HasProp('ext') && pathObj.ext != 'ignore'
        _path .= pathObj.ext
    }
    return Path.Normalize(_path)
  }

  static Relative(from, to) {
    if !IsString(from) or !IsString(to)
      throw TypeError('Path must be a string.')
    from := from || A_ScriptFullPath, to := to || A_ScriptFullPath
    from := Path.Normalize(from), to := Path.Normalize(to)
    if from = to
      return ''
    if Path.IsAbsolute(to) and !Path.IsAbsolute(from)
      return to
    res := [], froms := from.Split(Path.delimiter), tos := to.Split(Path.delimiter)
    i := j := 1
    while i <= froms.Length && j <= tos.Length {
      if froms[i] != tos[j]
        break
      i++, j++
    }
    loop froms.Length - i + 1
      res.Push('..')
    loop tos.Length - j + 1
      res.Push(tos[j + A_Index - 1])
    return res.Join(Path.delimiter)
  }

  static Resolve(params*) {
    for param in params {
      if !param or !IsString(param)
        continue
      if Path.IsAbsolute(param)
        _ := ''
      _ .= param Path.delimiter
    }
    return Path.IsAbsolute(_ := Path.Normalize(_)) ? _ : Path.Join(A_ScriptDir, _)
  }
}