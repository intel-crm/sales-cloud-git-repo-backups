import { LightningElement, track } from 'lwc';
import { ShowToastEvent }          from 'lightning/platformShowToastEvent';
import initializeMCPSession        from '@salesforce/apex/MCPContractController.initializeMCPSession';
import getAvailableTools           from '@salesforce/apex/MCPContractController.getAvailableTools';
import getContractMetadata         from '@salesforce/apex/MCPContractController.getContractMetadata';
import executeFullContractFlow     from '@salesforce/apex/MCPContractController.executeFullContractFlow';
import getAuthenticationUrl        from '@salesforce/apex/MCPContractController.getAuthenticationUrl';

const PENDING_FULL_FLOW_KEY = 'mcpContractComponent.pendingFullFlow';

export default class McpContractComponent extends LightningElement {
    
    // ─── State ───
    @track sessionId        = null;
    @track isLoading        = false;
    @track errorMessage     = null;
    @track responseData     = null;
    @track availableTools   = [];
    @track isInitialized    = false;
    @track requiresAuth     = false;
    
    // ─── Form Inputs ───
    @track contractNumber   = null;
    @track orderNumber      = 1;

    connectedCallback() {
        const pendingFlow = this.consumePendingFullFlow();
        if (pendingFlow) {
            this.contractNumber = pendingFlow.contractNumber;
            this.orderNumber    = pendingFlow.orderNumber;
            this.runFullFlow(false);
            return;
        }
        this.initializeSession(false);
    }

    async handleAuthenticate() {
        if (this.isAuthenticateDisabled) {
            return;
        }
        await this.redirectToAuthentication();
    }

    async redirectToAuthentication() {
        this.isLoading = true;
        try {
            const returnPath = window.location.pathname + window.location.search + window.location.hash;
            const authenticationUrl = await getAuthenticationUrl({ returnPath });
            window.location.assign(authenticationUrl);
        } catch (error) {
            this.clearPendingFullFlow();
            this.errorMessage = error.body?.message || error.message;
            this.showToast('Error', this.errorMessage, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    savePendingFullFlow() {
        try {
            window.sessionStorage.setItem(PENDING_FULL_FLOW_KEY, JSON.stringify({
                contractNumber : this.contractNumber,
                orderNumber    : this.orderNumber
            }));
            return true;
        } catch (error) {
            return false;
        }
    }

    clearPendingFullFlow() {
        try {
            window.sessionStorage.removeItem(PENDING_FULL_FLOW_KEY);
        } catch (error) {
            // Storage unavailable; nothing to clear.
        }
    }

    // Removed before resuming so a failed re-authentication cannot cause a redirect loop.
    consumePendingFullFlow() {
        let stored;
        try {
            stored = window.sessionStorage.getItem(PENDING_FULL_FLOW_KEY);
        } catch (error) {
            return null;
        }
        if (!stored) {
            return null;
        }
        this.clearPendingFullFlow();
        try {
            const parsed         = JSON.parse(stored);
            const contractNumber = parseInt(parsed?.contractNumber, 10);
            const orderNumber    = parseInt(parsed?.orderNumber, 10);
            if (!Number.isFinite(contractNumber)) {
                return null;
            }
            return {
                contractNumber,
                orderNumber: Number.isFinite(orderNumber) ? orderNumber : 1
            };
        } catch (error) {
            return null;
        }
    }

    updateAuthenticationStatus(result) {
        this.requiresAuth = result.requiresAuth === true;
        if (this.requiresAuth) {
            this.isInitialized = false;
            this.sessionId = null;
            this.availableTools = [];
        }
    }

    // ─────────────────────────────────────────
    // Initialize Session
    // ─────────────────────────────────────────
    handleInitialize() {
        return this.initializeSession(true);
    }

    async initializeSession(showFeedback) {
        this.isLoading     = true;
        this.errorMessage  = null;
        this.responseData  = null;
        this.isInitialized = false;
        this.sessionId     = null;
        this.availableTools = [];
        
        try {
            const result = await initializeMCPSession();
            this.updateAuthenticationStatus(result);
            
            if (result.success) {
                this.sessionId     = result.sessionId;
                this.isInitialized = true;
                this.responseData  = result.responseBody;
                
                if (showFeedback) {
                    this.showToast('Success', 'Session Initialized', 'success');
                }
            } else {
                this.errorMessage = result.error;
                if (showFeedback) {
                    this.showToast('Error', result.error, 'error');
                }
            }
            
        } catch (error) {
            console.error('Init Error:', error);
            this.errorMessage = error.body?.message || error.message;
            if (showFeedback) {
                this.showToast('Error', this.errorMessage, 'error');
            }
            
        } finally {
            this.isLoading = false;
        }
    }

    // ─────────────────────────────────────────
    // Load Tools
    // ─────────────────────────────────────────
    async handleLoadTools() {
        if (!this.isInitialized) {
            this.showToast('Warning', 'Please initialize session first', 'warning');
            return;
        }
        
        this.isLoading    = true;
        this.errorMessage = null;
        
        try {
            const result = await getAvailableTools({ 
                sessionId: this.sessionId 
            });
            
            console.log('Tools Result:', JSON.stringify(result));
            this.updateAuthenticationStatus(result);
            
            if (result.success) {
                const parsed        = JSON.parse(result.body);
                this.availableTools = parsed?.result?.tools || [];
                this.responseData   = result.body;
                
                console.log('Tools:', JSON.stringify(this.availableTools));
                
                this.showToast(
                    'Success', 
                    `${this.availableTools.length} tool(s) loaded`, 
                    'success'
                );
            } else {
                this.errorMessage = result.error;
                this.showToast('Error', result.error, 'error');
            }
            
        } catch (error) {
            console.error('Tools Error:', error);
            this.errorMessage = error.body?.message || error.message;
            this.showToast('Error', this.errorMessage, 'error');
            
        } finally {
            this.isLoading = false;
        }
    }

    // ─────────────────────────────────────────
    // Handle Input Changes
    // ─────────────────────────────────────────
    handleContractNumberChange(event) {
        this.contractNumber = parseInt(event.target.value, 10);
    }
    
    handleOrderNumberChange(event) {
        this.orderNumber = parseInt(event.target.value, 10);
    }

    // ─────────────────────────────────────────
    // Get Contract Metadata
    // ─────────────────────────────────────────
    async handleGetContractMetadata() {
        if (!this.isInitialized) {
            this.showToast('Warning', 'Please initialize session first', 'warning');
            return;
        }
        
        if (!this.contractNumber) {
            this.showToast('Warning', 'Please enter a Contract Number', 'warning');
            return;
        }
        
        this.isLoading    = true;
        this.errorMessage = null;
        this.responseData = null;
        
        try {
            console.log('Calling getContractMetadata:', {
                sessionId      : this.sessionId,
                contractNumber : this.contractNumber,
                orderNumber    : this.orderNumber
            });
            
            const result = await getContractMetadata({
                sessionId      : this.sessionId,
                contractNumber : this.contractNumber,
                orderNumber    : this.orderNumber
            });
            
            console.log('Contract Metadata Result:', JSON.stringify(result));
            this.updateAuthenticationStatus(result);
            
            if (result.success) {
                this.responseData = result.body;
                
                // ─── Update session if refreshed ───
                if (result.sessionId) {
                    this.sessionId = result.sessionId;
                }
                
                this.showToast('Success', 'Contract metadata retrieved', 'success');
            } else {
                this.errorMessage = result.error;
                this.showToast('Error', result.error, 'error');
            }
            
        } catch (error) {
            console.error('Contract Metadata Error:', error);
            this.errorMessage = error.body?.message || error.message;
            this.showToast('Error', this.errorMessage, 'error');
            
        } finally {
            this.isLoading = false;
        }
    }

    // ─────────────────────────────────────────
    // Full Flow - One Click
    // ─────────────────────────────────────────
    async handleFullFlow() {
        if (!this.contractNumber) {
            this.showToast('Warning', 'Please enter a Contract Number', 'warning');
            return;
        }
        await this.runFullFlow(true);
    }

    async runFullFlow(allowAuthRedirect) {
        this.isLoading    = true;
        this.errorMessage = null;
        this.responseData = null;
        
        try {
            const result = await executeFullContractFlow({
                contractNumber : this.contractNumber,
                orderNumber    : this.orderNumber
            });
            
            console.log('Full Flow Result:', JSON.stringify(result));
            this.updateAuthenticationStatus(result);

            if (this.requiresAuth && allowAuthRedirect && this.savePendingFullFlow()) {
                this.showToast('Info', 'Session expired. Redirecting to authenticate...', 'info');
                await this.redirectToAuthentication();
                return;
            }
            
            if (result.success) {
                this.sessionId     = result.sessionId;
                this.isInitialized = true;
                this.responseData  = result.body;
                
                this.showToast('Success', 'Contract data retrieved successfully', 'success');
            } else {
                this.errorMessage = result.error;
                this.showToast('Error', result.error, 'error');
            }
            
        } catch (error) {
            console.error('Full Flow Error:', error);
            this.errorMessage = error.body?.message || error.message;
            this.showToast('Error', this.errorMessage, 'error');
            
        } finally {
            this.isLoading = false;
        }
    }

    // ─────────────────────────────────────────
    // Toast
    // ─────────────────────────────────────────
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }

    // ─────────────────────────────────────────
    // Getters
    // ─────────────────────────────────────────
    get hasError()       { return !!this.errorMessage; }
    get isAuthenticateDisabled() { return this.isLoading || !this.requiresAuth; }
    get hasResponse()    { return !!this.responseData; }
    get hasTools()       { return this.availableTools.length > 0; }
    get sessionDisplay() { return this.sessionId || 'Not initialized'; }
    
    get formattedResponse() {
        try {
            return JSON.stringify(JSON.parse(this.responseData), null, 2);
        } catch(e) {
            return this.responseData;
        }
    }
}