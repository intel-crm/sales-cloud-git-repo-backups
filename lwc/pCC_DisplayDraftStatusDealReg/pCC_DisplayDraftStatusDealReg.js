import { LightningElement, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getDRStatus from "@salesforce/apex/PCC_Submit_DesignRegistrationController.getDRStatus";
import PCC_DraftStatusMessage from '@salesforce/label/c.PCC_DraftStatusMessage';
import PCC_DealDraftStatusMessage from '@salesforce/label/c.PCC_DealDraftStatusMessage';

//import hasDealRegPermissionSet from '@salesforce/apex/PCC_fetchDealPermissionSet.hasDealPermissionSet';
import fetchUserPermissions from '@salesforce/apex/Core_DDR_Design_Handler_Utility.fetchUserPermissions';


export default class PCC_DisplayDraftStatusDealReg extends LightningElement {
    @api recordId;
    label = {
        PCC_DraftStatusMessage,
        PCC_DealDraftStatusMessage,
    };
    displayText = false;
    displayDealStatus = false;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            console.log('currentPageReference:', currentPageReference);
        
            this.recordId = currentPageReference.attributes.recordId;
            console.log('recordId:', this.recordId);
        }
    }

    connectedCallback() {
        this.fetchDRStatus();
       // this.checkDealRegPermissionSet();
       
    }

    fetchDRStatus() {
        console.log('recccc iddddddddddd',this.recordId);
        getDRStatus({ recId: this.recordId })
            .then(result => {
                console.log('result in status--',result);
                if(result==true){
                    this.checkPermissionSet();
                //this.displayText = result;
                }
            })
            .catch(error => {
                // Handle error
                console.error(error);
                console.log('Error in fetching status');
            });
        }
        
        checkPermissionSet(){
            fetchUserPermissions()
            .then(data =>{
            console.log('data in second-----',data[0].permissionSets[0].includes('PCC_Deal_Reg_Partner_Access'));
            if(data[0].permissionSets[0].includes('PCC_Deal_Reg_Partner_Access')){
                console.log('Deal reg in Draft status');
                this.displayDealStatus =true;    
            }else if(data[0].permissionSets[0].includes('Core_DDR_Permission_Set')){
                console.log('Design reg in Draft status');
                this.displayText = true;
            }
        })
    }
            
    

    // checkDealRegPermissionSet(){
    //     hasDealRegPermissionSet()
    //     .then(data =>{
    //         console.log('data-----',data);
    //         if(data.includes('PCC_Deal_Reg_Partner_Access')){
    //             console.log('Deal Reg is in Draft Status');
    //         }
    //     })

    // }
}