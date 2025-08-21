#!/bin/bash

# 🏙️ Cognitive Cities Development Environment Setup
# Comprehensive setup script for cognitive cities development ecosystem

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
COGNITIVE_CITIES_VERSION=${COGNITIVE_CITIES_VERSION:-"1.0.0"}
DEPLOYMENT_ENV=${DEPLOYMENT_ENV:-"development"}
CITY_ID=${CITY_ID:-"cogcities-local"}
DISTRICT_ID=${DISTRICT_ID:-"main"}

echo -e "${CYAN}🏙️ Cognitive Cities Development Environment Setup${NC}"
echo -e "${CYAN}=================================================${NC}"
echo ""
echo -e "${BLUE}Configuration:${NC}"
echo -e "  Version: ${COGNITIVE_CITIES_VERSION}"
echo -e "  Environment: ${DEPLOYMENT_ENV}"
echo -e "  City ID: ${CITY_ID}"
echo -e "  District ID: ${DISTRICT_ID}"
echo ""

# Function to print status messages
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_step "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is required but not installed."
        echo "Please install Docker from: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is required but not installed."
        echo "Please install Docker Compose from: https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    # Check Python 3.12+
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3.12+ is required but not installed."
        exit 1
    fi
    
    python_version=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    if ! python3 -c "import sys; exit(0 if sys.version_info >= (3, 12) else 1)"; then
        print_error "Python 3.12+ is required. Found: $python_version"
        exit 1
    fi
    
    # Check Node.js 20+
    if ! command -v node &> /dev/null; then
        print_error "Node.js 20+ is required but not installed."
        exit 1
    fi
    
    node_version=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$node_version" -lt 20 ]; then
        print_error "Node.js 20+ is required. Found: v$node_version"
        exit 1
    fi
    
    # Check Git
    if ! command -v git &> /dev/null; then
        print_error "Git is required but not installed."
        exit 1
    fi
    
    print_status "All prerequisites satisfied"
}

# Create directory structure
create_directory_structure() {
    print_step "Creating cognitive cities directory structure..."
    
    # Core directories
    mkdir -p cognitive-cities/{governance,districts,infrastructure,ecosystem}
    mkdir -p cognitive-cities/governance/{mayor-ai,city-council,urban-planning,citizen-services}
    mkdir -p cognitive-cities/districts/{innovation,manufacturing,residential,transport-hub,data}
    mkdir -p cognitive-cities/infrastructure/{neural-transport,power-grid,waste-management,emergency-services}
    mkdir -p cognitive-cities/ecosystem/{sister-cities,trade-routes,immigration,tourism}
    
    # Development directories
    mkdir -p development/{scripts,configs,templates,tools}
    mkdir -p development/scripts/{deployment,monitoring,backup,migration}
    mkdir -p development/configs/{environment,security,networking,storage}
    mkdir -p development/templates/{docker,kubernetes,terraform,github-actions}
    
    # Data directories
    mkdir -p data/{knowledge-base,conversations,insights,metrics}
    mkdir -p data/knowledge-base/{tier-1,tier-2,tier-3,tier-4}
    mkdir -p data/conversations/{active,archived,analyzed}
    mkdir -p data/insights/{patterns,predictions,recommendations}
    mkdir -p data/metrics/{performance,quality,evolution,collaboration}
    
    # Logs and temporary directories
    mkdir -p logs/{application,system,neural-transport,knowledge-sync}
    mkdir -p tmp/{downloads,processing,cache,backups}
    
    print_status "Directory structure created"
}

# Setup Python environment
setup_python_environment() {
    print_step "Setting up Python environment..."
    
    # Create virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        print_status "Creating Python virtual environment..."
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Upgrade pip
    print_status "Upgrading pip..."
    pip install --upgrade pip
    
    # Install cognitive cities requirements
    print_status "Installing Python dependencies..."
    
    # Create requirements file if it doesn't exist
    if [ ! -f "requirements-cognitive-cities.txt" ]; then
        cat > requirements-cognitive-cities.txt << EOF
# Core AI/ML libraries
torch>=2.8.0
transformers>=4.55.0
datasets>=2.0.0
accelerate>=0.20.0

# Cognitive architecture
langchain>=0.1.0
semantic-kernel>=0.5.0
openai>=1.0.0
anthropic>=0.3.0

# Neural transport protocols
websockets>=12.0
asyncio-mqtt>=0.13.0
grpcio>=1.60.0
grpcio-tools>=1.60.0

# Knowledge management
redis>=5.0.0
elasticsearch>=8.0.0
neo4j>=5.0.0
chromadb>=0.4.0

# Web framework and APIs
fastapi>=0.104.0
uvicorn>=0.24.0
pydantic>=2.0.0
httpx>=0.25.0

# Development tools
pytest>=7.4.0
black>=23.0.0
isort>=5.12.0
mypy>=1.7.0

# Monitoring and observability
prometheus-client>=0.19.0
structlog>=23.2.0
sentry-sdk>=1.38.0

# Data processing
pandas>=2.0.0
numpy>=1.24.0
scipy>=1.11.0
matplotlib>=3.7.0

# Jupyter and notebooks
jupyter>=1.0.0
ipywidgets>=8.1.0
plotly>=5.17.0
EOF
    fi
    
    pip install -r requirements-cognitive-cities.txt
    
    print_status "Python environment setup complete"
}

# Setup Node.js environment
setup_nodejs_environment() {
    print_step "Setting up Node.js environment..."
    
    # Create package.json if it doesn't exist
    if [ ! -f "package.json" ]; then
        print_status "Creating package.json..."
        cat > package.json << EOF
{
  "name": "cognitive-cities",
  "version": "1.0.0",
  "description": "Cognitive Cities development environment",
  "main": "index.js",
  "scripts": {
    "start": "node cognitive-cities/main.js",
    "dev": "nodemon cognitive-cities/main.js",
    "test": "jest",
    "build": "tsc",
    "lint": "eslint . --ext .ts,.js",
    "format": "prettier --write ."
  },
  "dependencies": {
    "ws": "^8.14.0",
    "fastify": "^4.24.0",
    "socket.io": "^4.7.0",
    "redis": "^4.6.0",
    "neo4j-driver": "^5.15.0",
    "openai": "^4.20.0",
    "@anthropic-ai/sdk": "^0.9.0",
    "@octokit/rest": "^20.0.0",
    "dotenv": "^16.3.0",
    "winston": "^3.11.0",
    "joi": "^17.11.0"
  },
  "devDependencies": {
    "@types/node": "^20.10.0",
    "@types/ws": "^8.5.0",
    "typescript": "^5.3.0",
    "nodemon": "^3.0.0",
    "jest": "^29.7.0",
    "@types/jest": "^29.5.0",
    "eslint": "^8.54.0",
    "prettier": "^3.1.0",
    "tsx": "^4.6.0"
  },
  "keywords": [
    "cognitive-cities",
    "ai",
    "distributed-systems",
    "neural-transport"
  ],
  "author": "Cognitive Cities Development Team",
  "license": "MIT"
}
EOF
    fi
    
    # Install dependencies
    print_status "Installing Node.js dependencies..."
    npm install
    
    print_status "Node.js environment setup complete"
}

# Setup Docker environment
setup_docker_environment() {
    print_step "Setting up Docker environment..."
    
    # Create main docker-compose.yml
    if [ ! -f "docker-compose.yml" ]; then
        print_status "Creating docker-compose.yml..."
        cat > docker-compose.yml << EOF
version: '3.8'

services:
  # Neural Transport Hub
  neural-transport-hub:
    build:
      context: ./cognitive-cities/infrastructure/neural-transport
      dockerfile: Dockerfile
    ports:
      - "4000:4000"    # WebSocket server
      - "4001:4001"    # HTTP API
    environment:
      - NODE_ENV=development
      - CITY_ID=${CITY_ID}
      - DISTRICT_ID=${DISTRICT_ID}
      - REDIS_URL=redis://redis:6379
    depends_on:
      - redis
    networks:
      - cognitive-cities
    restart: unless-stopped

  # Knowledge Base Service
  knowledge-base:
    build:
      context: ./cognitive-cities/districts/data
      dockerfile: Dockerfile
    ports:
      - "5000:5000"    # Knowledge API
    environment:
      - PYTHON_ENV=development
      - REDIS_URL=redis://redis:6379
      - ELASTICSEARCH_URL=http://elasticsearch:9200
      - NEO4J_URI=bolt://neo4j:7687
    depends_on:
      - redis
      - elasticsearch
      - neo4j
    volumes:
      - knowledge-data:/data
    networks:
      - cognitive-cities
    restart: unless-stopped

  # AI Mayor Agent
  mayor-ai:
    build:
      context: ./cognitive-cities/governance/mayor-ai
      dockerfile: Dockerfile
    ports:
      - "6000:6000"    # Mayor API
    environment:
      - PYTHON_ENV=development
      - NEURAL_TRANSPORT_HUB=ws://neural-transport-hub:4000
      - KNOWLEDGE_BASE_URL=http://knowledge-base:5000
      - OPENAI_API_KEY=\${OPENAI_API_KEY}
    depends_on:
      - neural-transport-hub
      - knowledge-base
    networks:
      - cognitive-cities
    restart: unless-stopped

  # Foundry Manufacturing District
  foundry-hybrid:
    build:
      context: ./cognitive-cities/districts/manufacturing
      dockerfile: Dockerfile
    ports:
      - "8545:8545"    # Anvil RPC
      - "3000:3000"    # Web interface
      - "8080:8080"    # AI copilot
    environment:
      - FOUNDRY_PROFILE=cognitive-city
      - NEURAL_TRANSPORT_ENABLED=true
      - CITY_ID=${CITY_ID}
    volumes:
      - foundry-data:/data
      - ./projects:/workspace/projects
    networks:
      - cognitive-cities
    restart: unless-stopped

  # Monitoring Dashboard
  monitoring:
    build:
      context: ./cognitive-cities/infrastructure/monitoring
      dockerfile: Dockerfile
    ports:
      - "7000:7000"    # Dashboard
      - "9090:9090"    # Prometheus
    environment:
      - MONITOR_SERVICES=neural-transport-hub,knowledge-base,mayor-ai,foundry-hybrid
    volumes:
      - monitoring-data:/data
    networks:
      - cognitive-cities
    restart: unless-stopped

  # Redis for caching and message queuing
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      - cognitive-cities
    restart: unless-stopped

  # Elasticsearch for knowledge search
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.0
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch-data:/usr/share/elasticsearch/data
    networks:
      - cognitive-cities
    restart: unless-stopped

  # Neo4j for knowledge graph
  neo4j:
    image: neo4j:5.14
    environment:
      - NEO4J_AUTH=none
      - NEO4J_PLUGINS=["apoc"]
    ports:
      - "7474:7474"   # Web interface
      - "7687:7687"   # Bolt protocol
    volumes:
      - neo4j-data:/data
    networks:
      - cognitive-cities
    restart: unless-stopped

volumes:
  knowledge-data:
  foundry-data:
  monitoring-data:
  redis-data:
  elasticsearch-data:
  neo4j-data:

networks:
  cognitive-cities:
    driver: bridge
EOF
    fi
    
    # Create development override
    if [ ! -f "docker-compose.override.yml" ]; then
        cat > docker-compose.override.yml << EOF
version: '3.8'

services:
  neural-transport-hub:
    volumes:
      - ./cognitive-cities/infrastructure/neural-transport:/app
    environment:
      - NODE_ENV=development
      - DEBUG=cognitive-cities:*
    command: npm run dev

  knowledge-base:
    volumes:
      - ./cognitive-cities/districts/data:/app
      - ./data:/data
    environment:
      - PYTHON_ENV=development
      - DEBUG=1
    command: python -m uvicorn main:app --host 0.0.0.0 --port 5000 --reload

  mayor-ai:
    volumes:
      - ./cognitive-cities/governance/mayor-ai:/app
    environment:
      - PYTHON_ENV=development
      - DEBUG=1
    command: python -m uvicorn main:app --host 0.0.0.0 --port 6000 --reload
EOF
    fi
    
    print_status "Docker environment configuration created"
}

# Create template files
create_template_files() {
    print_step "Creating template files..."
    
    # Neural Transport Hub main file
    mkdir -p cognitive-cities/infrastructure/neural-transport
    cat > cognitive-cities/infrastructure/neural-transport/main.js << 'EOF'
#!/usr/bin/env node

/**
 * Neural Transport Hub - Main Entry Point
 * Cognitive Cities Infrastructure Component
 */

const WebSocket = require('ws');
const http = require('http');
const redis = require('redis');
const winston = require('winston');

// Configure logging
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: '/var/log/neural-transport.log' })
  ]
});

class NeuralTransportHub {
  constructor() {
    this.port = process.env.PORT || 4000;
    this.cityId = process.env.CITY_ID || 'cognitive-city-local';
    this.connections = new Map();
    this.messageQueue = [];
    
    // Initialize Redis client
    this.redisClient = redis.createClient({
      url: process.env.REDIS_URL || 'redis://localhost:6379'
    });
  }

  async start() {
    try {
      await this.redisClient.connect();
      logger.info('Connected to Redis');

      // Create HTTP server
      this.server = http.createServer();
      
      // Create WebSocket server
      this.wss = new WebSocket.Server({ 
        server: this.server,
        path: '/neural-transport'
      });

      this.wss.on('connection', (ws, req) => {
        this.handleConnection(ws, req);
      });

      // Start HTTP server
      this.server.listen(this.port, () => {
        logger.info(`Neural Transport Hub started on port ${this.port}`);
        logger.info(`City ID: ${this.cityId}`);
      });

      // Setup health check endpoint
      this.server.on('request', (req, res) => {
        if (req.url === '/health') {
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ 
            status: 'healthy', 
            cityId: this.cityId,
            connections: this.connections.size,
            timestamp: new Date().toISOString()
          }));
        }
      });

    } catch (error) {
      logger.error('Failed to start Neural Transport Hub:', error);
      process.exit(1);
    }
  }

  handleConnection(ws, req) {
    const connectionId = Math.random().toString(36).substr(2, 9);
    logger.info(`New connection: ${connectionId}`);

    this.connections.set(connectionId, {
      ws,
      cityId: null,
      districtId: null,
      connectedAt: Date.now(),
      messageCount: 0
    });

    ws.on('message', async (data) => {
      try {
        const message = JSON.parse(data.toString());
        await this.processMessage(connectionId, message);
      } catch (error) {
        logger.error(`Error processing message from ${connectionId}:`, error);
      }
    });

    ws.on('close', () => {
      logger.info(`Connection closed: ${connectionId}`);
      this.connections.delete(connectionId);
    });

    ws.on('error', (error) => {
      logger.error(`Connection error ${connectionId}:`, error);
    });
  }

  async processMessage(connectionId, message) {
    const connection = this.connections.get(connectionId);
    if (!connection) return;

    connection.messageCount++;

    switch (message.type) {
      case 'registration':
        await this.handleRegistration(connectionId, message);
        break;
      case 'protocol_message':
        await this.routeProtocolMessage(connectionId, message);
        break;
      case 'heartbeat':
        await this.handleHeartbeat(connectionId, message);
        break;
      default:
        logger.warn(`Unknown message type: ${message.type}`);
    }
  }

  async handleRegistration(connectionId, message) {
    const connection = this.connections.get(connectionId);
    connection.cityId = message.cityId;
    connection.districtId = message.districtId;

    logger.info(`Registered: ${message.cityId}/${message.districtId}`);

    connection.ws.send(JSON.stringify({
      type: 'registration_success',
      connectionId,
      hubInfo: {
        version: '1.0.0',
        supportedProtocols: ['TEP', 'KSP', 'ACP', 'MCP']
      }
    }));
  }

  async routeProtocolMessage(connectionId, message) {
    // Route message to target connections
    const targets = message.targets || ['broadcast'];
    
    for (const [targetId, targetConnection] of this.connections) {
      if (targetId === connectionId) continue;
      
      if (targets.includes('broadcast') || 
          targets.includes(targetConnection.cityId) ||
          targets.includes(`${targetConnection.cityId}/${targetConnection.districtId}`)) {
        
        targetConnection.ws.send(JSON.stringify(message));
      }
    }

    // Store message in Redis for persistence
    await this.redisClient.lpush('message_history', JSON.stringify({
      ...message,
      timestamp: Date.now(),
      sourceConnection: connectionId
    }));
  }

  async handleHeartbeat(connectionId, message) {
    const connection = this.connections.get(connectionId);
    connection.ws.send(JSON.stringify({
      type: 'heartbeat_ack',
      timestamp: Date.now()
    }));
  }
}

// Start the hub
const hub = new NeuralTransportHub();
hub.start().catch(error => {
  console.error('Failed to start hub:', error);
  process.exit(1);
});
EOF

    # Knowledge Base main file
    mkdir -p cognitive-cities/districts/data
    cat > cognitive-cities/districts/data/main.py << 'EOF'
#!/usr/bin/env python3

"""
Knowledge Base Service - Cognitive Cities Data District
Main API server for distributed knowledge management
"""

import asyncio
import json
import logging
from datetime import datetime
from typing import Dict, List, Optional, Any

from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import redis.asyncio as redis
import httpx

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Pydantic models
class KnowledgeItem(BaseModel):
    id: str
    type: str
    content: Any
    metadata: Dict[str, Any]
    tags: List[str]
    confidence: float
    source: str
    created_at: datetime
    updated_at: datetime

class QueryRequest(BaseModel):
    query: str
    filters: Optional[Dict[str, Any]] = None
    limit: int = 10
    include_metadata: bool = True

class SyncRequest(BaseModel):
    source_city: str
    knowledge_items: List[KnowledgeItem]
    sync_type: str = "incremental"

# FastAPI app
app = FastAPI(
    title="Cognitive Cities Knowledge Base",
    description="Distributed knowledge management for cognitive cities",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class KnowledgeBaseService:
    def __init__(self):
        self.redis_client = None
        self.knowledge_store = {}
        self.sync_queue = []
        
    async def initialize(self):
        """Initialize the knowledge base service"""
        self.redis_client = redis.from_url(
            "redis://redis:6379", 
            decode_responses=True
        )
        logger.info("Knowledge Base Service initialized")
        
    async def store_knowledge(self, item: KnowledgeItem) -> bool:
        """Store a knowledge item"""
        try:
            # Store in Redis
            key = f"knowledge:{item.id}"
            await self.redis_client.set(key, item.json())
            
            # Add to search index
            await self._index_knowledge_item(item)
            
            logger.info(f"Stored knowledge item: {item.id}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to store knowledge item {item.id}: {e}")
            return False
            
    async def query_knowledge(self, query: QueryRequest) -> List[KnowledgeItem]:
        """Query knowledge items"""
        try:
            # Simple implementation - in production, use Elasticsearch
            keys = await self.redis_client.keys("knowledge:*")
            results = []
            
            for key in keys[:query.limit]:
                data = await self.redis_client.get(key)
                if data:
                    item = KnowledgeItem.parse_raw(data)
                    if self._matches_query(item, query):
                        results.append(item)
                        
            return results
            
        except Exception as e:
            logger.error(f"Query failed: {e}")
            return []
            
    def _matches_query(self, item: KnowledgeItem, query: QueryRequest) -> bool:
        """Check if knowledge item matches query"""
        # Simple text matching - in production, use semantic search
        query_text = query.query.lower()
        
        # Search in content
        if isinstance(item.content, str) and query_text in item.content.lower():
            return True
            
        # Search in tags
        if any(query_text in tag.lower() for tag in item.tags):
            return True
            
        return False
        
    async def _index_knowledge_item(self, item: KnowledgeItem):
        """Index knowledge item for search"""
        # Add to tag indices
        for tag in item.tags:
            await self.redis_client.sadd(f"tag_index:{tag}", item.id)
            
        # Add to type index
        await self.redis_client.sadd(f"type_index:{item.type}", item.id)

# Global service instance
kb_service = KnowledgeBaseService()

@app.on_event("startup")
async def startup_event():
    await kb_service.initialize()

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "knowledge-base",
        "timestamp": datetime.now().isoformat()
    }

@app.post("/knowledge")
async def store_knowledge(item: KnowledgeItem):
    """Store a knowledge item"""
    success = await kb_service.store_knowledge(item)
    if success:
        return {"status": "stored", "id": item.id}
    else:
        raise HTTPException(status_code=500, detail="Failed to store knowledge item")

@app.post("/query")
async def query_knowledge(query: QueryRequest):
    """Query knowledge items"""
    results = await kb_service.query_knowledge(query)
    return {
        "query": query.query,
        "results": results,
        "count": len(results)
    }

@app.post("/sync")
async def sync_knowledge(sync_request: SyncRequest, background_tasks: BackgroundTasks):
    """Synchronize knowledge from another city"""
    background_tasks.add_task(process_sync, sync_request)
    return {
        "status": "sync_queued",
        "source_city": sync_request.source_city,
        "item_count": len(sync_request.knowledge_items)
    }

async def process_sync(sync_request: SyncRequest):
    """Process knowledge synchronization in background"""
    logger.info(f"Processing sync from {sync_request.source_city}")
    
    for item in sync_request.knowledge_items:
        await kb_service.store_knowledge(item)
        
    logger.info(f"Sync completed: {len(sync_request.knowledge_items)} items")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=5000)
EOF

    # Create Dockerfiles
    cat > cognitive-cities/infrastructure/neural-transport/Dockerfile << 'EOF'
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 4000 4001

CMD ["node", "main.js"]
EOF

    cat > cognitive-cities/districts/data/Dockerfile << 'EOF'
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "main.py"]
EOF

    print_status "Template files created"
}

# Create development scripts
create_development_scripts() {
    print_step "Creating development scripts..."
    
    mkdir -p scripts
    
    # Start development environment
    cat > scripts/start-dev-environment.sh << 'EOF'
#!/bin/bash

echo "🚀 Starting Cognitive Cities Development Environment"
echo "=================================================="

# Activate Python environment
if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
    echo "✅ Python virtual environment activated"
fi

# Start Docker services
echo "🐳 Starting Docker services..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 30

# Check service health
echo "🔍 Checking service health..."
services=("neural-transport-hub:4000" "knowledge-base:5000" "redis:6379")

for service in "${services[@]}"; do
    IFS=':' read -r name port <<< "$service"
    if curl -f "http://localhost:$port/health" &>/dev/null; then
        echo "✅ $name is healthy"
    else
        echo "⚠️ $name is not responding"
    fi
done

echo ""
echo "🌟 Development environment is ready!"
echo ""
echo "📊 Service URLs:"
echo "  Neural Transport Hub: ws://localhost:4000/neural-transport"
echo "  Knowledge Base API: http://localhost:5000"
echo "  Redis: localhost:6379"
echo "  Elasticsearch: http://localhost:9200" 
echo "  Neo4j Browser: http://localhost:7474"
echo ""
echo "📚 Development tools:"
echo "  View logs: docker-compose logs -f [service-name]"
echo "  Restart service: docker-compose restart [service-name]"
echo "  Stop environment: docker-compose down"
EOF

    # Stop development environment
    cat > scripts/stop-dev-environment.sh << 'EOF'
#!/bin/bash

echo "🛑 Stopping Cognitive Cities Development Environment"
echo "================================================="

# Stop Docker services
docker-compose down

echo "✅ Development environment stopped"
EOF

    # Monitor system health
    cat > scripts/monitor-system-health.sh << 'EOF'
#!/bin/bash

echo "📊 Cognitive Cities System Health Monitor"
echo "======================================="

while true; do
    clear
    echo "📊 System Health - $(date)"
    echo "=========================="
    echo ""
    
    # Check Docker containers
    echo "🐳 Docker Containers:"
    docker-compose ps
    echo ""
    
    # Check service health
    echo "🏥 Service Health:"
    services=("neural-transport-hub:4000" "knowledge-base:5000")
    
    for service in "${services[@]}"; do
        IFS=':' read -r name port <<< "$service"
        if curl -s "http://localhost:$port/health" | jq -r '.status' 2>/dev/null; then
            echo "✅ $name: healthy"
        else
            echo "❌ $name: unhealthy"
        fi
    done
    echo ""
    
    # Show resource usage
    echo "💻 Resource Usage:"
    echo "Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    echo "Disk: $(df -h | awk '$NF=="/" {print $3 "/" $2}')"
    echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')%"
    echo ""
    
    echo "Press Ctrl+C to exit"
    sleep 10
done
EOF

    # Make scripts executable
    chmod +x scripts/*.sh
    
    print_status "Development scripts created"
}

# Create configuration files
create_configuration_files() {
    print_step "Creating configuration files..."
    
    # Environment configuration
    cat > .env.example << 'EOF'
# Cognitive Cities Configuration

# Environment
NODE_ENV=development
PYTHON_ENV=development
DEPLOYMENT_ENV=development

# City Identity
CITY_ID=cogcities-local
DISTRICT_ID=main
CITY_VERSION=1.0.0

# API Keys (replace with actual keys)
OPENAI_API_KEY=your_openai_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here
GITHUB_TOKEN=your_github_token_here

# Database URLs
REDIS_URL=redis://localhost:6379
ELASTICSEARCH_URL=http://localhost:9200
NEO4J_URI=bolt://localhost:7687

# Neural Transport
NEURAL_TRANSPORT_HUB=ws://localhost:4000/neural-transport
NEURAL_TRANSPORT_ENABLED=true

# Knowledge Base
KNOWLEDGE_BASE_URL=http://localhost:5000
KNOWLEDGE_SYNC_INTERVAL=3600

# Monitoring
MONITORING_ENABLED=true
LOG_LEVEL=info
METRICS_ENABLED=true

# Security
JWT_SECRET=your_jwt_secret_here
ENCRYPTION_KEY=your_encryption_key_here
EOF

    # Copy to actual .env file
    if [ ! -f ".env" ]; then
        cp .env.example .env
        print_status "Created .env file from template"
    fi
    
    # VSCode configuration
    mkdir -p .vscode
    cat > .vscode/settings.json << 'EOF'
{
    "python.defaultInterpreterPath": "./venv/bin/python",
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": false,
    "python.linting.flake8Enabled": true,
    "python.formatting.provider": "black",
    "python.sortImports.args": ["--profile", "black"],
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    },
    "files.exclude": {
        "**/__pycache__": true,
        "**/.pytest_cache": true,
        "**/node_modules": true,
        "**/venv": true,
        "**/.git": true
    },
    "search.exclude": {
        "**/node_modules": true,
        "**/venv": true,
        "**/.git": true,
        "**/data": true,
        "**/logs": true,
        "**/tmp": true
    }
}
EOF

    cat > .vscode/launch.json << 'EOF'
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Python: Knowledge Base",
            "type": "python",
            "request": "launch",
            "program": "${workspaceFolder}/cognitive-cities/districts/data/main.py",
            "console": "integratedTerminal",
            "env": {
                "PYTHONPATH": "${workspaceFolder}",
                "PYTHON_ENV": "development"
            }
        },
        {
            "name": "Node.js: Neural Transport",
            "type": "node",
            "request": "launch",
            "program": "${workspaceFolder}/cognitive-cities/infrastructure/neural-transport/main.js",
            "env": {
                "NODE_ENV": "development",
                "DEBUG": "cognitive-cities:*"
            }
        }
    ]
}
EOF

    print_status "Configuration files created"
}

# Run initial tests
run_initial_tests() {
    print_step "Running initial tests..."
    
    # Test Python environment
    print_status "Testing Python environment..."
    source venv/bin/activate
    python -c "import torch; print(f'PyTorch: {torch.__version__}')"
    python -c "import transformers; print(f'Transformers: {transformers.__version__}')"
    
    # Test Node.js environment
    print_status "Testing Node.js environment..."
    node --version
    npm --version
    
    # Test Docker
    print_status "Testing Docker..."
    docker --version
    docker-compose --version
    
    print_status "All tests passed"
}

# Generate setup report
generate_setup_report() {
    print_step "Generating setup report..."
    
    cat > SETUP_REPORT.md << EOF
# 🏙️ Cognitive Cities Development Environment Setup Report

## Setup Summary

**Date**: $(date)
**Environment**: ${DEPLOYMENT_ENV}
**City ID**: ${CITY_ID}
**District ID**: ${DISTRICT_ID}
**Version**: ${COGNITIVE_CITIES_VERSION}

## ✅ Completed Setup Tasks

- [x] Prerequisites verification
- [x] Directory structure creation
- [x] Python environment setup ($(python3 --version))
- [x] Node.js environment setup ($(node --version))
- [x] Docker environment configuration
- [x] Template files creation
- [x] Development scripts creation
- [x] Configuration files setup
- [x] Initial testing

## 📁 Directory Structure

\`\`\`
cognitive-cities/
├── governance/          # City governance systems
├── districts/          # Specialized city districts
├── infrastructure/     # Core infrastructure services
└── ecosystem/         # External connections

development/
├── scripts/           # Deployment and management scripts
├── configs/          # Environment configurations
├── templates/        # Docker, K8s, and other templates
└── tools/           # Development utilities

data/
├── knowledge-base/   # Distributed knowledge storage
├── conversations/    # Conversation history
├── insights/        # AI-generated insights
└── metrics/         # Performance and quality metrics
\`\`\`

## 🚀 Getting Started

### Start Development Environment
\`\`\`bash
./scripts/start-dev-environment.sh
\`\`\`

### Monitor System Health
\`\`\`bash
./scripts/monitor-system-health.sh
\`\`\`

### Stop Development Environment
\`\`\`bash
./scripts/stop-dev-environment.sh
\`\`\`

## 🌐 Service URLs

- **Neural Transport Hub**: ws://localhost:4000/neural-transport
- **Knowledge Base API**: http://localhost:5000
- **Redis**: localhost:6379
- **Elasticsearch**: http://localhost:9200
- **Neo4j Browser**: http://localhost:7474

## 📚 Next Steps

1. **Configure API Keys**: Update .env file with actual API keys
2. **Start Services**: Run \`./scripts/start-dev-environment.sh\`
3. **Test Integration**: Verify all services are communicating
4. **Deploy Foundry**: Set up manufacturing district
5. **Connect Cities**: Establish neural transport to other cities

## 🔧 Development Workflow

1. **Activate Python Environment**: \`source venv/bin/activate\`
2. **Start Development Services**: \`docker-compose up -d\`
3. **Make Changes**: Edit code in respective directories
4. **Test Changes**: Use individual service endpoints
5. **View Logs**: \`docker-compose logs -f [service-name]\`

## 📊 Monitoring and Debugging

- **Service Logs**: \`docker-compose logs -f\`
- **Container Status**: \`docker-compose ps\`
- **Resource Usage**: Check monitoring dashboard
- **Health Checks**: All services expose /health endpoints

## 🚨 Troubleshooting

### Common Issues

1. **Port Conflicts**: Services use ports 3000, 4000, 5000, 6379, 7474, 8545, 9200
2. **Permission Issues**: Ensure Docker daemon is running
3. **API Key Issues**: Verify .env file configuration
4. **Memory Issues**: Docker services require ~4GB RAM

### Getting Help

- Check service logs: \`docker-compose logs [service-name]\`
- Verify network connectivity: \`docker network ls\`
- Reset environment: \`docker-compose down -v && docker-compose up -d\`

---

**🎉 Cognitive Cities development environment is ready for innovation!**
EOF

    print_status "Setup report generated: SETUP_REPORT.md"
}

# Main execution
main() {
    print_step "Starting Cognitive Cities Development Environment Setup"
    
    check_prerequisites
    create_directory_structure
    setup_python_environment
    setup_nodejs_environment
    setup_docker_environment
    create_template_files
    create_development_scripts
    create_configuration_files
    run_initial_tests
    generate_setup_report
    
    echo ""
    echo -e "${GREEN}🎉 Cognitive Cities Development Environment Setup Complete!${NC}"
    echo ""
    echo -e "${BLUE}📋 Next Steps:${NC}"
    echo -e "  1. Review and update ${YELLOW}.env${NC} file with your API keys"
    echo -e "  2. Run ${YELLOW}./scripts/start-dev-environment.sh${NC} to start services"
    echo -e "  3. Check ${YELLOW}SETUP_REPORT.md${NC} for detailed information"
    echo -e "  4. Visit http://localhost:7000 for monitoring dashboard"
    echo ""
    echo -e "${CYAN}🏙️ Welcome to the Cognitive Cities ecosystem!${NC}"
}

# Run main function
main "$@"