import { LightningElement } from 'lwc';
import getRecordsToApprove from '@salesforce/apex/Core_MDF_IUPGM_ApprovalRequest.getRecordsToApproveForHomePage';
import getValidationMessage from '@salesforce/apex/Core_MDF_IUPGM_ApprovalRequest.getValidationMessage';
import { NavigationMixin } from 'lightning/navigation';
import APPLICATION_ERROR from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Core_MDF_Home_DashBoard extends NavigationMixin(LightningElement) {
        

    approvalRequestJson = [];   
    showSpinner = false; 
    hasContentsToDisplay = false; 
    showMessage;
    connectedCallback() {
        this.getValidationMessage();
        this.getRecordsToApprove();
        
    }
    
    HOME_PAGE_DASHBBOARD_COL_HEADER1;
    HOME_PAGE_DASHBBOARD_COL_HEADER2;
    HOME_PAGE_DASHBOARD_NORECMSG;
    
    

    getValidationMessage() {
        this.showSpinner = true;
        getValidationMessage()
        .then(data => {
            this.showSpinner = false;
            var result = JSON.parse(data);
            this.HOME_PAGE_DASHBBOARD_COL_HEADER1 = result.Core_MDF_Home_Page_Dashboard_Col_Header1;
            this.HOME_PAGE_DASHBBOARD_COL_HEADER2 = result.Core_MDF_Home_Page_Dashboard_Col_Header2;
            this.HOME_PAGE_DASHBOARD_NORECMSG = result.Core_MDF_Home_Page_Dashboard_NoRecMsg;
            this.showMessage=this.HOME_PAGE_DASHBOARD_NORECMSG;
        })
        .catch(error => {
            this.showSpinner = false;
        });
    }
    
    getRecordsToApprove() {
        this.showSpinner = true;
        getRecordsToApprove()
            .then(result => {
                if (result != '') {
                    try{
                        this.approvalRequestJson = JSON.parse(result);
                        if(this.approvalRequestJson != null && this.approvalRequestJson.length > 0){

                            this.approvalRequestJson.forEach(content => {
                             if(content.count > 0){
                                     this.hasContentsToDisplay = true;
                                     this.showMessage='';
                             }
                             
                            });
                     }
                     
                    }
                    catch(e){
                        this.showSpinner = false;
                    }
                    
            }
                else{
                    this.hasContentsToDisplay = false;
                }
                this.showSpinner = false;
            })
            .catch(error => {
                this.showSpinner = false;
                this.hasContentsToDisplay = false;
                if(error!==null && error.hasOwnProperty('body') && error.body.hasOwnProperty('message') && error.body.message.includes('do not have access'))
                {
                    this.showMessage = 'You are not authorized to see this component.';
                }
                else{
                    this.showMessage = APPLICATION_ERROR;
                }

            });
    }

    handleNavigate(){
    this[NavigationMixin.GenerateUrl]({
        type: 'standard__navItemPage',
        attributes: {
            apiName: 'Core_MDF_Approval_Requests',
        }
    }).then(url => {
        window.open(url, "_blank");
    });
  }

  showToastMessage(title, message, variant, mode) {
    this.dispatchEvent(
        new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        })
    );
}
}