# ImageIO.jl

FileIO.jl integration for image files

[![Build Status](https://travis-ci.org/JuliaIO/ImageIO.jl.svg?branch=master)](https://travis-ci.org/JuliaIO/ImageIO.jl)
[![Codecov](https://codecov.io/gh/JuliaIO/ImageIO.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaIO/ImageIO.jl)

Currently provides:
- PNGFiles.jl for Portable Network Graphics via libpng - ([Benchmark vs. ImageMagick & QuartzImageIO](https://github.com/JuliaIO/PNGFiles.jl/issues/1#issuecomment-586749654))


## Installation

Install with Pkg:

```jl
pkg> add ImageIO  # Press ']' to enter te Pkg REPL mode
```

## Usage

```jl
using FileIO
save("test.png", rand(Gray, 100, 100))
load("test.png")
```
