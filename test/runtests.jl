using Test
using ImageIO
using FileIO: File, DataFormat, Stream, @format_str
using ImageCore: N0f8, RGB, Gray

tmpdir = mktempdir()
Threads.nthreads() <= 1 && @info "Threads.nthreads() = $(Threads.nthreads()), multithread tests will be disabled"
@testset "ImageIO" begin

    @testset "PNGs" begin
        for typ in [0:1, UInt8, N0f8, Gray{N0f8}, Gray{Float64}, RGB{N0f8}, RGB{Float64}]
            @testset "$typ PNG" begin
                img = rand(typ, 10, 10)
                f = File{DataFormat{:PNG}}(joinpath(tmpdir, "test_fpath.png"))
                ImageIO.save(f, img)
                img_saveload = ImageIO.load(f)
                if typ == UInt8
                    @test all(img .== reinterpret(UInt8, img_saveload))
                else
                    @test img == img_saveload
                end

                open(io->ImageIO.save(Stream(format"PNG", io), img, permute_horizontal=false), joinpath(tmpdir, "test_io.png"), "w")
                img_saveload = open(io->ImageIO.load(Stream(format"PNG", io)), joinpath(tmpdir, "test_io.png"))
                if typ == UInt8
                    @test all(img .== reinterpret(UInt8, img_saveload))
                else
                    @test img == img_saveload
                end
            end
        end
        if Threads.nthreads() > 1
            @testset "Threaded save" begin
                # test that loading of PNGFiles happens sequentially and doesn't segfault
                img = rand(UInt8, 10, 10)
                Threads.@threads for i in 1:Threads.nthreads()
                    f = File{DataFormat{:PNG}}(joinpath(tmpdir, "test_fpath_$i.png"))
                    ImageIO.save(f, img)
                end
            end
        end
    end

    @testset "Portable bitmap" begin
        for typ in [0:1, N0f8, Gray{N0f8}, Gray{Float64}, RGB{N0f8}, RGB{Float64}]
            @testset "$typ pgm" begin
                img = rand(typ, 10, 10)
                for fmt in (format"PGMBinary", format"PGMText")
                    f = File{fmt}(joinpath(tmpdir, "test_fpath.pgm"))
                    ImageIO.save(f, img)
                    img_saveload = ImageIO.load(f)
                    @test img == img_saveload

                    open(io->ImageIO.save(Stream(fmt, io), img), joinpath(tmpdir, "test_io.pgm"), "w")
                    img_saveload = open(io->ImageIO.load(Stream(fmt, io)), joinpath(tmpdir, "test_io.pgm"))
                    @test img == img_saveload
                end
            end
        end
    end

    @testset "TIFF" begin
        for typ in [Gray{N0f8}, Gray{Float64}, RGB{N0f8}, RGB{Float64}] # TODO: Add UInt8, N0f8 support in TiffImages
            @testset "$typ TIFF" begin
                img = rand(typ, 10, 10)
                f = File{format"TIFF"}(joinpath(tmpdir, "test_fpath.tiff"))
                ImageIO.save(f, img)
                img_saveload = ImageIO.load(f)
                @test img == img_saveload

                open(io->ImageIO.save(Stream(format"TIFF", io), img), joinpath(tmpdir, "test_io.tiff"), "w")
                img_saveload = open(io->ImageIO.load(Stream(format"TIFF", io)), joinpath(tmpdir, "test_io.tiff"))
                @test img == img_saveload
            end
        end
    end
end
