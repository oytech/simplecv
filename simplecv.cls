\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{simplecv}[2025/04/23 Simple CV LaTeX class]

%
% Font / Encoding
%

% Based on article class with a4 paper size and 11pt font size
\LoadClass[a4paper,10pt]{article}

% Set output font encoding with support for European accented characters
\RequirePackage[T1]{fontenc}

% Set input encoding to UTF-8
\RequirePackage[utf8]{inputenc}

% Improve typography
\RequirePackage{microtype}

% Change default font to default sans serif font
\renewcommand{\familydefault}{\sfdefault}

% Define sections font to huge size, medium weight, upright italic
\newcommand{\cvsectionstyle}[1]{\huge\mdseries\upshape{#1}}

% Define footer font
\newcommand{\cvsfooterstyle}[1]{\footnotesize{#1}}

%
% Layout
%

% Increase printable area size
\RequirePackage[scale=0.85]{geometry}

% Improve paragraph indentation and spacing
\RequirePackage{parskip}

% Enable arithmetic operators for lengths calculations
\RequirePackage{calc}

% Define left column hints with 21% width
\newlength{\cvhintscolwidth}
\setlength{\cvhintscolwidth}{0.21\textwidth}

\newcommand{\cvhints}[1]{
  \begin{minipage}[t]{\cvhintscolwidth}
    \begin{flushright}
      #1
    \end{flushright}
  \end{minipage}
}

% Define seperator between columns as 4% width
\newlength{\sepcolwidth}
\setlength{\sepcolwidth}{0.04\textwidth}

% Define main column with remaining width
\newlength{\cvmaincolwidth}
\setlength{\cvmaincolwidth}{\textwidth-\sepcolwidth-\cvhintscolwidth}

\newcommand{\cvmain}[1]{
  \hfill
  \begin{minipage}[t]{\cvmaincolwidth}
    #1
  \end{minipage}
}

% Define section
\newlength{\cvline}
\setlength{\cvline}{1ex}

\newlength{\cvsectionletterheight}
\settoheight{\cvsectionletterheight}{\cvsectionstyle{D}}

\newlength{\cvsectionletterwidth}
\settowidth{\cvsectionletterwidth}{\cvsectionstyle{x}}

\newlength{\cvsectionparindent}
\setlength{\cvsectionparindent}{0.8\cvline+0.5\cvsectionletterwidth}

\newcommand{\cvsection}[1]{
  \begin{minipage}[t]{\cvhintscolwidth}
    \setlength{\parindent}{-\cvsectionparindent}
    \rule{0.8\cvline}{\cvsectionletterheight}%
    \hspace{0.4\cvsectionletterwidth}%
    \cvsectionstyle{#1}
  \end{minipage}
}

% Customize headers and footers
\RequirePackage{fancyhdr}
\pagestyle{fancy}

% Clear all default header and footer fields
\fancyhf{}

% Disable header and footer lines
\renewcommand{\headrulewidth}{0pt}
\renewcommand{\footrulewidth}{0pt}

% Define header with scalable first and last name
\RequirePackage{adjustbox}

\newcommand{\cvfirstname}{}
\newcommand{\cvlastname}{}

\newcommand{\cvheader}{
  \cvhints{
    \adjustbox{width=\cvhintscolwidth,trim=0.2ex 0pt 0px 0pt}{\cvfirstname}
    \adjustbox{width=\cvhintscolwidth,trim=0.2ex 0pt 0px 0pt}{\cvlastname}
    \rule{\cvhintscolwidth}{\cvline}
  }
}

% Define left aligned footer
\newcommand{\cvfooter}[1]{\lfoot{\cvsfooterstyle{#1}}}
