import { LightningElement, track,wire } from 'lwc';
import getRegionListSort from '@salesforce/apex/UCD_AccountDuplicate.getRegionListSort';
import getAccountsForCim from '@salesforce/apex/UCD_AccountDuplicate.getAccountsForCim'; 
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import REGION_FIELD from '@salesforce/schema/Account.Core_Geo__c';
  
export default class UcdAccrDuplicatesTab extends LightningElement {

   
    @track accountsForCim = []; // Accounts to get based on CIM ID
    @track pageLoaded = false; //Spinner variable
    @track isModalOpen = false; // Modal pop up varibale to open and close
    @track regionValues=[];
    @track num = 0;
    @track regionData = [];
    @track error;
    @track noAccessToObject = false;
    @track showTable = false;
    
    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    AccountInfo;
    
    @wire(getPicklistValues, { recordTypeId: '$AccountInfo.data.defaultRecordTypeId', fieldApiName: REGION_FIELD})
    RegionPicklistValues({ data, error }){
        if(data){  
            console.log('!!!!!!'+JSON.stringify(this.RegionPicklistValues));
            this.regionValues = data.values;
            this.noAccessToObject = false;
            if(this.regionValues){
              for(let i=0;i<this.regionValues.length;i++){
                    let regionDetails = {
                         region: '', data: [] 
                    }
                    getRegionListSort({regValue : this.regionValues[i].value})
                    .then(result => {
                        this.pageLoaded = false;
                        regionDetails.region = this.regionValues[i].value;
                        regionDetails.data = result;
                        this.regionData.push(regionDetails);                       
                        this.num = this.num+1;
                        if( this.num == 4){
                            this.noAccessToObject = false;
                            this.pageLoaded = true;
                            this.showTable = true;
                        }
                    })
                    .catch(error => {
                        console.log("error " + JSON.stringify(error));
                    })  
                    .finally(() => {
                        console.log('Finally');
                    })                
                }               
            }                   
        }
        else if(data === undefined && data != ''){
            console.log('#####'+JSON.stringify(data));
            this.pageLoaded = true;
            this.showTable = false;
            this.noAccessToObject = true;
            this.isModalOpen = false;
            
        }
        else if(location.reload()){
            setTimeout(() => {this.noAccessToObject =false;}, 3000); 
        }
        else if(error){
            console.log(` Error while fetching Picklist values  ${error}`);
            this.error = error;
            this.regionValues = undefined;
        }
    }

    //Assigning data to pop up on click of cim id
    recordClickHandler(event) {
        getAccountsForCim({ cimId: event.detail })
            .then(result => {
                for (let index in result) {
                    let acct = {};
                    acct['accountName'] = result[index]['Name'];
                    acct['accountOwner'] = result[index]['Owner'] === undefined ? '' : result[index]['Owner']['Name'];
                    acct['isIPA'] = result[index]['Core_Intel_Partner_Alliance_PartnerGroup__c'] ? 'Yes' : 'No';
                    acct['salesgroup'] = result[index]['Core_Sales_Groups__c'];
                    acct['accountid'] = result[index]['Id'];
                    acct['contactCount'] = result[index]['Contacts'] === undefined ? 0 : result[index]['Contacts'].length;

                    this.accountsForCim.push(acct);
                }
                this.isModalOpen = true;
                
            })
            .catch(error => {
                console.log(error);
            })
    }

    //It will navigate to account detail on click of account id
    navigateToDetail(event){
        let recId = event.target.value;
        let sfdcBaseURL = window.location.origin;
        let acctUrl = sfdcBaseURL + '/' + recId;
        window.open(acctUrl);
    }

    //It will close modal pop up
    closeModal() {
        this.isModalOpen = false;
        this.accountsForCim = [];
    }
}