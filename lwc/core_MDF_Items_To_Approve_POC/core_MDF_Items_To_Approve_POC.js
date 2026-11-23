import { LightningElement,wire,track } from 'lwc';
import getSubmittedRecords from '@salesforce/apex/Core_MDF_Approval_Request_rajesh.getSubmittedRecords';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';


export default class Core_MDF_Items_To_Approve_POC extends NavigationMixin(LightningElement) {
   
    
@track PhoneOrDesktop;
@track error;
@track recordsToRender ;
@track formFactor;
formFactor = formFactorPropertyName;
@track phoneOrDesktop;

@wire(getSubmittedRecords)
wiredAccounts({
    error,
    data
}) {
    if (data) {
        this.recordsToRender = JSON.parse(data);
        console.log(JSON.parse(data));
    } else if (error) {
        this.error = error;
    }
}
handleClick(event){
    var a = '';
    a= event.target.dataset.recordId;
    console.log('@@@@'+a);
    this[NavigationMixin.Navigate]({
        type: "standard__component",
        attributes: {
            componentName: "c__Core_MDF_navAuraCmp"
        },
        state: {
            c__recId: a
        }
    });
    console.log('Outside Navigation');
}
}