import { LightningElement,api,track } from 'lwc';
/*import hostReassignment from '@salesforce/apex/Sales_LicenseRecordPageComponentsUtility.hostReassignment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { NavigationMixin } from 'lightning/navigation';
import licensefileGeneration from '@salesforce/apex/Sales_LicenseGenIntegration_Utility.returnHostIdDetail';
import SalesLicensegenerateerror from '@salesforce/label/c.Sales_License_generate_error';
import SalesLicensegenerateSuccess from '@salesforce/label/c.Sales_License_generate_Success';
import Saleslicensesuccess from '@salesforce/label/c.Sales_license_success';
import Saleshostassignment from '@salesforce/label/c.Sales_host_assignment';
import Sales_yes from '@salesforce/label/c.Sales_yes';
import Sales_no from '@salesforce/label/c.Sales_no';
import Sales_Confirmation from '@salesforce/label/c.Sales_Confirmation';
import Sales_SuccessHostReassignment from '@salesforce/label/c.Sales_SuccessHostReassignment';
*/




export default class ConfirmationDialog extends LightningElement{
    /*@api activationcode; 
    @api hostid; 
    @track isvisibleModal= true;
    @api licenserecordid;
    eventType='';
    //handles button clicks
    label={
        SalesLicensegenerateerror,
        SalesLicensegenerateSuccess,
        Saleslicensesuccess,
        Saleshostassignment,
        Sales_SuccessHostReassignment,
        Sales_no,
        Sales_yes,
        Sales_Confirmation
    };
    handleYes(event){
        console.log('this.activationcode'+this.licenserecordid, 'hostid'+this.hostid);
        hostReassignment({hostId: this.hostid, licenseId : this.licenserecordid})
        .then(result => {
            console.log('result==>'+result);
            var output = result;
                if(output.includes(this.label.Sales_SuccessHostReassignment)){
                    this.licensefileGenerationQueue();
                    this.reloadPage();   
                }else{
                    const evt = new ShowToastEvent({
                            variant:'info',
                            title: output,
                            message: '',
                    });
                    this.dispatchEvent(evt);
                }
            })
        this.isvisibleModal = false;
        }
        
    licensefileGenerationQueue(){
        licensefileGeneration({input : this.hostid,inputType : 'HostId',eventType:this.eventType})
            .then(result => {
                console.log('result=-->'+result);
                if(!result){
                    console.log('inside if=-->'+result);
                    const evt = new ShowToastEvent({
                        variant:'success',
                        title: this.label.SalesLicensegenerateSuccess,
                        message: '',
                    });
                    this.dispatchEvent(evt);
    
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.licenserecordid,
                            objectApiName: 'Sales_License__c', // objectApiName is optional
                            actionName: 'view'
                        }
                    });
                    
                }else{
                    const evt = new ShowToastEvent({
                        variant:'error',
                        title: this.label.SalesLicensegenerateerror,
                        message: '',
                    });
                    this.dispatchEvent(evt);
                }
            })
    }

    handleNo(event){
        this.isvisibleModal = false;
    }

    reloadPage(){

        setTimeout(function() {
                        location.reload(true);
        }, 2000);
}*/

}