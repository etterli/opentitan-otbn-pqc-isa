# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

import numpy as np

'''Tool to generate vectors and results to test the OTBN SIMD instructions.

Prints vectors to console and dumps OTBN assemlby formatted data section for each
instruction to a separate file named bn-<op>-memory.txt'''

###############################################################################
# Helpers from sim.isa.py
#
# Copied to remove dependecy / isolate golden model generation
###############################################################################


def to_2s_complement_sized(value: int, size: int) -> int:
    '''Interpret the signed value as a 2's complement of unsigned-`size` integer'''
    assert (size % 8) == 0
    assert -(1 << size) <= value < (1 << size)
    return (1 << size) + value if value < 0 else value


# copy from sim.isa.py
# copied to remove dependency
def extract_sub_word(value: int, size: int, index: int) -> int:
    '''Extract a `size`-bit word at index `index` from a 256-bit value and
    interprets it as unsigned integer'''
    assert 0 <= value < (1 << 256)
    assert 0 <= index <= 256 // size
    return (value >> (index * size)) & ((1 << size) - 1)


def logical_bit_shift(value: int, size: int, shift_type: int, shift_bits: int) -> int:
    '''Logical shift value by shift_bits to the left or right.

    value should be an unsigned `size`-bit value. shift_type should be 0 (shift
    left) or 1 (shift_right), matching the encoding of the big number
    instructions. shift_bits should be a non-negative number of bits to shift
    by.

    Returns an unsigned `size`-bit value, truncating on an overflowing left shift.
    '''
    mask = (1 << size) - 1
    assert 0 <= value <= mask
    assert 0 <= shift_type <= 1
    assert 0 <= shift_bits

    shifted = value << shift_bits if shift_type == 0 else value >> shift_bits
    return shifted & mask


def split_vectors(elems_a, elems_b, elems_c, size: int):
    '''Splits the elements into multiple vectors which fit into
    256bit vectors depending on the element size.
    We have space for only 256//size elements per vector '''

    vecs_a = []
    vecs_b = []
    vecs_c = []
    max_elems = 256 // size
    nof_vecs = len(elems_a) // max_elems
    if nof_vecs == 0:
        nof_vecs = 1

    done = 0
    for ind in range(nof_vecs):
        vec_a = elems_a[done:done + max_elems]
        vecs_a.append(vec_a)
        vec_b = elems_b[done:done + max_elems]
        vecs_b.append(vec_b)
        vec_c = elems_c[done:done + max_elems]
        vecs_c.append(vec_c)
        done += max_elems

    return vecs_a, vecs_b, vecs_c


###############################################################################
# Text formatters
###############################################################################


def format_otbn_memory(hexstring: str, size: int, elems, vec_name: str, operation: str) -> str:
    '''Formats the vector defined by the hexstring into the OTBN assemlby
    data section format'''
    # input elems has no fixed datatype. This way we can either pass a list of elements
    # or just a description
    wordstr = "  .word 0x" + hexstring[-8:] + "\n"
    for ind in range(1, 256 // 32):
        wordstr += "  .word 0x" + hexstring[-(8 * (ind + 1)):-(8 * ind)] + "\n"
    output = ""
    output +=  "/*\n"  # noqa: E222
    output += f"  {size}bit vector {vec_name} for instruction {operation}\n"
    output += f"  {vec_name} = {elems}\n"
    output += f"  {vec_name} = 0x{hexstring}\n"
    output +=  "*/\n"  # noqa: E222
    output += f"{vec_name}:\n"
    output += f"{wordstr}\n"
    return output


def format_otbn_result(hexstring: str, size: int, elems, operation: str) -> str:
    '''Creates a comment for OTBN assembly describing the expected result'''
    output = ""
    output +=  "/*\n"  # noqa: E222
    output += f"  Result of {size}bit {operation}\n"
    output += f"  res = {elems}\n"
    output += f"  res = 0x{hexstring}\n"
    output +=  "*/\n\n"  # noqa: E222
    return output


def convert_to_hex_string(elems, size: int) -> str:
    '''Formats all elements as contiguous string of hex characters.
    Each element is zero padded to match element size'''
    a_2s = [to_2s_complement_sized(int(twos), size) for twos in elems]
    inputstr = "".join([hex(val)[2:].zfill(size // 4) for val in a_2s])
    return inputstr


def format_vectors(vecs_a, vecs_b, vecs_c, size, operation):
    '''Formats all vectors into OTBN memory text.

    Vecs A and B are inputs, vecs_c are results.'''
    txt_a = ""
    txt_b = ""
    txt_c = ""
    for index, (vec_a, vec_b, vec_c) in enumerate(zip(vecs_a, vecs_b, vecs_c)):
        txt_a += format_otbn_memory(convert_to_hex_string(vec_a, size),
                                    size, vec_a, f"vec{size}a{index}", f"{operation}")
        txt_b += format_otbn_memory(convert_to_hex_string(vec_b, size),
                                    size, vec_b, f"vec{size}b{index}", f"{operation}")
        txt_c += format_otbn_result(convert_to_hex_string(vec_c, size),
                                    size, vec_c, f"{operation}")

    return txt_a, txt_b, txt_c


###############################################################################
# Golden vector generators for BN SIMD instructions
###############################################################################

def bn_addv(size: int) -> str:
    '''Generates golden vectors to test bn.addv.

    It tests the overflow and some random values.
    Returns a string containing the required assemlby data section.'''
    max_val = 2**(size) - 1
    min_val = 0

    # must be an even amount of testcases
    elems_a = [max_val, max_val]  # noqa: E201 E221 E241
    elems_b = [   2024,       1]  # noqa: E201 E221 E241

    # for smaller sizes than 128 we need additional vector elements to test
    # the operation on each element. Define some random additions as well.
    if size < 128:
        # for size 64 add 2 elements, total 4
        elems_a = elems_a + [max_val // 2, min_val]
        elems_b = elems_b + [max_val // 2, max_val // 2]
    if size < 64:
        # for size 32 add 4 elements, total 8
        elems_a = elems_a + [5630, max_val, 1684, min_val]
        elems_b = elems_b + [ 123,       1,  437, max_val]  # noqa: E201 E241
    if size < 32:
        # for size 16 add 8 elements, total 16
        elems_a = elems_a + [max_val,    5627, max_val - 12,      min_val]  # noqa: E241
        elems_b = elems_b + [   2024,    8001,         1568,         5678]  # noqa: E201 E221 E241
        elems_a = elems_a + [   8989, max_val, max_val // 2, max_val // 2]  # noqa: E201 E221 E241
        elems_b = elems_b + [    156,    2024, max_val // 2,      max_val]  # noqa: E201 E221 E241

    elems_c = []
    for a, b in zip(elems_a, elems_b):
        c = a + b

        # fake wrap around
        c = c & ((1 << size) - 1)

        elems_c.append(c)

    # we have space for only 256//size elements per vector
    vecs_a, vecs_b, vecs_c = split_vectors(elems_a, elems_b, elems_c, size)

    txt_a, txt_b, txt_c = format_vectors(vecs_a, vecs_b, vecs_c, size, "addv")

    return txt_a + txt_b + txt_c


def bn_addvm(size: int, mod: int):
    '''Generates vectors to test bn.addvm.
    Depending on the number of testcases and the size it returns multiple
    vectors.

    Modulus must be > 3.

    Reduction is performed if result is equal or greater than the modulus.
    Result is correct as long as intermediate result is less than 2*mod.
    This is the case if both inputs are less than mod.
    Returns a string containing the required assemlby data section.'''
    max_val = 2**(size) - 1
    min_val = 0

    # must be an even amount of testcases

    # these are the 4 elementary test cases. For 128b this requires multiple vector
    elems_a = [max_val, max_val, mod // 2, mod - 1]  # noqa: E201 E221 E241
    elems_b = [   2024,       1, mod // 3, mod - 3]  # noqa: E201 E221 E241

    # for smaller sizes than 64 we need additional vector elements to test
    # the operation on each element
    if size < 64:
        # for size 32 add 4 elements, total 8
        elems_a = elems_a + [max_val,      min_val, mod // 2, mod - 1]  # noqa: E201 E221 E241
        elems_b = elems_b + [   2024, max_val // 2, mod // 3, mod - 3]  # noqa: E201 E221 E241
    if size < 32:
        # for size 16 add 8 elements, total 16
        elems_a = elems_a + [max_val, max_val, mod // 2, mod - 1]  # noqa: E201 E221 E241
        elems_b = elems_b + [   2024,       1, mod // 3, mod - 3]  # noqa: E201 E221 E241
        elems_a = elems_a + [max_val, max_val, mod // 2, mod - 1]  # noqa: E201 E221 E241
        elems_b = elems_b + [   2024,       1, mod // 3, mod - 3]  # noqa: E201 E221 E241

    elems_c = []
    for a, b in zip(elems_a, elems_b):
        c = a + b

        if c >= mod:
            c -= mod

        # fake wrap around
        c = c & ((1 << size) - 1)
        # # fake wrap around
        # if c < min_val:
        #     c += 2**size
        # if c > max_val:
        #     c -= 2**size

        elems_c.append(c)

    # we have space for only 256//size elements per vector
    vecs_a, vecs_b, vecs_c = split_vectors(elems_a, elems_b, elems_c, size)

    txt_a, txt_b, txt_c = format_vectors(vecs_a, vecs_b, vecs_c, size, "addvm")

    txt_mod = format_otbn_memory(hex(mod)[2:].zfill(64),
                                 size, [mod], f"mod{size}", "addvm")

    return txt_mod + txt_a + txt_b + txt_c


def bn_subv(size: int) -> str:
    '''Generates vectors to test bn.subv (a - b).
    Depending on the number of testcases and the size it returns multiple
    vectors.

    Returns a string containing the required assemlby data section.'''
    max_val = 2**(size) - 1
    min_val = 0

    # must be an even amount of testcases
    elems_a = [min_val, min_val]  # noqa: E201 E221 E241
    elems_b = [   2048,       1]  # noqa: E201 E221 E241

    # for smaller sizes than 128 we need additional vector elements to test
    # the operation on each element
    if size < 128:
        # for size 64 add 2 elements, total 4
        elems_a = elems_a + [max_val // 2,  max_val // 2]  # noqa: E201 E221 E241
        elems_b = elems_b + [max_val // 2,             0]  # noqa: E201 E221 E241
    if size < 64:
        # for size 32 add 4 elements, total 8
        elems_a = elems_a + [min_val, max_val, 1684, min_val]  # noqa: E201 E221 E241
        elems_b = elems_b + [   2048,       1,  437,       1]  # noqa: E201 E221 E241
    if size < 32:
        # for size 16 add 8 elements, total 16
        elems_a = elems_a + [min_val, min_val, max_val - 12,      max_val]  # noqa: E201 E221 E241
        elems_b = elems_b + [   2048,       1,         1568, max_val // 7]  # noqa: E201 E221 E241
        elems_a = elems_a + [min_val, min_val, max_val // 2,      max_val]  # noqa: E201 E221 E241
        elems_b = elems_b + [   2048,       1, max_val // 2,           12]  # noqa: E201 E221 E241

    elems_c = []
    for a, b in zip(elems_a, elems_b):
        c = a - b

        # fake wrap around
        c = c & ((1 << size) - 1)

        elems_c.append(c)

    # we have space for only 256//size elements per vector
    vecs_a, vecs_b, vecs_c = split_vectors(elems_a, elems_b, elems_c, size)

    txt_a, txt_b, txt_c = format_vectors(vecs_a, vecs_b, vecs_c, size, "subv")

    return txt_a + txt_b + txt_c


def bn_subvm(size: int, mod: int) -> str:
    '''Generates vectors to test bn.subvm (a - b).
    Depending on the number of testcases and the size it returns multiple
    vectors.

    Modulus must be > 3.

    Reduction is performed if result is negative
    Result is correct as long as intermediate result is at least -mod
    and at most mod-1.
    This is the case if both inputs are less than mod.
    Returns a string containing the required assemlby data section.'''
    max_val = 2**(size) - 1
    min_val = 0

    # must be an even amount of testcases

    # these are the 4 elementary test cases. For 128b this requires multiple vector
    elems_a = [min_val, min_val, mod // 2, mod - 3]  # noqa: E201 E221 E241
    elems_b = [   2048,       1, mod // 3, mod - 1]  # noqa: E201 E221 E241

    # for smaller sizes than 64 we need additional vector elements to test
    # the operation on each element
    if size < 64:
        # for size 32 add 4 elements, total 8
        elems_a = elems_a + [min_val,      max_val, mod // 2, mod - 3]  # noqa: E201 E221 E241
        elems_b = elems_b + [   2048, max_val // 2, mod // 3, mod - 1]  # noqa: E201 E221 E241
    if size < 32:
        # for size 16 add 8 elements, total 16
        elems_a = elems_a + [min_val, min_val, mod // 2, mod - 3]  # noqa: E201 E221 E241
        elems_b = elems_b + [   2048,       1, mod // 3, mod - 1]  # noqa: E201 E221 E241
        elems_a = elems_a + [min_val, min_val, mod // 2, mod - 3]  # noqa: E201 E221 E241
        elems_b = elems_b + [   2048,       1, mod // 3, mod - 1]  # noqa: E201 E221 E241

    elems_c = []
    for a, b in zip(elems_a, elems_b):
        c = a - b

        if c < 0:
            c += mod

        # fake wrap around
        c = c & ((1 << size) - 1)

        elems_c.append(c)

    # we have space for only 256//size elements per vector
    vecs_a, vecs_b, vecs_c = split_vectors(elems_a, elems_b, elems_c, size)

    txt_a, txt_b, txt_c = format_vectors(vecs_a, vecs_b, vecs_c, size, "subvm")

    txt_mod = format_otbn_memory(hex(mod)[2:].zfill(64),
                                 size, [mod], f"mod{size}", "subvm")

    return txt_mod + txt_a + txt_b + txt_c


def bn_mulv(size: int, mod: int = -1) -> str:
    '''Generates vectors to test bn.mulv.

    Returns a string containing the required assemlby data section.'''
    match size:
        case 128:
            #          0 * anything = 0  ,         1 * x = x             , 64bit * 68bit = "132bit" -> 128bit, 116bit * 12bit = 128b  # noqa: E501
            elems_a = [               0x0,                            0x1,                 0xD2711DED0C4536EB,    0xB82D563BAE0BC42C1CF008893598e]  # noqa: E201 E221 E241 E501
            elems_b = [   0xFE65A8709C98D, 0x2cd3d491451a0e7eac07695eb499,                0x4B2E1CD923DE2AB63,                              0xa35]  # noqa: E201 E221 E241 E501
        case 64:
            #          0 * anything = 0  ,         1 * x = x , 32b*36b = "68b" -> 64b, 15b * 49b = 64b  # noqa: E501
            elems_a = [               0x0,                0x1,         0x901270bb,             0x78eb]  # noqa: E201 E221 E241 E501
            elems_b = [0xf4735494c1416055, 0x4766faf41dc3609c,        0xaade69b3e,    0x12afe2e825e6b]  # noqa: E201 E221 E241 E501
        case 32:
            #         0 * anything = 0  , 1 * x = x, 16b*20b="36b"->32b, 14b*18b=32b, 4xrandom numbers  # noqa: E501
            elems_a = [       0x0,        0x1,     0xaf71,     0x2606, 0x5aec, 0xfee3, 0x32d2, 0x9fc7]  # noqa: E201 E221 E241 E501
            elems_b = [0xf6c4a4b9, 0x6f70d834,    0x9b758,    0x32be1, 0xe90d, 0xcd18,  0x3b3, 0x77e3]  # noqa: E201 E221 E241 E501
        case 16:
            #          0 * anything = 0  , 1 * x = x, 8b*12b="20b"->16b, 6b*10b=16b, 12xrandom numbers  # noqa: E501
            elems_a = [   0x0,    0x1,  0x22,  0x3a,    0x9d, 0x17, 0xdd, 0x9f, 0x94, 0x3e, 0x21, 0x81, 0x0f, 0x9e, 0x24, 0x89]  # noqa: E201 E221 E241 E501
            elems_b = [0xf6e6, 0xe309, 0x39b, 0x24c,    0xd0, 0xdf, 0xcc, 0xb4, 0x0a, 0x01, 0x64, 0xc0, 0x2a, 0xa1, 0x5c, 0x2f]  # noqa: E201 E221 E241 E501

    elems_c = []
    for a, b in zip(elems_a, elems_b):
        c = a * b

        # TODO: match to HW implementation
        if mod > 0:
            c = c % mod

        # fake wrap around
        c = c & ((1 << size) - 1)

        elems_c.append(c)

    # we have space for only 256//size elements per vector
    vecs_a, vecs_b, vecs_c = split_vectors(elems_a, elems_b, elems_c, size)

    operation = "mulv"
    if mod > 0:
        operation += "m"

    txt_a, txt_b, txt_c = format_vectors(vecs_a, vecs_b, vecs_c, size, operation)

    return txt_a + txt_b + txt_c


def bn_mulvm(size: int, mod: int) -> str:
    '''Generates vectors to test bn.mulvm

    Returns a string containing the required assemlby data section.'''
    txt_mod = format_otbn_memory(hex(mod)[2:].zfill(64),
                                 size, [mod], f"mod{size}", "mulvm")

    return txt_mod + bn_mulv(size, mod=mod)


def bn_mulvl(size: int, mod: int = -1) -> str:
    '''Generates vectors to test bn.mulv.l or bn.mulvm.l

    The lane indexes the vector b. All possible lane values are generated

    Returns a string containing the required assemlby data section.'''
    match size:
        case 128:
            #          64bit * 68bit = "132bit" -> 128bit, 116bit * 12bit = 128b  # noqa: E501
            elems_a = [ 0xD2711DED0C4536EB,    0xB82D563BAE0BC42C1CF008893598e]  # noqa: E201 E221 E241 E501
            elems_b = [0x4B2E1CD923DE2AB63,                              0xa35]  # noqa: E201 E221 E241 E501
        case 64:
            #          0 * anything = 0  ,         1 * x = x , 32b*36b = "68b" -> 64b, 15b * 49b = 64b  # noqa: E501
            elems_a = [               0x0,                0x1,         0x901270bb,             0x78eb]  # noqa: E201 E221 E241 E501
            elems_b = [0xf4735494c1416055, 0x4766faf41dc3609c,        0xaade69b3e,    0x12afe2e825e6b]  # noqa: E201 E221 E241 E501
        case 32:
            #         0 * anything = 0  , 1 * x = x, 16b*20b="36b"->32b, 14b*18b=32b, 4xrandom numbers  # noqa: E501
            elems_a = [       0x0,        0x1,     0xaf71,     0x2606, 0x5aec, 0xfee3, 0x32d2, 0x9fc7]  # noqa: E201 E221 E241 E501
            elems_b = [0xf6c4a4b9, 0x6f70d834,    0x9b758,    0x32be1, 0xe90d, 0xcd18,  0x3b3, 0x77e3]  # noqa: E201 E221 E241 E501
        case 16:
            #          0 * anything = 0  , 1 * x = x, 8b*12b="20b"->16b, 6b*10b=16b, 12xrandom numbers  # noqa: E501
            elems_a = [   0x0,    0x1,  0x22,  0x3a,    0x9d, 0x17, 0xdd, 0x9f, 0x94, 0x3e, 0x21, 0x81, 0x0f, 0x9e, 0x24, 0x89]  # noqa: E201 E221 E241 E501
            elems_b = [0xf6e6, 0xe309, 0x39b, 0x24c,    0xd0, 0xdf, 0xcc, 0xb4, 0x0a, 0x01, 0x64, 0xc0, 0x2a, 0xa1, 0x5c, 0x2f]  # noqa: E201 E221 E241 E501

    all_lanes = []
    # we iterate from lane 0 to `256//size`.
    # But our python elems_a array is inverted (index 0 is lane `256//size` in WDR)
    # Thus `lane` must count down
    for lane in range(256 // size - 1, -1, -1):
        lane_results = []
        lane_value = elems_b[lane]

        for elem in range(256 // size):
            c = elems_a[elem] * lane_value

            # TODO: match to HW implementation
            if mod > 0:
                c = c % mod

            # fake wrap around
            c = c & ((1 << size) - 1)
            lane_results.append(c)

        all_lanes.append(lane_results)

    operation = "mulvl"
    if mod > 0:
        operation += "m"

    txt_a = ""
    txt_a += format_otbn_memory(convert_to_hex_string(elems_a, size),
                                size, elems_a, f"vec{size}a", operation)

    txt_b = ""
    txt_b += format_otbn_memory(convert_to_hex_string(elems_b, size),
                                size, elems_b, f"vec{size}b", operation)

    txt_lane_res = ""
    for index, lane in enumerate(all_lanes):
        txt_lane_res += format_otbn_result(convert_to_hex_string(lane, size),
                                           size, lane, f"{operation} index {index}")

    return txt_a + txt_b + txt_lane_res


def bn_mulvml(size: int, mod: int) -> str:
    '''Generates vectors to test bn.mulvm.l

    Returns a string containing the required assemlby data section.'''
    txt_mod = format_otbn_memory(hex(mod)[2:].zfill(64),
                                 size, [mod], f"mod{size}", "mulvml")
    return txt_mod + bn_mulvl(size, mod=mod)


def bn_trn1(size: int) -> str:
    '''Generates golden vectors for bn.trn1 instruction.

    Returns a string containing the required assemlby data section.'''
    # any random vectors
    vec_a = 0x21caff82_bc486be3_6aaecc11_ccdd1e56_21164f9c_456fec16_11a7c626_ee821bdb
    vec_b = 0x489bc556_1f6b6e6b_99c19e9f_26795d6d_bd9a16d9_ff11c455_42568d44_6c0130d1

    # Generator code as reference.
    # However, we checked the result manually and thus return only hard coded vectors.
    # vec_c = 0
    # for elem in range(0, 256 // size, 2):
    #     elem_a = extract_sub_word(vec_a, size, elem)
    #     elem_b = extract_sub_word(vec_b, size, elem)
    #     vec_c = vec_c | ((elem_a) << (elem * size))
    #     vec_c = vec_c | ((elem_b) << ((elem + 1) * size))

    match size:
        case 16:
            vec_c = 0xc556ff82_6e6b6be3_9e9fcc11_5d6d1e56_16d94f9c_c455ec16_8d44c626_30d11bdb  # noqa: E501
        case 32:
            vec_c = 0x1f6b6e6b_bc486be3_26795d6d_ccdd1e56_ff11c455_456fec16_6c0130d1_ee821bdb  # noqa: E501
        case 64:
            vec_c = 0x99c19e9f_26795d6d_6aaecc11_ccdd1e56_42568d44_6c0130d1_11a7c626_ee821bdb  # noqa: E501
        case 128:
            vec_c = 0xbd9a16d9_ff11c455_42568d44_6c0130d1_21164f9c_456fec16_11a7c626_ee821bdb  # noqa: E501
        case _:
            print(f"BN TRN2: no valid size ({size})!")
            return ""

    vec_a = hex(vec_a)[2:].zfill(64)
    vec_b = hex(vec_b)[2:].zfill(64)
    vec_c = hex(vec_c)[2:].zfill(64)

    mem_a = format_otbn_memory(vec_a, size, "n/a", f"vec{size}a", "trn1")
    mem_b = format_otbn_memory(vec_b, size, "n/a", f"vec{size}b", "trn1")
    mem_c = format_otbn_result(vec_c, size, "n/a", "trn1")

    return mem_a + mem_b + mem_c


def bn_trn2(size: int) -> str:
    '''Generates golden vectors for bn.trn2 instruction.

    Returns a string containing the required assemlby data section.'''
    vec_a = 0x1000_000A_0030_0008_0010_0008_0090_0006_0005_0008_0700_0004_0500_0004_0003_0002
    vec_b = 0x0100_A000_0300_0080_0001_0080_9000_0600_5000_0800_7000_0040_0050_0040_0030_0020

    # Generator code as reference.
    # However, we checked the result manually and thus return only hard coded vectors.
    # vec_c = 0
    # for elem in range(0, 256 // size, 2):
    #     elem_a = extract_sub_word(vec_a, size, elem + 1)
    #     elem_b = extract_sub_word(vec_b, size, elem + 1)
    #     vec_c = vec_c | ((elem_a) << (elem * size))
    #     vec_c = vec_c | ((elem_b) << ((elem + 1) * size))

    match size:
        case 16:
            vec_c = 0x0100_1000_0300_0030_0001_0010_9000_0090_5000_0005_7000_0700_0050_0500_0030_0003  # noqa: E501
        case 32:
            vec_c = 0x0100_a000_1000_000a_0001_0080_0010_0008_5000_0800_0005_0008_0050_0040_0500_0004  # noqa: E501
        case 64:
            vec_c = 0x0100_a000_0300_0080_1000_000a_0030_0008_5000_0800_7000_0040_0005_0008_0700_0004  # noqa: E501
        case 128:
            vec_c = 0x0100_a000_0300_0080_0001_0080_9000_0600_1000_000a_0030_0008_0010_0008_0090_0006  # noqa: E501
        case _:
            print(f"BN TRN2: no valid size ({size})!")
            return ""

    vec_a = hex(vec_a)[2:].zfill(64)
    vec_b = hex(vec_b)[2:].zfill(64)
    vec_c = hex(vec_c)[2:].zfill(64)

    mem_a = format_otbn_memory(vec_a, size, "n/a", f"vec{size}a", "trn2")
    mem_b = format_otbn_memory(vec_b, size, "n/a", f"vec{size}b", "trn2")
    mem_c = format_otbn_result(vec_c, size, "n/a", "trn2")

    return mem_a + mem_b + mem_c


def bn_shv(size: int) -> str:
    '''Generates two result vectors.

    vecXX_left are all elements left shifted by fixed constants.
    vecXX_right are all elements left shifted by fixed constants.
    The shifting constants are written as comments in the memory section string.
    These are different depending on the element size'''
    vec_orig = 0x9397271b502c41d6cf2538cfa72bf6800d250f06252fff02a626711a3a60e2eb
    runs = 4

    # random shift amounts. Each element of the vector is shifted once left and once right
    match size:
        case 16:
            shift_amount_left =  [0, 2, 9, 15]  # noqa: E222
            shift_amount_right = [0, 2, 9, 14]
        case 32:
            shift_amount_left =  [11, 22, 3, 19]  # noqa: E222
            shift_amount_right = [ 5, 30, 3, 16]  # noqa: E201
        case 64:
            shift_amount_left =  [44, 22, 3, 19]  # noqa: E222
            shift_amount_right = [56, 35, 3, 16]
        case 128:
            shift_amount_left =  [ 67,  22, 12, 111]  # noqa: E201 E222 E241
            shift_amount_right = [120, 35,  5,  55]  # noqa: E241

    vecs_left = []
    vecs_right = []
    for run in range(runs):
        vec_left = 0
        vec_right = 0
        for index in range(256 // size):
            elem = extract_sub_word(vec_orig, size, index)
            a_sh_left = logical_bit_shift(elem, size, 0, shift_amount_left[run])
            a_sh_right = logical_bit_shift(elem, size, 1, shift_amount_right[run])
            vec_left = vec_left | (a_sh_left << (index * size))
            vec_right = vec_right | (a_sh_right << (index * size))

        vec_left = hex(vec_left)[2:].zfill(64)
        vecs_left.append((shift_amount_left[run], vec_left))
        vec_right = hex(vec_right)[2:].zfill(64)
        vecs_right.append((shift_amount_right[run], vec_right))

    vec_orig = hex(vec_orig)[2:].zfill(64)

    mem_orig = format_otbn_memory(vec_orig, size, "n/a", f"vec{size}orig", "shv")
    mem_left = ""
    mem_right = ""
    for run in range(runs):
        sh_left, vec_left = vecs_left[run]
        sh_right, vec_right = vecs_right[run]
        mem_left += format_otbn_result(vec_left, size, f"[{sh_left}]", "shv left (res = [bitshift in decimals])")  # noqa: E501
        mem_right += format_otbn_result(vec_right, size, f"[{sh_right}]", "shv right (res = [bitshift in decimals])")  # noqa: E501

    return mem_orig + mem_left + mem_right


###############################################################################
# MAIN
###############################################################################

if __name__ == "__main__":
    FILENEDING = "golden"
    sizes = [16, 32, 64, 128]
    instructions = [bn_addv,
                    bn_subv,
                    bn_mulv,
                    bn_mulvl,
                    bn_trn1,
                    bn_trn2,
                    bn_shv]

    for insn in instructions:
        file = ""
        for size in sizes:
            file += insn(size)
        with open(f"{insn.__name__}-memory.{FILENEDING}", "w") as fd:
            fd.write(file)

    # instructions with MOD parameter
    mods = [7583, 8380417, 8380417, 8380417]
    instructions = [bn_addvm,
                    bn_subvm,
                    bn_mulvm,
                    bn_mulvml]
    for insn in instructions:
        file = ""
        for index, size in enumerate(sizes):
            file += insn(size, mods[index])
        with open(f"{insn.__name__}-memory.{FILENEDING}", "w") as fd:
            fd.write(file)
