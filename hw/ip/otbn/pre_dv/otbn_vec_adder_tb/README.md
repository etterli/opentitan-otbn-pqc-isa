# OTBN Vectorized Adder Testbench

Testcases:
- Carry addition and propagation
- Carry propagation
- Subtraction with positive result
- Subtraction with negative result (underflow)

## Test descriptions

### 001: Carry Addition and propagation
This testcase should cover the following questions:
- Does the fed carry increment the sum?
- Is the carry passed to the next vector chunk correctly? I.e. does the ELEN selection work properly?

Testcase:
```
a + b + C = 0 + 0 + 1 = 1
```
Inputs:
- `a = 'b0`, `b = 'b0`
- `carries_in = 'b1`. All ones. Some should be multiplexed (ignored) to use the proceeding adder's carry out.
- `operand_b_invert = 0`
- elen = all possible values

Expected output:
- `sum`: each element should be `= 1`
- `carries_out = 'b0`

### 002: Carry propagation
This testcase should cover the following questions:
- If each vector chunk adder (16b) generates a carry, is the carry propagated to the next stage up until the last adder of the element?
- Any external carry is correctly used. It is ignored if vector chunk is not the lowest of an element.

Inputs:
- a, b such that each adder has an overflow. `a = {16{16hFFFF}}`, `b = {16{16h2}}`
- `carries_in`: For `ELEN != 16`: Each 2nd carry of each element is set. For `ELEN = 16` all carries are zero.
- `operand_b_invert = 0`
- elen = all possible values

Expected output:
- `sum`: each element should be `== 1`
- `carries_out = '1`: each vector chunk should have its carry bit set.

### 003: Subtraction with positive result
This testcase should cover the following questions:
- The inversion correctly inverts the input b and with a given carry bit it performs the subtraction

Inputs:
- `a`: a random number with `0 < a && a > 3/4*(2**ELEN)`.
- `b`: a random number with `0 < b < a && b > 1/2 * (2**ELEN)`.
- `carries_in = 'b1`
- `operand_b_invert = 1`
- `elen` = all possible values

Expected output:
- `sum`: the correct numerical result
- `carries_out`: Generate a carry for a vector chunk `x` if `ax - bx >= 0`. Else carry is zero.

| `ELEN` | `a`                | `b`        | `sum (i.e. diff)` | `carry out` |
|--------|--------------------|------------|-------------------|-------------|
|  16    | 0xc69a             | 0xaf1c     | 0x177E            | 0xffff      |
|  32    | 0xc06bf44b         | 0xa9544cf9 | 0x1717A752        | 0xffff      |
|  64    | 0xe4aa0ea3fb8b4000 | 0x9267ae994a3a3800 | 0x5242600AB1510800 | 0xbbbb |
| 128    | 0xdeb78842093f72f6ac3ca3e53b835ff4 | 0xad146759a6431781a8eb8c745a43d789 | 0x31A320E862FC5B7503511770E13F886B | 0x????? |
| 256    | 0xfeb5cfff11edc8a2e529a44ac133457bfefb5a48866a0a2c5c805773f878e76b | 0xbb4cfb388f016e8b15d401d8eea806a4e6374c908d870de7451e45aff6fb3f58 | 0x4368D4C682EC5A17CF55A271D28B3ED718C40DB7F8E2FC45176211C4017DA813 | 0x9dcf |

### 004: Subtraction with negative result (underflow)
This testcase should cover the following questions:
- If `a - b < 0` then the carry bit should be cleared

Inputs:
- `a`: a random number with `0 < a && a > 1/2*(2**ELEN)`. 
- `b`: a random number with `0 < a < b && b > 3/4 * (2**ELEN)`.
- `carries_in = 'b1`
- `operand_b_invert = 1`
- elen = all possible values

Expected output:
- `sum`: the correct numerical result
- `carries_out`: Generate a carry for a vector chunk `x` if `ax - bx >= 0`. Else carry is zero.

| `ELEN` | `a`                | `b`        | `sum (i.e. diff)`      | `carry out` |
|--------|--------------------|------------|------------------------|-------------|
|  16    | 0x8797             | 0xd5e1     | 0xb1b6                 | 0x0000      |
|  32    | 0xa5438f08         | 0xd0c574d3 | 0xd47e1a35             | 0x5555      |
|  64    | 0x88330a000709b7ce | 0xc3b2a9165261d50a | 0xc48060e9b4a7e2c4 | 0x0000
| 128    | 0x89061131e2bc60c6c8600fde70254304 | 0xc79fe6af6b672d4389c2deb41914f306 | 0xc1662a82775533833e9d312a57104ffe | 0x3a3a |
| 256    | 0x84ca07062382f77f0e0f29cec73271133abb7a8106103c7a6153b6691bbe3ba8 | 0xde6a8ee2d2a3c5e50bf069863f72253472b3fbad45f8304c98bf40ab9776ec9f | 0x1b14 |

## Golden Vector file
All testcases inputs and outputs are defined in the `otbn_vec_adder.golden` file.
Each line of the file has the following format and represents a testcase.
```
<elen>, 0x<a>, 0x<b>, 0x<cin>, <op_b_invert>, 0x<sum>, 0x<cout>
```
where
- `<elen>`: one of `16, 32, 64, 128, 256`
- `<a>`: input vector `a` as `256'hxx...` (0x is expected)
- `<b>`: input vector `b` as `256'hxx...` (0x is expected)
- `<cin>`: input carries as `16'hxxxx` (0x is expected)
- `<op_b_invert>`: `0` for noninverting, `1` for inverting
- `<sum>`: the expected sum as `256'hxx...` (0x is expected)
- `<cout>`: the exected carries out as `16'hxxxx` (0x is expected)
