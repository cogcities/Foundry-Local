# Cognitive Forge Examples

This directory contains examples demonstrating the Cognitive Forge functionality built on top of Foundry Local.

## Prerequisites

Before running these examples, ensure you have:

1. Foundry Local installed and accessible via CLI
2. Node.js and npm installed
3. The foundry-local-sdk package installed

```bash
npm install foundry-local-sdk
```

## Examples

### Basic Example (`basic-example.ts`)

Demonstrates the core functionality of the Cognitive Forge:

- Creating cognitive agents with different specializations
- Memory management across different memory types
- Reasoning with memory context
- Cognitive workflows
- Agent collaboration through synergies

**Features Demonstrated:**
- Agent creation and management
- Memory storage and retrieval
- Context-aware reasoning
- Multi-step workflows
- Cognitive synergy setup
- Statistics and monitoring

**To run:**
```bash
npx ts-node basic-example.ts
```

### Expected Output

The basic example will show:

1. **Initialization**: Setting up the Cognitive Forge
2. **Agent Creation**: Creating reasoning and memory agents
3. **Memory Storage**: Storing knowledge in different memory types
4. **Reasoning**: Performing context-aware reasoning
5. **Workflow Execution**: Running a multi-step cognitive workflow
6. **Synergy Creation**: Setting up agent collaboration
7. **Statistics**: Displaying forge statistics
8. **Cleanup**: Removing agents and cleaning up resources

## Memory Types Used

- **Semantic Memory**: Factual knowledge (e.g., "Paris is the capital of France")
- **Procedural Memory**: Process knowledge (e.g., "How to find a capital city")
- **Episodic Memory**: Event-based memories (automatically created during reasoning)

## Agent Types Demonstrated

- **Reasoning Agent**: Specialized for logical reasoning and problem-solving
- **Memory Agent**: Focused on knowledge storage and retrieval

## Workflow Steps

The example demonstrates these workflow step types:

- **memory-retrieval**: Retrieving relevant memories
- **reasoning**: Performing cognitive reasoning
- **memory-storage**: Storing new memories

## Synergy Types

- **Consensus**: Agents work together to reach agreement
- **Coordination**: Structured collaboration strategies

## Troubleshooting

### Common Issues

1. **"Foundry is not installed or not on PATH"**
   - Ensure Foundry Local is properly installed
   - Verify `foundry` command is accessible in your terminal

2. **Model download failures**
   - Check internet connectivity
   - Verify the model alias exists in the catalog
   - Try a different model if needed

3. **Memory errors**
   - Reduce the number of concurrent agents
   - Adjust memory retention settings
   - Monitor system resources

### Debug Mode

Enable debug mode for detailed logging:

```typescript
const forge = new CognitiveForge({
  config: {
    debugMode: true
  }
})
```

## Advanced Usage

For more advanced scenarios, consider:

- Creating specialized agent configurations
- Implementing custom workflow steps
- Using different collaboration strategies
- Integrating with external data sources
- Building domain-specific cognitive architectures

## Configuration Options

The Cognitive Forge supports extensive configuration:

```typescript
const config = {
  maxConcurrentAgents: 10,      // Maximum concurrent agents
  memoryRetentionDays: 30,      // Memory retention period
  maxMemoryEntries: 10000,      // Maximum memory entries
  enableCollaboration: true,     // Enable agent collaboration
  workflowTimeout: 300000,      // Workflow timeout (5 minutes)
  debugMode: false              // Debug logging
}
```

## Performance Considerations

- **Agent Limits**: Monitor the number of concurrent agents
- **Memory Management**: Tune memory retention and cleanup policies
- **Model Selection**: Choose appropriate models for agent specializations
- **Hardware**: Leverage GPU/NPU acceleration when available

## Next Steps

After running the basic example, explore:

1. Creating domain-specific cognitive architectures
2. Implementing custom agent behaviors
3. Building complex multi-agent workflows
4. Integrating with external APIs and data sources
5. Developing cognitive applications for specific use cases