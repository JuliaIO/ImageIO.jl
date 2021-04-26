using Test
using ImageIO
using FileIO: File, DataFormat, Stream, @format_str
using ImageCore: N0f8, RGB, Gray

function is_backend_available(pkgid)
    try
        Base.require(pkgid) # this has side-effects
        return true
    catch
        return false
    end
end

tmpdir = mktempdir()
Threads.nthreads() <= 1 && @info "Threads.nthreads() = $(Threads.nthreads()), multithread tests will be disabled"
@testset "ImageIO" begin
    if Threads.nthreads() > 1 ## NOTE: This test must go first, to test that PNGFiles loading behaves correctly
        @testset "Threaded save" begin
            # test that loading of PNGFiles happens sequentially and doesn't segfault
            img = rand(UInt8, 10, 10)
            Threads.@threads for i in 1:Threads.nthreads()
                f = File{DataFormat{:PNG}}(joinpath(tmpdir, "test_fpath_$i.png"))
                ImageIO.save(f, img)
            end
        end
    end

    is_PNGFiles_available = is_backend_available(ImageIO.idPNGFiles)
    if is_PNGFiles_available # should be always true, otherwise "Threaded save" would just fail.
        include("png.jl")
    else
        @warn "PNGFiles not available, skip \"PNGs\" testset."
        @testset "PNGs" begin end
    end

    is_Netpbm_available = is_backend_available(ImageIO.idNetpbm)
    if is_Netpbm_available
        include("pbm.jl")
    else
        @warn "Netpbm not available, skip \"Portable bitmap\" test."
        @testset "Portable bitmap" begin end
    end

    is_TiffImages_available = is_backend_available(ImageIO.idTiffImages)
    if is_TiffImages_available
        include("tiff.jl")
    else
        @warn "TiffImages not available, skip \"TIFF\" test."
        @testset "TIFF" begin end
    end
end
