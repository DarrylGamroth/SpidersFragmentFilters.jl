using Automa
using SpidersMessageCodecs
using UUIDs

struct SpidersEventTagFragmentFilter{T<:Aeron.AbstractFragmentHandler,V} <: Aeron.AbstractFragmentHandler
    fragment_handler::T
    validator::V

    function SpidersEventTagFragmentFilter(fragment_handler::T, regex_string::AbstractString) where {T}
        validator = eval(generate_buffer_validator(Symbol("$regex_string-$(UUIDs.uuid4())"), RE(regex_string); docstring=false))
        new{T,typeof(validator)}(fragment_handler, validator)
    end
end

function (f::SpidersEventTagFragmentFilter)(clientd, buffer, header)
    message = Event.EventMessageDecoder(buffer, Event.MessageHeader(buffer))
    tag = Event.tag(String, Event.header(message))
    isnothing(f.validator(tag)) ? Aeron.on_fragment(f.fragment_handler)(clientd, buffer, header) : nothing
end

Aeron.on_fragment(f::SpidersEventTagFragmentFilter) = f
Aeron.clientd(f::SpidersEventTagFragmentFilter) = Aeron.clientd(f.fragment_handler)

export SpidersEventTagFragmentFilter
