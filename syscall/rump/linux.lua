-- If using Linux ABI compatibility we need a few extra types from NetBSD
-- TODO In theory we should not need these, just create a new NetBSD rump instance when we want them instead
-- currently just mount support

local require, error, assert, tonumber, tostring,
setmetatable, pairs, ipairs, unpack, rawget, rawset,
pcall, type, table, string = 
require, error, assert, tonumber, tostring,
setmetatable, pairs, ipairs, unpack, rawget, rawset,
pcall, type, table, string

local function init(types, c)

local ffi = require "ffi"

ffi.cdef [[
typedef uint32_t _netbsd_mode_t;
typedef uint64_t _netbsd_ino_t;
struct _netbsd_ufs_args {
  char *fspec;
};
struct _netbsd_tmpfs_args {
  int ta_version;
  _netbsd_ino_t ta_nodes_max;
  off_t ta_size_max;
  uid_t ta_root_uid;
  gid_t ta_root_gid;
  _netbsd_mode_t ta_root_mode;
};
struct _netbsd_ptyfs_args {
  int version;
  gid_t gid;
  _netbsd_mode_t mode;
  int flags;
};
]]

local h = require "syscall.helpers"

local addtype = h.addtype

local addstructs = {
  ufs_args = "struct _netbsd_ufs_args",
  tmpfs_args = "struct _netbsd_tmpfs_args",
  ptyfs_args = "struct _netbsd_ptyfs_args",
}

for k, v in pairs(addstructs) do addtype(types, k, v, {}) end

return types

end

return {init = init}

