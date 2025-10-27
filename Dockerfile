FROM texlive/texlive:TL2024-historic

WORKDIR /doc

RUN apt-get update && apt-get install -y dumb-init \
    curl git python3-venv build-essential plantuml librsvg2-bin openssh-client \
    graphviz libenchant-2-dev libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
    libsqlite3-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
    libffi-dev liblzma-dev python3-poetry python3-pip \
    xvfb wget libgbm1 libasound2 npm inkscape \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /src/*.deb

RUN python -m venv /venv

WORKDIR "/root"

RUN <<EOF

wget -q https://github.com/jgraph/drawio-desktop/releases/download/v28.2.5/drawio-amd64-28.2.5.deb

apt-get update
apt-get install -y /opt/drawio-desktop/drawio-amd64-28.2.5.deb
rm /opt/drawio-desktop/drawio-amd64-28.2.5.deb

# Additional Fonts
apt-get install -y fonts-liberation \
  fonts-arphic-ukai fonts-arphic-uming \
  fonts-noto fonts-noto-cjk \
  fonts-ipafont-mincho fonts-ipafont-gothic \
  fonts-unfonts-core \
  fonts-montserrat

rm -rf /var/lib/apt/lists/*
rm -rf /src/*.deb
chmod a+w .

npm install -g @mermaid-js/mermaid-cli
EOF

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

WORKDIR /doc
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
