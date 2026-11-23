import { LightningElement,wire,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { NavigationMixin } from 'lightning/navigation';
import SalesSerialError from '@salesforce/label/c.Sales_SerialError';
import Sales_Statuserror  from '@salesforce/label/c.Sales_LicenseStatusError';
import SalesAddSeatRenewError from '@salesforce/label/c.Sales_AddSeatRenewError';
//import Sales_Err from '@salesforce/apex/Sales_FeedbackController.Sales_Err';//added for feedback
import Sales_Err from '@salesforce/label/c.Sales_Err';
import userId from '@salesforce/user/Id';
import licensefileGeneration from '@salesforce/apex/Sales_LicenseGenIntegration_Utility.returnHostIdDetail';
import { getRecord } from 'lightning/uiRecordApi';
import getHosts from '@salesforce/apex/Sales_FreeLicenseProvider.getHosts';
import createLicNew from '@salesforce/apex/Sales_FreeLicenseProvider.createLicNew';
import { refreshApex } from '@salesforce/apex';
import TermsCondition from '@salesforce/label/c.TermsCondition';
import TermsCondition_Optin from '@salesforce/label/c.TermsCondition_Optin';
import T_C from '@salesforce/label/c.T_C';
import LicenseDetailUrl from '@salesforce/label/c.Sales_LicenseDetailUrl';
import Sales_AssignExistingComputerHelptext from '@salesforce/label/c.Sales_AssignExistingComputerHelptext';
import Sales_CreateNewCompHelptext from '@salesforce/label/c.Sales_CreateNewCompHelptext';
import Sales_Path2TextLabel from '@salesforce/label/c.Sales_Path2TextLabel';
import Sales_GenerateLicenseHeadingHostPage from '@salesforce/label/c.Sales_GenerateLicenseHeadingHostPage';
import Sales_CreateNewComputerHeadingHostPage from '@salesforce/label/c.Sales_CreateNewComputerHeadingHostPage';
import Sales_AssignAnExistingComputerHostPage from '@salesforce/label/c.Sales_AssignAnExistingComputerHostPage';
import Sales_NewComputerButtonHostPage from '@salesforce/label/c.Sales_NewComputerButtonHostPage';
import Sales_Generate from '@salesforce/label/c.Sales_Generate';
import Sales_BackHostPage from '@salesforce/label/c.Sales_BackHostPage';
import Sales_NoExistingHost from '@salesforce/label/c.Sales_NoExistingHost';
import Sales_NoExistingHost1 from '@salesforce/label/c.Sales_NoExistingHost1';
import Sales_ViewAllComputers from '@salesforce/label/c.Sales_ViewAllComputers';
import Sales_ViewAllComputersURL from '@salesforce/label/c.Sales_ViewAllComputersURL';

const FIELDS = [ 'Sales_License__c.Id', 'Sales_License__c.Sales_License_Web_Display_Flag__c','Sales_License__c.Sales_Tool_License_Type__c','Sales_License__c.Sales_License_Activation_Code__c','Sales_License__c.Sales_License_Host_Node_Id__c','Sales_License__c.Sales_License_Primary_Admin_Contact__c','Sales_License__c.Sales_License_Lic_User_Contact_ID__c','Sales_License__c.Sales_License_Type__c','Sales_License__c.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c','Sales_License__c.Sales_License_Status__c'];

export default class sales_FreeLicenseHostPage extends NavigationMixin(LightningElement) {
    @api fromlac;
    @track userId=userId;
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
    @api termsCond;
    isGenerateButtonDisabled = 'true';
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
    termsCondition;
    hostNameInput;
    optionArray = [];
    StringOptions=[];
	@track isspinnerOn = false;
    hostNewCreate=false;
    hasRender=true;
    hasTerms=false;
    @track hasExistingHosts = true;
    @api isOptionSelect;
label = {
    T_C,
    TermsCondition_Optin,
    TermsCondition,
    Sales_AssignExistingComputerHelptext,
    Sales_CreateNewCompHelptext,
    Sales_Path2TextLabel,
    Sales_GenerateLicenseHeadingHostPage,
    Sales_CreateNewComputerHeadingHostPage,
    Sales_AssignAnExistingComputerHostPage,
    Sales_NewComputerButtonHostPage,
    Sales_Generate,
    Sales_BackHostPage,
    Sales_NoExistingHost,
    Sales_NoExistingHost1,
    Sales_ViewAllComputers,
    Sales_ViewAllComputersURL
};
    TermsCondition_Optin=this.label.TermsCondition_Optin;
    TermsConditionTxt=this.label.TermsCondition;

    @track hostDetailsRes;
    @track hostDetails=[];
    error;

    /*connectedCallback()
    {
        const topDiv = this.template.querySelector('[data-id="redDiv"]');
        topDiv.scrollIntoView({behavior: "smooth", block: "center", inline: "nearest"});
       console.log('productoption '+this.productOption);
       console.log('productId '+this.productId);
       console.log('seats '+this.seats);
       console.log('currhostId'+this.currhostId);
       this.termsCondition =this.termsCond;
       
    }*/

    renderedCallback() {
        const topDiv = this.template.querySelector('[data-id="redDiv"]');
        topDiv.scrollTop=0;
        console.log('isOptionSelect in host ' +this.isOptionSelect);
        console.log('ProductOptions Length ' +this.productOption.length);
        if(this.hasRender){
            this.termsCondition =this.termsCond;
            this.hasRender = false;
        }
        if(this.hostNewCreate){
            this.handleCheckSelection();
        }
    }

    @wire(getHosts, {licenseType : '$licenseType'})
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
                host.compName = rec.Sales_Computer_Name_Txt__c;
                console.log(self.currhostId+'----'+rec.Id);
                console.log(self.currhostId==rec.Id);
                host.selected=(self.currhostId==rec.Id?true:false);
                hostList.push(host);
            });
            this.hostDetails = hostList;
            this.error = undefined;
            if(!(this.hostDetails.length >0)){
                this.hasExistingHosts = false;
            }
            else{
                this.hasExistingHosts = true;
            }
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
     }

     handleHostSuccess(event){
        console.log('In host success ' +JSON.stringify(event.detail));
        var response=JSON.parse(JSON.stringify(event.detail));
        if(response.HostId){
            this.currhostId=response.HostId;
        }        
        this.createComputer=false;
        console.log('response saved ' +this.hostDetailsRes);
        console.log('response value ' +response);
        refreshApex(this.hostDetailsRes);
        this.hostNewCreate = true;
        if(this.hasTerms){
             this.isGenerateButtonDisabled = false;
        }
       
     }

     cancelEvent(){
        this.createComputer=false;
     }
    handleBacktButtonClick() {
    console.log('Back button clicked!');
    var selectedEvent = new CustomEvent('productpage1', { detail:{"comp1" : true, "comp2" : false, "productId" : this.productId, "Seats" :  this.seats, "productOption" : this.productOption,"termsCondition" : this.termsCondition, "isOptionSelect" : this.isOptionSelect}});
    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
    }

    handleNextButtonClick(){
        console.log('In button click ' + this.productOption);
		this.isspinnerOn = true;
        createLicNew({ productId: this.productId, productOption: this.productOption,
                        hostId: this.currhostId, seats: this.seats})
         .then(result =>{
            console.log('Hiii');
            this.licenserec = result;
            console.log('licenserec '+ JSON.stringify(this.licenserec));
            const licenseId = this.licenserec.Id;
            const licenseName = this.licenserec.Name;
            console.log('licenseName ' +licenseName);
            const licenseUrl = LicenseDetailUrl;
            console.log('licenseUrl ' +licenseUrl ); 
            const licenseFullURL = licenseUrl + licenseId;
            console.log('licenseFullURLL ' +licenseFullURL ); 
            var selectedEvent = new CustomEvent('licenseconfirmation', { detail:{ "licenseName" : licenseName, "licenseFullURL" : licenseFullURL}});
            // Dispatches the event.
            
            this.dispatchEvent(selectedEvent);
        })
        .catch(error =>{
            console.log('Error ' +JSON.stringify(error));
			this.isspinnerOn = true;
            this.error = error.body.pageErrors[0].message;
            console.log('Errorrr ' +this.error);
            this.showToast('Error', error.body.pageErrors[0].message, 'error');
            this.isspinnerOn = false;
        })

    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }


    handleChange(event){
        this.currhostId  = event.target.dataset.hostid;
        console.log('check host ' + this.currhostId);

        if(this.hasTerms && (this.currhostId == undefined  || this.currhostId == '')){
            this.isGenerateButtonDisabled = true;
        }
        else if(this.hasTerms && this.currhostId != null){
            this.isGenerateButtonDisabled = false;
        }

      /*  this.template.querySelectorAll(`[data-hostid=${this.currhostId}]`)[0].defaultChecked=true;
        this.template.querySelectorAll(`[data-hostid=${this.currhostId}]`)[0].checked=true;*/
    }
    //Changes made by -Bishal Singh
    handleTandC(event){
        console.log('isGenerateButtonDisableddd ' +this.isGenerateButtonDisabled);
        console.log('currhostIdTANDC ' +this.currhostId);
        const checkVal = event.currentTarget.checked;
        this.hasTerms = checkVal;
        if((!this.hasTerms && (this.currhostId == undefined  || this.currhostId != '')) || (this.hasTerms && (this.currhostId == undefined  || this.currhostId == ''))){

            this.isGenerateButtonDisabled = true;
            return
        }
        if(this.currhostId != undefined){
            console.log('currhostIdddd ' +this.currhostId);
            this.handleCheckSelection();
        }
        this.isGenerateButtonDisabled = false;
    }
    handleCheckSelection(event){
        this.template.querySelectorAll(`[data-hostid=${this.currhostId}]`)[0].defaultChecked=true;
        this.template.querySelectorAll(`[data-hostid=${this.currhostId}]`)[0].checked=true;

    }
    handleOptin(event){

    }
}