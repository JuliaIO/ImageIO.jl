# ImageIO.jl

FileIO.jl integration for image files

![Julia version](https://img.shields.io/badge/julia-%3E%3D%201.3-blue)
[![Run tests](https://github.com/JuliaIO/ImageIO.jl/actions/workflows/test.yml/badge.svg)](https://github.com/JuliaIO/ImageIO.jl/actions/workflows/test.yml)
[![Codecov](https://codecov.io/gh/JuliaIO/ImageIO.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaIO/ImageIO.jl)

Currently provides:
- [PNGFiles.jl](https://github.com/JuliaIO/PNGFiles.jl) for Portable Network Graphics via libpng - ([Benchmark vs. ImageMagick & QuartzImageIO](https://github.com/JuliaIO/PNGFiles.jl/issues/1#issuecomment-586749654))
- [Netpbm.jl](https://github.com/JuliaIO/Netpbm.jl) for Portable Bitmap formats (in pure Julia)
- [TiffImages.jl](https://github.com/tlnagy/TiffImages.jl) for TIFFs (in pure Julia)
- [OpenEXR.jl](https://github.com/twadleigh/OpenEXR.jl) for OpenEXR files (wrapping the C API provided by the [OpenEXR](https://github.com/AcademySoftwareFoundation/openexr) library)
- [QOI.jl](https://github.com/KristofferC/QOI.jl) for [QOI](https://qoiformat.org/) files (in pure Julia)


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

## Compatibility

This package requires Julia at least v1.3. For old Julia versions, a dummy ImageIO version v0.0.1 with no real function will be installed.
In this case, you still need to install [ImageMagick.jl] to make `FileIO.save`/`FileIO.load` work.

[ImageMagick.jl]: https://github.com/JuliaIO/ImageMagick.jl
