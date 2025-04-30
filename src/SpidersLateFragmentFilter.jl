using Clocks

mutable struct SpidersLateFragmentFilter{T<:Aeron.AbstractFragmentHandler,L<:Aeron.AbstractFragmentHandler,C<:AbstractClock} <: Aeron.AbstractFragmentHandler
    const fragment_handler::T
    const late_fragment_handler::L
    const threshold::Int64
    const clock::C
    SpidersLateFragmentFilter(fragment_handler::T, late_fragment_handler::L, threshold::Int64, clock::C=EpochClock()) where {T,L,C} = new{T,L,C}(fragment_handler, late_fragment_handler, threshold, clock)
end

function (f::SpidersLateFragmentFilter)(clientd, buffer, header)
    sbe_header = SpidersMessageCodecs.MessageHeader(buffer)
    spiders_header = SpidersMessageCodecs.SpidersMessageHeader(buffer,
        sbe_encoded_length(sbe_header),
        SpidersMessageCodecs.version(sbe_header))

    timestamp = SpidersMessageCodecs.timestampNs(spiders_header)
    now = time_nanos(f.clock)
    time_diff = now - timestamp

    if time_diff < 0
        return nothing
    elseif time_diff > f.threshold
        return Aeron.on_fragment(f.late_fragment_handler)(clientd, buffer, header)
    else
        return Aeron.on_fragment(f.fragment_handler)(clientd, buffer, header)
    end
end

Aeron.on_fragment(f::SpidersLateFragmentFilter) = f
Aeron.clientd(f::SpidersLateFragmentFilter) = Aeron.clientd(f.fragment_handler)

export SpidersLateFragmentFilter
