import { LightningElement,api,wire,track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import WarningLabel from "@salesforce/label/c.UCD_AccountTeams_warningMessage";




import getAccountCategory from "@salesforce/apex/UCD_ACM_AccountTeamCategory.getAccountCategory";


export default class UCD_ACM_AccountTeam extends LightningElement {

@api recordId; 
@track messageForDisplay = '';
@track WarningLabelValue = WarningLabel ;

 connectedCallback(){
    getAccountCategory({accountId:this.recordId}).then(response => {
        this.messageForDisplay = response;
        if(this.messageForDisplay != null && this.messageForDisplay != ''){
            this.messageForDisplay = response;
            //this.showNotification();
        }
    })

    .catch(error => {

    })

    }


    showNotification() {


        const evt = new ShowToastEvent({
          title: this.WarningLabelValue,
          message: this.messageForDisplay,
          variant: 'error',
        });
        this.dispatchEvent(evt);
    }
//System.Label.UCD_AccountTeams_warningMessage
 }