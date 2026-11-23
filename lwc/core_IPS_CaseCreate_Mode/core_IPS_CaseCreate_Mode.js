import { LightningElement,api,track,wire } from 'lwc';
import getCustomSettingLogs from '@salesforce/apex/Core_IPS_CaseCreateMode_CTRL.getCustomSettingLogs';

export default class Core_IPS_CaseCreate_Mode extends LightningElement {
@api descriptiondefault;
@api Assetdefault;
@api Projectdefault;

@api CaseTypedefault;
@api CaseSubcategorydefault;
@api Supported_Productdefault;

@api IssueSourcedefault;
@api Case_Categorydefault;
@api CaseSubcategoryDetaildefalut;
    connectedCallback(){
        this.handleLoad();
    }
       
    handleLoad(){
          getCustomSettingLogs().then(result => {
             this.casedatainfo = result;
             //this.getdatafromCus = result[0];
            console.log('result stringfy--'+JSON.stringify(this.casedatainfo));
            for (let key in this.casedatainfo) {
                 console.log(`${key} key---> ${this.casedatainfo[key]}`);
                 //console.log('result -- stringfy--'+JSON.stringify(this.casedatainfo[key]));
                  for(let key1 in this.casedatainfo[key]){
                    console.log(`${key1} key1---> ${this.casedatainfo[key][key1]}`);
                    console.log('result key==='+key);
                        if(key == 0 && key1 == "Core_IPS_Default_Data__c"){
                            this.descriptiondefault = this.casedatainfo[key][key1];
                        }
                        if(key == 1 && key1 == 'Core_IPS_Default_Data__c'){
                            this.Assetdefault = this.casedatainfo[key][key1];
                        }
                        if(key == 2 && key1 == 'Core_IPS_Default_Data__c'){
                            this.Projectdefault = this.casedatainfo[key][key1];
                        }
                        if(key == 3 && key1 == 'Core_IPS_Default_Data__c'){
                            this.CaseTypedefault = this.casedatainfo[key][key1];
                        }
                        if(key == 4 && key1 == 'Core_IPS_Default_Data__c'){
                            this.CaseSubcategorydefault = this.casedatainfo[key][key1];
                        }
                        if(key == 5 && key1 == 'Core_IPS_Default_Data__c'){
                            this.Supported_Productdefault = this.casedatainfo[key][key1];
                        }
                        if(key == 6 && key1 == 'Core_IPS_Default_Data__c'){
                            this.IssueSourcedefault = this.casedatainfo[key][key1];
                        }
                        if(key == 7 && key1 == 'Core_IPS_Default_Data__c'){
                            this.Case_Categorydefault = this.casedatainfo[key][key1];
                        }
                        if(key == 8 && key1 == 'Core_IPS_Default_Data__c'){
                            this.CaseSubcategoryDetaildefalut = this.casedatainfo[key][key1];
                        }
                    } 
                }
        console.log('descriptiondefault--'+this.descriptiondefault);
        console.log('Assetdefault--'+this.Assetdefault);
        console.log('Projectdefault--'+this.Projectdefault);
        console.log('CaseTypedefault--'+this.CaseTypedefault);
        console.log('CaseSubcategorydefault--'+this.CaseSubcategorydefault);
        console.log('Supported_Productdefault--'+this.Supported_Productdefault);
        console.log('IssueSourcedefault--'+this.IssueSourcedefault);
        console.log('Case_Categorydefault--'+this.Case_Categorydefault);
        console.log('CaseSubcategoryDetaildefalut--'+this.CaseSubcategoryDetaildefalut);
        })
       .catch(error => {this.error = error;});}
}