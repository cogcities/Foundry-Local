// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

import type { FoundryModelInfo } from './types.js'

/**
 * Enum representing different types of cognitive agents.
 */
export enum CognitiveAgentType {
  REASONING = 'reasoning',
  MEMORY = 'memory', 
  PLANNING = 'planning',
  EXECUTION = 'execution',
  MONITORING = 'monitoring',
  COLLABORATION = 'collaboration'
}

/**
 * Enum representing different types of memory systems.
 */
export enum MemoryType {
  WORKING = 'working',
  EPISODIC = 'episodic', 
  SEMANTIC = 'semantic',
  PROCEDURAL = 'procedural'
}

/**
 * Enum representing cognitive workflow states.
 */
export enum WorkflowState {
  PENDING = 'pending',
  ACTIVE = 'active',
  COMPLETED = 'completed',
  FAILED = 'failed',
  PAUSED = 'paused'
}

/**
 * Interface representing a cognitive agent configuration.
 */
export interface CognitiveAgent {
  /**
   * Unique identifier for the agent.
   */
  id: string

  /**
   * Name of the agent.
   */
  name: string

  /**
   * Type of cognitive agent.
   */
  type: CognitiveAgentType

  /**
   * Model information for the agent.
   */
  model: FoundryModelInfo

  /**
   * Agent-specific configuration.
   */
  config: Record<string, unknown>

  /**
   * Current state of the agent.
   */
  state: 'idle' | 'active' | 'busy' | 'error'

  /**
   * Timestamp when agent was created.
   */
  createdAt: Date

  /**
   * Timestamp when agent was last updated.
   */
  updatedAt: Date
}

/**
 * Interface representing a memory entry.
 */
export interface MemoryEntry {
  /**
   * Unique identifier for the memory entry.
   */
  id: string

  /**
   * Type of memory.
   */
  type: MemoryType

  /**
   * Content of the memory entry.
   */
  content: string

  /**
   * Metadata associated with the memory.
   */
  metadata: Record<string, unknown>

  /**
   * Timestamp when memory was created.
   */
  timestamp: Date

  /**
   * Importance score (0-1).
   */
  importance: number

  /**
   * Access count for the memory.
   */
  accessCount: number

  /**
   * Last access timestamp.
   */
  lastAccessed: Date
}

/**
 * Interface representing a cognitive workflow.
 */
export interface CognitiveWorkflow {
  /**
   * Unique identifier for the workflow.
   */
  id: string

  /**
   * Name of the workflow.
   */
  name: string

  /**
   * Description of the workflow.
   */
  description: string

  /**
   * Current state of the workflow.
   */
  state: WorkflowState

  /**
   * Steps in the workflow.
   */
  steps: WorkflowStep[]

  /**
   * Agents involved in the workflow.
   */
  agents: string[]

  /**
   * Input data for the workflow.
   */
  input: Record<string, unknown>

  /**
   * Output data from the workflow.
   */
  output: Record<string, unknown>

  /**
   * Timestamp when workflow was created.
   */
  createdAt: Date

  /**
   * Timestamp when workflow was last updated.
   */
  updatedAt: Date
}

/**
 * Interface representing input for creating a workflow step.
 */
export interface WorkflowStepInput {
  /**
   * Name of the step.
   */
  name: string

  /**
   * Type of step operation.
   */
  type: 'reasoning' | 'memory-retrieval' | 'memory-storage' | 'agent-collaboration' | 'decision' | 'action'

  /**
   * Agent responsible for this step.
   */
  agentId: string

  /**
   * Input data for the step.
   */
  input: Record<string, unknown>

  /**
   * Dependencies (other step IDs that must complete first).
   */
  dependencies: string[]
}

/**
 * Interface representing a single step in a cognitive workflow.
 */
export interface WorkflowStep {
  /**
   * Unique identifier for the step.
   */
  id: string

  /**
   * Name of the step.
   */
  name: string

  /**
   * Type of step operation.
   */
  type: 'reasoning' | 'memory-retrieval' | 'memory-storage' | 'agent-collaboration' | 'decision' | 'action'

  /**
   * Agent responsible for this step.
   */
  agentId: string

  /**
   * Input data for the step.
   */
  input: Record<string, unknown>

  /**
   * Output data from the step.
   */
  output: Record<string, unknown>

  /**
   * State of the step.
   */
  state: WorkflowState

  /**
   * Dependencies (other step IDs that must complete first).
   */
  dependencies: string[]

  /**
   * Timestamp when step was executed.
   */
  executedAt?: Date
}

/**
 * Interface representing cognitive synergy configuration.
 */
export interface CognitiveSynergy {
  /**
   * Agents participating in the synergy.
   */
  agents: string[]

  /**
   * Type of collaboration.
   */
  collaborationType: 'consensus' | 'debate' | 'delegation' | 'parallel' | 'sequential'

  /**
   * Coordination strategy.
   */
  coordinationStrategy: Record<string, unknown>

  /**
   * Shared context between agents.
   */
  sharedContext: Record<string, unknown>
}

/**
 * Interface representing cognitive forge configuration.
 */
export interface CognitiveForgeConfig {
  /**
   * Maximum number of concurrent agents.
   */
  maxConcurrentAgents?: number

  /**
   * Memory retention policy.
   */
  memoryRetentionDays?: number

  /**
   * Maximum memory entries per type.
   */
  maxMemoryEntries?: number

  /**
   * Enable agent collaboration.
   */
  enableCollaboration?: boolean

  /**
   * Workflow timeout in milliseconds.
   */
  workflowTimeout?: number

  /**
   * Debug mode for detailed logging.
   */
  debugMode?: boolean
}

/**
 * Interface representing a cognitive reasoning request.
 */
export interface ReasoningRequest {
  /**
   * The problem or question to reason about.
   */
  problem: string

  /**
   * Context information.
   */
  context: Record<string, unknown>

  /**
   * Available evidence or data.
   */
  evidence: unknown[]

  /**
   * Reasoning strategy to use.
   */
  strategy: 'deductive' | 'inductive' | 'abductive' | 'analogical' | 'causal'

  /**
   * Maximum reasoning depth.
   */
  maxDepth?: number
}

/**
 * Interface representing a cognitive reasoning response.
 */
export interface ReasoningResponse {
  /**
   * The conclusion or answer.
   */
  conclusion: string

  /**
   * Confidence level (0-1).
   */
  confidence: number

  /**
   * Reasoning steps taken.
   */
  reasoningSteps: string[]

  /**
   * Supporting evidence used.
   */
  supportingEvidence: unknown[]

  /**
   * Alternative conclusions considered.
   */
  alternatives: Array<{
    conclusion: string
    confidence: number
    reasoning: string
  }>
}