import { LightningElement,api,track } from 'lwc';
/*import getOptionProducts from '@salesforce/apex/Sales_ExistingLicenseViewCtrl.getOptionProducts';
import createOptionLicense from '@salesforce/apex/Sales_ExistingLicenseViewCtrl.createOptionLicense';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SalesProductSelection from '@salesforce/label/c.Sales_Product_Selection';
import SalesoptionalHtml from '@salesforce/label/c.Sales_optional_Html';
import SalesSuccessmsg from '@salesforce/label/c.Sales_Success_msg';
import SalesOptionalConfigurationHtml from '@salesforce/label/c.Sales_OptionalConfiguration_Html';
import Sales_optionalproducterror from '@salesforce/label/c.Sales_optionalproducterror';
import Sales_noOfseatErrorMsg from '@salesforce/label/c.Sales_noOfseatErrorMsg';

const columns = [
		{
				label: 'Option Product',
				fieldName: 'OptionProductUrl',
				type: 'url',
				typeAttributes: {
						label: {
								fieldName: 'OptionProductName'
						},
						target: '_blank'
				},
				sortable: true
		}
];*/

export default class Sales_optionProductLicenseCreation extends LightningElement {
		/*@api licenseRowFromParent;
		@track optionProducts;
		@track data;
		@track error;
		@track noOptionAvailable=false;
		@track allOptionProcessed=false;
		@track noOfSeatError=false;
		columnsList = columns;
		label={
			SalesProductSelection,
			SalesoptionalHtml,
			SalesSuccessmsg,
			SalesOptionalConfigurationHtml,
			Sales_optionalproducterror,
			Sales_noOfseatErrorMsg
		}

		connectedCallback(){
			console.log('this.licenseRowFromParent.licenseQty'+this.licenseRowFromParent.licenseQty);
				getOptionProducts({prodId: this.licenseRowFromParent.productId,orderItemId:this.licenseRowFromParent.orderItemRecordId})
						.then(result => {
						if(result.optionNotAvailable){
								this.noOptionAvailable=true;
                                return;
						}
						if((result && result.productOptionReturnList.length>0) && (this.licenseRowFromParent.licenseQty<=0 || this.licenseRowFromParent.licenseQty==undefined || this.licenseRowFromParent.licenseQty==null)){
							console.log('this.licenseRowFromParent.licenseQty'+this.licenseRowFromParent.licenseQty);
                            this.noOfSeatError=true;
							this.showNotification('Error',this.label.Sales_noOfseatErrorMsg,'error');
							const closeOptionModalEvent = new CustomEvent("closeoptionmodalevent");
						    this.dispatchEvent(closeOptionModalEvent);
						}
						if (result && result.productOptionReturnList.length>0) {
								console.log('here'+result.productOptionReturnList.length);
								this.dispatchEvent(new CustomEvent('createoptionlicense'));
								this.optionProducts = result.productOptionReturnList;
								let prodList = [];
								this.optionProducts.forEach(row => {
										let optionProdObj = {
												...row
										};
										if (row.SBQQ__OptionalSKU__c) {
												optionProdObj.OptionProductName = row.SBQQ__OptionalSKU__r.Name;
												optionProdObj.OptionProductUrl = '/lightning/r/Product2/' + row.SBQQ__OptionalSKU__c + '/view';
										}
										prodList.push(optionProdObj);
								})
								this.data = prodList;
								this.error = undefined;
						}
						else if (result && result.productOptionReturnList.length<=0) {
								this.allOptionProcessed=true;
						}
					
				}).catch(error => {
						this.error = error;
						this.data = undefined;
				});
		}
		
		@api generateOptionLicense(){
				let prodList=[];
				const selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
				console.log('@@'+JSON.stringify(selectedRows));
				console.log('@@'+selectedRows.length);
				if(selectedRows.length==0){
					this.dispatchEvent(new CustomEvent("buttonclickedevent", { detail: false }));
						this.showNotification('Error',this.label.SalesProductSelection,'error');
						return;
				}
				selectedRows.forEach(row => {
						prodList.push(row.SBQQ__OptionalSKU__c);
				});
				console.log('@@'+prodList);
				createOptionLicense({licenseId: this.licenseRowFromParent.licenseId,optionProductIdList:prodList})
						.then(result => {
						this.showNotification('Success',this.label.SalesSuccessmsg,'success');
						const closeOptionModalEvent = new CustomEvent("closeoptionmodalevent");
						this.dispatchEvent(closeOptionModalEvent);
				})
						.catch(error => {
							this.dispatchEvent(new CustomEvent("buttonclickedevent", { detail: false }));
							this.showNotificationerror(this.label.Sales_Err,this.label.Sales_optionalproducterror,'error');
						console.log('Error Occured:- '+error);
				});
		}
		
		showNotification(title,msg,variant) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
            mode: 'pester'
        });
        this.dispatchEvent(event);
    }
	showNotificationerror(title,msg,variant) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
            mode: 'sticky'
        });
        this.dispatchEvent(event);
    }*/
}