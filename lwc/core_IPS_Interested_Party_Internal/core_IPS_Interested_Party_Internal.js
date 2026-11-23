import { LightningElement,track,api , wire} from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getSearchRecords from "@salesforce/apex/Core_IPS_Interested_Party_LEX.getUserDetailsBasedOnSearch";
import saveRecordhandle from "@salesforce/apex/Core_IPS_Interested_Party_LEX.saveInternalInterestedParty";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//columns to display
const ACC_PRODUCT__COLS =  [
    
    {
        label: 'Name',
        fieldName:  'mapNavigationUrl', 
        type: 'url',
        typeAttributes: {label: {fieldName: 'Name'},
            target: '_blank', 
        },
        cellAttributes: { class: 'slds-text-color_error slds-text-title_bold'},
        sortable: true,
    },
    {
        label: 'FirstName',
        fieldName: 'FirstName'
    },
    {
        label: 'LastName',
        fieldName: 'LastName'
    },
    {
        label: 'Email',
        fieldName: 'Email'
    },
   
];

export default class Core_IPS_Interested_Party_Internal extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference)
    getpageRef(pageRef) {
        console.log('data => ', JSON.stringify(pageRef));
    }

    @api recordId;
    sVal = '';
    @track isMapResultPresent = false;
    @track mapRecords;
    @track column = ACC_PRODUCT__COLS;
    @track selectedIPS;
    @track dataWrapper =[];
    @track isSaveButtonShow = false;
    @api isLoaded = false;
    @track userDetails;
    @track isSearchValueBlank = false;
    connectedCallback() {
        
    }
   
    updateSeachKey(event) {
        this.sVal = event.target.value;
        console.log('this.sVal'+this.sVal);
        if(this.sVal != ''){
            this.isSearchValueBlank = true;
            console.log('-->this.isSearchValueBlank in handle search'+this.isSearchValueBlank);
        }
    }
    handleSearch() {
        console.log('Invoked Search button1');
console.log('searchValueUser'+this.sVal);
console.log('caseid'+this.recordId);

        this.isLoaded = true;
        getSearchRecords({searchValueUser : this.sVal,
                            caseid : this.recordId})
               .then(data =>{
                if(data){
                    this.mapRecords ='';
                    this.dataWrapper ='';
                    this.isMapResultPresent = false;
                    console.log('Invoked Search button2');
                    console.log(data);
                    let dataWrapper = [];
                        for(let i=0;i<data.length;i++) {
                         let obj = {
                             'Id':data[i].Id,
                             'Name' : data[i].Name,
                             'FirstName':data[i].FirstName,
                             'LastName':data[i].LastName,
                             'Email':data[i].Email,
                             'mapNavigationUrl': '/lightning/r/' + data[i].Id + '/view'
                        };
                        dataWrapper = [...dataWrapper, obj];
                     }
                     console.log(dataWrapper);
         
                        this.mapRecords = dataWrapper;
                        this.isMapResultPresent = true;
                        this.isSaveButtonShow = true; 
                        this.isLoaded = false;

                }
               })
    }
    getSelectedRecords(event) {
        if(event.detail.selectedRows.length > 0) {
            this.selectedIPS = event.detail.selectedRows;
            console.log(JSON.stringify(event.detail.selectedRows));
            let dataWrapper = [];

            for(let i=0;i<event.detail.selectedRows.length;i++) {
                console.log('hey im in');
                  dataWrapper = [...dataWrapper, this.selectedIPS[i].Id]; 
                  console.log('dataWrapper'+JSON.stringify(dataWrapper)); 
            }
          
            this.userDetails = dataWrapper;
            console.log('userDetails1'+this.userDetails);

        } else {
        }
    }
   
    saveHandler() {
        console.log('userDetails'+JSON.stringify(this.userDetails));

        this.isLoaded = true;
        console.log('test' + this.recordId);
                saveRecordhandle({
                    caseId: this.recordId,
                    userID: this.userDetails,
                    contactID: ''

                })
                    .then(result => {
                        this.isSaveButtonShow = false; 
                        this.navigateToViewCase();

                        //this.showSuccessToast();
                        if (result !== undefined || result !== null || result !== '') {
                            console.log("result" + JSON.stringify(result));
                            //this.navigateToViewCase();
                        } else {

                            console.log("result" + JSON.stringify(result));
                        }
                    })
                    .catch(error => {
                        if (error !== undefined) {
                            console.log("this.edq" + JSON.stringify(error));
                            this.isLoaded = false;
                        }

                    });
    }
    navigateToViewCase() {
        console.log('navi'+this.recordId);
        window.open('/lightning/r/Case/' + this.recordId + '/view', '_top');
        this.isLoaded = false;

        /*this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: '5003F000006pZfLQAU',
                actionName: 'view',
            },
        });*/

    }
    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Record Updated',
            message: 'Record Updated  ',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}