import { LightningElement ,wire,track} from 'lwc';
import  getUserInformation from '@salesforce/apex/PSG_Utility.getUserInformation';
//import {getRecord} from 'lightning/uiRecordApi';

//import USER_ID from '@salesforce/user/Id';

//import NAME_FIELD from '@salesforce/schema/User.Name';
//import EMAIL_FIELD from '@salesforce/schema/User.Email';

export default class psg_welcomebanner extends LightningElement{
    @track result
    @wire(getUserInformation, {})
    getUserInformation({error,data}){
        if(data){
            this.result=data;
           // console.log("This is data"+data.Id)
        }
        if(error){
           // console.log(error);
        }
    }

}