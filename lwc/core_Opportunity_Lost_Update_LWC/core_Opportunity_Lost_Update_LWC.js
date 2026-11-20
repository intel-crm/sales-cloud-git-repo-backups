import { LightningElement, api, wire,track} from 'lwc';

import { getRecord } from 'lightning/uiRecordApi';
import {  getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import OPPORTUNITY_LINEITEM from '@salesforce/schema/OpportunityLineItem';
import COMPETITOR_FIELD from '@salesforce/schema/OpportunityLineItem.Core_Competitor__c';	
import getOppItemPickListValues from '@salesforce/apex/Core_CRM_Utility.getOppItemPickListValues';
import getDependantPickListValues from '@salesforce/apex/Core_CRM_Utility.getDependantPickListValues';
import updateCompetitorData from '@salesforce/apex/Core_CRM_Utility.updateCompetitorData';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {CloseActionScreenEvent} from 'lightning/actions';

const FIELDS = [
'Opportunity.StageName',
'Opportunity.Core_System_Prod_Competitor_Empty_Count__c',
'Opportunity.Core_Opportunity_Coverage_Nm__c',
'Opportunity.Core_No_of_On_Hold_Opportunity_Products__c',
'Opportunity.Core_Coverage_Type_Nm__c',
];
const openStages = ['Qualify','Define','Develop','Design'];
const lostCancelled = ['Lost','Cancelled'];
const prodLost = 'Production Lost' ;
const productionLostCancelled = ['Production Lost','Production Cancelled'];
const designWinProductionWin = ['Design Win','Production Win'];


export default class Core_Opportunity_Lost_Update_LWC extends LightningElement {

@api recordId;
@api bypassExecuting = false;
@api disableButton = false;
isReadOnly = false;
showComp = true;
isCompetitorDisabled = true;
disableComboBox = true;
StageValue = '';
options =[];
value ='';

textvalue = '';
@track competitorCount = false;
@track competitorProdValue;
@track competitorValue;
@track toastTitle;
@track toastMessage;
@track toastVariant;
@track lossCancelReason;
@track lossCancelDetails;
opportunity = undefined;
accountRecordTypeId ;
//@track loaded = false;
@track compOptions ;
@track compProdOptions;
@track response ='';
compValue = '';
@track selectedComp ;
@track selectedCompProd ;
@track isPartnerOppty = false;
@track isIntelOppty = false;
FIELD = 'OpportunityLineItem.Core_Competitor__c';
@track isPartnerDealOppty = false;




@wire(getRecord, { recordId: '$recordId', fields: FIELDS })
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
		this.options = this.handleOptions();
	}

	
	this.compOptions = '';
	getOppItemPickListValues( {  fieldApiName: this.FIELD })
	.then(data => {
		
		this.compOptions = data;
			
		})
		.catch(error => {
			console.log('error-'+error);
		});

}

get opportunityCompetitorcount(){
	//console.log('competior count'+this.opportunity.fields.Core_System_Prod_Competitor_Empty_Count__c.value);
	return this.opportunity.fields.Core_System_Prod_Competitor_Empty_Count__c.value;
	
	
}

get opportunityStage(){
//	console.log('competior count2'+this.opportunity.fields.StageName.value);
	return this.opportunity.fields.StageName.value;
	
}

get onHoldProducts(){
	return this.opportunity.fields.Core_No_of_On_Hold_Opportunity_Products__c.value;
	
}

get opportunityCoverage(){
		console.log('competior count2'+this.opportunity.fields.Core_Opportunity_Coverage_Nm__c.value);
	return this.opportunity.fields.Core_Opportunity_Coverage_Nm__c.value;
}

get coverageType(){
	console.log('coverage type '+this.opportunity.fields.Core_Coverage_Type_Nm__c.value);
	return this.opportunity.fields.Core_Coverage_Type_Nm__c.value;
}


handleOptions() {
		console.log('----'+this.opportunityStage);

	/*if(this.opportunityCompetitorcount > 0 &&  this.opportunityStage != 'Production Cancelled' &&( this.opportunityStage != '' || this.opportunityStage != undefined)  ){
	this.competitorCount = true; 
	}*/
		if(this.opportunityCoverage.includes('Partner') && this.coverageType=='Deal Registration'){
			this.isPartnerDealOppty = true;
		}

	
		if(openStages.includes(this.opportunityStage) || lostCancelled.includes(this.opportunityStage) ){

		this.showCompetitorData();
		
		if(this.opportunityCoverage.includes('Partner')){
			
		this.isPartnerOppty = true;
		return [{
				label: 'Lost',
				value: 'option1'
			},{
				label: 'Cancelled',
				value: 'option2'
			},
			
			];
		}else{
		this.isIntelOppty = true;
			return [{
				label: 'Lost',
				value: 'option1'
			},
			
			];

		}
		}
	else if(productionLostCancelled.includes(this.opportunityStage)||designWinProductionWin.includes(this.opportunityStage)){
		
		if(this.opportunityCoverage.includes('Partner')){
			this.isPartnerOppty = true;
		}else{
			this.isIntelOppty = true;	
		}
		
		return [{
			label: 'Production Lost',
			value: 'option3'
		},
		{
			label: 'Production Cancelled',
			value: 'option4'
		},
		];
	}
	
}



handleSubmit(event) {

//	console.log('StageValue--'+this.StageValue);
		console.log('lossCancelReason--'+this.lossCancelReason);
		console.log('lossDetails--'+this.lossDetails);
		console.log('onHoldProducts--'+this.onHoldProducts);
		console.log('selectedComp--'+this.selectedComp);
		console.log('selectedCompProd--'+this.selectedCompProd);

	var lossDetails = this.template.querySelector('lightning-input-field.detailsId').value ;
	this.disableButton = true;
	var isValid = true;
	this.toastTitle = "Error";
	this.toastVariant = "error";
	console.log('isValid'+isValid);
	if(this.StageValue == '' || this.StageValue == undefined){
		console.log('StageValue--'+this.StageValue);
            this.toastMessage = 'Please select Stage';
			this.showToast(this.toastTitle, this.toastMessage, this.toastVariant);
			this.disableButton = false;
			isValid = false;
			
	}else if( (this.lossCancelReason == '' || this.lossCancelReason == undefined )
	||  (lossDetails == '' || lossDetails == undefined) ){

		console.log('lossCancelReason--'+this.lossCancelReason);
		console.log('lossDetails--'+this.lossDetails);

		this.toastMessage = 'Please provide Loss/ Cancel related data';
			this.showToast(this.toastTitle, this.toastMessage, this.toastVariant);
			this.disableButton = false;
			isValid = false;

	}
	else if(this.onHoldProducts > 0){

console.log('onHoldProducts--'+this.onHoldProducts);
            this.toastMessage = 'You cannot Close Opportunity when there is an On-Hold product';
			this.showToast(this.toastTitle, this.toastMessage, this.toastVariant);
			this.disableButton = false;
			isValid = false;
			

	}else if(((this.selectedComp == '' || this.selectedComp == undefined ) || (this.selectedCompProd == '' || this.selectedCompProd == undefined))
		&& (this.competitorCount == true)){
			console.log('check--'+this.selectedComp +'---'+this.selectedCompProd);
			
            this.toastMessage = 'Please provide Competitor Data';
			this.showToast(this.toastTitle, this.toastMessage, this.toastVariant);
			this.disableButton = false;
			isValid = false;
			

	
	} else if((this.selectedComp != '' || this.selectedComp != undefined ) && 
	(this.selectedCompProd != '' || this.selectedCompProd != undefined) && (this.competitorCount == true) 
		){
			console.log('inside saving');
		this.bypassExecuting = true;
		this.updateCompetData();
		
	}else if(isValid){
		console.log('isnide last');
		this.bypassExecuting = true;
		this.template.querySelector('lightning-record-edit-form').submit();
		//this.bypassExecuting = false;
		
		
	}
	

	window.console.log("You selected value from lookUP LWC---->>>> ");
	console.log('onsubmit event recordEditForm' + event.detail.fields);
}

updateCompetData(){

	updateCompetitorData( {  competitor: this.selectedComp , competitorProduct : this.selectedCompProd ,textvalue: this.textvalue ,recordID :this.recordId })
	.then(data => {
		console.log('Update competitor data:'+data);
		if(data.includes('Success')){
			this.template.querySelector('lightning-record-edit-form').submit();
		
			this.response = 'Competitor Data Updated Succesfully';
			
			this.toastTitle = "Success";
            this.toastMessage = 'Competitor Data Updated Succesfully';
            this.toastVariant = "success";
			this.showToast(this.toastTitle, this.toastMessage, this.toastVariant);

		}else if(data.includes('Info:')){
			
			this.toastTitle = "Info";
            this.toastMessage = data;
            this.toastVariant = "Info";
			this.showToast(this.toastTitle, this.toastMessage, this.toastVariant);


		}else{

			this.toastTitle = "Error";
            this.toastMessage = data;
            this.toastVariant = "Error";
			this.showToast(this.toastTitle, this.toastMessage, this.toastVariant);

		}
	
		
		})
		.catch(error => {
			console.log('error-'+error);
		});
	
}

handleError(evt){
	this.bypassExecuting = false;
	this.disableButton = false;
}

handleSuccess(event) {
	this.bypassExecuting = false;
	this.disableButton = false;
	if (this.recordId !== null) {           
		// Close the modal window and display a success toast
		this.dispatchEvent(new CloseActionScreenEvent());			
		this.dispatchEvent(new ShowToastEvent({
			title: "SUCCESS!",
			message: "Opportunity Record Updated!",
			variant: "success",
		}), );			
	} 
}

handleChange(event) {
	if (event.detail.value === 'option1') {
		this.isReadOnly = false;
		this.StageValue = 'Lost';
		this.showCompetitorData();

	} else if (event.detail.value === 'option2') {
		this.StageValue = 'Cancelled';
		this.isReadOnly = false;
	} else if (event.detail.value === 'option3') {
		this.StageValue = 'Production Lost';
		this.isReadOnly = false;
		this.showCompetitorData();

	} else if (event.detail.value === 'option4') {
		console.log('Inside PC' + this.opportunityCompetitorcount);
		this.StageValue = 'Production Cancelled';
		this.isReadOnly = false;
		this.competitorCount = false;
	
	} else {
		this.isReadOnly = false;
	}
}

handleLossCancelReason(event){

	this.isCompetitorDisabled = true;
	this.lossCancelReason = event.detail.value;
	console.log('lossCancelReason---'+this.lossCancelReason);

	if( (this.lossCancelReason=='Customer Discontinued Project' ||this.lossCancelReason=='Entered in Error' || this.lossCancelReason=='POP Unobtainable') 
	&& this.isIntelOppty == true && this.competitorCount == true){//TWC3123-6699 updated value for api change

		this.compProdOptions = [{
				label: 'None',
				value: 'None'
			}];

		this.disableComboBox = false;
		this.template.querySelector('lightning-combobox.competitorProduct').value = 'None';
		this.template.querySelector('lightning-combobox.competitorTag').value = 'None';
		this.selectedCompProd = 'None';
		this.selectedComp = 'None';

	}else {
		if(this.isIntelOppty == true && this.competitorCount == true ){
		this.disableComboBox = true;
		this.template.querySelector('lightning-combobox.competitorProduct').value = '';
		this.template.querySelector('lightning-combobox.competitorTag').value = '';
		this.selectedCompProd = '';
		this.selectedComp = '';
		}

	}


}

handleLossCancelDetails(event){
	this.lossCancelDetails = event.detail.value;
}

closeAction() {
	this.dispatchEvent(new CloseActionScreenEvent());
	}

handleReset(event) {
	const inputFields = this.template.querySelectorAll(
		'lightning-input-field'
	);
	if (inputFields) {
		inputFields.forEach(field => {
			field.reset();
		});
	}
}

competitorChangeHandler(event){
	

   this.bypassExecuting = true;
	if(event.detail.value != 'None' && event.detail.value != 'Other'){
	
	this.compProdOptions = '';
	this.disableComboBox = false;
	this.selectedComp = event.detail.value;
	getDependantPickListValues( {  controllingValue: this.selectedComp })
	.then(data => {
		
		this.compProdOptions = data;
		this.bypassExecuting = false;
		})
		.catch(error => {
			console.log('error-'+error);
		});
	}else if(event.detail.value == 'None' ) {
		console.log('Inside None---');
		
		this.disableComboBox = false;
		this.compProdOptions = [{
				label: 'None',
				value: 'None'
			}];

	this.template.querySelector('lightning-combobox.competitorProduct').value = 'None';
	this.bypassExecuting = false;
	this.selectedCompProd = 'None';
	this.selectedComp = 'None';
	}else if(event.detail.value == 'Other'){
		console.log('inside other');
		
		this.selectedComp = 'Other';
		this.selectedCompProd = 'None';
		getDependantPickListValues( {  controllingValue: this.selectedComp })
		.then(data => {
		this.bypassExecuting = false;
		this.compProdOptions = data;
		})
		.catch(error => {
			console.log('error-'+error);
		});

		this.template.querySelector('lightning-combobox.competitorProduct').value = 'None';
		this.disableComboBox = false;
		//this.selectedCompProd = 'None';
		

	}
	
	

}

competitorProdChangeHandler(event){
	console.log('event data in comp prod'+event.detail.value);
	this.selectedCompProd = event.detail.value;
}

handleCompetitorText(event){
	console.log('event data in comp prod'+event.detail.value);
	this.textvalue = event.detail.value;
}

showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
		this.dispatchEvent(new CustomEvent('closequickmodal'));
    }

showCompetitorData(){
	
	if(this.opportunityCompetitorcount > 0 ){
		this.competitorCount = true;
	}

}



}