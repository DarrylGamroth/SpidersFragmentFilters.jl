mutable struct RateLimitingFragmentFilter{F<:Aeron.AbstractFragmentHandler,C<:AbstractClock} <: Aeron.AbstractFragmentHandler
    const fragment_handler::F
    const clock::C
    const min_interval::Int64
    last_timestamp::Int64
    function RateLimitingFragmentFilter(fragment_handler::F,
        min_interval::Int64,
        clock::C=EpochClock()) where {F,C}

        new{F,C}(fragment_handler, clock, min_interval, 0)
    end
end

function (f::RateLimitingFragmentFilter)(clientd, buffer, header)
    now = time_nanos(f.clock)
    time_diff = now - f.last_timestamp

    if time_diff < f.min_interval
        return nothing
    else
        f.last_timestamp = now
        return Aeron.on_fragment(f.fragment_handler)(clientd, buffer, header)
    end
end

Aeron.on_fragment(f::RateLimitingFragmentFilter) = f
Aeron.clientd(f::RateLimitingFragmentFilter) = Aeron.clientd(f.fragment_handler)

export RateLimitingFragmentFilter
