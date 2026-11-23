import { LightningElement, track } from 'lwc';
import analyzeWithAI from '@salesforce/apex/AIMetadataAnalyzer.analyzeWithAI';
import processNaturalLanguageQuery from '@salesforce/apex/AIMetadataAnalyzer.processNaturalLanguageQuery';
import testDeepSeekConnection from '@salesforce/apex/AIMetadataAnalyzer.testDeepSeekConnection';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';
export default class AiDeclutterAgent extends LightningElement {
    @track selectedObjects = ['Account'];
    @track messages = [];
    @track currentMessage = '';
    @track isSending = false;
    @track connectionTested = false;
    @track connectionStatus = '';
    @track connectionBadgeVariant = 'inverse';
    @track showRiskChart = false;
    @track riskChartData = null;
    
    objectOptions = [
        { label: 'Account', value: 'Account' },
        { label: 'Contact', value: 'Contact' },
        { label: 'Lead', value: 'Lead' },
        { label: 'Opportunity', value: 'Opportunity' },
        { label: 'Case', value: 'Case' },
        { label: 'ACM Integration Message Queue', value: 'ACM_Integration_Message_Queue__c' },
        { label: 'Integration Outbound Message', value: 'Core_Integration_Outbound_Message__c' },
        // Add more custom objects as needed
        
    ];
    
    connectedCallback() {
        this.addWelcomeMessage();
    }
    
    addWelcomeMessage() {
        this.addMessage({
            sender: 'API Assistant',
            text: 'Hello! I\'m your AI-powered Salesforce declutter agent . I can help you:\n\n' +
                  '• 🔍 Find unused or redundant fields\n' +
                  '• 🔄 Identify duplicate functionality\n' +
                  '• ⚠️ Assess cleanup risks with AI reasoning\n' +
                  '• 📊 Generate detailed cleanup recommendations\n' +
                  '• 💬 Answer natural language questions about your metadata\n\n' +
                  'Try asking: "What Account fields have no data and are never used in code?" or click the quick action buttons above!',
            isAI: true,
            confidence: '95%'
        });
    }
    
    async testConnection() {
        this.connectionTested = false;
        
        try {
            const isConnected = await testDeepSeekConnection();
            
            this.connectionTested = true;
            if (isConnected) {
                this.connectionStatus = '✅ API Connected';
                this.connectionBadgeVariant = 'success';
                this.showToast('Success', 'API connection successful!', 'success');
            } else {
                this.connectionStatus = '❌ Connection Failed';
                this.connectionBadgeVariant = 'error';
                this.showToast('Error', 'API connection failed. Check your API key.', 'error');
            }
        } catch (error) {
            this.connectionTested = true;
            this.connectionStatus = '❌ Connection Error';
            this.connectionBadgeVariant = 'error';
            this.showToast('Error', 'API connection test failed: ' + error.body?.message, 'error');
        }
    }
    
    handleObjectSelection(event) {
        this.selectedObjects = event.detail.value;
    }
    
    handleMessageChange(event) {
        this.currentMessage = event.target.value;
    }
    
    handleKeyUp(event) {
        if (event.keyCode === 13) {
            this.sendMessage();
        }
    }
    
    async sendMessage() {
        if (!this.currentMessage.trim()) {
            this.showToast('Warning', 'Please enter a message', 'warning');
            return;
        }
        
        if (this.selectedObjects.length === 0) {
            this.showToast('Warning', 'Please select at least one object to analyze', 'warning');
            return;
        }
        
        const userMessage = this.currentMessage;
        this.addMessage({
            sender: 'You',
            text: userMessage,
            isAI: false
        });
        
        this.currentMessage = '';
        this.isSending = true;
        
        try {
            const response = await processNaturalLanguageQuery({
                userQuery: userMessage,
                objects: this.selectedObjects
            });
            
            this.addAIResponse(response);
            
        } catch (error) {
            console.error('Error:', error);
            this.addMessage({
                sender: 'API Assistant',
                text: '❌ I encountered an error analyzing your request: ' + 
                      (error.body?.message || error.message) + 
                      '\n\nPlease try:\n• Rephrasing your question\n• Checking your API connection\n• Selecting fewer objects',
                isAI: true,
                confidence: '0%'
            });
        } finally {
            this.isSending = false;
        }
    }
    
    async analyzeUnusedFields() {
        await this.processQuickAction('Find all unused custom fields with zero data population and no code references', 'unused_fields');
    }
    
    async findDuplicates() {
        await this.processQuickAction('Identify duplicate or redundant metadata including similar fields and overlapping functionality', 'duplicates');
    }
    
    async assessRisk() {
        await this.processQuickAction('Perform comprehensive risk assessment for all metadata cleanup opportunities', 'risk_assessment');
    }
    
    async processQuickAction(query, analysisType) {
        if (this.selectedObjects.length === 0) {
            this.showToast('Warning', 'Please select objects to analyze first', 'warning');
            return;
        }
        
        this.addMessage({
            sender: 'You',
            text: `🚀 Quick Action: ${query}`,
            isAI: false
        });
        
        this.isSending = true;
        
        try {
            console.log('Calling analyzeWithAI with:', {
                query: query,
                selectedObjects: this.selectedObjects,
                analysisType: analysisType
            });
            
            const response = await analyzeWithAI({
                query: query,
                selectedObjects: this.selectedObjects,
                analysisType: analysisType
            });
            
            console.log('Received response:', response);
            this.addAIResponse(response);
            
        } catch (error) {
            console.error('Quick action error details:', error);
            console.error('Error stack:', error.stack);
            console.error('Error body:', error.body);
            
            let errorMessage = 'Unknown error occurred';
            if (error.body && error.body.message) {
                errorMessage = error.body.message;
            } else if (error.message) {
                errorMessage = error.message;
            }
            
            this.addMessage({
                sender: 'API Assistant',
                text: '❌ Quick analysis failed: ' + errorMessage,
                isAI: true,
                confidence: '0%'
            });
        } finally {
            this.isSending = false;
        }
    }
    
    addAIResponse(response) {
        console.log('Processing AI response:', response);
        
        // Null safety checks
        if (!response) {
            console.error('Response is null or undefined');
            this.addMessage({
                sender: 'API Assistant',
                text: '❌ Received empty response from AI',
                isAI: true,
                confidence: '0%'
            });
            return;
        }
        
        const recommendations = (response.recommendations && Array.isArray(response.recommendations)) ? 
            response.recommendations.map(rec => {
                if (!rec) return null;
                return {
                    ...rec,
                    badgeVariant: this.getBadgeVariant(rec.action)
                };
            }).filter(rec => rec !== null) : [];
        
        const modelInfo = response.tokensUsed ? 
            `\n\n🤖 API Model: ${response.modelUsed || 'gpt-4o'} | Tokens Used: ${response.tokensUsed}` : '';
        
        // Format the AI response text for better display
        let formattedText = response.summary || 'Analysis completed';
        
        // Clean up the AI response text to remove unwanted sections
        formattedText = this.cleanResponseText(formattedText);
        
        const message = {
            sender: 'API Assistant',
            text: formattedText + modelInfo,
            isAI: true,
            confidence: (response.confidence || 85) + '%',
            recommendations: recommendations,
            reasoning: response.reasoning || 'Analysis completed successfully'
        };
        // Check if this is a risk assessment and has recommendations for chart
        if (recommendations.length > 0 && this.shouldShowChart(recommendations)) {
            message.showChart = true;
            message.chartData = this.prepareChartData(recommendations);
        }
        this.addMessage(message);
        
        if (recommendations.length > 0) {
            this.showToast('Success', `Analysis complete! Found ${recommendations.length} recommendations.`, 'success');
        }
    }
    
    cleanResponseText(text) {
        if (!text) return '';
        
        // Remove common unwanted sections and excessive formatting
        let cleaned = text
            // Remove repeated recommendation sections
            .replace(/📋 Recommendations:[\s\S]*?────────────────────────────────────────/g, '')
            .replace(/📋 Next Steps:[\s\S]*?────────────────────────────────────────/g, '')
            .replace(/🎯 Recommendations:[\s\S]*$/g, '')
            // Remove excessive bullet points and formatting
            .replace(/^\s*[-•]\s*/gm, '• ')
            .replace(/^\s*\d+\.\s*🔸\s*/gm, '• ')
            // Clean up multiple newlines
            .replace(/\n{3,}/g, '\n\n')
            // Remove trailing whitespace
            .trim();
        
        return cleaned;
    }
    
    getBadgeVariant(action) {
        if (action && action.includes('REMOVE')) return 'success';
        if (action && action.includes('REVIEW')) return 'warning';
        if (action && action.includes('KEEP')) return 'error';
        if (action && action.includes('CONSOLIDATE')) return 'brand';
        return 'inverse';
    }
    
    addMessage(messageData) {
        const message = {
            id: Date.now() + Math.random(),
            timestamp: new Date().toLocaleTimeString(),
            cssClass: messageData.isAI ? 'ai-message' : 'user-message',
            ...messageData
        };
        
        this.messages = [...this.messages, message];
        
        setTimeout(() => {
            const chatContainer = this.template.querySelector('.chat-messages');
            if (chatContainer) {
                chatContainer.scrollTop = chatContainer.scrollHeight;
            }
            
            // Render charts if this message has chart data
            if (messageData.showChart && messageData.chartData) {
                this.renderCharts(messageData.chartData);
            }
        }, 100);
    }
    
    shouldShowChart(recommendations) {
        // Show chart for any risk assessment that has recommendations with risk levels or actions
        const hasRiskLevels = recommendations.some(rec => rec.riskLevel);
        const hasActions = recommendations.some(rec => rec.action);
        return hasRiskLevels || hasActions; // Show chart if we have risk levels or actions
    }
    prepareChartData(recommendations) {
        // Count recommendations by risk level
        const riskCounts = {
            'LOW': 0,
            'MEDIUM': 0,
            'HIGH': 0
        };
        recommendations.forEach(rec => {
            if (rec.riskLevel && riskCounts.hasOwnProperty(rec.riskLevel)) {
                riskCounts[rec.riskLevel]++;
            }
        });
        // Count by action type
        const actionCounts = {
            'REMOVE': 0,
            'REVIEW': 0,
            'KEEP': 0,
            'CONSOLIDATE': 0
        };
        recommendations.forEach(rec => {
            if (rec.action && actionCounts.hasOwnProperty(rec.action)) {
                actionCounts[rec.action]++;
            }
        });
        return {
            riskData: {
                labels: ['Low Risk', 'Medium Risk', 'High Risk'],
                data: [riskCounts.LOW, riskCounts.MEDIUM, riskCounts.HIGH],
                colors: ['#4CAF50', '#FF9800', '#F44336']
            },
            actionData: {
                labels: ['Remove', 'Review', 'Keep', 'Consolidate'],
                data: [actionCounts.REMOVE, actionCounts.REVIEW, actionCounts.KEEP, actionCounts.CONSOLIDATE],
                colors: ['#4CAF50', '#FF9800', '#2196F3', '#9C27B0']
            }
        };
    }
    renderCharts(chartData) {
        try {
            setTimeout(() => {
                // Create simple bar charts using div elements
                this.createSimpleBarChart('.risk-chart', chartData.riskData);
                this.createSimpleBarChart('.action-chart', chartData.actionData);
            }, 200);
        } catch (error) {
            console.error('Error rendering charts:', error);
        }
    }
    createSimpleBarChart(selector, data) {
        const canvas = this.template.querySelector(selector);
        if (!canvas) return;
        // Replace canvas with div-based chart
        const chartContainer = canvas.parentElement;
        chartContainer.innerHTML = `
            <h5 class="slds-text-heading_x-small">${selector.includes('risk') ? 'Risk Distribution' : 'Recommended Actions'}</h5>
            <div class="simple-chart">
                ${data.labels.map((label, index) => {
                    const value = data.data[index];
                    const percentage = data.data.length > 0 ? (value / Math.max(...data.data)) * 100 : 0;
                    return `
                        <div class="chart-item" style="margin-bottom: 8px;">
                            <div class="chart-label" style="font-size: 11px; margin-bottom: 2px;">${label}: ${value}</div>
                            <div class="chart-bar" style="width: 100%; height: 20px; background-color: #f3f3f3; border-radius: 4px; overflow: hidden;">
                                <div class="chart-fill" style="width: ${percentage}%; height: 100%; background-color: ${data.colors[index]}; transition: width 0.5s ease;"></div>
                            </div>
                        </div>
                    `;
                }).join('')}
            </div>
        `;
    }
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}