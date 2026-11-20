import { LightningElement,api, wire } from 'lwc';
import { registerRefreshHandler, unregisterRefreshHandler } from "lightning/refresh";
import getAccountMemberType from '@salesforce/apex/Core_IPS_ProjectController_Lex.getAccountMemberType';
import Project_AllMemberType_Message from "@salesforce/label/c.Core_IPS_Project_AllMemberType_Message";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class Core_IPS_Message_Utility_LEX extends LightningElement {
    @api recordId;
    refreshID;
    connectedCallback() {
      this.refreshID = registerRefreshHandler(this.template.host,this.refreshHandler.bind(this),
    );
    }
    disconnectedCallback() {
        unregisterRefreshHandler(this.refreshID);
    }
    refreshHandler() {
      return new Promise((resolve) => {
        this.getAccountMemberType();
        resolve(true);
      });
    }
    getAccountMemberType(){
        getAccountMemberType( {
            projAccId : this.recordId
        })
        .then(data=>{
            if(data != null && data != undefined && data !='' && data == true ){
                this.dispatchEvent(new ShowToastEvent({
                    message: Project_AllMemberType_Message,
                    variant: 'warning'
                }));
            }
        })
        .catch(error=>{
               console.log(' Error Occured:  '+error.message);
        })
    }
}