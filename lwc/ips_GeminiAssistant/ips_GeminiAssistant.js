import { LightningElement, api, track } from 'lwc';
import askGemini from '@salesforce/apex/ips_GeminiController.askGemini';

export default class GeminiAssistant extends LightningElement {

    @api recordId;
    question = '';
    error = '';
    isLoading = false;
    @track messages = [];
    messageCounter = 0;

    connectedCallback() {
        this.messages = [
            {
                id: ++this.messageCounter,
                text: 'How can I help you with your case today?',
                cssClass: 'message-row bot-message'
            }
        ];
    }

    handleChange(event) {
        this.question = event.target.value;
    }

    async sendMessage() {

        if (!this.question || !this.question.trim()) {
            return;
        }

        const userQuestion = this.question;

        this.error = '';

        // Add user message
        this.messages = [
            ...this.messages,
            {
                id: ++this.messageCounter,
                text: userQuestion,
                cssClass: 'message-row user-message'
            }
        ];

        this.question = '';
        this.isLoading = true;

        try {

            const result = await askGemini({
                question: userQuestion,
                caseNumber: this.recordId
            });

            // Add Gemini response
            this.messages = [
                ...this.messages,
                {
                    id: ++this.messageCounter,
                    text: result,
                    cssClass: 'message-row bot-message'
                }
            ];

        } catch (err) {

            console.error(err);

            this.error =
                err?.body?.message ||
                err?.message ||
                JSON.stringify(err);

            this.messages = [
                ...this.messages,
                {
                    id: ++this.messageCounter,
                    text: 'Sorry, an error occurred while getting a response.',
                    cssClass: 'message-row bot-message'
                }
            ];

        } finally {
            this.isLoading = false;
        }
    }

    handleKeyDown(event) {
        if (event.key === 'Enter') {
            this.sendMessage();
        }
    }
}