#pragma once
#include <cstdint>

//
// NB: "extern C" to avoid procedure name mangling by compiler
//
extern "C" int _cdecl factorial(int);
extern "C" int _cdecl poly(int);
extern "C" void _cdecl multiple_k_asm(uint16_t, uint16_t, uint16_t, uint16_t array[]);


// eof
