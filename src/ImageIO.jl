module ImageIO

using FileIO: File, DataFormat, Stream

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
function save(s::Stream{DataFormat{:PNG}}, image::S; kwargs...) where {T, S<:Union{AbstractMatrix, AbstractArray{T,3}}}
    if !PNGFiles_LOADED[]
        @eval ImageIO import PNGFiles
        PNGFiles_LOADED[] = isdefined(ImageIO, :PNGFiles)
    end
    return Base.invokelatest(PNGFiles.save, stream(s), image, kwargs...)
end

end # module
