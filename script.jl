using GLMakie
using GeoMakie
using ClimaAnalysis

simdir = SimDir("data")
lhf = get(simdir, "lhf")
lon = lhf.dims["lon"]
lat = lhf.dims["lat"]

month = Observable(1)

lhf_month = @lift(slice(lhf, time = lhf.dims["time"][$month]))
lhf_land = @lift(apply_oceanmask($lhf_month))
lhf_data = @lift($lhf_land.data)

fontsize_theme = Theme(fontsize = 20)
set_theme!(fontsize_theme)

fig = Figure(size = (1500, 800))
ax = GeoAxis(fig[1,1]; dest = "+proj=wintri")
limits = (0, 200)
p = surface!(ax, lon, lat, lhf_data, colorrange = limits, shading = NoShading)
Colorbar(
         fig[2, 1],
         p,
         label = "latent heat (W m⁻²)",
         vertical = false,
         colorrange = limits,
        )

record(fig, "animation.mp4", 1:12; framerate = 5) do m
    month[] = m
end
