import { LightningElement, track } from 'lwc';
import createTicket from '@salesforce/apex/SupportTicketAIController.createTicket';

export default class SupportTicketAI extends LightningElement {

    @track userInput = '';
    @track fileData;
    @track recordId;
    @track error;

    handleInput(event) {
        this.userInput = event.target.value;
    }

    handleFileUpload(event) {
        const file = event.target.files[0];

        const reader = new FileReader();
        reader.onload = () => {
            this.fileData = reader.result.split(',')[1]; // base64
        };
        reader.readAsDataURL(file);
    }

    handleSubmit() {
        createTicket({
            userInput: this.userInput,
            base64File: this.fileData
        })
        .then(result => {
            this.recordId = result;
            this.error = undefined;
        })
        .catch(error => {
            this.error = error.body.message;
            this.recordId = undefined;
        });
    }
}