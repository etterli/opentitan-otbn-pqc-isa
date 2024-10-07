/* Copyright lowRISC contributors (OpenTitan project). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.section .text.start
/*
  Testing each lane results in 30 results.
  Thus only load one size vector pair at a time into w0 and w1
  MOD is loaded via w0 before loading the vectors
  Results are ordered (increasing lane):
  16b:  w2 to w17
  32b:  w18 to w25
  64b:  w26 to w29
  128b: w30 and w31
*/

/* load the modulus into w0 and then into MOD*/
/* MOD <= dmem[modulus] = p */
addi x2, x0, 0
li           x2, 0
la           x3, mod16
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w0

addi x2, x0, 0
la     x3, vec16a
bn.lid x2++, 0(x3)
la     x3, vec16b
bn.lid x2++, 0(x3)

bn.mulvml.16H  w2, w0, w1, 0
bn.mulvml.16H  w3, w0, w1, 1
bn.mulvml.16H  w4, w0, w1, 2
bn.mulvml.16H  w5, w0, w1, 3
bn.mulvml.16H  w6, w0, w1, 4
bn.mulvml.16H  w7, w0, w1, 5
bn.mulvml.16H  w8, w0, w1, 6
bn.mulvml.16H  w9, w0, w1, 7
bn.mulvml.16H w10, w0, w1, 8
bn.mulvml.16H w11, w0, w1, 9
bn.mulvml.16H w12, w0, w1, 10
bn.mulvml.16H w13, w0, w1, 11
bn.mulvml.16H w14, w0, w1, 12
bn.mulvml.16H w15, w0, w1, 13
bn.mulvml.16H w16, w0, w1, 14
bn.mulvml.16H w17, w0, w1, 15

/* 32bit */
addi x2, x0, 0
la           x3, mod32
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w0

addi x2, x0, 0
la     x3, vec32a
bn.lid x2++, 0(x3)
la     x3, vec32b
bn.lid x2++, 0(x3)
bn.mulvml.8S  w18, w0, w1, 0
bn.mulvml.8S  w19, w0, w1, 1
bn.mulvml.8S  w20, w0, w1, 2
bn.mulvml.8S  w21, w0, w1, 3
bn.mulvml.8S  w22, w0, w1, 4
bn.mulvml.8S  w23, w0, w1, 5
bn.mulvml.8S  w24, w0, w1, 6
bn.mulvml.8S  w25, w0, w1, 7

/* 64bit */
addi x2, x0, 0
la           x3, mod64
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w0

addi x2, x0, 0
la     x3, vec64a
bn.lid x2++, 0(x3)
la     x3, vec64b
bn.lid x2++, 0(x3)
bn.mulvml.4D  w26, w0, w1, 0
bn.mulvml.4D  w27, w0, w1, 1
bn.mulvml.4D  w28, w0, w1, 2
bn.mulvml.4D  w29, w0, w1, 3

/* 128bit */
addi x2, x0, 0
la           x3, mod128
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w0

addi x2, x0, 0
la     x3, vec128a
bn.lid x2++, 0(x3)
la     x3, vec128b
bn.lid x2++, 0(x3)
bn.mulvml.2Q  w30, w0, w1, 0
bn.mulvml.2Q  w31, w0, w1, 1


addi x2, x0, 0 /* reset x2*/
addi x3, x0, 0 /* reset x3*/

ecall

.section .data
/*
  16bit vector mod16 for instruction mulvml
  mod16 = [7583]
  mod16 = 0x0000000000000000000000000000000000000000000000000000000000001d9f
*/
mod16:
  .word 0x00001d9f
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  16bit vector vec16a for instruction mulvlm
  vec16a = [0, 1, 34, 58, 157, 23, 221, 159, 148, 62, 33, 129, 15, 158, 36, 137]
  vec16a = 0x000000010022003a009d001700dd009f0094003e00210081000f009e00240089
*/
vec16a:
  .word 0x00240089
  .word 0x000f009e
  .word 0x00210081
  .word 0x0094003e
  .word 0x00dd009f
  .word 0x009d0017
  .word 0x0022003a
  .word 0x00000001

/*
  16bit vector vec16b for instruction mulvlm
  vec16b = [63206, 58121, 923, 588, 208, 223, 204, 180, 10, 1, 100, 192, 42, 161, 92, 47]
  vec16b = 0xf6e6e309039b024c00d000df00cc00b4000a0001006400c0002a00a1005c002f
*/
vec16b:
  .word 0x005c002f
  .word 0x002a00a1
  .word 0x006400c0
  .word 0x000a0001
  .word 0x00cc00b4
  .word 0x00d000df
  .word 0x039b024c
  .word 0xf6e6e309

/*
  Result of 16bit mulvlm index 0
  res = [0, 47, 1598, 2726, 7379, 1081, 2804, 7473, 6956, 2914, 1551, 6063, 705, 7426, 1692, 6439]
  res = 0x0000002f063e0aa61cd304390af41d311b2c0b62060f17af02c11d02069c1927
*/

/*
  Result of 16bit mulvlm index 1
  res = [0, 92, 3128, 5336, 6861, 2116, 5166, 7045, 6033, 5704, 3036, 4285, 1380, 6953, 3312, 5021]
  res = 0x0000005c0c3814d81acd0844142e1b85179116480bdc10bd05641b290cf0139d
*/

/*
  Result of 16bit mulvlm index 2
  res = [0, 161, 5474, 1755, 2528, 3703, 5249, 2850, 1079, 2399, 5313, 5603, 2415, 2689, 5796, 6891]
  res = 0x000000a1156206db09e00e7714810b220437095f14c115e3096f0a8116a41aeb
*/

/*
  Result of 16bit mulvlm index 3
  res = [0, 42, 1428, 2436, 6594, 966, 1699, 6678, 6216, 2604, 1386, 5418, 630, 6636, 1512, 5754]
  res = 0x0000002a0594098419c203c606a31a1618480a2c056a152a027619ec05e8167a
*/

/*
  Result of 16bit mulvlm index 4
  res = [0, 192, 6528, 3553, 7395, 4416, 4517, 196, 5667, 4321, 6336, 2019, 2880, 4, 6912, 3555]
  res = 0x000000c019800de11ce3114011a500c4162310e118c007e30b4000041b000de3
*/

/*
  Result of 16bit mulvlm index 5
  res = [0, 100, 3400, 5800, 534, 2300, 6934, 734, 7217, 6200, 3300, 5317, 1500, 634, 3600, 6117]
  res = 0x000000640d4816a8021608fc1b1602de1c3118380ce414c505dc027a0e1017e5
*/

/*
  Result of 16bit mulvlm index 6
  res = [0, 1, 34, 58, 157, 23, 221, 159, 148, 62, 33, 129, 15, 158, 36, 137]
  res = 0x000000010022003a009d001700dd009f0094003e00210081000f009e00240089
*/

/*
  Result of 16bit mulvlm index 7
  res = [0, 10, 340, 580, 1570, 230, 2210, 1590, 1480, 620, 330, 1290, 150, 1580, 360, 1370]
  res = 0x0000000a01540244062200e608a2063605c8026c014a050a0096062c0168055a
*/

/*
  Result of 16bit mulvlm index 8
  res = [0, 180, 6120, 2857, 5511, 4140, 1865, 5871, 3891, 3577, 5940, 471, 2700, 5691, 6480, 1911]
  res = 0x000000b417e80b291587102c074916ef0f330df9173401d70a8c163b19500777
*/

/*
  Result of 16bit mulvlm index 9
  res = [0, 204, 6936, 4249, 1696, 4692, 7169, 2104, 7443, 5065, 6732, 3567, 3060, 1900, 7344, 5199]
  res = 0x000000cc1b18109906a012541c0108381d1313c91a4c0def0bf4076c1cb0144f
*/

/*
  Result of 16bit mulvlm index 10
  res = [0, 223, 7582, 5351, 4679, 5129, 3785, 5125, 2672, 6243, 7359, 6018, 3345, 4902, 445, 219]
  res = 0x000000df1d9e14e7124714090ec914050a7018631cbf17820d11132601bd00db
*/

/*
  Result of 16bit mulvlm index 11
  res = [0, 208, 7072, 4481, 2324, 4784, 470, 2740, 452, 5313, 6864, 4083, 3120, 2532, 7488, 5747]
  res = 0x000000d01ba01181091412b001d60ab401c414c11ad00ff30c3009e41d401673
*/

/*
  Result of 16bit mulvlm index 12
  res = [0, 588, 4826, 3772, 1320, 5941, 1037, 2496, 3611, 6124, 4238, 22, 1237, 1908, 6002, 4726]
  res = 0x0000024c12da0ebc05281735040d09c00e1b17ec108e001604d5077417721276
*/

/*
  Result of 16bit mulvlm index 13
  res = [0, 923, 1050, 453, 834, 6063, 6825, 2680, 110, 4145, 127, 5322, 6262, 1757, 2896, 5123]
  res = 0x0000039b041a01c5034217af1aa90a78006e1031007f14ca187606dd0b501403
*/

/*
  Result of 16bit mulvlm index 14
  res = [0, 5040, 4534, 4166, 2648, 2175, 6722, 5145, 2786, 1577, 7077, 5605, 7353, 105, 7031, 427]
  res = 0x000013b011b610460a58087f1a4214190ae206291ba515e51cb900691b7701ab
*/

/*
  Result of 16bit mulvlm index 15
  res = [0, 2542, 3015, 3359, 4778, 5385, 640, 2279, 4649, 5944, 473, 1849, 215, 7320, 516, 7019]
  res = 0x000009ee0bc70d1f12aa1509028008e71229173801d9073900d71c9802041b6b
*/

/*
  32bit vector mod32 for instruction mulvml
  mod32 = [8380417]
  mod32 = 0x00000000000000000000000000000000000000000000000000000000007fe001
*/
mod32:
  .word 0x007fe001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  32bit vector vec32a for instruction mulvlm
  vec32a = [0, 1, 44913, 9734, 23276, 65251, 13010, 40903]
  vec32a = 0x00000000000000010000af710000260600005aec0000fee3000032d200009fc7
*/
vec32a:
  .word 0x00009fc7
  .word 0x000032d2
  .word 0x0000fee3
  .word 0x00005aec
  .word 0x00002606
  .word 0x0000af71
  .word 0x00000001
  .word 0x00000000

/*
  32bit vector vec32b for instruction mulvlm
  vec32b = [4140082361, 1869666356, 636760, 207841, 59661, 52504, 947, 30691]
  vec32b = 0xf6c4a4b96f70d8340009b75800032be10000e90d0000cd18000003b3000077e3
*/
vec32b:
  .word 0x000077e3
  .word 0x000003b3
  .word 0x0000cd18
  .word 0x0000e90d
  .word 0x00032be1
  .word 0x0009b758
  .word 0x6f70d834
  .word 0xf6c4a4b9

/*
  Result of 32bit mulvlm index 0
  res = [0, 30691, 4036495, 5431599, 2028271, 8079195, 5410311, 6671840]
  res = 0x00000000000077e3003d978f0052e12f001ef2ef007b475b00528e070065cde0
*/

/*
  Result of 32bit mulvlm index 1
  res = [0, 947, 630526, 837681, 5281538, 3129778, 3940053, 5213473]
  res = 0x00000000000003b300099efe000cc83100509702002fc1b2003c1ed5004f8d21
*/

/*
  Result of 32bit mulvlm index 2
  res = [0, 52504, 3214975, 8248916, 6922639, 6728368, 4263263, 2184360]
  res = 0x000000000000cd1800310e7f007dde540069a18f0066aab000410d5f002154a8
*/

/*
  Result of 32bit mulvlm index 3
  res = [0, 59661, 6201470, 2491401, 5900631, 4426423, 5191246, 1612536]
  res = 0x000000000000e90d005ea07e00260409005a095700438ab7004f364e00189af8
*/

/*
  Result of 32bit mulvlm index 4
  res = [0, 207841, 7358712, 3443797, 2206507, 2318385, 5517136, 3577585]
  res = 0x0000000000032be1007048f800348c550021ab2b0023603100542f50003696f1
*/

/*
  Result of 32bit mulvlm index 5
  res = [0, 636760, 4819076, 5093677, 4648504, 7499691, 4395604, 7438661]
  res = 0x000000000009b75800498884004db92d0046ee3800726fab0043125400718145
*/

/*
  Result of 32bit mulvlm index 6
  res = [0, 833365, 1979923, 8111671, 5118802, 5754119, 6199469, 3972656]
  res = 0x00000000000cb755001e3613007bc637004e1b520057cd07005e98ad003c9e30
*/

/*
  Result of 32bit mulvlm index 7
  res = [0, 156363, 8322390, 5181965, 2404210, 3874624, 6221716, 1457618]
  res = 0x00000000000262cb007efd56004f120d0024af72003b1f40005eef9400163dd2
*/

/*
  64bit vector mod64 for instruction mulvml
  mod64 = [8380417]
  mod64 = 0x00000000000000000000000000000000000000000000000000000000007fe001
*/
mod64:
  .word 0x007fe001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  64bit vector vec64a for instruction mulvlm
  vec64a = [0, 1, 2417127611, 30955]
  vec64a = 0x0000000000000000000000000000000100000000901270bb00000000000078eb
*/
vec64a:
  .word 0x000078eb
  .word 0x00000000
  .word 0x901270bb
  .word 0x00000000
  .word 0x00000001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  64bit vector vec64b for instruction mulvlm
  vec64b = [17614515565450322005, 5145075550695678108, 45867244350, 328746167066219]
  vec64b = 0xf4735494c14160554766faf41dc3609c0000000aade69b3e00012afe2e825e6b
*/
vec64b:
  .word 0x2e825e6b
  .word 0x00012afe
  .word 0xade69b3e
  .word 0x0000000a
  .word 0x1dc3609c
  .word 0x4766faf4
  .word 0xc1416055
  .word 0xf4735494

/*
  Result of 64bit mulvlm index 0
  res = [0, 7031919, 8297214, 101487]
  res = 0x000000000000000000000000006b4c6f00000000007e9afe0000000000018c6f
*/

/*
  Result of 64bit mulvlm index 1
  res = [0, 1222109, 5386136, 1181757]
  res = 0x0000000000000000000000000012a5dd0000000000522f98000000000012083d
*/

/*
  Result of 64bit mulvlm index 2
  res = [0, 6736375, 7667658, 2952331]
  res = 0x0000000000000000000000000066c9f7000000000074ffca00000000002d0c8b
*/

/*
  Result of 64bit mulvlm index 3
  res = [0, 559663, 5318863, 2046226]
  res = 0x00000000000000000000000000088a2f00000000005128cf00000000001f3912
*/

/*
  128bit vector mod128 for instruction mulvml
  mod128 = [8380417]
  mod128 = 0x00000000000000000000000000000000000000000000000000000000007fe001
*/
mod128:
  .word 0x007fe001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128a for instruction mulvlm
  vec128a = [15163934324283487979, 59768885155910817024740993528977806]
  vec128a = 0x0000000000000000d2711ded0c4536eb000b82d563bae0bc42c1cf008893598e
*/
vec128a:
  .word 0x8893598e
  .word 0x42c1cf00
  .word 0x63bae0bc
  .word 0x000b82d5
  .word 0x0c4536eb
  .word 0xd2711ded
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128b for instruction mulvlm
  vec128b = [86676785931336461155, 2613]
  vec128b = 0x0000000000000004b2e1cd923de2ab6300000000000000000000000000000a35
*/
vec128b:
  .word 0x00000a35
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x3de2ab63
  .word 0xb2e1cd92
  .word 0x00000004
  .word 0x00000000

/*
  Result of 128bit mulvlm index 0
  res = [6288065, 6051552]
  res = 0x000000000000000000000000005ff2c1000000000000000000000000005c56e0
*/

/*
  Result of 128bit mulvlm index 1
  res = [4265058, 5841845]
  res = 0x00000000000000000000000000411462000000000000000000000000005923b5
*/
