# dsHomebrew

**dsHomebrew** is a lightweight toolchain for assembling **Nintendo DS (NDS)** cartridges from **ARM assembly code** using **VASM**.  
It’s designed to work cross-platform and has been tested on **macOS** and **Windows** so far.

---

##  Usage

### On Windows
1. Run the provided build script:
   ```bash
   buildScript.bat "Code/example.s" "/path/to/code.nds"
   ```
2. Open the included emulator:
   ```
   /emulator/DeSmuME.exe
   ```
3. Load the output ROM located at:
   ```
   /BuildDNS/program.nds
   ```

---

### On macOS / Unix
1. Run the shell build script:
   ```bash
   ./buildScript.sh "code.s" "/path/to/code.nds"
   ```
   > The script **overwrites** the output file `program.nds` by default.  
   It’s highly recommended to rename your `.nds` file before compiling.

---

## Project Structure

```
dsHomebrew/
├── Sandbox.s
├── SandboxGUI.s
├── SandboxWithHeaders.s
├── Headers/
│   ├── Font96.FNT
│   ├── v1_bitmapMemory
│   ├── v1_Header
│   ├── v1_Monitor
│   └── (other header files)
├── Resources/
│   └── (demo artwork and assets)
├── buildScript.bat
├── buildScript.sh
├── README.md
└── .gitignore
```

> Note: `Utils/`, `buildNDS/`, and `Emulator/` are locally ignored and not included in the GitHub repository.

---

## Code Files

Place your assembly source files **in the same directory as `dsHomebrew`**.  
Do **not** move or rename these files unless you update the build scripts accordingly.

- `Sandbox.s` — example ARM9 assembly source.  
- `SandboxWithHeaders.s` — example with header imports included.

---

## Headers (`/dsHomebrew/Headers`)

These files contain reusable routines and constants to simplify DS homebrew development:

- **Font96.FNT** — 96-pixel byte-sized bitmap font. You can replace it with another font of your choice.  
- **v1_bitmapMemory** — initializes the DS screen and provides helper functions (newline, print string, etc.). Recommended to read before editing `.s` code.  
- **v1_Header** — defines the NDS cartridge header. Leave default unless you need to modify engine mode (A/B) or file allocation flags.  
- **v1_Monitor** — contains utility functions for debugging registers such as PC, LS, etc.  

> Some header files are third-party and not written by me. See the `/ARMDevTools` folder for attribution.

---

##  Utils (`/dsHomebrew/Utils/Vasm`)

This folder includes **VASM binaries** used to assemble your code:

- `vasmarm_std_macos` — VASM ARM standard build for macOS.  
- `vasmarm_std_win32.exe` — VASM ARM standard build for Windows.  

You can replace these with binaries for your platform.  
Just ensure the filename matches `vasmarm_std` in the scripts.

---

## Build Output

Compiled ROMs are placed in the **`BuildDNS/`** folder.  
The resulting `.nds` files can be loaded into any Nintendo DS emulator, such as **DeSmuME**, for testing.  
Supports **ARM9** (and ARM7 if included in your code).

---

## License

All original files are licensed under **Creative Commons Attribution (CC BY)** unless otherwise noted.  
Third-party files retain their original licenses — see the `/ARMDevTools` folder for details.

---

**Author:** Juan Vargas  
**Written:** October 29, 2025  
**Toolchain:** dsHomebrew — ARM Assembly → NDS ROM Builder
