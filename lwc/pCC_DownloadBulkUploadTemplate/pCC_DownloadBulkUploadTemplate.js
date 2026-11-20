import { LightningElement,track,api } from 'lwc';

export default class Prm_bulkInviteParent extends LightningElement {
   
         //progress bar:
         progress = 0;
         isProgressing = false;
    
        
        //show progress bar:
        get computedLabel() {
            return this.isProgressing ? 'Stop' : 'Start';
        }
    
        actionToggleBar() {
            if (this.isProgressing) {
                // progress bar stop
                this.isProgressing = false;
                clearInterval(this._interval);
            } else {
                // progress bar start
                this.isProgressing = true;            
                this._interval = setInterval(() => {
                    this.progress = this.progress === 100 ? 0 : this.progress + 1;
                }, 100);
            }
        }
    
        disconnectedCallback() {
            // the component gets disconnected       
            clearInterval(this._interval);
        }
        connectedCallback() {
        this.handleSubscribe();
        
        }
        handleSubscribe(){
            this.actionToggleBar();
        }
        renderedCallback(){
            this.handleSubscribe();
            this.actionToggleBar();
        }
      
}