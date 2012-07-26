# Overview

This repository contains **unofficial** formulae for [Homebrew](https://github.com/mxcl/homebrew).  
With a special focus on **Python** projects not yet well supported by `pip install x`.

## Formulae you find here
* numpy
* scipy
* wxpython

## Quick Start

To install homebrew-alt formulae, use one of the following:

 * `brew install [raw GitHub URL]`
 * Via the new [brew-tap](https://github.com/mxcl/homebrew/pull/6086): See below.



# How This Repository Is Organized

  *   **duplicates**<br>
      These brews duplicate OS X functionality, though may provide newer or
      bug-fixed versions.  

      (Homebrew policy discourages duplicates, except in some specific cases.)

  *   **versions**<br>
      These formulae provide multiple versions of the same software package.

      (Homebrew policy is to maintain a single, stable version of a given
      package.)

  *   **other**<br>
      Other formulae that haven't been accepted into master.



# Installing homebrew-alt Formulae

There are two methods to install packages from this repository.


## Method 1: Raw URL

First, find the raw URL for the formula you want. For example, the raw URL for
the `scipy` formula is:

```
    https://raw.github.com/samueljohn/homebrew-alt/samuel/other/scipy.rb
```

Once you know the raw URL, simply use `brew install [raw URL]`, like so:

```
    brew install https://raw.github.com/samueljohn/homebrew-alt/samuel/other/scipy.rb
```


## Method 2: Use brew-tap

    cd `brew --prefix`  
    git checkout -b brew-tap  
    brew pull https://github.com/mxcl/homebrew/pull/6086  
    brew tap add samueljohn  
    brew tap install scipy  



That's it!
