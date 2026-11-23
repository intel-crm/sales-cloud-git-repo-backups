import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
//import isCommunity from '@salesforce/apex/Sales_AddNewLicenseAdminController.isCommunity';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import successTxt from '@salesforce/label/c.Sales_Order_Success';
import successMsg from '@salesforce/label/c.Sales_LicenseCreationSuccessMsg';
import Sales_LicErrorMsg1 from '@salesforce/label/c.Sales_LicErrorMsg1';
import Sales_Error_Message from '@salesforce/label/c.Sales_Error_Message';
import Sales_standardlicheading from '@salesforce/label/c.Sales_standardlicheading';
import Sales_License_Info from '@salesforce/label/c.Sales_License_Info';
import Sales_License_product_Info from '@salesforce/label/c.Sales_License_product_Info';
import Sales_OrderInfo_HTML from '@salesforce/label/c.Sales_OrderInfo_HTML';
import Sales_Licensing_Info from '@salesforce/label/c.Sales_Licensing_Info';


export default class Sales_CreateNewLicenseOnNewButton extends NavigationMixin(LightningElement) {
		  label={successTxt,successMsg,Sales_LicErrorMsg1,Sales_Error_Message,Sales_standardlicheading,Sales_License_Info,Sales_License_product_Info,Sales_OrderInfo_HTML,
					Sales_Licensing_Info	};
    @api isInternal="true";
    isSfdc=false;
    resetpage = false;
    redirect = true;
   
		
    /*handleOnLoad(event) {
       console.log('isSfdc==>' + this.isSfdc);
     //If the below method returns true -> Internal Salesforce,  else if false then -> Salesforce Community
        isCommunity()
            .then(result => {
                console.log('Is Internal Salesforce result:' + result);
						console.log('isSfdc==>' + this.isSfdc);
                this.isInternal = result;
               if(this.isInternal==false){
						 console.log('this.redirect>>' + this.redirect);
                           this.isSfdc=false;
                           }
						       else{
									this.isSfdc=true;
									 }
                    })
                
              
            .catch(error => {
                this.fireToastEvent(this.label.errorMsg, error.body.message, 'error', 'dismissable');
            });

       
    }*/
  
    handleCancelNew(){
           this.resetpage=true;
            console.log('internal user');
            this[NavigationMixin.Navigate]({
              type: 'standard__objectPage',
              attributes: {
                  objectApiName: 'Sales_License__c',
                  actionName: 'list'
              },
              state: 'recent'
          }); 
				 if (this.resetpage == true) {
            //this.handleReset();
						// console.log('resetpage'+this.resetpage);
            eval("$A.get('e.force:refreshView').fire();");
        }
        }
		  handleSubmit(event){
              console.log('In Submit');
            let fields = event.detail.fields;
            this.template.querySelector('lightning-record-edit-form');
       //Added by Chaithanya -- Focuses on Top of the Modal before we save, benefit for Error Banner Focus
        const topDiv = this.template.querySelector('[data-id="focusOnErrorBannerId"]');
        topDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
        }
	
        handleSuccess(event) {
            
            console.log('this.iserror>>' + this.iserror);
						this.resetpage=true;
         
            const evt = new ShowToastEvent({
                variant: 'success',
                title: this.label.successTxt,
                message: this.label.successMsg,
            });
            this.dispatchEvent(evt);
            console.log('this.redirect>>' + this.redirect);
            if (this.redirect == true) {
                var recId = event.detail.id;
                console.log('Order record', event.detail.id);
                
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: recId,
                        objectApiName: 'Sales_License__c',
                        actionName: 'view'
                    }
                });
            }
						 if (this.resetpage == true) {
            //this.handleReset();
            eval("$A.get('e.force:refreshView').fire();");
        }
        
        }
        
}