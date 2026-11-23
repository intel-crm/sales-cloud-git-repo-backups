import { LightningElement,api,wire,track} from 'lwc';
import { CurrentPageReference,NavigationMixin } from "lightning/navigation";
import Core_KPI_Refresh_Started from '@salesforce/label/c.Core_KPI_Refresh_Started';
import Core_KPI_Refresh_On from '@salesforce/label/c.Core_KPI_Refresh_On';
import autoKPIRun from '@salesforce/apex/Core_RefreshKPI.autoKPIRun';
import { RefreshEvent } from 'lightning/refresh';

export default class Crm_RefreshKPIs extends NavigationMixin(LightningElement) {

    @api Id;

    label = {Core_KPI_Refresh_Started,Core_KPI_Refresh_On};
    @track showpageStartMsg = false;
    @track showpageProgressMsg =false;

    @wire(CurrentPageReference)
    currentPageRef;

    get Id() {
        return this.currentPageRef.state.c__Id;
    }

    connectedCallback() {
        this.autoRun();
    }

    autoRun() {
        autoKPIRun({oppId : this.Id})
       .then(data=>{
            console.log('AA data frm Apex::'+JSON.stringify(data));
            this.showpageStartMsg = data.showpageStartMsg;
            console.log('AA wrappedData frm Apex::'+JSON.stringify(this.showpageStartMsg));
            this.showpageProgressMsg = data.showpageProgressMsg;
            console.log('AA wrappedData frm Apex::'+JSON.stringify(this.showpageProgressMsg));
       })
       .catch(error=>{
            console.error('AA error frm Apex::'+JSON.stringify(error));
            if(error!==''){
                const evnt = new ShowToastEvent({
                    title : error.statusText +' !!',
                    message : error.body.exceptionType +'::'+ error.body.stackTrace,
                    variant : 'Error',
                    mode : 'dismissable'
                });
                this.dispatchEvent(evnt);
            }
       })
    }

    navigateToRecord() {

        eval("$A.get('e.force:refreshView').fire();");
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.Id,
                actionName: 'view'
            }
        });

        /*window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {*/
            eval("$A.get('e.force:refreshView').fire();");
        /*}, 300);*/
    }

}