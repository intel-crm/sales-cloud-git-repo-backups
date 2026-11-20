import { LightningElement, api } from 'lwc';
/*import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import getLicenseHostId from '@salesforce/apex/Sales_GetComputerDetailsForCompanion_bot.getLicenseHostId';
import compErrormessage from '@salesforce/label/c.Sales_AssignPrimaryCompErr';
import errorMsg from '@salesforce/label/c.Sales_Error_Message'; 
import userId from '@salesforce/user/Id';
//import validateUserAccess from '@salesforce/apex/Sales_ValidateUserEditAccess.validateUserAccess';
import Sales_AccessCheckMsg from '@salesforce/label/c.Sales_AccessCheckMsg';

//import propertyName from '@salesforce/community/property';
//import communityId from '@salesforce/community/Id';
//import communityBasePath from '@salesforce/community/basePath';
import { CurrentPageReference } from 'lightning/navigation';
*/

export default class SalesGenerateCompanionLicense extends LightningElement {
        @api recordId;
        /*@api licPrimaryComputerId;
        @api currentPageReference;
        @track userId=userId;
        @wire(CurrentPageReference)
        setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        console.log('pgref@@@'+ JSON.stringify(this.currentPageReference));}
          
        label={
                compErrormessage,
                errorMsg,
                Sales_AccessCheckMsg
              } 

        connectedCallback() {
                console.log('@@recordId' + this.recordId);
                console.log('824');
                validateUserAccess({ userID: this.userId, recordId: this.recordId })
                        .then((result) => {
                                console.log('result =' + result);
                                if (result == false) {
                                        console.log('user doesnt have access to the record');
                                        //this.closeQuickAction();
                                        const evt = new ShowToastEvent({
                                                variant: 'error',
                                                title: 'Failure',
                                                mode: 'sticky',
                                                message: this.label.Sales_AccessCheckMsg,
                                        });
                                        //
                                        //this.fireToastEvent('Failure!','You cannot modify this record !! ','error','Sticky');
                                        this.dispatchEvent(evt);
                                        this.dispatchEvent(new CustomEvent('close'));
                                }
                                else{
                                /*getLicenseHostId({ recId: this.recordId })
                                        .then((result) => {
                                                console.log('result--?>' + result);
                                                this.licPrimaryComputerId = result;
                                                //if computer is not associated to license show error that please assign computer
                                                if (this.licPrimaryComputerId == null) {
                                                        this.closeQuickAction();
                                                       this.fireToastEvent(this.label.errorMsg, this.label.compErrormessage, 'error', 'sticky');
                                                }
                                                else {
                                                        this.closeQuickAction();
                                                        this.openpage(this.licPrimaryComputerId);       //if computer is there navigate to that computer record
                                                }
                                        })
                                        .catch((error) => {
                                                this.closeQuickAction();
                                                this.fireToastEvent('Error!', error.body.message, 'error', 'sticky');
                                        });*/
                                /*}
                        /*})
        }
        generateUrls() {
                this[NavigationMixin.GenerateUrl](this.showPanelPageReference)
                    .then(url => this.showPanelUrl = url);
                this[NavigationMixin.GenerateUrl](this.noPanelPageReference)
                    .then(url => this.noPanelUrl = url);
            }

        //method to Navigate to computer record in new Tab
        openpage(primCompId) {
                //window.open(window.location.origin + '/' + primCompId, '_top');
                //window.open('/' + primCompId, '_blank');  
                //if(User.ProfileId=='Partner')
                //window.open('https://licensing.intel.com/psg/detail/'+primCompId) ; 
               //else
               //if( isLightningExperienceOrSalesforce1() ) {
                // Do something for Lightning Experience
                //this.sfdcBaseURL = window.location.origin;
               // console.log('pagerefrernc@@@'+pageRef);
               if(JSON.stringify(window.location.origin ).includes('.lightning.'))
               { console.log(window.location.origin);
                window.open(window.location.origin+'/' + primCompId, '_blank');        
               }
               else
               {//console.log('location@@@'+JSON.stringify(window.location.href).split('/s/')[0].split('"'));
                //window.open(JSON.stringify(window.location.href).split('s/')[0].split('"') + primCompId, '_blank');
                console.log('final approach'+JSON.parse(JSON.stringify(JSON.parse(JSON.stringify(window.location.href))).split('s/')[0]+'"')+primCompId, '_blank');
                window.open(JSON.parse(JSON.stringify(JSON.parse(JSON.stringify(window.location.href))).split('s/')[0]+'"')+primCompId, '_blank');
        }
                
                //console.log('pagerefrernc@@@'+pageRef);
           // }
           // else if(communityBasePath=='intelcloudcrm.cs69.force.com/psg/s')
           /* Network psgQuotingLicensing = [SELECT Id, Name, UrlPathPrefix FROM Network where Name = 'PSG Quoting and Licensing' Limit 1];
            String communityName = 'YourCommunityName';
SELECT Name, UrlPathPrefix FROM Network WHERE Name = :communityName;
        String pageURL = Network.getLoginUrl(psgQuotingLicensing.Id).removeEndIgnoreCase('login') + 'detail/' + primCompId;*/
            /*else*/
            //window.open('https://licensing.intel.com/psg/detail/'+primCompId) ;
        /*}

        fireToastEvent(title, message, variant, mode) {
                const event = new ShowToastEvent({
                        title: title,
                        message: message,
                        variant: variant,
                        mode: mode
                });
                this.dispatchEvent(event);
        }

        reloadPage() {
                setTimeout(function () {
                        //eval("$A.get('e.force:refreshView').fire();");
                        location.reload(true);
                }, 2000);
                /*window.setTimeout(function(){ 
                        location.reload(true);
                }, 2000);*/
        /*}

        closeQuickAction() {
                const closeModal = new CustomEvent('close');
                // Dispatches the event.
                this.dispatchEvent(closeModal);
        }*/
}