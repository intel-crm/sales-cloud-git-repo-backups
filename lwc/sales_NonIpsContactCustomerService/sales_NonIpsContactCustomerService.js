import { LightningElement, wire, track} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import fetchNonIPSCaseCreation from '@salesforce/apex/Sales_NonIPSCaseCreation.fetchNonIPSCaseCreation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import validateFieldsCaseCreation from '@salesforce/apex/Sales_NonIPSCaseCreation.validateFieldsCaseCreation';
import SalesAdditionalInfoHtml from '@salesforce/label/c.Sales_Additional_Info_Html';
import SalesDescriptionCustomerService from '@salesforce/label/c.SalesDescriptionCustomerService';
import SalesThankYoumsg from '@salesforce/label/c.Sales_ThankYou_msg';
import SalesReqFields from '@salesforce/label/c.Sales_Req_Fields';
import SalesProvideDetails from '@salesforce/label/c.Sales_Provide_Details';
import SalesErrorMsg from '@salesforce/label/c.Sales_Error_Msg';
import Sales_Required_field_Missing from '@salesforce/label/c.Sales_Required_field_Missing';
import Sales_Submit_Issue from '@salesforce/label/c.Sales_Submit_Issue';
import Sales_Type_Of_License from '@salesforce/label/c.Sales_Type_Of_License';
import Sales_Po from '@salesforce/label/c.Sales_Po';
import Sales_License_Activation from '@salesforce/label/c.Sales_License_Activation';
import Sales_Nic_Guard from '@salesforce/label/c.Sales_Nic_Guard';
import Sales_Product_Name from '@salesforce/label/c.Sales_Product_Name';
import Sales_Description from '@salesforce/label/c.Sales_Description';
import Sales_Contact_Customer_Title from '@salesforce/label/c.Sales_Contact_Customer_Title';
import Sales_Nonips_description from '@salesforce/label/c.Sales_Nonips_description';
import Sales_Nonips_Licenseissue from '@salesforce/label/c.Sales_Nonips_Licenseissue';


export default class LwcNonIpsSubmitCase extends LightningElement {
    @track pickListValues = [];
    @track value;
    @track showLoadingSpinner = false;
    label={ validateFieldsCaseCreation,SalesAdditionalInfoHtml,SalesDescriptionCustomerService,SalesThankYoumsg,SalesReqFields,SalesProvideDetails,SalesErrorMsg,Sales_Required_field_Missing,
        Sales_Submit_Issue,Sales_Type_Of_License,Sales_License_Activation,Sales_Nic_Guard,Sales_Po,Sales_Product_Name,Sales_Description,Sales_Contact_Customer_Title,Sales_Nonips_description,Sales_Nonips_Licenseissue

    };

    @wire( fetchNonIPSCaseCreation )  
    issueType( value ) {
        this.issueLicenseType = value;
        const { data, error } = value;
        if (data) {
            console.log(data);
            this.pickListValues = data;
            this.error = undefined;
        } else if ( error ) {
            console.log('inside error');
            this.error = error;
            this.records = undefined;
        }
        console.log('fetchNonIPSCaseCreation 3'+JSON.stringify(this.pickListValues));
    }  
    handleOnSubmitBtnClick(){
        var isValid = true;
        console.log('element name 1');
        var description;
        var typeofissue;
        try {  this.template.querySelectorAll('lightning-textarea').forEach(element => {
            console.log('element name '+element.value);
            //console.log('element name '+element.name);
            //isValid = isValid && element.reportValidity();
            if(element.name == 'description'){
                description = element.value;
            }
            if(element.name == 'description' && (element.value == null || element.value == '' || element.value == undefined)){
                isValid = false;
               
            }
            console.log('element name '+isValid);
        });
        
        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if(element.name == 'TypeLicenses'){
                typeofissue = element.value;
            }

            if((element.name == 'TypeLicenses' && (element.value == null || element.value == '' || element.value == undefined))){
                isValid = false;
               
            }
            console.log('element name '+isValid);
        });
        var po;
        var serialnumber;
        var hostid;
        var productName;
        if(isValid == true){
          //  showLoadingSpinner = false;
            this.template.querySelectorAll('lightning-input').forEach(element => {
                if((element.name == 'po' || element.name == 'serialnumber' || element.name == 'hostid') && (element.value != null && element.value != '' && element.value != undefined)){
                    isValid = true;
                }
                if(element.name == 'po'){
                    po = element.value;
                }
                if(element.name == 'serialnumber'){
                    serialnumber = element.value;
                }
                if(element.name == 'hostid'){
                    hostid = element.value;
                }
                if(element.name == 'productname'){
                    productName = element.value;
                }
                console.log('element name '+isValid+'po'+po+'serialnumber'+serialnumber+'hostid'+hostid);
            });
            console.log('test 500 '+po + ' '+serialnumber + ' '+hostid);
           this.showLoadingSpinner = true;
            
            if(po!=''||serialnumber!=''||hostid!=''){
            validateFieldsCaseCreation({ po:  po,serialnumber : serialnumber,hostid: hostid,description: description,productName: productName,subject : this.value})
            .then((result) => {
                console.log('validate fields '+result);
                if(result != 'success'){
                    this.showToast('Error',result,'error');
                }
                else{
                    this.showToast('Success',this.label.SalesThankYoumsg,'success');
                   
                    this.template.querySelectorAll('lightning-input[data-id="datafield"]').forEach(element => {
                    element.value = null;
                   });
                   this.template.querySelectorAll('lightning-combobox[data-id="datalicense"]').forEach(element => {
                    element.value = null;
                   });
                   this.template.querySelectorAll('lightning-textarea[data-id="datadescription"]').forEach(element => {
                    element.value = null;
                   });
                   
                   
                }
                this.showLoadingSpinner = false;
            })
            .catch((error) => {
                this.error = error;
                this.contacts = undefined;
                this.showLoadingSpinner = false;
            });
        }
        /*else
        {
            this.showToast('Required Fields Missing','Please fill PO/ActivationCode/HostId','error');
        }*/
        
        }
        if ((isValid == false)&& (typeofissue != null || typeofissue != '' || typeofissue != undefined)&&(description != null || description != '' || description != undefined)) {
            this.showToast(this.label.Sales_Required_field_Missing,this.label.SalesReqFields,'error');
            this.showLoadingSpinner = false;
            console.log('checking false along with fields');

        }
       else if ((isValid == true) && ( po =='' && serialnumber=='' && hostid=='')) {
            this.showToast(this.label.Sales_Required_field_Missing,this.label.SalesProvideDetails,'error');
            this.showLoadingSpinner = false;
            console.log('checking if false');
        }
      /*  else {
            this.showToast('Required Fields Missing','Please provide at least one of these values-PO,License Activation Code/Serial Number or NIC/Host/Guard ID, in order to process your request.','error');
            this.showLoadingSpinner = false;

        }*/
        //this.showLoadingSpinner = false;
      }
        catch (e){
            console.error("An error occurred");
            this.showToast('Error',e,'error');
        }
    }
    showToast(msgTitle,msg,type){
        console.log('In Toast');
        this.dispatchEvent(
            new ShowToastEvent({
                title: msgTitle,
                message: msg,
                variant: type,
                mode: 'sticky'
            }),
        );
    }
  

    handleChange(event) {
        this.value = event.detail.value;
    }
}