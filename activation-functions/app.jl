"""
app.jl
"""

# Authors: Tolgahan Cepel <tolgahan.cepel@gmail.com>

using PlotlyJS
using Dash, DashHtmlComponents, DashCoreComponents, DashBootstrapComponents

app = dash(
    external_stylesheets=["assets/style.css",
    "https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-MML-AM_CHTML",
    dbc_themes.UNITED]
)
dcc_interval()

# -----------------------------------------------------------------------------
# Activation Functions
# -----------------------------------------------------------------------------


# Linear
function linear(x)
    return x
end

# Unit Step
function unit_step(x)
    x_new=[]
    for i in x
        if(i < 0)
            append!(x_new,0)
        elseif x==0
            append!(0)
        else
            append!(x_new,1)
        end
    end
    return x_new
end

# Signum
function signum(x)
    x_new=[]
    for i in x
        if(i < 0)
            append!(x_new,-1)
        elseif x==0
            append!(0)
        else
            append!(x_new,1)
        end
    end
    return x_new
end

# Sigmoid
sigmoid(x) = 1.0 ./(1.0 .+ exp.(-x))

# Hyperbolic Tangent
function hardtanh(x)
    x_new=[]
    for i in x
        append!(x_new,tanh(i))
    end
    return x_new
end

# Relu
function relu(x)
    x_new=[]
    for i in x
        append!(x_new,max(0,i))
    end
    return x_new
end


# -----------------------------------------------------------------------------
# Card - Dropdown
# -----------------------------------------------------------------------------

card_dropdown = dbc_card(
    [
        dbc_cardheader("Activation Function"),
        dbc_cardbody(
            [
                dcc_dropdown(
                    id="dropdown-functions",
                    options=[
                        (label="Linear", value="linear"),
                        (label="Unit Step", value="unit_step"),
                        (label="Signum", value="signum"),
                        (label="Sigmoid", value="sigmoid"),
                        (label="Hyperbolic Tangent", value="tanh"),
                        (label="ReLu", value="relu"),
                    ],
                    value="",
                    multi=true
                ),
                
                dcc_radioitems(
                    id="radio-ranges",
                    options=[
                        (label="(-1 to +1)", value="one"),
                        (label="(-10 to +10)", value="ten")
                    ],
                    value="one"
                )
            ]
            
        )
    ]
)

card_info = dbc_card(
    [
        dbc_cardheader("INFO"),
        dbc_cardbody(
            [
                html_p("Please use [-10 to 10] range for Sigmoid and Hyperbolic Tangent. Have fun!"),
                html_a(
                    href="#",
                    html_img(src="assets/GitHub-Mark-Light-64px.png", width=32)
                )
            ]
        )
    ], className="cardbody-info"
)

# -----------------------------------------------------------------------------
# Card- Graph
# -----------------------------------------------------------------------------

card_graph = dbc_card(
    [
        dbc_cardheader("1-Dimension Graph"),
        dbc_cardbody(dcc_graph(id="graph"))
    ]
)

# -----------------------------------------------------------------------------
# Application Layout
# -----------------------------------------------------------------------------

app.layout = dbc_container(
    [
        dbc_jumbotron(
            html_h3("Activation Functions in Neural Networks"),
        ),
        dbc_row(
            [
                dbc_col(
                    html_div(
                        [
                            card_dropdown,
                            card_info
                        ]
                    ),
                    lg=4,sm=12
                ),

                dbc_col(
                    card_graph,
                    lg=8, sm=12
                )
            ]
        )
    ]
)

# -----------------------------------------------------------------------------
# Calbacks
# -----------------------------------------------------------------------------

callback!(
    app,
    Output("graph", "figure"),
    [Input("dropdown-functions", "value"),
     Input("radio-ranges", "value")]
) do function_names, range_selected

    axis_range=[]
    if range_selected=="one"
        axis_range=[-1.01,1.01]
    else
        axis_range=[-10.01,10.01]
    end
    

    layout=Layout(
        autosize=true,
        margin=attr(l=20, r=20, b=20, t=50),
        hovermode="closest",
        plot_bgcolor="#192233",
        paper_bgcolor="#192233",
        # legend=dict(font=dict(size=10), orientation="h"),
        # title="1-Dimension Graph",
        font_color ="#fff",
        xaxis_showgrid=false,
        yaxis_showgrid=false,
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
                color="#fff"
            ),
        ),
        yaxis=attr(
            title="Activation(z)",
            range=[-1.02,1.02],
            tickfont_size= 14,
            tickfont_color="rgb(107, 107, 107)"
        ),
        xaxis=attr(
            title="z",
            range=axis_range,
            tickfont_size= 14,
            tickfont_color="rgb(107, 107, 107)",
            
        ),

        font=attr(
            size=14,
        )

    )



    if isempty(function_names)
        return plot(layout)
    else
        x = range(-10,stop=10,length=5000)
        traces=[]
        
        if typeof(function_names) !== Vector{Any}
            function_names=[function_names]
        end
        

        for name in function_names

            if name=="linear"
                y=linear(x)
            elseif name=="unit_step"
                y=unit_step(x)
            elseif name=="signum"
                y=signum(x)
            elseif name=="sigmoid"
                y=sigmoid(x)
            elseif name=="tanh"
                y=hardtanh(x)
            elseif name=="relu"
                y=relu(x)
            end


            push!(
                traces,
                scatter(
                    x=x,
                    y=y,
                    name=name,
                    # marker_color="red"
                    line_width=4,
                )
            )
        end

        fig=plot(
            [trace for trace in traces],
            layout
        )

        return fig
    end
end


run_server(app, "0.0.0.0", debug=false)
