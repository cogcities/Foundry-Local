import { CognitiveForge, CognitiveAgentType, MemoryType } from 'foundry-local-sdk'

/**
 * Example demonstrating basic cognitive forge functionality
 */
async function basicCognitiveForgeExample() {
  console.log('🧠 Starting Cognitive Forge Example...\n')
  
  // Create a cognitive forge instance
  const forge = new CognitiveForge({
    config: {
      maxConcurrentAgents: 3,
      enableCollaboration: true,
      debugMode: true
    }
  })

  try {
    // Initialize the forge
    console.log('📡 Initializing Cognitive Forge...')
    await forge.initialize()
    console.log('✅ Cognitive Forge initialized successfully\n')

    // Create a reasoning agent
    console.log('🤖 Creating reasoning agent...')
    const reasoningAgent = await forge.createAgent({
      name: 'Primary Reasoner',
      type: CognitiveAgentType.REASONING,
      modelAlias: 'phi-3.5-mini',
      config: {
        specialization: 'logical-reasoning',
        temperature: 0.7
      }
    })
    console.log(`✅ Created reasoning agent: ${reasoningAgent.name} (${reasoningAgent.id})\n`)

    // Create a memory agent
    console.log('🧮 Creating memory agent...')
    const memoryAgent = await forge.createAgent({
      name: 'Knowledge Keeper',
      type: CognitiveAgentType.MEMORY,
      modelAlias: 'phi-3.5-mini',
      config: {
        specialization: 'knowledge-management'
      }
    })
    console.log(`✅ Created memory agent: ${memoryAgent.name} (${memoryAgent.id})\n`)

    // Store some knowledge in different memory types
    console.log('💾 Storing knowledge in memory systems...')
    
    await forge.storeMemory({
      type: MemoryType.SEMANTIC,
      content: 'Paris is the capital and largest city of France',
      metadata: { domain: 'geography', confidence: 0.95 },
      importance: 0.9
    })

    await forge.storeMemory({
      type: MemoryType.SEMANTIC,
      content: 'France is a country in Western Europe',
      metadata: { domain: 'geography', confidence: 0.95 },
      importance: 0.8
    })

    await forge.storeMemory({
      type: MemoryType.PROCEDURAL,
      content: 'To find a capital city, look for the political and administrative center',
      metadata: { domain: 'geography', type: 'procedure' },
      importance: 0.7
    })

    console.log('✅ Knowledge stored in memory systems\n')

    // Perform reasoning with memory context
    console.log('🤔 Performing reasoning with memory context...')
    const reasoningResponse = await forge.reason(reasoningAgent.id, {
      problem: 'What is the capital of France and why is it significant?',
      context: { 
        domain: 'geography',
        requireEvidence: true,
        detailLevel: 'comprehensive'
      },
      evidence: ['official government sources', 'geographic databases'],
      strategy: 'deductive'
    })

    console.log('🎯 Reasoning Result:')
    console.log(`   Conclusion: ${reasoningResponse.conclusion}`)
    console.log(`   Confidence: ${(reasoningResponse.confidence * 100).toFixed(1)}%`)
    console.log(`   Reasoning Steps: ${reasoningResponse.reasoningSteps.length}`)
    reasoningResponse.reasoningSteps.forEach((step, index) => {
      console.log(`     ${index + 1}. ${step}`)
    })
    console.log()

    // Create and execute a cognitive workflow
    console.log('🔄 Creating cognitive workflow...')
    const workflow = await forge.createWorkflow({
      name: 'Geographic Research Workflow',
      description: 'Comprehensive geographic research and analysis',
      steps: [
        {
          name: 'Knowledge Retrieval',
          type: 'memory-retrieval',
          agentId: memoryAgent.id,
          input: {
            memoryType: MemoryType.SEMANTIC,
            query: 'France geography',
            limit: 5
          },
          dependencies: []
        },
        {
          name: 'Comprehensive Analysis',
          type: 'reasoning',
          agentId: reasoningAgent.id,
          input: {
            problem: 'Provide a comprehensive analysis of France based on available knowledge',
            context: { 
              analysisType: 'comprehensive',
              includeGeography: true,
              includePolitics: true
            },
            evidence: [],
            strategy: 'inductive'
          },
          dependencies: ['Knowledge Retrieval']
        }
      ],
      input: { 
        topic: 'France',
        analysisDepth: 'detailed'
      }
    })

    console.log(`✅ Created workflow: ${workflow.name} (${workflow.id})`)
    console.log(`   Steps: ${workflow.steps.length}`)
    
    console.log('\n⚙️ Executing workflow...')
    const executedWorkflow = await forge.executeWorkflow(workflow.id)
    
    console.log('✅ Workflow executed successfully!')
    console.log(`   Status: ${executedWorkflow.state}`)
    console.log(`   Completed Steps: ${executedWorkflow.steps.filter(s => s.state === 'completed').length}/${executedWorkflow.steps.length}`)
    
    // Display workflow results
    executedWorkflow.steps.forEach((step, index) => {
      console.log(`\n   Step ${index + 1}: ${step.name}`)
      console.log(`     Status: ${step.state}`)
      if (step.output && Object.keys(step.output).length > 0) {
        if (step.type === 'memory-retrieval' && step.output.memories) {
          console.log(`     Retrieved: ${step.output.memories.length} memories`)
        } else if (step.type === 'reasoning' && step.output.conclusion) {
          console.log(`     Conclusion: ${step.output.conclusion.substring(0, 100)}...`)
          console.log(`     Confidence: ${(step.output.confidence * 100).toFixed(1)}%`)
        }
      }
    })

    // Create cognitive synergy
    console.log('\n🤝 Creating cognitive synergy...')
    const synergy = await forge.createSynergy(
      [reasoningAgent.id, memoryAgent.id],
      'consensus',
      {
        votingThreshold: 0.8,
        maxIterations: 3,
        convergenceStrategy: 'weighted-average'
      }
    )

    console.log('✅ Cognitive synergy created successfully!')
    console.log(`   Collaboration Type: ${synergy.collaborationType}`)
    console.log(`   Participating Agents: ${synergy.agents.length}`)

    // Display statistics
    console.log('\n📊 Cognitive Forge Statistics:')
    const stats = forge.getStatistics()
    console.log(`   Active Agents: ${stats.agents}`)
    console.log(`   Total Memories: ${stats.memories}`)
    console.log(`   Workflows: ${stats.workflows}`)
    console.log(`   Synergies: ${stats.synergies}`)
    console.log('   Memory Distribution:')
    Object.entries(stats.memoryByType).forEach(([type, count]) => {
      console.log(`     ${type}: ${count}`)
    })

    // Clean up
    console.log('\n🧹 Cleaning up agents...')
    await forge.removeAgent(reasoningAgent.id)
    await forge.removeAgent(memoryAgent.id)
    console.log('✅ Cleanup completed')

  } catch (error) {
    console.error('❌ Error in cognitive forge example:', error)
  }
}

// Run the example
if (require.main === module) {
  basicCognitiveForgeExample()
    .then(() => {
      console.log('\n🎉 Cognitive Forge example completed successfully!')
    })
    .catch((error) => {
      console.error('\n💥 Example failed:', error)
      process.exit(1)
    })
}

export { basicCognitiveForgeExample }