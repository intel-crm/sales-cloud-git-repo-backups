/* eslint-disable no-alert */
/* eslint-disable no-unused-vars */
/* eslint-disable no-console */

import {
	LightningElement,
	track,
	api
} from 'lwc';

export default class CustomPickList extends LightningElement {

	@track firstValues = [];
	@track secondValues = [];
	@track firstVal;
	@track secondVal;

	@api primaryPickList;
 
	connectedCallback() {
		for (let key of this.primaryPickList.keys()) {
			//this.firstValues.push(key);
			this.firstValues = [...this.firstValues, {
				label: key,
				value: key
			}];
		}
	}

	handleStatusChange(event) {
		
		let secondArray = [];		
		this.firstVal = event.detail.value;
		console.log("firstVal-->", this.firstVal)
		secondArray = this.primaryPickList.get(this.firstVal);
		this.secondValues = [];
		for (let element of secondArray) {
			this.secondValues = [...this.secondValues, {
				label: element,
				value: element
			}];
		}
	}

	handlePriorityChange(event) {
		
		this.secondVal = event.detail.value;
		console.log("secondVal-->", this.secondVal)
	}
}