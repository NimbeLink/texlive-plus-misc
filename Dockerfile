FROM node:25-trixie

# Install mermaid CLI
RUN npm install -g @mermaid-js/mermaid-cli

# Install packages Sphinx installs
# (see https://github.com/sphinx-doc/sphinx-docker-images/blob/master/latexpdf/Dockerfile)
RUN apt-get update && apt-get install -y \
      graphviz \
      imagemagick \
      make \
      \
      latexmk \
      lmodern \
      fonts-freefont-otf \
      texlive-latex-recommended \
      texlive-latex-extra \
      texlive-fonts-recommended \
      texlive-luatex \
      texlive-xetex \
      xindy \
      tex-gyre \
  && apt-get autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install packages we utilize internally
RUN apt-get update && apt-get install -y \
      dumb-init \
      python3-poetry \
      git \
      curl \
      python3-venv \
      plantuml \
      librsvg2-bin \
      openssh-client \
      graphviz \
      libenchant-2-dev \
      xvfb \
      libgbm1 \
      libasound2 \
      inkscape \
      fonts-montserrat \
    && apt-get autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install DrawIO
RUN <<EOF

set -e

curl -LO https://github.com/jgraph/drawio-desktop/releases/download/v27.0.9/drawio-amd64-27.0.9.deb

apt-get update
apt-get install -y ./drawio-amd64-27.0.9.deb
rm drawio-amd64-27.0.9.deb

rm -rf /var/lib/apt/lists/*
rm -rf /src/*.deb
chmod a+w .

EOF

# Create Python Virtual Environment
RUN python3 -m venv /venv

# Setup
ENV ELECTRON_DISABLE_SECURITY_WARNINGS="true" \
    ELECTRON_ENABLE_LOGGING="false" \
    ELECTRON_DISABLE_SANDBOX=1 \
    DRAWIO_DISABLE_UPDATE="true" \
    DRAWIO_DESKTOP_COMMAND_TIMEOUT="10s" \
    DRAWIO_DESKTOP_EXECUTABLE_PATH="/opt/drawio/drawio" \
    DRAWIO_DESKTOP_SOURCE_FOLDER="/opt/drawio-desktop" \
    DRAWIO_DESKTOP_RUNNER_COMMAND_LINE="/opt/drawio-desktop/runner.sh" \
    DISPLAY=":42" \
    XVFB_DISPLAY=":42" \
    XVFB_OPTIONS="-nolisten unix" \
    SCRIPT_DEBUG_MODE="false"

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
