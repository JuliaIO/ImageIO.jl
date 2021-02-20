using Test
using ImageIO
using FileIO: File, DataFormat, Stream, @format_str
using ImageCore: N0f8, RGB

tmpdir = mktempdir()
Threads.nthreads() <= 1 && @info "Threads.nthreads() = $(Threads.nthreads()), multithread tests will be disabled"
@testset "ImageIO" begin

    @testset "PNGs" begin

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
        img = rand(UInt8, 10, 10)
        f = File{DataFormat{:PNG}}(joinpath(tmpdir, "test_fpath.png"))
        ImageIO.save(f, img)
        img_saveload = ImageIO.load(f)
        @test all(img .== reinterpret(UInt8, img_saveload))

        open(io->ImageIO.save(Stream(format"PNG", io), img, permute_horizontal=false), joinpath(tmpdir, "test_io.png"), "w")
        img_saveload = open(io->ImageIO.load(Stream(format"PNG", io)), joinpath(tmpdir, "test_io.png"))
        @test all(img .== reinterpret(UInt8, img_saveload))
    end

    @testset "Portable bitmap" begin

        @testset "Bicolor pbm" begin
            img = rand(0:1, 10, 10)
            for fmt in (format"PBMBinary", format"PBMText")
                f = File{fmt}(joinpath(tmpdir, "test_fpath.pbm"))
                ImageIO.save(f, img)
                img_saveload = ImageIO.load(f)
                @test img == img_saveload

                open(io->ImageIO.save(Stream(fmt, io), img), joinpath(tmpdir, "test_io.pbm"), "w")
                img_saveload = open(io->ImageIO.load(Stream(fmt, io)), joinpath(tmpdir, "test_io.pbm"))
                @test img == img_saveload
            end
        end

        @testset "Gray pgm" begin
            img = rand(N0f8, 10, 10)
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

        @testset "Color ppm" begin
            img = rand(RGB{N0f8}, 10, 10)
            for fmt in (format"PPMBinary", format"PPMText")
                f = File{fmt}(joinpath(tmpdir, "test_fpath.ppm"))
                ImageIO.save(f, img)
                img_saveload = ImageIO.load(f)
                @test img == img_saveload

                open(io->ImageIO.save(Stream(fmt, io), img), joinpath(tmpdir, "test_io.ppm"), "w")
                img_saveload = open(io->ImageIO.load(Stream(fmt, io)), joinpath(tmpdir, "test_io.ppm"))
                @test img == img_saveload
            end
        end
    end

    @testset "TIFF" begin

        @testset "Gray TIFF" begin
            img = rand(N0f8, 10, 10)
            for fmt in (format"TIFF")
                f = File{fmt}(joinpath(tmpdir, "test_fpath.tiff"))
                ImageIO.save(f, img)
                img_saveload = ImageIO.load(f)
                @test img == img_saveload

                open(io->ImageIO.save(Stream(fmt, io), img), joinpath(tmpdir, "test_io.tiff"), "w")
                img_saveload = open(io->ImageIO.load(Stream(fmt, io)), joinpath(tmpdir, "test_io.tiff"))
                @test img == img_saveload
            end
        end

        @testset "Color TIFF" begin
            img = rand(RGB{N0f8}, 10, 10)
            for fmt in (format"TIFF")
                f = File{fmt}(joinpath(tmpdir, "test_fpath.tiff"))
                ImageIO.save(f, img)
                img_saveload = ImageIO.load(f)
                @test img == img_saveload

                open(io->ImageIO.save(Stream(fmt, io), img), joinpath(tmpdir, "test_io.tiff"), "w")
                img_saveload = open(io->ImageIO.load(Stream(fmt, io)), joinpath(tmpdir, "test_io.tiff"))
                @test img == img_saveload
            end
        end
    end
end
