#!/bin/bash

# dsHomebrew Build Script
# Usage: ./buildScript.sh <sourcefile.s> [optional:output.nds]
# If no output name is provided, defaults to ./buildNDS/program.nds

BuildFile="$1"
OutputName="$2"

if [ -z "$BuildFile" ]; then
    echo "Usage: $0 <BuildFile> [OutputName.nds]"
    echo "Example: ./buildScript.sh SandboxWithHeaders.s myGame.nds"
    exit 1
fi

# Ensure the source file exists
if [ ! -f "$BuildFile" ]; then
    echo "Error: Source file '$BuildFile' not found."
    exit 1
fi

# Prepare output folder
mkdir -p ./buildNDS

# Determine output name
if [ -z "$OutputName" ]; then
    OutputName="program.nds"
fi

# Normalize paths
BuildFile="$(realpath "$BuildFile")"
OutputDir="$(realpath ./buildNDS)"
BuildPath="$OutputDir/$OutputName"

# Ensure VASM path
VASM_PATH="./Utils/Vasm/vasmarm_std_macos"  # adjust if needed

if [ ! -f "$VASM_PATH" ]; then
    echo "Error: VASM compiler not found at $VASM_PATH"
    echo "Please make sure vasmarm_std_macos (or your platform equivalent) exists."
    exit 1
fi

# Build command
echo "Building $BuildFile → $BuildPath ..."
"$VASM_PATH" "$BuildFile" \
    -m7tdmi -noialign -chklabels -nocase -Dvasm=1 \
    -L "$OutputDir/Listing.txt" -DbuildNDS=1 -Fbin \
    -o "$BuildPath"

# Check result
if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
else
    echo "Build successful! Output:"
    echo "Output: $BuildPath"
fi
