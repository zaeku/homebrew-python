# Overview

This repository contains formulae for [Homebrew](https://github.com/mxcl/homebrew) with a special focus on **Python** libraries not yet well supported by `pip install x` due to compilation and dependency issues.


## Formulae you find here

* Numpy (linked with suite-sparse (amd,umfpack) and optionally openBLAS)
* SciPy
* PyOpenCL
* _Open an issue if your favorite is missing_


## Quick Start

To install 

 * `brew tap samueljohn/python`
 * `brew install scipy`


## Alternative install method : Raw URL

First, grab the raw URL for the formula you want by clicking on the "raw" button. For example, the raw URL for the `scipy` formula is:

```
    https://raw.github.com/samueljohn/homebrew-python/master/scipy.rb
```

Once you know the raw URL, simply use `brew install [raw URL]`.



That's it!
