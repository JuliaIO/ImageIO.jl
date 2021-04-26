@testset "PNGs" begin
    for typ in [UInt8, N0f8, Gray{N0f8}, RGB{N0f8}] # TODO: Fix 0:1, Gray{Float64}, RGB{Float64} in PNGFiles
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
end
