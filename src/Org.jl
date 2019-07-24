# This file is part of Org.jl.
#
# Org.jl is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Org.jl is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.

module Org

import Base: size, getindex, setindex!, IndexStyle, iterate, length

abstract type AbstractOrg end

# Forward array interface methods
size(a::AbstractOrg) = size(a.content)
getindex(a::AbstractOrg, i::Int) = getindex(a.content, i)
setindex!(a::AbstractOrg, i::Int) = setindex!(a.content, i)
IndexStyle(a::AbstractOrg) = IndexStyle(a.content)
length(a::AbstractOrg) = length(a.content)
iterate(a::AbstractOrg, args...) = iterate(a.content, args...)

struct OrgDocument<:AbstractOrg
    content::Vector{AbstractOrg}
end#struct
OrgDocument() = OrgDocument(AbstractOrg[])

function find_nesting(org::OrgDocument, level)
    # TODO: no this is wrong. I never care about anything but the last element unless it's a paragraph...
    for i in reverse(org)
        return if level(i) == level
            i
        elseif level(i) > level
            find_nesting(i, level)
        else
            i
        end#if
    end#for
end#function

"""
    parser!(line::AbstractString, org::OrgDocument, T::Type{AbstractOrg})

Attempt to parse next line from io as T.

If successful, it returns an instance of `T` that is `push!`ed to
`org`. If unsuccesful, returns `nothing`.
"""
function parser! end

struct Headline<:AbstractOrg
    title::String
    level::Int8
    tags::Vector{String}
    content::Vector{AbstractOrg}
end#struct

function parser(line::AbstractString, org::OrgDocument, ::Type{Headline})
    # Determine headline level and whether validly formatted
    level = 0
    for c in line
        c != '*' && break
        level += 1
    end#for
    if iszero(level) || level == length(line) || @inbounds line[level + 1] != ' '
        return nothing
    end#if

    # Determine whether tags exist and add all found tags
    tags = String[]
    if endswith(line, ':')
        for tag in reverse(split(line, ':'))
            if length(tag) != 0 && all(isletter, tag)
                push!(tags, tag)
            else
                break
            end#if
        end#for
        reverse!(tags)
    end#if
    num_tag_chars = mapreduce(length, +, tags; init=0) + length(tags)
    # One more colon than number of tags
    num_tag_chars != 0 && (num_tag_chars += 1)

    title = strip(line[level + 1:length(line) - num_tag_chars])

    hl = Headline(title, level, tags, AbstractOrg[])
    push!(find_nesting(org, level), hl)
    hl
end#function

end # module