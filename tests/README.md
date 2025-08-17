# ZMK Keymap Alignment Tests

Comprehensive test suite for the keymap alignment script that validates and formats ZMK keymap files using JSON layout definitions.

## Files

**Test Suite:**

- `test_align_keymap.py` - Main test suite covering all functionality
- `test_data.py` - Test data constants and fixtures  

**Test Keymaps:**

- `glove80_missing_bindings.keymap` - Glove80 keymap with 77/80 bindings (MOUSE layer incomplete)
- `glove80_misaligned.keymap` - Valid Glove80 keymap with poor alignment formatting
- `glove80_aligned.keymap` - Same content as misaligned, but properly aligned
- `glove80_too_many_bindings.keymap` - Keymap with extra bindings to test validation
- `simple_3x2.keymap` - Minimal 6-key keymap for unit testing
- `simple_3x2_layout.json` - Layout definition for simple keymap

## What is Tested

**Core Functionality:**

- Layout loading from JSON files
- Binding extraction from keymap content (handles comments, complex behaviors, parameters)
- Layer validation with helpful error messages
- Column width calculation and alignment formatting
- Complete workflow integration

**Binding Types:**

- Simple keycodes and behaviors with parameters
- Complex multi-parameter behaviors (`&hml LCTRL A`, `&lt 1 SPACE`)
- Behaviors taking other behaviors as parameters (`&hmr &caps_word RALT`)
- All ZMK binding types (bluetooth, media, RGB, mouse, system)

**Error Handling:**

- Missing/malformed files
- Incorrect binding counts (too few/many with position details)
- Invalid JSON layouts
- Edge cases and unusual formatting

## Running Tests

```bash
# From project root
python3 tests/test_align_keymap.py

# With unittest module
python3 -m unittest tests.test_align_keymap -v
```

## Key Test Cases to Watch

**Validation Testing:** Multiple test keymaps verify validation logic:

- `glove80_missing_bindings.keymap` has 77/80 bindings (MOUSE layer incomplete)
- `glove80_too_many_bindings.keymap` has extra bindings in one layer
- Both should fail with helpful position-specific error messages

**Alignment Workflow:**

- `glove80_misaligned.keymap` → should align to match `glove80_aligned.keymap`
- Tests complete process from unformatted input to properly aligned output

**Complex Binding Parsing:** Tests ensure that multi-word bindings like `&hml LCTRL A` and nested behaviors like `&hmr &caps_word RALT` are parsed as single units, not split into separate tokens.

**Integration vs Unit Testing:** Real keymap files test end-to-end workflow while inline test data in the test suite covers specific parsing edge cases.

Expected output when all tests pass: `Ran 21 tests in X.XXXs OK`
