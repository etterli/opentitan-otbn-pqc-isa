# OTBN Vectorized Shifter Testbench

Testcases (each for addvm and subvm):
- Check that existing functionality is not broken
- Check new vector shifting functionality

## Test descriptions

### 001: Right shift & BN.RSHI
This testcase should cover the following questions:
- 256b right shift works
- This also tests BN.RSHI

Inputs:
- `lower`, `upper`: random 256b values
- `shift_right`: 1
- `shift_amt`: values in steps of 8 and some other random values (for BN.RSHI testing) (0, 8, 27, 72, 111, 248)
- `elen`: 256b

Expected output:
- `result`: the expected shifted 256b result

### 002: Left shift
This testcase should cover the following questions:
- 256b left shift works

Inputs:
- `lower`, `upper`: random 256b values
- `shift_right`: 0
- `shift_amt`: values in steps of 8 (0, 8, 3, 96, 168, 200)
- `elen`: 256b

Expected output:
- `result`: the expected shifted 256b result

### 003: Right shift vectorized
Inputs:
- `lower`: random vector
- `upper`: all zeros
- `shift_right`: 1
- `shift_amt`: all values of list in range of ELEN (0, 3, 11, 16, 22, 32, 55, 64, 96, 128)
- `elen`: all except 256b

Expected output:
- `result`: the expected shifted vector

### 004: Left shift vectorized
Inputs:
- `lower`: random vector
- `upper`: all zeros
- `shift_right`: 0
- `shift_amt`: all values of list in range of ELEN (0, 3, 11, 16, 22, 32, 55, 64, 96, 128)
- `elen`: all except 256b

Expected output:
- `result`: the expected shifted vector

## Golden Vector file
All testcases inputs and outputs are defined in the `otbn_vec_transposer.golden` file.
Each line of the file has the following format and represents a testcase.
```
<elen>, 0x<upper>, 0x<lower>, <shift_right>, <shift_amt>, 0x<result>
```
where
- `<elen>`: one of `16, 32, 64, 128, 256`
- `<upper>`: upper shifter input (vector) as `256'hxx...` (0x is expected)
- `<lower>`: lower shifter input (vector) as `256'hxx...` (0x is expected)
- `<shift_right>`: `0` for left shift, `1` for right shift
- `<shift_amt>`: the shift amount in bits in decimal
- `<result>`: the expected result as `256'hxx...` (0x is expected)
