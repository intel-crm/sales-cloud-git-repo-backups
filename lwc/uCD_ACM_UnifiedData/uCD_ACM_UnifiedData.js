import { LightningElement,track,api,wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import unifiedDataValues from "@salesforce/apex/UCD_ACM_UnifiedDataController.getUnifiedData";
//import Account_Id from '@salesforce/Account/Id';
//import Acct_CompWatchList from '@salesforce/schema/Account.complaince_watchlist_test__c';
import Acct_BPId from '@salesforce/schema/Account.Core_Business_Party_Id__c';
import Acct_CustAggrType from '@salesforce/schema/Account.Core_Customer_Aggregation_Type__c';
import Acct_masteredName from '@salesforce/schema/Account.Core_Data_Simplified_Account_Nm__c';
import Acct_LocalLang from '@salesforce/schema/Account.Core_Data_Simplified_Local_Language_Nm__c';
import Acct_Country from '@salesforce/schema/Account.Core_Data_Country_Nm__c';
import Requested_Name from '@salesforce/schema/Account.Core_Requested_Name__c';
import Acct_Unifiedherarchy from '@salesforce/schema/Account.Unified_Hierarchy_View__c';
import Acct_Website from '@salesforce/schema/Account.Core_MDM_Website__c'
import Acct_Global from '@salesforce/schema/Account.Core_Unified_Global_Customer__r.Name';
import Acct_GlobalName from '@salesforce/schema/Account.Core_Unified_Global_Customer_Name__c';
import Acct_GlobalID from '@salesforce/schema/Account.Core_Unified_Global_Customer_BP_Id__c';
import Acct_Intermediate1 from '@salesforce/schema/Account.Core_Unified_Intermediate_Customer__r.Name';
import Acct_Intermediate2 from '@salesforce/schema/Account.Core_Unified_Intermdt_Customer_2_Name__c';
import Acct_IntermediateL2Id from '@salesforce/schema/Account.Core_Unified_Intermdt_Customer_2_BP_Id__c';// added by sadiq
import Acct_Intermediate2Name from '@salesforce/schema/Account.Core_Unified_Intermediate_Customer_Name__c';
import Acct_Intermediate2Id from '@salesforce/schema/Account.Core_Unified_Intermediate_Customer_BP_Id__c';
import Acct_countryCust from '@salesforce/schema/Account.Core_Unified_Country_Customer__r.Name';
const fields = [Acct_BPId,Acct_CustAggrType,Acct_masteredName,Acct_LocalLang,Acct_Country,Acct_Unifiedherarchy,Acct_Website,Acct_Global,Acct_GlobalName,Acct_GlobalID,Acct_Intermediate1,Acct_Intermediate2,Acct_Intermediate2Name,Acct_Intermediate2Id,Acct_countryCust,Requested_Name,Acct_IntermediateL2Id];

export default class UCD_ACM_UnifiedData extends LightningElement {
        @api
        recordId;
        @track cpe='';
        @track cwl='';
        aggregationType=[];
        isDisplayPage = false;
        apexResponse;


        @wire(getRecord, {
            recordId: "$recordId",
            fields
            
        })
            account;
        @wire(getObjectInfo, { objectApiName: 'Account' })
            objectInfo;

        @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Acct_CustAggrType })
        setPicklistOptions({error, data}) {
            if (data) {
                console.log('data--> ',data);
                this.aggregationType = data.values;
                
            }
        }
        
        renderedCallback(){
            unifiedDataValues({accountId:this.recordId}).then(response => {
                this.cpe = response.customerProcessEngg;
                this.cwl = response.complianceWatchList;
                this.isDisplayPage = true;
                
            })
            .catch(error => {
                console.log('Error is --> ',error);
                this.error = error;
                
            })
        }
    
        get bpId() {
            console.log('this.account.data--> ',this.account);
            console.log('bpid',getFieldValue(this.account.data, Acct_BPId));
            return getFieldValue(this.account.data, Acct_BPId);
        }

        get customerAggType() {
            console.log('this.aggregationType--> ',this.aggregationType.length);
            if(this.aggregationType.length > 0 && getFieldValue(this.account.data, Acct_CustAggrType) != null){
                for(var i=0;i<=this.aggregationType.length;i++){
                    if(this.aggregationType[i].value == getFieldValue(this.account.data, Acct_CustAggrType)){
                        return this.aggregationType[i].label;
                    }
                }
            }
            return '';
        }
        get MasterAccountName() {
        return getFieldValue(this.account.data, Acct_masteredName);
        }
        get localName() {
        return getFieldValue(this.account.data, Acct_LocalLang);
        }
        get countryName() {
        return getFieldValue(this.account.data, Acct_Country);
        }
        get requestedName() {
            return getFieldValue(this.account.data, Requested_Name);
            }
        get unifiedHierarchy() {
        return getFieldValue(this.account.data, Acct_Unifiedherarchy);
        }
        get unifiedWebsite(){
        return getFieldValue(this.account.data, Acct_Website);
        }
        get unifiedGlobal() {
        return getFieldValue(this.account.data, Acct_Global);
        
        }
        get unifiedGlobalName(){
        return getFieldValue(this.account.data,Acct_GlobalName);
        }
        get unifiedGlobalId1(){
            console.log('globalid-->',getFieldValue(this.account.data, Acct_GlobalID));
        return getFieldValue(this.account.data, Acct_GlobalID);
        }
        get unifiedInter() {
        return getFieldValue(this.account.data, Acct_Intermediate1);
        }
        get unifiedInterId2(){
            return getFieldValue(this.account.data, Acct_Intermediate2Id);

        }
        get unifiedInterName2(){
        return getFieldValue(this.account.data, Acct_Intermediate2Name);
        }
        get unifiedInter2() {
        return getFieldValue(this.account.data, Acct_Intermediate2);
        }
        get unifiedInterLevel2Id() {// added by sadiq
            return getFieldValue(this.account.data, Acct_IntermediateL2Id);
        }
        get unifiedCountry() {
        return getFieldValue(this.account.data, Acct_countryCust);
        }
        
    
      
}