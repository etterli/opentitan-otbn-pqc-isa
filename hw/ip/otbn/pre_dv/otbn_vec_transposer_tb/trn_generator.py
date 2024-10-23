def extract_sub_word(value: int, size: int, index: int) -> int:
    '''Extract a `size`-bit word at index `index` from a 256-bit value and
    interprets it as unsigned integer'''
    assert 0 <= value < (1 << 256)
    assert 0 <= index <= 256 // size
    return (value >> (index * size)) & ((1 << size) - 1)


vec_a = 0x5618f029e3973ebcceb4e619091fd07a054bfe9a7d9b303b79d55aa3ceb8e629
vec_b = 0xe6065378a9daf92d31281a6aff39c2ac778ebbbd37f704cc116b789397fc16cc
size = 128

vec_c = 0
# TRN1
for elem in range(0, 256 // size, 2):
    elem_a = extract_sub_word(vec_a, size, elem)
    elem_b = extract_sub_word(vec_b, size, elem)
    vec_c = vec_c | ((elem_a) << (elem * size))
    vec_c = vec_c | ((elem_b) << ((elem + 1) * size))

print(f"TRN1: {hex(vec_c)}")

# TRN2
vec_c = 0
for elem in range(0, 256 // size, 2):
    elem_a = extract_sub_word(vec_a, size, elem + 1)
    elem_b = extract_sub_word(vec_b, size, elem + 1)
    vec_c = vec_c | ((elem_a) << (elem * size))
    vec_c = vec_c | ((elem_b) << ((elem + 1) * size))

print(f"TRN2: {hex(vec_c)}")
