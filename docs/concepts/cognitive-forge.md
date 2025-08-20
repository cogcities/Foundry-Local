# Cognitive Forge

The Cognitive Forge is an advanced cognitive architecture built on top of Foundry Local that enables multi-agent AI coordination, memory management, and sophisticated reasoning workflows.

## Features

### Multi-Agent Coordination
- Create and manage multiple cognitive agents with different specializations
- Coordinate agents for collaborative problem-solving
- Support for different cognitive agent types: reasoning, memory, planning, execution, monitoring, and collaboration

### Memory Systems
- **Working Memory**: Short-term storage for active cognitive processes
- **Episodic Memory**: Memory of specific events and experiences
- **Semantic Memory**: Factual knowledge and concepts
- **Procedural Memory**: Skills and procedures

### Cognitive Workflows
- Define complex multi-step cognitive processes
- Support for dependencies between workflow steps
- Automatic orchestration and execution of cognitive tasks

### Cognitive Synergy
- Enable collaboration between multiple agents
- Support for different collaboration types: consensus, debate, delegation, parallel, and sequential
- Shared context and coordination strategies

## Quick Start

```typescript
import { CognitiveForge, CognitiveAgentType, MemoryType } from 'foundry-local-sdk'

// Create a cognitive forge instance
const forge = new CognitiveForge({
  config: {
    maxConcurrentAgents: 5,
    enableCollaboration: true,
    debugMode: true
  }
})

// Initialize the forge
await forge.initialize()

// Create a reasoning agent
const reasoningAgent = await forge.createAgent({
  name: 'Primary Reasoner',
  type: CognitiveAgentType.REASONING,
  modelAlias: 'phi-3.5-mini'
})

// Store some knowledge in semantic memory
await forge.storeMemory({
  type: MemoryType.SEMANTIC,
  content: 'The capital of France is Paris',
  importance: 0.8
})

// Perform reasoning
const response = await forge.reason(reasoningAgent.id, {
  problem: 'What is the capital of France?',
  context: { domain: 'geography' },
  evidence: [],
  strategy: 'deductive'
})

console.log(response.conclusion) // Should reference Paris based on stored memory
```

## Agent Types

### Reasoning Agent
Specialized for logical reasoning and problem-solving:
- Deductive reasoning
- Inductive reasoning  
- Abductive reasoning
- Analogical reasoning
- Causal reasoning

### Memory Agent
Focused on memory storage and retrieval:
- Context-aware memory storage
- Intelligent memory search and ranking
- Memory consolidation and cleanup

### Planning Agent
Designed for strategic planning and goal decomposition:
- Goal hierarchization
- Task planning and sequencing
- Resource allocation planning

### Execution Agent
Specialized for action execution and monitoring:
- Task execution coordination
- Progress monitoring
- Error detection and recovery

### Monitoring Agent
Focused on system observation and analysis:
- Performance monitoring
- Quality assessment
- Anomaly detection

### Collaboration Agent
Facilitates multi-agent coordination:
- Agent communication
- Consensus building
- Conflict resolution

## Memory Management

The cognitive forge provides sophisticated memory management with automatic ranking, cleanup, and retrieval:

```typescript
// Store different types of memories
await forge.storeMemory({
  type: MemoryType.EPISODIC,
  content: 'User asked about weather at 2:30 PM',
  metadata: { timestamp: new Date(), userId: 'user123' },
  importance: 0.6
})

await forge.storeMemory({
  type: MemoryType.SEMANTIC,
  content: 'Weather can be predicted using atmospheric pressure',
  importance: 0.9
})

// Retrieve memories with ranking
const semanticMemories = await forge.retrieveMemory(
  MemoryType.SEMANTIC, 
  'weather prediction', 
  5
)
```

## Cognitive Workflows

Create complex multi-step cognitive processes:

```typescript
const workflow = await forge.createWorkflow({
  name: 'Research and Analysis',
  description: 'Comprehensive research workflow',
  steps: [
    {
      name: 'Information Gathering',
      type: 'memory-retrieval',
      agentId: memoryAgent.id,
      input: { 
        memoryType: MemoryType.SEMANTIC,
        query: 'research topic',
        limit: 10 
      },
      dependencies: []
    },
    {
      name: 'Analysis',
      type: 'reasoning', 
      agentId: reasoningAgent.id,
      input: {
        problem: 'Analyze gathered information',
        strategy: 'inductive'
      },
      dependencies: ['Information Gathering']
    }
  ]
})

const result = await forge.executeWorkflow(workflow.id)
```

## Cognitive Synergy

Enable collaboration between multiple agents:

```typescript
// Create multiple specialized agents
const reasoner = await forge.createAgent({
  name: 'Logical Reasoner',
  type: CognitiveAgentType.REASONING,
  modelAlias: 'phi-3.5-mini'
})

const memory = await forge.createAgent({
  name: 'Knowledge Base',
  type: CognitiveAgentType.MEMORY, 
  modelAlias: 'phi-3.5-mini'
})

// Create a synergy for collaborative problem-solving
const synergy = await forge.createSynergy(
  [reasoner.id, memory.id],
  'consensus',
  { votingThreshold: 0.8 }
)
```

## Configuration Options

```typescript
interface CognitiveForgeConfig {
  maxConcurrentAgents?: number     // Default: 10
  memoryRetentionDays?: number     // Default: 30
  maxMemoryEntries?: number        // Default: 10000
  enableCollaboration?: boolean    // Default: true
  workflowTimeout?: number         // Default: 300000 (5 minutes)
  debugMode?: boolean             // Default: false
}
```

## Architecture

The Cognitive Forge is built on top of the existing Foundry Local infrastructure and provides:

1. **Agent Management Layer**: Handles creation, lifecycle, and coordination of cognitive agents
2. **Memory System**: Sophisticated storage and retrieval with importance-based ranking
3. **Reasoning Engine**: Advanced reasoning capabilities with multiple strategies  
4. **Workflow Orchestrator**: Manages complex multi-step cognitive processes
5. **Synergy Coordinator**: Enables agent collaboration and consensus building

## Integration with Foundry Local

The Cognitive Forge seamlessly integrates with the existing Foundry Local ecosystem:

- Uses the same model management and caching infrastructure
- Compatible with all supported hardware acceleration (CPU, GPU, NPU)
- Leverages the OpenAI-compatible API for model interaction
- Maintains the same security and privacy guarantees

## Examples

See the `examples/cognitive-forge/` directory for complete examples including:

- Multi-agent research assistant
- Collaborative problem solving
- Memory-augmented reasoning
- Workflow automation
- Cognitive agent specialization

## API Reference

For detailed API documentation, see the TypeScript definitions in `cognitive-types.ts` and the implementation in `cognitive-forge.ts`.