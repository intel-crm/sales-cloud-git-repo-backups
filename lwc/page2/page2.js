import { LightningElement,wire,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { NavigationMixin } from 'lightning/navigation';
import SalesSerialError from '@salesforce/label/c.Sales_SerialError';
import Sales_Statuserror  from '@salesforce/label/c.Sales_LicenseStatusError';
import SalesAddSeatRenewError from '@salesforce/label/c.Sales_AddSeatRenewError';
//import Sales_Err from '@salesforce/apex/Sales_FeedbackController.Sales_Err';//added for feedback
import Sales_Err from '@salesforce/label/c.Sales_Err';
import userId from '@salesforce/user/Id';
import TermsCondition from '@salesforce/label/c.TermsCondition';
import TermsCondition_Optin from '@salesforce/label/c.TermsCondition_Optin';
import licensefileGeneration from '@salesforce/apex/Sales_LicenseGenIntegration_Utility.returnHostIdDetail';
import { getRecord } from 'lightning/uiRecordApi';
import getHosts from '@salesforce/apex/Sales_FreeLicenseProvider.getHosts';
import createLicNew from '@salesforce/apex/Sales_FreeLicenseProvider.createLicNew';
import { refreshApex } from '@salesforce/apex';
const FIELDS = [ 'Sales_License__c.Id', 'Sales_License__c.Sales_License_Web_Display_Flag__c','Sales_License__c.Sales_Tool_License_Type__c','Sales_License__c.Sales_License_Activation_Code__c','Sales_License__c.Sales_License_Host_Node_Id__c','Sales_License__c.Sales_License_Primary_Admin_Contact__c','Sales_License__c.Sales_License_Lic_User_Contact_ID__c','Sales_License__c.Sales_License_Type__c','Sales_License__c.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c','Sales_License__c.Sales_License_Status__c'];
export default class Page2 extends NavigationMixin(LightningElement) {
    @api fromlac;
    @track userId=userId;
    @api licensetypevalue;
    @api primarycontact;
    @api tooltype;//added for tool type
    @api licusercontact;
    @api recordId;
    @track showModal=true;
    @api licneserecordid;
    @api activatecodeonload;
    @api licenseType;
    @track createComputer= false;
    @api toollicensetype;
    @api primaryadmincontact;
    @api isInternal;
    @api webdisplayFlag;
    @api fromcmp;
    @api licstatus;
    //feedback start
    @track licensestatus;
    @track buttonClicked=false;//added for disabling user from clicking generate license button twice
	@track bypassRehostStatus=false;
    termsAccepted=false;
    termsCondition;
    @track isGenerateButtonDisabled = 'true';
    @track showTable = false;
    @track result;
    @api uniqueId = 'radio-' + Math.random().toString(36).substring(7);
    @api existingcomputername;
    @api hostid;
    @track enableFeedback=false;
    @track isFeedbackvisible=false;
    @api disablefeedback=false;
    @api isnotexistingHost;
    @track isvisibleModal;
    @track licensestatus;
    @track currhostId;
    @api productId ;
    @api productOption ;
    @api seats ;
    @track licenserec;
    termandcondition=false;
hostNameInput;

label = {
    TermsCondition_Optin,
    TermsCondition,
};
TermsCondition_Optin=this.label.TermsCondition_Optin;
TermsConditionTxt=this.label.TermsCondition;
//@wire(getRecord, { recordId: '$recordId', fields: FIELDS })
//license;

//@wire(getHosts, {})
    @track hostDetailsRes;
    @track hostDetails=[];
    @track error;

    connectedCallback()
    {
       console.log('productoption '+this.productOption);
       console.log('productId '+this.productId);
       console.log('seats '+this.seats);
       console.log('currhostId'+this.currhostId);
    }

    @wire(getHosts, {})
    getHostsDetails(response) { 
        console.log('currhostId--> '+this.currhostId) ;
        this.hostDetailsRes=response;
        if (response.data) { 
            var hostList=[];
            var self=this;
            response.data.forEach((rec)=>{
                var host={};
                host.Id=rec.Id;
                host.Name=rec.Name;
                console.log(self.currhostId+'----'+rec.Id);
                console.log(self.currhostId==rec.Id);
                host.selected=(self.currhostId==rec.Id?true:false);
                hostList.push(host);
            });
            this.hostDetails = hostList;
            this.error = undefined;
            console.log('data-->'+JSON.stringify(this.hostDetails));            
        }else if (response.error) { 
            this.hostDetails = [];
            this.error = response.error;
            console.log('error-->'+JSON.stringify(response.error)); 
        } 
    }

    get hostExist(){
        return this.hostDetails.length>0;
    }

    createNewComputer(event){
    this.createcomputerlogic();

    }
    createcomputerlogic(){
        this.createComputer=true;
            /*console.log('I am here');
             var compDetails = {
                 componentDef: "c:sslcCreateNewComputerButton",
                 attributes: {
                     //Value you want to pass to the next lwc component
                     propertyValue: "500",
                
                     toollicensetype : this.licenseType,
                     primaryadmincontact : this.primarycontact,
                     licensedusercontact : this.licusercontact,
                     showmodal:true                        
     
                 }
             };
             // Base64 encode the compDefinition JS object
             var encodedCompDetails = btoa(JSON.stringify(compDetails));
             this[NavigationMixin.Navigate]({
                 type: 'standard__webPage',
                 attributes: {
                     url: '/one/one.app#' + encodedCompDetails
                 }
             });*/
     }

     handleHostSuccess(event){
        var response=JSON.parse(JSON.stringify(event.detail));
        if(response.HostId){
            this.currhostId=response.HostId;
        }        
        this.createComputer=false;
        refreshApex(this.hostDetailsRes);
        this.isGenerateButtonDisabled = false;
     }

     cancelEvent(){
        this.createComputer=false;
     }
     handleNextButtonState() {
        // Enable the generate button once host is created or selected 
        this.isGenerateButtonDisabled = true;
    }
    handleBacktButtonClick() {
    console.log('Back button clicked!');
    var selectedEvent = new CustomEvent('productpage1', { detail:{"comp1" : true, "comp2" : false}});
    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
    }

    handleNextButtonClick(){
        console.log('In button click ');
        createLicNew({ productId: this.productId, optionalProducts: this.productOption,
                        hostId: this.currhostId, seats: this.seats})
         .then(result =>{
            console.log('Hiii');
            this.licenserec = result;
            console.log('licenserec '+ JSON.stringify(this.licenserec));
            const licenseId = this.licenserec.Id;
            const licenseName = this.licenserec.Name;
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: licenseId,
                    objectApiName: 'Sales_License__c', // objectApiName is optional
                    actionName: 'view'
                }
            });
        })
        .catch(error =>{
            console.log('Error ' +error);
            this.errorMsg = error;
            
        })
    }

    handleChange(event){
    //    const selectedHost = event.target.value;
    //    console.log('selectedHost ' +selectedHost)
      /*  var val = event.target.name;
        console.log('currhostId ' +val);*/
        //this.currhostId = selectedHost;
        this.currhostId  = event.target.dataset.hostid;
        console.log('currhostId ' +this.currhostId);
        this.isGenerateButtonDisabled = false;
    }
    handleTandC(event){
        if (event.target.checked)
         {
             this.termsAccepted=true;
         }
         else
             this.termsAccepted=false;
}
handleOptin(event){
    if (event.target.checked)
    {
        this.optin=true;
    }
    else
    this.optin=false;

}
}