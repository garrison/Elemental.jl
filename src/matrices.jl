for (elty, relty, ext) in ((:Float32, :Float32, :s),
                           (:Float64, :Float64, :d),
                           (:Complex64, :Float32, :c),
                           (:Complex128, :Float64, :z))

    for (mat, sym) in ((:Matrix, "_"),
                       (:DistMatrix, "Dist_"),
                       (:DistMultiVec, "DistMultiVec_"))
        @eval begin

            # Gaussian
            function gaussian!(A::$mat{$elty}, m::Integer, n::Integer,
                               mean::$elty=zero($elty), stddev::$relty=one($relty))
                err = ccall(($(string("ElGaussian", sym, ext)), libEl), Cuint,
                    (Ptr{Void}, ElInt, ElInt, $elty, $relty),
                    A.obj, m, n, mean, stddev)
                err == 0 || throw(ElError(err))
                return A
            end

            # Uniform
            function uniform!(A::$mat{$elty}, m::Integer, n::Integer,
                              center::$elty=zero($elty), radius::$relty=one($relty))
                err = ccall(($(string("ElUniform", sym, ext)), libEl), Cuint,
                    (Ptr{Void}, ElInt, ElInt, $elty, $relty),
                    A.obj, m, n, center, radius)
                err == 0 || throw(ElError(err))
                return A
            end

            # Zeros
            function zeros!(A::$mat{$elty}, m::Integer, n::Integer)
                err = ccall(($(string("ElZeros", sym, ext)), libEl), Cuint,
                    (Ptr{Void}, ElInt, ElInt),
                    A.obj, m, n)
                err == 0 || throw(ElError(err))
                return A
            end
        end
    end
end

function Base.zeros{T}(::Type{DistMatrix{T}}, m::Integer, n::Integer)
    A = DistMatrix(T)
    zeros!(A,m,n)
    return A
end
Base.zeros{T}(::Type{DistMatrix{T}}, dim::NTuple{Integer,2}) = zeros(DistMatrix{T}, dim...)
