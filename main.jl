import CSV
using DataFrames, GLM
using Plots
pyplot(legend=false)


function main()
    path = download("https://raw.githubusercontent.com/carranco-sga/Mexico-COVID-19/master/Mexico_COVID19.csv")
    
    table_ = CSV.read(path)
    table = hcat( DataFrame(:Day => 1:size(table_, 1)), table_ )

    r = table[end, :Pos]
    p = table[end, :Deceased] / r

    @show p
    @show r
    probit = glm(@formula(VER_D ~ Day), table, NegativeBinomial(r, p), LogLink())
    
    days = table[end, :Day]:table[end, :Day] + 7
    infected= predict(probit, DataFrame(:Day => days))
    
    
    p = plot(xlabel = "Day", ylabel = "Death")
    plot!(table[!, :VER_D ])
    # plot!(table[!, :Pos ])
    plot!(days, infected, markershape=:o)

    for i in 1:7
        annotate!(days[i], infected[i], text("$(5+i)/04/2020", :red, :right, 8))
    end
    p
end

main()
