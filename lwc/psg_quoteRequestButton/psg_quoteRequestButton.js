import { LightningElement,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo,getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
//Lakshman added to toggle new quote button for PSG and Tenders
import userId from '@salesforce/user/Id';
//import getUserPermissionSets from '@salesforce/apex/PSG_Utility.getUserPemissionSets';
// button toggle ends

export default class psg_quoteRequestButton extends NavigationMixin(LightningElement) {
    @track isModalOpen = false;
    @track isPSG = false;
    @track isTender = false;
    @track userPemissionSet=[];

    handleNavigate() {
        var compDefinition = {
            componentDef: "c:psg_QuoteRequest",
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });
    }
    get recordTypeId() {
        const rtis = this.objectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'Pricing Tender Quote - Create');
    }
    //Lakshman added to toggle new quote button for PSG and Tenders
    openNewIQRQuoteForm(){
        let temp = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'SBQQ__Quote__c',
                actionName: 'new'             
            },
            state : {
                nooverride: '1',
                //c/ucdGridWithPaginationdefaultFieldValues : "RecordTypeId = this.recordTypeId" 
                //defaultFieldValues:"RecordType.Name = Pricing Tender Quote - Create" //Please chnage this
            }
        };
        this[NavigationMixin.Navigate](temp);
    }

    
    /*connectedCallback(){
        console.log('inside connected call back '+userId);
        this.getUserPermissionSets(userId);
    }      
    
    getUserPermissionSets(userId){
        getUserPermissionSets({ userId: userId})
        .then(data => {
            console.log("PermissionSets:" + JSON.stringify(data));
            data.forEach(item => {
                if((item.PermissionSet.Name).includes('PSG_')) {
                    this.isPSG = true;
                }
                if((item.PermissionSet.Name).includes('Tender')){
                    this.isTender = true;
                }
            });
            /*
            //this.userPemissionSet = data;
            console.log("PermissionSets:" + JSON.stringify(data));
            if(JSON.stringify(data).includes('PSG_')){
                this.isPSG = true;
            }
            if(JSON.stringify(data).includes('Tender')){
                this.isTender = true;
            }
            
        })
        .catch(error => {
            console.log('Error Updating Records',JSON.stringify(error),'error');
            this.userPemissionSet = [];
        })
    }*/
    //Toggle button ends here

    
    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }
    submitDetails() {
        this.isModalOpen = false;
    }
}