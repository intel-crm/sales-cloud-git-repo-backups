import { LightningElement,track,api,wire } from 'lwc';
import getExistingMembers from '@salesforce/apex/Core_IPS_ProjectController_Lex.getExistingMembers';
import getAddMembers from '@salesforce/apex/Core_IPS_ProjectController_Lex.getAddMembers';
//import addMembersToProject from '@salesforce/apex/Core_IPS_ProjectController_Lex.addMembersToProject';
//import { refreshApex } from '@salesforce/apex';
// import getSearchMembers from '@salesforce/apex/Core_IPS_ProjectController_Lex.getSearchMembers';
   
    const columns = [{
        label: 'First Name',
        fieldName: 'FirstName',
        type: 'text',
        sortable: true
        },
        {
        label: 'Last Name',
        fieldName: 'LastName',
        type: 'text',
        sortable: true
        },
        {
        label: 'Email',
        fieldName: 'Email',
        type: 'email',
        sortable: true
        },
        {
        label: 'Account Name',
        fieldName: 'Name',
        type: 'text',
        sortable: true
        }        
    ];
    
export default class Core_IPS_AddProjectMember extends LightningElement {   

    @track error;
    @track sortBy;
    @track sortDirection;
    @api recordId;
    @api searchKey = '';
    sections = ['A'];
    memList=[];
    addMemList=[];
    addMemSearchList=[];
    filteredRecords=[];
    memIds=[];
    memRecords=[];
    searchKey='';
    columns=columns;
    limitSize=7;
    offset=0;
    ConnectedCallback(){
        this.getData();
        //this.RefreshValues();
    }
   /* async RefreshValues() {
        await new Promise(resolve => setTimeout(resolve, 1500));
        this.getMembers('Load Data');
        this.getMembers('All Data');
    }
    loadMoreData(event) {
            
            const currentRecord = this.addMemList;
            const lastRecId = currentRecord[currentRecord.length - 1].Id;
            getExistingMembers({recordId: lastRecId})
            .then(result => {
                console.log('data:' + JSON.stringify(result));
                const currentData = result.sObjectRecords;
                const newData = currentRecord.concat(currentData);
                this.data = newData; 
            })
            .catch(error => {
                console.log('-------error-------------'+error);
            });*/
      /*  const currentRecord = this.addMemList;
        const { target } = event;
        target.isLoading = true;
        this.offSet = this.offSet + this.limitSize;
        this.getMembers('Load Data')
        .then(()=> {
            target.isLoading = false;
        });  
        }*/
   // @wire(getExistingMembers, { projectId: '$recordId' } ) wiredExistingMembers({data, error}){
   
    getExistingMembers() {
        getExistingMembers({ projectId : this.recordId })
    .then(data=>{
        if (data) {
            console.log('pavani-----existingmembers'+data);
            for (let i = 0; i < data.length; i++) {
                let ele = {
                    'FirstName' : data[i].Core_IPS_Contact__r.FirstName,
                    'LastName' : data[i].Core_IPS_Contact__r.LastName,
                    'Email' : data[i].Core_IPS_Contact__r.Email,
                    'Name' : data[i].Core_IPS_Contact__r.Account.Name
                };
                this.memList = [...this.memList, ele];
              //  this.memIds = [...this.memIds, data[i].Core_IPS_Contact__c];
                console.log('pavani----memList'+this.memList);
            }
        }
    })
    .catch(error=>{
        console.log('error----'+error.message);
    })
}


 /* // @wire(getAddMembers, { projectId: '$recordId' } ) wiredAddMembers({data, error}){
    getAccounts(msg){
        let type = msg;
        return getAddMembers({
            memIds :  this.memIds,
            limitRows : this.limitSize,
            offset1 : this.offset,
            fetchType : type
        })
        .then( data => {
            if(data) {
           /*  console.log('data:' + JSON.stringify(data));
              
            data.forEach(element => {
                let elt = {};
                elt.FirstName = element.Contact.FirstName;
                elt.LastName = element.Contact.LastName;
                elt.Email =  element.Contact.Email;
                elt.Name =  element.Contact.Account.Name;
                
                if(type === 'Load Data') {
                    this.addMemList = [...this.addMemList, elt];
                } else if(type === 'All Data') {
                    this.memRecords = [...this.memRecords, elt];
                }
            });
            this.flag = true;    
        }  
           // this.addMemList = data;
            //this.filteredRecords = [... this.addMemList];
        })
    .catch(error=>{
        console.log('error-----'+JSON.stringify(error));
    })*/
 /*   for (let i = 0; i < data.length; i++) {
        let ele = {
            'FirstName' : data[i].Contact.FirstName,
            'LastName' : data[i].Contact.LastName,
            'Email' : data[i].Contact.Email,
            'Name' : data[i].Contact.Account.Name
        };
        if(type === 'Load Data') {
            this.addMemList = [...this.addMemList, ele];
        } else if(type === 'All Data') {
            this.memRecords = [...this.memRecords, ele];
        }
    }
    this.flag = true;
}
})
.catch(error=>{
console.log(' Error: '+error.message);
})
}
/*
     doSorting(event) {
      this.sortBy = event.detail.fieldName;
      this.sortDirection = event.detail.sortDirection;
      this.sortData(this.sortBy, this.sortDirection);

    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.memList));
        let keyValue = (a) => {
        return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
        parseData.sort((x, y) => {
        x = keyValue(x) ? keyValue(x) : ''; 
        y = keyValue(y) ? keyValue(y) : '';

        return isReverse * ((x > y) - (y > x));
        });
        this.memList = parseData;
    }    
    handleKeyChange(event){*/
        //this.searchKey = event.target.value;
       /* this.searchString = this.searchKey.toString().toLowerCase();
        let tempContacts = [];
        if(this.searchKey){
              this.filteredRecords = this.addMemList.forEach(contact => {
               if((contact.FirstName.toLowerCase().includes(this.searchString))||(contact.LastName.toLowerCase().includes(this.searchString))||(contact.Email.toLowerCase().includes(this.searchString))||(contact.Name.toLowerCase().includes(this.searchString))) 
               tempContacts.push(contact);
              });
            this.filteredRecords = this.tempContacts;
        } else {
          this.filteredRecords = this.addMemList; 
        }*/
       /* try{
            let tempMembers = [];
            this.searchKey = event.target.value;
            if(this.searchKey) {
                this.memRecords.forEach(contact =>{
                    if(contact.FirstName != undefined && contact.FirstName.toLowerCase().indexOf(this.searchKey.toString().toLowerCase()) !== -1){
                        tempMembers.push(contact);
                    } else if(contact.LastName != undefined && contact.LastName.toLowerCase().indexOf(this.searchKey.toString().toLowerCase()) !== -1){
                        tempMembers.push(contact);
                    } else if(contact.Email != undefined && contact.Email.toLowerCase().indexOf(this.searchKey.toString().toLowerCase()) !== -1){
                        tempMembers.push(contact);
                    } else if(contact.Name != undefined && contact.Name.toLowerCase().indexOf(this.searchKey.toString().toLowerCase()) !== -1){
                        tempMembers.push(contact);
                    }
                });
                this.addMemSearchList = tempMembers;
                this.flag =false;
            } else {
                this.flag = true;
            }
        } catch(error){
            console.log('error in search handler '+error.message());
        }
      }
      addMember(){  
        var selectedRecords =  
         this.template.querySelector("lightning-datatable").getSelectedRows();  
        addMembersToProject({addMem: selectedRecords, addMemList: this.addMemList, projectId: '$recordId' })  
        .then(result=>{  
          return refreshApex(this.addMemList);  
        })  
        .catch(error=>{  
          alert('Cloud not add'+JSON.stringify(error));  
        })  
      }  */
    }