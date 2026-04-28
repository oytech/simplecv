pdf:
    pdflatex example.tex

png:
    pdftoppm example.pdf example -png -f 1 -singlefile -r 300

txt:
    pdftotext example.pdf -

tex:
    pandoc \
        -f commonmark+fenced_divs+yaml_metadata_block \
        -t latex \
        --template=pandoc/template.tex \
        --lua-filter=pandoc/simplecv.lua \
        example.md -o example.tex

ast:
    pandoc \
        -f commonmark+fenced_divs+yaml_metadata_block \
        -t native \
        --template=pandoc/template.tex \
        --lua-filter=pandoc/simplecv.lua \
        --wrap=preserve \
        example.md
