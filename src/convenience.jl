# Formats package and version into a standard string
package_name(package::Package) = package_name(package.name, package.version)
package_name(package::String, version::VersionNumber) = "$package-$version"
# Creates standard work-directory name
builddir(package::Package, workdir::String) = abspath(joinpath(workdir, package_name(package)))
# Directory where the package is located with debian files and such
function packagedir(package::Package, workdir::String)
  joinpath(builddir(package, workdir), package_name(package))
end
# Creates standard tar-file name
function tarfile(package::Package, workdir::String)
  const version = VersionNumber(package.version.major, package.version.minor, package.version.patch)
  joinpath(builddir(package, workdir), "$(package.name)_$(version).orig.tar.gz")
end
function sourcedir(package::Package, workdir::String)
  joinpath(builddir(package, workdir), "source", package_name(package))
end

# Converts from kwargs for list of dictionaries
# Each dictionary specifies a binary package
function get_binaries(name::String; kwargs...)
  # Transform variable keyword arguments into binary packages
  current = Dict{Symbol, Any}()
  binaries = Dict{Symbol, Any}[]

  # Adds to list of packages, making sure a package name is available
  function add_package(current, binaries)
    if !haskey(current, :package); current[:package] = name end
    push!(binaries, current)
  end

  for (key, value) in kwargs
    if key == :package && length(current) > 0
      add_package(current, binaries)
      current = {key => value}
    else
      current[key] = value
    end
  end
  if length(current) > 0; add_package(current, binaries) end
  if length(binaries) == 0; push!(binaries, {:package => name}) end
  binaries
end
