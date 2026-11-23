import { LightningElement, track, wire, api } from 'lwc';
import fetchAccountRecordTypes from '@salesforce/apex/AccRecordTypeController_POC.fetchAccountRecordTypes';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import { NavigationMixin } from 'lightning/navigation';

export default class RadioGroupBasic extends NavigationMixin(LightningElement) {
    value = '';

    /*get options() {
        return [
            { label: 'Intel Account', value: 'option1' },
            { label: 'CoMarketing', value: 'option2' },
            { label: 'Country Customer', value: 'option3' },
            { label: 'Direct Account', value: 'option4' },
        ];
    }*/

    options = [];

    @track selectedOption;

    connectedCallback() {
        fetchAccountRecordTypes()
		.then(result => {
			console.log('check result : ',result)
            this.options = result;

            for(var i=0; i<result.length; i++ ) {
                if(result[i].checked) {
                    this.selectedOption = result[i].recordTypeId;
                    console.log('this.selectedOption : ',this.selectedOption);
                }
            }
            
            /*this.options.forEach(function(element) {
                if(element.checked) {
                    this.selectedOption = element.recordTypeId;
                }
            });*/

            /*
            result.foreach(function(element)) {
                console.log('element : ',element);
                //var option = {'Label':element.recordTypeName, 'value':result.element.recordTypeId};
                //console.log('option : ',option);
                this.options = result;
            });

            console.log('this.options : ',this.options);*/

		})
		.catch(error => {
			//todo handle error
		})
    }

    handleRadioChange(event){
        this.selectedOption = event.target.value;
    }


    submitDetails() {

        var recordTypeSelected = [];
        for(var i=0; i<this.options.length; i++ ) {
            if(this.options[i].recordTypeId === this.selectedOption) {
                recordTypeSelected = this.options[i];
            }
        }

        console.log('recordTypeSelected : ',recordTypeSelected);

        if (recordTypeSelected.recordTypeName === 'Intel Account'){
           this.navigateToTab();
        } else {
            this.navigateToNewRecordPage(recordTypeSelected.recordTypeId);
        }

        //this.selectedOption = event.detail.value;
       // alert('selectedOption ' + selectedOption);
        /*if (this.selectedOption == 'option1'){
           // this.navigateToNewRecordPage('012o0000000GlzTAAS');
           this.navigateToTab();
            console.log('111111111' +this.intelAccount);
        }
        if(this.selectedOption == 'option2'){
            this.navigateToNewRecordPage('0121J000000yaFXQAY');
        }
        if(this.selectedOption == 'option3'){
            this.navigateToNewRecordPage('0122D000001PHjtQAG');
        }
        if(this.selectedOption == 'option4'){
            this.navigateToNewRecordPage('0122D000001MhgLQAS');
        }*/
    }

    @track blogFieldValue = true;

    navigateToNewRecordPage(rtId){
        // Opens the new Account record modal
        // to create an Account.
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'new'
            },
            state: {
                count: '1',
                nooverride: '1',
                useRecordTypeCheck : '1',
                recordTypeId: rtId
            }
        });
    }
  
    navigateToTab() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                //Name of any CustomTab. Visualforce tabs, web tabs, Lightning Pages, and Lightning Component tabs
                apiName: 'New_Account_SBR'
            },
        });
    }

    handleCancel(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'list'
            }
        });
        }
}