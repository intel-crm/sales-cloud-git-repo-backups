import { LightningElement,api } from 'lwc';
import {NavigationMixin } from 'lightning/navigation';

export default class LoginHomePage extends NavigationMixin(LightningElement) {
    @api recordId;
     // Navigation to lightning component
     connectedCallback(){
         console.log('calling LWC page');
        this.navigateToLightningComponent();
     }
     navigateToLightningComponent() {
       // this[NavigationMixin.Navigate]({
         //   "type": "standard__component",
           // "attributes": {
                //Here customLabelExampleAura is name of lightning aura component
                //This aura component should implement lightning:isUrlAddressable
             //   "componentName": "c__DisclaimerPage"
            //}
        //});
      /*
        var compDefinition = {
          componentDef: "c:DisclaimerPage"
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        console.log('encodedCompDef ', encodedCompDef);
        //var url = 'https://'+window.location.hostname+'/one/one.app#' + encodedCompDef;
        var url = 'https://'+window.location.hostname+'/Partnercenter/' + encodedCompDef;*/
        var url = 'https://'+window.location.hostname+'/Partnercenter/s/customerdisclaimer';
        //window.open(url,  "_self");
        /*this[NavigationMixin.GenerateUrl]({
            type: 'standard__component',
            attributes: {
              componentName: 'c__DisclaimerPage'
            }
        });*/
    }
}