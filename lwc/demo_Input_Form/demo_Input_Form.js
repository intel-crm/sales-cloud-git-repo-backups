import { LightningElement, track } from 'lwc';

export default class Demo_Input_Form extends LightningElement {
    @track inputData;
    @track flag = false;
    updateHandler(event){
        this.inputData = event.target.value;
        this.flag = true;
        // console.log(this.inputData);
        // console.log(this.flag);
        // let optionId = event.target.dataset.item; 
        //set sessionStorage and localStorage values
        console.log(this.inputData);
        sessionStorage.setItem('id',this.inputData)
        localStorage.setItem('id',this.inputData);
    }
  
}