module ImageIO

using UUIDs
using FileIO: File, DataFormat, Stream, stream, Formatted

const idNetpbm = Base.PkgId(UUID("f09324ee-3d7c-5217-9330-fc30815ba969"), "Netpbm")
const idPNGFiles = Base.PkgId(UUID("f57f5aa1-a3ce-4bc8-8ab9-96f992907883"), "PNGFiles")
const idTiffImages = Base.PkgId(UUID("731e570b-9d59-4bfa-96dc-6df516fadf69"), "TiffImages")

# Enforce a type conversion to be backend independent (issue #25)
# Note: If the backend does not provide efficient `convert` implementation,
#       there will be an extra memeory allocation and thus hurt the performance.
for FMT in (
    :PBMBinary, :PGMBinary, :PPMBinary, :PBMText, :PGMText, :PPMText,
    :TIFF,
    :PNG,
)
    @eval canonical_type(::DataFormat{$(Expr(:quote, FMT))}, ::AbstractArray{T, N}) where {T,N} =
        Array{T,N}
end
@inline canonical_type(::Formatted{T}, data) where T = canonical_type(T(), data)

## PNGs

const load_locker = Threads.ReentrantLock()
function checked_import(pkgid)
    Base.root_module_exists(pkgid) && return Base.root_module(pkgid)
    # If not available, lock and load the library in a sequential order
    lock(load_locker) do
        Base.require(pkgid)
    end
end

function load(f::File{DataFormat{:PNG}}; kwargs...)
    data = Base.invokelatest(checked_import(idPNGFiles).load, f.filename, kwargs...)
    return Base.invokelatest(convert, canonical_type(f, data), data)
end
function load(s::Stream{DataFormat{:PNG}}; kwargs...)
    data = Base.invokelatest(checked_import(idPNGFiles).load, stream(s), kwargs...)
    return Base.invokelatest(convert, canonical_type(s, data), data)
end

function save(f::File{DataFormat{:PNG}}, image::S; kwargs...) where {T, S<:Union{AbstractMatrix, AbstractArray{T,3}}}
    return Base.invokelatest(checked_import(idPNGFiles).save, f.filename, image, kwargs...)
end

function save(s::Stream{DataFormat{:PNG}}, image::S; permute_horizontal=false, mapi=identity, kwargs...) where {T, S<:Union{AbstractMatrix, AbstractArray{T,3}}}
    imgout = map(mapi, image)
    if permute_horizontal
        perm = ndims(imgout) == 2 ? (2, 1) : ndims(imgout) == 3 ? (2, 1, 3) : error("$(ndims(imgout)) dims array is not supported")
        return Base.invokelatest(checked_import(idPNGFiles).save, stream(s), PermutedDimsArray(imgout, perm), kwargs...)
    else
        return Base.invokelatest(checked_import(idPNGFiles).save, stream(s), imgout, kwargs...)
    end
end

# Netpbm types

for NETPBMFORMAT in (:PBMBinary, :PGMBinary, :PPMBinary, :PBMText, :PGMText, :PPMText)
    @eval begin
        function load(f::File{DataFormat{$(Expr(:quote,NETPBMFORMAT))}})
            data = Base.invokelatest(checked_import(idNetpbm).load, f)
            return Base.invokelatest(convert, canonical_type(f, data), data)
        end

        function load(s::Stream{DataFormat{$(Expr(:quote,NETPBMFORMAT))}})
            data = Base.invokelatest(checked_import(idNetpbm).load, s)
            return Base.invokelatest(convert, canonical_type(s, data), data)
        end

        function save(f::File{DataFormat{$(Expr(:quote,NETPBMFORMAT))}}, image::S; kwargs...) where {S<:AbstractMatrix}
            return Base.invokelatest(checked_import(idNetpbm).save, f, image; kwargs...)
        end

        function save(s::Stream{DataFormat{$(Expr(:quote,NETPBMFORMAT))}}, image::S; kwargs...) where {S<:AbstractMatrix}
            return Base.invokelatest(checked_import(idNetpbm).save, s, image; kwargs...)
        end
    end
end

## TIFFs

function load(f::File{DataFormat{:TIFF}}; kwargs...)
    data = Base.invokelatest(checked_import(idTiffImages).load, f.filename, kwargs...)
    return Base.invokelatest(convert, canonical_type(f, data), data)
end
function load(s::Stream{DataFormat{:TIFF}}; kwargs...)
    data = Base.invokelatest(checked_import(idTiffImages).load, stream(s), kwargs...)
    return Base.invokelatest(convert, canonical_type(s, data), data)
end

function save(f::File{DataFormat{:TIFF}}, image::S) where {T, S<:Union{AbstractMatrix, AbstractArray{T,3}}}
    Base.invokelatest(checked_import(idTiffImages).save, f.filename, image)
end

function save(s::Stream{DataFormat{:TIFF}}, image::S; permute_horizontal=false, mapi=identity) where {T, S<:Union{AbstractMatrix, AbstractArray{T,3}}}
    imgout = map(mapi, image)
    if permute_horizontal
        perm = ndims(imgout) == 2 ? (2, 1) : ndims(imgout) == 3 ? (2, 1, 3) : error("$(ndims(imgout)) dims array is not supported")
        Base.invokelatest(checked_import(idTiffImages).save, stream(s), PermutedDimsArray(imgout, perm))
    else
        Base.invokelatest(checked_import(idTiffImages).save, stream(s), imgout)
    end
end

## Function names labelled for FileIO. Makes FileIO lookup quicker
const fileio_save = save
const fileio_load = load

end # module
