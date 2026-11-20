import {LightningElement,api,track,wire} from 'lwc';
import pullSeedsSamples from '@salesforce/apex/core_OpportunitySupportStatusController.pullSeedsSamples';
import filterSeeds from '@salesforce/apex/core_OpportunitySupportStatusController.filterSeeds';
import filterSamples from '@salesforce/apex/core_OpportunitySupportStatusController.filterSamples';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";//TWC4767-3983
//import ACC_KCR_Name from '@salesforce/schema/Opportunity.Account.KCR_Global_Account_Name_Temp__c';//TWC4767-3983

//const fields = [ACC_KCR_Name];//TWC4767-3983

export default class Core_OpportunitySupportStatus extends LightningElement {
	@api recordId;
	chevronChange = "utility:chevronright";
	orderNo;
	chevronclicked = false;
	isSeedsSample = false;
	orderNoValue;
	prodNameValue;
	estShipdateValue;
	deliverydateValue;
	deliveryStatValue;
	pickUpDateValue;
	requesterValue;
	reqQtyValue;
	accNameValue;
	oppNameValue;
	seedRecordsflag;
	bSeedsErrorFlag = false;
	bSamplesErrorFlag = false;
	SeedsDataEmpty = false;
	SamplesDataEmpty = false;
	sampleRecordsflag = false;
	@track records = [];
	@track seedsRecords = [];
	@track sampleRecords = [];
	@track isLoading = true;
	@track searchSeedArray = [];
	@track searchSampleArray = [];
	@track result = [];
	@track unifiedOrCimLabelSample; //TWC4767-3431
	labelsString = ['Account Unified ID','Account CIM ID'];
	@track kcrGlobalAccNameTemp; //TWC4767-3983


	@wire(pullSeedsSamples, {
		sOppId: '$recordId'
	}) pullSeedsSamples({
		error,
		data
	}) {
		if (data) {

			console.log('Seeds inside res ' + JSON.stringify(data));
			this.seedsRecords = data.SeedWrapper === null ? [] : data.SeedWrapper;
			this.sampleRecords = data.SampleWrapper === null ? [] : data.SampleWrapper;
			if (this.sampleRecords.length !== 0) {
				this.sampleRecordsflag = true;
				this.isLoading = false;
			}
			if (this.seedsRecords.length !== 0) {
				this.seedRecordsflag = true;
				this.isLoading = false;
			}
			//this.kcrGlobalAccNameTemp = data.kcrGlobalAccNameTemp;
			this.unifiedOrCimLabelSample = data.ucdSwitch == true ? this.labelsString[0] : this.labelsString[1]; //TWC4767-3983

			this.bSeedsErrorFlag = data.bSeedsErrorFlag;
			this.bSeedsErrorMessage = data.bSeedsErrorMessage;
			this.bSamplesErrorFlag = data.bSamplesErrorFlag;
			this.bSamplesErrorMessage = data.bSamplesErrorMessage;
			this.SeedsDataEmpty = data.SeedsDataEmpty;
			this.SamplesDataEmpty = data.SamplesDataEmpty;
			JSON.parse(JSON.stringify(this.seedsRecords));
			this.finalSeedsData = this.seedsRecords;
			this.finalSampleData = this.sampleRecords;
			if (data || this.bSeedsErrorFlag === true || this.bSamplesErrorFlag === true) {
				this.isLoading = false;
			}

			console.log('Seeds inside ' + this.unifiedOrCimLabel + JSON.stringify(this.seedsRecords));
		} else if (error) {
			this.error = error;
			this.isLoading = false;
		}
	}

	hideAndShow(event) {
		let tableDataID = event.target.dataset.id;

		console.log('EVT' + event.target.dataset.id);

		let indx = parseInt(event.target.dataset.recordId);

		if (tableDataID === 'Seeds') {

			let recs = JSON.parse(JSON.stringify(this.seedsRecords));
			let currVal = recs[indx].hideBool;
			console.log('Current Val ' + currVal);
			recs[indx].hideBool = !currVal;
			recs[indx].chevronChange = (recs[indx].hideBool === true) ? "utility:chevrondown" : "utility:chevronright";
			this.seedsRecords = recs;
			console.log('After Change ' + this.seedsRecords[indx].hideBool);
		} else if (tableDataID === 'Samples') {

			let recs = JSON.parse(JSON.stringify(this.sampleRecords));
			let currVal = recs[indx].hideBool;
			console.log('Current Val ' + currVal);
			recs[indx].hideBool = !currVal;
			recs[indx].chevronChange = (recs[indx].hideBool === true) ? "utility:chevrondown" : "utility:chevronright";
			this.sampleRecords = recs;
			console.log('After Change ' + this.sampleRecords[indx].hideBool);
		}

	}

	handleSeedFilter(event) {
		console.log('Order No' + this.searchSeedArray);
		filterSeeds({
				sSeedSearch: this.searchSeedArray,
				lstSeeds: this.finalSeedsData
			})
			.then(result => {
				this.seedsRecords = JSON.parse(JSON.stringify(result));
				console.log('Filtered Data : ' + JSON.stringify(result));

			})
			.catch(error => {
				console.log('Errorured:- ' + JSON.stringify(error));
			});
		this.template.querySelector('[data-id="Seeds"]').blur();
	}

	handleSampleFilter(event) {
		console.log('Order No' + this.searchSampleArray);
		filterSamples({
				sSampleSearch: this.searchSampleArray,
				lstSamples: this.finalSampleData
			})
			.then(result => {
				this.sampleRecords = JSON.parse(JSON.stringify(result));
				console.log('Filtered Data : ' + JSON.stringify(result));

			})
			.catch(error => {
				console.log('Errorured:- ' + JSON.stringify(error));
			});
		this.template.querySelector('[data-id="Samples"]').blur();
	}

	handleInputChange(event) {
		var value = event.target.value;
		//Seeds Filter
		if (event.target.dataset.id === 'orderNo') {
			this.orderNoValue = value;
		} else if (event.target.dataset.id === 'prodName') {
			this.prodNameValue = value;
		} else if (event.target.dataset.id === 'estShipdate') {
			this.estShipdateValue = value;
		} else if (event.target.dataset.id === 'deliverydate') {
			this.deliverydateValue = value;
		} else if (event.target.dataset.id === 'deliveryStat') {
			this.deliveryStatValue = value;
		} else if (event.target.dataset.id === 'pickUpDate') {
			this.pickUpDateValue = value;
		} else if (event.target.dataset.id === 'requester') {
			this.requesterValue = value;
		} else if (event.target.dataset.id === 'reqQty') {
			this.reqQtyValue = value;
		} else if (event.target.dataset.id === 'accName') {
			this.accNameValue = value;
		}
		//Samples Filter
		if (event.target.dataset.id === 'reqIDSample') {
			this.reqIDSampleValue = value;
		} else if (event.target.dataset.id === 'lineSample') {
			this.lineSampleValue = value;
		} else if (event.target.dataset.id === 'prodNameSample') {
			this.prodNameSampleValue = value;
		} else if (event.target.dataset.id === 'deliveryDateSample') {
			this.deliveryDateSampleValue = value;
		} else if (event.target.dataset.id === 'statusSample') {
			this.statusSampleValue = value;
		} else if (event.target.dataset.id === 'requesterSample') {
			this.requesterSampleValue = value;
		} else if (event.target.dataset.id === 'reqQtySample') {
			this.reqQtySampleValue = value;
		} else if (event.target.dataset.id === 'appQtySample') {
			this.appQtySampleValue = value;
		} else if (event.target.dataset.id === 'accNameSample') {
			this.accNameSampleValue = value;
		} else if (event.target.dataset.id === 'oppNameSample') {
			this.oppNameSampleValue = value;
		} else if (event.target.dataset.id === 'oppStageSample') {
			this.oppStageSampleValue = value;
		} else if (event.target.dataset.id === 'approverSample') {
			this.approverSampleValue = value;
		}

		this.searchSeedArray = [this.orderNoValue,
			this.prodNameValue,
			this.estShipdateValue,
			this.deliverydateValue,
			this.deliveryStatValue,
			this.pickUpDateValue,
			this.requesterValue,
			this.reqQtyValue,
			this.accNameValue
		];

		this.searchSampleArray = [
			this.reqIDSampleValue,
			this.lineSampleValue,
			this.prodNameSampleValue,
			this.deliveryDateSampleValue,
			this.statusSampleValue,
			this.requesterSampleValue,
			this.reqQtySampleValue,
			this.appQtySampleValue,
			this.accNameSampleValue,
			this.oppNameSampleValue,
			this.oppStageSampleValue,
			this.approverSampleValue
		];
	}
}