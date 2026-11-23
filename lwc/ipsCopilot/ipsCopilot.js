import { LightningElement, wire, track } from 'lwc';
import getSessionId from '@salesforce/apex/IpsCopilotController.getSessionId';

export default class IpsCopilot extends LightningElement {
    @track copilotUrl;
    
    // Replace this URL with your hosted React application URL (e.g., Vercel, Heroku, or Salesforce Static Resource URL)
    hostedAppUrl = 'https://genai-app-salesforceipscopilot-1-1789498552714-522237602216.us-central1.run.app/?key=KyvXruIeAyhvwVKn53o9YPuKBnKeFiOC'; 

    @wire(getSessionId)
    wiredSession({ error, data }) {
        if (data) {
            // Pass the session ID securely via the URL hash fragment to prevent it from being logged in server logs
            this.copilotUrl = `${this.hostedAppUrl}#sid=${encodeURIComponent(data)}`;
        } else if (error) {
            console.error('Error retrieving Salesforce Session ID:', error);
            // Fallback to direct URL if session ID retrieval fails
            this.copilotUrl = this.hostedAppUrl;
        }
    }
}