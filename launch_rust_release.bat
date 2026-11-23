@echo off
rem Launcher for the pure-Rust port (rustport/) - optimized release build.
rem Usage: launch_rust_release.bat [--help]   (args go straight to the binary)
setlocal
cd /d "%~dp0\rustport"

where cargo >nul 2>nul
if errorlevel 1 (
  echo cargo not found. Install Rust from https://rustup.rs/ then retry.
  pause
  exit /b 1
)

echo Building and running cossacks3-rust (release)...
cargo run --release --bin cossacks3-rust -- %*
if errorlevel 1 (
  echo rustport exited with an error, code %errorlevel%.
  pause
)
