import CSV
using DataFrames, GLM
using Plots
pyplot(legend=true, size = (640, 480))


function main()
    path = download("https://raw.githubusercontent.com/carranco-sga/Mexico-COVID-19/master/Mexico_COVID19_CTD.csv")
    
    table_ = CSV.read(path)
    table = hcat( DataFrame(:Day => 1:size(table_, 1)), table_ )

    r = table[end, :Pos]
    p = table[end, :Deceased] / r

    @show p
    @show r
    probit = glm(@formula(Deceased ~ Day), table, NegativeBinomial(r, p), LogLink())
    
    days = table[end, :Day]-1:table[end, :Day] + 6
    infected= predict(probit, DataFrame(:Day => days))
    
    
    p = plot(xlabel = "Days since 1th positive case", title="Mexico", ylabel = "Num. of Deceased")
    plot!(table[!, :Deceased ], label = "Official data")
    # plot!(table[!, :Pos ])
    plot!(days, infected, markershape=:o, label="Approx. data")

    for i in 1:7
        annotate!(days[i], infected[i], text("$(21+i)/04/2020", :red, :right, 8))
        annotate!(days[i], infected[i], text("  ($(round(Int,infected[i])))", :red, :left, 8))
    end
    savefig(p, "Deceased.png")
    p
end

main()
