# dsHomebrew

A compact Nintendo DS demo project created as a demoscene demo of ARM9 assambly. This repository contains the demo assembly source and supporting headers used to showcase ARM9/ARM7 NDS homebrew development.

---

## Project structure

```
dsHomebrew/
├── Sandbox.s
├── SandboxGUI.s
├── SandboxWithHeaders.s
├── Headers/
│   ├── Font96.FNT
│   ├── V1_BitmapMemory.asm
│   ├── V1_Header.asm
│   ├── V1_Monitor.asm
│   └── (other included headers)
├── Resources/
│   ├── Sprites/
│   └── SpritesRaw/
├── buildScript.bat
├── buildScript.sh
├── README.md
└── .gitignore
```

> `Utils/`, `buildNDS/`, and `Emulator/` are excluded from the public repository and are not part of this demo upload.

---

## Notes

This repository is intended as a demo for a resume/CV and is focused on source-level NDS assembly work.
Local assembler binaries, build outputs, and emulator files are intentionally ignored so the repo stays clean and portable.

If you want to build the project locally, use your own VASM assembler or adjust the scripts to point to a locally installed assembler.

---

## License

Apache license.

The demo code and assets in this repository are intended as a portfolio piece. Local build tools, emulator files, and generated ROM output are excluded from the public repository.

---

**Author:** Juan Vargas  
**Originally Written:** October 29, 2025  
**Last Edited** June 3, 2026
**Toolchain:** dsHomebrew — VASM ARM Assembly → NDS ROM Builder
