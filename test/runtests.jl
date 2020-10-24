using Test
using ImageIO
using FileIO: File, DataFormat, Stream, @format_str

tmpdir = mktempdir()
@testset "ImageIO" begin

    @testset "PNGs" begin

        @testset "Threaded save" begin
            # test that loading of PNGFiles happens sequentially and doesn't segfault
            img = rand(UInt8, 10, 10)
            Threads.@threads for i in 1:Threads.nthreads()
                f = File{DataFormat{:PNG}}(joinpath(tmpdir, "test_fpath_$i.png"))
                ImageIO.save(f, img)
            end
        end
        img = rand(UInt8, 10, 10)
        f = File{DataFormat{:PNG}}(joinpath(tmpdir, "test_fpath.png"))
        ImageIO.save(f, img)
        img_saveload = ImageIO.load(f)
        @test all(img .== reinterpret(UInt8, img_saveload))

        open(io->ImageIO.save(Stream(format"PNG", io), img), joinpath(tmpdir, "test_io.png"), "w")
        img_saveload = open(io->ImageIO.load(Stream(format"PNG", io)), joinpath(tmpdir, "test_io.png"))
        @test all(img .== reinterpret(UInt8, img_saveload))
    end

end
