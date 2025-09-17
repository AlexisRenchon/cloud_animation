using GLMakie
using GeoMakie
using ClimaAnalysis
using FileIO

earth_img = load(download("https://upload.wikimedia.org/wikipedia/commons/5/56/Blue_Marble_Next_Generation_%2B_topography_%2B_bathymetry.jpg"))

fig = Figure(size = (2000, 2000), backgroundcolor = :black)
ax = GeoMakie.GlobeAxis(fig[1,1]; show_axis = false)

simdir = SimDir("data")
var = get(simdir, "clwvi")
lon = var.dims["lon"]
lat = var.dims["lat"]

surface!(ax,
         -180..180, -90..90,
         zeros(axes(rotr90(earth_img)));
         shading = NoShading,
         color = rotr90(earth_img),
         backlight = 1.5f0,
        )

# lines!(ax, GeoMakie.coastlines(), color = :black)

time = Observable(1)

var_time = @lift(slice(var, time = var.dims["time"][$time]))
var_data = @lift($var_time.data)

limits = (0, 0.04)

# var_data_normalized = @lift(($var_data .- minimum($var_data)) ./ (maximum($var_data) - minimum($var_data)))

p = surface!(ax, lon, lat, var_data,
             zlevel = 300_000,
             colorrange = limits,
             colormap = Reverse(:PuBu),
             #colormap = [:white, :white],
             shading = NoShading,
             #             alpha = var_data_normalized,
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
    rotate_cam!(ax.scene, 0, -0.015, 0)
end

#
#record(fig, "animation.gif", 1:total_frames; framerate = 20, compression = 40) do t
#    if t == 1
#        zoom!(ax.scene, 0.6)
#    end
#    time[] = t
#    rotate_cam!(ax.scene, 0, -0.015, 0)
#end
