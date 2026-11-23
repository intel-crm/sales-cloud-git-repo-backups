import { LightningElement,api,wire,track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import getAccountCategory from "@salesforce/apex/UCD_ACM_AccountTeamCategory.getAccountCategory";


export default class UCD_ACM_AccountTeam extends LightningElement {

@api recordId; 

renderedcallback(){
    console.log('callback');
    getAccountCategory({accountId:this.recordId}).then(response => {

    console.log('valid');
    })

    .catch(error => {
        console.log('error');

    })

    }
 }