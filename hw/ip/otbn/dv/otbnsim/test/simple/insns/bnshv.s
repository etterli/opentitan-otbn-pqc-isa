/* Copyright lowRISC contributors (OpenTitan project). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.section .text.start
/*
  Testing all 4x8 cases requires 32 WDRs.
  Each shift is performed in place.
*/

addi x2, x0, 0

/* 16bit left */
la     x3, vec16orig
bn.lid x2++, 0(x3)
bn.shv.16H w0, w0 << 0
bn.lid x2++, 0(x3)
bn.shv.16H w1, w1 << 2
bn.lid x2++, 0(x3)
bn.shv.16H w2, w2 << 9
bn.lid x2++, 0(x3)
bn.shv.16H w3, w3 << 15

/* 16bit right */
bn.lid x2++, 0(x3)
bn.shv.16H w4, w4 >> 0
bn.lid x2++, 0(x3)
bn.shv.16H w5, w5 >> 2
bn.lid x2++, 0(x3)
bn.shv.16H w6, w6 >> 9
bn.lid x2++, 0(x3)
bn.shv.16H w7, w7 >> 14

/* 32bit left */
la     x3, vec32orig
bn.lid x2++, 0(x3)
bn.shv.8S w8, w8 << 11
bn.lid x2++, 0(x3)
bn.shv.8S w9, w9 << 22
bn.lid x2++, 0(x3)
bn.shv.8S w10, w10 << 3
bn.lid x2++, 0(x3)
bn.shv.8S w11, w11 << 19
bn.lid x2++, 0(x3)
/* 32bit right */
bn.shv.8S w12, w12 >> 5
bn.lid x2++, 0(x3)
bn.shv.8S w13, w13 >> 30
bn.lid x2++, 0(x3)
bn.shv.8S w14, w14 >> 3
bn.lid x2++, 0(x3)
bn.shv.8S w15, w15 >> 16


/* 64bit left */
la     x3, vec64orig
bn.lid x2++, 0(x3)
bn.shv.4D w16, w16 << 44
bn.lid x2++, 0(x3)
bn.shv.4D w17, w17 << 22
bn.lid x2++, 0(x3)
bn.shv.4D w18, w18 << 3
bn.lid x2++, 0(x3)
bn.shv.4D w19, w19 << 19
/* 64bit right */
bn.lid x2++, 0(x3)
bn.shv.4D w20, w20 >> 56
bn.lid x2++, 0(x3)
bn.shv.4D w21, w21 >> 35
bn.lid x2++, 0(x3)
bn.shv.4D w22, w22 >> 3
bn.lid x2++, 0(x3)
bn.shv.4D w23, w23 >> 16

/* 128bit left */
la     x3, vec64orig
bn.lid x2++, 0(x3)
bn.shv.2Q w24, w24 << 67
bn.lid x2++, 0(x3)
bn.shv.2Q w25, w25 << 22
bn.lid x2++, 0(x3)
bn.shv.2Q w26, w26 << 12
bn.lid x2++, 0(x3)
bn.shv.2Q w27, w27 << 111
/* 128bit right */
bn.lid x2++, 0(x3)
bn.shv.2Q w28, w28 >> 120
bn.lid x2++, 0(x3)
bn.shv.2Q w29, w29 >> 35
bn.lid x2++, 0(x3)
bn.shv.2Q w30, w30 >> 5
bn.lid x2++, 0(x3)
bn.shv.2Q w31, w31 >> 55


ecall

.section .data
/*
  16bit vector vec16orig for instruction shv
  vec16orig = n/a
  vec16orig = 0x9397271b502c41d6cf2538cfa72bf6800d250f06252fff02a626711a3a60e2eb
*/
vec16orig:
  .word 0x3a60e2eb
  .word 0xa626711a
  .word 0x252fff02
  .word 0x0d250f06
  .word 0xa72bf680
  .word 0xcf2538cf
  .word 0x502c41d6
  .word 0x9397271b

/*
  Result of 16bit shv left (res = [bitshift in decimals])
  res = [0]
  res = 0x9397271b502c41d6cf2538cfa72bf6800d250f06252fff02a626711a3a60e2eb
*/

/*
  Result of 16bit shv left (res = [bitshift in decimals])
  res = [2]
  res = 0x4e5c9c6c40b007583c94e33c9cacda0034943c1894bcfc089898c468e9808bac
*/

/*
  Result of 16bit shv left (res = [bitshift in decimals])
  res = [9]
  res = 0x2e0036005800ac004a009e00560000004a000c005e0004004c003400c000d600
*/

/*
  Result of 16bit shv left (res = [bitshift in decimals])
  res = [15]
  res = 0x8000800000000000800080008000000080000000800000000000000000008000
*/

/*
  Result of 16bit shv right (res = [bitshift in decimals])
  res = [0]
  res = 0x9397271b502c41d6cf2538cfa72bf6800d250f06252fff02a626711a3a60e2eb
*/

/*
  Result of 16bit shv right (res = [bitshift in decimals])
  res = [2]
  res = 0x24e509c6140b107533c90e3329ca3da0034903c1094b3fc029891c460e9838ba
*/

/*
  Result of 16bit shv right (res = [bitshift in decimals])
  res = [9]
  res = 0x00490013002800200067001c0053007b000600070012007f00530038001d0071
*/

/*
  Result of 16bit shv right (res = [bitshift in decimals])
  res = [14]
  res = 0x0002000000010001000300000002000300000000000000030002000100000003
*/

/*
  32bit vector vec32orig for instruction shv
  vec32orig = n/a
  vec32orig = 0x9397271b502c41d6cf2538cfa72bf6800d250f06252fff02a626711a3a60e2eb
*/
vec32orig:
  .word 0x3a60e2eb
  .word 0xa626711a
  .word 0x252fff02
  .word 0x0d250f06
  .word 0xa72bf680
  .word 0xcf2538cf
  .word 0x502c41d6
  .word 0x9397271b

/*
  Result of 32bit shv left (res = [bitshift in decimals])
  res = [11]
  res = 0xb938d800620eb00029c678005fb40000287830007ff810003388d00007175800
*/

/*
  Result of 32bit shv left (res = [bitshift in decimals])
  res = [22]
  res = 0xc6c000007580000033c00000a0000000c1800000c080000046800000bac00000
*/

/*
  Result of 32bit shv left (res = [bitshift in decimals])
  res = [3]
  res = 0x9cb938d881620eb07929c678395fb40069287830297ff810313388d0d3071758
*/

/*
  Result of 32bit shv left (res = [bitshift in decimals])
  res = [19]
  res = 0x38d800000eb00000c6780000b400000078300000f810000088d0000017580000
*/

/*
  Result of 32bit shv right (res = [bitshift in decimals])
  res = [5]
  res = 0x049cb9380281620e067929c605395fb40069287801297ff80531338801d30717
*/

/*
  Result of 32bit shv right (res = [bitshift in decimals])
  res = [30]
  res = 0x0000000200000001000000030000000200000000000000000000000200000000
*/

/*
  Result of 32bit shv right (res = [bitshift in decimals])
  res = [3]
  res = 0x1272e4e30a05883a19e4a71914e57ed001a4a1e004a5ffe014c4ce23074c1c5d
*/

/*
  Result of 32bit shv right (res = [bitshift in decimals])
  res = [16]
  res = 0x000093970000502c0000cf250000a72b00000d250000252f0000a62600003a60
*/

/*
  64bit vector vec64orig for instruction shv
  vec64orig = n/a
  vec64orig = 0x9397271b502c41d6cf2538cfa72bf6800d250f06252fff02a626711a3a60e2eb
*/
vec64orig:
  .word 0x3a60e2eb
  .word 0xa626711a
  .word 0x252fff02
  .word 0x0d250f06
  .word 0xa72bf680
  .word 0xcf2538cf
  .word 0x502c41d6
  .word 0x9397271b

/*
  Result of 64bit shv left (res = [bitshift in decimals])
  res = [44]
  res = 0xc41d600000000000bf68000000000000fff02000000000000e2eb00000000000
*/

/*
  Result of 64bit shv left (res = [bitshift in decimals])
  res = [22]
  res = 0xc6d40b107580000033e9cafda0000000c1894bffc0800000468e9838bac00000
*/

/*
  Result of 64bit shv left (res = [bitshift in decimals])
  res = [3]
  res = 0x9cb938da81620eb07929c67d395fb40069287831297ff810313388d1d3071758
*/

/*
  Result of 64bit shv left (res = [bitshift in decimals])
  res = [19]
  res = 0x38da81620eb00000c67d395fb40000007831297ff810000088d1d30717580000
*/

/*
  Result of 64bit shv right (res = [bitshift in decimals])
  res = [56]
  res = 0x000000000000009300000000000000cf000000000000000d00000000000000a6
*/

/*
  Result of 64bit shv right (res = [bitshift in decimals])
  res = [35]
  res = 0x000000001272e4e30000000019e4a7190000000001a4a1e00000000014c4ce23
*/

/*
  Result of 64bit shv right (res = [bitshift in decimals])
  res = [3]
  res = 0x1272e4e36a05883a19e4a719f4e57ed001a4a1e0c4a5ffe014c4ce23474c1c5d
*/

/*
  Result of 64bit shv right (res = [bitshift in decimals])
  res = [16]
  res = 0x00009397271b502c0000cf2538cfa72b00000d250f06252f0000a626711a3a60
*/

/*
  128bit vector vec128orig for instruction shv
  vec128orig = n/a
  vec128orig = 0x9397271b502c41d6cf2538cfa72bf6800d250f06252fff02a626711a3a60e2eb
*/
vec128orig:
  .word 0x3a60e2eb
  .word 0xa626711a
  .word 0x252fff02
  .word 0x0d250f06
  .word 0xa72bf680
  .word 0xcf2538cf
  .word 0x502c41d6
  .word 0x9397271b

/*
  Result of 128bit shv left (res = [bitshift in decimals])
  res = [67]
  res = 0x7929c67d395fb4000000000000000000313388d1d30717580000000000000000
*/

/*
  Result of 128bit shv left (res = [bitshift in decimals])
  res = [22]
  res = 0xc6d40b1075b3c94e33e9cafda0000000c1894bffc0a9899c468e9838bac00000
*/

/*
  Result of 128bit shv left (res = [bitshift in decimals])
  res = [12]
  res = 0x7271b502c41d6cf2538cfa72bf68000050f06252fff02a626711a3a60e2eb000
*/

/*
  Result of 128bit shv left (res = [bitshift in decimals])
  res = [111]
  res = 0xfb40000000000000000000000000000071758000000000000000000000000000
*/

/*
  Result of 128bit shv right (res = [bitshift in decimals])
  res = [120]
  res = 0x000000000000000000000000000000930000000000000000000000000000000d
*/

/*
  Result of 128bit shv right (res = [bitshift in decimals])
  res = [35]
  res = 0x000000001272e4e36a05883ad9e4a7190000000001a4a1e0c4a5ffe054c4ce23
*/

/*
  Result of 128bit shv right (res = [bitshift in decimals])
  res = [5]
  res = 0x049cb938da81620eb67929c67d395fb40069287831297ff815313388d1d30717
*/

/*
  Result of 128bit shv right (res = [bitshift in decimals])
  res = [55]
  res = 0x00000000000001272e4e36a05883ad9e000000000000001a4a1e0c4a5ffe054c
*/
