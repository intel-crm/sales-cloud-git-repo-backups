import { LightningElement, api, track } from 'lwc';
import isCommunity from '@salesforce/apex/Sales_AddNewLicenseAdminController.isCommunity';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from 'lightning/navigation';
import updateLicenses from '@salesforce/apex/Sales_GenLicByActivationCondeController.updateLiceseRecord';
import validateActivationCode from '@salesforce/apex/Sales_GenLicByActivationCondeController.validateLicenses';
import LICENSE_OBJECT from '@salesforce/schema/Sales_License__c';
import fetchLicenseDetails from '@salesforce/apex/Sales_GenLicByActivationCondeController.fetchLicenseDetails';
import PRIMARY_ADMIN_CONTACT_FIELD from '@salesforce/schema/Sales_License__c.Sales_License_Primary_Admin_Contact__c';
import ACTIVATION_CODE from '@salesforce/schema/Sales_License__c.Sales_License_Activation_Code__c';
import PRIMARY_COMPUTER from '@salesforce/schema/Sales_License__c.Sales_License_Host_Node_Id__c';
import LICENSE_TYPE from '@salesforce/schema/Sales_License__c.Sales_Tool_License_Type__c';
import SalesOrderClose from '@salesforce/label/c.Sales_OrderClose';
import SalesPrimaryAdminHTML from '@salesforce/label/c.Sales_PrimaryAdmin_HTML';
import SalesLACHTML from '@salesforce/label/c.Sales_LAC_HTML';
import SalesSerialError from '@salesforce/label/c.Sales_SerialError';
import SalesAddSeatRenewError from '@salesforce/label/c.Sales_AddSeatRenewError';
import Saleslicinfotitle from '@salesforce/label/c.Sales_licinfotitle';
import SalesActivationCodeTitle from '@salesforce/label/c.Sales_ActivationCodeTitle';
import salesreq from '@salesforce/label/c.sales_req';
import SalessearchErr from '@salesforce/label/c.Sales_searchErr';
import Sales_OrderClose from '@salesforce/label/c.Sales_OrderClose';
import Sales_Cancel from '@salesforce/label/c.Sales_Cancel';
import Sales_nextmsg from '@salesforce/label/c.Sales_nextmsg';
import Sales_Err from '@salesforce/label/c.Sales_Err';
import Sales_ActivationCode_Cancle_Nav from '@salesforce/label/c.Sales_ActivationCode_Cancle_Nav';
import Sales_Statuserror  from '@salesforce/label/c.Sales_LicenseStatusError';
//import BypassRehostForCustomOps from '@salesforce/apex/Sales_ValidateUpdateOnHost.BypassRehostForCustomOps';


const columns = [
  {label: 'License Name', fieldName: 'licenseName', type: 'text', initialwidth:'20'},
  {label: 'License Activation Code', fieldName: 'licenseActivationCode', type: 'text', finalwidth:600},
  {label: 'Product Name', fieldName: 'productName', type: 'text', initialwidth:'20%'},
  {label: 'No of Seats', fieldName: 'noOfSeats', type: 'text', initialwidth:'20'},
  {label: 'Tool License Type', fieldName: 'licenseToolType', type: 'text', initialwidth:'20'}
];

export default class Sales_GenerateLicenseByActivationCode extends NavigationMixin(LightningElement) {
    @api fromlac=false;
    @api isInternal = false;
    @api licRecordIds;
    @track isLoaded;
    @api primarycontact;
    @api licensetypevalue;
    @api licenseId;
    @track showModal=true;
    @track columns = columns;
    @api isDataFound;
    @api existingcomputername;
    @api licenseToolType;
    @api webdisplayflag;
    @api isHost;
    @api isValidateMentorGraphic = false;
    @api licType;
    @api showGenerateLicenseForm = false;
    @api licenseStatus;
    primaryAdminContact;
    primaryComputer;
    licenseduser;
    activationCode;
    selectedLicense;
    @api licenserecordId;
    @api hostlist;
    label={
      SalesOrderClose,
      SalesPrimaryAdminHTML,
      SalesLACHTML,
      SalesSerialError,
      SalesAddSeatRenewError,
      SalesActivationCodeTitle,
      Saleslicinfotitle,
      salesreq,
      SalessearchErr,
      Sales_OrderClose,
      Sales_Cancel,
      Sales_nextmsg,
      Sales_Err,
      Sales_ActivationCode_Cancle_Nav,
      Sales_Statuserror


    }

    connectedCallback() {
      this.isLoaded = true;
        console.log('in init');
        isCommunity()
          .then(result => {
            console.log('result:'+result);
            this.isInternal = result;             
      })
      .catch(error => {
        const evt = new ShowToastEvent({
          title: this.label.Sales_Err,
          message: error.body.message,
          variant: 'error',
          mode: 'sticky'
      });
        this.dispatchEvent(evt);
      });   
      }

  
      get disableSearch(){
        if(this.isInternal == true){
          if((this.primaryAdminContact==undefined || this.primaryAdminContact==null || this.primaryAdminContact=='') 
          || (this.activationCode==undefined || this.activationCode==null || this.activationCode=='' || this.activationCode==' ')){
            return true;
          }else{
            return false;
          }
        }else{
          return false;
        }
      }

      handleRowSelection(event){
        
        var selectedRows=event.detail.selectedRows;
        this.selectedLicense = selectedRows;
        this.licenseId = selectedRows[0].licenserecordId;
        this.licenseToolType = selectedRows[0].licenseToolType;
        this.isHost = selectedRows[0].isHost;
        this.webdisplayflag =  selectedRows[0].webdisplayflag;
        this.licType = selectedRows[0].licType;
        this.licenseStatus = selectedRows[0].licenseStatus;
        console.log('this.webdisplayflag==>'+this.webdisplayflag);
        console.log('this.isHost==>'+this.isHost);
        console.log('this.licType==>'+this.licType);
        console.log('this.licenseStatus==>'+this.licenseStatus);
    }

      handleInputFieldChange(event){   
        this.selectedLicense = null;
        var fieldName = event.target.fieldName;
this.isDataFound = false;
        switch(fieldName) {
          case PRIMARY_ADMIN_CONTACT_FIELD.fieldApiName:
            this.primaryAdminContact = event.target.value;
            break;
          case ACTIVATION_CODE.fieldApiName:
            this.activationCode = event.target.value;
            break;
            case PRIMARY_COMPUTER.fieldApiName:
              this.primaryComputer = event.target.value;
            break; 
            case LICENSE_TYPE.fieldApiName:
            this.licenseToolType = event.target.value;
            break;            
        }    
        console.log('primary line 146'+ this.primaryAdminContact);
      }

      get disableNext(){
        if(this.selectedLicense==undefined || this.selectedLicense==null){
          return true;
        }else{
          return false;
        }
      }
      

  validateinputactivationCode(){
    this.selectedLicense = null;
    this.isLoaded = true;
    this.isDataFound = false;
    let licRecord = {
      sobjectType : LICENSE_OBJECT.objectApiName,
      Sales_License_Primary_Admin_Contact__c : this.primaryAdminContact,
      Sales_License_Activation_Code__c : this.activationCode,
    }
    fetchLicenseDetails({activationCode:this.activationCode})
    .then(result => {
      console.log('result'+result);
      if(result!=null && result!=''){
        console.log('result'+result);
        console.log('this.licRecordIds[0].licType-->'+result[0].licType);
        this.licRecordIds = result;
        if(result[0]!=undefined && (result[0].licType=='Add Seat' || result[0].licType=='Renewal' || result[0].productToolType=='ADD SEAT' || result[0].productToolType=='RENEWAL')){
          console.log('Inside iffff-->');
          const evt = new ShowToastEvent({
            variant: 'error',
            title: this.label.Sales_Err,
            mode: 'sticky',
            message: this.label.SalesAddSeatRenewError
          });
          this.dispatchEvent(evt);
        }
       /* else if(result[0].licenseStatus == 'Renewals Applied' || this.licenseStatus=='Cancelled'){
          const evt = new ShowToastEvent({
            title: this.label.Sales_Err,
            message: this.label.Sales_Statuserror,
            variant: 'error',
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
        }*/
      else{
        console.log('inside else part');

        validateActivationCode({
            licRecord: licRecord
        })
        .then(result => {
          console.log('result'+result);
          if(result!=null && result!=''){
            console.log('result'+result);
            this.licRecordIds = result;
            this.isDataFound = true;
            this.hostlist = result;
        }else{
          this.isDataFound=false;
            const evt = new ShowToastEvent({
                title: this.label.Sales_Err,
                message: this.label.SalesSerialError,//SalesAddSeatRenewError,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);    
            this.isLoaded = true;   
          }
        });





      }
    }else{
      /*console.log('consode else ');
      this.isDataFound=false;
        const evt = new ShowToastEvent({
            title: 'Error',
            message: this.label.SalesSerialError,//SalesAddSeatRenewError,
            variant: 'error',
            mode: 'sticky'
        });
        this.dispatchEvent(evt);    
        this.isLoaded = true;   
      }
    })*/
    validateActivationCode({
      licRecord: licRecord
      })
      .then(result => {
        console.log('result'+result);
        if(result!=null && result!=''){
          console.log('result'+result);
          this.licRecordIds = result;
          this.isDataFound = true;
          this.hostlist = result;
      }else{
        this.isDataFound=false;
          const evt = new ShowToastEvent({
              title: this.label.Sales_Err,
              message: this.label.SalesSerialError,//SalesAddSeatRenewError,
              variant: 'error',
              mode: 'sticky'
          });
          this.dispatchEvent(evt);    
          this.isLoaded = true;   
        }
      });
    }
  })
}


    handleOnLoad() {
      this.isLoaded = true;
    }

      handleOnSubmitBtnClick(event) {
        /*console.log('in btn click method'+this.selectedLicense);
        if (!this.validateFields()) {
          const toast = new ShowToastEvent({
              message: "Review all errors to correct your data.",
              variant: "error",
          });
          this.dispatchEvent(toast);
      }else if(this.selectedLicense==undefined || this.webdisplayflag==false){
        console.log('Inside else if');
          const evt = new ShowToastEvent({
            title: 'Error',
            message: 'Cannot generate license with this Serial#. Please contact Customer Service for support.',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);  
      }
      else {
        console.log('Inside else'+this.primaryAdminContact);
        this.isLoaded = false;
           
            let licRecord = {
              sobjectType : LICENSE_OBJECT.objectApiName,
              Sales_License_Primary_Admin_Contact__c : this.primaryAdminContact,
              Sales_License_Activation_Code__c : this.activationCode,
            }
            console.log('licRecord:'+ JSON.stringify(licRecord));
            getLicensesByActivationCode({
                licRecord: licRecord
        })
          .then(result => {
              console.log('result'+result);
              this.licRecordIds = result; 
              console.log('this.licRecordIds[0]:'+this.licRecordIds[0]);
              console.log('this.licRecordIds[0]:'+this.licRecordIds);
              if(this.licRecordIds != undefined && this.licRecordIds.length != 0 && this.licRecordIds!=''){
              
                console.log('showing child');
                this.isLoaded = true;
                this.showGenerateLicenseForm = true;
                //this.showModal = false;
                
            }else{
              console.log('in error');
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Cannot generate license with this Serial#. Please contact Customer Service for support.',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);    
                this.isLoaded = false;         
            }
            
          })    
          .catch(error => {
          console.log('error'+error);
            const evt = new ShowToastEvent({
              title: 'Error',
              message: error.body.message,
              variant: 'error',
              mode: 'dismissable'
          });
          this.dispatchEvent(evt);
          this.isLoaded = true;   
          });  
          
        } */
      
        if(this.licType=='Add Seat' || this.licType=='Renewal'){
          const evt = new ShowToastEvent({
            variant: 'error',
            title: this.label.Sales_Err,
            mode: 'sticky',
            message: this.label.SalesAddSeatRenewError,
          });
          this.dispatchEvent(evt);
        }else{
          this.isLoaded = true;
          console.log('lic id  and primary '+this.licenseId+""+this.primaryAdminContact);
          updateLicenses({
            licRecord: this.licenseId,
            primaryAdmin : this.primaryAdminContact
        })
        .then(result => {
          if(result){
            this.showGenerateLicenseForm = true; 
            this.fromlac=true;
          }else{
            const evt = new ShowToastEvent({
              title: this.label.Sales_Err,
              message: this.label.SalesSerialError,//SalesAddSeatRenewError,
              variant: 'error',
              mode: 'sticky'
          });
          this.dispatchEvent(evt);    
          this.isLoaded = true;   
        }
      });
    }
  }   

      validateFields() {
        return [...this.template.querySelectorAll("lightning-input-field")].reduce((validSoFar, field) => {
            // Return whether all fields up to this point are valid and whether current field is valid
            // reportValidity returns validity and also displays/clear message on element based on validity
            return (validSoFar && field.reportValidity());
        }, true);
    }

    navigateToListView() {
      
        if(this.isInternal == true){
          this.reloadPage();
            this[NavigationMixin.Navigate]({
              type: 'standard__objectPage',
              attributes: {
                  objectApiName: 'Sales_License__c',
                  actionName: 'list'
              },
              state: 'recent'
          });  
          
        }else{
          
          this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
              "url": this.label.Sales_ActivationCode_Cancle_Nav
            }
        });  
        }
      }

      
    reloadPage() {

      setTimeout(function () {
          location.reload(true);
      }, 2000);
  }
  closeModal(){ 
    
    if(this.isInternal == true){
      this.reloadPage();
      this[NavigationMixin.Navigate]({
        type: 'standard__objectPage',
        attributes: {
            objectApiName: 'Sales_License__c',
            actionName: 'list'
        },
        state: 'recent'
    });  
   }
    else{
      this.showModal=false;
    }
  }
  key_Code_Checker(event) {
    if (event.keyCode === 13) {
      event.preventDefault();
    }
  }

}