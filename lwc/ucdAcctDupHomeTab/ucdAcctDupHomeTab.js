import { LightningElement, track, wire } from 'lwc';
import getRegionHome from '@salesforce/apex/UCD_AccountDuplicate.getRegionHome';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import REGION_FIELD from '@salesforce/schema/Account.Core_Geo__c';

export default class UcdAcctDupHomeTab extends LightningElement {
    @track regionCount = [];

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    AccountInfo;

    @wire(getPicklistValues, { recordTypeId: '$AccountInfo.data.defaultRecordTypeId', fieldApiName: REGION_FIELD})
    RegionPicklistValues({ data, error }){
        if(data){           
            this.regionValues = data.values;
            if(this.regionValues){
                for(let i=0;i<this.regionValues.length;i++){
                    getRegionHome({regValue : this.regionValues[i].value})
                    .then(result => {                          
                            let regionDetails = {
                                regionName : "",
                                recordCount : ""
                            }
                            regionDetails.regionName = this.regionValues[i].value;
                            regionDetails.recordCount = result.length;
                            this.regionCount.push(regionDetails);
                    })
                    .catch(error => {
                        console.log("error " + JSON.stringify(error));
                    });                   
                }               
            }                      
        }
        if(error){
            console.log(` Error while fetching Picklist values  ${error}`);
            this.error = error;
            this.regionValues = undefined;
        }
    }
    navigateToDetail(){
        let sfdcBaseURL = window.location.origin;
        let acctUrl = sfdcBaseURL+'/lightning/n/CIM_Duplicate_Accounts?0.source=alohaHeader';
        window.open(acctUrl);
    }
}