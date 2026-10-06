#!/bin/sh
set -eu
cd "$(dirname "$0")"
cargo build --locked --release --target wasm32-unknown-unknown --target-dir target
cp target/wasm32-unknown-unknown/release/image_clip.wasm image_clip.wasm
