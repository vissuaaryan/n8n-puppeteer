FROM debian:bullseye-slim

ENV TZ=Etc/UTC DEBIAN_FRONTEND=noninteractive \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

RUN apt-get update && \
    apt-get install -y wget curl gnupg unzip fontconfig ca-certificates \
    nodejs chromium && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    rm -rf /var/lib/apt/lists/*

# Create app dir
WORKDIR /app

# Install n8n
RUN npm install -g n8n

# Install deps for Puppeteer server
RUN npm install express puppeteer --prefix /app

# Copy Puppeteer server script
COPY puppeteer-server.js /app/puppeteer-server.js

EXPOSE 5678 3000

# Start both services: n8n + puppeteer server
CMD ["sh", "-c", "node /app/puppeteer-server.js & n8n start --tunnel"]
