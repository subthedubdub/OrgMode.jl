# Thanks to load order issues, we have to do the documentation seperately

const README, compatability =
    let readme=read("$(dirname(dirname(@__DIR__)))/README.org", String)
        prolouge=match(r"\n([^#\n][\s\S]*)\n\* Progress", readme).captures[1]
        progress=match(r"\n\* Progress\s*((?:\|[^\n]+\n)+)", readme).captures[1]
        Base.Docs.doc!(@__MODULE__,
                       Base.Docs.Binding(@__MODULE__, Symbol(@__MODULE__)),
                       Base.Docs.docstr(parse(Org, prolouge),
                                        Dict(:path => joinpath(@__DIR__, @__FILE__),
                                             :linenumber => @__LINE__,
                                             :module => @__MODULE__)),
                       Union{})
        (parse(Org, readme),
         parse(Org,
               replace(replace(replace(progress,
                                       "| X " => "| =✓="),
                               r"\| +\|" => "| ~⋅~ |"),
                       r"\| +\|" => "| ~⋅~ |")))
    end

@doc org"""
#+begin_src julia
orgmatcher(::Type{C}) where {C <: OrgComponent}
#+end_src

Return a /matcher/ for components of type ~C~.
This will either be:
+ nothing, if no matcher is defined
+ a regular expression which matcher the entire component
+ a function which takes a string and returns either
  - nothing, if the string does not start with the component
  - the substring which has been identified as an instance of the component
  - a tuple of the substring instance of the component, and the component data structure
""" orgmatcher

@doc org"""
#+begin_src julia
consume(component::Type{<:OrgComponent}, text::AbstractString)
#+end_src
Try to /consume/ a ~component~ from the start of ~text~.

Returns a tuple of the consumed text and the resulting component
or =nothing= if this is not possible.
""" consume

@doc org"""
An ~Org~ wrapper type, which when ~iterated~ over yeilds
each component of the ~Org~ document.
""" OrgIterator

@doc org"""
An ~Org~ wrapper type, which when ~iterated~ over yeilds
each element of the ~Org~ document.
""" OrgElementIterator
