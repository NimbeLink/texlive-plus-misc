FROM node:25-trixie

# Install mermaid CLI and Wavedrom-cli
RUN npm install -g @mermaid-js/mermaid-cli wavedrom-cli

RUN <<EOF
  set -e

  export DEBIAN_FRONTEND=noninteractive
  apt-get update

  # Install packages Sphinx installs, plus internally used packages
  # (see https://github.com/sphinx-doc/sphinx-docker-images/blob/master/latexpdf/Dockerfile)
  apt-get install -y \
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
      tex-gyre

  # Install packages used internally
  apt-get install -y \
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
      fonts-montserrat

  # Install package required by mermaid-cli
  apt-get install -y chromium

  # Install DrawIO
  curl -LO https://github.com/jgraph/drawio-desktop/releases/download/v27.0.9/drawio-amd64-27.0.9.deb
  apt-get install -y ./drawio-amd64-27.0.9.deb
  rm drawio-amd64-27.0.9.deb

  # Clean up Apt
  apt-get autoremove
  apt-get clean
  rm -rf /var/lib/apt/lists/*
EOF

# Create Python Virtual Environment
RUN python3 -m venv /venv

# Wrap mmdc to pass in a puppeteer configuration to pass --no-sandbox to
# Chrome since it's being run in Docker.
ADD puppeteer-config.json /.puppeteerrc.json
RUN rm /usr/local/bin/mmdc
ADD mmdc /usr/local/bin/mmdc

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
