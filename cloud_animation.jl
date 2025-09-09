using GLMakie
using GeoMakie
using ClimaAnalysis

simdir = SimDir("data")
var = get(simdir, "clwvi")
lon = var.dims["lon"]
lat = var.dims["lat"]

time = Observable(1)

var_time = @lift(slice(var, time = var.dims["time"][$time]))
var_data = @lift($var_time.data)

fontsize_theme = Theme(fontsize = 20)
set_theme!(fontsize_theme)

fig = Figure(size = (1500, 800))
ax = GeoAxis(fig[1,1])
limits = (0, 0.04)

surface!(ax,
         -180..180, -90..90,
         zeros(axes(rotr90(GeoMakie.earth())));
         shading = NoShading, color = rotr90(GeoMakie.earth())
        )

lines!(ax, GeoMakie.coastlines(), color = :black)


hidedecorations!(ax)

p = surface!(ax, lon, lat, var_data,
             colorrange = limits,
             colormap = Reverse(:PuBu),
             shading = NoShading,
             alpha = 0.5,
             transparency = true,
             highclip = :white,
            )

Colorbar(
         fig[2, 1],
         p,
         label = "Cloud water path (kg m⁻²)",
         vertical = false,
         colorrange = limits,
        )

total_frames = length(var.dims["time"])

record(fig, "animation.mp4", 1:total_frames; framerate = 30) do t
    time[] = t
end
