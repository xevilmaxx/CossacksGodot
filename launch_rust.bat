@echo off
rem Launcher for the pure-Rust port (rustport/ - scaffold, T6-R01).
rem Builds (debug) and runs the cossacks3-rust binary.
rem Usage: launch_rust.bat [--help]   (args go straight to the binary, no -- needed)
rem   Other binaries: cargo run --bin win32_demo | raster_piece | m0_capture
setlocal
cd /d "%~dp0\rustport"

where cargo >nul 2>nul
if errorlevel 1 (
  echo cargo not found. Install Rust from https://rustup.rs/ then retry.
  pause
  exit /b 1
)

echo Building and running cossacks3-rust (debug)...
cargo run --bin cossacks3-rust -- %*
if errorlevel 1 (
  echo rustport exited with an error, code %errorlevel%.
  pause
)
