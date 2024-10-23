# OTBN Vectorized Modulo Result Selector Testbench

Testcases (each for addvm and subvm):
- Selector resolves no modulo reduction correctly
- Selector resolves modulo reduction correctly

## Test descriptions

### 001: addvm - No modulo reduction
This testcase should cover the following questions:
- Is result X chosen if there holds `a + b < mod`

Inputs:
- `result_x, result_y`: random values (are not considered)
- `carries_x`: all zero
- `carries_y`: all zero
- `is_subtraction`: `0`
- `elen`: all possible values

Expected output:
- `result` == `result_x`

### 002: addvm - Modulo reduction - X overflow
This testcase should cover the following questions:
- Is result Y chosen if there holds `a + b >= mod`

Inputs:
- `result_x, result_y`: different random values (are not considered)
- `carries_x`: all ones
- `carries_y`: all zero
- `is_subtraction`: `0`
- `elen`: all possible values

Expected output:
- `result` == `result_y`

### 003: addvm - Modulo reduction - Y overflow
This testcase should cover the following questions:
- Is result Y chosen if there holds `X - mod >= 0`

Inputs:
- `result_x, result_y`: different random values (are not considered)
- `carries_x`: all zeros
- `carries_y`: all ones
- `is_subtraction`: `0`
- `elen`: all possible values

Expected output:
- `result` == `result_y`

### 004: addvm - Modulo reduction - X and Y overflow
This testcase should cover the following questions:
- Is result Y chosen if there holds `X - mod >= 0`

Inputs:
- `result_x, result_y`: different random values (are not considered)
- `carries_x`: all ones
- `carries_y`: all ones
- `is_subtraction`: `0`
- `elen`: all possible values

Expected output:
- `result` == `result_y`

### 005: addvm - Mixed reduction
This testcase should cover the following questions:
- Combination of 001 - 004.

Inputs:
- `result_x, result_y`: different random values (are not considered)
- `carries_x`: randomly zero or one
- `carries_y`: randomly zero or one
- `is_subtraction`: `0`
- `elen`: all possible values

Expected output:
- `result` matches the expected carry decision


### 010: subvm - No modulo reduction - Y low
This testcase should cover the following questions:
- Is result X chosen if there holds `a - b >= 0`

Inputs:
- `result_x, result_y`: random values (are not considered)
- `carries_x`: all ones
- `carries_y`: all zero
- `is_subtraction`: `1`
- `elen`: all possible values

Expected output:
- `result` == `result_x`

### 011: subvm - No modulo reduction - Y high
This testcase should cover the following questions:
- Is result X chosen if there holds `a - b >= 0` ignoring the Y carries.

Inputs:
- `result_x, result_y`: random values (are not considered)
- `carries_x`: all ones
- `carries_y`: all ones
- `is_subtraction`: `1`
- `elen`: all possible values

Expected output:
- `result` == `result_x`

### 012: subvm - Modulo reduction - Y low
This testcase should cover the following questions:
- Is result Y chosen if there holds `a - b < 0`

Inputs:
- `result_x, result_y`: different random values (are not considered)
- `carries_x`: all zeros
- `carries_y`: all zeros
- `is_subtraction`: `1`
- `elen`: all possible values

Expected output:
- `result` == `result_y`

### 013: subvm - Modulo reduction - Y high
This testcase should cover the following questions:
- Is result Y chosen if there holds `a - b < 0` ignoring the Y carries

Inputs:
- `result_x, result_y`: different random values (are not considered)
- `carries_x`: all zeros
- `carries_y`: all ones
- `is_subtraction`: `1`
- `elen`: all possible values

Expected output:
- `result` == `result_y`

todo below-----
### 014: subvm - Mixed reduction
This testcase should cover the following questions:
- Combination of 010 - 013.

Inputs:
- `result_x, result_y`: different random values (are not considered)
- `carries_x`: randomly zero or one
- `carries_y`: randomly zero or one
- `is_subtraction`: `1`
- `elen`: all possible values

Expected output:
- `result` matches the expected carry decision

## Golden Vector file
All testcases inputs and outputs are defined in the `otbn_vec_mod_result_selector.golden` file.
Each line of the file has the following format and represents a testcase.
```
<elen>, 0x<result_x>, 0x<carries_x>, 0x<result_y>, 0x<carries_y>, <is_subtraction>, 0x<result>
```
where
- `<elen>`: one of `16, 32, 64, 128, 256`
- `<result_x>`: input vector `result_x` as `256'hxx...` (0x is expected)
- `<carries_x>`: input carries of `result_x` as `16'hxxxx` (0x is expected)
- `<result_y>`: input vector `result_y` as `256'hxx...` (0x is expected)
- `<carries_y>`: input carries of `result_y` as `16'hxxxx` (0x is expected)
- `<is_subtraction>`: `0` for addvm, `1` for subvm
- `<result>`: the expected result as `256'hxx...` (0x is expected)
