import { LightningElement,api,track,wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import fetchCIMStatus from '@salesforce/apex/PRM_CIM_Status_OPIDRecommendation.fetchCIMStatus';
export default class PRM_Sync_CIM_Status extends LightningElement {
    @api recordId;
    @track hasRendered = true;
    // @track hasRendered=true;

    
    // renderedCallback(){
    //    if(this.hasRendered){
    //         this.fetchCIMStatus();
    //    }
    //    this.hasRendered=false;
    // }
    @track hasRenderedFirst = true;
    connectedCallback() {
        console.log('connected===============');
        console.log(this.recordId + ' is null');
    }

    // @wire(getRecord, { recordId: '$recordId'})
    // wiredRecord({ error, data }) {
    //     console.log('insodeGetRec'+data+'recID'+this.recordId);
    //         if (data) {
    //             this.fetchCIMStatus();
    //         }
        
    // }
    renderedCallback() {
        //guarding code inside the renderedCallback using boolean property
        if (this.hasRenderedFirst == true) {
            console.log(this.recordId + ' hasRenderedFirst:true'+this.hasRenderedFirst );
            this.hasRenderedFirst = false;
        }
        if(this.recordId!=undefined){
            console.log(this.recordId + ' hasRenderedFirst:false'+this.hasRenderedFirst );
            this.fetchCIMStatus();
        }
    }

    async fetchCIMStatus(){
        console.log(this.recordId + ' is provided fetchCIMStatus');
        this.CIMStatusAccId = await fetchCIMStatus({opidRecId :this.recordId});
        alert('JSON',this.CIMStatusAccId );
        console.log('JSON',this.CIMStatusAccId );
        if(this.CIMStatusAccId!=null){
             const evt = new ShowToastEvent({
                 title: 'Info',
                 message: 'this.CIMStatusAccId',
                 variant: 'info'
             });
             this.dispatchEvent(evt);
             this.closeAction();
        }
    }
}