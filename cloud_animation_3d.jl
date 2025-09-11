using GLMakie
using GeoMakie
using ClimaAnalysis

fig = Figure(size = (2000, 2000), backgroundcolor = :black)
ax = GeoMakie.GlobeAxis(fig[1,1]; show_axis = false)

simdir = SimDir("data")
var = get(simdir, "clwvi")
lon = var.dims["lon"]
lat = var.dims["lat"]

surface!(ax,
         -180..180, -90..90,
         zeros(axes(rotr90(GeoMakie.earth())));
         shading = NoShading, color = rotr90(GeoMakie.earth())
        )

# lines!(ax, GeoMakie.coastlines(), color = :black)

time = Observable(1)

var_time = @lift(slice(var, time = var.dims["time"][$time]))
var_data = @lift($var_time.data)

limits = (0, 0.04)

p = surface!(ax, lon, lat, var_data,
             zlevel = 500_000,
             colorrange = limits,
             colormap = Reverse(:PuBu),
             shading = NoShading,
             alpha = 0.3,
             transparency = true,
             highclip = :white,
            )

total_frames = length(var.dims["time"])

record(fig, "animation.mp4", 1:total_frames; framerate = 20, compression = 10) do t
    if t == 1
        zoom!(ax.scene, 0.6)
    end
    time[] = t
    rotate_cam!(ax.scene, 0, 0.01, 0)
end
