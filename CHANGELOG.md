# Changelog

## [2.1.0](https://github.com/you-n-g/simplegpt.nvim/compare/v2.0.0...v2.1.0) (2026-01-29)


### Features

* add 'f' code_only reg and update variable_explain template ([8bb5a43](https://github.com/you-n-g/simplegpt.nvim/commit/8bb5a4349dae4e06957a27479187f61acbe81f40))
* add @ shortcut in file-path popup to insert files via fzf-lua ([eff8f1a](https://github.com/you-n-g/simplegpt.nvim/commit/eff8f1a1cb90b8451703109a327168be57f5e03e))
* add context_line_num variable with line numbers and current line marker ([c88fa18](https://github.com/you-n-g/simplegpt.nvim/commit/c88fa18f56a5739d9841f87cc16d2158f298eb4d))
* add register history and C-p/C-n navigation in template editor ([654a68e](https://github.com/you-n-g/simplegpt.nvim/commit/654a68ecb2f53b2415e6bb6e82b4537aff7c8825))
* add variable documentation feature with cword support and docs update ([3a1bde5](https://github.com/you-n-g/simplegpt.nvim/commit/3a1bde591494cbd3b07e6684bd37572d69f14dd1))
* add visual-mode 'k' binding for code completion docs in diff ([af5e8bd](https://github.com/you-n-g/simplegpt.nvim/commit/af5e8bd9f2b4de6ddb94e1236ae207e016b1e19f))
* display history entry index in register popup ([30cdf31](https://github.com/you-n-g/simplegpt.nvim/commit/30cdf31e2ed0de26a9daddfa2ce537fd02996da8))
* enhance code_explain template with full file description guidance ([5a97650](https://github.com/you-n-g/simplegpt.nvim/commit/5a97650e9443ce7fcbb3d363779b9bc7d0809454))
* highlight non-existent file paths in Files popup ([e33fb1d](https://github.com/you-n-g/simplegpt.nvim/commit/e33fb1d7858ee013c21049a91ecffc0f8dca8b3d))


### Bug Fixes

* notify user on API error in chat completions and buf chat ([e1e9798](https://github.com/you-n-g/simplegpt.nvim/commit/e1e97987cb2dc44378eef96431a4c66526c690c3))
* refine the context notation explanation ([7343385](https://github.com/you-n-g/simplegpt.nvim/commit/7343385427c8526bb5cb754838d266c4b5f218e6))
* set visual selection to current line if none is selected in DiffPopup ([57223e0](https://github.com/you-n-g/simplegpt.nvim/commit/57223e0c7cbcc8f83f25b14168122cc5595a3cfd))

## [2.0.0](https://github.com/you-n-g/simplegpt.nvim/compare/v1.3.0...v2.0.0) (2025-05-23)


### ⚠ BREAKING CHANGES

* **config:** breaking change - update shortcut registration and config formatting

### Features

* add custom highlight for placeholders in template popup ([e5c9def](https://github.com/you-n-g/simplegpt.nvim/commit/e5c9def4262424547616eb3a4f41219c2cfe76ba))
* add full_terminal and chat answer navigation keymaps ([ea10dfb](https://github.com/you-n-g/simplegpt.nvim/commit/ea10dfb8afc6305bc17c9cd601929d8e31b0ec11))
* add message extmark styling and update line indexing ([fcbc7b9](https://github.com/you-n-g/simplegpt.nvim/commit/fcbc7b978415dce2e91fa3e15c09b3f6daa5aad0))
* add provider option for buffer chat completions ([681a04a](https://github.com/you-n-g/simplegpt.nvim/commit/681a04a3f104fc4943e1218e1d8d2ce5e4c847ad))
* add terminal section in question template ([92f667b](https://github.com/you-n-g/simplegpt.nvim/commit/92f667b773e5e9e00f7559248c918f64e1e5d2e7))
* annotate omitted lines in content and context output ([c29714e](https://github.com/you-n-g/simplegpt.nvim/commit/c29714eec6f48ff7abd6139b5c3bf508591a465f))
* code_review ([d41e66e](https://github.com/you-n-g/simplegpt.nvim/commit/d41e66e89b89f30d9c719ce4a8179a03816d12ec))
* improve buf_chat parsing, formatting, and default system prompt ([bc7f1ca](https://github.com/you-n-g/simplegpt.nvim/commit/bc7f1ca43eb3df11a9eb1b8378df81209f5842bf))
* integrate spinner for chat completions and schedule API call ([3a5d520](https://github.com/you-n-g/simplegpt.nvim/commit/3a5d520ec22c2593aa06aa5bb7623160140d36a5))
* support buffer chat! ([69ce2d7](https://github.com/you-n-g/simplegpt.nvim/commit/69ce2d7cb39b86563e35fc6ca83a7ff1d4ca5c44))
* support path when rewriting. ([4fcf280](https://github.com/you-n-g/simplegpt.nvim/commit/4fcf280e1ab5752d37846faf7b5609340370d863))


### Bug Fixes

* patch tpl values to convert empty strings to nil ([9f8d18b](https://github.com/you-n-g/simplegpt.nvim/commit/9f8d18b2df5546e01a61c4ce7da8878f07f0c484))
* update config mappings to use search_replace and code_only ([63b565f](https://github.com/you-n-g/simplegpt.nvim/commit/63b565f417cfc67405ec27cf7e55e9687d9746a6))
* update error template to include filename and new code fences ([174e485](https://github.com/you-n-g/simplegpt.nvim/commit/174e48528bebec716fffe6bf80c851014503159f))


### Code Refactoring

* **config:** breaking change - update shortcut registration and config formatting ([6f7defb](https://github.com/you-n-g/simplegpt.nvim/commit/6f7defb331a4f4727264aeea37531320c75046c2))

## [1.3.0](https://github.com/you-n-g/simplegpt.nvim/compare/v1.2.0...v1.3.0) (2025-03-20)


### Features

* Add conditional visual content section to question template ([5d71d7d](https://github.com/you-n-g/simplegpt.nvim/commit/5d71d7de151c19a3abb907aec49d5c7af0592fb5))
* Add LSP diagnostics fix command and template ([150bf3d](https://github.com/you-n-g/simplegpt.nvim/commit/150bf3dcc53dbfa49f74223f133e0433aa63ba7a))
* Add preview_keys functionality and InfoDialog class for displaying information ([1bc520d](https://github.com/you-n-g/simplegpt.nvim/commit/1bc520d6e436c6ab2ef9fabeab3ee59c45e1dd3d))
* add search and replace functionality with key mappings ([#7](https://github.com/you-n-g/simplegpt.nvim/issues/7)) ([7d245aa](https://github.com/you-n-g/simplegpt.nvim/commit/7d245aa92efb8e220da1315af018a872b6eddfb6))
* Add support for handling current line when no visual selection ([0c176e5](https://github.com/you-n-g/simplegpt.nvim/commit/0c176e522792ccb1fd067f388952a7fb6bde1cd7))
* Add terminal buffer handling and improve code consistency ([d39b96a](https://github.com/you-n-g/simplegpt.nvim/commit/d39b96a37d19fce4ee0aa510e3696f7ea56243d5))
* Add terminal command support and template for simplegpt ([87971fe](https://github.com/you-n-g/simplegpt.nvim/commit/87971fe6eb50f00652ce7569a3b531525a2abf32))
* Add terminal output handling in code_complete.json template ([e1b1ec9](https://github.com/you-n-g/simplegpt.nvim/commit/e1b1ec9aaa45df1158ca8984d7d1df57cfe8cc62))
* Add toggle dialog functionality and improve keymap handling ([9bda560](https://github.com/you-n-g/simplegpt.nvim/commit/9bda56069c8e0383b7916262cee33240898ba82c))
* Add window switch functionality to BaseDialog methods ([d5802e3](https://github.com/you-n-g/simplegpt.nvim/commit/d5802e34e7213c64bc36ffeeab73b24ac864dc93))
* enhance context with markdown, filename, file selection, terminal.  better template structure. ([#8](https://github.com/you-n-g/simplegpt.nvim/issues/8)) ([d331493](https://github.com/you-n-g/simplegpt.nvim/commit/d331493461a7b0eaee538eec10a133a5bf4a2ee8))
* Fix tpl focus & Add LSP diagnostics info retrieval in RegQAUI.get_special function ([492e7a2](https://github.com/you-n-g/simplegpt.nvim/commit/492e7a27f3ef0b85c0eb8ffc705a24d40011aafe))


### Bug Fixes

* Correct JSON key from 'q' to 'q-' in terminal.json ([274a500](https://github.com/you-n-g/simplegpt.nvim/commit/274a5006392ecd1bfd1bdbea4d6cf704e6144cea))

## [1.2.0](https://github.com/you-n-g/simplegpt.nvim/compare/v1.1.0...v1.2.0) (2025-01-01)


### Features

* add condition for error fixing ([2248e1e](https://github.com/you-n-g/simplegpt.nvim/commit/2248e1e9fd6a53aa1f8b9fcb6ed59beffaf3049c))
* Add multi-round conversation support with context in chat dialog ([7da7344](https://github.com/you-n-g/simplegpt.nvim/commit/7da7344086c599172ab55bd5f008bd9b08922241))
* Add show_value keymap and functionality for special value display ([97f4baa](https://github.com/you-n-g/simplegpt.nvim/commit/97f4baa561c71dd3de2c00e19d00a5f9c18548ca))
* Add support for custom keyboard shortcuts in simplegpt ([17d67c3](https://github.com/you-n-g/simplegpt.nvim/commit/17d67c3e1270ba8c64496c1cbfef45160b5ec513))
* Add support for custom template paths in loader module ([3b7f826](https://github.com/you-n-g/simplegpt.nvim/commit/3b7f826150e1535f878780a102258b916a465b22))
* enhance visual selection handling and key mappings in dialog and utils ([d242bdd](https://github.com/you-n-g/simplegpt.nvim/commit/d242bddf81dcbbb4a6e42af80ea20dd1578eae15))
* improved translate ([da049f3](https://github.com/you-n-g/simplegpt.nvim/commit/da049f386dbc8b24b23650ece2b01d0e3c22fc65))
* refactor shortcuts ([5b7b6a3](https://github.com/you-n-g/simplegpt.nvim/commit/5b7b6a3a3dd34d4d11dad8b12eefc7e0d73e2e43))
* Update code completion templates and adjust configuration settings ([6632c56](https://github.com/you-n-g/simplegpt.nvim/commit/6632c56a16f5b8a8cd3b34218496f173f346f4d7))


### Bug Fixes

* append naming error ([f546967](https://github.com/you-n-g/simplegpt.nvim/commit/f5469677ded447033a732c66672a1bdd9788345f))
* correct column selection logic in visual mode ([3b9733e](https://github.com/you-n-g/simplegpt.nvim/commit/3b9733ebe5d200244f7db4c63a14dfc4e9f225b0))
* Correct key mappings and formatting in README and Lua files ([6bdab62](https://github.com/you-n-g/simplegpt.nvim/commit/6bdab629fe5cec442f257d4b5db84c64cd48498d))
* format ([3fc60ff](https://github.com/you-n-g/simplegpt.nvim/commit/3fc60ffe0be19ca7785751f46469c778bcee1c38))

## [1.1.0](https://github.com/you-n-g/simplegpt.nvim/compare/v1.0.1...v1.1.0) (2024-11-22)


### Features

* improve translate ([38a3698](https://github.com/you-n-g/simplegpt.nvim/commit/38a369824b87b6cae95b8b8d1946bc3b4300fe98))
* support all buffer ([2dcaef6](https://github.com/you-n-g/simplegpt.nvim/commit/2dcaef68d182bc57a10e859c1b36459b09a46b67))
* support template engine ([fd79869](https://github.com/you-n-g/simplegpt.nvim/commit/fd7986915b35220d48676e6a5277740e9fe60b82))


### Bug Fixes

* use show and hide control the text ([19556d9](https://github.com/you-n-g/simplegpt.nvim/commit/19556d9a9955f3756c6c01f7fc11aa39672d6975))
* variable naming bug ([7baca7a](https://github.com/you-n-g/simplegpt.nvim/commit/7baca7a41730040b57ca83fa05e230d1d4385999))

## [1.0.1](https://github.com/you-n-g/simplegpt.nvim/compare/v1.0.0...v1.0.1) (2024-08-02)


### Bug Fixes

* **CI:** Update CI tasks ([f875ec1](https://github.com/you-n-g/simplegpt.nvim/commit/f875ec14c655b9eed53a4b7d0874fa1cbdf2e7a0))
* refine document ([06ba0c1](https://github.com/you-n-g/simplegpt.nvim/commit/06ba0c1be624a8304ef3842de480f20feb596664))

## 1.0.0 (2024-03-25)


### Features

* Add release ([3b6cb57](https://github.com/you-n-g/simplegpt.nvim/commit/3b6cb5782781292244764bc2bb00602657d1ed5d))


### Bug Fixes

* merge ci ([65b5052](https://github.com/you-n-g/simplegpt.nvim/commit/65b505260d604617c11fd28598a33559d9690ef7))
