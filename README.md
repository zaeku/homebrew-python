# Overview #

This repository contains formulae for [Homebrew](http://mxcl.github.com/homebrew/) with a special focus on **Python** libraries not yet well supported by `pip install x` due to compilation and dependency issues.


## Formulae you find here ##

*   **Numpy**
    -   using *suite-sparse* for fast sparse matrices (amd,umfpack)
    -   optionally link against the *openBLAS* (--with-openblas)
    -   use `--devel` or `--HEAD` to get the latest greatest.
*   **SciPy**
    -   optionally link against the *openBLAS* (--with-openblas)
    -   If you want, turn around your `--HEAD`
*   **Matplotlib**
    -   Support all optional deps, installable by brew
        (e.g. PyGTK, cairo, ghostscript, tk, freetype and libpng)
*   **PIL** (`brew install pillow`)
    -   The *Python Image Library* in the newer distribution named "pillow"
    -   Support for zlib/PNG
    -   Based on the fast(er) *graphicsmagick* (imagemagick compatible)
    -   *Freetype2* support
    -   *Little-CMS* (for color management)
*   **PyGame** (Game development and provides bindings to SDL)
*   **Pmw** (Python Megawidgets)
    -   A dead project, but its not in PyPI, so we have it here.
*   _Open an issue if your favorite is missing_


## Install ##

*   `brew tap samueljohn/python`
*   `brew install scipy`
*   `brew test scipy --verbose`


## Python ##

Right now, only Python 2.7.x is supported. This will change in the near future.

I recommend to install a brewed Python: `brew install python`
Because it's distutils knows already about the right flags to pass to the C compiler in order to find libs includes of other brewed software and the Apple frameworks (even if you don't have the "Command Line Tools for Xcode.")
Read more aboute [Homebrew and Python][1]


## Acceptable formulae in this tap ##

*   Software has to be maintained and alive
    -   No updates in the last five years -> I consider it dead.
*   Not your own little Python modules. Try to get them into PyPi first.
*   A simple `pip intall <x>` has to fail either
    -   because it needs other software to be brewed first, or
    -   because it builds C-extensions that need special treatment
        (gfortran,lapack)
*   It has to be Python software. Others should go into main homebrew.


## How to add a new formulae here ##

*   Fork my repository on github.
*   Clone to your Mac.
*   Read [Homebrew and Python][1] and look at the other formulae here.
*   In your local `homebrew-python` repo, create a new branch:
    `git checkout --branch my_new_formulae`
*   Write your formulae. Check the Homebrew wiki for details.
*   Test it. Does it install?
*   `git push --set-upstream origin my_new_formulae`
    to get it into your github as a new branch.
*   If you have to change something, add a commit and `git push`.
*   On github, select your new branch and then click the
    "Pull Request" button.


[1]: https://github.com/mxcl/homebrew/wiki/Homebrew-and-Python
