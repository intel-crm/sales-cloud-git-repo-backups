import { api, LightningElement } from 'lwc';
import getObjectNameById from '@salesforce/apex/Core_IPS_HandleDeepLinksController.getObjectNameById';

export default class Core_IPS_HandleDeepLinks extends LightningElement {
    

    connectedCallback(){

        let recordId
        var pathArray = window.location.pathname.split('/');
        if(window.location.pathname.includes('/IPS/Partnercenter/s/case/')){
             recordId = pathArray[pathArray.length-2];
        }else{
             recordId = pathArray[pathArray.length-1];
        }
        // console.log('location>>', window.location);
        // let recordId;
        // console.log('inside constructor to handle deeplinks');
        // var pathArray = window.location.pathname.split('/');
        // recordId = pathArray[pathArray.length-1];
        console.log('>>>>',recordId);
        //call apex method
        getObjectNameById({ recId: recordId})
        .then(res => {
            console.log('response success');
            console.log(res);
            if(res == 'Case'){
                location.href = window.location.origin + "/IPS/Partnercenter/s/case-detail?recordId=" + recordId;
            }else if(res == 'Asset'){
                location.href = window.location.origin + "/IPS/Partnercenter/s/product-detail?recordId="  + recordId;
            }else if(res == 'Core_IPS_Project__c'){
                location.href = window.location.origin + "/IPS/Partnercenter/s/project-detail?recordId=" + recordId;
            }else{
                location.href = window.location.origin + "/IPS/Partnercenter/s/";
            }
        })
        .catch(err=>{
            console.log('inside error', err);
            location.href = window.location.origin + "/IPS/Partnercenter/s/";
        });
    }
}