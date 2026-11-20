import { LightningElement, api, wire,track} from 'lwc';
//import iconLabel from '@salesforce/label/c.Core_SA_IconPath';
//import iconLabel from '@salesforce/label/c.Core_AccountPulse_IconPath';
//import getCustomSettings from '@salesforce/apex/Core_GenerateAccountSummary.getCustomSettingsUserWWID';
//import Id from '@salesforce/user/Id';
//import makePostRequest from '@salesforce/apex/Core_GenerateAccountSummary.makePostRequest';
//import aPLabel from "@salesforce/label/c.CRM_AccountPulse_Label";


export default class Core_GenerateAIPoweredAccountSummaryComp extends LightningElement {
    //@api icon = iconLabel;
    @api modalOpen = false;
    //@api userId = Id;
    @api recordId;
    @api action = 'has_summary';
    //@api result;
    @track result = null; // Initially null to indicate no result yet
    @track isLoading = true; // Initially true to indicate loading state

    @api icon;
    userWWID;
    //label = {aPLabel};

    /*@wire(getCustomSettings,{}  )
    myCustomSettings({ error, data }){
    if(data){
        this.details = data; 
        this.icon = this.details.customSetting;
        this.userWWID = this.details.userWWID;
        console.log('updateddata'+this.icon+this.userWWID);  
        this.callout();                        
    } else if (error) {
        console.log('An error has occurred:');
        console.log(error);
        // handle your error.
    }
    
    }   

callout(){
    makePostRequest({ recordId: this.recordId, userId: this.userId, action: this.action,  userWWID: this.userWWID })
    .then(response => { 
            this.result = response;
           console.log('response after making callout '+response+this.userWWID+this.recordId+this.userId+this.userWWID);
        })
        .catch(error => {
           console.error('HTTP Callout Error:', error);
           this.result = false;
        })
        .finally(() => {
            this.isLoading = false; // Set loading to false after the call is complete
        });
}*/

    /*handleClick() {
        this.modalOpen = true;				
		}
    modalClose(){
        this.modalOpen = false;
    } */
}