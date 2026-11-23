import { LightningElement,api,track, wire } from 'lwc';
import getExistingAccounts from '@salesforce/apex/Core_IPS_ProjectController_Lex.getExistingAccounts';
import getAddAccounts from '@salesforce/apex/Core_IPS_ProjectController_Lex.getAddAccounts';
const columns = [
    { label: 'Account Name', fieldName: 'name', sortable: true, type: 'text' },
    { label: 'Account Owner', fieldName: 'owner', sortable: true, type: 'text' },
    { label: 'Account ID', fieldName: 'accid', sortable: true, type: 'text' },
    { label: 'CIM ID', fieldName: 'cim', sortable: true, type: 'text' },
    { label: 'Members', fieldName: 'members', sortable: true, type: 'text' }
];
export default class Core_IPS_AddAccount_Lex extends LightningElement {

    switchView;
    isModalOpen;


    @api recordId;

    activeSections = ['A', 'B'];
    columns = columns;

    searchText='';

    existingData =[];
    accountsData = [];
    searchResult = [];
    allAccountsData =[];
    accntIds = [];

    

    rowLimit =25;
    rowOffSet=0;

    addColumns = [
        { label: 'Account Name', fieldName: 'name', sortable: true, type: 'text' },
        { label: 'Account Owner', fieldName: 'owner', sortable: true, type: 'text' },
        { label: 'Account ID', fieldName: 'accid', sortable: true, type: 'text' },
        { label: 'CIM ID', fieldName: 'cim', sortable: true, type: 'text' },
        { label: 'Members', fieldName: 'members',type: "button", typeAttributes: {  
            label: 'Please Select',  
            name: 'members',  
            title: 'Members',  
            disabled: false,  
            value: 'Members'  
        }}
    ];

    connectedCallback() {
        this.getExistantAccounts();
        this.RefreshValues();
    }
    async RefreshValues() {
        await new Promise(resolve => setTimeout(resolve, 1500));
        this.getAccounts('Load Data');
        this.getAccounts('All Data');
    }

    getExistantAccounts() {
        getExistingAccounts( {
            projectId : this.recordId
        })
        .then(data=>{
            if(data){
                for (let i = 0; i < data.length; i++) {
                    let obj = {
                        'name' : data[i].Core_Account__r.Name,
                        'owner' : data[i].Core_Account__r.Owner.Name,
                        'accid' : data[i].Core_Account__r.Id,
                        'cim' : data[i].Core_Account__r.Core_CIM_ID__c,
                        'members' : data[i].Core_Members__c
                    };
                    this.existingData = [...this.existingData, obj];
                    this.accntIds = [...this.accntIds, data[i].Core_Account__c];
                }
            }
        })
        .catch(error=>{
            console.log(' Error Occured:  '+error.message);
        })
    }

    getAccounts(mssg){
        let type = mssg;
        return getAddAccounts({
            accIds :  this.accntIds,
            limitSize : this.rowLimit,
            offset : this.rowOffSet,
            fetchType : type
        })
        .then( data => {
            if(data) {
                for (let i = 0; i < data.length; i++) {
                    let obj = {
                        'name' : data[i].Name,
                        'owner' : data[i].Owner.Name,
                        'accid' : data[i].Id,
                        'cim' : data[i].Core_CIM_ID__c
                    };
                    if(type === 'Load Data') {
                        this.accountsData = [...this.accountsData, obj];
                    } else if(type === 'All Data') {
                        this.allAccountsData = [...this.allAccountsData, obj];
                    }
                }
                this.switchView = true;
            }
        })
        .catch(error=>{
            console.log(' Error: '+error.message);
        })
    }

    handleLoadMore(event) {
        const currentRecord = this.accountsData;
        const { target } = event;
        target.isLoading = true;
        this.rowOffSet = this.rowOffSet + this.rowLimit;
        this.getAccounts('Load Data')
        .then(()=> {
            target.isLoading = false;
        });  
        
    }
    handleKeyChange(event) {
        try{
            let tempAccountsVar = [];
            this.searchText = event.target.value;
            if(this.searchText) {
                this.allAccountsData.forEach(account =>{
                    if(account.name != undefined && account.name.toLowerCase().indexOf(this.searchText.toString().toLowerCase()) !== -1){
                        tempAccountsVar.push(account);
                    } else if(account.owner != undefined && account.owner.toLowerCase().indexOf(this.searchText.toString().toLowerCase()) !== -1){
                        tempAccountsVar.push(account);
                    } else if(account.accid != undefined && account.accid.toLowerCase().indexOf(this.searchText.toString().toLowerCase()) !== -1){
                        tempAccountsVar.push(account);
                    } else if(account.cim != undefined && account.cim.toLowerCase().indexOf(this.searchText.toString().toLowerCase()) !== -1){
                        tempAccountsVar.push(account);
                    }
                });
                this.searchResult = tempAccountsVar;
                this.switchView =false;
            } else {
                this.switchView = true;
            }
        } catch(error){
            console.log('error in search handler '+error.message());
        }
    }

    //Row action code

    handleRowAction(event) {
        console.log('row handler '+event.detail.action.name);
        this.isModalOpen = true;
    }

    initValue ='Selective';
    combOptions =[{label: 'Selective', value: 'Selective'}, {label: 'All', value: 'All'}];
    handleCombChange(event){
        console.log('clicked on value'+event.detail.value);
    }

    //modal methods
    closeModal() {
        this.isModalOpen = false;
    }


    //Code for sorting functionality
    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
            };
        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.existingData];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.existingData = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    /*sDirection;
    sBy;
     

    onHandleSortTwo(event) {
        this.sBy = event.detail.fieldName;    
        this.sDirection = event.detail.sortDirection;  
        this.sortAccountData(event.detail.fieldName, event.detail.sortDirection);   
    }

    sortAccountData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.accountsData));
        let keyValue = (a) => {
            return a[fieldname];
        };
       let isReverse = direction === 'asc' ? 1: -1;
           parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';       
            return isReverse * ((x > y) - (y > x));
        });
        if(this.switchView === true){
            this.accountsData = parseData;
        } else {
            this.searchResult = parseData;
        }
    }*/
}