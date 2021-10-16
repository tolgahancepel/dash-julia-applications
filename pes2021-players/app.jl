"""
app.jl
"""

# Authors: Tolgahan Cepel <tolgahan.cepel@gmail.com>

using DataFrames, CSV, PlotlyJS
using Dash, DashHtmlComponents, DashCoreComponents, DashBootstrapComponents

app = dash(external_stylesheets=["assets/style.css", dbc_themes.UNITED])

df = DataFrame(CSV.File("data/pes2021.csv"))

players = select(df, :Player_Name)

n_clicks_count=0

# -----------------------------------------------------------------------------
# Sidebar
# -----------------------------------------------------------------------------
sidebar = html_div(
    [
        html_div(html_img(src="assets/pes2021-logo.png", className="logo"), className="logo-div"),
        html_hr(),

        dbc_nav(
            [
                dbc_navlink("Graphic", href="/", active="exact"),
                dbc_navlink("About", href="/about", active="exact")
            ],
            vertical=true,
            pills=true,
        )
    ],
    className="sidebar"
)

# -----------------------------------------------------------------------------
# Page - Graphic
# -----------------------------------------------------------------------------
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
                                    # dbc_button(id="btn-reset", "Reset", outline=true, color="danger", className="mr-1")
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

# -----------------------------------------------------------------------------
# Page - About
# -----------------------------------------------------------------------------

about_text= """PES2021 Dashboard is a Dash Julia application that allows you
                to compare football players on radar chart. The players data
                scraped from pesdb.net, and only top 32 players included because
                the Heroku's memory limitations."""


page_about = html_div(
    [
        dbc_row(
            dbc_col(html_h4("About"), lg=12)
        ),
        dbc_row(
            dbc_col(
                dbc_card(
                    dbc_cardbody(
                        [
                            html_p(about_text),
                            html_h5("Source Code"),
                            html_a(
                                "https://github.com/tolgahancepel/dash-julia-applications/tree/main/pes2021-players",
                                href="https://github.com/tolgahancepel/dash-julia-applications/tree/main/pes2021-players"
                            ),
                            html_h5("Dataset"),
                            html_a(
                                "https://pesdb.net/pes2021/",
                                href="https://pesdb.net/pes2021/"
                            ),
                        ], className="cardbody-about"
                    )
                )
            )
        )
    ]
)

# -----------------------------------------------------------------------------
# Content
# -----------------------------------------------------------------------------
content = html_div(id="page-content", className="page-content")

app.layout = html_div([dcc_location(id="url"), sidebar, content])

# -----------------------------------------------------------------------------
# Callbacks
# -----------------------------------------------------------------------------

# Radar Chart Update Callback
callback!(
    app,
    Output("radar-graph", "figure"),
    Input("btn-update", "n_clicks"),
    State("dropdown-players", "value")
) do n_clicks, players

    if players !== nothing

        traces = []

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

        fig = plot(
            [trace for trace in traces],
            Layout(
                showlegend=true,
                polar=attr(
                    radialaxis=attr(
                        range=[0,100],
                        visible=true
                    )
                ),
                legend=attr(
                    orientation="h",
                    yanchor="bottom",
                    y=-0.5,
                    x=0.18,
                    font=attr(
                        size=14,
                        color="#3d4465"
                    ),
                ),
            )
        )
    end
    
    if n_clicks !== nothing && n_clicks > n_clicks_count
        global n_clicks_count = n_clicks_count+1
        return fig
    else
        return no_update
    end
    
end

# Path Routing Callback
callback!(
    app,
    Output("page-content", "children"),
    Input("url", "pathname")
) do pathname
    if pathname == "/"
        return page_graphic
    elseif pathname == "/about"
        return page_about
    else
        return html_p("404")
    end
end

run_server(app, "0.0.0.0", debug=false)