import { LightningElement } from 'lwc';
export default class BasicFormUsingLWC extends LightningElement {
    name;
    email;
    phone;

  handleOnClick(){
    var loop = this.template.querySelectorAll('lightning-input');
    loop.forEach(function(element){
      if(element.name =='Name'){
        this.name = element.value;
      }
      if(element.name =='Email'){
        this.email = element.value;
      }
      if(element.name =='Phone'){
        this.phone = element.value;
      }
    },this);
    alert('Name is '+this.name +' Email is '+this.email +' Phone is '+this.phone);
  }
}