import { LightningElement } from 'lwc';
import getIdList from "@salesforce/apex/GanapatiLWCController.getIdList";

export default class LwcCompTest extends LightningElement {

    AccountIdList1;
    AccountIdList2;
    connectedCallback() {
        var conqueryStr = "SELECT Id From Account LIMIT 10";
        
        getIdList({queryString: conqueryStr})
        .then(result=>{
            console.log('Acc1 contact account id list ', result);
            this.AccountIdList1 = result;

            console.log(JSON.stringify(this.AccountIdList1));
            let idlist = JSON.stringify(this.AccountIdList1);
            idlist = idlist.replace("[", "(");
            idlist = idlist.replace("]", ")");
            idlist = idlist.replace(/"/g, "'");
            let accqueryStr = "SELECT Id From Account where Id IN " + idlist + " LIMIT 10";
            console.log('accqueryStr '+accqueryStr);
            getIdList({queryString: accqueryStr})
            .then(result1=>{
                console.log('Acc11 contact account id list ', result1);
                this.AccountIdList2 = result1;
                console.log(JSON.stringify(this.AccountIdList2));
            })
            .catch(error1=>{
                console.log("error", error1);
                
            })
        })
        .catch(error=>{
            console.log("error", error);
            
        })
    }
}