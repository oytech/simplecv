pdf:
    pdflatex example.tex

png:
    pdftoppm example.pdf example -png -f 1 -singlefile -r 300
