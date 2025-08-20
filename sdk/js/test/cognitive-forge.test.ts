// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

import { beforeEach, describe, expect, it, vi } from 'vitest'
import { CognitiveForge } from '../src/cognitive-forge.js'
import { CognitiveAgentType, MemoryType, WorkflowState } from '../src/cognitive-types.js'

// Mock the fetch function
const mockFetch = vi.fn()

// Mock the global fetch
global.fetch = mockFetch

// Mock the Foundry service responses
const mockModelInfo = {
  id: 'test-model-id',
  alias: 'test-model',
  version: '1.0.0',
  runtime: 'CPUExecutionProvider',
  uri: 'test://model',
  modelSize: 100,
  promptTemplate: {},
  provider: 'test',
  publisher: 'test',
  license: 'MIT',
  task: 'text-generation'
}

describe('CognitiveForge', () => {
  let cognitiveForge: CognitiveForge
  let mockFoundryManager: any

  beforeEach(() => {
    vi.clearAllMocks()
    
    // Create mock FoundryLocalManager
    mockFoundryManager = {
      startService: vi.fn().mockResolvedValue(),
      downloadModel: vi.fn().mockResolvedValue(),
      loadModel: vi.fn().mockResolvedValue(mockModelInfo),
      unloadModel: vi.fn().mockResolvedValue(),
      get serviceUrl() { return 'http://localhost:8080' },
      get endpoint() { return 'http://localhost:8080/v1' },
      get apiKey() { return 'test-key' }
    }
    
    // Mock foundry service responses
    mockFetch.mockImplementation((url: string, options?: any) => {
      if (url.includes('/chat/completions')) {
        return Promise.resolve({
          json: () => Promise.resolve({
            choices: [{
              message: {
                content: JSON.stringify({
                  conclusion: "Test reasoning conclusion",
                  confidence: 0.85,
                  reasoningSteps: ["Step 1", "Step 2"],
                  supportingEvidence: ["Evidence 1"],
                  alternatives: []
                })
              }
            }]
          })
        })
      }
      
      return Promise.resolve({
        json: () => Promise.resolve([]),
        ok: true
      })
    })

    cognitiveForge = new CognitiveForge({
      foundryManager: mockFoundryManager,
      config: {
        debugMode: true,
        maxConcurrentAgents: 5
      }
    })
  })

  describe('initialization', () => {
    it('should initialize correctly', async () => {
      await cognitiveForge.initialize()
      expect(mockFoundryManager.startService).toHaveBeenCalled()
    })

    it('should use default configuration', () => {
      const stats = cognitiveForge.getStatistics()
      expect(stats.agents).toBe(0)
      expect(stats.memories).toBe(0)
      expect(stats.workflows).toBe(0)
      expect(stats.synergies).toBe(0)
    })
  })

  describe('agent management', () => {
    beforeEach(async () => {
      await cognitiveForge.initialize()
    })

    it('should create a cognitive agent', async () => {
      const agent = await cognitiveForge.createAgent({
        name: 'Test Agent',
        type: CognitiveAgentType.REASONING,
        modelAlias: 'test-model'
      })

      expect(agent.name).toBe('Test Agent')
      expect(agent.type).toBe(CognitiveAgentType.REASONING)
      expect(agent.state).toBe('idle')
      expect(agent.model).toEqual(mockModelInfo)
      expect(mockFoundryManager.downloadModel).toHaveBeenCalledWith('test-model')
      expect(mockFoundryManager.loadModel).toHaveBeenCalledWith('test-model')
    })

    it('should list agents', async () => {
      await cognitiveForge.createAgent({
        name: 'Agent 1',
        type: CognitiveAgentType.REASONING,
        modelAlias: 'test-model'
      })

      await cognitiveForge.createAgent({
        name: 'Agent 2',
        type: CognitiveAgentType.MEMORY,
        modelAlias: 'test-model'
      })

      const agents = cognitiveForge.listAgents()
      expect(agents).toHaveLength(2)
      expect(agents[0].name).toBe('Agent 1')
      expect(agents[1].name).toBe('Agent 2')
    })

    it('should get agent by ID', async () => {
      const createdAgent = await cognitiveForge.createAgent({
        name: 'Test Agent',
        type: CognitiveAgentType.REASONING,
        modelAlias: 'test-model'
      })

      const foundAgent = cognitiveForge.getAgent(createdAgent.id)
      expect(foundAgent).toEqual(createdAgent)
    })

    it('should remove an agent', async () => {
      const agent = await cognitiveForge.createAgent({
        name: 'Test Agent',
        type: CognitiveAgentType.REASONING,
        modelAlias: 'test-model'
      })

      await cognitiveForge.removeAgent(agent.id)
      
      const foundAgent = cognitiveForge.getAgent(agent.id)
      expect(foundAgent).toBeUndefined()
      expect(mockFoundryManager.unloadModel).toHaveBeenCalledWith(mockModelInfo.id)
    })

    it('should enforce maximum concurrent agents', async () => {
      // Create maximum number of agents
      for (let i = 0; i < 5; i++) {
        await cognitiveForge.createAgent({
          name: `Agent ${i}`,
          type: CognitiveAgentType.REASONING,
          modelAlias: 'test-model'
        })
      }

      // Try to create one more
      await expect(cognitiveForge.createAgent({
        name: 'Extra Agent',
        type: CognitiveAgentType.REASONING,
        modelAlias: 'test-model'
      })).rejects.toThrow('Maximum number of concurrent agents')
    })
  })

  describe('memory management', () => {
    beforeEach(async () => {
      await cognitiveForge.initialize()
    })

    it('should store memory', async () => {
      const memory = await cognitiveForge.storeMemory({
        type: MemoryType.SEMANTIC,
        content: 'Test memory content',
        metadata: { source: 'test' },
        importance: 0.8
      })

      expect(memory.type).toBe(MemoryType.SEMANTIC)
      expect(memory.content).toBe('Test memory content')
      expect(memory.importance).toBe(0.8)
      expect(memory.metadata.source).toBe('test')
      expect(memory.accessCount).toBe(0)
    })

    it('should retrieve memories by type', async () => {
      await cognitiveForge.storeMemory({
        type: MemoryType.SEMANTIC,
        content: 'Semantic memory 1',
        importance: 0.9
      })

      await cognitiveForge.storeMemory({
        type: MemoryType.EPISODIC,
        content: 'Episodic memory 1',
        importance: 0.7
      })

      await cognitiveForge.storeMemory({
        type: MemoryType.SEMANTIC,
        content: 'Semantic memory 2',
        importance: 0.6
      })

      const semanticMemories = await cognitiveForge.retrieveMemory(MemoryType.SEMANTIC)
      expect(semanticMemories).toHaveLength(2)
      // Memory with higher importance (0.9) should come first
      const highImportanceMemory = semanticMemories.find(m => m.importance === 0.9)
      const lowImportanceMemory = semanticMemories.find(m => m.importance === 0.6)
      expect(highImportanceMemory).toBeDefined()
      expect(lowImportanceMemory).toBeDefined()
      expect(semanticMemories[0]).toBe(highImportanceMemory) // Higher importance first

      const episodicMemories = await cognitiveForge.retrieveMemory(MemoryType.EPISODIC)
      expect(episodicMemories).toHaveLength(1)
      expect(episodicMemories[0].content).toBe('Episodic memory 1')
    })

    it('should filter memories by query', async () => {
      await cognitiveForge.storeMemory({
        type: MemoryType.SEMANTIC,
        content: 'Information about cats',
        importance: 0.8
      })

      await cognitiveForge.storeMemory({
        type: MemoryType.SEMANTIC,
        content: 'Information about dogs',
        importance: 0.7
      })

      const catMemories = await cognitiveForge.retrieveMemory(MemoryType.SEMANTIC, 'cats')
      expect(catMemories).toHaveLength(1)
      expect(catMemories[0].content).toBe('Information about cats')

      const dogMemories = await cognitiveForge.retrieveMemory(MemoryType.SEMANTIC, 'dogs')
      expect(dogMemories).toHaveLength(1)
      expect(dogMemories[0].content).toBe('Information about dogs')
    })

    it('should update access count when retrieving memories', async () => {
      const storedMemory = await cognitiveForge.storeMemory({
        type: MemoryType.SEMANTIC,
        content: 'Test memory',
        importance: 0.8
      })

      expect(storedMemory.accessCount).toBe(0)

      const retrievedMemories = await cognitiveForge.retrieveMemory(MemoryType.SEMANTIC)
      expect(retrievedMemories[0].accessCount).toBe(1)
    })
  })

  describe('reasoning', () => {
    let agent: any

    beforeEach(async () => {
      await cognitiveForge.initialize()
      agent = await cognitiveForge.createAgent({
        name: 'Reasoning Agent',
        type: CognitiveAgentType.REASONING,
        modelAlias: 'test-model'
      })
    })

    it('should perform reasoning', async () => {
      const response = await cognitiveForge.reason(agent.id, {
        problem: 'What is 2 + 2?',
        context: { domain: 'mathematics' },
        evidence: ['2', '2', '+'],
        strategy: 'deductive'
      })

      expect(response.conclusion).toBe('Test reasoning conclusion')
      expect(response.confidence).toBe(0.85)
      expect(response.reasoningSteps).toEqual(['Step 1', 'Step 2'])
      expect(response.supportingEvidence).toEqual(['Evidence 1'])

      // Check that memory was stored
      const memories = await cognitiveForge.retrieveMemory(MemoryType.EPISODIC)
      expect(memories).toHaveLength(1)
      expect(memories[0].content).toContain('What is 2 + 2?')
    })

    it('should throw error for non-existent agent', async () => {
      await expect(cognitiveForge.reason('non-existent', {
        problem: 'test',
        context: {},
        evidence: [],
        strategy: 'deductive'
      })).rejects.toThrow('Agent non-existent not found')
    })

    it('should throw error when agent is busy', async () => {
      // Manually set agent state to busy
      const foundAgent = cognitiveForge.getAgent(agent.id)!
      foundAgent.state = 'busy'

      await expect(cognitiveForge.reason(agent.id, {
        problem: 'test',
        context: {},
        evidence: [],
        strategy: 'deductive'
      })).rejects.toThrow('is not available')
    })
  })

  describe('workflows', () => {
    beforeEach(async () => {
      await cognitiveForge.initialize()
    })

    it('should create a workflow', async () => {
      const workflow = await cognitiveForge.createWorkflow({
        name: 'Test Workflow',
        description: 'A test workflow',
        steps: [
          {
            name: 'Step 1',
            type: 'reasoning',
            agentId: 'agent-1',
            input: { problem: 'test problem' },
            dependencies: []
          }
        ],
        input: { data: 'test' }
      })

      expect(workflow.name).toBe('Test Workflow')
      expect(workflow.description).toBe('A test workflow')
      expect(workflow.state).toBe(WorkflowState.PENDING)
      expect(workflow.steps).toHaveLength(1)
      expect(workflow.input.data).toBe('test')
    })

    it('should execute a simple workflow', async () => {
      const agent = await cognitiveForge.createAgent({
        name: 'Workflow Agent',
        type: CognitiveAgentType.REASONING,
        modelAlias: 'test-model'
      })

      const workflow = await cognitiveForge.createWorkflow({
        name: 'Simple Workflow',
        description: 'A simple workflow',
        steps: [
          {
            name: 'Reasoning Step',
            type: 'reasoning',
            agentId: agent.id,
            input: {
              problem: 'What is the capital of France?',
              context: {},
              evidence: [],
              strategy: 'deductive'
            },
            dependencies: []
          }
        ]
      })

      const executedWorkflow = await cognitiveForge.executeWorkflow(workflow.id)
      expect(executedWorkflow.state).toBe(WorkflowState.COMPLETED)
      expect(executedWorkflow.steps[0].state).toBe(WorkflowState.COMPLETED)
      expect(executedWorkflow.steps[0].output.conclusion).toBe('Test reasoning conclusion')
    })
  })

  describe('synergies', () => {
    beforeEach(async () => {
      await cognitiveForge.initialize()
    })

    it('should create a cognitive synergy', async () => {
      const agent1 = await cognitiveForge.createAgent({
        name: 'Agent 1',
        type: CognitiveAgentType.REASONING,
        modelAlias: 'test-model'
      })

      const agent2 = await cognitiveForge.createAgent({
        name: 'Agent 2',
        type: CognitiveAgentType.MEMORY,
        modelAlias: 'test-model'
      })

      const synergy = await cognitiveForge.createSynergy(
        [agent1.id, agent2.id],
        'consensus',
        { votingThreshold: 0.8 }
      )

      expect(synergy.agents).toEqual([agent1.id, agent2.id])
      expect(synergy.collaborationType).toBe('consensus')
      expect(synergy.coordinationStrategy.votingThreshold).toBe(0.8)
    })

    it('should throw error for non-existent agents in synergy', async () => {
      await expect(cognitiveForge.createSynergy(
        ['non-existent-1', 'non-existent-2'],
        'consensus'
      )).rejects.toThrow('Agent non-existent-1 not found')
    })
  })

  describe('statistics', () => {
    beforeEach(async () => {
      await cognitiveForge.initialize()
    })

    it('should provide accurate statistics', async () => {
      await cognitiveForge.createAgent({
        name: 'Agent 1',
        type: CognitiveAgentType.REASONING,
        modelAlias: 'test-model'
      })

      await cognitiveForge.storeMemory({
        type: MemoryType.SEMANTIC,
        content: 'Semantic memory'
      })

      await cognitiveForge.storeMemory({
        type: MemoryType.EPISODIC,
        content: 'Episodic memory'
      })

      await cognitiveForge.createWorkflow({
        name: 'Test Workflow',
        description: 'Test',
        steps: []
      })

      const stats = cognitiveForge.getStatistics()
      expect(stats.agents).toBe(1)
      expect(stats.memories).toBe(2)
      expect(stats.workflows).toBe(1)
      expect(stats.memoryByType[MemoryType.SEMANTIC]).toBe(1)
      expect(stats.memoryByType[MemoryType.EPISODIC]).toBe(1)
    })
  })
})