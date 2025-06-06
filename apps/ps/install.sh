#!/bin/bash
cargo build -r &&cp target/release/ps ../../bin;
chmod +x ../../bin;
