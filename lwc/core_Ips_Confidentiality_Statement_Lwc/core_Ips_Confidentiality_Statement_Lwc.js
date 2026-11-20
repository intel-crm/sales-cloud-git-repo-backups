import { LightningElement } from 'lwc';
import getDiscData from '@salesforce/apex/Core_IPS_ContactloginDisclaimerCtrl_LWC.getDocData';

export default class Core_Ips_Confidentiality_Statement_Lwc extends LightningElement {
    finalDocData;
    connectedCallback(){
       this.getDocBody(); 
    }
    getDocBody() {
        getDiscData()
            .then((result) => {
                var docBody = result;
               this.finalDocData = docBody.replaceAll("class=MsoNormal style='margin-bottom", "class=MsoNormal style='text-align: justify; margin-bottom");
              // this.finalDocData = docBody;
                console.log('Doc Data Minhaj>>>: '+typeof this.docBody,this.docBody);
                
            })
            .catch((error) => {
                
                console.log('DOC ERROR ',error);
            });
        
    }

}