using Automa
using UUIDs

mutable struct SpidersTagFragmentFilter{T<:Aeron.AbstractFragmentHandler,V} <: Aeron.AbstractFragmentHandler
    fragment_handler::T
    validator::V

    function SpidersTagFragmentFilter(fragment_handler::T, regex_string::AbstractString) where {T}
        validator = eval(generate_buffer_validator(Symbol("$regex_string-$(UUIDs.uuid4())"), RE(regex_string); docstring=false))
        new{T,typeof(validator)}(fragment_handler, validator)
    end
end

function (f::SpidersTagFragmentFilter)(clientd, buffer, header)
    sbe_header = SpidersMessageCodecs.MessageHeader(buffer)
    spiders_header = SpidersMessageCodecs.SpidersMessageHeader(buffer,
        sbe_encoded_length(sbe_header),
        SpidersMessageCodecs.version(sbe_header))
    tag = SpidersMessageCodecs.tag(spiders_header, AbstractString)
    isnothing(f.validator(tag)) ? Aeron.on_fragment(f.fragment_handler)(clientd, buffer, header) : nothing
end

Aeron.on_fragment(f::SpidersTagFragmentFilter) = f
Aeron.clientd(f::SpidersTagFragmentFilter) = Aeron.clientd(f.fragment_handler)

export SpidersTagFragmentFilter
