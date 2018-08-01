export print, init_output, final_output

###############################################################################
####  Relaxation context
###############################################################################
function print_build_relctx(relax_ctx, pb)
    relaxparams = relax_ctx.relaxparams

    outstream = []
    relaxparams[:opt_outmode]!=1 && push!(outstream, STDOUT)
    relaxparams[:opt_outmode]>0  && push!(outstream, open(relaxparams[:opt_outname], "a"))

    (relaxparams[:opt_outlev] == 0) && return

    # Compute indicators
    nb_densecstrs = 0
    maxdeg_densecstr = Float32[]
    for (cstr, ki_) in relax_ctx.ki
        if relax_ctx.di[cstr] > ki_
            nb_densecstrs += 1
            push!(maxdeg_densecstr, ki_)
        end
    end

    exposet = Set()
    nb_expotot = 0
    degbycstr = Int64[]
    for (cstrname, cstr) in get_constraints(pb)
        push!(degbycstr, max(cstr.p.degree.explvar, cstr.p.degree.conjvar))
        for (expo, λ) in cstr.p
            push!(exposet, expo)
            nb_expotot += 1
        end
    end

    # print
    for outstr in outstream
        if relaxparams[:opt_outlev] ≥ 1
            println(outstr, "\n=== set_relaxation()")

            print(outstr, "Relaxation is ", string(relaxparams[:opt_hierarchykind]))
            relaxparams[:opt_issparse] && print(outstr, ", sparse")
            relaxparams[:opt_multiordered] && print(outstr, ", multiordered")
            println(outstr, ".")

            println(outstr, "Global order is : ", relaxparams[:opt_globalorder], ".")

            print(outstr, "PhaseInvariance ")
            !relaxparams[:opt_sym_phaseinv] && print(outstr, "not ")
            print(outstr, "required and ")
            !relaxparams[:pb_isphaseinv] && print(outstr, "not ")
            println(outstr, "found.")

            println(outstr, "\n=> Problem with:")
            println(outstr, "-> Nb of variables:                        ", length(pb.variables))
            println(outstr, "-> Nb of constraints:                      ", length(pb.constraints))
            println(outstr, "-> Nb of monomials:                        $nb_expotot ($(length(exposet)) different)")
            @printf(outstr, "-> Max total degree by constraint:         %.1f / %.1f (mean/std)\n", mean(degbycstr), std(degbycstr))

            println(outstr, "=> Relaxation characteristics:")
            @printf(outstr, "-> Number of constraints s.t. di > ki:     %i / %i\n", nb_densecstrs, length(pb.constraints))
            @printf(outstr, "-> Max total degree on such constraints:   %.1f / %.1f (mean/std)\n", mean(maxdeg_densecstr), std(maxdeg_densecstr))
            @printf(outstr, "All variables appearing in such constraints will be linked in the sparsity pattern, which will largely densify it.\n")
        end

        (outstr!=STDOUT) && close(outstr)
    end
end



###############################################################################
####  Moment problem construction
###############################################################################
function print_build_momentrelax(relax_ctx, momentrelaxation, nb_expos)
    relaxparams = relax_ctx.relaxparams

    (relaxparams[:opt_outlev] == 0) && return

    outstream = []
    relaxparams[:opt_outmode]!=1 && push!(outstream, STDOUT)
    relaxparams[:opt_outmode]>0  && push!(outstream, open(relaxparams[:opt_outname], "a"))


    for outstr in outstream
        if relaxparams[:opt_outlev] ≥ 1
            println(outstr, "\n=== build_momentrelaxation(relax_ctx, problem, moment_param::Dict{String, Tuple{Set{String}, Int}}, max_cliques::Dict{String, Set{Variable}})")
            println(outstr, "Compute the moment and localizing matrices associated with the problem constraints and clique decomposition and return a SDPDual object.")

            if relaxparams[:opt_outlev] ≥ 3
                print(outstr, momentrelaxation)
            end

            println(outstr, "Number of moments      : ", nb_expos)
            println(outstr, "Nb exponents coupled   : ", length(momentrelaxation.moments_overlap))

            ## NOTE: which relevant indicators here ?
        end

        (outstr!=STDOUT) && close(outstr)
    end
end


###############################################################################
####  SOS problem construction
###############################################################################
function print_build_SOSrelax(relax_ctx::RelaxationContext, sosrel::SDPPrimal)
    relaxparams = relax_ctx.relaxparams

    (relaxparams[:opt_outlev] == 0) && return

    outstream = []
    relaxparams[:opt_outmode]!=1 && push!(outstream, STDOUT)
    relaxparams[:opt_outmode]>0  && push!(outstream, open(relaxparams[:opt_outname], "a"))

    ## Compute indicators
    nb_SDPvars = length(Set([(key[2]) for key in keys(sosrel.blocks)]))
    size_SDPvars = length(Set([(key[2], key[3], key[4]) for key in keys(sosrel.blocks)]))
    nb_symvars = length(Set([(key[2]) for key in keys(sosrel.linsym)]))
    size_symvars = length(Set([(key[2], key[3]) for key in keys(sosrel.linsym)]))
    nb_scalvars = length(Set([key[2] for key in keys(sosrel.lin)]))

    momentset = Set{Moment}([key[1] for key in keys(sosrel.blocks)])
    union!(momentset, Set([key[1] for key in keys(sosrel.linsym)]))
    union!(momentset, Set([key[1] for key in keys(sosrel.lin)]))
    union!(momentset, Set([key for key in keys(sosrel.cst)]))
    for moment in momentset
        if product(moment.expl_part, moment.conj_part) == Exponent()
            delete!(momentset, moment)
        end
    end

    for outstr in outstream
        if relaxparams[:opt_outlev] ≥ 1
            println(outstr, "\n=== SOSrelaxation")

            if relaxparams[:opt_outlev] ≥ 2
                warn(outstr, "(C)SDP variables :")
                println(outstr, SortedSet([(key[2]) for key in keys(sosrel.blocks)]))
                warn(outstr, "Symmetric variables :")
                println(outstr, SortedSet([(key[2]) for key in keys(sosrel.linsym)]))
                warn(outstr, "Scalar variables :")
                println(outstr, SortedSet([key[3] for key in keys(sosrel.lin)]))
                warn(outstr, "Constraint keys :")
                println(outstr, SortedSet(collect(momentset)))
            end

            println(outstr, "- nb of (C)SDP matrix vars     : ", nb_SDPvars)
            println(outstr, "- size of (C)SDP matrix vars   : ", size_SDPvars)
            println(outstr, "- nb of (C)Sym matrix vars     : ", nb_symvars)
            println(outstr, "- size of (C)Sym matrix vars   : ", size_symvars)
            println(outstr, "- nb of scalar variables       : ", nb_scalvars)
            println(outstr, "- nb of constraints            : ", length(momentset))

            if relaxparams[:opt_outlev] ≥ 3
                print(outstr, sosrel)
            end
            ## NOTE: which relevant indicators here ?
        end

        (outstr!=STDOUT) && close(outstr)
    end
end




function init_output(relax_ctx::RelaxationContext)
    relaxparams = relax_ctx.relaxparams

    # Create empty log file
    if relaxparams[:opt_outmode] ≥ 1
        isfile(relaxparams[:opt_outname]) && rm(relaxparams[:opt_outname])
        open(relaxparams[:opt_outname], "w") do f
            repo = LibGit2.GitRepo(pwd()); branch = LibGit2.shortname(LibGit2.head(repo))

            println(f, "MomentSOS hierarchy, date: ", String(Dates.format(now(), "mm_dd-HH:MM:SS")))
        end
    end

    # Create minimal csv file
    if relaxparams[:opt_outcsv] ≥ 1
        write_ctxcsv(relax_ctx.relaxparams)
    end
end

function final_output(relax_ctx::RelaxationContext)
    relaxparams = relax_ctx.relaxparams

    # Print CSV file
    if relaxparams[:opt_outcsv] ≥ 1
        write_ctxcsv(relaxparams)
    end
end


function write_ctxcsv(relaxparams)
    isfile(relaxparams[:opt_outcsvname]) && rm(relaxparams[:opt_outcsvname])
    open(relaxparams[:opt_outcsvname], "w") do f
        n = length(keys(relaxparams))
        for (i, key) in enumerate(keys(relaxparams))
            print(f, key)
            (i < n) && print(f, ";")
        end
        println(f)

        for (i, val) in enumerate(values(relaxparams))
            print(f, val, ";")
            (i < n) && print(f, ";")
        end
    end
end