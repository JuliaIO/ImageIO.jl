module ImageIO

using FileIO: File, DataFormat, Stream, stream, _findmod, topimport

const load_locker = Base.ReentrantLock()

function checked_import(pkg::Symbol)
    lock(load_locker) do
        if isdefined(ImageIO, pkg)
            m1 = getfield(ImageIO, pkg)
            isa(m1, Module) && return m1
        end
        if isdefined(Main, pkg)
            m1 = getfield(Main, pkg)
            isa(m1, Module) && return m1
        end
        m = _findmod(pkg)
        m == nothing || return Base.loaded_modules[m]
        @eval ImageIO import $pkg
        return Base.getfield(ImageIO, pkg)
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

function save(s::Stream{DataFormat{:PNG}}, image::S; permute_horizontal=false, mapi=identity, kwargs...) where {T, S<:Union{AbstractMatrix, AbstractArray{T,3}}}
    imgout = map(mapi, image)
    if permute_horizontal
        perm = ndims(imgout) == 2 ? (2, 1) : ndims(imgout) == 3 ? (2, 1, 3) : error("$(ndims(imgout)) dims array is not supported")
        return Base.invokelatest(checked_import(:PNGFiles).save, stream(s), PermutedDimsArray(imgout, perms), kwargs...) 
    else
        return Base.invokelatest(checked_import(:PNGFiles).save, stream(s), imgout, kwargs...)
    end
end

# Netpbm types

for NETPBMFORMAT in (:PBMBinary, :PGMBinary, :PPMBinary, :PBMText, :PGMText, :PPMText)
    @eval begin
        function load(f::File{DataFormat{$(Expr(:quote,NETPBMFORMAT))}})
            return Base.invokelatest(checked_import(:Netpbm).load, f)
        end

        function load(s::Stream{DataFormat{$(Expr(:quote,NETPBMFORMAT))}})
            return Base.invokelatest(checked_import(:Netpbm).load, s)
        end

        function save(f::File{DataFormat{$(Expr(:quote,NETPBMFORMAT))}}, image::S; kwargs...) where {S<:AbstractMatrix}
            return Base.invokelatest(checked_import(:Netpbm).save, f, image; kwargs...)
        end

        function save(s::Stream{DataFormat{$(Expr(:quote,NETPBMFORMAT))}}, image::S; kwargs...) where {S<:AbstractMatrix}
            return Base.invokelatest(checked_import(:Netpbm).save, s, image; kwargs...)
        end
    end
end

end # module
