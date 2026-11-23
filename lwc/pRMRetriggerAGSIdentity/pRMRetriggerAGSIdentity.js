import { LightningElement,track,api,wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import AGS_IDENTITY_CREATION_FAILED from '@salesforce/label/c.PRM_ACR_Status_AGS_Identity_Creation_Failed';
import createIdentityInAGSSync1 from '@salesforce/apex/PRM_AGS_IdentityCreation.createIdentityInAGSSync1';
import getACRList from '@salesforce/apex/PRM_AGS_IdentityCreation.getACRList'; 
import SendEmailVerificationAndCreateIdentityInAGS from '@salesforce/apex/PRM_AGS_IdentityCreation.SendEmailVerificationAndCreateIdentityInAGS'; 
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import CONTACT_FIELD from '@salesforce/schema/PRM_Account_Contact_Relationship__c.PRM_Contact_Id__c';
import ENTERPRISE_FIELD from '@salesforce/schema/PRM_Account_Contact_Relationship__c.PRM_Contact_Id__r.Core_Enterprise_Id__c';
import AGS_IDENTITY_FAILED from '@salesforce/schema/PRM_Account_Contact_Relationship__c.PRM_AGS_Identity_Creation_Fail__c';



const fields = [CONTACT_FIELD,ENTERPRISE_FIELD,AGS_IDENTITY_FAILED];
export default class PRMRetriggerAGSIdentity extends LightningElement {
    @api recordId;
    @track conId;
    showConfirm = false;
    @track acrList = [];

    enterpriseCheck =false;
    sendEmail = false;
    recordDetail;
    identityExist = false;

    // Below method will fetch ACR Record ID and fetch Contact ID,Enterprise ID of Contact and ACR Status from ACR record.
    @wire(getRecord, { recordId: '$recordId', fields })
    wiredRecord({error, data}) {
        if (error) {
            console.log('in error block',error);
        } else if (data) {
           this.recordDetail = data;
           this.conId = getFieldValue( this.recordDetail, CONTACT_FIELD);
           let enterpriseValue = getFieldValue( this.recordDetail, ENTERPRISE_FIELD);
           let acrAgsIdentityFailed = getFieldValue( this.recordDetail, AGS_IDENTITY_FAILED);
          
           if(acrAgsIdentityFailed == true){
               console.log('Inside  First If');
                if(enterpriseValue == null){
                    console.log('Inside  Second If');
                    this.enterpriseCheck = true;
                    this.showConfirm = true;
                }else{
                    this.sendEmail = true;
                    console.log('Inside Else Condition');
                    if(this.conId != null ){
                        getACRList({contactId : this.conId})
                        .then(result => {
                            console.log('ACR List',JSON.stringify(result));
                            this.acrList = result;
                            this.showConfirm = true;

                        })
                        .catch(error => {
                            console.log('Error occured in getrecord method');
                        });   
                    }                   

                }
           }else if(acrAgsIdentityFailed == false){
            this.identityExist = true;
           }
           
        }
    }
  
    //This method will call createIdentityInAGSSync method and will create an Enterprise ID on Contact.
    handleConfirm(){
        if(this.enterpriseCheck && this.conId != null ){
        createIdentityInAGSSync1({contactId:this.conId,acrID:'fromLWC'})
        .then(result => {
            const evt = new ShowToastEvent({
                title: 'Info',
                message: 'AGS Identity Creation Request Submitted Succesfully',
                variant: 'info',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.dispatchEvent(new CloseActionScreenEvent());
        })
        .catch(error => {  
            console.log('Error occured while calling createIdentityInAGSSync');
        });
        }else if(!this.enterpriseCheck && this.acrList !=null){
            SendEmailVerificationAndCreateIdentityInAGS({accConRelList : this.acrList})
            .then(result => {
                const evt = new ShowToastEvent({
                    title: 'Info',
                    message: 'Email has been sent to the user for confirmation',
                    variant: 'info',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {  
                console.log('Error occured while calling SendEmailVerificationAndCreateIdentityInAGS');
            });
            }
        
    }

    closeModal(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    
    
}