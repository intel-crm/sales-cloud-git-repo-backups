import { LightningElement,track,api, wire } from 'lwc';
import getOptions from '@salesforce/apex/Core_IPS_CaseCommentLWCController.getVisibilityOptions';
import postCaseComment from '@salesforce/apex/Core_IPS_CaseCommentLWCController.saveCaseComment';
import showVisibilityOptions from '@salesforce/apex/Core_IPS_CaseCommentLWCController.showVisibilityOptions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AddCaseComments extends LightningElement {
    @api recordId;
    @track options;
    @track comments = '';

    @wire(getOptions, {caseId : '$recordId' }) 
    wiredSurvey({ data, error }) {
        if(data) {
            let optionsValues = [];
            window.console.log('data ===> '+JSON.stringify(data));
            for(let i = 0; i < data.length; i++) {
                window.console.log(data[i]);  
                optionsValues.push({
                    label: data[i],
                    value: data[i]
                })
            }
            this.options = optionsValues;
            window.console.log('optionsValues ===> '+JSON.stringify(optionsValues));
        }
        else if(error) {
            window.console.log('error ===> '+JSON.stringify(error));
        }
    }

    @wire(showVisibilityOptions) rendervisibilityPicklist;
   
    @track formats = ['font', 'size', 'bold', 'italic', 'underline',
       'strike', 'list', 'indent', 'align', 'link', 'blockquote', 'direction', 'code-block',
       'image', 'clean', 'table', 'header', 'color', 'background', 'script', 'code' ];



      handlePicklistChange(event) {
        this.visibilityValue = event.detail.value; 
        console.log('this.visibilityValue '+ this.visibilityValue);
    }
    
    handleRichTextChange(event) {
        this.comments = event.detail.value;
        console.log('this.comments '+ this.comments);
    }
    postComment() {
        console.log('postComment::: postComment');
       
        postCaseComment({caseId :this.recordId , visibility : this.visibilityValue , comment : this.comments  })
       .then(data => {
    
           if (data) {
               this.message = data;
               this.errors = undefined;
               console.log('repose data '+ data);

               const event = new ShowToastEvent({
                title: 'Success',
                message: 'Comment on case posted successfully.',
                variant: 'success'
            });
            this.dispatchEvent(event);

           }
           
       })
       .catch(error => {
           console.error('caseAttachmentUpload::: Error in getting URL. Error : ', JSON.stringify(error));
           this.response = undefined;
               this.errors = error;
           
               const event = new ShowToastEvent({
                title: 'Erro',
                message: 'Error while posting comment.',
                variant: 'error'
            });
            this.dispatchEvent(event);

       })
    
    }
    
}