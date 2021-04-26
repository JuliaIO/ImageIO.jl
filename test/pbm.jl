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
