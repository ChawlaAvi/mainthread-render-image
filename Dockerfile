# The machine image a rented RunPod machine starts from, so a rental does not
# install anything: Node, Chrome's libraries, the GPU loaders, ffmpeg, an SSH
# server, the project's npm packages and Chrome Headless Shell are already inside.
# It holds open-source software only. No project code, no keys.
#
# The package list is the one the 26 Nov 2026 GPU measurements were made with.
# Built and hosted by GitHub: see publish.mjs in this folder.
FROM ubuntu:24.04

# "all" asks the NVIDIA runtime to mount EGL and Vulkan as well as CUDA; Chrome needs those to draw on the GPU
ENV DEBIAN_FRONTEND=noninteractive NVIDIA_DRIVER_CAPABILITIES=all NVIDIA_VISIBLE_DEVICES=all

RUN apt-get update -qq \
 && apt-get install -y -qq curl ca-certificates rsync ffmpeg openssh-server fonts-liberation \
      libnss3 libdbus-1-3 libatk1.0-0 libatk-bridge2.0-0 libgbm1 libxrandr2 libxkbcommon0 libxfixes3 libxcomposite1 libxdamage1 libpango-1.0-0 libcairo2 libcups2 libasound2t64 \
      libglvnd0 libegl1 libgl1 libgles2 libvulkan1 libx11-6 libx11-xcb1 libxcb1 libxext6 libxshmfence1 libdrm2 libatspi2.0-0 libxss1 libgtk-3-0t64 \
 && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
 && apt-get install -y -qq nodejs \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# every machine makes its own SSH host keys when it starts (start.sh); none are shipped in a public image
RUN rm -f /etc/ssh/ssh_host_*

# The project is copied into /work at render time. Its node_modules folder is already here.
WORKDIR /work
COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund --loglevel=error \
 && npx remotion browser ensure \
 && npm cache clean --force \
 && mkdir -p /opt/render-image \
 && cp package-lock.json /opt/render-image/package-lock.json

COPY start.sh same-packages.mjs /opt/render-image/
CMD ["bash", "/opt/render-image/start.sh"]
