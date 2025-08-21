# 🏭 Foundry Hybrid Containerization - Multi-Stage Dockerfile
# Integrates Microsoft Foundry-Local with Ethereum Foundry toolchain
# for cognitive cities manufacturing district

# Stage 1: Base foundation
FROM ubuntu:22.04 AS foundation

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    python3 \
    python3-pip \
    nodejs \
    npm \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Stage 2: Foundry installation (Ethereum toolchain)
FROM foundation AS foundry-layer

# Install Rust (required for Foundry)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Foundry (forge, anvil, cast)
RUN curl -L https://foundry.paradigm.xyz | bash
ENV PATH="/root/.foundry/bin:${PATH}"
RUN /root/.foundry/bin/foundryup

# Stage 3: Cognitive runtime
FROM foundry-layer AS cognitive-runtime

# Copy Python requirements
COPY requirements.txt /tmp/
RUN pip3 install -r /tmp/requirements.txt

# Install PyTorch, Transformers, and AI libraries
RUN pip3 install torch torchvision transformers jupyter

# Install additional AI/ML dependencies
RUN pip3 install \
    asyncio \
    websockets \
    fastapi \
    uvicorn \
    pydantic \
    numpy \
    pandas

# Stage 4: Neural transport protocols
FROM cognitive-runtime AS neural-transport

# Copy neural transport source
COPY neural-transport/ /opt/neural-transport/
WORKDIR /opt/neural-transport

# Install Node.js dependencies for transport layer
RUN npm install && npm install --save \
    ws \
    express \
    cors \
    uuid

# Install WebSocket and async communication libraries
RUN pip3 install websockets asyncio aiohttp

# Stage 5: AI-enhanced development tools
FROM neural-transport AS ai-tools

# Copy AI tools source
COPY ai-copilot/ /opt/ai-copilot/
WORKDIR /opt/ai-copilot

# Install AI SDK dependencies
RUN pip3 install \
    openai \
    anthropic \
    langchain \
    langchain-openai \
    chromadb \
    sentence-transformers

# Stage 6: Foundry-Local integration
FROM ai-tools AS foundry-local-layer

# Copy Foundry-Local SDK and core files
COPY sdk/ /opt/foundry-local/sdk/
COPY samples/ /opt/foundry-local/samples/

# Install Foundry-Local Python SDK
WORKDIR /opt/foundry-local/sdk/python
RUN pip3 install -e .

# Install Foundry-Local JavaScript SDK
WORKDIR /opt/foundry-local/sdk/js
RUN npm install && npm run build

# Stage 7: Production ready
FROM foundry-local-layer AS production

# Copy configuration and scripts
COPY foundry-configs/ /opt/foundry-configs/
COPY scripts/ /opt/scripts/
COPY monitoring/ /opt/monitoring/

# Set working directory
WORKDIR /workspace

# Create necessary directories
RUN mkdir -p /data /workspace/projects /workspace/configs

# Set environment variables
ENV FOUNDRY_PROFILE=cognitive-city
ENV NEURAL_TRANSPORT_ENABLED=true
ENV AI_COPILOT_ENABLED=true
ENV CITY_ID=cogcities-main

# Expose ports
EXPOSE 8545 3000 8080 9090 4000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8545/health || exit 1

# Copy startup script
COPY scripts/start-foundry-hybrid.sh /opt/scripts/
RUN chmod +x /opt/scripts/start-foundry-hybrid.sh

# Default command
CMD ["/opt/scripts/start-foundry-hybrid.sh"]