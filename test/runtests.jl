using Test
using ImageIO
using FileIO: File, DataFormat

@testset "ImageIO" begin

    @testset "PNGs" begin
        img = rand(UInt8, 10, 10)
        f = File{DataFormat{:PNG}}("test.png")
        ImageIO.save(f, img)
        img_saveload = ImageIO.load(f)
        @test all(img .== reinterpret(UInt8, img_saveload))
    end

end

isfile("test.png") && rm("test.png")
