import { LightningElement,track, wire} from 'lwc';
import getAllUsers from '@salesforce/apex/Seismic_UserController.getAllUsers';
import deleteUsers from '@salesforce/apex/Seismic_UserController.deleteUsers';
import saveLessonlyUsers from '@salesforce/apex/Lessonly_UserController.saveLessonlyUsers';
import saveSeismicUsers from '@salesforce/apex/Seismic_UserController.saveSeismicUsers';
import clearLastLoad from '@salesforce/apex/Seismic_UserController.clearLastLoad';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Seismic_UserDeletion extends LightningElement {
    @track columns = [
        {  label: 'Seismic Id',  fieldName: 'Seismic_UserId__c',   type: 'text',  sortable: true  },
        {  label: 'Lessonly Id',  fieldName: 'User_Id__c',   type: 'text',  sortable: true  },
        {  label: 'Name',  fieldName: 'Name__c',   type: 'text',  sortable: true  },
        {  label: 'Email', fieldName: 'Email__c', type: 'text', sortable: true },
        {  label: 'Deleted In Seismic',  fieldName: 'Deleted_In_Seismic__c',  type: 'boolean', sortable: true },
        {  label: 'Deleted In Lessonly', fieldName: 'Deleted_In_Lessonly__c', type: 'boolean', sortable: true },
        {  label: 'Status', fieldName: 'Status__c', type: 'text', sortable: true }
    ];

    initialRecords;
    searchString;
    wiredDataResult;
    @track isLoaded = false;
    @track error;
    @track data ;
    @wire(getAllUsers)
    wiredOpps(result) {

        this.wiredDataResult = result;
        if (result.data) {
            this.data = result.data;
            this.initialRecords = result.data;
            this.isLoaded = true;
        }
    }

   

    getSelectedName() {
        const selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
        const selectedIds = [];
        
        
        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++){
            selectedIds.push(selectedRows[i].Id);
            console.log("You selected: " + selectedRows[i].Id);
        }

        deleteUsers({ids: selectedIds}).then(result => {
            console.log("User updated!" + result)
             // Display fresh data in the datatable
             this.selectedRows = [];
             return refreshApex(this.wiredDataResult);
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: error.message,
                    variant: 'error'
                })
            );
        });
    }

    handleSearchChange( event ) {

        this.searchString = event.detail.value;
        console.log('Updated Search String is ' + this.searchString );

    }

    handleSearch( event ) {

        const searchKey = event.target.value.toLowerCase();
        console.log( 'Search String is ' + searchKey );

        if ( searchKey ) {

            this.data = this.initialRecords;
           
            console.log( 'Account Records are ' + JSON.stringify( this.data ) );
            
            if ( this.data ) {

                let recs = [];
                
                for ( let rec of this.data ) {

                    console.log( 'Rec is ' + JSON.stringify( rec ) );
                    let valuesArray = Object.values( rec );
                    console.log( 'valuesArray is ' + JSON.stringify( valuesArray ) );
 
                    for ( let val of valuesArray ) {

                        console.log( 'val is ' + val );
                        let strVal = String( val );
                        
                        if ( strVal ) {

                            if ( strVal.toLowerCase().includes( searchKey ) ) {

                                recs.push( rec );
                                break;
                        
                            }

                        }

                    }
                    
                }

                console.log( 'Matched Accounts are ' + JSON.stringify( recs ) );
                this.data = recs;

             }
 
        }  else {

            this.data = this.initialRecords;

        }        

    }

/*
    connectedCallback() {
        (async () => {
            try {
                await getUserDetails();
                
                //return refreshApex(this.wiredDataResult);
                //await this.promiseFunc();
                //;
                console.log('2nd then executes after 3 seconds async, value:' + value);
            } catch (error) {
                this.error = 'connectedcallback: '+ error;
            } finally {
                this.isLoaded = true;
            }
        })();
    }
*/


clearLastLoad() {
    this.isLoaded = false;
    (async () => {
        try {
            await clearLastLoad();
            return refreshApex(this.wiredDataResult);
        } catch (error) {
            this.error = 'clearLastLoad: '+ error;
        } finally {
            this.isLoaded = true;
        }
    })();
}

    loadUsers() {
        this.isLoaded = false;
        (async () => {
            try {
                await saveLessonlyUsers();
                await saveSeismicUsers();
                return refreshApex(this.wiredDataResult);

                console.log('2nd then executes after 3 seconds async, value:' + value);
            } catch (error) {
                this.error = 'loadusers: '+ error;
            } finally {
                this.isLoaded = true;
            }
        })();
       
    }



}