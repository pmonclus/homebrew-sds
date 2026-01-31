# Homebrew Tap for SDS

This is a Homebrew tap for [SDS (Synchronized Data Structures)](https://github.com/pmonclus/sds-library) - a lightweight MQTT-based state synchronization library for IoT.

## Installation

```bash
brew tap pmonclus/sds
brew install sds
```

## Usage

After installation:

```bash
# Generate C and Python types from schema
sds-codegen schema.sds --c --python

# View help
sds-codegen --help
```

## What's Included

- **C Library** (`libsds`) - Core state synchronization library
- **Python Bindings** - CFFI-based Python wrapper
- **sds-codegen** - Code generator for creating types from `.sds` schemas
- **Arduino Library** - ZIP file for ESP32/ESP8266 development

## Arduino

The Arduino library ZIP is installed at:
```
$(brew --prefix)/share/sds/sds-arduino-*.zip
```

Install in Arduino IDE: **Sketch → Include Library → Add .ZIP Library**

## Documentation

See the [main repository](https://github.com/pmonclus/sds-library) for full documentation.

## License

MIT
