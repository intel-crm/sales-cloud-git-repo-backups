import { LightningElement, track } from 'lwc';

export default class Sales_NewComponentTest extends LightningElement 
{ @track isWindowCheck=false;
  @track windowHeigth;
  @track windowwidth;
    extendFeedback(){

    }
    connectedCallback(){
       
       this.windowHeigth=window.innerHeight;
       console.log('windowHeigth'+this.windowHeigth);
       this.windowwidth=window.innerWidth;
       console.log('windowwidth'+this.windowwidth);
       this.isWindowCheck=true;
    
    }
}