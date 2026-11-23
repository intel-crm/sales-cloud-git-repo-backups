import { LightningElement } from 'lwc';

export default class Smg1aiChatUtility extends LightningElement {
    // Flag to track if the chat popup is open or not
    isChatOpen = true;
    
    // URL for the external chat UI
    chatUrl = 'https://smg-1ai-test.intel.com/';  // Replace with your actual external chat URL

    // Method to close the chat popup
    closeChat() {
        // Close the chat popup
        this.isChatOpen = false;
    }
}