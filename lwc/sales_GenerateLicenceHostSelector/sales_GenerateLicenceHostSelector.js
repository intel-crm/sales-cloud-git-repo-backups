import { api, LightningElement, track } from 'lwc';

export default class Sales_GenerateLicenceHostSelector extends LightningElement {
    @api activatecodeonload;
    @api hostValue;
    @api webdisplayFlag;
    @api recordId;
    @api existingcomputername;
    @api fromComponentValue=false;
    @api closeModel = false;
    disablefeedback=true;
    closeEvent(event){    
				 this.fromComponentValue = false;
					this.closeModel=false;
				 //this.dispatchEvent(new CloseActionScreenEvent());
                
        this.dispatchEvent(new CustomEvent('close'));
      
				}
    
    connectedCallback(){
        this.fromComponentValue = true;
        console.log('from host selector comp -->'+this.activatecodeonload+' -->'+this.hostValue+' -->'+this.webdisplayFlag+' -->'+this.recordId+'existingcomputername -->'+this.existingcomputername);
    }
}