import { LightningElement,api,track,wire } from 'lwc';
import projSubmit from '@salesforce/apex/Core_IPS_ProjectController_Lex.projSubmit';
import detailPage from '@salesforce/label/c.Core_IPS_Project_Detail_Page';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class Core_IPS_submitProject_Lex extends LightningElement {
    @api recordId;
    spinner=true;
    errorMsg;
    errMsg;
    submit;
    connectedCallback() {
        this.RefreshValues();
    }
    async RefreshValues() {
        await new Promise(resolve => setTimeout(resolve, 500));
        this.statusUpdate();
    }
    statusUpdate(){
        return projSubmit({
            projectId: this.recordId
        })   
        .then(data=>{
            if(data==1){
                this.errorMsg = true;    
            }
            else if(data==2){
                this.errMsg = true;    
            }
            else if(data==3){
                this.submit = true;
                window.location.href = detailPage +this.recordId + '/view'   
            }  
            this.spinner=false;  
        })
        .catch(error=> {
            console.log('error:'+ error);
        })
    }
    cancel(){
        this.dispatchEvent(new CloseActionScreenEvent());
    } 
}