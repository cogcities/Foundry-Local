/**
 * 🧠 Neural Transport Hub for Foundry Manufacturing District
 * Enables communication with other cognitive cities
 */

import WebSocket from 'ws';
import express from 'express';
import cors from 'cors';
import { v4 as uuidv4 } from 'uuid';

interface CityMessage {
  sourceCity: string;
  targetCity: string;
  district: string;
  messageType: string;
  payload: any;
  timestamp: number;
  messageId: string;
}

interface FoundryInsight {
  type: 'security' | 'optimization' | 'pattern' | 'template';
  contractType: string;
  insight: any;
  confidence: number;
}

interface ConnectedCity {
  id: string;
  websocket: WebSocket;
  lastSeen: number;
  capabilities: string[];
  district: string;
}

class FoundryNeuralTransport {
  private server: WebSocket.Server;
  private httpServer: express.Application;
  private connectedCities: Map<string, ConnectedCity> = new Map();
  private cityId: string;
  private district: string = 'manufacturing';
  private port: number;
  private httpPort: number;
  
  constructor(cityId: string, port: number = 4000, httpPort: number = 4001) {
    this.cityId = cityId;
    this.port = port;
    this.httpPort = httpPort;
    this.setupWebSocketServer();
    this.setupHttpServer();
  }
  
  private setupWebSocketServer(): void {
    this.server = new WebSocket.Server({ port: this.port });
    
    console.log(`🧠 Neural Transport Hub listening on ws://localhost:${this.port}`);
    
    this.server.on('connection', (ws: WebSocket) => {
      console.log('🔗 New connection established');
      
      ws.on('message', async (data: WebSocket.Data) => {
        try {
          const message = JSON.parse(data.toString());
          await this.handleIncomingMessage(ws, message);
        } catch (error) {
          console.error('❌ Error processing message:', error);
          ws.send(JSON.stringify({
            type: 'error',
            message: 'Invalid message format'
          }));
        }
      });
      
      ws.on('close', () => {
        this.handleDisconnection(ws);
      });
      
      ws.on('error', (error) => {
        console.error('🚨 WebSocket error:', error);
      });
    });
  }
  
  private setupHttpServer(): void {
    this.httpServer = express();
    this.httpServer.use(cors());
    this.httpServer.use(express.json());
    
    // Health check endpoint
    this.httpServer.get('/health', (req, res) => {
      res.json({
        status: 'healthy',
        cityId: this.cityId,
        district: this.district,
        connectedCities: Array.from(this.connectedCities.keys()),
        timestamp: Date.now()
      });
    });
    
    // Get connected cities
    this.httpServer.get('/cities', (req, res) => {
      const cities = Array.from(this.connectedCities.entries()).map(([id, city]) => ({
        id,
        district: city.district,
        capabilities: city.capabilities,
        lastSeen: city.lastSeen
      }));
      
      res.json({ cities });
    });
    
    // Send message via HTTP
    this.httpServer.post('/send', async (req, res) => {
      try {
        const { targetCity, messageType, payload } = req.body;
        
        const message: CityMessage = {
          sourceCity: this.cityId,
          targetCity,
          district: this.district,
          messageType,
          payload,
          timestamp: Date.now(),
          messageId: uuidv4()
        };
        
        await this.routeMessage(message);
        res.json({ success: true, messageId: message.messageId });
      } catch (error) {
        res.status(500).json({ error: error.message });
      }
    });
    
    this.httpServer.listen(this.httpPort, () => {
      console.log(`🌐 Neural Transport HTTP API listening on http://localhost:${this.httpPort}`);
    });
  }
  
  private async handleIncomingMessage(ws: WebSocket, message: any): Promise<void> {
    console.log(`📨 Received message type: ${message.type}`);
    
    switch (message.type) {
      case 'city_registration':
        await this.handleCityRegistration(ws, message.payload);
        break;
      case 'foundry_insight_request':
        await this.handleInsightRequest(ws, message);
        break;
      case 'foundry_insight_share':
        await this.handleInsightShare(ws, message);
        break;
      case 'collaboration_request':
        await this.handleCollaborationRequest(ws, message);
        break;
      case 'ping':
        ws.send(JSON.stringify({ type: 'pong', timestamp: Date.now() }));
        break;
      default:
        console.warn(`⚠️ Unknown message type: ${message.type}`);
    }
  }
  
  private async handleCityRegistration(ws: WebSocket, payload: any): Promise<void> {
    const { cityId, district, capabilities, services } = payload;
    
    console.log(`🏙️ City registration: ${cityId} (${district})`);
    
    const connectedCity: ConnectedCity = {
      id: cityId,
      websocket: ws,
      lastSeen: Date.now(),
      capabilities: capabilities || [],
      district: district || 'unknown'
    };
    
    this.connectedCities.set(cityId, connectedCity);
    
    // Send registration confirmation
    ws.send(JSON.stringify({
      type: 'registration_confirmed',
      hubId: this.cityId,
      timestamp: Date.now(),
      connectedCities: Array.from(this.connectedCities.keys())
    }));
    
    // Notify other cities of new connection
    this.broadcastToOtherCities(cityId, {
      type: 'city_connected',
      cityId,
      district,
      capabilities
    });
  }
  
  private async handleInsightRequest(ws: WebSocket, message: CityMessage): Promise<void> {
    console.log(`🔍 Insight request from ${message.sourceCity}`);
    
    // Route insight request to appropriate cities
    await this.routeMessage(message);
    
    // Send acknowledgment
    ws.send(JSON.stringify({
      type: 'insight_request_received',
      messageId: message.messageId || uuidv4(),
      timestamp: Date.now()
    }));
  }
  
  private async handleInsightShare(ws: WebSocket, message: CityMessage): Promise<void> {
    console.log(`💡 Insight shared by ${message.sourceCity}`);
    
    const insight: FoundryInsight = message.payload;
    
    // Store insight in knowledge base (placeholder)
    console.log(`📚 Storing insight: ${insight.type} - ${insight.contractType}`);
    
    // Broadcast to interested cities
    this.broadcastToOtherCities(message.sourceCity, {
      type: 'foundry_insight_broadcast',
      sourceCity: message.sourceCity,
      insight,
      timestamp: Date.now()
    });
  }
  
  private async handleCollaborationRequest(ws: WebSocket, message: CityMessage): Promise<void> {
    console.log(`🤝 Collaboration request from ${message.sourceCity}`);
    
    const proposal = message.payload;
    proposal.hubProcessedAt = Date.now();
    proposal.proposalId = uuidv4();
    
    // Route to target city or broadcast if no specific target
    if (message.targetCity && message.targetCity !== 'broadcast') {
      await this.routeMessage(message);
    } else {
      this.broadcastToOtherCities(message.sourceCity, {
        type: 'collaboration_proposal',
        sourceCity: message.sourceCity,
        proposal,
        timestamp: Date.now()
      });
    }
  }
  
  private async routeMessage(message: CityMessage): Promise<void> {
    const targetCity = this.connectedCities.get(message.targetCity);
    
    if (targetCity && targetCity.websocket.readyState === WebSocket.OPEN) {
      targetCity.websocket.send(JSON.stringify(message));
      console.log(`📤 Message routed to ${message.targetCity}`);
    } else {
      console.warn(`⚠️ Target city ${message.targetCity} not connected`);
    }
  }
  
  private broadcastToOtherCities(excludeCityId: string, message: any): void {
    this.connectedCities.forEach((city, cityId) => {
      if (cityId !== excludeCityId && city.websocket.readyState === WebSocket.OPEN) {
        city.websocket.send(JSON.stringify(message));
      }
    });
  }
  
  private handleDisconnection(ws: WebSocket): void {
    // Find and remove disconnected city
    for (const [cityId, city] of this.connectedCities.entries()) {
      if (city.websocket === ws) {
        console.log(`🔌 City disconnected: ${cityId}`);
        this.connectedCities.delete(cityId);
        
        // Notify other cities
        this.broadcastToOtherCities(cityId, {
          type: 'city_disconnected',
          cityId,
          timestamp: Date.now()
        });
        break;
      }
    }
  }
  
  async shareFoundryInsight(insight: FoundryInsight, targetCities: string[]): Promise<void> {
    const message: CityMessage = {
      sourceCity: this.cityId,
      targetCity: '', // Will be set for each target
      district: 'manufacturing',
      messageType: 'foundry_insight_share',
      payload: insight,
      timestamp: Date.now(),
      messageId: uuidv4()
    };
    
    for (const targetCity of targetCities) {
      message.targetCity = targetCity;
      await this.routeMessage(message);
    }
  }
  
  // Cleanup and health monitoring
  startHealthMonitoring(): void {
    setInterval(() => {
      const now = Date.now();
      
      this.connectedCities.forEach((city, cityId) => {
        // Remove stale connections (5 minutes)
        if (now - city.lastSeen > 300000) {
          console.log(`🧹 Removing stale connection: ${cityId}`);
          this.connectedCities.delete(cityId);
        }
      });
      
      console.log(`💓 Health check: ${this.connectedCities.size} cities connected`);
    }, 60000); // Check every minute
  }
}

// Initialize and start the neural transport hub
const cityId = process.env.CITY_ID || 'foundry-manufacturing-district';
const wsPort = parseInt(process.env.WS_PORT || '4000');
const httpPort = parseInt(process.env.HTTP_PORT || '4001');

const neuralTransport = new FoundryNeuralTransport(cityId, wsPort, httpPort);
neuralTransport.startHealthMonitoring();

console.log(`🏭 Foundry Neural Transport Hub initialized for city: ${cityId}`);

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('🛑 Shutting down Neural Transport Hub...');
  process.exit(0);
});

export default FoundryNeuralTransport;