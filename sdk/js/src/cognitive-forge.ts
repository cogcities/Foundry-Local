// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

import { FoundryLocalManager } from './index.js'
import type { Fetch } from './types.js'
import {
  CognitiveAgentType,
  MemoryType,
  WorkflowState
} from './cognitive-types.js'
import type {
  CognitiveAgent,
  CognitiveForgeConfig,
  CognitiveWorkflow,
  CognitiveSynergy,
  MemoryEntry,
  ReasoningRequest,
  ReasoningResponse,
  WorkflowStep,
  WorkflowStepInput
} from './cognitive-types.js'

/**
 * Class representing the Cognitive Forge - an advanced cognitive architecture
 * built on top of Foundry Local for multi-agent AI coordination and reasoning.
 */
export class CognitiveForge {
  /**
   * The underlying Foundry Local Manager.
   */
  private foundryManager: FoundryLocalManager

  /**
   * Configuration for the cognitive forge.
   */
  private config: CognitiveForgeConfig

  /**
   * Active cognitive agents.
   */
  private agents: Map<string, CognitiveAgent> = new Map()

  /**
   * Memory system storage.
   */
  private memory: Map<string, MemoryEntry> = new Map()

  /**
   * Active workflows.
   */
  private workflows: Map<string, CognitiveWorkflow> = new Map()

  /**
   * Active cognitive synergies.
   */
  private synergies: Map<string, CognitiveSynergy> = new Map()

  /**
   * Constructs a new CognitiveForge instance.
   * @param {Object} [options] - Configuration options for the CognitiveForge.
   * @param {FoundryLocalManager} [options.foundryManager] - Pre-configured FoundryLocalManager instance.
   * @param {Fetch} [options.fetch] - Optional custom fetch implementation.
   * @param {CognitiveForgeConfig} [options.config] - Cognitive forge configuration.
   */
  constructor({ 
    foundryManager,
    fetch = globalThis.fetch, 
    config = {} 
  }: { 
    foundryManager?: FoundryLocalManager
    fetch?: Fetch
    config?: CognitiveForgeConfig 
  } = {}) {
    this.foundryManager = foundryManager || new FoundryLocalManager({ fetch })
    this.config = {
      maxConcurrentAgents: 10,
      memoryRetentionDays: 30,
      maxMemoryEntries: 10000,
      enableCollaboration: true,
      workflowTimeout: 300000, // 5 minutes
      debugMode: false,
      ...config
    }
  }

  /**
   * Initializes the cognitive forge.
   * @returns {Promise<void>} Resolves when initialization is complete.
   */
  async initialize(): Promise<void> {
    await this.foundryManager.startService()
    
    if (this.config.debugMode) {
      console.log('CognitiveForge initialized with config:', this.config)
    }
  }

  /**
   * Creates a new cognitive agent.
   * @param {Object} agentConfig - Configuration for the agent.
   * @param {string} agentConfig.name - Name of the agent.
   * @param {CognitiveAgentType} agentConfig.type - Type of cognitive agent.
   * @param {string} agentConfig.modelAlias - Model alias or ID to use for the agent.
   * @param {Record<string, any>} [agentConfig.config] - Agent-specific configuration.
   * @returns {Promise<CognitiveAgent>} The created cognitive agent.
   */
  async createAgent({
    name,
    type,
    modelAlias,
    config = {}
  }: {
    name: string
    type: CognitiveAgentType
    modelAlias: string
    config?: Record<string, unknown>
  }): Promise<CognitiveAgent> {
    if (this.agents.size >= this.config.maxConcurrentAgents!) {
      throw new Error(`Maximum number of concurrent agents (${this.config.maxConcurrentAgents}) reached`)
    }

    // Download and load the model for this agent
    await this.foundryManager.downloadModel(modelAlias)
    const modelInfo = await this.foundryManager.loadModel(modelAlias)

    const agentId = `agent-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
    const agent: CognitiveAgent = {
      id: agentId,
      name,
      type,
      model: modelInfo,
      config,
      state: 'idle',
      createdAt: new Date(),
      updatedAt: new Date()
    }

    this.agents.set(agentId, agent)

    if (this.config.debugMode) {
      console.log(`Created cognitive agent: ${name} (${agentId})`)
    }

    return agent
  }

  /**
   * Gets an agent by ID.
   * @param {string} agentId - The agent ID.
   * @returns {CognitiveAgent | undefined} The agent if found.
   */
  getAgent(agentId: string): CognitiveAgent | undefined {
    return this.agents.get(agentId)
  }

  /**
   * Lists all active agents.
   * @returns {CognitiveAgent[]} Array of all active agents.
   */
  listAgents(): CognitiveAgent[] {
    return Array.from(this.agents.values())
  }

  /**
   * Removes an agent.
   * @param {string} agentId - The agent ID to remove.
   * @returns {Promise<void>} Resolves when agent is removed.
   */
  async removeAgent(agentId: string): Promise<void> {
    const agent = this.agents.get(agentId)
    if (!agent) {
      throw new Error(`Agent ${agentId} not found`)
    }

    // Unload the model
    try {
      await this.foundryManager.unloadModel(agent.model.id)
    } catch (error) {
      if (this.config.debugMode) {
        console.warn(`Could not unload model for agent ${agentId}:`, error)
      }
    }

    this.agents.delete(agentId)

    if (this.config.debugMode) {
      console.log(`Removed agent: ${agentId}`)
    }
  }

  /**
   * Stores a memory entry.
   * @param {Object} memoryData - Memory data to store.
   * @param {MemoryType} memoryData.type - Type of memory.
   * @param {string} memoryData.content - Content of the memory.
   * @param {Record<string, any>} [memoryData.metadata] - Additional metadata.
   * @param {number} [memoryData.importance] - Importance score (0-1).
   * @returns {Promise<MemoryEntry>} The stored memory entry.
   */
  async storeMemory({
    type,
    content,
    metadata = {},
    importance = 0.5
  }: {
    type: MemoryType
    content: string
    metadata?: Record<string, unknown>
    importance?: number
  }): Promise<MemoryEntry> {
    const memoryId = `memory-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
    const memory: MemoryEntry = {
      id: memoryId,
      type,
      content,
      metadata,
      timestamp: new Date(),
      importance,
      accessCount: 0,
      lastAccessed: new Date()
    }

    this.memory.set(memoryId, memory)

    // Cleanup old memories if needed
    await this.cleanupMemory()

    if (this.config.debugMode) {
      console.log(`Stored memory: ${memoryId} (${type})`)
    }

    return memory
  }

  /**
   * Retrieves memories by type and optional query.
   * @param {MemoryType} type - Type of memory to retrieve.
   * @param {string} [query] - Optional query to filter memories.
   * @param {number} [limit] - Maximum number of memories to return.
   * @returns {Promise<MemoryEntry[]>} Array of matching memory entries.
   */
  async retrieveMemory(type: MemoryType, query?: string, limit: number = 10): Promise<MemoryEntry[]> {
    const memories = Array.from(this.memory.values())
      .filter(memory => memory.type === type)
      .filter(memory => !query || memory.content.toLowerCase().includes(query.toLowerCase()))
      .sort((a, b) => {
        // Sort by importance and recency
        const importanceScore = b.importance - a.importance
        const recencyScore = b.timestamp.getTime() - a.timestamp.getTime()
        return importanceScore * 0.7 + recencyScore * 0.3
      })
      .slice(0, limit)

    // Update access count and timestamp
    memories.forEach(memory => {
      memory.accessCount++
      memory.lastAccessed = new Date()
    })

    return memories
  }

  /**
   * Creates a cognitive reasoning request.
   * @param {string} agentId - Agent to perform the reasoning.
   * @param {ReasoningRequest} request - The reasoning request.
   * @returns {Promise<ReasoningResponse>} The reasoning response.
   */
  async reason(agentId: string, request: ReasoningRequest): Promise<ReasoningResponse> {
    const agent = this.agents.get(agentId)
    if (!agent) {
      throw new Error(`Agent ${agentId} not found`)
    }

    if (agent.state !== 'idle') {
      throw new Error(`Agent ${agentId} is not available (state: ${agent.state})`)
    }

    agent.state = 'active'
    agent.updatedAt = new Date()

    try {
      // Retrieve relevant memories for context
      const relevantMemories = await this.retrieveMemory(MemoryType.SEMANTIC, request.problem, 5)
      const memoryContext = relevantMemories.map(m => m.content).join('\n')

      // Construct reasoning prompt
      const prompt = this.buildReasoningPrompt(request, memoryContext)

      // Send request to the model (using OpenAI-compatible API)
      const response = await fetch(`${this.foundryManager.endpoint}/chat/completions`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.foundryManager.apiKey}`
        },
        body: JSON.stringify({
          model: agent.model.id,
          messages: [{ role: 'user', content: prompt }],
          temperature: 0.7,
          maxTokens: 1000
        })
      })

      const result = await response.json()
      const reasoning = result.choices[0].message.content

      // Parse the reasoning response
      const reasoningResponse = this.parseReasoningResponse(reasoning)

      // Store the reasoning in memory
      await this.storeMemory({
        type: MemoryType.EPISODIC,
        content: `Reasoning: ${request.problem} -> ${reasoningResponse.conclusion}`,
        metadata: {
          agentId,
          strategy: request.strategy,
          confidence: reasoningResponse.confidence
        },
        importance: reasoningResponse.confidence
      })

      return reasoningResponse
    } finally {
      agent.state = 'idle'
      agent.updatedAt = new Date()
    }
  }

  /**
   * Creates a cognitive workflow.
   * @param {Object} workflowConfig - Workflow configuration.
   * @param {string} workflowConfig.name - Name of the workflow.
   * @param {string} workflowConfig.description - Description of the workflow.
   * @param {any[]} workflowConfig.steps - Steps in the workflow.
   * @param {Record<string, any>} [workflowConfig.input] - Input data.
   * @returns {Promise<CognitiveWorkflow>} The created workflow.
   */
  async createWorkflow({
    name,
    description,
    steps,
    input = {}
  }: {
    name: string
    description: string
    steps: WorkflowStepInput[]
    input?: Record<string, unknown>
  }): Promise<CognitiveWorkflow> {
    const workflowId = `workflow-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
    const workflow: CognitiveWorkflow = {
      id: workflowId,
      name,
      description,
      state: WorkflowState.PENDING,
      steps: steps.map(step => ({
        ...step,
        id: `step-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
        state: WorkflowState.PENDING,
        output: {}
      })),
      agents: [],
      input,
      output: {},
      createdAt: new Date(),
      updatedAt: new Date()
    }

    this.workflows.set(workflowId, workflow)
    return workflow
  }

  /**
   * Executes a cognitive workflow.
   * @param {string} workflowId - The workflow ID to execute.
   * @returns {Promise<CognitiveWorkflow>} The completed workflow.
   */
  async executeWorkflow(workflowId: string): Promise<CognitiveWorkflow> {
    const workflow = this.workflows.get(workflowId)
    if (!workflow) {
      throw new Error(`Workflow ${workflowId} not found`)
    }

    workflow.state = WorkflowState.ACTIVE
    workflow.updatedAt = new Date()

    try {
      // Execute steps based on dependencies
      for (const step of workflow.steps) {
        // Check if all dependencies are completed
        const dependenciesCompleted = step.dependencies.every(depId =>
          workflow.steps.find(s => s.id === depId)?.state === WorkflowState.COMPLETED
        )

        if (!dependenciesCompleted) {
          continue
        }

        step.state = WorkflowState.ACTIVE
        step.executedAt = new Date()

        // Execute the step based on its type
        try {
          await this.executeWorkflowStep(step)
          step.state = WorkflowState.COMPLETED
        } catch (error) {
          step.state = WorkflowState.FAILED
          throw error
        }
      }

      workflow.state = WorkflowState.COMPLETED
      return workflow
    } catch (error) {
      workflow.state = WorkflowState.FAILED
      throw error
    } finally {
      workflow.updatedAt = new Date()
    }
  }

  /**
   * Creates a cognitive synergy between agents.
   * @param {string[]} agentIds - Agent IDs to include in the synergy.
   * @param {string} collaborationType - Type of collaboration.
   * @param {Record<string, any>} [coordinationStrategy] - Coordination strategy.
   * @returns {Promise<CognitiveSynergy>} The created synergy.
   */
  async createSynergy(
    agentIds: string[],
    collaborationType: 'consensus' | 'debate' | 'delegation' | 'parallel' | 'sequential',
    coordinationStrategy: Record<string, unknown> = {}
  ): Promise<CognitiveSynergy> {
    if (!this.config.enableCollaboration) {
      throw new Error('Agent collaboration is disabled')
    }

    // Validate that all agents exist
    for (const agentId of agentIds) {
      if (!this.agents.has(agentId)) {
        throw new Error(`Agent ${agentId} not found`)
      }
    }

    const synergy: CognitiveSynergy = {
      agents: agentIds,
      collaborationType,
      coordinationStrategy,
      sharedContext: {}
    }

    const synergyId = `synergy-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
    this.synergies.set(synergyId, synergy)

    return synergy
  }

  /**
   * Cleans up old memory entries based on retention policy.
   * @returns {Promise<void>} Resolves when cleanup is complete.
   */
  private async cleanupMemory(): Promise<void> {
    if (this.memory.size <= this.config.maxMemoryEntries!) {
      return
    }

    const retentionMs = this.config.memoryRetentionDays! * 24 * 60 * 60 * 1000
    const cutoffDate = new Date(Date.now() - retentionMs)

    // Remove old, low-importance memories
    const memoriesToRemove = Array.from(this.memory.values())
      .filter(memory => memory.timestamp < cutoffDate && memory.importance < 0.3)
      .sort((a, b) => a.importance - b.importance)
      .slice(0, this.memory.size - this.config.maxMemoryEntries! + 100)

    for (const memory of memoriesToRemove) {
      this.memory.delete(memory.id)
    }

    if (this.config.debugMode && memoriesToRemove.length > 0) {
      console.log(`Cleaned up ${memoriesToRemove.length} old memory entries`)
    }
  }

  /**
   * Builds a reasoning prompt from the request and context.
   * @param {ReasoningRequest} request - The reasoning request.
   * @param {string} memoryContext - Relevant memory context.
   * @returns {string} The constructed prompt.
   */
  private buildReasoningPrompt(request: ReasoningRequest, memoryContext: string): string {
    return `
You are a cognitive reasoning agent. Please analyze the following problem using ${request.strategy} reasoning:

Problem: ${request.problem}

Context: ${JSON.stringify(request.context, null, 2)}

Evidence: ${JSON.stringify(request.evidence, null, 2)}

Relevant Memory Context:
${memoryContext}

Please provide your reasoning in the following JSON format:
{
  "conclusion": "your main conclusion",
  "confidence": 0.85,
  "reasoningSteps": ["step 1", "step 2", "step 3"],
  "supportingEvidence": ["evidence 1", "evidence 2"],
  "alternatives": [
    {"conclusion": "alternative 1", "confidence": 0.3, "reasoning": "why this alternative"},
    {"conclusion": "alternative 2", "confidence": 0.2, "reasoning": "why this alternative"}
  ]
}
`.trim()
  }

  /**
   * Parses the reasoning response from the model.
   * @param {string} response - Raw response from the model.
   * @returns {ReasoningResponse} Parsed reasoning response.
   */
  private parseReasoningResponse(response: string): ReasoningResponse {
    try {
      // Try to extract JSON from the response
      const jsonMatch = response.match(/\{[\s\S]*\}/)
      if (jsonMatch) {
        const parsed = JSON.parse(jsonMatch[0])
        return {
          conclusion: parsed.conclusion || 'No conclusion provided',
          confidence: Math.max(0, Math.min(1, parsed.confidence || 0.5)),
          reasoningSteps: Array.isArray(parsed.reasoningSteps) ? parsed.reasoningSteps : [],
          supportingEvidence: Array.isArray(parsed.supportingEvidence) ? parsed.supportingEvidence : [],
          alternatives: Array.isArray(parsed.alternatives) ? parsed.alternatives : []
        }
      }
    } catch (error) {
      if (this.config.debugMode) {
        console.warn('Failed to parse reasoning response as JSON:', error)
      }
    }

    // Fallback to basic parsing
    return {
      conclusion: response.substring(0, 500),
      confidence: 0.5,
      reasoningSteps: [],
      supportingEvidence: [],
      alternatives: []
    }
  }

  /**
   * Executes a single workflow step.
   * @param {WorkflowStep} step - The workflow step to execute.
   * @returns {Promise<void>} Resolves when step is complete.
   */
  private async executeWorkflowStep(step: WorkflowStep): Promise<void> {
    switch (step.type) {
      case 'reasoning': {
        const reasoningResult = await this.reason(step.agentId, {
          problem: step.input.problem as string,
          context: (step.input.context as Record<string, unknown>) || {},
          evidence: (step.input.evidence as unknown[]) || [],
          strategy: (step.input.strategy as 'deductive' | 'inductive' | 'abductive' | 'analogical' | 'causal') || 'deductive'
        })
        step.output = reasoningResult
        break
      }

      case 'memory-retrieval': {
        const memories = await this.retrieveMemory(
          step.input.memoryType as MemoryType,
          step.input.query as string,
          (step.input.limit as number) || 10
        )
        step.output = { memories }
        break
      }

      case 'memory-storage': {
        const storedMemory = await this.storeMemory({
          type: step.input.memoryType as MemoryType,
          content: step.input.content as string,
          metadata: (step.input.metadata as Record<string, unknown>) || {},
          importance: (step.input.importance as number) || 0.5
        })
        step.output = { memoryId: storedMemory.id }
        break
      }

      default:
        throw new Error(`Unknown workflow step type: ${step.type}`)
    }
  }

  /**
   * Gets the underlying Foundry Local Manager.
   * @returns {FoundryLocalManager} The Foundry Local Manager instance.
   */
  get foundry(): FoundryLocalManager {
    return this.foundryManager
  }

  /**
   * Gets current cognitive forge statistics.
   * @returns {Object} Statistics about the cognitive forge.
   */
  getStatistics(): {
    agents: number
    memories: number
    workflows: number
    synergies: number
    memoryByType: Record<MemoryType, number>
  } {
    const memoryByType = {} as Record<MemoryType, number>
    for (const memory of this.memory.values()) {
      memoryByType[memory.type] = (memoryByType[memory.type] || 0) + 1
    }

    return {
      agents: this.agents.size,
      memories: this.memory.size,
      workflows: this.workflows.size,
      synergies: this.synergies.size,
      memoryByType
    }
  }
}