import { LightningElement,api, wire } from 'lwc';
import { registerRefreshHandler, unregisterRefreshHandler,REFRESH_COMPLETE } from "lightning/refresh";
import getAccountMemberType from '@salesforce/apex/Core_IPS_ProjectController_Lex.getAccountMemberType';
import Project_AllMemberType_Message from "@salesforce/label/c.Core_IPS_Project_AllMemberType_Message";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference  } from "lightning/navigation";

export default class Core_IPS_Message_Utility_LEX extends LightningElement {
    @api recordId;
    refreshID;

    @wire(CurrentPageReference) pageRef;

    /*get currentPageReference(){
      console.log('recordID in cuurentpagemu-'+this.recordId);
      console.log('cuurent age')
        console.log(`this page ref ${this.pageRef ? JSON.stringify(this.pageRef) : 'empty'}`);
    }*/
        @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
          console.log(currentPageReference);
          console.log('currentpage 1 recrdid-'+currentPageReference.attributes.recordId);
          console.log('currentpage 1 att-'+currentPageReference.attributes);
          console.log('currentpage 1 state-'+currentPageReference.state);
          console.log('currentpage 1 type-'+currentPageReference.type);
       }
    }





    connectedCallback() {
      console.log('@@@@ connected call back');
      console.log('recordID in connectedcallbackmu-'+this.recordId);
      //this.refreshID = registerRefreshHandler(this, this.refreshHandler);
      this.refreshID = registerRefreshHandler(this.template.host,this.refreshHandler.bind(this),
    );
    }
    disconnectedCallback() {
        unregisterRefreshHandler(this.refreshID);
    }
    refreshHandler() {
      console.log("refreshing");
      console.log('recordID in refreshhandlermu-'+this.recordId);
      /*return new Promise(resolve => {
        this.getAccountMemberType();
        resolve(true)
      });*/
      return new Promise((resolve) => {
        this.getAccountMemberType();
        resolve(true);
      });
    }
    getAccountMemberType(){
      console.log('projjjacccmu---'+this.recordId);
      //if(this.recordId.startswith('a08')){
        console.log('projjjaccc111mu---'+this.recordId);
        getAccountMemberType( {
            projAccId : this.recordId
        })
        .then(data=>{
            console.log('MESSGEUTILITY1 data -'+data);
            if(data != null && data != undefined && data !='' && data == true ){
                console.log('MESSGEUTILITY2 data -'+data);
                this.dispatchEvent(new ShowToastEvent({
                    message: Project_AllMemberType_Message,
                    variant: 'warning'
                   /* mode: 'sticky'*/
                }));
            }
        })
        .catch(error=>{
               console.log(' Error Occured:  '+error.message);
        })
      //}
    }
}