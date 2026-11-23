import { LightningElement } from 'lwc';
import pricingChatUrl from '@salesforce/label/c.core_Pricing_ChatUrl';

export default class SmgPricingAgent extends LightningElement {
    chatUrl = pricingChatUrl;
    isChatOpen = false;

    get iframeTitle() {
        return 'SMG Pricing Agent';
    }

    openChat() {
        this.isChatOpen = true;
    }

    closeChat() {
        this.isChatOpen = false;
    }

    handleOverlayClick(event) {
        if (event.target === event.currentTarget) {
            this.closeChat();
        }
    }

    handleKeydown(event) {
        if (event.key === 'Escape') {
            this.closeChat();
        }
    }
}