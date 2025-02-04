using ConcurrentUtilities

struct SessionIdFragmentFilter{F<:Aeron.AbstractFragmentHandler} <: Aeron.AbstractFragmentHandler
    fragment_handler::F
    accept_set::Set{Int64}
    deny_set::Set{Int64}
    lock::ReadWriteLock
    SessionIdFragmentFilter(fragment_handler::T) where {T} = new{T}(fragment_handler, Set{Int64}(), Set{Int64}(), ReadWriteLock())
end

function (f::SessionIdFragmentFilter)(clientd, buffer, header)
    readlock(f.lock)
    deny = Aeron.session_id(header) in f.deny_set
    accept = isempty(f.accept_set) || Aeron.session_id(header) in f.accept_set
    readunlock(f.lock)
    !deny && accept && Aeron.on_fragment(f.fragment_handler)(clientd, buffer, header)
end

deny_push!(f::SessionIdFragmentFilter, session_id::Int64) = @lock f.lock push!(f.deny_set, session_id)
deny_delete!(f::SessionIdFragmentFilter, session_id::Int64) = @lock f.lock delete!(f.deny_set, session_id)
accept_push!(f::SessionIdFragmentFilter, session_id::Int64) = @lock f.lock push!(f.accept_set, session_id)
accept_delete!(f::SessionIdFragmentFilter, session_id::Int64) = @lock f.lock delete!(f.accept_set, session_id)
accept(f::SessionIdFragmentFilter) = @lock f.lock f.accept_set
deny(f::SessionIdFragmentFilter) = @lock f.lock f.deny_set

Aeron.on_fragment(f::SessionIdFragmentFilter) = f
Aeron.clientd(f::SessionIdFragmentFilter) = Aeron.clientd(f.fragment_handler)

export SessionIdFragmentFilter, deny_push!, deny_delete!, accept_push!, accept_delete!, accept, deny
