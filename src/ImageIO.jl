module ImageIO

using UUIDs
using FileIO: File, DataFormat, Stream, stream

const idNetpbm = Base.PkgId(UUID("f09324ee-3d7c-5217-9330-fc30815ba969"), "Netpbm")
const idPNGFiles = Base.PkgId(UUID("f57f5aa1-a3ce-4bc8-8ab9-96f992907883"), "PNGFiles")
const idTiffImages = Base.PkgId(UUID("731e570b-9d59-4bfa-96dc-6df516fadf69"), "TiffImages")

## PNGs

const libload_lock = [Threads.SpinLock()]
function lazy_load(pkgid)
    Base.root_module_exists(pkgid) && return Base.root_module(pkgid)
    # If not available, lock and load the library in a sequential order
    lock(libload_lock[1]) do
        Base.require(pkgid)
    end
end

function load(f::File{DataFormat{:PNG}}; kwargs...)
    return Base.invokelatest(lazy_load(idPNGFiles).load, f.filename, kwargs...)
end
function load(s::Stream{DataFormat{:PNG}}; kwargs...)
    return Base.invokelatest(lazy_load(idPNGFiles).load, stream(s), kwargs...)
end

function save(f::File{DataFormat{:PNG}}, image::S; kwargs...) where {T, S<:Union{AbstractMatrix, AbstractArray{T,3}}}
    return Base.invokelatest(lazy_load(idPNGFiles).save, f.filename, image, kwargs...)
end

function save(s::Stream{DataFormat{:PNG}}, image::S; permute_horizontal=false, mapi=identity, kwargs...) where {T, S<:Union{AbstractMatrix, AbstractArray{T,3}}}
    imgout = map(mapi, image)
    if permute_horizontal
        perm = ndims(imgout) == 2 ? (2, 1) : ndims(imgout) == 3 ? (2, 1, 3) : error("$(ndims(imgout)) dims array is not supported")
        return Base.invokelatest(lazy_load(idPNGFiles).save, stream(s), PermutedDimsArray(imgout, perm), kwargs...)
    else
        return Base.invokelatest(lazy_load(idPNGFiles).save, stream(s), imgout, kwargs...)
    end
end

# Netpbm types

for NETPBMFORMAT in (:PBMBinary, :PGMBinary, :PPMBinary, :PBMText, :PGMText, :PPMText)
    @eval begin
        function load(f::File{DataFormat{$(Expr(:quote,NETPBMFORMAT))}})
            return Base.invokelatest(lazy_load(idNetpbm).load, f)
        end

        function load(s::Stream{DataFormat{$(Expr(:quote,NETPBMFORMAT))}})
            return Base.invokelatest(lazy_load(idNetpbm).load, s)
        end

        function save(f::File{DataFormat{$(Expr(:quote,NETPBMFORMAT))}}, image::S; kwargs...) where {S<:AbstractMatrix}
            return Base.invokelatest(lazy_load(idNetpbm).save, f, image; kwargs...)
        end

        function save(s::Stream{DataFormat{$(Expr(:quote,NETPBMFORMAT))}}, image::S; kwargs...) where {S<:AbstractMatrix}
            return Base.invokelatest(lazy_load(idNetpbm).save, s, image; kwargs...)
        end
    end
end

## TIFFs

function load(f::File{DataFormat{:TIFF}}; kwargs...)
    return Base.invokelatest(lazy_load(idTiffImages).load, f.filename, kwargs...)
end
function load(s::Stream{DataFormat{:TIFF}}; kwargs...)
    return Base.invokelatest(lazy_load(idTiffImages).load, stream(s), kwargs...)
end

function save(f::File{DataFormat{:TIFF}}, image::S) where {T, S<:Union{AbstractMatrix, AbstractArray{T,3}}}
    Base.invokelatest(lazy_load(idTiffImages).save, f.filename, image)
end

function save(s::Stream{DataFormat{:TIFF}}, image::S; permute_horizontal=false, mapi=identity) where {T, S<:Union{AbstractMatrix, AbstractArray{T,3}}}
    imgout = map(mapi, image)
    if permute_horizontal
        perm = ndims(imgout) == 2 ? (2, 1) : ndims(imgout) == 3 ? (2, 1, 3) : error("$(ndims(imgout)) dims array is not supported")
        Base.invokelatest(lazy_load(idTiffImages).save, stream(s), PermutedDimsArray(imgout, perm))
    else
        Base.invokelatest(lazy_load(idTiffImages).save, stream(s), imgout)
    end
end

## Function names labelled for FileIO. Makes FileIO lookup quicker
const fileio_save = save
const fileio_load = load

end # module
