module ImageIO

using FileIO: File, DataFormat

## PNGs
function load(f::File{DataFormat{:PNG}}; kwargs...)
    !isdefined(ImageIO, :PNGFiles) && @eval ImageIO import PNGFiles
    return PNGFiles.load(f.filename, kwargs...)
end
function save(f::File{DataFormat{:PNG}}, image::S; kwargs...) where {
        T,
        S<:Union{AbstractMatrix, AbstractArray{T,3}}
    }
    !isdefined(ImageIO, :PNGFiles) && @eval ImageIO import PNGFiles
    return PNGFiles.save(f.filename, image, kwargs...)
end

end # module
