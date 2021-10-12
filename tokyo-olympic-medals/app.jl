using DataFrames, CSV, PlotlyJS
using Dash, DashHtmlComponents, DashCoreComponents, DashBootstrapComponents

df = DataFrame(CSV.File("data/Tokyo2020.csv"))
sort!(df, [order(:"Team/NOC", rev=false)])
countries = unique(df[!, "Team/NOC"])

app = dash(external_stylesheets=["assets/style.css", dbc_themes.BOOTSTRAP])

app.layout = dbc_container(
    [
        dbc_row(
            [
                dbc_col(
                    [
                        dcc_dropdown(
                            id = "country-dropdown",
                            options = [
                                (label = string(i), value = string(i)) for i in countries
                            ],
                            value = "Canada"
                        )

                        html_div(
                            html_img(src="assets/tokyo2020.png", className="tokyo-image"),
                            className="tokyo-div"
                        )

                    ],
                    lg=4
                )

                dbc_col(
                    dbc_card(dcc_graph(id = "medals-graph")),
                    lg=8
                )
            ]
        )
    ]
)

callback!(
    app,
    Output("medals-graph", "figure"),
    Input("country-dropdown", "value")
) do selected_country
    dff = df[df[!, "Team/NOC"] .== selected_country, :]
    
    trace1 = bar(;x=["Gold"],
        y=dff[!, "Gold"],
        name="Gold Medals",
        marker_color="rgb(175, 149, 0)"
    )

    trace2 = bar(;x=["Silver"],
        y=dff[!, "Silver"],
        name="Silver Medals",
        marker_color="rgb(180, 180, 180)"
    )

    trace3 = bar(;x=["Bronze"],
        y=dff[!, "Bronze"],
        name="Bronze Medals",
        marker_color="rgb(173, 138, 86)"
    )

    data = [trace1, trace2, trace3]

    layout = Layout(    
        title=attr(text="Tokyo 2020 Olmypic Medals", x=0.5),
    
        yaxis=attr(
            title="Number of Medals",
            tickfont_size= 14,
            tickfont_color="rgb(107, 107, 107)"
        ),
        
        legend=attr(
            x=0, y=1.0,
            bgcolor="rgba(255, 255, 255, 0)",
            bordercolor="rgba(255, 255, 255, 0)"
        ),
        plot_bgcolor="rgba(0,0,0,0)"
    )

    return plot(data, layout)
end

run_server(app, "0.0.0.0", debug=true)