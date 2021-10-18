## Dash Julia Applications
Dash Julia is a framework created by Plotly, and allows you to create web analytics applications. You can find example applications in this repository. If you have any questions, feel free to ask me or <a href="https://community.plotly.com/c/dash/julia/20">Dash Julia Community Forum</a>.

### Applications
- <b>Tokyo Olympic Medals — </b><a href="https://dash-tokyo-olympics.herokuapp.com">Live on Heroku</a> <br>
<img src="https://raw.githubusercontent.com/tolgahancepel/dash-julia-applications/main/img/tokyo-olympics.gif" width=800></img><br><br>
- <b>Body Mass Index (BMI) Calculator — </b><a href="https://dash-bmi-calculator.herokuapp.com/">Live on Heroku</a> <br>
<img src="https://raw.githubusercontent.com/tolgahancepel/dash-julia-applications/main/img/bmi-calculator.gif" width=800></img><br><br>
- <b>PES2021 Players — </b><a href="https://dash-pes2021.herokuapp.com/">Live on Heroku</a> <br>
<img src="https://raw.githubusercontent.com/tolgahancepel/dash-julia-applications/main/img/pes2021-players.gif" width=800></img><br><br>
- <b>Activation Functions in Neural Networks — </b><a href="https://dash-activation-functions.herokuapp.com/">Live on Heroku</a> <br>
<img src="https://raw.githubusercontent.com/tolgahancepel/dash-julia-applications/main/img/activation-functions.gif" width=800></img>

P.S. If you see an error, please try refreshing the page. It's about Heroku's limited memory.

### Installation and Usage
1. Install all dependencies listed in Project.toml - for example:
```
using Pkg
Pkg.add("Dash")
```
2. Run app.jl to launch a local Dash server to host the app. Visit http://127.0.0.1:8050/ to see the application (use the following code in a command line).
```
/path/to/julia app.jl
```
or, if you added julia to PATH:
```
julia app.jl
```
