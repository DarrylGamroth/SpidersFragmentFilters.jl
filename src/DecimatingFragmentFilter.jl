mutable struct DecimatingFragmentFilter{F<:Aeron.AbstractFragmentHandler} <: Aeron.AbstractFragmentHandler
    const fragment_handler::F
    const decimation::Int64
    counter::Int64
    DecimatingFragmentFilter(fragment_handler::T, decimation::Int64) where {T} = new{T}(fragment_handler, decimation, decimation)
end

function (f::DecimatingFragmentFilter)(clientd, buffer, header)
    f.counter += 1
    if f.counter >= f.decimation
        f.counter = 0
        return Aeron.on_fragment(f.fragment_handler)(clientd, buffer, header)
    end
    nothing
end

Aeron.on_fragment(f::DecimatingFragmentFilter) = f
Aeron.clientd(f::DecimatingFragmentFilter) = Aeron.clientd(f.fragment_handler)

export DecimatingFragmentFilter