import { LightningElement, track, wire, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import strUserId from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import Sales_CreateOptnLic from '@salesforce/label/c.Sales_CreateOptnLic';
import Sales_createLic_HTML from '@salesforce/label/c.Sales_createLic_HTML';
import Sales_OrderClose from '@salesforce/label/c.Sales_OrderClose';
import Sales_validProfile from '@salesforce/label/c.Sales_validProfile';
import Sales_AccessCheckMsg from '@salesforce/label/c.Sales_AccessCheckMsg';

import checkUserPermissionSet from '@salesforce/apex/Sales_ApplyRenewalController.checkUserPermissionSet';
import getLicense from '@salesforce/apex/Sales_CreateLicenseProvider.getLicense';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import validateUserAccess from '@salesforce/apex/Sales_ValidateUserEditAccess.validateUserAccess';

const fields = [
    'Sales_License__c.Sales_License_Product__c',
    'Sales_License__c.Sales_License_Order_Product__c',
    'Sales_License__c.Sales_Tool_License_Type__c',
    'Sales_License__c.Sales_License_Type__c'
]

export default class Sales_CreateOptionalLicenseParentCmp extends LightningElement {
    @track callanothercomp = false;
    @api recordId;
    @track error;
    @track licenseRow={};
    @track buttonClicked=false;
    @track isCOS_Telesales = false;
    @track flag=false;
    //added
    @track prfName;
    @track Sfdc=false;
    userId = strUserId;
    @track profileList=[];
    @track licid=this.recordId;
    @track acessCheck=false;
    licenseRecordType;
    loadEvalutionScreen=false;
    parentLicRecId;
    parentLicProdId;
    label={
        Sales_CreateOptnLic,
        Sales_OrderClose,
        Sales_createLic_HTML,
        Sales_validProfile,
        Sales_AccessCheckMsg


    }
    connectedCallback() {
        //get base url
    
        this.baseUrl = window.location;
			
			if (JSON.stringify(this.baseUrl.pathname).includes('Sales_License__c')) {
				var split = JSON.stringify(this.baseUrl.pathname).split('Sales_License__c/');
				console.log('split >>>'+split);
				var split3=split.toString();
				console.log('before if>>'+split3.includes('action/quick/'));
				//avoid quick action page reload
				this.Sfdc=true;
				console.log('sfdc'+this.Sfdc);
				if(!split3.includes('action/quick/')){
					
					console.log('Spli -->' + this.recordId);
					
				}
			 
			}
           // console.log('recordId -->' + recId);
            console.log('strUserId -->' + strUserId);
           
       
        
       
    }
   

 @wire(getRecord, { recordId: '$recordId', fields: ['account.OwnerId'] })
   mom;

   @wire(getRecord, {
    recordId: strUserId,
    fields: [PROFILE_NAME_FIELD]
}) wireuser({
    error,
    data
}) {
    if (error) {
       this.error = error ; 
    } else if (data) {
        this.prfName =data.fields.Profile.value.fields.Name.value;        
    }
}
    @wire (getLicense,{recordId:'$recordId'})
        
    optionProd({error,data}) {
        
        if (error) {
            this.error = error;
        } else if (data) {
            validateUserAccess({userID: strUserId, recordId : data.Id})
            .then((result) =>{
                
                console.log('result ='+result);
                if(result==false){
                    this.acessCheck=true;
                    
                        console.log('user doesnt have access to the record');
                        
                }
                else{
                    var profile=this.label.Sales_validProfile;
                    this.profileList=profile.slice(0,-1);;
                    console.log('this.profileList :'+this.profileList)
                    this.checkUser();
                }
            });
            console.log('data: '+JSON.stringify(data));
            this.licenseRow.licenseId = data.Id;
            this.licenseRow.productId = data.Sales_License_Product__c;
            this.licenseRow.orderItemRecordId = data.Sales_License_Order_Product__c;
            this.licenseRow.toolLicenseType = data.Sales_Tool_License_Type__c;
            this.licenseRow.licenseQty=data.Sales_License_Quantity__c;
            
            this.callanothercomp = true;
            this.licenseRecordType=data.Sales_License_Type__c;
            if(this.licenseRecordType==='Evaluation'){
                this.loadEvalutionScreen=true;
                console.log('loadEvalutionScreen>>'+this.loadEvalutionScreen);
                this.parentLicRecId=data.Sales_License_Product__c;
                this.parentLicProdId=data.Id;
                console.log('parentLicProdId>>'+this.parentLicProdId+'parentLicRecId>>'+this.parentLicRecId);

            }
        }
    }
    

    closeOptionModalAndRefreshAction(){
        this.closeProcessModalAction();
        this.reload();
    }

    reload(){
        setTimeout(function() {
                location.reload(true);
        }, 3000);
    }

    closeProcessModalAction(){
        console.log('close');
        this.dispatchEvent(new CloseActionScreenEvent());
        this.reload();
    }

    showProcessOptionLicense(){
        this.licenseRow.hasOptionProduct=true;
    }

    generateOptionLicense(){
        this.buttonClicked = true;
        this.template.querySelector("c-sales_option-product-license-creation").generateOptionLicense();  
    }

    handleButtonClicked(event){
        const isButtonClicked = event.detail;
        this.buttonClicked = isButtonClicked;
    }
    checkUser(){
        checkUserPermissionSet()
            .then((result) => {
               
                if((this.Sfdc==true &&(result == true || this.profileList.includes(this.prfName)))||this.Sfdc==false){
                    this.isCOS_Telesales=true;
                    this.flag=true;
                    console.log("COS/Telesales User",+result+'cosuser'+this.isCOS_Telesales);
             }
             else{
               
                this.isCOS_Telesales=false;
                this.flag=true;
                console.log(" Not COS/Telesales User",+result+'cosuser'+this.isCOS_Telesales);
               
             }
        });
    }
   
}