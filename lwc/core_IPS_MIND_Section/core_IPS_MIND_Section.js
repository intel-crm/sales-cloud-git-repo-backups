/* eslint-disable no-alert */
/* eslint-disable no-console */
import { LightningElement, track, api, wire } from 'lwc';
import COUNTRY_REGION from '@salesforce/schema/Contact.Core_Country_Region__c';
import STATE from '@salesforce/schema/Contact.Core_IPS_State__c';
import getDefaultCountriesOptions from "@salesforce/apex/Core_IPS_MindSectionController.getDefaultCountry";
import {  getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import TickerSymbol from '@salesforce/schema/Account.TickerSymbol';

export default class core_IPS_MINDSection extends LightningElement {

  @track selectedContact;
  @track countrydefaultvalue;// = "India";
  @api contactId;
  @api countrySelected;
  @track countryList = [];
  @track stateList = [];
  @track stateFieldData;
  @track errors;
  @track selectedValue;
  @track selectedContactId;
  @track contactdata;
  @track radioOptions; 
  @track objectInfo;
  @track showState = false;
  @api noassignedcase;
  @api casecountryselected;
  @api modetype;
  @api statedefaultvalue;
  @wire(getObjectInfo, {
    objectApiName: 'Contact'
})
objectInfo;

@wire(getPicklistValues, {
    recordTypeId: '$objectInfo.data.defaultRecordTypeId',
    fieldApiName: COUNTRY_REGION
})
wiredsourceField({
    data,
    error
}) {
    if (data) {
      console.log('in new MINDS comp this.countryList ', JSON.stringify(data));
        this.countryList = data.values;
        console.log('in new MINDS comp this.countryList ', this.countryList);
    }
    if (error) {
        console.log('error: ' + JSON.stringify(error));
    }
}

@wire(getPicklistValues, {
    recordTypeId: '$objectInfo.data.defaultRecordTypeId',
    fieldApiName: STATE
})
wiredstateField({
    data,
    error
}) {
    if (data) {
      console.log('in new MINDS comp this.stateList ', JSON.stringify(data));
      this.stateFieldData = data;
      if(this.casecountryselected != undefined) {
          let key = this.stateFieldData.controllerValues[this.casecountryselected];
          this.stateList = this.stateFieldData.values.filter(opt => opt.validFor.includes(key));
          if(this.stateList.length != 0 && this.modetype != 'edit') {
               this.showState = true;
          } else {
               this.showState = false;
        }
    }
    if (error) {
        console.log('error: ' + JSON.stringify(error));
    }
}
}

get options() {
    return this.radioOptions;
  }

  connectedCallback() {
    console.log("callback ::: ");
    this.contactdata = this.contactId;
    this.radioOptions =
              [{
                label: 'Yes',
                value: true,
                checked: ''
              },
              {
                label: 'No',
                value: false,
                checked: 'checked'
              }];

    // this.selectedValue = 'Yes';
    if (this.contactdata !== undefined || this.contactdata !== null) {
      console.log("contact id>>>> " + this.contactdata);
      if(this.noassignedcase != null && this.noassignedcase != undefined && this.noassignedcase ){
        this.countrydefaultvalue = this.casecountryselected; 
      }
      getDefaultCountriesOptions({
        contactdata: this.contactId, //'0033F000001QqZ5QAK'
        //this.contactId,
      })
        .then(result => {
          console.log("inside id" + JSON.stringify(result));
          if (this.result !== undefined || this.result !== null) {
            console.log("this.records" + JSON.stringify(result));
            if(this.modetype!=null && this.modetype!=undefined && this.modetype == 'copy'){
              this.countrydefaultvalue = this.casecountryselected;
            }
            else{
            this.countrydefaultvalue = result[0];
            }
            this.statedefaultvalue = result[1];
            if (this.statedefaultvalue != undefined && this.statedefaultvalue != 'Yes' && this.statedefaultvalue != 'No') {
              this.showState = true;
              this.sendDefaultState();
            }
            console.log('shossss--->' + this.stateFieldData);
            this.countrySelected = result[0];
            console.log('ppcountryM-'+this.countrySelected);
            this.selectedValue = result[2];

            // this.error = undefined;
          }
          //this.selectedValue = 'Yes';
          console.log('selec' + this.selectedValue);
          console.log(this.selectedValue === 'Yes');
          if (this.selectedValue === 'Yes') {


            this.radioOptions =
              [{
                label: 'Yes',
                value: true,
                checked: 'checked'
              },
              {
                label: 'No',
                value: false,
                checked: ''
              }];

          } else {
            console.log('else');


            this.radioOptions =
              [{
                label: 'Yes',
                value: true,
                checked: ''
              },
              {
                label: 'No',
                value: false,
                checked: 'checked'
              }];
          }
          console.log('this.radioOptions[0].value  ' + this.radioOptions[0].value);
          console.log('this.radioOptions[1].value  ' + this.radioOptions[1].value);
        
          const mindsEvent = new CustomEvent("getmindsvalue",{detail: this.selectedValue});
          this.dispatchEvent(mindsEvent);

        })
        .catch(error => {
          this.error = error;

        });
    }

  }
  renderedCallback(){
    console.log('ppcountrym1--'+this.countrySelected);
    if(this.countrySelected!=null&&this.countrySelected!=undefined&&this.countrySelected!=''){
        const handledefaultCountryEvent = new CustomEvent("getdefaultcountryselection", {
           detail: this.countrySelected
        });
        this.dispatchEvent(handledefaultCountryEvent);
    }
  }

  sendDefaultState() {
        const handledefaultStateEvent = new CustomEvent("getdefaultstateselection", {
           detail: this.statedefaultvalue
        });
        this.dispatchEvent(handledefaultStateEvent);
  }
  
  handleChangeforContact(event) {
    let key = this.stateFieldData.controllerValues[event.target.value];
    this.stateList = this.stateFieldData.values.filter(opt => opt.validFor.includes(key));
    if(this.stateList.length != 0 && this.modetype != 'edit') {
      this.showState = true;
    } else {
      this.showState = false;
      this.statedefaultvalue = '';
      this.sendDefaultState();
    }
    this.selectedContactId = event.detail.value;
    console.log("selectedContactId:" + JSON.stringify(this.selectedContactId));
    if (this.selectedContactId !== undefined) {
      console.log("selectedContactId:" + JSON.stringify(this.countrydefaultvalue));
    }

    const handlecountrySelectionEvent = new CustomEvent("countryselect", {
      detail: {
          countryName: event.detail.value 
      }
    });
    this.dispatchEvent(handlecountrySelectionEvent);
  }

   handleStateChange(event) {
     const handlestateSelectionEvent = new CustomEvent("stateselect", {
       detail: {
         stateName: event.detail.value
       }
     });
    this.dispatchEvent(handlestateSelectionEvent);
  }

  handleSelected(event) {
    console.log('selected value ===> ' + event.target.value);
    this.selectedValue = event.target.value;
    const handleismindsEvent = new CustomEvent("isminds", {
      detail: {
          isMinds: event.target.value 
      }
    });
    this.dispatchEvent(handleismindsEvent);
  }
  
}