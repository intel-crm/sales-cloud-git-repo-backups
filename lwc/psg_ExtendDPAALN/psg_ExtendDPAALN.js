import { LightningElement,api,track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendRequestToSAP from '@salesforce/apex/PSG_Integration_DPA.sendRequestToSAP';
import validateDpaRec from '@salesforce/apex/PSG_Integration_DPA.validateDpaRec';

export default class Psg_ExtendDPAALN extends LightningElement {
    @api recordId;
    @track type='';
    @track spinnerOn=true;
    handleSubmit(event){
        this.spinnerOn=true;
        event.preventDefault();      // stop the form from submitting
        let shipEndDate=new Date(event.detail.fields.core_cpq_ship_end_date_dt__c);
        let currentDate=new Date();
        let operationType='';
        if(shipEndDate.getFullYear()+'-'+(shipEndDate.getMonth()+1)+'-'+shipEndDate.getDate() == currentDate.getFullYear()+'-'+(currentDate.getMonth()+1)+'-'+currentDate.getDate()){
            operationType='Expire';
        }else{
            operationType='Extend';
        }
        if(operationType=='Extend'){
            validateDpaRec({dpaId : this.recordId,action: operationType}).then(result => {
                if(result.isSuccess){
                    const fields = event.detail.fields;
                    fields.core_cpq_change_flag__c = 'E';
                    fields.core_cpq_status_txt__c='Extended';
                    this.template.querySelector('lightning-record-edit-form').submit(fields);
                    this.spinnerOn=true;
                }else{
                    this.fireToastEvent('Extend/Expire failed!',result.message,'error','sticky');
                    this.spinnerOn=false;
                    eval("$A.get('e.force:refreshView').fire();");
                    this.closeQuickAction();
                }
            }).catch(error => {
                this.fireToastEvent('Extend/Expire failed!',error,'error','sticky');
                this.spinnerOn=false;
                this.closeQuickAction();
            });
        }else{
            const fields = event.detail.fields;
            fields.core_cpq_change_flag__c = 'E';
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            this.spinnerOn=true;
        }        
    }

    handleSuccess(event){
        this.spinnerOn=true;
        sendRequestToSAP({dpaId : this.recordId,action: 'Extend'}).then(result => {
            if(result.isSuccess){
                this.fireToastEvent('Success!',this.type+' Extended/Expired successfully and Submitted to SAP '+this.sapType+'!','success','dismissable');
                this.spinnerOn=false;
                eval("$A.get('e.force:refreshView').fire();");
                this.closeQuickAction();
            }else{
                this.fireToastEvent('Failed!',this.type+' Extended/Expired successfully and Failed to Submit to SAP '+this.sapType+',Please try again! \nErrors : '+result.message,'error','sticky');
                this.spinnerOn=false;
                this.closeQuickAction();
            }
        }).catch(error => {
            this.fireToastEvent('Failed!',this.type+' Extended/Expired successfully and Failed to Submit to SAP '+this.sapType+',Please try again! \nError : '+error,'error','sticky');
            this.spinnerOn=false;
            this.closeQuickAction();
        });
    }

    handleError(event){
        this.fireToastEvent('Failed!',event.detail.message+' \n'+event.detail.detail,'error','sticky');
        this.spinnerOn=false;
    }

    handleLoad(event){
        var record = event.detail.records;
        var fields = record ? JSON.parse(JSON.stringify(record[this.recordId].fields)) : undefined;
        var typeValue=fields ? fields.core_cpq_record_type_identifier__c : undefined;
        this.type = typeValue? typeValue.displayValue : '';
        this.spinnerOn=false;
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    fireToastEvent(title, message, variant, mode) {
        const event = new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: mode
        });
        this.dispatchEvent(event);
    }

    get sapType(){
        return this.type=='ALN'? 'ECC' : 'CHM';
    }
}