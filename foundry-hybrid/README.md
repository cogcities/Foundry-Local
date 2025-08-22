# 🏭 Foundry Hybrid Manufacturing District

A containerized foundry system that integrates Microsoft Foundry-Local (AI models platform) with Ethereum Foundry toolchain (blockchain development) for cognitive cities architecture.

## 🎯 Overview

The Foundry Hybrid Manufacturing District serves as the **manufacturing district** for cognitive cities, providing:

- **AI-Enhanced Smart Contract Development** with integrated copilot
- **Neural Transport Protocols** for cross-city knowledge sharing  
- **Real-time Monitoring** and analytics dashboard
- **Containerized Deployment** with Docker and Kubernetes
- **Automated CI/CD Pipeline** with GitHub Actions

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- Node.js 18+ and Python 3.9+
- Git

### Development Setup

1. **Clone and setup environment:**
   ```bash
   cd foundry-hybrid
   ./scripts/setup-dev-environment.sh
   ```

2. **Access services:**
   - Web Interface: http://localhost:3000
   - AI Copilot: http://localhost:8080
   - Monitoring: http://localhost:9090
   - Anvil RPC: http://localhost:8545
   - Neural Transport: ws://localhost:4000

### Production Deployment

1. **Docker Compose:**
   ```bash
   docker-compose up -d
   ```

2. **Kubernetes:**
   ```bash
   kubectl apply -f k8s/production/
   ```

## 🏗️ Architecture

```
Foundry Hybrid Manufacturing District
├── foundry-core/              # Ethereum development tools
│   ├── anvil-testnet/        # Local blockchain
│   ├── forge-compiler/       # Smart contract compilation
│   └── cast-utilities/       # Blockchain interaction
│
├── ai-enhanced-tools/         # AI-powered development
│   ├── foundry-copilot/      # AI assistant for contracts
│   ├── security-analyzer/    # Automated security scanning
│   └── gas-optimizer/        # Gas usage optimization
│
├── neural-interfaces/         # Cognitive cities integration
│   ├── transport-hub/        # WebSocket communication
│   ├── knowledge-sync/       # Cross-city knowledge sharing
│   └── collaboration-hub/    # Multi-agent development
│
└── production-systems/        # Deployment and monitoring
    ├── monitoring-dashboard/  # Real-time metrics
    ├── container-orchestration/ # Docker/K8s configs
    └── ci-cd-pipeline/       # Automated deployment
```

## 🧠 AI Copilot Features

The integrated AI copilot provides:

- **Smart Contract Analysis** - Security scanning and optimization
- **Code Generation** - Template-based contract creation
- **Gas Optimization** - AI-guided efficiency improvements
- **Test Generation** - Automated test case creation
- **Cross-City Learning** - Knowledge sharing between cities

### API Usage

```python
import requests

# Analyze a smart contract
response = requests.post("http://localhost:8080/copilot/analyze", json={
    "contract_code": "pragma solidity ^0.8.0; contract Example { ... }",
    "project_name": "my-project",
    "optimization_level": 2
})

analysis = response.json()
print(f"Security issues: {len(analysis['security_issues'])}")
print(f"Gas optimization potential: {analysis['gas_optimization']['optimization_potential']}")
```

## 🌐 Neural Transport Integration

Connect to other cognitive cities through neural transport protocols:

```typescript
import { FoundryNeuralTransport } from './neural-transport';

const transport = new FoundryNeuralTransport('cogcities-main', 4000);

// Share insights with other cities
await transport.shareFoundryInsight({
    type: 'optimization',
    contractType: 'ERC20',
    insight: { gasReduction: '15%', technique: 'struct-packing' },
    confidence: 0.92
}, ['cogpilot', 'cosmo']);
```

## 📊 Monitoring

Access the real-time monitoring dashboard at http://localhost:9090 to view:

- Infrastructure metrics (CPU, memory, network)
- Development activity (compilations, tests, deployments)
- AI assistance usage (copilot interactions, suggestions)
- Neural transport activity (connected cities, message flow)
- City integration status (collaboration efficiency, knowledge sync)

## 🐳 Container Configuration

### Multi-Stage Build

The Dockerfile uses a multi-stage build for optimization:

1. **Foundation** - Base Ubuntu with system dependencies
2. **Foundry Layer** - Ethereum Foundry toolchain installation
3. **Cognitive Runtime** - AI/ML libraries and Python dependencies
4. **Neural Transport** - WebSocket communication layer
5. **AI Tools** - Copilot and enhancement tools
6. **Foundry-Local** - Microsoft Foundry-Local integration
7. **Production** - Final optimized image

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `FOUNDRY_PROFILE` | `cognitive-city` | Foundry configuration profile |
| `CITY_ID` | `cogcities-main` | Cognitive city identifier |
| `NEURAL_TRANSPORT_ENABLED` | `true` | Enable neural transport protocols |
| `AI_COPILOT_ENABLED` | `true` | Enable AI copilot features |
| `RUST_LOG` | `info` | Rust logging level |

## 🚀 Deployment Options

### Local Development
```bash
./scripts/setup-dev-environment.sh
```

### Docker Compose
```bash
docker-compose up -d
```

### Kubernetes
```bash
kubectl apply -f k8s/production/deployment.yaml
```

### CI/CD Pipeline
GitHub Actions automatically:
- Builds and tests containers
- Deploys to staging environment
- Runs integration tests
- Promotes to production (manual approval)

## 🧪 Testing

Run the test suite:

```bash
# Container tests
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
./scripts/run-tests.sh

# AI copilot tests
cd ai-copilot
python -m pytest tests/

# Neural transport tests
cd neural-transport
npm test
```

## 📋 Configuration

### Foundry Configuration (`foundry-configs/foundry.toml`)

```toml
[profile.cognitive-city]
src = 'src'
out = 'out'
optimizer = true
optimizer_runs = 1000
via_ir = true  # AI-enhanced optimizations

[cognitive_cities]
ai_copilot_enabled = true
neural_transport_enabled = true
city_id = "cogcities-main"
district = "manufacturing"
```

### AI Copilot Configuration

Configure AI models and API keys in `.env`:

```bash
OPENAI_API_KEY=your_key_here
ANTHROPIC_API_KEY=your_key_here
AI_MODEL_CACHE_SIZE=2GB
```

## 🔒 Security

- Container security scanning with Trivy
- AI model sandboxing
- Network isolation between services
- Encrypted neural transport communication
- Smart contract security analysis

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Run tests: `./scripts/run-tests.sh`
4. Submit a pull request

## 📚 Documentation

- [Foundry Book](https://book.getfoundry.sh/) - Ethereum Foundry documentation
- [Cognitive Cities Architecture](../cognitive-architecture/) - Overall system design
- [Neural Transport Protocols](../cognitive-architecture/neural-transport-protocols.md) - Communication specs
- [AI Copilot API](./ai-copilot/README.md) - AI assistant documentation

## 📊 Success Metrics

### Target KPIs

- **Development Velocity**: Contract compilation < 5s, deployment < 10min
- **AI Effectiveness**: >95% security detection, >70% suggestion acceptance  
- **Neural Integration**: >50 insights/day, <100ms transport latency
- **Container Performance**: <30s startup, <4GB memory, <80% CPU
- **Developer Experience**: <5min setup, >4.5/5 satisfaction

## 🌟 Roadmap

- [ ] Advanced AI model fine-tuning for smart contracts
- [ ] Multi-chain support (Polygon, Arbitrum, Optimism)
- [ ] Enhanced visual development environment
- [ ] Automated security audit integration
- [ ] Cross-city collaboration workflows
- [ ] Real-time collaborative smart contract editing

## 📄 License

This project is licensed under the Microsoft Software License Terms. See the [LICENSE](../LICENSE) file for details.

---

**🌆 Foundry Hybrid Manufacturing District - Powering the cognitive cities AI development ecosystem**