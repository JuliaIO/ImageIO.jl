module ImageIO

using FileIO: File, DataFormat, Stream, stream

const load_locker = Base.ReentrantLock()

function checked_import(pkg::Symbol)
    lock(load_locker) do
        if !isdefined(ImageIO, pkg)
            @eval ImageIO import $pkg
        end
    end
    return nothing
end

## PNGs

function load(f::File{DataFormat{:PNG}}; kwargs...)
    checked_import(:PNGFiles)
    return Base.invokelatest(PNGFiles.load, f.filename, kwargs...)
end
function load(s::Stream{DataFormat{:PNG}}; kwargs...)
    checked_import(:PNGFiles)
    return Base.invokelatest(PNGFiles.load, stream(s), kwargs...)
end
function load(s::IO; kwargs...)
    checked_import(:PNGFiles)
    return Base.invokelatest(PNGFiles.load, s, kwargs...)
end

function save(f::File{DataFormat{:PNG}}, image::S; kwargs...) where {T, S<:Union{AbstractMatrix, AbstractArray{T,3}}}
    checked_import(:PNGFiles)
    return Base.invokelatest(PNGFiles.save, f.filename, image, kwargs...)
end
function save(s::Stream{DataFormat{:PNG}}, image::S; kwargs...) where {T, S<:Union{AbstractMatrix, AbstractArray{T,3}}}
    checked_import(:PNGFiles)
    return Base.invokelatest(PNGFiles.save, stream(s), image, kwargs...)
end

end # module
