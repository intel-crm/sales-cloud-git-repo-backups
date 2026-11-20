import { LightningElement, wire, track} from 'lwc';
//import aiInferenceDynamicURL from '@salesforce/label/c.Crm_SmartSheet_dynamic_view';
import getaiInferneceDynamicViewURL from '@salesforce/apex/core_OpportunitySupportStatusController.getAiInferenceDynamicViewURL';

export default class Crm_AiInferenceSupport extends LightningElement {
    @track getSSDynamicURL;
    @track showDropdown = false;
    handleAiInfernceDynamicView(){
        getaiInferneceDynamicViewURL()
        .then(data => {
                if(data){
                    this.getSSDynamicURL = data;
                    window.open(this.getSSDynamicURL,'_blank');
                }
            })
            .catch(error=> {
                console.error('error'+error);
            });
        
    }
    handleExpand(){
        this.showDropdown = !this.showDropdown;
    }

}