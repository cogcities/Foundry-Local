#!/bin/bash
# 🧪 Foundry Hybrid Integration Tests
# Validates end-to-end functionality of the manufacturing district

set -e

echo "🧪 Running Foundry Hybrid Integration Tests"
echo "==========================================="

# Configuration
FOUNDRY_HYBRID_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$FOUNDRY_HYBRID_DIR"

TEST_RESULTS=()
FAILED_TESTS=0

# Helper functions
log_test() {
    echo "🔍 Testing: $1"
}

log_success() {
    echo "  ✅ $1"
    TEST_RESULTS+=("✅ $1")
}

log_failure() {
    echo "  ❌ $1"
    TEST_RESULTS+=("❌ $1")
    ((FAILED_TESTS++))
}

wait_for_service() {
    local service=$1
    local url=$2
    local timeout=${3:-60}
    local count=0
    
    while [ $count -lt $timeout ]; do
        if curl -sf "$url" >/dev/null 2>&1; then
            return 0
        fi
        sleep 1
        ((count++))
    done
    return 1
}

# Test 1: Configuration Validation
log_test "Configuration validation"
if docker compose config >/dev/null 2>&1; then
    log_success "Docker Compose configuration valid"
else
    log_failure "Docker Compose configuration invalid"
fi

if [ -f "Dockerfile" ] && [ -f "requirements.txt" ]; then
    log_success "Core container files present"
else
    log_failure "Missing core container files"
fi

# Test 2: Container Build
log_test "Container build process"
if docker compose build foundry-hybrid >/dev/null 2>&1; then
    log_success "Main container builds successfully"
else
    log_failure "Main container build failed"
fi

if docker compose build ai-copilot >/dev/null 2>&1; then
    log_success "AI copilot container builds successfully"
else
    log_failure "AI copilot container build failed"
fi

if docker compose build neural-transport-hub >/dev/null 2>&1; then
    log_success "Neural transport container builds successfully"
else
    log_failure "Neural transport container build failed"
fi

# Test 3: Service Startup
log_test "Service startup and health checks"
echo "  Starting services..."
docker compose up -d >/dev/null 2>&1

sleep 30  # Give services time to start

# Check individual services
if wait_for_service "foundry-hybrid" "http://localhost:8545" 60; then
    log_success "Foundry hybrid service started (Anvil RPC)"
else
    log_failure "Foundry hybrid service failed to start"
fi

if wait_for_service "ai-copilot" "http://localhost:6000/health" 30; then
    log_success "AI copilot service started"
else
    log_failure "AI copilot service failed to start"
fi

if wait_for_service "neural-transport" "http://localhost:4001/health" 30; then
    log_success "Neural transport service started"
else
    log_failure "Neural transport service failed to start"
fi

if wait_for_service "monitoring" "http://localhost:7000/health" 30; then
    log_success "Monitoring service started"
else
    log_failure "Monitoring service failed to start"
fi

# Test 4: API Functionality
log_test "API functionality"

# Test AI Copilot API
COPILOT_RESPONSE=$(curl -s -X POST "http://localhost:6000/copilot/analyze" \
    -H "Content-Type: application/json" \
    -d '{
        "contract_code": "pragma solidity ^0.8.0; contract Test { uint256 public value; }",
        "project_name": "test-project",
        "optimization_level": 1
    }' 2>/dev/null || echo "failed")

if [[ "$COPILOT_RESPONSE" == *"security_issues"* ]]; then
    log_success "AI copilot API responds correctly"
else
    log_failure "AI copilot API not responding correctly"
fi

# Test Neural Transport API
TRANSPORT_RESPONSE=$(curl -s "http://localhost:4001/health" 2>/dev/null || echo "failed")

if [[ "$TRANSPORT_RESPONSE" == *"healthy"* ]]; then
    log_success "Neural transport API responds correctly"
else
    log_failure "Neural transport API not responding correctly"
fi

# Test Monitoring API
MONITORING_RESPONSE=$(curl -s "http://localhost:7000/metrics" 2>/dev/null || echo "failed")

if [[ "$MONITORING_RESPONSE" == *"timestamp"* ]]; then
    log_success "Monitoring API responds correctly"
else
    log_failure "Monitoring API not responding correctly"
fi

# Test 5: Inter-service Communication
log_test "Inter-service communication"

# Test if AI copilot can communicate with other services
PROJECTS_RESPONSE=$(curl -s "http://localhost:6000/copilot/projects" 2>/dev/null || echo "failed")

if [[ "$PROJECTS_RESPONSE" == *"projects"* ]]; then
    log_success "AI copilot internal APIs working"
else
    log_failure "AI copilot internal APIs not working"
fi

# Test neural transport city connections
CITIES_RESPONSE=$(curl -s "http://localhost:4001/cities" 2>/dev/null || echo "failed")

if [[ "$CITIES_RESPONSE" == *"cities"* ]]; then
    log_success "Neural transport city management working"
else
    log_failure "Neural transport city management not working"
fi

# Test 6: Container Health
log_test "Container health and resource usage"

CONTAINER_STATUS=$(docker compose ps --format "table {{.Name}}\t{{.State}}" | grep -c "running" || echo "0")

if [ "$CONTAINER_STATUS" -ge 3 ]; then
    log_success "Multiple containers running ($CONTAINER_STATUS containers)"
else
    log_failure "Insufficient containers running ($CONTAINER_STATUS containers)"
fi

# Test 7: Configuration Files
log_test "Configuration file validation"

if [ -f "foundry-configs/foundry.toml" ]; then
    if grep -q "cognitive-city" "foundry-configs/foundry.toml"; then
        log_success "Foundry configuration contains cognitive city profile"
    else
        log_failure "Foundry configuration missing cognitive city profile"
    fi
else
    log_failure "Foundry configuration file missing"
fi

# Test 8: Kubernetes Manifests
log_test "Kubernetes manifest validation"

if command -v kubectl >/dev/null 2>&1; then
    if kubectl apply --dry-run=client -f k8s/production/ >/dev/null 2>&1; then
        log_success "Production Kubernetes manifests valid"
    else
        log_failure "Production Kubernetes manifests invalid"
    fi
    
    if kubectl apply --dry-run=client -f k8s/staging/ >/dev/null 2>&1; then
        log_success "Staging Kubernetes manifests valid"
    else
        log_failure "Staging Kubernetes manifests invalid"
    fi
else
    echo "  ⚠️ kubectl not available, skipping Kubernetes validation"
fi

# Test 9: GitHub Actions Workflow
log_test "GitHub Actions workflow validation"

if [ -f "../.github/workflows/foundry-hybrid-deploy.yml" ]; then
    if grep -q "foundry-hybrid" "../.github/workflows/foundry-hybrid-deploy.yml"; then
        log_success "GitHub Actions workflow configured"
    else
        log_failure "GitHub Actions workflow misconfigured"
    fi
else
    log_failure "GitHub Actions workflow file missing"
fi

# Test 10: Development Environment
log_test "Development environment setup"

if [ -f "scripts/setup-dev-environment.sh" ] && [ -x "scripts/setup-dev-environment.sh" ]; then
    log_success "Development setup script available and executable"
else
    log_failure "Development setup script missing or not executable"
fi

if [ -f "scripts/start-foundry-hybrid.sh" ] && [ -x "scripts/start-foundry-hybrid.sh" ]; then
    log_success "Startup script available and executable"
else
    log_failure "Startup script missing or not executable"
fi

# Cleanup
echo ""
echo "🧹 Cleaning up test environment..."
docker compose down >/dev/null 2>&1

# Test Results Summary
echo ""
echo "📊 Test Results Summary"
echo "======================"
echo ""

for result in "${TEST_RESULTS[@]}"; do
    echo "$result"
done

echo ""
if [ $FAILED_TESTS -eq 0 ]; then
    echo "🎉 All tests passed! Foundry Hybrid Manufacturing District is ready."
    echo ""
    echo "🚀 Next steps:"
    echo "  1. Deploy to staging: kubectl apply -f k8s/staging/"
    echo "  2. Run development environment: ./scripts/setup-dev-environment.sh"
    echo "  3. Access services at configured ports"
    echo "  4. Monitor via dashboard at http://localhost:9090"
    echo ""
    echo "🌆 Foundry manufacturing district validated for cognitive city deployment!"
    exit 0
else
    echo "❌ $FAILED_TESTS test(s) failed. Please review the issues above."
    echo ""
    echo "🔧 Common fixes:"
    echo "  • Ensure Docker and Docker Compose are installed"
    echo "  • Check that ports 3000, 4000, 4001, 5000, 6000, 7000, 8080, 8545, 9090 are available"
    echo "  • Verify all dependencies are installed (Node.js, Python)"
    echo "  • Check Docker daemon is running"
    exit 1
fi