import {api, LightningElement,track,wire } from 'lwc';
import Core_IPS_Country_Message from '@salesforce/label/c.Core_IPS_Country_Message';
import Core_IPS_Required from '@salesforce/label/c.Core_IPS_Required';
import COUNTRY_REGION from '@salesforce/schema/Contact.Core_Country_Region__c';
import STATE from '@salesforce/schema/Contact.Core_IPS_State__c';
import Contact from '@salesforce/schema/Contact';
import {  getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
export default class Core_IPS_CountryState_LWC extends LightningElement {
     label = {
         Core_IPS_Country_Message,
         Core_IPS_Required
     }
@api selectedvaluecountry;
@api statedefaultvalue;
@track countryOptions = [];
@track stateList = [];
@track showState = false;
isRequiredStatecpy = false;
isRequiredCountrycpy = false;
    
  @wire(getObjectInfo, { objectApiName: Contact })
    objectInfo;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: COUNTRY_REGION })
    wiredData({ error, data }) {
        if (data) {
            let dataOjb = data.values;
            let finalData = [{ label: "--None--", value: "None" }, ...dataOjb];
            this.countryOptions = finalData.map(objPL => {
                return {
                    label: `${objPL.label}`,
                    value: `${objPL.value}`
                };
            });
        } else if (error) {}
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
      if(this.selectedvaluecountry != undefined) {
          let key = this.stateFieldData.controllerValues[this.casecountryselected];
          this.stateList = this.stateFieldData.values.filter(opt => opt.validFor.includes(key));
          if(this.stateList.length != 0 && this.modetype != 'edit') {
               this.showState = true;
          } else {
               this.showState = false;
        }
    }
    }
    if (error) {
        console.log('error: ' + JSON.stringify(error));
    }
    }
  connectedCallback() {
    if (this.statedefaultvalue != undefined)
      this.showState = true;
  }

   handleChangecountry(event) {
    let key = this.stateFieldData.controllerValues[event.target.value];
    this.stateList = this.stateFieldData.values.filter(opt => opt.validFor.includes(key));
    if(this.stateList.length != 0) {
      this.showState = true;
    } else {
      this.showState = false;
      this.statedefaultvalue = '';
    }
       this.selectedvaluecountry = event.detail.value;
       this.isRequiredCountrycpy = false;
       this.template.querySelector('.cpyCountryInput')?.classList.remove('showRequired');
       const handlecountrySelectionEvent = new CustomEvent("countryselect", {
          detail: {
            countryName: event.target.value,
            showState: this.showState,
            state : this.statedefaultvalue
          }
        });
        this.dispatchEvent(handlecountrySelectionEvent);
   }
    
    handleChangeState(event) {
        this.statedefaultvalue = event.detail.value;
        this.isRequiredStatecpy = false;
        this.template.querySelector('.cpyStateInput')?.classList.remove('showRequired');
        const handlestateSelectionEvent = new CustomEvent("stateselect", {
          detail: {
          stateName: event.target.value
          }
        });
        this.dispatchEvent(handlestateSelectionEvent);
    }
  @api validateCountryMethod() {
        this.isRequiredCountrycpy = true;
        this.template.querySelector('.cpyCountryInput')?.classList.add('showRequired');
        this.template.querySelector('.cpyCountryInput')?.scrollIntoView();
    }
  @api validateStateMethod() {
      this.isRequiredStatecpy = true;
      this.template.querySelector('.cpyStateInput')?.classList.add('showRequired');
      this.template.querySelector('.cpyStateInput')?.scrollIntoView();
    }
}