module ImageIO

using FileIO: File, DataFormat, Stream, stream

## PNGs
const PNGFiles_LOADED = Ref(false)

function load(f::File{DataFormat{:PNG}}; kwargs...)
    if !PNGFiles_LOADED[]
        @eval ImageIO import PNGFiles
        PNGFiles_LOADED[] = isdefined(ImageIO, :PNGFiles)
    end
    return Base.invokelatest(PNGFiles.load, f.filename, kwargs...)
end
function load(s::Stream{DataFormat{:PNG}}; kwargs...)
    if !PNGFiles_LOADED[]
        @eval ImageIO import PNGFiles
        PNGFiles_LOADED[] = isdefined(ImageIO, :PNGFiles)
    end
    return Base.invokelatest(PNGFiles.load, stream(s), kwargs...)
end
function load(s::IO; kwargs...)
    if !PNGFiles_LOADED[]
        @eval ImageIO import PNGFiles
        PNGFiles_LOADED[] = isdefined(ImageIO, :PNGFiles)
    end
    return Base.invokelatest(PNGFiles.load, s, kwargs...)
end

function save(f::File{DataFormat{:PNG}}, image::S; kwargs...) where {T, S<:Union{AbstractMatrix, AbstractArray{T,3}}}
    if !PNGFiles_LOADED[]
        @eval ImageIO import PNGFiles
        PNGFiles_LOADED[] = isdefined(ImageIO, :PNGFiles)
    end
    return Base.invokelatest(PNGFiles.save, f.filename, image, kwargs...)
end
function save(s::Stream{DataFormat{:PNG}}, image::S; permute_horizontal=false, mapi=identity, kwargs...) where {T, S<:Union{AbstractMatrix, AbstractArray{T,3}}}
    if !PNGFiles_LOADED[]
        @eval ImageIO import PNGFiles
        PNGFiles_LOADED[] = isdefined(ImageIO, :PNGFiles)
    end
    imgout = copy(image)
    if permute_horizontal
        permutedims!(imgout, imgout, (2,1))
    end
    if mapi != identity
        map!(mapi, imgout, imgout)
    end
    return Base.invokelatest(PNGFiles.save, stream(s), imgout, kwargs...)
end

end # module
