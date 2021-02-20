# ImageIO.jl

FileIO.jl integration for image files

[![Build Status](https://travis-ci.org/JuliaIO/ImageIO.jl.svg?branch=master)](https://travis-ci.org/JuliaIO/ImageIO.jl)
[![Codecov](https://codecov.io/gh/JuliaIO/ImageIO.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaIO/ImageIO.jl)

Currently provides:
- [PNGFiles.jl](https://github.com/JuliaIO/PNGFiles.jl) for Portable Network Graphics via libpng - ([Benchmark vs. ImageMagick & QuartzImageIO](https://github.com/JuliaIO/PNGFiles.jl/issues/1#issuecomment-586749654))
- [Netpbm.jl](https://github.com/JuliaIO/Netpbm.jl) for Portable Bitmap formats (in pure Julia)
- [TiffImages.jl](https://github.com/tlnagy/TiffImages.jl) for TIFFs


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
save("test.ppm", rand(RGB, 100, 100))
load("test.ppm")
save("test.tiff", rand(RGB, 100, 100))
load("test.tiff")
```
