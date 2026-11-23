import { 
    LightningElement,
    track,
    api, 
    wire 
} from 'lwc';

const DELAY = 100;

import fetchUltimateAccounts from '@salesforce/apex/Core_MDF_AccountHierarchyController.fetchUltimateAccounts';

export default class AccountHierarchy extends LightningElement {

    accountName= '';

    @track accountList= [];
    @wire (fetchUltimateAccounts,{
        accName:'$accountName'
    })
    retrieveAccounts({error, data}){
        if(data){
            this.accountList=data;
        }
        else if(error){

        }
    }

}