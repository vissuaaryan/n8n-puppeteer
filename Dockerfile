# Use Debian-based image (better for Chromium deps)
FROM debian:bullseye-slim

# Prevent tzdata prompt (fuck interactive setup)
ENV TZ=Etc/UTC \
    DEBIAN_FRONTEND=noninteractive \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=false \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Install required packages (fuck yes)
RUN apt-get update && \
    apt-get install -y wget curl gnupg unzip fontconfig ca-certificates sudo && \
    # Add NodeSource repo for Node.js 18
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    # Install Chromium (Puppeteer needs this)
    apt-get install -y chromium && \
    # Clean up
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /root/.cache/puppeteer

# Set working directory
WORKDIR /opt/n8n

# Install n8n globally
RUN npm install -g n8n

# Add user to prevent running as root (security my ass, we still do it anyway)
RUN groupadd --gid 1001 nodeuser && \
    useradd --uid 1001 --gid nodeuser --shell /bin/bash --create-home nodeuser && \
    echo 'nodeuser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/nodeuser

# Switch to user
USER nodeuser

# Install Puppeteer globally so nodes can use it
RUN npm install puppeteer

# Expose port
EXPOSE 5678

# Set environment variables for headless Chrome in Docker
ENV NODE_OPTIONS="--no-sandbox --disable-setuid-sandbox"
ENV N8N_BASIC_AUTH_ACTIVE=false
ENV N8N_HOST=localhost
ENV N8N_PORT=5678

# Start n8n with browser automation enabled
CMD ["sh", "-c", "n8n start --tunnel"]
