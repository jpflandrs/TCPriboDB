# #FromPlatformFlagConstDisallowed: FROM --platform flag should not use constant value "linux/amd64"
# FROM julia:latest 

# # Create user and set up directories
# RUN useradd --create-home --shell /bin/bash ribo_tcp
# RUN mkdir /home/ribo_tcp/app
# RUN mkdir /home/ribo_tcp/app/public
# RUN mkdir /home/ribo_tcp/app/public/utilisateurs
# COPY . /home/ribo_tcp/app
# WORKDIR /home/ribo_tcp/app
# COPY Project.toml /home/ribo_tcp/app/

# # Install system dependencies and clean up in one RUN to reduce layers
# # no dependancies
   
# # Set ownership
# RUN chown -R ribo_tcp:ribo_tcp /home/

# # Switch to ribo_tcp user
# USER ribo_tcp

# # Configure ports
# EXPOSE 8080

# # Set environment variables LegacyKeyValueFormat: "ENV key=value" should be used instead of legacy "ENV key value" format
# ENV JULIA_DEPOT_PATH="/home/ribo_tcp/.julia"
# ENV JULIA_REVISE="off"

# # ENV PORT="8020"
# # ENV WSPORT="8080"


# # Install Julia packages
# RUN julia --project=. -e "import Pkg; using Pkg; Pkg.resolve(); Pkg.instantiate(); Pkg.precompile();"

# ENTRYPOINT ["julia", "--project=.", "server.jl"]
FROM julia:latest 

# Create user and set up directories
RUN useradd --create-home --shell /bin/bash ribo_tcp
RUN mkdir -p /home/ribo_tcp/app/public/utilisateurs
WORKDIR /home/ribo_tcp/app

# Copy application files
COPY . /home/ribo_tcp/app/

# Set ownership
RUN chown -R ribo_tcp:ribo_tcp /home/ribo_tcp

# Switch to ribo_tcp user
USER ribo_tcp

# Set environment variables
ENV JULIA_DEPOT_PATH="/home/ribo_tcp/.julia"
ENV JULIA_REVISE="off"

# Install Julia packages
RUN julia --project=. -e "import Pkg; Pkg.resolve(); Pkg.instantiate(); Pkg.precompile();"

# Expose port
EXPOSE 8080

# Set entrypoint
ENTRYPOINT ["julia", "--project=.", "server.jl"]
