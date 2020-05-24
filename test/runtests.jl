using Test
using ImageIO
using FileIO: File, DataFormat, Stream, @format_str

@testset "ImageIO" begin

    @testset "PNGs" begin
        img = rand(UInt8, 10, 10)
        f = File{DataFormat{:PNG}}("test_fpath.png")
        ImageIO.save(f, img)
        img_saveload = ImageIO.load(f)
        @test all(img .== reinterpret(UInt8, img_saveload))
        
        open(io->ImageIO.save(Stream(format"PNG", io), img), "test_io.png", "w")
        img_saveload = open(io->ImageIO.load(Stream(format"PNG", io)), "test_io.png")
        @test all(img .== reinterpret(UInt8, img_saveload))
    end

end

rm("test_fpath.png", force=true)
rm("test_io.png", force=true)
