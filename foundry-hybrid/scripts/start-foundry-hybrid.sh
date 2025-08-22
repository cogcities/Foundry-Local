#!/bin/bash
# 🏭 Foundry Hybrid Manufacturing District Startup Script
# Orchestrates the complete cognitive cities foundry ecosystem

set -e

echo "🏭 Starting Foundry Hybrid Manufacturing District"
echo "================================================="

# Environment setup
export FOUNDRY_PROFILE=${FOUNDRY_PROFILE:-"cognitive-city"}
export CITY_ID=${CITY_ID:-"cogcities-main"}
export NEURAL_TRANSPORT_ENABLED=${NEURAL_TRANSPORT_ENABLED:-"true"}
export AI_COPILOT_ENABLED=${AI_COPILOT_ENABLED:-"true"}

echo "📋 Configuration:"
echo "  City ID: $CITY_ID"
echo "  Foundry Profile: $FOUNDRY_PROFILE"
echo "  Neural Transport: $NEURAL_TRANSPORT_ENABLED"
echo "  AI Copilot: $AI_COPILOT_ENABLED"
echo ""

# Create necessary directories
mkdir -p /data/{foundry,knowledge,monitoring,transport,models}
mkdir -p /workspace/{projects,configs,logs}

# Initialize Foundry configuration
echo "⚙️ Initializing Foundry configuration..."
if [ ! -f /workspace/configs/foundry.toml ]; then
    cp /opt/foundry-configs/foundry.toml /workspace/configs/
fi

# Start neural transport hub if enabled
if [ "$NEURAL_TRANSPORT_ENABLED" = "true" ]; then
    echo "🧠 Starting neural transport protocols..."
    cd /opt/neural-transport
    npm start &
    NEURAL_TRANSPORT_PID=$!
    echo "  Neural transport started with PID: $NEURAL_TRANSPORT_PID"
fi

# Start AI copilot if enabled
if [ "$AI_COPILOT_ENABLED" = "true" ]; then
    echo "🤖 Starting AI copilot services..."
    cd /opt/ai-copilot
    python3 -m foundry_copilot &
    AI_COPILOT_PID=$!
    echo "  AI copilot started with PID: $AI_COPILOT_PID"
fi

# Start Anvil (Ethereum local testnet)
echo "⛏️ Starting Anvil testnet..."
cd /workspace
anvil --host 0.0.0.0 --port 8545 --accounts 10 --balance 10000 &
ANVIL_PID=$!
echo "  Anvil started with PID: $ANVIL_PID"

# Wait for Anvil to be ready
sleep 5
echo "  Anvil RPC available at: http://localhost:8545"

# Start Foundry-Local service
echo "🚀 Starting Foundry-Local AI service..."
cd /opt/foundry-local
# Note: This would start the actual Foundry-Local service
# foundry-local serve --port 3000 &
# For now, we'll start a simple web server as placeholder
python3 -m http.server 3000 &
FOUNDRY_LOCAL_PID=$!
echo "  Foundry-Local started with PID: $FOUNDRY_LOCAL_PID"

# Start monitoring dashboard
echo "📊 Starting monitoring dashboard..."
cd /opt/monitoring
python3 -m monitoring_dashboard --port 9090 &
MONITORING_PID=$!
echo "  Monitoring dashboard started with PID: $MONITORING_PID"

# Health check function
health_check() {
    echo "🔍 Performing health checks..."
    
    # Check Anvil
    if curl -s http://localhost:8545 > /dev/null; then
        echo "  ✅ Anvil RPC: healthy"
    else
        echo "  ❌ Anvil RPC: unhealthy"
    fi
    
    # Check Foundry-Local
    if curl -s http://localhost:3000 > /dev/null; then
        echo "  ✅ Foundry-Local: healthy"
    else
        echo "  ❌ Foundry-Local: unhealthy"
    fi
    
    # Check AI Copilot (if enabled)
    if [ "$AI_COPILOT_ENABLED" = "true" ]; then
        if curl -s http://localhost:8080 > /dev/null; then
            echo "  ✅ AI Copilot: healthy"
        else
            echo "  ❌ AI Copilot: unhealthy"
        fi
    fi
    
    # Check Monitoring
    if curl -s http://localhost:9090 > /dev/null; then
        echo "  ✅ Monitoring: healthy"
    else
        echo "  ❌ Monitoring: unhealthy"
    fi
}

# Initial health check
sleep 10
health_check

echo ""
echo "✅ Foundry Hybrid Manufacturing District is active!"
echo ""
echo "📊 Access points:"
echo "  Anvil RPC: http://localhost:8545"
echo "  Foundry-Local: http://localhost:3000"
if [ "$AI_COPILOT_ENABLED" = "true" ]; then
    echo "  AI Copilot: http://localhost:8080"
fi
echo "  Monitoring: http://localhost:9090"
if [ "$NEURAL_TRANSPORT_ENABLED" = "true" ]; then
    echo "  Neural Transport: ws://localhost:4000"
fi
echo ""
echo "🌆 Manufacturing district active in cognitive city: $CITY_ID"

# Cleanup function
cleanup() {
    echo ""
    echo "🛑 Shutting down Foundry Hybrid Manufacturing District..."
    
    if [ ! -z "$ANVIL_PID" ]; then
        kill $ANVIL_PID 2>/dev/null || true
    fi
    
    if [ ! -z "$FOUNDRY_LOCAL_PID" ]; then
        kill $FOUNDRY_LOCAL_PID 2>/dev/null || true
    fi
    
    if [ ! -z "$AI_COPILOT_PID" ]; then
        kill $AI_COPILOT_PID 2>/dev/null || true
    fi
    
    if [ ! -z "$NEURAL_TRANSPORT_PID" ]; then
        kill $NEURAL_TRANSPORT_PID 2>/dev/null || true
    fi
    
    if [ ! -z "$MONITORING_PID" ]; then
        kill $MONITORING_PID 2>/dev/null || true
    fi
    
    echo "🏁 Shutdown complete"
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

# Keep the container running and perform periodic health checks
while true; do
    sleep 300  # 5 minutes
    health_check
done