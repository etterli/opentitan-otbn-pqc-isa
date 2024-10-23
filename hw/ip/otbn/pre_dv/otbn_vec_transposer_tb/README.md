# OTBN Vectorized Transposer Testbench

Testcases (each for addvm and subvm):
- Check TRN1 for all ELENs
- Check TRN2 for all ELENs

## Test descriptions

### 001: TRN1
This testcase should cover the following questions:
- All ELEN are shuffled correctly

Inputs:
- `operand_a`, `operand_a`: random vectors
- `is_trn1`: 1
- `elen`: all possible values except 256b

Expected output:
- `result`: the expected shuffled vector

### 002: TRN2
This testcase should cover the following questions:
- All ELEN are shuffled correctly

Inputs:
- `operand_a`, `operand_a`: random vectors
- `is_trn1`: 0
- `elen`: all possible values except 256b

Expected output:
- `result`: the expected shuffled vector

## Golden Vector file
All testcases inputs and outputs are defined in the `otbn_vec_transposer.golden` file.
Each line of the file has the following format and represents a testcase.
```
<elen>, 0x<operand_a>, 0x<operand_b>, <is_trn1>, 0x<result>
```
where
- `<elen>`: one of `16, 32, 64, 128, 256`
- `<operand_a>`: input vector `operand_a` as `256'hxx...` (0x is expected)
- `<operand_b>`: input vector `operand_b` as `256'hxx...` (0x is expected)
- `<is_trn1>`: `0` for TRN2, `1` for TRN1
- `<result>`: the expected result as `256'hxx...` (0x is expected)
