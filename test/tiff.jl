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
