"""
app.jl
"""

# Authors: Tolgahan Cepel <tolgahan.cepel@gmail.com>

using PlotlyJS
using Dash, DashHtmlComponents, DashCoreComponents, DashBootstrapComponents

app = dash(external_stylesheets=["assets/style.css", dbc_themes.UNITED])

app.layout = dbc_container(
    [
        # ---------------------------------------------------------------------
        # Jumbotron
        # ---------------------------------------------------------------------
        dbc_row(
            dbc_col(
                dbc_jumbotron(html_h1("Body Mass Index Calculator"), className="bmi-jumbotron")
            )
        )

        # ---------------------------------------------------------------------
        # Calculation and Result
        # ---------------------------------------------------------------------
        dbc_row(
            [
                # BMI Calculation Column
                dbc_col(
                    dbc_card(
                        [
                            dbc_cardheader("BMI Calculation")
                            dbc_cardbody(
                                dbc_formgroup(
                                    [
                                        dbc_inputgroup(
                                            [
                                                dbc_inputgroupaddon("Height",
                                                                    addon_type="prepend")
                                                dbc_input(id="inp-height",
                                                          placeholder="Height in centimeters",
                                                          type="number", min=152, max=193, step=1)
                                            ]
                                        )

                                        dbc_inputgroup(
                                            [
                                                dbc_inputgroupaddon("Weight",
                                                                    addon_type="prepend")
                                                dbc_input(id="inp-weight",
                                                          placeholder="Weight in kilograms",
                                                          type="number", min=45, max=97, step=1)
                                            ]
                                        )

                                        dbc_button(id="btn-calculate", "Calculate",
                                                   color="info", className="mr-1")
                                        dbc_button(id="btn-reset", "Reset",
                                                   outline=true, color="danger", className="mr-1")
                                    ]
                                ), className="cardbody-bmi-calculation"
                            )
                        ], className="card-tiny"
                    ),
                    lg=4, md=12, sm=12
                )

                # BMI Result Column
                dbc_col(
                    dbc_card(
                        dbc_cardbody(
                            [
                                html_h2("YOUR BMI")
                                html_h1(id="bmi-value")
                            ], className="card-bmi-info"
                        ), className="card-tiny"
                    )
                )

                # BMI Weight Ranges Column
                dbc_col(
                    dbc_card(
                        [
                            dbc_cardheader("BMI Weight Ranges")
                            dbc_cardbody(
                                [
                                    html_p("Less than 18.5 = Underweight")
                                    html_p("Between 18.5 - 24.9 = Healthy Weight")
                                    html_p("Between 25 - 29.9 = Overweight")
                                    html_p("Over 30 = Obese")
                                ]
                            )
                        ], className="card-tiny"
                    ),
                    lg=4, md=12, sm=12
                )
            ]
        )

        # ---------------------------------------------------------------------
        # BMI Chart
        # ---------------------------------------------------------------------
        dbc_row(
            dbc_col(
                dbc_card(
                    [
                        dbc_cardheader("BMI Chart"),
                        dbc_cardbody(dcc_graph(id="bmi-chart"), className="cardbody-bmi-chart")
                    ], className="bmi-chart"
                )
            )
        )
    ]
)

# ---------------------------------------------------------------------
# Callbacks
# ---------------------------------------------------------------------

# BMI value calculation callback
callback!(
    app,
    Output("bmi-value", "children"),
    Input("btn-calculate", "n_clicks"),
    [State("inp-height", "value"),
     State("inp-weight", "value")]

) do n_clicks, height, weight
    if n_clicks===nothing
        return no_update
    else
        return round(weight / ((height/100) * (height/100)), digits=2)
    end
end

# Reset button callback
callback!(
    app,
    [Output("inp-height", "value"),
     Output("inp-weight", "value")],
    Input("btn-reset", "n_clicks")
) do n_clicks
    if n_clicks==true
        return nothing, nothing
    else
        return no_update, no_update
    end
end

# BMI chart and value annotation callback
callback!(
    app,
    Output("bmi-chart", "figure"),
    Input("bmi-value", "children"),
    [State("inp-height", "value"),
     State("inp-weight", "value")]
) do bmi_value, height, weight


    trace1 = heatmap(
        z=[[12,12,12,13,13,14,14,14,15,15,16,16,17,17,18,18.5,19],
        [12,13,13,13,14,14,15,15,16,16,17,17,18,18,19,19,20],
        [13,13,14,14,14,15,15,16,16,17,17,18,18,19,20,20,21],
        [14,14,14,15,15,16,16,17,17,18,18,19,19,20,21,21,22],
        [14,15,15,15,16,16,17,17,18,18,19,20,20,21,22,22,23],
        [15,15,16,16,17,17,18,18,19,19,20,20,21,22,22,23,24],
        [15,16,16,17,17,18,18,19,19,20,21,21,22,23,23,24,25],
        [16,16,17,17,18,18,19,20,20,21,21,22,23,24,24,25,26],
        [17,17,18,18,19,19,20,20,21,22,22,23,24,24,25,26,27],
        [17,18,18,19,19,20,20,21,22,22,23,24,24,25,26,27,28],
        [18,18,19,19,20,21,21,22,22,23,24,25,25,26,27,28,29],
        [18,19,19,20,21,21,22,22,23,24,25,25,26,27,28,29,30],
        [19,20,20,21,21,22,23,23,24,25,25,26,27,28,29,30,31],
        [20,20,21,21,22,23,23,24,25,25,26,27,28,29,30,31,32],
        [20,21,21,22,23,23,24,25,25,26,27,28,29,30,31,32,33],
        [21,21,22,23,23,24,25,25,26,27,28,29,30,31,32,33,34],
        [22,22,23,23,24,25,25,26,27,28,29,30,31,32,33,34,35],
        [22,23,24,25,25,26,27,28,28,29,30,31,32,33,34,35,36],
        [23,23,24,25,25,26,27,28,28,29,30,31,32,33,34,36,37],
        [23,24,25,25,26,27,28,28,29,30,31,32,33,34,35,36,38],
        [24,25,25,26,27,28,28,29,30,31,32,33,34,35,36,37,39],
        [25,25,26,27,27,28,29,30,31,32,33,34,35,36,37,38,40],
        [25,26,27,27,28,29,30,31,32,33,34,35,36,37,38,39,41],
        [26,26,27,28,29,30,30,31,32,33,34,35,37,38,39,40,42]],
        
        x=[45.5,47.7,50,52.3,54.5,56.8,59.1,61.4,63.6,65.9,68.2,70.5,
        72.7,75,77.3,79.5,81.8,84.1,86.4,88.6,90.9,93.2,95.5,97.7],
        
        y=[193,190.5,187.9,185.4,182.8,180.3,177.8,175.2,172.7,170.1,
        167.6,165.1,162.5,160,157.4,154.9,152.4],
        
        colorscale=[[0, "rgb(255,196,18)"],
        [0.21, "rgb(255,196,18)"], 
        [0.21, "rgb(18,203,198)"],
        [0.43, "rgb(18,203,198)"],
        [0.43, "rgb(24,134,169)"], 
        [0.6, "rgb(24,134,169)"],
        [0.6, "rgb(242,73,104)"],
        [0.93, "rgb(242,73,104)"],
        [0.93, "rgb(181,53,114)"],
        [1, "rgb(181,53,114)"]],

        xgap=3,
        ygap=3,
        autosize=true,
        hovertemplate= "Height: %{y} cm <br>Weight: %{x} kg <br>BMI: %{z} <extra></extra>",
        showscale=false,
    )

    # Traces only for legend
    trace2 = scatter(name="Underweight", x=[50], y=[182.8], marker_color="rgb(255,196,18)", marker_size=12, visible=true, mode="markers")
    trace3 = scatter(name="Healthy", x=[61.4], y=[170.1], marker_color="rgb(18,203,198)", marker_size=12, visible=true, mode="markers")
    trace4 = scatter(name="Overweight", x=[75], y=[165.1], marker_color="rgb(24,134,169)", marker_size=12, visible=true, mode="markers")
    trace5 = scatter(name="Obese", x=[88.6], y=[160], marker_color="rgb(242,73,104)", marker_size=12, visible=true, mode="markers")
    trace6 = scatter(name="Extreme", x=[97.7], y=[154.9], marker_color="rgb(181,53,114)", marker_size=12, visible=true, mode="markers")

    if string(typeof(weight)) != "NamedTuple{(), Tuple{}}"
        annotations=[
            attr(
                x=weight,
                y=height,
                text="Your BMI value is here!",
                showarrow=true,
                arrowsize=2,
                arrowhead=1,
                arrowcolor="#3d4465",
                yshift=10,
                font=attr(
                    size=18,
                    color="#3d4465",
                    weight=900
                ),
                bgcolor="white",
            )
        ]
    else
        annotations=[]
    end

    fig = plot(
        [trace2, trace3, trace4, trace5, trace6, trace1],
    
        Layout(
            height=600,
            yaxis_autorange="reversed",
            plot_bgcolor="rgb(251,251,253)",
            paper_bgcolor="rgb(251,251,253)",
            yaxis=attr(
                title="Height (cm)",
                tickfont_size= 14,
                tickfont_color="rgb(107, 107, 107)"
            ),
            xaxis=attr(
                title="Weight (kg)",
                tickfont_size= 14,
                tickfont_color="rgb(107, 107, 107)"
            ),
            annotations=annotations,
            margin=attr(t=20),
            legend=attr(
                orientation="h",
                yanchor="bottom",
                y=1.05,
                x=0.18,
                font=attr(
                    size=14,
                    color="#3d4465"
                ),
            ),
            xaxis_range=[43, 100],
            yaxis_range=[152.4, 193]
        )
    )

    return fig
end

run_server(app, "0.0.0.0", debug=false)