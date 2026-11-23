import { LightningElement } from 'lwc';
export default class BasicHideShowTemplate extends LightningElement {
   
   showVar;
   box=[];
   handleShow(){
        this.showVar = true;
   }
   handleHide(){
        this.showVar = false;
   }
   connectedCallback() {
      this.box.push('Apple 1');
      this.box.push('Apple 2');
      this.box.push('Apple 3');
      this.box.push('Apple 4');
      this.box.push('Apple 5');
   }
}