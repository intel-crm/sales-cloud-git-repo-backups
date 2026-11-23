import { LightningElement,track } from 'lwc';

export default class Smg1aiChatUtility extends LightningElement {
    // Flag to track if the chat popup is open or not
    isChatOpen = true;
    // Track properties to ensure reactivity
    @track modalHeader = '';
    @track isModel = false;
    @track iframeResponse = '';
    // URL for the external chat UI
    chatUrl = 'https://smg-1ai-test.intel.com/c/new?agent_id=agent_qGLAN8kx4uGJVb_ATNkXU';  // Replace with your actual external chat URL


    handleCreateCaseClick(event) {
        event.preventDefault(); // Prevent default hyperlink behavior
        this.modalHeader = 'Sales CRM';
        this.isModel = true;

        // Select the iframe element using the class name
        const iframe = this.template.querySelector('.chat-iframe');
        // Retrieve the URL from the src attribute of the iframe
        const iframeUrl = iframe.getAttribute('src');

        // Log the URL to the console
        console.log('Iframe URL:', iframeUrl);
        try {
            // Create a URL object to easily access query parameters
            const url = new URL(iframeUrl);
        
            // Extract the chat conversation or any other parameter from the URL
            const chatConversation = url.searchParams.get('chat_conversation'); // Replace 'chat_conversation' with the actual parameter name
        
            // Log the chat conversation to the console
            console.log('Chat Conversation:', chatConversation);
        } catch (error) {
            console.error('Error processing URL:', error);
        }
        //event.preventDefault();
        // Logic to call another LWC component or perform any action
        // For example, you can dispatch a custom event or navigate to another component
        //this.dispatchEvent(new CustomEvent('createcase'));
    }

    handleModalClose() {
        this.isModel = false;
    }
}