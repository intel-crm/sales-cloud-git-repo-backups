import { LightningElement,track } from 'lwc';

export default class Sales_MentainanceBanner extends LightningElement {
@track datetime;
@track mentainancestarttime='2/11/2022 13:32:00';
@track mentainanceendtime='2/11/2022 13:34:00';
@track ismentainancetime =true;
    
connectedCallback(){
 var currentdate = new Date(); 
 var datetime = (currentdate.getMonth()+1) +"/"
                              +currentdate.getDate() + "/"
                + currentdate.getFullYear() + " "  
                + currentdate.getHours() + ":"  
                + currentdate.getMinutes() + ":" 
                + currentdate.getSeconds();

               
 console.log(this.mentainancestarttime+'start');
if(this.mentainancestarttime<=datetime && datetime<=this.mentainanceendtime)   
{
    this.ismentainancetime =true;
    console.log('schedule time');
}             
 else 
 {
    this.ismentainancetime =false;
    console.log('schedule not time');
 }
console.log('value'+this.ismentainancetime);

}

renderedCallback(){
    console.log('datetime'+datetime);
}
}