"""
app.jl
"""

# Authors: Tolgahan Cepel <tolgahan.cepel@gmail.com>

using DataFrames, CSV, PlotlyJS
using Dash, DashHtmlComponents, DashCoreComponents, DashBootstrapComponents

app = dash(external_stylesheets=["assets/style.css", dbc_themes.UNITED])


df = DataFrame(CSV.File("data/pes2021.csv"))

players = select(df, :Player_Name)

sidebar = html_div(
    [
        html_h5("PES2021 Players"),
        html_hr(),

        dbc_nav(
            [
                dbc_navlink("Graphic", href="/", active="exact"),
                dbc_navlink("About", href="/page-1", active="exact")
            ],
            vertical=true,
            pills=true,
        )
    ],
    className="sidebar"
)

page_graphic = html_div(
    [
        dbc_row(dbc_col(html_h4("Graphic"), lg=12)),

        dbc_row(
            [
                dbc_col(
                    dbc_card(
                        [
                            dbc_cardheader("Filter Players"),
                            dbc_cardbody(
                                [
                                    dcc_dropdown(
                                        id="dropdown-players",
                                        options=[
                                            (label = string(i), value = string(i)) for i in Matrix(players)
                                        ],
                                        multi=true,
                                        className="form-element"
                                    ),

                                    dbc_button(id="btn-update", "Update Filters", color="info", className="mr-1"),
                                    dbc_button("Reset", outline=true, color="danger", className="mr-1")
                                ]
                            )
                        ]
                    ),
                    lg=4, md=12, sm=12
                ),
            
                # Radar Chart Column
                dbc_col(
                    dbc_card(
                        [
                            dbc_cardheader("Radar Chart"),
                            dcc_graph(id="radar-graph")
                        ]
                    ),
                    lg=8, md=12, sm=12
                )
            ]

        )
    ]
)


content = html_div(id="page-content", className="page-content")

app.layout = html_div([dcc_location(id="url"), sidebar, content])




callback!(
    app,
    Output("radar-graph", "figure"),
    [Input("dropdown-players", "value"),
     Input("btn-update", "n_clicks")]
) do players, n_clicks

    # Check
    
    df_wind = dataset(DataFrame, "wind")

    categories = ["Acceleration","Balance","Ball Control", "Curl", "Dribbling", 
    "Finishing", "Heading", "Jump", "Kicking Power", "Lofted Pass",
    "Low Pass" ,"Offensive Awareness" ,"Physical Contact",
    "Place Kicking", "Speed", "Tight Possession"]
    
    traces = []

    if players !== nothing
        for plyr in players
            sing_row = filter(row -> row.Player_Name == string(plyr), df)
            sing_row = select!(sing_row, Not(:Player_Name))
            sing_row = DataFrame([[names(sing_row)]; collect.(eachrow(sing_row))], [:column; Symbol.(axes(sing_row, 1))])
            push!(
                traces,
                scatterpolar(
                    sing_row,
                    r=sing_row[:,2],
                    theta=:column,
                    name=plyr,
                    fill="toself",
                    marker=attr(sizeref=0.05), mode="lines"
                )
            )
        end
    end
    


    if n_clicks===nothing
        return no_update
    else
        return plot(
            [trace for trace in traces],
            Layout(
                polar=attr(
                    radialaxis=attr(
                        range=[0,100],
                        visible=true
                    )
                ),
                showlegend=true
            )
        )
    end
end




callback!(
    app,
    Output("page-content", "children"),
    Input("url", "pathname")
) do pathname
    if pathname == "/"
        return page_graphic
    elseif pathname == "/page-1"
        return html_p("This is page-1")
    elseif pathname == "/page-2"
        return html_p("This is page-2")
    else
        return html_p("404")
    end
end



run_server(app, "0.0.0.0", debug=false)