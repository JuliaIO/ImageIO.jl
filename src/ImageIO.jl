module ImageIO

using FileIO: File, DataFormat, Stream, stream, _findmod, topimport

const load_locker = Base.ReentrantLock()

function checked_import(pkg::Symbol)
    lock(load_locker) do
        if isdefined(Main, pkg)
            m1 = getfield(Main, pkg)
            isa(m1, Module) && return m1
        end
        if isdefined(ImageIO, pkg)
            m1 = getfield(ImageIO, pkg)
            isa(m1, Module) && return m1
        end
        m = _findmod(pkg)
        m == nothing || return Base.loaded_modules[m]
        topimport(pkg)
        return Base.loaded_modules[_findmod(pkg)]
    end
end

## PNGs

function load(f::File{DataFormat{:PNG}}; kwargs...)
    return Base.invokelatest(checked_import(:PNGFiles).load, f.filename, kwargs...)
end
function load(s::Stream{DataFormat{:PNG}}; kwargs...)
    return Base.invokelatest(checked_import(:PNGFiles).load, stream(s), kwargs...)
end
function load(s::IO; kwargs...)
    return Base.invokelatest(checked_import(:PNGFiles).load, s, kwargs...)
end

function save(f::File{DataFormat{:PNG}}, image::S; kwargs...) where {T, S<:Union{AbstractMatrix, AbstractArray{T,3}}}
    return Base.invokelatest(checked_import(:PNGFiles).save, f.filename, image, kwargs...)
end
function save(s::Stream{DataFormat{:PNG}}, image::S; kwargs...) where {T, S<:Union{AbstractMatrix, AbstractArray{T,3}}}
    return Base.invokelatest(checked_import(:PNGFiles).save, stream(s), image, kwargs...)
end

end # module
