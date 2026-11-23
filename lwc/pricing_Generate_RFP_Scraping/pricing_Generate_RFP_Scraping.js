import { LightningElement, api, track, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import updateQuoteStatus from '@salesforce/apex/Pricing_RFP_Scraping_AI_Integration.updateQuoteStatus';
import checkRFPDocumentExists from '@salesforce/apex/Pricing_RFP_Scraping_AI_Integration.checkRFPDocumentExists';
import fetchQuoteDetails from '@salesforce/apex/Pricing_RFP_Scraping_AI_Integration.fetchQuoteDetails';
import getQuoteDocuments from '@salesforce/apex/Pricing_RFP_Scraping_AI_Integration.getQuoteDocuments';

export default class Pricing_Generate_RFP_Scraping extends LightningElement {
    //@api recordId;
    @track isLoading = false;
    @track showProceedDialog = true;
    @track documentOptions = [];
    @track selectedDocuments = [];
    @track selectionError = false;

    @api
    set recordId(value) {
        this._recordId = value;

        if (value && !this.isInitialized) {
            this.isInitialized = true;
            console.log('recordId received:', value);
            this.loadDocuments();
        }
    }

    get recordId() {
        return this._recordId;
    }
    async handleNext() {
        console.log('Inside handleNext',JSON.stringify(this.selectedDocuments));
        console.log('Inside handleNext',this.selectedDocuments.length);
    // Validation - At least one document must be selected
    if (!this.selectedDocuments || this.selectedDocuments.length === 0) {
        console.log('Aswin inside handle next');
        this.selectionError = true;

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Required',
                message: 'Please select at least one document.',
                variant: 'error'
            })
        );
        return;
    }

    this.selectionError = false;

    try {
        console.log('INSIDE RFP SCRAPING JS HANDLENEXT : ' + this._recordId);
        console.log('Selected Documents : ', JSON.stringify(this.selectedDocuments));

        this.isLoading = true;

        // Optional validation if you still want to verify documents exist
        const rfpDocumentsMap = await checkRFPDocumentExists({
            quoteIds: [this._recordId]
        });

        const hasRFPDocuments =
            rfpDocumentsMap[this._recordId] &&
            rfpDocumentsMap[this._recordId].length > 0;

        if (!hasRFPDocuments) {
            this.showRFPDocumentMissingToast();
            return;
        }

        // Update Quote Status
        await updateQuoteStatus({
            quoteIds: [this._recordId]
        });

        await getRecordNotifyChange([
            { recordId: this._recordId }
        ]);

        // Pass selected document ids to Apex
        await fetchQuoteDetails({
            quoteIds: [this._recordId],
            selectedDocumentIds: this.selectedDocuments
        });

        await getRecordNotifyChange([
            { recordId: this._recordId }
        ]);

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Agentic RFP Generation started successfully!',
                variant: 'success'
            })
        );

        this.dispatchEvent(new CloseActionScreenEvent());

    } catch (error) {
        console.error('Error in pricing generate scraping lwc:', error);

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: error?.body?.message || error?.message || 'Unknown error occurred',
                variant: 'error'
            })
        );

        this.dispatchEvent(new CloseActionScreenEvent());

    } finally {
        this.isLoading = false;
    }
}
    isInitialized = false;

    renderedCallback() {
        console.log('inside recordId available:')
        if (!this.isInitialized && this._recordId) {
            this.isInitialized = true;

            console.log('recordId available:', this._recordId);

            this.loadDocuments();
        }
    }

    async loadDocuments() {
        console.log('Inside loadDocuments');
        try {
            console.log('Inside loadDocuments1',[this._recordId]);
            const docs = await getQuoteDocuments({
                quoteId: [this._recordId]
            });
            console.log('Returned Docs:', JSON.stringify(docs));
            this.documentOptions = docs.map(doc => ({
                label: doc.Title,
                value: doc.ContentDocumentId
            }));

            // Optional: preselect first document
            if (this.documentOptions.length > 0) {
                this.selectedDocuments = [
                    this.documentOptions[0].value
                ];
            }

        } catch(error) {
            console.error('Error loading documents', error);
        }
    }
    handleDocumentSelection(event) {
    const selected = event.detail.value;

    if(selected.length === 0) {
        this.isLoading = true;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Required',
                message: 'At least one document must be selected.',
                variant: 'warning'
            })
        );

        return;
    }
    this.isLoading = false;
    this.selectedDocuments = selected;
    }

    async agenticBriefGeneration() {
        try {
            const quoteRecIds = [this._recordId];
            //fetchQuoteDetails
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