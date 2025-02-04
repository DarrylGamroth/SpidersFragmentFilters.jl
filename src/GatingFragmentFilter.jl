mutable struct GatingFragmentFilter{T<:Aeron.AbstractFragmentHandler} <: Aeron.AbstractFragmentHandler
    const fragment_handler::T
    @atomic gated::Bool
    GatingFragmentFilter(fragment_handler::T, enable::Bool=false) where {T} = new{T}(fragment_handler, enable)
end

function (f::GatingFragmentFilter)(clientd, buffer, header)
    gate(f) ? nothing : Aeron.on_fragment(f.fragment_handler)(clientd, buffer, header)
end

Aeron.on_fragment(f::GatingFragmentFilter) = f
Aeron.clientd(f::GatingFragmentFilter) = Aeron.clientd(f.fragment_handler)

gate(f::GatingFragmentFilter) = @atomic f.gated
gate!(f::GatingFragmentFilter, enable::Bool) = @atomic f.gated = enable

export GatingFragmentFilter
