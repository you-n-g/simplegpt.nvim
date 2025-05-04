# Changelog

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
