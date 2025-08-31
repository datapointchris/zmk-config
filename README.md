# ZMK Config - Keymap Alignment Tool

A comprehensive ZMK keymap alignment tool that formats and validates ZMK keymap files using JSON layout definitions. This tool ensures consistent column alignment and proper formatting for complex multi-parameter behaviors.

## Features

- **Automatic keymap alignment** - Formats keymaps to proper column alignment based on keyboard layout
- **Multi-parameter behavior support** - Correctly handles complex ZMK behaviors like `&hml LCTRL A`, `&hmr &caps_word RALT`
- **Layout validation** - Verifies binding counts match expected keyboard layout
- **Comprehensive testing** - Full test suite covering all functionality with pytest
- **Multiple keyboard support** - Works with any keyboard layout defined in JSON format

## Quick Start

### Align a keymap

```bash
# Align Glove80 keymap
make align-glove80

# Align Corne keymap  
make align-corne

# Align both keyboards
make align
```

### Run tests

```bash
# Run full test suite
make test

# Run tests with minimal output
make test-fast

# Run tests with verbose output
make test-verbose
```

### Build firmware

```bash
make build
```

## Usage

### Command Line

```bash
python3 align_keymap.py -k <keymap_file> -l <layout_file> [-o <output_file>]

# Examples:
python3 align_keymap.py -k config/glove80.keymap -l glove80_layout.json
python3 align_keymap.py -k config/glove80.keymap -l glove80_layout.json -o aligned_output.keymap
```

### Options

- `-k, --keymap` - Input ZMK keymap file
- `-l, --layout` - JSON layout definition file
- `-o, --output` - Output file (optional, defaults to updating input file)
- `--debug` - Enable debug output

## Layout Files

Layout files define the physical keyboard matrix in JSON format:

```json
```json
{
  "name": "Keyboard Layout",
  "layout": [
    ["X", "X", "X", "X"],  
    ["X", "X", "X", "X"],  
    ["-", "X", "X", "-"]   
  ]
}
```

- `"X"` - Active key position
- `"-"` - No key at this position

## Project Structure

```text
├── align_keymap.py          # Main alignment script
├── Makefile                 # Build and test automation
├── config/                  # Keymap configurations
│   ├── glove80.keymap      
│   └── corne.keymap      
├── tests/                   # Comprehensive test suite
│   ├── layouts/            # JSON layout files
│   ├── test_keymaps/       
│   │   ├── correct/        # Hand-aligned reference files
│   │   ├── misaligned/     # Test input files
│   │   └── test_output/    # Generated test outputs
│   ├── simple_tests/       # Simple test cases
│   └── test_align_keymap.py  # Main test file
├── glove80_layout.json     # Glove80 80-key layout
└── corne_layout.json     # Corne 42-key layout
```

## Testing

### Test Suite Overview

The test suite validates ALL essential functionality:

**Core Functionality:**

- Layout loading from JSON files  
- Binding extraction from keymap content (handles comments, complex behaviors)
- Layer validation with helpful error messages
- Column width calculation and alignment formatting
- Complete workflow integration

**Binding Types Tested:**

- Simple keycodes: `&kp A`, `&trans`, `&none`
- Multi-parameter behaviors: `&hml LCTRL A`, `&hmr RALT B`, `&lt 1 SPACE`
- Behaviors with behavior parameters: `&hmr &caps_word RALT`, `&hmrt RSHFT &caps_word`
- All ZMK binding types: bluetooth, media, RGB, mouse, system

**Error Handling:**

- Missing/malformed files
- Incorrect binding counts with position details
- Invalid JSON layouts  
- Edge cases and unusual formatting

### Test Files

**Reference Files (Hand-Aligned):**

- `glove80_reference_properly_aligned.keymap` - Perfect alignment reference
- `glove80_reference_reverse_key_order.keymap` - Reverse key order reference

**Test Input Files:**

- `glove80_input_badly_aligned.keymap` - Poor alignment formatting
- `glove80_input_cramped_no_spacing.keymap` - All keys crammed together
- `glove80_input_insufficient_bindings.keymap` - Missing bindings
- `glove80_input_excess_bindings.keymap` - Too many bindings

### Running Tests

```bash
# Run all tests with pytest
make test

# Run with minimal output
make test-fast  

# Run with extra verbose output
make test-verbose

# Run specific test class
python3 -m pytest tests/test_align_keymap.py::TestBindingExtraction -v

# Run specific test
python3 -m pytest tests/test_align_keymap.py::TestBindingExtraction::test_glove80_specific_behaviors -v
```

### Key Test Cases

**Validation Testing:**

- Tests verify binding count validation with helpful error messages
- Multiple test keymaps with various binding count issues
- Position-specific error reporting

**Alignment Workflow:**

- End-to-end testing from misaligned input to properly aligned output
- Byte-for-byte comparison with hand-aligned reference files
- File size and checksum validation

**Complex Binding Parsing:**

- Multi-parameter behaviors like `&hml LCTRL A` parsed as single units
- Nested behaviors like `&hmr &caps_word RALT` handled correctly  
- Thumb-specific behaviors like `&hmrt RSHFT &caps_word` supported

**Integration Testing:**

- Real keymap files test complete workflow
- Multiple keyboard layout support
- Error recovery and graceful failure

Expected output: `20 passed in X.XXs` with pytest

## Supported Keyboards

- **Glove80** - 80-key split keyboard with thumb clusters
- **Corne** - 42-key split keyboard
- **Custom layouts** - Any keyboard with JSON layout definition

## Requirements

- Python 3.7+
- pytest (for running tests)
- ZMK-compatible keymap files

## Development

### Adding New Keyboard Support

1. Create JSON layout file defining key positions
2. Add Makefile targets for alignment
3. Add test cases for the new layout
4. Test with sample keymap files

### Contributing

1. Ensure all tests pass: `make test`
2. Add tests for new functionality  
3. Follow existing code style and patterns
4. Update documentation as needed

## License

This project is part of a ZMK configuration setup for custom keyboard layouts.
