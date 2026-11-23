import { LightningElement, wire, track } from 'lwc';
import loadUsers from '@salesforce/apex/ManageUsers_Controller.getUsers';
import saveDeletedUser from '@salesforce/apex/ManageUsers_Controller.saveDeletedUser';
import getDeletedUsers from '@salesforce/apex/ManageUsers_Controller.getDeletedUsers';

const columns = [
    {
        label: 'Id',
        fieldName: 'id', 
        type: 'text',
    },
    {
        label: 'Name',
        fieldName: 'name', 
        type: 'text',
    }, {
        label: 'Email',
        fieldName: 'email',
        type: 'text'
    }, {
        label: 'Role',
        fieldName: 'role',
        type: 'text'
    },
        {type: "button-icon", typeAttributes: {iconName: "utility:delete", name: "delete", iconClass: "slds-icon-text-error"}, fixedWidth: 50}
    
];


const mcolumns = [
    {
        label: 'User Id',
        fieldName: 'User_Id__c', 
        type: 'text',
    },
    {
        label: 'Name',
        fieldName: 'Name__c', 
        type: 'text',
    }, {
        label: 'Email',
        fieldName: 'Email__c',
        type: 'text'
    }, {
        label: 'Role',
        fieldName: 'Role__c',
        type: 'text'
    }
    , {
        label: 'Deleted On',
        fieldName: 'CreatedDate',
        type: 'text'
    }, {
        label: 'Deleted By',
        fieldName: 'LastModifiedById',
        type: 'text'
    },
    {type: "button-icon", typeAttributes: {iconName: "utility:undo", name: "undo", iconClass: "slds-icon-text"}, fixedWidth: 50}
   
];

export default class ManageUsers extends LightningElement {
    @wire(getDeletedUsers) lessonlyusers;
    @track lessonlyusers = [];
    @track mcolumns = mcolumns;

    @track users = [];
    @track columns = columns;
    @track error;
    @track empty;
    searchValue = '';

    connectedCallback(){
        if (this.searchValue !== '') {
        loadUsers({searchKey: this.searchValue})
        .then(result => {
            console.log('result : '+JSON.stringify(result));
            if(result.users && result.users.length > 0){
                this.users = result.users;
                this.error = undefined;
                this.empty = undefined;
            } 
            else{
                this.empty = true;
            }
        })
        .catch(error => {
            this.error = error;
            //this.users = undefined;
            console.log('error : '+JSON.stringify(error));
        });
    }
   }
   handleRowAction(event) {
        if (event.detail.action.name === "delete") {
            this.deleteSelectedRow(event.detail.row);
        }
    }
    deleteSelectedRow(deleteRow) {
    if(confirm('Are you sure you want to delete this user record?')){   
    const { id } = deleteRow;
        const index = this.findRowIndexById(id);
        if (index !== -1) {
        saveDeletedUser({deletedData :JSON.stringify(this.users[index])}).then(response=>{
          console.log('response:::'+JSON.stringify(response));
          this.error = undefined;
        }).catch(error=>{
          this.error = error;
          console.log('error : '+JSON.stringify(error));
        })
         this.users = this.users
                .slice(0, index)
                .concat(this.users.slice(index + 1));
        }
    }
    }

    findRowIndexById(id) {
        let ret = -1;
        this.users.some((row, index) => {
            if (row.id === id) {
                ret = index;
                return true;
            }
            return false;
        });
        return ret;
    }
    
    handleSearchClick(event) {
        if (this.searchValue !== '') {
        loadUsers({searchKey: this.searchValue})
        .then(result => {
            console.log('result : '+JSON.stringify(result));
            if(result.users && result.users.length > 0){
                this.users = result.users;
                this.error = undefined;
            }
            else{
                this.empty = true;
            }
        })
        .catch(error => {
            this.error = error;
            //this.users = undefined;
            console.log('error : '+JSON.stringify(error));
        });
    }
    }

    searchKeyword(event) {
        this.searchValue = event.target.value;
    }

    handleUploadFile(event) {
        if (this.searchValue !== '') {
        loadUsers({searchKey: this.searchValue})
        .then(result => {
            console.log('result : '+JSON.stringify(result));
            if(result.users && result.users.length > 0)
                this.users = result.users;
                this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            //this.users = undefined;
            console.log('error : '+JSON.stringify(error));
        });
    }
    }

}