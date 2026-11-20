import { LightningElement, api, track, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import updateQuoteStatus from '@salesforce/apex/Pricing_RFP_Scraping_AI_Integration.updateQuoteStatus';
import checkRFPDocumentExists from '@salesforce/apex/Pricing_RFP_Scraping_AI_Integration.checkRFPDocumentExists';
import fetchQuoteDetails from '@salesforce/apex/Pricing_RFP_Scraping_AI_Integration.fetchQuoteDetails';


export default class Pricing_Generate_RFP_Scraping extends LightningElement {
    @api recordId;
    @track isLoading = false;
    @track showProceedDialog = true;

    async handleNext() {
            
        try{
            console.log('INSIDE RFP SCRAPING JS HANDLENEXT'+this.recordId);
            //Check if RFP Document exists
            const rfpDocumentsMap = await checkRFPDocumentExists({quoteIds: [this.recordId]});
            console.log('RFP DOCUMENTS MAP:', rfpDocumentsMap);
        
            // Check if the quote has any RFP documents
            const hasRFPDocuments = rfpDocumentsMap[this.recordId] && rfpDocumentsMap[this.recordId].length > 0;
            console.log('Has RFP Documents:', hasRFPDocuments);

            if(!hasRFPDocuments){
                        this.showRFPDocumentMissingToast();
                        return;
            }
            this.isLoading = true;

            const quoteRecIds = [this.recordId];
            
            const quoteStatusUpdate = await updateQuoteStatus({ 
                    quoteIds: quoteRecIds 
                });

            await getRecordNotifyChange([{recordId: this.recordId}]);

                await this.agenticBriefGeneration();

                await getRecordNotifyChange([{recordId: this.recordId}]);
                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Agentic RFP Generation started successfully!',
                        variant: 'success'
                    })
                );
                
                this.dispatchEvent(new CloseActionScreenEvent());

        } catch (error) {
            console.log('Error in pricing generate scraping lwc:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'An error occurred: ' + (error.body?.message || error.message),
                    variant: 'error'
                })
            );
            this.dispatchEvent(new CloseActionScreenEvent());
        } finally {
            this.isLoading = false;
        }
    }

    async agenticBriefGeneration() {
        try {
            const quoteRecIds = [this.recordId];
            
            // Call the fetchQuoteDetails method
            await fetchQuoteDetails({ 
                quoteIds: quoteRecIds 
            });
            
            console.log('fetchQuoteDetails method called successfully');
            
        } catch (error) {
            console.log('Error in agenticRFPGeneration:', error);
        }
    }
        
    showRFPDocumentMissingToast() {
        this.dispatchEvent(
            new ShowToastEvent({
               title: 'RFP Document Missing',
                message: "Please upload a document to summarize.",
                variant: 'error'
            })
        );
        
      this.dispatchEvent(new CloseActionScreenEvent());
    }
}