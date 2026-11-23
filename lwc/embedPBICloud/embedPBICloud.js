import { LightningElement,api } from 'lwc';
import getURLFromApex from '@salesforce/apex/pBI_Embed_Cloud.getURL'; 

export default class EmbedPBICloud extends LightningElement {
    @api recordId;
    @api configName;
    fullUrl='';
    noAccessMsg = '';
    hasAccess = false;
    noAccess = false;

    connectedCallback() { 
        this.getURL();
    }

    getURL(){
        getURLFromApex({configName:this.configName,recordId:this.recordId})
        .then((data) => {
            
            var saveRes = JSON.parse(JSON.stringify(data));
            console.log('saveRes: '+saveRes);
            for(var key in saveRes){
                if(key == "true"){
                    this.hasAccess = true;
                    this.fullUrl = saveRes[key];
                }
                else if(key == "false"){
                    this.noAccess = true;
                    this.noAccessMsg = saveRes[key];
                }  
            }
        })
        .catch(error => {
            this.error = error;  
        });
    }
}