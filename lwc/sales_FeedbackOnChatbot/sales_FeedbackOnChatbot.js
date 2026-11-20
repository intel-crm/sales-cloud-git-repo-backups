import { api, LightningElement,track,wire } from 'lwc';
/*import getFeedRecordchatbot from '@salesforce/apex/Sales_FeedbackController.getFeedRecordchatbot';//added for feedback
import checkCapablity from '@salesforce/apex/Sales_FeedbackController.checkCapablity';//added for feedback
*/
export default class Sales_FeedbackOnChatbot extends LightningElement {

    /*@api isFeedbackvisible=false;
    @track noofdays;
    @track iscapablity=false;
    ischatbot='chatbot';//added for chatbot feedback
    capablity='License Chatbot';
    @track fromchatbotvaalue=true;
    @track fromchatbotvariable=false;
   

    @wire(checkCapablity, {capablity : '$capablity'})
    checkCapablity({error,data}){
        if(data){
           console.log('capability available>'+data);
           this.iscapablity=data;
           this.getFeedbackRecords();    
        if(error){
        }
    }
}
 connectedCallback(){
   
}  
 
 

 getFeedbackRecords(){
    getFeedRecordchatbot({feedbackchatbot:this.fromchatbotvaalue})
        .then((result) => {
            this.feedrec = result;
            console.log('feed back records length>>'+ JSON.stringify(this.feedrec));
            console.log("This is data"+this.feedrec.Last_Feedback_Captured__c);
            this.noofdays=this.feedrec.Last_Feedback_Captured__c;
            this.fromchatbotvariable=this.feedrec.Chatbot_Feedback__c;
            console.log("this.noofdays>>"+this.noofdays);
            if((this.noofdays>89) && this.iscapablity==true && this.fromchatbotvariable==true){
            console.log('capability value'+this.iscapablity+'from chatbot variable'+this.fromchatbotvariable);   
            this.isFeedbackvisible=true;
            console.log('feedback component visible');
            } 
             else{
                console.log('inside else isFeedbackvisible>>>'+this.isFeedbackvisible);   
                this.isFeedbackvisible=false;
            }
            
        })
        .catch((error) => {
            console.log('imperative existing feedback>>>'+JSON.stringify(error) +'this.iscapablity>>'+this.iscapablity);
            if(this.iscapablity==true){
                this.isFeedbackvisible=true;
            }
        });
       
}
closeFeedback() {
    console.log('cancel feedback');
    this.isFeedbackvisible=false;
}*/


}