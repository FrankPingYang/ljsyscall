-- define system calls for ffi, OSX specific calls

local require, print, error, assert, tonumber, tostring,
setmetatable, pairs, ipairs, unpack, rawget, rawset,
pcall, type, table, string, math = 
require, print, error, assert, tonumber, tostring,
setmetatable, pairs, ipairs, unpack, rawget, rawset,
pcall, type, table, string, math

local cdef = require "ffi".cdef

cdef[[
int lchmod(const char *path, mode_t mode);
int fchroot(int fd);
int utimes(const char *filename, const struct timeval times[2]);
int getdirentries(int fd, char *buf, int nbytes, long *basep);
int futimes(int, const struct timeval *);

/* might just use syscalls */
int stat64(const char *path, struct stat *sb);
int lstat64(const char *path, struct stat *sb);
int fstat64(int fd, struct stat *sb);

int syscall(int number, ...);
]]

