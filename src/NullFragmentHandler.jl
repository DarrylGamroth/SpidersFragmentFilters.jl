mutable struct NullFragmentHandler <: Aeron.AbstractFragmentHandler end
(f::NullFragmentHandler)(clientd, buffer, header) = nothing
Aeron.on_fragment(f::NullFragmentHandler) = f
Aeron.clientd(::NullFragmentHandler) = nothing

mutable struct NullControlledFragmentHandler <: Aeron.AbstractFragmentHandler end
(f::NullControlledFragmentHandler)(clientd, buffer, header) = Aeron.ControlledAction.CONTINUE
Aeron.on_fragment(f::NullControlledFragmentHandler) = f
Aeron.clientd(::NullControlledFragmentHandler) = nothing

export NullFragmentHandler, NullControlledFragmentHandler