# """
# Dockerfile du serveur TCP de riboDB

# Copyright or © or Copr. UCBL Lyon, France;  
# contributor : [Jean-Pierre Flandrois] ([2024/12/20])
# [JP.flandrois@univ-lyon1.fr]

# This software is a computer program whose purpose is to create a TCP server interface to the riboDB sequence database.

# This software is governed by the [CeCILL|CeCILL-B|CeCILL-C] license under French law and
# abiding by the rules of distribution of free software.  You can  use, 
# modify and/ or redistribute the software under the terms of the [CeCILL|CeCILL-B|CeCILL-C]
# license as circulated by CEA, CNRS and INRIA at the following URL
# "http://www.cecill.info". 

# As a counterpart to the access to the source code and  rights to copy,
# modify and redistribute granted by the license, users are provided only
# with a limited warranty  and the software's author,  the holder of the
# economic rights,  and the successive licensors  have only  limited
# liability. 

# In this respect, the user's attention is drawn to the risks associated
# with loading,  using,  modifying and/or developing or reproducing the
# software by the user in light of its specific status of free software,
# that may mean  that it is complicated to manipulate,  and  that  also
# therefore means  that it is reserved for developers  and  experienced
# professionals having in-depth computer knowledge. Users are therefore
# encouraged to load and test the software's suitability as regards their
# requirements in conditions enabling the security of their systems and/or 
# data to be ensured and,  more generally, to use and operate it in the 
# same conditions as regards security. 

# The fact that you are presently reading this means that you have had
# knowledge of the [CeCILL|CeCILL-B|CeCILL-C] license and that you accept its terms.

# """


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
ENTRYPOINT ["julia", "--project=.", "ribodb_server.jl"]
