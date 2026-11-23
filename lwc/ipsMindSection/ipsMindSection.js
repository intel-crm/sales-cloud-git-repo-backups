/* eslint-disable no-alert */
/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
import getCountriesOptions from "@salesforce/apex/showMindsController.getCountriesOptions";
import getDefaultCountriesOptions from "@salesforce/apex/showMindsController.getDefaultCountry";

export default class ipsMindSection extends LightningElement {

  @track selectedContact;
  @track countrydefaultvalue = "India";
  @api contactId;
  @track records = [];
  @track errors;
  @track selectedValue;
  @track selectedContactId;
  @track contactdata;
  @track radioOptions;

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

      getCountriesOptions()
        .then(result => {

          if (this.result !== undefined || this.result !== null) {
            // console.log("this.records" + JSON.stringify(this.records));
            this.records = result;
            //this.error = undefined;
          }
        })
        .catch(error => {
          this.error = error;

        });
      getDefaultCountriesOptions({
        contactdata: this.contactId, //'0033F000001QqZ5QAK'
        //this.contactId,
      })
        .then(result => {
          console.log("inside id" + JSON.stringify(result));
          if (this.result !== undefined || this.result !== null) {
            console.log("this.records" + JSON.stringify(result));
            this.countrydefaultvalue = result[0];
            this.selectedValue = result[1];

            // this.error = undefined;
          }
          this.selectedValue = 'Yes';
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

        })
        .catch(error => {
          this.error = error;

        });
    }

  }

  handleChangeforContact(event) {

    console.log("insideminds");
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