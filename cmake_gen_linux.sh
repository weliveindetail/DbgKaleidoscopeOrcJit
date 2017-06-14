export CC=clang-3.8
export CXX=clang++-3.8

if [ ! -d "build" ]; then
    mkdir build
fi

cd build
cmake -DCMAKE_BUILD_TYPE=Debug -DLLVM_DIR=/media/LLVM/build-llvm40-clang-lldb/lib/cmake/llvm ..
