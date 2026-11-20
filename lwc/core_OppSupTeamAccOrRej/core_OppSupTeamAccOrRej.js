import { LightningElement ,wire,api} from 'lwc';
import { getRecord,updateRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import ID_FIELD from '@salesforce/schema/Core_Opportunity_Support_Team__c.Id';
import SUPPORT_STATUS from '@salesforce/schema/Core_Opportunity_Support_Team__c.Core_Status__c';
import getUserFromOppSupTeam from "@salesforce/apex/Core_OppSupTeamAccOrRej.checkUserformOppteam";
import updateOppSupTeam from "@salesforce/apex/Core_OppSupTeamAccOrRej.updateStatusOppRequestTeam";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Core_OppSupTeamAccOrRej extends LightningElement {
        
    
    @api recordId;
    showAccOrdenied = false;
    supporRequest = '';
    isModalOpen = false;
    singleDataShow;
    userComments = '';
    coeRecord = false;
    tssRecord = false;
    csaRecord = false;
    csaTSSfields = false;
    addnullForemptyvalues = '  ';


    @wire(getUserFromOppSupTeam,{userID:USER_ID})
    resultData({error,data}){
        console.log('data--'+data);
       if (data != null  && data.length > 0) {  
        console.log('data lenght--'+ data.length);          
                this.showAccOrdenied = true;
                this.supporRequest = data;
                //this.singleDataShow = data[0];
            console.log('return data'+ JSON.stringify(data));
        }
           else {
            console.log('Not record found');
        } 
    } 
    detailview(event){
        this.isModalOpen= true; 
        this.coeRecord = false;
        this.tssRecord = false;
        this.csaRecord = false;
        this.csaTSSfields = false;
        var recordID = event.target.dataset.oppsupid;
        //alert('event.target.id'+event.target.dataset.oppsupid);
        this.singleDataShow =    this.supporRequest.find(record => record.Id === recordID) ;  
        console.log('data----'+JSON.stringify(this.singleDataShow)); 
        if(this.singleDataShow.Core_Opportunity_Support__r.RecordType.DeveloperName == 'Core_Center_of_Excellence_Request' )
            this.coeRecord = true;
        if(this.singleDataShow.Core_Opportunity_Support__r.RecordType.DeveloperName == 'Core_CSA_RecordType' )
            this.csaRecord = true;
        if(this.singleDataShow.Core_Opportunity_Support__r.RecordType.DeveloperName == 'Core_TSS_Request' )
            this.tssRecord = true;
        if(this.tssRecord || this.csaRecord )
            this.csaTSSfields= true;
        //this.displaymessage('warning','Please privode comments before Accept / Deny','warning');
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
      
    handleAccept(event) {   
        var buttonName = event.target.value;  
        this.updateStatus('Accepted',buttonName);
       
    }

    handleDeny(event) {
        var buttonName = event.target.value;       
        this.updateStatus('Denied',buttonName);
      
    }

    updateStatus(statusvalue,id){
        var allTextAreaValid = [...this.template.querySelectorAll('lightning-textarea')]
        .reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
       
        
         if(allTextAreaValid){
            console.log('single data view --'+ JSON.stringify(this.singleDataShow));
            updateOppSupTeam({
                status: statusvalue,
                recordID: id,
                comments: this.userComments,
                OppSupTeam: this.singleDataShow
            }).then(result => {
                var variantValue = (statusvalue == 'Accepted' ? 'success' : 'Error');
                this.displaymessage('','Opportunity Support Request '+statusvalue,'success');            
                this.supporRequest = this.supporRequest.filter(obj => obj.Id !== id);

                if(this.supporRequest.length <= 0)
                    this.showAccOrdenied = false;
                this.closeModal();

            }).catch(error => {
                this.closeModal();
                this.displaymessage('Error while '+statusvalue + ' Status',JSON.stringify(error),'error');
            });
        }
    }

    handleInputChange(event) {
        
        const fieldName = event.target.name;
        const value = event.target.value;
        if (fieldName === 'Comments') {
            this.userComments = value;
        }
        console.log('commnets@@ --'+ this.userComments);
       

    }
          
    //Displays message
    displaymessage(title,message,variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }),
        );
    }
}