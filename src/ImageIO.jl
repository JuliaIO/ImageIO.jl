module ImageIO

using UUIDs
using FileIO: File, DataFormat, Stream, stream, Formatted

const idSixel = Base.PkgId(UUID("45858cf5-a6b0-47a3-bbea-62219f50df47"), "Sixel")
const idNetpbm = Base.PkgId(UUID("f09324ee-3d7c-5217-9330-fc30815ba969"), "Netpbm")
const idPNGFiles = Base.PkgId(UUID("f57f5aa1-a3ce-4bc8-8ab9-96f992907883"), "PNGFiles")
const idTiffImages = Base.PkgId(UUID("731e570b-9d59-4bfa-96dc-6df516fadf69"), "TiffImages")
const idOpenEXR = Base.PkgId(UUID("52e1d378-f018-4a11-a4be-720524705ac7"), "OpenEXR")
const idQOI = Base.PkgId(UUID("4b34888f-f399-49d4-9bb3-47ed5cae4e65"), "QOI")
const idJpegTurbo = Base.PkgId(UUID("b835a17e-a41a-41e7-81f0-2f016b05efe0"), "JpegTurbo")

# Enforce a type conversion to be backend independent (issue #25)
# Note: If the backend does not provide efficient `convert` implementation,
#       there will be an extra memory allocation and thus hurt the performance.
for FMT in (
    :PBMBinary, :PGMBinary, :PPMBinary, :PBMText, :PGMText, :PPMText,
    :TIFF,
    :PNG,
    :EXR,
    :QOI,
    :SIXEL,
    :JPEG
)
    @eval canonical_type(::DataFormat{$(Expr(:quote, FMT))}, ::AbstractArray{T, N}) where {T,N} =
        Array{T,N}
end
@inline canonical_type(::Formatted{T}, data) where T = canonical_type(T(), data)

function enforce_canonical_type(f, data)
    AT = canonical_type(f, data)
    # This may not be type stable if `AT` is not a concrete type,
    # but it's not an issue for `load`; it can never be type stable.

    # work around the invokelatest overhead with an eager type check
    if data isa AT
        return data
    else
        # the backend might provide its own convert method
        # use invokelatest to avoid world age issues
        # See issue #34
        return Base.invokelatest(convert, AT, data)
    end
end

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
    data = Base.invokelatest(checked_import(idPNGFiles).load, f.filename; kwargs...)
    return enforce_canonical_type(f, data)
end
function load(s::Stream{DataFormat{:PNG}}; kwargs...)
    data = Base.invokelatest(checked_import(idPNGFiles).load, stream(s); kwargs...)
    return enforce_canonical_type(s, data)
end

function save(f::File{DataFormat{:PNG}}, image::S; kwargs...) where {T, S<:Union{AbstractMatrix, AbstractArray{T,3}}}
    return Base.invokelatest(checked_import(idPNGFiles).save, f.filename, image; kwargs...)
end

function save(s::Stream{DataFormat{:PNG}}, image::S; permute_horizontal=false, mapi=identity, kwargs...) where {T, S<:Union{AbstractMatrix, AbstractArray{T,3}}}
    imgout = map(mapi, image)
    if permute_horizontal
        perm = ndims(imgout) == 2 ? (2, 1) : ndims(imgout) == 3 ? (2, 1, 3) : error("$(ndims(imgout)) dims array is not supported")
        return Base.invokelatest(checked_import(idPNGFiles).save, stream(s), PermutedDimsArray(imgout, perm); kwargs...)
    else
        return Base.invokelatest(checked_import(idPNGFiles).save, stream(s), imgout; kwargs...)
    end
end

# Netpbm types

for NETPBMFORMAT in (:PBMBinary, :PGMBinary, :PPMBinary, :PBMText, :PGMText, :PPMText)
    @eval begin
        function load(f::File{DataFormat{$(Expr(:quote,NETPBMFORMAT))}})
            data = Base.invokelatest(checked_import(idNetpbm).load, f)
            return enforce_canonical_type(f, data)
        end

        function load(s::Stream{DataFormat{$(Expr(:quote,NETPBMFORMAT))}})
            data = Base.invokelatest(checked_import(idNetpbm).load, s)
            return enforce_canonical_type(s, data)
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
    data = Base.invokelatest(checked_import(idTiffImages).load, f.filename; kwargs...)
    return enforce_canonical_type(f, data)
end
function load(s::Stream{DataFormat{:TIFF}}; kwargs...)
    data = Base.invokelatest(checked_import(idTiffImages).load, stream(s); kwargs...)
    return enforce_canonical_type(s, data)
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

## OpenEXR

function load(f::File{DataFormat{:EXR}}; kwargs...)
    data = Base.invokelatest(checked_import(idOpenEXR).load, f; kwargs...)
    return enforce_canonical_type(f, data)
end

function save(f::File{DataFormat{:EXR}}, args...; kwargs...)
    Base.invokelatest(checked_import(idOpenEXR).save, f, args...; kwargs...)
end

## QOI

function load(f::File{DataFormat{:QOI}}; kwargs...)
    data = Base.invokelatest(checked_import(idQOI).qoi_decode, f.filename; kwargs...)
    return enforce_canonical_type(f, data)
end

function save(f::File{DataFormat{:QOI}}, args...; kwargs...)
    Base.invokelatest(checked_import(idQOI).qoi_encode, f.filename, args...; kwargs...)
end

## Sixel
# Sixel.jl itself provides `fileio_load`/`fileio_save` so we simply delegate everything to it
function load(f::File{DataFormat{:SIXEL}}; kwargs...)
    data = Base.invokelatest(checked_import(idSixel).fileio_load, f, kwargs...)
    return  enforce_canonical_type(f, data)
end
function load(s::Stream{DataFormat{:SIXEL}}; kwargs...)
    data = Base.invokelatest(checked_import(idSixel).fileio_load, s, kwargs...)
    return  enforce_canonical_type(s, data)
end
function save(f::File{DataFormat{:SIXEL}}, image::AbstractArray; kwargs...)
    Base.invokelatest(checked_import(idSixel).fileio_save, f, image; kwargs...)
end
function save(s::Stream{DataFormat{:SIXEL}}, image::AbstractArray; kwargs...)
    Base.invokelatest(checked_import(idSixel).fileio_save, s, image; kwargs...)
end

## JPEG
function load(f::File{DataFormat{:JPEG}}; kwargs...)
    data = Base.invokelatest(checked_import(idJpegTurbo).fileio_load, f, kwargs...)
    return enforce_canonical_type(f, data)
end
function load(s::Stream{DataFormat{:JPEG}}; kwargs...)
    data = Base.invokelatest(checked_import(idJpegTurbo).fileio_load, s, kwargs...)
    return enforce_canonical_type(s, data)
end
function save(f::File{DataFormat{:JPEG}}, image::AbstractArray; kwargs...)
    Base.invokelatest(checked_import(idJpegTurbo).fileio_save, f, image; kwargs...)
end
function save(s::Stream{DataFormat{:JPEG}}, image::AbstractArray; kwargs...)
    Base.invokelatest(checked_import(idJpegTurbo).fileio_save, s, image; kwargs...)
end

## Function names labelled for FileIO. Makes FileIO lookup quicker
const fileio_save = save
const fileio_load = load

end # module
