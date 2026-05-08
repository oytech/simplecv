# translate example.md into latex and then generate pdf
default: tex pdf

# generate pdf from example.tex
pdf:
    pdflatex example.tex

# print pdf to png image
png:
    pdftoppm example.pdf example -png -f 1 -singlefile -r 300

# extract and print plain text from pdf
txt:
    pdftotext example.pdf -

# generate example.tex from example.md using pandoc
tex:
    pandoc \
        -f commonmark+fenced_divs+yaml_metadata_block \
        -t latex \
        --template=pandoc/template.tex \
        --lua-filter=pandoc/simplecv.lua \
        example.md -o example.tex

# print pandoc AST parsed from example.md
ast:
    pandoc \
        -f commonmark+fenced_divs+yaml_metadata_block \
        -t native \
        --template=pandoc/template.tex \
        --lua-filter=pandoc/simplecv.lua \
        --wrap=preserve \
        example.md
