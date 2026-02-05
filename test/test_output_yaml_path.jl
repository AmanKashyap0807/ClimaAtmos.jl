import ClimaAtmos as CA
import YAML
import ClimaComms
using Test
using Logging

ClimaComms.@import_required_backends

device = ClimaComms.device()
context = ClimaComms.context(device)
ClimaComms.init(context)

@testset "Output YAML Path Test" begin
    output_dir = mktempdir()
    job_id = "test_yaml_path_fix"
    
    input_toml_path = joinpath(output_dir, "input.toml")
    open(input_toml_path, "w") do io
        print(io, "")
    end

    config_dict = Dict(
        "job_id" => job_id,
        "output_dir" => output_dir,
        "config" => "box",
        "initial_condition" => "DecayingProfile",
        "moist" => "dry",
        "precip_model" => nothing,
        "rad" => "gray",
        "t_end" => "2s",
        "dt" => "1s",
        "dt_save_state_to_disk" => "2s",
        "toml" => [input_toml_path],
        "x_max" => 1e4,
        "y_max" => 1e4,
        "z_max" => 1e4,
        "x_elem" => 4,
        "y_elem" => 4,
        "z_elem" => 10,
    )

    config = CA.AtmosConfig(config_dict; job_id)

    simulation = CA.get_simulation(config)
    real_output_dir = simulation.output_dir

    output_yaml_path = joinpath(real_output_dir, "$(job_id).yml")
    output_toml_path = joinpath(real_output_dir, "$(job_id)_parameters.toml")

    @test isfile(output_yaml_path)
    @test isfile(output_toml_path)

    yaml_data = YAML.load_file(output_yaml_path)
    @test yaml_data["toml"] == [abspath(output_toml_path)]
    @test yaml_data["toml"] != [input_toml_path]

    rm(output_dir, recursive=true)
end
