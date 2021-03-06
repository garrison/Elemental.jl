# Detect Elemental integer size
function ElIntType()
    using64 = Cint[0]
    err = ccall((:ElUsing64BitInt, libEl), Cuint, (Ptr{Cint},), using64)
    err == 0 || throw(ElError(err))
    return using64[1] == 1 ? Int64 : Int32
end
const ElInt = ElIntType()

function ElCommType()
    sameSizeAsInt = Cint[0]
    err = ccall((:ElMPICommSameSizeAsInteger, libEl), Cuint, (Ptr{Cint},),
      sameSizeAsInt)
    err == 0 || throw(ElError(err))
    return sameSizeAsInt[1] == 1 ? Cint : Ptr{Void}
end
const ElComm = ElCommType()

function ElGroupType()
    sameSizeAsInt = Cint[0]
    err = ccall((:ElMPIGroupSameSizeAsInteger, libEl), Cuint, (Ptr{Cint},),
      sameSizeAsInt)
    err == 0 || throw(ElError(err))
    return sameSizeAsInt[1] == 1 ? Cint : Ptr{Void}
end
const ElGroup = ElGroupType()

# Detect Elemental Bool type
function ElBoolType()
    # NOTE: Returning Uint8 when C claims that sizeof(bool) is 1 byte leads
    #       to improperly passed structs to Elemental's C interface. This is
    #       worth investigating and might be an alignment issue.

    # warn("Hardcoding ElBool to Cint")
    boolsize = Ref(zero(Cuint))
    err = ccall((:ElSizeOfCBool, libEl), Cuint, (Ref{Cuint},), boolsize)
    err == 0 || throw(ElError(err))
    return boolsize[] == 1 ? UInt8 : Cint
end
const ElBool = ElBoolType()

function ElBool(value::Bool)
    if value
      return ElBool(1)
    else
      return ElBool(0)
    end
end

using Base.LinAlg: BlasFloat, BlasReal, BlasComplex

typealias ElElementType Union{ElInt,Float32,Float64,Complex64,Complex128}

typealias ElFloatType Union{Float32,Float64} # TODO: Maybe just use BlasReal here

abstract ElementalMatrix{T} <: AbstractMatrix{T}
eltype{T}(A::ElementalMatrix{T}) = T

# Error is handled in error.jl as an Exception

typealias SortType Cint
const UNSORTED   = Cint(0)
const DESCENDING = Cint(1)
const ASCENDING  = Cint(2)

typealias Dist Cint
const MC		= Cint(0)
const MD		= Cint(1)
const MR		= Cint(2)
const VC		= Cint(3)
const VR		= Cint(4)
const STAR		= Cint(5)
const CIRC		= Cint(6)

typealias Orientation Cint
const NORMAL 	= Cint(0)
const TRANSPOSE = Cint(1)
const ADJOINT 	= Cint(2)

typealias UpperOrLower Cint
const LOWER = Cint(0)
const UPPER = Cint(1)

# Get MPIWorldComm
function CommWorldValue()
    r = Ref{ElComm}(0)
    ccall((:ElMPICommWorld, libEl), Cuint, (Ref{ElComm},), r)
    return r[]
end
const CommWorld = CommWorldValue()
