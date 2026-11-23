import { LightningElement, api, track } from 'lwc';
import jQuery from '@salesforce/resourceUrl/PSG_Feedback_JQuery';
import { loadScript } from 'lightning/platformResourceLoader';
import getFormDetails from '@salesforce/apex/PSG_FeedbackController.getFormDetails';
import feebackSubmit from '@salesforce/apex/PSG_FeedbackController.feedbackSubmit';	
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FeedbackRatingNotGiven from '@salesforce/label/c.PSG_FeedbackRatingNotGiven';

export default class PSG_Feedback_Form extends LightningElement {
    isEmoji;
    isStar;
    isFormVisible;
    isSubmit;
    feedbackVal='';
    comment ='';
    feedbackType;
    isbuttonvisible=false;
    @track commentLimit = 500;
    @track errorMessage = '';
    @track output= 500;
   
    connectedCallback(){
        getFormDetails()
        .then(result => {
            if(result){
                this.isFormVisible = result['isFormVisible'];
                if(this.isFormVisible){
                    if(localStorage.getItem('firstTimeShow')){
                        console.log('Hit');
                        this.isbuttonvisible = !this.isbuttonvisible;
                        this.isEmoji = result['isEmoji'];
                        this.isStar = result['isStar'];
                    }else{
                        console.log('Hit');
                        localStorage.setItem("firstTimeShow", true);                        
                        this.isEmoji = result['isEmoji'];
                        this.isStar = result['isStar'];
                    }
                }
            }
            window.addEventListener('beforeunload', this.beforeUnloadHandler.bind(this));
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.contacts = undefined;
        });
        
    }
    
    handleCancel(){
        this.isSubmit = false;
    }

    handleFeedbackVal(event){
        this.feedbackVal = event.target.dataset.val;
        this.handleRatingColor();
        this.errorMessage = '';        
    }

    handleRatingColor(){
        console.log("Ok");
        Promise.all([
            loadScript(this, jQuery)
        ]).then(() =>{
                if(this.feedbackVal=='Extremely Unsatisfied'){
                    $(this.template.querySelector('span.fontDesign4')).addClass("fontDesign");
                    $(this.template.querySelector('span.fontDesign3')).removeClass("fontDesign");
                    $(this.template.querySelector('span.fontDesign2')).removeClass("fontDesign");
                    $(this.template.querySelector('span.fontDesign1')).removeClass("fontDesign");
                    $(this.template.querySelector('span.fontDesign0')).removeClass("fontDesign");
                }else if(this.feedbackVal=='Dissatisfied'){
                    $(this.template.querySelector('span.fontDesign3')).addClass("fontDesign");
                    $(this.template.querySelector('span.fontDesign4')).removeClass("fontDesign");
                    $(this.template.querySelector('span.fontDesign2')).removeClass("fontDesign");
                    $(this.template.querySelector('span.fontDesign1')).removeClass("fontDesign");
                    $(this.template.querySelector('span.fontDesign0')).removeClass("fontDesign");
                }else if(this.feedbackVal=='Neutral'){
                    $(this.template.querySelector('span.fontDesign2')).addClass("fontDesign");
                    $(this.template.querySelector('span.fontDesign3')).removeClass("fontDesign");
                    $(this.template.querySelector('span.fontDesign4')).removeClass("fontDesign");
                    $(this.template.querySelector('span.fontDesign1')).removeClass("fontDesign");
                    $(this.template.querySelector('span.fontDesign0')).removeClass("fontDesign");
                }else if(this.feedbackVal=='Satisfied'){
                    $(this.template.querySelector('span.fontDesign1')).addClass("fontDesign");
                    $(this.template.querySelector('span.fontDesign3')).removeClass("fontDesign");
                    $(this.template.querySelector('span.fontDesign2')).removeClass("fontDesign");
                    $(this.template.querySelector('span.fontDesign4')).removeClass("fontDesign");
                    $(this.template.querySelector('span.fontDesign0')).removeClass("fontDesign");
                }else if(this.feedbackVal=='Extremely Satisfied'){
                    $(this.template.querySelector('span.fontDesign0')).addClass("fontDesign");
                    $(this.template.querySelector('span.fontDesign3')).removeClass("fontDesign");
                    $(this.template.querySelector('span.fontDesign2')).removeClass("fontDesign");
                    $(this.template.querySelector('span.fontDesign1')).removeClass("fontDesign");
                    $(this.template.querySelector('span.fontDesign4')).removeClass("fontDesign");
                }
        });
    }

    handeleComment(event){
            this.comment=event.target.value;
            this.output = this.commentLimit - (this.comment.length);
    }

    handleFeedbackSubmit(event){
        this.feedbackType = event.target.dataset.id;
        if(this.feedbackType !='Skipped'){
             if(this.feedbackVal==''){ 
                    this.errorMessage = '⚠ ' + FeedbackRatingNotGiven;
             }else{
                feebackSubmit({feedbackRating: this.feedbackVal,feedbackComment: this.comment,feedbackType: this.feedbackType})
                .catch(error =>{
                    this.error=error;
                });
                this.isStar = false;
                this.isEmoji = false;
                this.isSubmit = true;
                const evt = new ShowToastEvent({
                    title: 'Feedback Submitted',
                    message: 'Thank you for your valuable feedback.',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                localStorage.removeItem("firstTimeShow");
             }
                 
        }else{
            feebackSubmit({feedbackRating: '',feedbackComment: '',feedbackType: this.feedbackType})
            .catch(error =>{
                this.error=error;
            });
            this.isStar = false;
            this.isEmoji = false;
            localStorage.removeItem("firstTimeShow");
        }
    }

    Buttonvisibility(){
        this.isbuttonvisible=!this.isbuttonvisible;
        this.feedbackVal='';
        this.comment='';
        this.errorMessage = '';
        this.output= 500;
    }

    beforeUnloadHandler(event) {
        localStorage.removeItem("firstTimeShow");
    }
}