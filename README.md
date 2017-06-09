# DbgKaleidoscopeOrcJit

Minimal changes on LLVM [Kaleidoscope example (Chapter 9)](http://llvm.org/docs/tutorial/LangImpl09.html) to enable source level debugging of JITed code.
See [commits page](https://github.com/weliveindetail/DbgKaleidoscopeOrcJit/commits/master) for step-by-step changes.

![Demo debug process](https://raw.githubusercontent.com/weliveindetail/DbgKaleidoscopeOrcJit/master/auto-spawn-lldb-demo-session.gif)

Well nobody said LLDB is fast in attaching. This was recorded from branch [`auto-spawn-lldb`](https://github.com/weliveindetail/DbgKaleidoscopeOrcJit/tree/auto-spawn-lldb).

The following terminal log shows the whole process from checkout to execution from `master`.
You probably have to adjust `cmake_gen_linux.sh` as shown below.
I use Linux Mint 18 with CMake 3.5, Clang 3.8 stable to compile C++ and LLVM Release 4.0 to build the project against.

```
~/Develop $ git clone https://github.com/weliveindetail/DbgKaleidoscopeOrcJit.git kaleidodbg
Cloning into 'kaleidodbg'...
remote: Counting objects: 26, done.
remote: Compressing objects: 100% (12/12), done.
remote: Total 26 (delta 13), reused 26 (delta 13), pack-reused 0
Unpacking objects: 100% (26/26), done.
Checking connectivity... done.

~/Develop $ cd kaleidodbg
~/Develop/kaleidodbg $ ls
cmake_gen_linux.sh  fib.ks  src

~/Develop/kaleidodbg $ cat cmake_gen_linux.sh 
# CC, CCX and LLVM_DIR may need adjustments
export CC=clang-3.8 
export CXX=clang++-3.8

if [ ! -d "build" ]; then
    mkdir build
fi

cd build
cmake -DCMAKE_BUILD_TYPE=Debug -DLLVM_DIR=/media/LLVM/build-llvm40-clang-lldb/lib/cmake/llvm ../src

~/Develop/kaleidodbg $ ./cmake_gen_linux.sh 
...
-- Build files have been written to: ~/Develop/kaleidodbg/build

~/Develop/kaleidodbg $ cd build/
~/Develop/kaleidodbg/build $ cmake --build .
Scanning dependencies of target kaleidodbg
[ 50%] Building CXX object CMakeFiles/kaleidodbg.dir/toy.cpp.o
[100%] Linking CXX executable kaleidodbg
[100%] Built target kaleidodbg

~/Develop/kaleidodbg/build $ lldb-4.0 -- ./kaleidodbg
(lldb) target create "./kaleidodbg"
Current executable set to './kaleidodbg' (x86_64).
(lldb) log enable lldb jit
(lldb) b fib.ks:7
Breakpoint 1: no locations (pending).
WARNING:  Unable to resolve breakpoint to any actual locations.
(lldb) process launch -i ../fib.ks
JITLoaderGDB::SetJITBreakpoint looking for JIT register hook
JITLoaderGDB::SetJITBreakpoint setting JIT breakpoint
Process 4306 launched: './kaleidodbg' (x86_64)
JITLoaderGDB::JITDebugBreakpointHit hit JIT breakpoint
JITLoaderGDB::ReadJITDescriptorImpl registering JIT entry at 0x2c3fc30 (3240 bytes)
1 location added to breakpoint 1
Process 4306 stopped
* thread #1, name = 'kaleidodbg', stop reason = breakpoint 1.1
    frame #0: JIT(0x2c3fc30)`main at fib.ks:7
   4   	  else
   5   	    fib(x-1)+fib(x-2);
   6
-> 7   	fib(10)
(lldb) b fib.ks:5
Breakpoint 2: where = JIT(0x2c3fc30)`fib + 56 at fib.ks:5, address = 0x00007ffff7ff5038
(lldb) continue
Process 4306 resuming
Process 4306 stopped
* thread #1, name = 'kaleidodbg', stop reason = breakpoint 2.1
    frame #0: JIT(0x2c3fc30)`fib(x=10) at fib.ks:5
   2   	  if x < 3 then
   3   	    1
   4   	  else
-> 5   	    fib(x-1)+fib(x-2);
   6
   7   	fib(10)
(lldb) s
Process 4306 stopped
* thread #1, name = 'kaleidodbg', stop reason = step in
    frame #0: JIT(0x2c3fc30)`fib(x=9) at fib.ks:2
   1   	def fib(x)
-> 2   	  if x < 3 then
   3   	    1
   4   	  else
   5   	    fib(x-1)+fib(x-2);
   6
   7   	fib(10)
(lldb) s
Process 4306 stopped
* thread #1, name = 'kaleidodbg', stop reason = breakpoint 2.1
    frame #0: JIT(0x2c3fc30)`fib(x=9) at fib.ks:5
   2   	  if x < 3 then
   3   	    1
   4   	  else
-> 5   	    fib(x-1)+fib(x-2);
   6
   7   	fib(10)
(lldb) s
Process 4306 stopped
* thread #1, name = 'kaleidodbg', stop reason = step in
    frame #0: JIT(0x2c3fc30)`fib(x=8) at fib.ks:2
   1   	def fib(x)
-> 2   	  if x < 3 then
   3   	    1
   4   	  else
   5   	    fib(x-1)+fib(x-2);
   6
   7   	fib(10)
(lldb) bt
* thread #1, name = 'kaleidodbg', stop reason = step in
  * frame #0: JIT(0x2c3fc30)`fib(x=8) at fib.ks:2
    frame #1: JIT(0x2c3fc30)`fib(x=9) at fib.ks:5
    frame #2: JIT(0x2c3fc30)`fib(x=10) at fib.ks:5
    frame #3: JIT(0x2c3fc30)`main at fib.ks:7
    frame #4: kaleidodbg`main at toy.cpp:1541
    frame #5: libc.so.6`__libc_start_main(main=(kaleidodbg`main at toy.cpp:1485), argc=1, argv=0x00007fffffffdfa8, init=<unavailable>, fini=<unavailable>, rtld_fini=<unavailable>, stack_end=0x00007fffffffdf98) at libc-start.c:291
    frame #6: 0x0000000000797ea9 kaleidodbg`_start + 41
(lldb) continue
Process 4306 resuming
Evaluated to 55
Process 4306 exited with status = 0 (0x00000000)
(lldb) quit
```
