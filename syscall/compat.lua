-- Compatibility wrappers to add more commonality between different systems, plus define common functions from man(3)

local function init(S) 

local abi, types, c = S.abi, S.types, S.c
local t, pt, s = types.t, types.pt, types.s

local ffi = require "ffi"

if abi.os == "linux" then S = require "syscall.linux.compat".init(S) end

local function mktype(tp, x) if ffi.istype(tp, x) then return x else return tp(x) end end

function S.creat(pathname, mode) return S.open(pathname, "CREAT,WRONLY,TRUNC", mode) end

function S.nice(inc)
  local prio = S.getpriority("process", 0) -- this cannot fail with these args.
  local ok, err = S.setpriority("process", 0, prio + inc)
  if not ok then return nil, err end
  return S.getpriority("process", 0)
end

-- deprecated in NetBSD and not in some archs for Linux, implement with recvfrom
function S.recv(fd, buf, count, flags) return S.recvfrom(fd, buf, count or #buf, c.MSG[flags], nil, nil) end

-- not a syscall in many systems, defined in terms of sigaction
function S.signal(signum, handler) -- defined in terms of sigaction
  local oldact = t.sigaction()
  local ok, err = S.sigaction(signum, handler, oldact)
  if not ok then return nil, err end
  return oldact.sa_handler
end

if not S.pause then -- NetBSD and OSX deprecate pause
  function S.pause() return S.sigsuspend(t.sigset()) end
end

-- non standard names
if not S.umount then S.umount = S.unmount end
if not S.unmount then S.unmount = S.umount end

if S.getdirentries and not S.getdents then -- eg OSX has extra arg
  function S.getdents(fd, buf, len)
    return S.getdirentries(fd, buf, len, nil)
  end
end

-- TODO we should allow utimbuf and also table of times really; this is the very old 1s precesion version, NB Linux has syscall
if not S.utime then
  function S.utime(path, actime, modtime)
    local tv
    modtime = modtime or actime
    if actime and modtime then tv = {actime, modtime} end
    return S.utimes(path, tv)
  end
end

-- the utimes, futimes, lutimes are legacy, but OSX does not support the nanosecond versions; we support both
S.futimes = S.futimes or S.futimens

if S.utimensat and not S.lutimes then
  function S.lutimes(filename, times)
    return S.utimensat("FDCWD", filename, times, "SYMLINK_NOFOLLOW")
  end
end

-- OSX does not support nanosecond times, emulate to less precision; note we auto convert timeval, timespec anyway
S.futimens = S.futimens or S.futimes

-- common libc function
function S.sleep(sec)
  local rem, err = S.nanosleep(sec)
  if not rem then return nil, err end
  if rem == true then return 0 end
  return tonumber(rem.tv_sec)
end

return S

end

return {init = init}

