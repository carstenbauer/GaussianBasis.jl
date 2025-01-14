test_file = joinpath(@__DIR__, "CH4_631g.h5")

atoms = Molecules.parse_string("""
C   -2.131551124300    2.286168823700    0.000000000000
H   -1.061551124300    2.286168823700    0.000000000000
H   -2.488213906200    1.408104616400    0.496683911300
H   -2.488218762100    2.295059432700   -1.008766153900
H   -2.488220057000    3.155340844300    0.512081313000""")

bs = BasisSet("6-31g", atoms)
bs2 = BasisSet("sto-3g", atoms)

@testset "One-Electron Integrals" begin

    @test overlap(bs) ≈ h5read(test_file, "overlap")
    @test kinetic(bs) ≈ h5read(test_file, "kinetic")
    @test nuclear(bs) ≈ h5read(test_file, "nuclear")

    @test overlap(bs, bs2) ≈ h5read(test_file, "overlap_sto3g")
    @test kinetic(bs, bs2) ≈ h5read(test_file, "kinetic_sto3g")
    @test nuclear(bs, bs2) ./2 ≈ h5read(test_file, "nuclear_sto3g")
end

@testset "Two-Electron Four-Center" begin

    @test ERI_2e4c(bs) ≈ h5read(test_file, "denseERI")

    idx, data = sparseERI_2e4c(bs)

    uniform = zeros(Int16, length(idx)*4)
    for i in eachindex(idx)
        uniform[(1+4*(i-1)):(4+4*(i-1))] .= idx[i]
    end

    @test uniform ≈ h5read(test_file, "sparseERIidx")
    @test data ≈ h5read(test_file, "sparseERIdata")
end

@testset "Two-Electron Three-Center" begin
    @test ERI_2e3c(bs, bs2) ≈ h5read(test_file, "Pqp_aux_sto3g")
end

@testset "Two-Electron Two-Center" begin
    @test ERI_2e2c(bs) ≈ h5read(test_file, "J")
end