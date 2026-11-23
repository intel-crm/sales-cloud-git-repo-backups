import { LightningElement,api } from 'lwc';

export default class HelpTextCustomInputType extends LightningElement {
    @api status;
  
    

    @api
    get showHelpText(){
        return this.status=="Pending Action"?true:false;
    }

}