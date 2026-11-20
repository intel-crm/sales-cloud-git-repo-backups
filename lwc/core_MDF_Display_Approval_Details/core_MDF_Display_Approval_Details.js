import { api,LightningElement, track } from 'lwc';
import getApprovalDetails from '@salesforce/apex/Core_MDF_Display_Approval_Details.getApprovalDetails';
//import Core_MDF_ApprovalStageComplete from '@salesforce/resourceUrl/Core_MDF_ApprovalStageComplete'; 
export default class Core_MDF_Display_Approval_Details extends LightningElement {

showSpinner = false;
@track displayContent = [];
@api recordId;
//svgURL = `${Core_MDF_ApprovalStageComplete}`;
dataAvailable = false;

connectedCallback(){
        this.getApprovals();
}

getApprovals() {
                this.showSpinner = true;
                getApprovalDetails({recordId : this.recordId})
                        .then(data => {
                                this.displayContent.push(data);
                               this.showSpinner = false;
                               if(this.displayContent[0].stageWrapperList.length>0){
                               this.dataAvailable = true;
                               }
                               else{
                                this.dataAvailable = false;
                               }
                        })
                        .catch(error => {
                                this.showSpinner = false;
                        });
        }
}