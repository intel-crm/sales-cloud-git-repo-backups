import { LightningElement, api, wire, track } from 'lwc';
import getFormDetails from '@salesforce/apex/Pricing_FieldSetFormController.getFormFieldsAndSectionLabel';

export default class CreatedEditForm extends LightningElement {
    //@api recordId;
    @track recordId = 'a9UDf000000QPVkMAO';
    @track formValues;
    @track iconName = 'utility:chevrondown';
    @track isSelected = true;
    @track isSpinner = false;
    @track variable1 = false;


    connectedCallback() {
        this.getFieldSetFormDetails();
    }

    getFieldSetFormDetails() {
        this.isSpinner = true;
        getFormDetails({ recordId: this.recordId })
            .then(result => {
                this.formValues = result;
                console.log('FormValues: '+JSON.stringify(this.formValues));
                this.isSpinner = false;

                for (var i = 0; i < this.formValues.length; i++) {
                    for (var j = 0; j < this.formValues[i].Fields.length; j++) {
                        if (this.formValues[i].Fields[j]["APIName"] == 'CreatedById' || this.formValues[i].Fields[j]["APIName"] == 'CreatedDate') 
                        {
                            console.log('inside if');
                            this.formValues[i].Fields[j]["isDisplayField"] = true;

                        }
                    }
                }
                console.log('FormValues: '+JSON.stringify(this.formValues));
            })
            .catch(error => {
                console.log('error===>', JSON.stringify(error));
                this.isSpinner = false;
            });
    }
   /* get methodTogetDate(){
        
        let test1 = false;
        console.log('result: '+JSON.stringify(this.formValues));
        for (var i = 0; i < this.formValues.length; i++) {
            for (var j = 0; j < this.formValues[i].Fields.length; j++) {
                if (this.formValues[i].Fields[j]["APIName"] == 'CreatedById') 
                {
                    this.test1 = true;
                    console.log('inside if 50 ' +this.test1);
                    break;

                }
                else{
                    this.test1 = false;
                    console.log('inside else 30' +this.test1);
                }
            }

        }
        console.log('final result '+ this.test1);
        return this.test1;

    }*/

    handleClick(event) {
        let childComp = (event.target.firstElementChild === null) ? event.target : event.target.firstElementChild.firstElementChild;
        childComp.iconName = (childComp.iconName === 'utility:chevronright') ? 'utility:chevrondown' : 'utility:chevronright';

    }

}