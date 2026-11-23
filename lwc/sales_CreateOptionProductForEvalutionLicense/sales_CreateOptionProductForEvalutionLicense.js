/* eslint-disable no-console */
import { LightningElement,api,wire,track} from 'lwc';
import getOptionProducts from '@salesforce/apex/Sales_ExistingLicenseViewCtrl.getOptionProducts';
import createOptnLic from '@salesforce/apex/Sales_CreateLicenseProvider.createOptnLic';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 import Sales_nextmsg from '@salesforce/label/c.Sales_nextmsg';
 import Sales_Optional from '@salesforce/label/c.Sales_Optional';
 import SalesProductSelection from '@salesforce/label/c.Sales_Product_Selection';
 import Sales_Lic_Created_Success from '@salesforce/label/c.Sales_Lic_Created_Success';
 import SalesOptionalConfigurationHtml from '@salesforce/label/c.Sales_OptionalConfiguration_Html';
 import { NavigationMixin } from 'lightning/navigation';
 import Sales_createLic_HTML from '@salesforce/label/c.Sales_createLic_HTML';
 import Sales_OrderClose from '@salesforce/label/c.Sales_OrderClose';
 import { CloseActionScreenEvent } from 'lightning/actions';
const columns = [
	{
			label: 'Optional Product',
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
];

export default class Sales_CreateOptionProductForEvalutionLicense extends NavigationMixin(LightningElement) {
		@api parentLicprodId;
        @api orderItemId='';
		@api parentLicId;
		@api parentActivationCode;
		@api primarycontact;
		@api licensetypevalue;
		@api optnCreated;
		@track allOptionProcessed=false;
		@track Sfdc=false;
		@track buttonClicked=false;
		optionProducts;
		result;
	    errors;
		showError=false;
		noOptionAvailable=false;
		optionProducts;
		columnsList = columns;
		prodAvailable=false;
		
		connectedCallback() {
			//get base url
			this.baseUrl = window.location;
			console.log('Base location -->' + this.baseUrl);
	
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
		}
		label={Sales_nextmsg,SalesProductSelection,Sales_Optional,Sales_Lic_Created_Success,SalesOptionalConfigurationHtml,Sales_OrderClose,Sales_createLic_HTML};
		
        @wire (getOptionProducts,{prodId:'$parentLicprodId',orderItemId:'$orderItemId',licenseId:'$parentLicId'})
        
		optionProd({error,data}){
            if(data){
                console.log('data>>>>>'+JSON.stringify(data));
				if(data.optionNotAvailable){
					this.buttonClicked=true;
					this.noOptionAvailable=true;
					
					return;
				}
				else if(data.productOptionReturnList.length>0){
					this.prodAvailable=true;
					this.optionProducts = data.productOptionReturnList;
					console.log('this.optionProducts>>>'+JSON.stringify(this.optionProducts));
					let prodList = [];
									this.optionProducts.forEach(row => {
											let optionProdObj = {
													...row
											};
											if (row.SBQQ__OptionalSKU__c) {
													optionProdObj.OptionProductName = row.SBQQ__OptionalSKU__r.Name;
													//optionProdObj.OptionProductUrl = '/lightning/r/Product2/' + row.SBQQ__OptionalSKU__c + '/view';
													optionProdObj.OptionProductUrl = '/lightning/r/Product2/' + row.Id + '/view';

											}
											prodList.push(optionProdObj);
									})
					this.result = prodList;
					console.log('this.result>>>'+JSON.stringify(this.result));
					this.errors=undefined;	
				}
				else{
					this.buttonClicked=true;
					this.allOptionProcessed=true;
			}				
            }
            else if(error){
                this.result=undefined;
                this.errors=error;
            }
        }
		handleClose(){
			console.log('close');
			this.dispatchEvent(new CloseActionScreenEvent());
		}
	   @api handleNext(){
		this.buttonClicked=true;
			let prodList=[];
				const selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
				console.log('selectedRows>>'+JSON.stringify(selectedRows));
				if(selectedRows.length==0 && this.Sfdc==true){
					this.buttonClicked=false;
					this.showNotification('Error',this.label.SalesProductSelection,'error');
					return;
			}
				selectedRows.forEach(row => {
						prodList.push(row.SBQQ__OptionalSKU__c);
				});
				console.log('prodList>>>>'+prodList);
				//calling apex method to create optional lic
				createOptnLic({licId: this.parentLicId,optProdIds:prodList})
				.then(result => {
					if(result){
						this.showNotification('Success',this.label.Sales_Lic_Created_Success,'success');
					}
					//navigate to parent and fire close modal
					const closemodal = new CustomEvent("closemodal");
				    this.dispatchEvent(closemodal);
					if(this.Sfdc==true){
						this[NavigationMixin.Navigate]({
							type: 'standard__recordPage',
							attributes: {
								recordId: this.parentLicId,
								objectApiName: 'Sales_License__c', // objectApiName is optional
								actionName: 'view'
							}
						});
					//  alert('before reload');
				  this.reloadPage();
					}
				
		})
				.catch(error => {
					this.errors=error;
					console.log('Error Occured:- '+error);
				 
		});
		
		}
		
	
		showNotification(title,msg,variant) {
			const event = new ShowToastEvent({
				title: title,
				message: msg,
				variant: variant,
				mode: 'dismissable'
			});
			this.dispatchEvent(event);
		}
			
		handleRow(){
            
        }
		
		reloadPage(){

			setTimeout(function() {
			location.reload(true);
			}, 2000);    
		}
    	
}