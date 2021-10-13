using PlotlyJS
using Dash, DashHtmlComponents, DashCoreComponents, DashBootstrapComponents

app = dash(external_stylesheets=["assets/style.css", dbc_themes.UNITED])

app.layout = dbc_container(
    [
        dbc_row(
            dbc_col(
                dbc_jumbotron(html_h1("Body Mass Index Calculator"), className="bmi-jumbotron")
            )
        )

        dbc_row(
            [
                dbc_col(
                    dbc_card(
                        [
                            dbc_cardheader("BMI Calculation")

                            dbc_cardbody(
                                dbc_formgroup(
                                    [
                                        dbc_inputgroup(
                                            [
                                                dbc_inputgroupaddon("Height", addon_type="prepend")
                                                dbc_input(id="inp-height", placeholder="Height in centimeters", type="number", min=1, max=250, step=1)
                                            ]
                                        )

                                        dbc_inputgroup(
                                            [
                                                dbc_inputgroupaddon("Weight", addon_type="prepend")
                                                dbc_input(id="inp-weight", placeholder="Weight in kilograms", type="number", min=1, max=250, step=1)
                                            ]
                                        )

                                        dbc_button(id="btn-calculate", "Calculate", color="info", className="mr-1")
                                        dbc_button(id="btn-reset", "Reset", outline=true, color="danger", className="mr-1")
                                    ]
                                ), className="cardbody-bmi-calculation"
                            )
                        ]
                    ),
                    lg=4, md=12, sm=12
                )

                dbc_col(
                    dbc_card(
                        [
                            html_h2("YOUR BMI")
                            html_h1(id="bmi-value")
                        ], className="card-bmi-info"
                    )
                )

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
                        ]
                    ),
                    lg=4, md=12, sm=12
                )
            ]
        )

        dbc_row(
            dbc_col(
                html_img(src="assets/bmi-chart.png", className="bmi-chart"),
                lg=12, md=12, sm=12
            )
        )
    ]
)

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

run_server(app, "0.0.0.0", debug=false)