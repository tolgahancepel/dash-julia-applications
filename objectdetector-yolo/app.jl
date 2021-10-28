"""
app.jl
"""

# Authors: Tolgahan Cepel <tolgahan.cepel@gmail.com>
using PlotlyJS
using Dash, DashHtmlComponents, DashCoreComponents, DashBootstrapComponents
using ObjectDetector, FileIO, Images
using HTTP
using UUIDs

n_clicks_count = 0   # handling button click activitiy

# -----------------------------------------------------------------------------
# Card - Image
# -----------------------------------------------------------------------------

card_img = dbc_card(
    [
        dbc_cardheader("Yolo V3 Annnotated Frame"),
        dbc_cardbody(dcc_graph(id="graph"))
    ]
)

# -----------------------------------------------------------------------------
# Card - Control
# -----------------------------------------------------------------------------

card_control = dbc_card(
     [
         dbc_cardheader("Control"),
         dbc_cardbody(
            [
                html_div(
                    [
                        "Image URL: ",
                        dcc_input(
                            id="image-url",
                            type="text",
                            placeholder="Enter an URL",
                            value="https://obj.shine.cn/files/2020/12/31/93c26b9c-902a-46a0-8f3a-1a8cffa9badb_0.jpg"
                        )
                    ]
                ),
                
                html_div(
                    [
                        "Detection Threshold",
                        dcc_input(
                            id="detection-threshold",
                            type="range",
                            min=0,
                            max=1,
                            step=0.1,
                            value=0.4
                        )
                    ]
                ),

                html_div(
                    [
                        "Overlap Threshold",
                        dcc_input(
                            id="overlap-threshold",
                            type="range",
                            min=0,
                            max=1,
                            step=0.1,
                            value=0.4
                        )
                    ]
                ),

                dbc_button(id="btn-update", "Update", color="info", className="mr-1")
            ]
         )
     ]
)

card_info = dbc_card(
    [
        dbc_cardheader("Information"),
        dbc_cardbody(
            [
                html_p("• Decrease 'Detection Treshold' to detect more objects."),
                html_p("• Increase 'Overlap Treshold' to see many overlapped objects."),
                html_a(
                    href="https://github.com/tolgahancepel/dash-julia-applications/tree/main/objectdetector-yolo",
                    html_img(src="assets/GitHub.png", width=96),
                    target="_blank"
                )
            ],
            className="cardbody-info"
        )
    ]
)

app = dash(
    external_stylesheets=["assets/style.css",dbc_themes.UNITED]
)

# -----------------------------------------------------------------------------
# Application Layout
# -----------------------------------------------------------------------------

app.layout = html_div(
    [
        dbc_navbar(
            [
                html_img(src="https://plotly-marketing-website.cdn.prismic.io/plotly-marketing-website/948b6663-9429-4bd6-a4cc-cb33231d4532_logo-plotly.svg", height=40)
                html_h3("Object Detection with Dash Julia", className="navbar-header")
            ]
        ),
    
        dbc_container(
            dbc_row(
                [
                    dbc_col([card_control, card_info])
                    dbc_col(card_img, lg=8)
                ]
                
            )
        )
    ]
)

# -----------------------------------------------------------------------------
# Callbacks
# -----------------------------------------------------------------------------

# Detect the objects and return the image with bounding boxes 
callback!(
    app,
    Output("graph", "figure"),
    Input("btn-update", "n_clicks"),
    [
        State("detection-threshold", "value"),
        State("overlap-threshold", "value"),
        State("image-url", "value")
    ]
        
) do n_clicks, detection_threshold, overlap_threshold, image_url

    # If the user clicks Update button
    if n_clicks !== nothing && n_clicks > n_clicks_count

        # Remove all the JPG images if exist
        foreach(rm, filter(endswith(".jpg"), readdir("assets/img/",join=true)))

        # Assign a random name for the image and define directory
        IMG_DIR = string("assets/img/", UUIDs.uuid4(), ".jpg")

        # Download the image and parse threshold values
        try
            HTTP.download(image_url, IMG_DIR)
            detection_threshold = parse(Float64, detection_threshold)
            overlap_threshold = parse(Float64, overlap_threshold)
        catch
        end

        # Define YOLO v3 model (see ObjectDetector docs for more YOLO versions)
        yolomod = YOLO.v3_COCO(silent=true, w=416, h=416)
        batch = emptybatch(yolomod)

        img = load(IMG_DIR)
        batch[:,:,:,1], padding = prepareImage(img, yolomod)
        res = yolomod(batch, detectThresh=detection_threshold, overlapThresh=overlap_threshold)
        imgBoxes = drawBoxes(img, yolomod, padding, res);
        img_width = size(img)[2]
        img_height = size(img)[1]
        scale_factor = 1.0
        imgratio = size(img,2) / size(img,1)
        modelratio = 1.0
        x1i, y1i, x2i, y2i = [1, 2, 3, 4]
        h, w = size(img,2) ./ (modelratio, 1)

        shapes = []   # shapes list for bounding boxes 

        # Add bounding boxes to shapes list iteratively
        for i in 1:size(res,2)
            bbox = res[1:4, i] .- padding
            class = res[end-1, i]
            conf = res[5,i]

            x0 = round(Int, bbox[x1i]*w)+1
            x1 = round(Int, bbox[x2i]*w)
            y0 = img_height - round(Int, bbox[y1i]*h)+1
            y1 = img_height - round(Int, bbox[y2i]*h)
            
            push!(
                shapes,
                PlotlyJS.rect(
                    x0=x0, y0=y0, x1=x1, y1=y1,
                    line_color = "rgb(255, 93, 162)",
                    line_width = 2, opacity=1,
                    fillcolor="rgba(255, 93, 162, 0.3)", 
                    xref='x', yref='y'
                )
            )
        end

        # Add an invisible trace
        trace1 = scatter(
            x=[0, img_width * scale_factor],
            y=[0, img_height * scale_factor],
            mode="markers",
            marker_opacity=0
        )

        # Add layout for the image and shapes (bounding boxes)
        layout = Layout(
            xaxis = attr(
                visible=false,
                range=[0, img_width * scale_factor]
            ),
            yaxis=attr(
                visible=false,
                range=[0, img_height * scale_factor],
                scaleanchor="x"
            ),
            images=[
                attr(
                    x=0,
                    sizex=img_width * scale_factor,
                    y=img_height * scale_factor,
                    sizey=img_height * scale_factor,
                    xref="x",
                    yref="y",
                    opacity=1.0,
                    layer="above",
                    sizing="stretch",
                    source=IMG_DIR
                )
            ],
            autosize=true,
            margin=attr(l= 0, r= 0, t= 0, b= 0),
            plot_bgcolor="#fff",
            shapes=shapes   # assign shapes
        )
        
        global n_clicks_count = n_clicks_count+1   # handling update clicks
        plt = plot(trace1, layout)
        return plt

    # If the user does not click the Update button
    else
        return no_update
    end
end

run_server(app, "0.0.0.0", debug=false)