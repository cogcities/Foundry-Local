#!/bin/bash
# 🛠️ Foundry Hybrid Development Environment Setup
# Sets up local development environment for cognitive cities foundry

set -e

echo "🛠️ Setting up Foundry Hybrid Development Environment"
echo "==================================================="

# Configuration
FOUNDRY_HYBRID_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$FOUNDRY_HYBRID_DIR"

echo "📁 Working directory: $FOUNDRY_HYBRID_DIR"

# Check prerequisites
echo "🔍 Checking prerequisites..."
command -v docker >/dev/null 2>&1 || { echo "❌ Docker is required but not installed."; exit 1; }
command -v docker-compose >/dev/null 2>&1 || { echo "❌ Docker Compose is required but not installed."; exit 1; }
command -v node >/dev/null 2>&1 || { echo "❌ Node.js is required but not installed."; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "❌ Python 3 is required but not installed."; exit 1; }

echo "✅ Prerequisites satisfied"

# Create development directories
echo "📁 Creating development directories..."
mkdir -p {projects,configs,data/{foundry,knowledge,monitoring,transport,models},logs}
mkdir -p neural-transport/{protocols,clients,servers}
mkdir -p ai-copilot/{models,training,inference}
mkdir -p monitoring/{dashboards,alerts,metrics}
mkdir -p knowledge-base/{embeddings,vectors,indexes}

# Setup Python virtual environment
echo "🐍 Setting up Python environment..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

echo "✅ Python environment ready"

# Install Node.js dependencies for neural transport
echo "📦 Installing Node.js dependencies..."
cd neural-transport
if [ ! -f "package-lock.json" ]; then
    npm install
fi
cd ..

# Setup git hooks
echo "🪝 Setting up git hooks..."
if [ -d "../.git" ]; then
    cat > ../.git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Pre-commit hook for foundry-hybrid

echo "🔍 Running pre-commit checks for foundry-hybrid..."

# Check if we're in foundry-hybrid directory
if [ -d "foundry-hybrid" ]; then
    cd foundry-hybrid
fi

# Lint Python code
if command -v black >/dev/null 2>&1; then
    echo "🐍 Formatting Python code..."
    black --check ai-copilot/ monitoring/ || {
        echo "❌ Python code formatting issues found. Run 'black ai-copilot/ monitoring/' to fix."
        exit 1
    }
fi

# Lint TypeScript code
if command -v npx >/dev/null 2>&1 && [ -f "neural-transport/package.json" ]; then
    echo "📝 Checking TypeScript code..."
    cd neural-transport
    npx tsc --noEmit || {
        echo "❌ TypeScript compilation errors found."
        exit 1
    }
    cd ..
fi

# Validate Docker files
if command -v hadolint >/dev/null 2>&1; then
    echo "🐳 Linting Dockerfile..."
    hadolint Dockerfile || echo "⚠️ Dockerfile linting warnings (non-blocking)"
fi

# Validate docker-compose
echo "📋 Validating Docker Compose..."
docker-compose config >/dev/null || {
    echo "❌ Docker Compose configuration is invalid."
    exit 1
}

echo "✅ Pre-commit checks passed"
EOF

    chmod +x ../.git/hooks/pre-commit
    echo "✅ Git hooks installed"
fi

# Initialize foundry project template
echo "⚒️ Initializing foundry project template..."
if command -v forge >/dev/null 2>&1; then
    if [ ! -d "projects/example-project" ]; then
        cd projects
        forge init example-project --no-git
        cd ..
        echo "✅ Example project created"
    else
        echo "ℹ️ Example project already exists"
    fi
else
    echo "⚠️ Foundry not installed locally. Will use containerized version."
fi

# Create default configuration files
echo "⚙️ Creating default configuration..."

# Create development docker-compose override
cat > docker-compose.dev.yml << 'EOF'
# Development override for foundry-hybrid
version: '3.8'

services:
  foundry-hybrid:
    build:
      target: cognitive-runtime  # Use earlier stage for faster dev builds
    volumes:
      - ./ai-copilot:/opt/ai-copilot:ro
      - ./neural-transport:/opt/neural-transport:ro
      - ./monitoring:/opt/monitoring:ro
      - ./scripts:/opt/scripts:ro
    environment:
      - RUST_LOG=debug
      - LOG_LEVEL=debug
    ports:
      - "8545:8545"
      - "3000:3000" 
      - "8080:8080"
      - "9090:9090"
    restart: "no"  # Don't auto-restart in dev

  neural-transport-hub:
    volumes:
      - ./neural-transport:/app:ro
    environment:
      - LOG_LEVEL=debug
    restart: "no"

  ai-copilot:
    volumes:
      - ./ai-copilot:/app:ro
    environment:
      - LOG_LEVEL=debug
    restart: "no"

  monitoring:
    volumes:
      - ./monitoring:/app:ro
    environment:
      - LOG_LEVEL=debug
    restart: "no"
EOF

# Create environment file template
cat > .env.example << 'EOF'
# Foundry Hybrid Development Environment Configuration

# City Configuration
CITY_ID=cogcities-dev
FOUNDRY_PROFILE=cognitive-city

# Feature Flags
NEURAL_TRANSPORT_ENABLED=true
AI_COPILOT_ENABLED=true

# Network Configuration
ANVIL_PORT=8545
WEB_PORT=3000
COPILOT_PORT=8080
MONITORING_PORT=9090
TRANSPORT_PORT=4000

# Logging
RUST_LOG=info
LOG_LEVEL=info

# AI Configuration
OPENAI_API_KEY=your_openai_key_here
ANTHROPIC_API_KEY=your_anthropic_key_here

# Development Settings
HOT_RELOAD=true
DEBUG_MODE=true
EOF

if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "📝 Created .env file from template"
fi

# Build development images
echo "🔨 Building development containers..."
docker-compose -f docker-compose.yml -f docker-compose.dev.yml build

# Start development services
echo "🚀 Starting development services..."
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 30

# Run health checks
echo "🔍 Running health checks..."
check_service() {
    local service=$1
    local url=$2
    local name=$3
    
    if curl -sf "$url" >/dev/null 2>&1; then
        echo "  ✅ $name: healthy"
        return 0
    else
        echo "  ⚠️ $name: not ready yet"
        return 1
    fi
}

check_service "anvil" "http://localhost:8545" "Anvil RPC"
check_service "web" "http://localhost:3000" "Web Interface"
check_service "copilot" "http://localhost:8080/health" "AI Copilot"
check_service "monitoring" "http://localhost:9090/health" "Monitoring Dashboard"
check_service "transport" "http://localhost:4001/health" "Neural Transport"

echo ""
echo "✅ Development environment setup complete!"
echo ""
echo "🎯 Next steps:"
echo "  1. Open your browser to http://localhost:3000 (Web Interface)"
echo "  2. Access AI copilot at http://localhost:8080"
echo "  3. View monitoring dashboard at http://localhost:9090"
echo "  4. Check neural transport at http://localhost:4001/health"
echo "  5. Start developing in the projects/ directory"
echo ""
echo "🔧 Development commands:"
echo "  • forge build                    # Compile contracts"
echo "  • forge test                     # Run tests"
echo "  • docker-compose logs [service]  # View logs"
echo "  • docker-compose restart        # Restart services"
echo "  • docker-compose down           # Stop all services"
echo ""
echo "📚 Documentation:"
echo "  • Foundry Book: https://book.getfoundry.sh/"
echo "  • Cognitive Cities: https://docs.cogcities.dev/"
echo "  • Local setup: http://localhost:9090/docs"
echo ""
echo "🌆 Foundry hybrid development environment is ready for cognitive city: $(grep CITY_ID .env | cut -d'=' -f2)"