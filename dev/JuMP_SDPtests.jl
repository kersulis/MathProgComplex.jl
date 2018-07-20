using JuMP, Mosek

m = Model(solver=MosekSolver())

@variable(m, Xs1[1:3,1:3], SDP)
@variable(m, Xs2[1:1,1:1], SDP)

# moment constraint one
@constraint(m, Xs1[1,1] == 1)

# Ball constraint
@constraint(m, Xs1[2,2] + Xs1[3,3] + Xs2[1,1] == 4)

# Find upper bound
@objective(m, Max, Xs1[1,2])

println(m)
solve(m)
println("Maximum value is ", getobjective(m))

println("\nSolution is:")
@show getvalue(Xs1)
@show getvalue(Xs2)

@show getdual(Xs1)
@show getdual(Xs2)

############ Plain Mosek:

printstream(msg::String) = print(msg)

barvardim = [3, 1]

numcon = 2
bkc = [Mosek.Boundkey(2), Mosek.Boundkey(2)]
blc = [1, 4]
buc = [1, 4]

barai    = [1, 2, 2, 2]
baraj    = [1, 1, 1, 2]
barak    = [1, 2, 3, 1]
baral    = [1, 2, 3, 1]
baraijkl = [1, 1, 1, 1]

barcj    = [1]
barck    = [2]
barcl    = [1]
barcjkl  = [0.5]

# Create a task object and attach log stream printer
maketask() do task

    putstreamfunc(task, MSK_STREAM_LOG, printstream)

    # Append SDP matrix variables and scalar variables.
    # The variables will initially be fixed at zero.
    appendbarvars(task,barvardim)


    # Append 'numcon' empty constraints.
    # The constraints will initially have no bounds.
    appendcons(task,numcon)
    putconboundslice(task,1,numcon+1, bkc,blc,buc)

    putobjsense(task, MSK_OBJECTIVE_SENSE_MAXIMIZE)

    # Set constraints SDP vars coeffs
    putbarablocktriplet(task, length(barai), barai, baraj, barak, baral, baraijkl)

    # Objective matrices and constant
    putbarcblocktriplet(task, length(barcj), barcj, barck, barcl, barcjkl)

    MathProgComplex.dump_mosek_model(task)

    optimize(task)
    solutionsummary(task,MSK_STREAM_MSG)

    info("suc:")
    @show getsuc(task, MSK_SOL_ITR)
    info("slc:")
    @show getslc(task, MSK_SOL_ITR)
    info("sux:")
    @show getsux(task, MSK_SOL_ITR)
    info("slx:")
    @show getslx(task, MSK_SOL_ITR)

    # Get status information about the solution
    prosta = getprosta(task, MSK_SOL_ITR)
    solsta = getsolsta(task, MSK_SOL_ITR)

    info("Primal solution:")
    @show getbarxj(task, MSK_SOL_ITR, 1)
    @show getbarxj(task, MSK_SOL_ITR, 2)

    info("Dual solution:")
    @show getbarsj(task, MSK_SOL_ITR, 1)
    @show getbarsj(task, MSK_SOL_ITR, 2)

end

##########################################################################
m = Model(solver=MosekSolver())

@variable(m, Xs1[1:6,1:6], SDP)
@variable(m, Xs2[1:1,1:1], SDP)
@variable(m, Xs3[1:1,1:1], SDP)

# moment constraint one
@constraint(m, Xs1[1,1] == 1)

# Ball constraint
@constraint(m, Xs1[4,4] + Xs1[6,6] + Xs2[1,1] == 16)
@constraint(m, Xs1[2,2] + Xs1[3,3] + Xs3[1,1] == 100)

# Find upper bound
@objective(m, Max, Xs1[1,2])

println(m)
solve(m)
println("Maximum value is ", getobjective(m))

println("\nSolution is:")
@show getvalue(Xs1)
@show getvalue(Xs2)

@show getdual(Xs1)
@show getdual(Xs2)