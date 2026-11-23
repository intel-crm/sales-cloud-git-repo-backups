import { LightningElement, track, api,wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getUserRegionUITheme from '@salesforce/apex/Core_Create_SSR_Controller.getUserRegionUITheme';
//Software Expert Support
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import formTitle from '@salesforce/label/c.Core_SSR_Create_Request';
import ErrorRequestType from '@salesforce/label/c.Core_SSR_Support_Request_Error';
import ErrorSubject from '@salesforce/label/c.Core_SSR_Subject_Error';
import ErrorDesc from '@salesforce/label/c.Core_SSR_Description_Error';
import ErrorDeadLine from '@salesforce/label/c.Core_SSR_Deadline_Error';
import ErrorUserAgreed from '@salesforce/label/c.Core_SSR_Opportunity_Checkflag_Error';
import getPicklist from '@salesforce/apex/Core_Create_SSR_Controller.getSupport_Request_Type_Picklist_Values';
import DDR_WebService from '@salesforce/apex/Core_Create_SSR_Controller.SSR_In_DRD_via_REST_Call'
import getURL from '@salesforce/apex/Core_Create_SSR_Controller.getURL'
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import NAME_FIELD from "@salesforce/schema/Opportunity.Name";
//As part of TWC3123-6823
import ACC_FIELD from "@salesforce/schema/Opportunity.AccountId";
import CreateSSR from '@salesforce/apex/Core_Create_SSR_Controller.CreateSSR';
import WebQuoteURL from '@salesforce/label/c.Core_Web_Quote_URL'; //Create Web Quote URL
import getSeedSampleURL from '@salesforce/apex/Core_Create_SSR_Controller.getSeedSampleURL';
//Start - PSG Quote TWC3123-4852
//import createPSGQuoteonSiebel from'@salesforce/apex/Core_Create_SSR_Controller.createPSGQuoteonSiebel';
import { getObjectInfo} from 'lightning/uiObjectInfoApi';
import getIQRTenderURL from '@salesforce/apex/Core_Create_SSR_Controller.getIQRTenderURL';
import getAtRiskURL from '@salesforce/apex/Core_Create_SSR_Controller.getAtRiskURL';
import checkOpptyStage from '@salesforce/apex/Core_Create_SSR_Controller.checkOpptyStage';
import showPricingAndQuoting from '@salesforce/apex/Core_Create_SSR_Controller.showPricingAndQuoting';
import getSWAndServQuoteSuppRequestDetails from '@salesforce/apex/CRM_Software_And_ServicesQuote.getSWAndServQuoteSuppRequestDetails';
import hasAccessToCreateSWQuote from '@salesforce/apex/CRM_Software_And_ServicesQuote.hasAccessToCreateSWQuote';
import getQuoteProgramName from '@salesforce/apex/CRM_Software_And_ServicesQuote.getQuoteProgramName';
import CRM_SW_SWQuote_Exists_HardStopErrorMsg from '@salesforce/label/c.CRM_SW_SWQuote_Exists_HardStopErrorMsg';
import CRM_SW_PSGIRGQuoteExists_HardStopErrorMs from '@salesforce/label/c.CRM_SW_PSGIRGQuoteExists_HardStopErrorMs';
import customCSS from '@salesforce/resourceUrl/toastCSS';
import { loadStyle } from 'lightning/platformResourceLoader';
import getaiInferenceURL from '@salesforce/apex/Core_Create_SSR_Controller.getaiInferenceURL';
import USERID from '@salesforce/user/Id';
import USEREMAIL from '@salesforce/schema/User.Email';
import OPP_DW_AMT from '@salesforce/schema/Opportunity.Amount';
import OPP_VERTICAL_MARKET from '@salesforce/schema/Opportunity.Core_Consumption_Market__c';
import ACC_GEO from '@salesforce/schema/Opportunity.Account.Core_Geo__c';
import ACC_NAME from '@salesforce/schema/Opportunity.Account.Name';
import ACC_SALES_GROUP from '@salesforce/schema/Opportunity.Account.Core_Sales_Groups__c';
import ACC_UCD_ID from '@salesforce/schema/Opportunity.Account.Core_Business_Party_Id__c';//TWC4767-3983
import ACC_CIM_ID from '@salesforce/schema/Opportunity.Account.Core_CIM_ID__c';//TWC4767-3983
//import ACC_KCR_Name from '@salesforce/schema/Opportunity.Account.KCR_Global_Account_Name_Temp__c';//TWC4767-3983

//import hideAndshowPSGQuoteFlag from '@salesforce/apex/CRM_Software_And_ServicesQuote.hideAndshowPSGQuoteFlag';

//End - PSG Quote TWC3123-4852
//As part of TWC3123-6823
const fields = [NAME_FIELD, ACC_FIELD,OPP_DW_AMT,OPP_VERTICAL_MARKET,ACC_GEO,ACC_NAME,ACC_SALES_GROUP,ACC_UCD_ID,ACC_CIM_ID/*,ACC_KCR_Name*/];//TWC4767-3983
//const accFields = [ACC_GEO,ACC_NAME];

// Software Expert Support
export default class Core_OpportunitySupport extends NavigationMixin(LightningElement) {
    @track comboflag=false;
    @track iconName='utility:down';
    @track fieldValue='Select one';
    @track flag=false;
    @track icon="utility:chevronright";
    @track techExpertparent=false;
    @track marketingSupparent=false; //TWC4767-2678

    @track flgshowPricingAndQuoting=false;
    @track flghasAccessToCreateSWQuote=false;
    //@track hideAndshowPSGQuoteFlag=false;
    @track flgisSWQuotePresent = false;
    @track isCSSLoaded = false;
    @track recordTypeId;
    
    IndExpertparent=false;
    @track OppAtRiskparent=false;
    @track GeneralExportparent=false;
    @track pqparent=false;
    @track prodFulfilparent=false;
    @track showSearchComponent=false;
    showITIntelComponent = false;
    @api recordId;
    @track userRegion = '';
    @track UITheme = '';
    @track showMainComponent = true;
    @track expand=false;
    //Software Expert Support
    @track errorList = [];
    @track alertViewed = false;
    @track LoadComponent = true;
    @track options = [];
    @track userAgreed= false;
    @track RequestType ='';
    @track Subject='';
    @track Description='';
    @track DeadlineDate='';
    @track OppsName;
    @track OppsLink;
    @track isShowModal=false;
    @track spinnerOn = false;
    label = {formTitle};
    @track SrrDetails;
    @track ShowTss=false;
    //Software Expert Support

    //TWC3123-4852 -Seed & Sample Urls
    @track SeedURL;
    @track SampleURL;
    //TWC3123-4852 - End
    @track getAIURL;
    //TSS-CSA-COE
    @track recordTypeOptions;
    @track isCOEModal=false;
    @track TssCsaCoe;
    @track oppsSupptypName;
    //PSG Quote - Start
    //@track psgSpinner=false;
    //PSG Quote - end
    isIQRURL=false;
    riskURL='';
    listOfWarnings = '';
    @track listOfErrors ={};
    errorMessageToDisplay = '';
    
	@track wrapperData;
    @track noDataMessage;
    @track stageName = '';
    @track status = false;
    //As part of TWC3123-6823
    @track accountId;
    opportunity = undefined;
    @track programName;
    //As part of CIM/UCD changes
    @track sUCDId;
    @track sCIMId; //TWC4767-3983
    @track kcrGlobalAccNameTemp; //TWC4767-3983

    account = undefined;
    
    @track flgisPSGorIQRQuotePresent=false;
	//As part of TWC3123-6823
    @wire(getRecord, { recordId: '$recordId', fields: fields })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading opportunity',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
			this.opportunity = data;
            this.accountId = this.opportunity.fields.AccountId.value;
            this.dwAmount= this.opportunity.fields.Amount.value;
            this.verticalMarket = this.opportunity.fields.Core_Consumption_Market__c.displayValue;
            this.accGeo = this.opportunity.fields.Account.value.fields.Core_Geo__c.value;
            this.accName = this.opportunity.fields.Account.value.fields.Name.value;
            this.accSalesGroup = this.opportunity.fields.Account.value.fields.Core_Sales_Groups__c.value;
            this.oppName = this.opportunity.fields.Name.value;
            this.sUCDId = this.opportunity.fields.Account.value.fields.Core_Business_Party_Id__c.value;
            this.sCIMId = this.opportunity.fields.Account.value.fields.Core_CIM_ID__c.value;//TWC4767-3983
            //this.kcrGlobalAccNameTemp = this.opportunity.fields.Account.value.fields.KCR_Global_Account_Name_Temp__c.value;//TWC4767-3983
            this.seedSample();
            //this.aiInferenceURL();  
        }
    }
    @wire(getRecord, {recordId :USERID, fields : USEREMAIL})
    userDetail({error,data}){
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading user data',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data){
            this.userEmail = data.fields.Email.value;
        }
    }
    renderedCallback() {
        this.OppsName = this.oppName;//getFieldValue(this.wiredRecord.data, NAME_FIELD);
        this.OppsLink = "/"+this.recordId;
    }

    handleChange(event) {
        this.comboflag=!this.comboflag;
        if(this.comboflag == false){
            this.iconName="utility:down";
        }else{
            this.iconName="utility:up";
        }
    }

    get renderTemplate(){
        return this.comboflag;
    }

    handleDropDown(event){
        let selectedId=event.target.dataset.id;
        let iconParent=selectedId+'parent';//techExpertparent === techExpertparent

        let target=this.template.querySelector("[data-id='" +iconParent+ "']");
        let targetIcon=this.template.querySelector("[data-id='" +selectedId+ "']");
        if(iconParent == 'techExpertparent'){
            this.techExpertparent=!this.techExpertparent;
            
            if(this.techExpertparent == false){
                
                target.classList.remove('slds-theme_shade');
                targetIcon.iconName="utility:chevronright";
            }else{
                
                target.classList.add('slds-theme_shade');
                targetIcon.iconName="utility:chevrondown";
            }
        }
        //TWC4767-2678 - Start
		if(iconParent == 'marketingSupparent'){
            this.marketingSupparent=!this.marketingSupparent;
            
            if(this.marketingSupparent == false){
                target.classList.remove('slds-theme_shade');
                targetIcon.iconName="utility:chevronright";
            }else{
                target.classList.add('slds-theme_shade');
                targetIcon.iconName="utility:chevrondown";
            }
        }
		//TWC4767-2678 - End
        if(iconParent == 'IndExpertparent'){
            this.IndExpertparent=!this.IndExpertparent;
            

            if(this.IndExpertparent == false){
                
                target.classList.remove('slds-theme_shade');
                targetIcon.iconName="utility:chevronright";
            }else{
                
                target.classList.add('slds-theme_shade');
                targetIcon.iconName="utility:chevrondown";
            }
        }

        if(iconParent == 'OppAtRiskparent'){
            this.OppAtRiskparent=!this.OppAtRiskparent;
            

            if(this.OppAtRiskparent == false){
                
                target.classList.remove('slds-theme_shade');
                targetIcon.iconName="utility:chevronright";
            }else{
                
                target.classList.add('slds-theme_shade');
                targetIcon.iconName="utility:chevrondown";
            }
        }

        if(iconParent == 'GeneralExportparent'){
            this.GeneralExportparent=!this.GeneralExportparent;
            

            if(this.GeneralExportparent == false){
                
                target.classList.remove('slds-theme_shade');
                targetIcon.iconName="utility:chevronright";
            }else{
                
                target.classList.add('slds-theme_shade');
                targetIcon.iconName="utility:chevrondown";
            }
        }

        if(iconParent == 'pqparent'){
            this.pqparent=!this.pqparent;
            

            if(this.pqparent == false){
                
                target.classList.remove('slds-theme_shade');
                targetIcon.iconName="utility:chevronright";
            }else{
                
                target.classList.add('slds-theme_shade');
                targetIcon.iconName="utility:chevrondown";
            }
        }

        if(iconParent == 'prodFulfilparent'){
            this.prodFulfilparent=!this.prodFulfilparent;
            

            if(this.prodFulfilparent == false){
                
                target.classList.remove('slds-theme_shade');
                targetIcon.iconName="utility:chevronright";
            }else{
                
                target.classList.add('slds-theme_shade');
                targetIcon.iconName="utility:chevrondown";
            }
        }
    };

    handleSES(event){
        this.showMainComponent = false;
        this.isShowModal=true;
         //this.closeAction();
        
    }

    @wire(getUserRegionUITheme,{})
    userDetails({error,data}){
    if(data){
        this.userRegion = data[1];
        this.UITheme = data[0];
      }
    }

    @wire(getAtRiskURL,{})
    getAtRiskURL({error,data}){
        if(data){
            this.result = data;
           this.riskURL=this.result+this.recordId;
        }else{
            console.log('Error:',JSON.stringify(error));

        }
    }
    //As part of TWC3123-6823
    seedSample() {
        getSeedSampleURL({OpportunityId : this.recordId, AccountId : this.accountId, sUCDId : this.sUCDId, sCIMId : this.sCIMId/*, kcrGlobalAccNameTemp : this.kcrGlobalAccNameTemp*/})//TWC4767-3983
            .then(data => {
                if(data){
                    this.SeedURL =data.SeedURL;
                    this.SampleURL=data.SampleURL+this.recordId;
                }
            })
            .catch(error => {
            });
    }

    async aiInferenceURL(){
        const result = await getaiInferenceURL({OpportunityId : this.recordId, dwAmt : this.dwAmount, VertMart : this.verticalMarket, accname : this.accName, accgeo : this.accGeo, useremail : this.userEmail, accsalesgrp : this.accSalesGroup, oppname : this.oppName})
            .then(data => {
                if(data){
                    this.getAIURL = data;
                }
            })
            .catch(error=> {
                console.error('error'+JSON.stringify(error));
            });
    }
    
    //TWC3123-4852- End
    //Start - TWC3123-4852 - RecordTypes
    @wire(getObjectInfo, { objectApiName:  'Core_Opportunity_Support__c' })
    objectInfo({ error, data }) {
        if (data) {
            this.recordTypeOptions = Object.values(data.recordTypeInfos).filter(option => (option.name != 'Master')).map(option => ({ label: option.name, value: option.recordTypeId }));
        
        } else if (error) {
            console.log(error);
        }
    }  
    //End - TWC3123-4852
    handleITIntel(){
        
        const defaultValues = encodeDefaultFieldValues({
            Core_IT_Intel_Geo__c: this.userRegion,
            Core_Opportunity__c : this.recordId,  
        });

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Core_Sales_Support_Request__c',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });
    }
//TWC3123-4852: start
    async handleTSSS(){
        const result = JSON.parse(JSON.stringify(await checkOpptyStage({ recordId : this.recordId})));
       
        if (result.statusApp == true){
                const event = new ShowToastEvent({
                title: 'Error',
                message: 'Cannot request for TSS when aproval status is Approved',
                variant: 'error',
        });
        this.dispatchEvent(event);
        }
            else if(this.status == false){
                this.showMainComponent = false;
                this.TssCsaCoe= this.recordTypeOptions.find(option => option.label === 'Technical Sales Specialist Request').value
                this.oppsSupptypName='Technical Sales Specialist Request';
                this.isCOEModal=true; 
            }
               

    }
    async handleCSA() {
        const result = JSON.parse(JSON.stringify(await checkOpptyStage({ recordId : this.recordId})));
        
        if (result.statusApp == true){
                const event = new ShowToastEvent({
                title: 'Error',
                message: 'Cannot request for CSA when aproval status is Approved',
                variant: 'error',
        });
        this.dispatchEvent(event);
        } 
        else if(result.statusApp == false){
        this.showMainComponent = false;
        this.TssCsaCoe= this.recordTypeOptions.find(option => option.label === 'Cloud Solutions Architect Request').value
        this.oppsSupptypName='Cloud Solutions Architect Request';
        this.isCOEModal=true;   
        }
        
    }
    async handleCOE(){
        const result = JSON.parse(JSON.stringify(await checkOpptyStage({ recordId : this.recordId})));
        if (result.statusApp == true){
                const event = new ShowToastEvent({
                title: 'Error',
                message: 'Cannot request for COE when aproval status is Approved',
                variant: 'error',
        });
        this.dispatchEvent(event);
        } 
        else if(result.statusApp == false){
        this.showMainComponent = false;
        this.TssCsaCoe= this.recordTypeOptions.find(option => option.label === 'Center of Excellence Request').value
        this.oppsSupptypName='Center of Excellence Request';
        this.isCOEModal=true;
         }
         
    }
    //TWC4767-2678 - Start
	async handleMS(){
        const result = JSON.parse(JSON.stringify(await checkOpptyStage({ recordId : this.recordId})));
        this.stageName =  result.stageName ;

        if (this.stageName == 'Design' || this.stageName == 'Design Win' || this.stageName == 'Production Win'){
	            this.showMainComponent = false;
                this.TssCsaCoe= this.recordTypeOptions.find(option => option.label === 'Marketing Support').value
                this.oppsSupptypName='Marketing Support';
                this.isCOEModal=true; 
            }
        else{
	            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Marketing Support Request can be raised only when Opportunity is in "Design/Design Win/Production Win Stages',
                variant: 'error',
                });
                this.dispatchEvent(event);
           }
    }
	//TWC4767-2678 - End


        createPremierSupport(){
        var compDefinition = {
            componentDef: "c:core_IPS_Create_Opportunity_PAR",
            attributes: {
                recordId: this.recordId
            }
            
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
    });
    }
//TWC3123-4852: End
    closeAction() {
        const closeModalEvent = new CustomEvent("modalclose");
        this.dispatchEvent(closeModalEvent);
    }
    handleSave() {
        const closeModalEvent = new CustomEvent("modalclose");
        this.dispatchEvent(closeModalEvent);
    };
//Software Expert Support
connectedCallback(){ 
    loadStyle(this, customCSS).then(() => {
        
    }).catch(error => {
       
    });


    showPricingAndQuoting({ recordId :  this.recordId})
        .then(result => {
           
            if (result!= null){
                this.flgshowPricingAndQuoting = result; 
        } 
        
        })



    getPicklist().then(result => {
            this.options = result;
        }).catch(error => {
            this.showErrorToast(error.body.message);
        })

        //Areefa: TWC4767-2562
        hasAccessToCreateSWQuote({ recordId :  this.recordId}).then(result => {
            if (result!= null){
                this.flghasAccessToCreateSWQuote = result;
            }
        }).catch(error => {
            this.showErrorToast(error.body.message);
        }) 

             
        //Areefa: WW28,2025        
        /*hideAndshowPSGQuoteFlag({ settingName: 'hideAndshowPSGQuote' })
            .then((result) => {
                this.hideAndshowPSGQuoteValue = result;
                console.log('Custom Setting Value:', this.hideAndshowPSGQuoteValue);
            })
            .catch((error) => {
                console.error('Error fetching custom setting value:', error);
            });*/
    
};

//Areefa: TWC4767-2525
async  setQuoteProgramNamesFlags() {
    const result = await getQuoteProgramName({ recordId: this.recordId })
        .then((result) => {
            result.forEach(result => {           
                if (result === 'Tender' || result === 'PSG') { 
                    this.flgisPSGorIQRQuotePresent = true; 
                }
                if (result === 'Software & Services') {                   
                    this.flgisSWQuotePresent = true;     
                }                
            });
        })
        .catch((error) => {
            console.error('Error retrieving quote program names:', error);
        });
}
/*@wire(getRecord, {recordId: '$recordId',fields }) Opportunity;
renderedCallback() {
    this.OppsName = getFieldValue(this.Opportunity.data, NAME_FIELD);
    this.OppsLink = "/"+this.recordId;
}*/

renderedCallback1() { 
    if (this.isCSSLoaded) return;
    this.isCSSLoaded = true;
    loadStyle(this, customCSS).then(() => {
        console.log('css loaded successfully');
    }).catch(error => {
        console.log('error to load css');
    });
}

closeErrorBox(){
    this.alertViewed= false;
    this.errorList = [];
};
hideModalBox() {  
    this.ShowTss=false
    this.isShowModal = false;
    this.showMainComponent = false;
    this.closeAction();
};
handleChange1(event){
    if( event.target.name == 'RequestType' ){
        this.RequestType = event.target.value;        
    }
    else if( event.target.name == 'Subject' ){
        this.Subject = event.target.value;
    }
    else if( event.target.name == 'Description' ){
        this.Description = event.target.value;
    }
    else if( event.target.name == 'DeadLineDate' ){
        this.DeadlineDate = event.target.value;
    }
    else if( event.target.name == 'UserAgreed' ){
        this.userAgreed = event.target.checked;
    }
};

doValidation(){
    this.errorList = [];
    if (this.RequestType === null || this.RequestType === '') {
        this.errorList.push (ErrorRequestType);
    }
    if (this.Subject === null || this.Subject === undefined || this.Subject.trim().length === 0) {
        this.errorList.push (ErrorSubject);
    }
    if (this.Description === null || this.Description === undefined || this.Description.trim().length === 0) {
        this.errorList.push (ErrorDesc);
    }
    if (this.DeadlineDate == null || this.DeadlineDate.trim() === '') {
        this.errorList.push (ErrorDeadLine);
    }
    if (this.userAgreed === null || this.userAgreed === false) {
        this.errorList.push (ErrorUserAgreed);
    }

};

createSSRRequest(){
this.doValidation();
    if(this.errorList.length>0){
        this.alertViewed=true;
    }
    else{
        this.closeErrorBox();
        this.spinnerOn=true;
        CreateSSR({ 
        OppsId : this.recordId, 
        RequestType : this.RequestType, 
        Subject : this.Subject,
        Description : this.Description,
        DeadlineDate : this.DeadlineDate,
        UserAgreed : this.userAgreed
    })
    .then(result => {
        this.spinnerOn=false;
        this.SrrDetails = result;
        const event = new ShowToastEvent({
        title:result.smgSSRName,
        message: 'New Software Support Request Created.', 
        variant: 'success'
        });
        this.dispatchEvent(event);
        //Call DDR Webservice
        this.Call_DDR_Service();
    })
    .catch(error => {
        const event = new ShowToastEvent({
        title : 'Something went wrong',
        message : error.body.message,
        variant : 'error'
        });
        this.dispatchEvent(event);
        this.spinnerOn=false;
        this.isShowModal = false;
        this.showMainComponent = false;
        this.closeAction();
    });                
    }
};


  

Call_DDR_Service(){
this.spinnerOn=true;
    DDR_WebService({ 
        SMGSupportRequestID : this.SrrDetails.SSRId, 
        SSR_JSON : this.SrrDetails.SMGJosn,
    })
    .then(result => {
        this.spinnerOn=false;
    if(result.includes('Successful')){
        this.spinnerOn=false;
        this.isShowModal = false;
        this.showMainComponent = false;
        this.closeAction();
        this.navigateToSSRPage(this.SrrDetails.SSRId);
    }
    else{
        this.errorList.push (result);
            if(this.errorList.length>0){
                this.alertViewed=true;
            }
        }
    })
    .catch(error => {
        const event = new ShowToastEvent({
        title : 'Exception Call Out',
        message : error.body.message,
        variant : 'error'
        });
        this.dispatchEvent(event);
        this.spinnerOn=false;
        this.isShowModal = false;
        this.showMainComponent = false;
        this.closeAction();
    });
}
showErrorToast(ErrorList) {
    const evt = new ShowToastEvent({
        title: 'Toast Error',
        message: ErrorList,
        variant: 'error',
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
}

navigateToSSRPage(SrrID) {
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: SrrID,
            objectApiName: 'Core_Sales_Support_Request__c',
            actionName: 'view'
        }
    });
}
//Software Expert Support


//General Support
handleAskAQuestion(){
    this.closeAction();
    this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/Core_AAQ_TabOverride'
            }
        }).then(vfURL => {
        window.open(vfURL);
        });

}
//TWC3123-4852 
//Create WebQuote call
async createWebQuote(){
    await this.setQuoteProgramNamesFlags();
    console.log('result:::', this.flgisSWQuotePresent);
    if(this.flgisSWQuotePresent){
        this.showErrorMessage(CRM_SW_SWQuote_Exists_HardStopErrorMsg); //Only Software & Services Quote can be created for Software Opportunities.
    }else if (this.flgshowPricingAndQuoting){
    const QUOTE_URL = WebQuoteURL+this.recordId;
    this.closeAction();
    window.open(QUOTE_URL, '_blank');
}
else{	console.log('Deal reg so no action required'); }
}
//Order Seeds
orderSeed(){
    this.closeAction();
    window.open(this.SeedURL, '_blank');
}
// AI inference
async handleAiInference(){
    await this.aiInferenceURL();   
    console.log('MV--'+this.getAIURL);
    this.closeAction();
    //window.open(ssFormUrl+ssReqEmail+this.userEmail,'_blank');
    window.open(this.getAIURL,'_blank');
}
//Request Sample
requestSample(){
    this.closeAction();
    window.open(this.SampleURL, '_blank');    
}
/*
//Create PSG Quote
async createPSGQuote(){
    // ORIGINAL IMPLEMENTATION COMMENTED OUT PER REQUEST
    await this.setQuoteProgramNamesFlags();

    if(this.flgisSWQuotePresent){
        this.showErrorMessage(CRM_SW_SWQuote_Exists_HardStopErrorMsg); //Only Software & Services Quote can be created for Software Opportunities.
    }else if (this.flgshowPricingAndQuoting){
        this.psgSpinner=true;
        createPSGQuoteonSiebel({soppId : this.recordId})
        .then(result => {
            if(result.status==='Success'){
                this.psgSpinner=false;
                const event = new ShowToastEvent({
                    title : 'Success',
                    message : 'Quote Created Successfully - {0}',
                    variant : 'success',
                    messageData: [
                        {
                            url: '/'+result.quoteRecId,
                            label: result.quoteID,
                        },
                    ],
                    mode: 'dismissable',
                });
                this.dispatchEvent(event);
                this.showMainComponent = false;
                this.closeAction();
            }
            else{
                this.psgSpinner=false;
                const event = new ShowToastEvent({
                    title : 'Fail',
                    message : result.errorMsg,
                    variant : 'error'
                });
                this.dispatchEvent(event);
                this.closeAction();
                this.showMainComponent = false;
            }
        })
        .catch(error => {
            this.psgSpinner=false;
            const event = new ShowToastEvent({
                title : 'Something went wrong',
                message : error.body.message,
                variant : 'error'
            });
            this.dispatchEvent(event);
            this.showMainComponent = false;
            this.closeAction();
        });

    }
    else
    {
        console.log('Deal reg so no action required');  
    }
}
*/

async handleIQRTender(event) {
    await this.setQuoteProgramNamesFlags(); 
    console.log('result:::', this.flgisSWQuotePresent);
    if (this.flgisSWQuotePresent) {
        this.showErrorMessage(CRM_SW_SWQuote_Exists_HardStopErrorMsg);//Only Software & Services Quote can be created for Software Opportunities.
    } else if (this.flgshowPricingAndQuoting) {
        getIQRTenderURL()
            .then(response => {
                this.result = response;
                window.open(this.result, '_blank');
            })
            .catch(error => {
                console.error('Error:', error);
            });
    } else {
        console.log('Deal reg so no action required');
    }
}


//End- TWC3123-4852
handleExpandAll(){
        let techExpert= this.refs.myDiv;
        let indExpert= this.refs.myDiv1;
        let oppAtRiskExpert= this.refs.myDiv2;
        let generalExport= this.refs.myDiv3;
      
        let productFulfillment= this.refs.myDiv5;
        let techExpertTargetIcon=this.template.querySelector('[data-id="techExpert"]');
        techExpertTargetIcon.iconName="utility:chevrondown";
        let indExpertTargetIcon =this.template.querySelector('[data-id="IndExpert"]');
        indExpertTargetIcon.iconName="utility:chevrondown";
        let oppAtRiskExpertTargetIcon =this.template.querySelector('[data-id="OppAtRisk"]');
        oppAtRiskExpertTargetIcon.iconName="utility:chevrondown";
        let generalExportTargetIcon =this.template.querySelector('[data-id="GeneralExport"]');
        generalExportTargetIcon.iconName="utility:chevrondown";
         if (this.flgshowPricingAndQuoting)
        {
              let pricingQuoting= this.refs.myDiv4;
        pricingQuoting.classList.add('slds-theme_shade');
        let pricingQuotingTargetIcon =this.template.querySelector('[data-id="pq"]');
        pricingQuotingTargetIcon.iconName="utility:chevrondown";
        }
        let productFulfillmentTargetIcon =this.template.querySelector('[data-id="prodFulfil"]');
        productFulfillmentTargetIcon.iconName="utility:chevrondown";
        //TWC4767-2678- Start
		let marketingSup= this.refs.myDiv6;
        let marketingSupTargetIcon=this.template.querySelector('[data-id="marketingSup"]');
        marketingSupTargetIcon.iconName="utility:chevrondown";
		marketingSup.classList.add('slds-theme_shade');//theme_info
		//TWC4767-2678- End
		
    
        techExpert.classList.add('slds-theme_shade');//theme_info
        this.icon ="utility:chevrondown";
        
        indExpert.classList.add('slds-theme_shade');
        
        oppAtRiskExpert.classList.add('slds-theme_shade');
        
        generalExport.classList.add('slds-theme_shade');
        
        productFulfillment.classList.add('slds-theme_shade');
        this.techExpertparent = true;
        this.marketingSupparent = true;//TWC4767-2678
        this.IndExpertparent = true;
        this.OppAtRiskparent = true;
        this.GeneralExportparent = true;
        if (this.flgshowPricingAndQuoting)
        {
            this.pqparent = true;
        }
        this.prodFulfilparent = true;
}

handleCollapseAll(){
    this.icon="utility:chevronright";
    let techExpert= this.refs.myDiv;
    let indExpert= this.refs.myDiv1;
    let oppAtRiskExpert= this.refs.myDiv2;
    let generalExport= this.refs.myDiv3;
     if (this.flgshowPricingAndQuoting)
    {
    let pricingQuoting= this.refs.myDiv4;
     pricingQuoting.classList.remove('slds-theme_shade');
      let pricingQuotingTargetIcon =this.template.querySelector('[data-id="pq"]');
    pricingQuotingTargetIcon.iconName="utility:chevronright";
    }
    let productFulfillment= this.refs.myDiv5;
    let techExpertTargetIcon=this.template.querySelector('[data-id="techExpert"]');
    techExpertTargetIcon.iconName="utility:chevronright";
    let indExpertTargetIcon =this.template.querySelector('[data-id="IndExpert"]');
    indExpertTargetIcon.iconName="utility:chevronright";
    let oppAtRiskExpertTargetIcon =this.template.querySelector('[data-id="OppAtRisk"]');
    oppAtRiskExpertTargetIcon.iconName="utility:chevronright";
    let generalExportTargetIcon =this.template.querySelector('[data-id="GeneralExport"]');
    generalExportTargetIcon.iconName="utility:chevronright";
   
    let productFulfillmentTargetIcon =this.template.querySelector('[data-id="prodFulfil"]');
    productFulfillmentTargetIcon.iconName="utility:chevronright";
    //TWC4767-2678- Start
	let marketingSup= this.refs.myDiv6;
	let marketingSupTargetIcon=this.template.querySelector('[data-id="marketingSup"]');
	marketingSupTargetIcon.iconName="utility:chevronright";
	marketingSup.classList.remove('slds-theme_shade');//theme_info
	//TWC4767-2678- End
    
    techExpert.classList.remove('slds-theme_shade');
    
    indExpert.classList.remove('slds-theme_shade');
    
    oppAtRiskExpert.classList.remove('slds-theme_shade');
   
    generalExport.classList.remove('slds-theme_shade');
    
    productFulfillment.classList.remove('slds-theme_shade');
    this.techExpertparent = false;
    this.marketingSupparent = false;//TWC4767-2678
    this.IndExpertparent = false;
    this.OppAtRiskparent = false;
    this.GeneralExportparent = false;
    if (this.flgshowPricingAndQuoting)
    {
        this.pqparent = false;
    }
     
    this.prodFulfilparent = false;
}
//Areefa :TWC4767-2562
async handleCreateQuote(event){  
    await this.setQuoteProgramNamesFlags();  
    console.log('result:::', this.flgisPSGorIQRQuotePresent);
    getSWAndServQuoteSuppRequestDetails({ recordId :this.recordId})
        .then(result => {            
            if (!result.isApprovedOppt && result.isOpptPrimaryContactHasData && !this.flgisPSGorIQRQuotePresent && !result.isOneOfTheQuoteAccepted) {
                const defaultValues = encodeDefaultFieldValues({
                    Pricing_SW_Description__c : result.OpptyDescription , 
                    SBQQ__PrimaryContact__c : result.OpptPrimaryContact ,
                    SBQQ__Account__c : result.OpptAcctOwner ,
                    SBQQ__Opportunity2__c : result.OpptyId,
                    SBQQ__SalesRep__c :  result.currentUserId //USERID
                });

                this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                    attributes: {
                    objectApiName: 'SBQQ__Quote__c',
                    actionName: 'new'
                    },
                state: {
					nooverride: '1',
                	useRecordTypeCheck: '1',
                    defaultFieldValues: defaultValues,
                    recordTypeId : result.SWRecId,
                    }
                });

                this.errorMessageToDisplay = '';
                let listofErrors = new Set();
                if(result.OpptProdCountGrtTnZeroWarning != null){
                    listofErrors.add(result.OpptProdCountGrtTnZeroWarning);
                }
                if(result.MutipleSWQuoteOnOpptyWarning != null){
                    listofErrors.add(result.MutipleSWQuoteOnOpptyWarning);
                }

                listofErrors.forEach((value) =>{
                    this.errorMessageToDisplay +=  value+' \n';   
                  });

                  if(this.errorMessageToDisplay != '' ){
                    this.dispatchEvent(
            
                        new ShowToastEvent({
                            title: 'Warning',
                            message:this.errorMessageToDisplay,
                            variant: 'Warning',
                            mode : 'sticky'                            
                        })
                    );
                  }

            }else {
                this.hardErrMessageToDisplay = '';
                let listofHardErrors = new Set();
                if(this.flgisPSGorIQRQuotePresent ){ 
                    listofHardErrors.add(CRM_SW_PSGIRGQuoteExists_HardStopErrorMs);
                }else{
                    if(result.isOneOfTheQuoteAccepted && result.OneOfTheOpptySwQuoteisAcceptedHardError){
                        listofHardErrors.add(result.OneOfTheOpptySwQuoteisAcceptedHardError);
                    }
                    if(!result.isOpptPrimaryContactHasData && result.OpptPrimaryContactNullHardError){
                        listofHardErrors.add(result.OpptPrimaryContactNullHardError);
                    }
                    if(result.isApprovedOppt && result.isApprovedOpptyHardStopError){
                        listofHardErrors.add(result.isApprovedOpptyHardStopError);
                    }
                }
                
                listofHardErrors.forEach((value) =>{
                    this.hardErrMessageToDisplay +=  value+' \n';
                  });
                  
                 
                  if(this.hardErrMessageToDisplay != '' ){
                    this.dispatchEvent(
            
                        new ShowToastEvent({
                            title: 'Error',
                            message:this.hardErrMessageToDisplay,
                            variant: 'Error',
                            mode : 'dismissable'
                        })
                    );
                  }    
            }
           
        
        }).catch(error => {
            const event = new ShowToastEvent({
            title : 'Something went wrong in handleCreateQuote',
            message : error.body.message,
            variant : 'dismissable'
            });
            this.dispatchEvent(event);
          });
    }
    showErrorMessage(message) {
        const event = new ShowToastEvent({
            title: 'Error',
            message:message,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    } 
}