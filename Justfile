name := "example"

# translate example.md into latex and then generate pdf
default: tex pdf

# generate pdf from example.tex
pdf:
    pdflatex {{name}}.tex

# print pdf to png image
png:
    pdftoppm {{name}}.pdf {{name}} -png -f 1 -singlefile -r 300

# extract and print plain text from pdf
txt:
    pdftotext {{name}}.pdf -

# generate example.tex from example.md using pandoc
tex:
    pandoc \
        -f commonmark+fenced_divs+yaml_metadata_block \
        -t latex \
        --template=pandoc/template.tex \
        --lua-filter=pandoc/simplecv.lua \
        {{name}}.md -o {{name}}.tex

# print pandoc AST parsed from example.md
ast:
    pandoc \
        -f commonmark+fenced_divs+yaml_metadata_block \
        -t native \
        --template=pandoc/template.tex \
        --lua-filter=pandoc/simplecv.lua \
        --wrap=preserve \
        {{name}}.md
