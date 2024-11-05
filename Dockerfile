FROM ubuntu:20.04

# Install Node.js, qBittorrent and other dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    qbittorrent-nox \
    supervisor \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

WORKDIR /app

# Create necessary directories
RUN mkdir -p /downloads /config /var/log/qbittorrent src/utils public/dist

# Copy qBittorrent config
COPY qBittorrent.conf /config/qBittorrent/qBittorrent.conf

# Copy package files first
COPY package*.json ./
COPY webpack.config.js ./

# Install dependencies
RUN npm install

# Copy all source files
COPY . .

# Build React app
RUN npm run build

# Environment variables
ENV NODE_ENV=production
ENV PORT=3000
ENV QB_USERNAME=admin
ENV QB_PASSWORD=adminadmin

# Expose ports for Node.js and qBittorrent
EXPOSE 3000 8080

# Copy supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Debug: List files
RUN ls -la public/dist/

# Start services using supervisor
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]