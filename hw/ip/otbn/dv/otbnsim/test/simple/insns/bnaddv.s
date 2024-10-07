/* Copyright lowRISC contributors (OpenTitan project). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.section .text.start
/*
  Load the vectors into w0-w5
*/
addi x2, x0, 0

/* is pseudo op combined of 2 instr -> +2 INSN_CNT */
la     x3, vec16a
bn.lid x2++, 0(x3)
la     x3, vec16b
bn.lid x2++, 0(x3)

la     x3, vec32a
bn.lid x2++, 0(x3)
la     x3, vec32b
bn.lid x2++, 0(x3)

la     x3, vec64a
bn.lid x2++, 0(x3)
la     x3, vec64b
bn.lid x2++, 0(x3)

la     x3, vec128a
bn.lid x2++, 0(x3)
la     x3, vec128b
bn.lid x2++, 0(x3)


addi x3, x0, 0 /* reset x3*/

/*
  check that all datatypes work as expected
  16bit  .16H
  32bit  .8S
  Further datatypes forseen for future. Not implemented in HW
  64bit  .4D
  128bit .2Q
*/

bn.addv.16H w10, w0, w1
bn.addv.8S  w11, w2, w3
bn.addv.4D  w12, w4, w5
bn.addv.2Q  w13, w6, w7

ecall

.section .data

/*
  16bit vector vec16a for instruction addv
  vec16a = [-32768 -32768  32767  32767  32767 -32768  32767 -32768 -32768 -32768
  32767  32767  32767 -32768 -32768  32767]
  vec16a = 0x800080007fff7fff7fff80007fff8000800080007fff7fff7fff800080007fff
*/
vec16a:
  .word 0x80007fff
  .word 0x7fff8000
  .word 0x7fff7fff
  .word 0x80008000
  .word 0x7fff8000
  .word 0x7fff8000
  .word 0x7fff7fff
  .word 0x80008000

/*
  16bit vector vec16b for instruction addv
  vec16b = [  16  -16    1  -16    6  -16  564 -546  -32   -1   32    1    1   -1
   -1    1]
  vec16b = 0x0010fff00001fff00006fff00234fddeffe0ffff002000010001ffffffff0001
*/
vec16b:
  .word 0xffff0001
  .word 0x0001ffff
  .word 0x00200001
  .word 0xffe0ffff
  .word 0x0234fdde
  .word 0x0006fff0
  .word 0x0001fff0
  .word 0x0010fff0

/*
  Result of 16bit addv
  res = [-32752, 32752, -32768, 32751, -32763, 32752, -32205, 32222, 32736, 32767, -32737, -32768, -32768, 32767, 32767, -32768]
  res = 0x80107ff080007fef80057ff082337dde7fe07fff801f800080007fff7fff8000
*/

/*
  32bit vector vec32a for instruction addv
  vec32a = [-2147483648 -2147483648  2147483647  2147483647  2147483647 -2147483648
 -2147483648  2147483647]
  vec32a = 0x80000000800000007fffffff7fffffff7fffffff80000000800000007fffffff
*/
vec32a:
  .word 0x7fffffff
  .word 0x80000000
  .word 0x80000000
  .word 0x7fffffff
  .word 0x7fffffff
  .word 0x7fffffff
  .word 0x80000000
  .word 0x80000000

/*
  32bit vector vec32b for instruction addv
  vec32b = [-32  -1  32   1   1  -1  -1   1]
  vec32b = 0xffffffe0ffffffff000000200000000100000001ffffffffffffffff00000001
*/
vec32b:
  .word 0x00000001
  .word 0xffffffff
  .word 0xffffffff
  .word 0x00000001
  .word 0x00000001
  .word 0x00000020
  .word 0xffffffff
  .word 0xffffffe0

/*
  Result of 32bit addv
  res = [2147483616, 2147483647, -2147483617, -2147483648, -2147483648, 2147483647, 2147483647, -2147483648]
  res = 0x7fffffe07fffffff8000001f80000000800000007fffffff7fffffff80000000
*/

/*
  64bit vector vec64a for instruction addv
  vec64a = [ 9223372036854775807 -9223372036854775808 -9223372036854775808
  9223372036854775807]
  vec64a = 0x7fffffffffffffff800000000000000080000000000000007fffffffffffffff
*/
vec64a:
  .word 0xffffffff
  .word 0x7fffffff
  .word 0x00000000
  .word 0x80000000
  .word 0x00000000
  .word 0x80000000
  .word 0xffffffff
  .word 0x7fffffff

/*
  64bit vector vec64b for instruction addv
  vec64b = [ 1 -1 -1  1]
  vec64b = 0x0000000000000001ffffffffffffffffffffffffffffffff0000000000000001
*/
vec64b:
  .word 0x00000001
  .word 0x00000000
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff
  .word 0x00000001
  .word 0x00000000

/*
  Result of 64bit addv
  res = [-9223372036854775808, 9223372036854775807, 9223372036854775807, -9223372036854775808]
  res = 0x80000000000000007fffffffffffffff7fffffffffffffff8000000000000000
*/

/*
  128bit vector vec128a for instruction addv
  vec128a = [-170141183460469231731687303715884105728
 170141183460469231731687303715884105727]
  vec128a = 0x800000000000000000000000000000007fffffffffffffffffffffffffffffff
*/
vec128a:
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff
  .word 0x7fffffff
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x80000000

/*
  128bit vector vec128b for instruction addv
  vec128b = [-1  1]
  vec128b = 0xffffffffffffffffffffffffffffffff00000000000000000000000000000001
*/
vec128b:
  .word 0x00000001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff

/*
  Result of 128bit addv
  res = [170141183460469231731687303715884105727, -170141183460469231731687303715884105728]
  res = 0x7fffffffffffffffffffffffffffffff80000000000000000000000000000000
*/
