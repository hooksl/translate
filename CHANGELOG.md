# Changelog

## v0.1.0 - 2026-10-21

First tagged release.

### Added
- `:Translate [local|online|sound] [text]` command with range support and engine completion
- `:checkhealth translate` for checking `sdcv` / `trans`
- Options: `default_engine`, `proxy`, `languages`, `commands`, `window`
- Lua API: `translate(text, engine)` and `translate_cursor(engine)`
- Floating window sized to its content, closed with `q` / `<Esc>` or by leaving it
- Headless test suite and GitHub Actions CI

### Changed
- External tools run asynchronously with an argument list (no shell), so quotes,
  backticks and other special characters in the text are passed through safely
- The online proxy is now optional and configurable (was hard-coded to `127.0.0.1:2080`)
- `sdcv` is called with UTF-8 input/output forced, so Chinese lookups work in any locale
- Visual selections are read with `getregion()` instead of yanking into register `9`
- Keymap names `local` / `online` are accepted alongside `local_translation` / `online_translation`

### Removed
- Development-only `<leader>pt` reload mapping that was set for every user
