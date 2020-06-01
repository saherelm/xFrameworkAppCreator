#
# Select Base Image ...
FROM ubuntu:latest

#
# Update Packages ...
RUN DEBIAN_FRONTEND=noninteractive \
    apt update;

#
# Install Requirements ...
RUN DEBIAN_FRONTEND=noninteractive \
    apt install -y --no-install-recommends \
    #
    # My Favorite Requirements ...
    #
    # Browsing and File Manipulations ...
    mc \
    #
    # Search and Replace File Content ...
    sed \
    #
    # Most Common File Editor ...
    nano \
    #
    # Node js ...
    nodejs \
    #
    # Download Manager ...
    curl \
    #
    # Handling Certificates ...
    ca-certificates \
    #
    # Git Source Control Management ...
    git;

#
# Installing NPM ...
RUN curl -L https://npmjs.org/install.sh | sh

#
# Installing npm Packages ...
RUN npm install -g @angular/cli
RUN npm install -g fx

#
# Create Output Voluem ...
RUN mkdir /var/x-framework

#
# Clone AppCreator ...
RUN git clone --recursive https://github.com/saherelm/xFrameworkAppCreator.git /var/x-framework

#
# Working Directory ...
WORKDIR /var/x-framework
RUN git submodule foreach 'git checkout master'
RUN mkdir projects
VOLUME [ "/var/x-framework/projects" ]

#
# Start ...
ENTRYPOINT ["/var/x-framework/create.sh"]