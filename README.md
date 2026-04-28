## Simple CV
Simple CV is minimalistic template for creating CV.

You can either:
- write content in Markdown and then generate LaTeX document using `pandoc`
- modify LaTeX document directly

Check example files - [example.md](example.md), [example.tex](example.tex) (generated using `pandoc`).

## Usage
Project uses [Just command runner](https://github.com/casey/just). 

You can either run predefined commands with `just tex`, `just pdf` or copy them from [Justfile](Justfile).

LaTeX distribution is required, `pandoc` is optional (only for generating from Markdown).

## Preview [example.pdf](https://raw.githubusercontent.com/oytech/simplecv/main/example.pdf)
[![Résumé](https://raw.githubusercontent.com/oytech/simplecv/main/example.png)](https://raw.githubusercontent.com/oytech/simplecv/main/example.pdf)
