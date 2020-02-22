# ImageIO.jl

(work in progress) FileIO.jl integration for image files

[![Build Status](https://travis-ci.com/JuliaIO/ImageIO.jl.svg?branch=master)](https://travis-ci.com/JuliaIO/ImageIO.jl)
[![Codecov](https://codecov.io/gh/JuliaIO/ImageIO.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaIO/ImageIO.jl)

## Installation

Install with Pkg:

```jl
pkg> add ImageIO  # Press ']' to enter te Pkg REPL mode.
```

## Usage

```jl
using FileIO
save("test.png", rand(Gray, 100, 100))
load("test.png")
```
