import { LightningElement,wire,track } from 'lwc';
//import getSubmittedRecords from '@salesforce/apex/Core_MDF_Approval_Request_POC55.getSubmittedRecords';
import getApprovalRecords from '@salesforce/apex/Core_MDF_ApprovalReqsController.getSubmittedRecords';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';

export default class Core_MDF_Approval_Requests extends NavigationMixin(LightningElement) {
    @track PhoneOrDesktop;
    @track error;
    @track recordsToRender = [];
    @track formFactor;
    formFactor = formFactorPropertyName;
    @track phoneOrDesktop;

    @wire(getApprovalRecords)
    wiredAccounts({error, data}) {
        if (data) {
            this.recordsToRender = JSON.parse(data);
            console.log(JSON.parse(data));
        } else if (error) {
            this.error = error;
        }
        console.log('Total Records Length=> '+ this.recordsToRender.length);
    }
    handleClick(event){
        var selectedRecId = '';
        let isNavigateToStandardPage = false;
        selectedRecId = event.target.dataset.recordId;
        //let processInstWIRecs = [];
        //processInstWIRecs = this.recordsToRender;
        let selRecId = selectedRecId.substring(1);
        console.log('All Recs => '+JSON.stringify(this.recordsToRender));
        for(let i = 0; i <this.recordsToRender.length; i++){

            if (this.recordsToRender[i].recordId == selRecId && this.recordsToRender[i].naviagteToStandardPage) {
                isNavigateToStandardPage = true;
                break;
            }
        }
        console.log('Navigate to standard Page Check => '+isNavigateToStandardPage);
        alert('Selected Rec Id => '+selRecId);
        if(isNavigateToStandardPage) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: selRecId,
                    objectApiName: 'ProcessInstanceWorkItem',
                    actionName: 'view'
                }
            });            
        }else{
            this[NavigationMixin.Navigate]({
                type: "standard__component",
                attributes: {
                    componentName: "c__Core_MDF_navAuraCmp"
                },
                state: {
                    c__recId: selectedRecId
                }
            });
            console.log('Outside Navigation');
        }        
    }
}