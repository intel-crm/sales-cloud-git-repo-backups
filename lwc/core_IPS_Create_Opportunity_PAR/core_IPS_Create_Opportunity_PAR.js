import { LightningElement, track, api, wire } from "lwc";
import getQueryResult from '@salesforce/apex/Core_IPS_NewMapHomePageController.getQueryResult';
import submitRecord from '@salesforce/apex/Core_IPS_CreateOpportunityPAR_Controller.submitRecord';
import { NavigationMixin } from 'lightning/navigation';
import lookupSearchProjectFieldName from '@salesforce/label/c.lookupSearchProjectFieldName';
import Core_IPS_Project_DetailsLink from '@salesforce/label/c.Core_IPS_Project_DetailsLink'; 
import Core_IPS_Project_DetailsTooltip from '@salesforce/label/c.Core_IPS_Project_DetailsTooltip';
import Core_IPS_Project_ToolTip from '@salesforce/label/c.Core_IPS_Project_ToolTip';
import Core_IPS_Supported_Product_HelpText from '@salesforce/label/c.Core_IPS_Supported_Product_HelpText';
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Opportunity.Name';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class Core_IPS_Create_Opportunity_PAR extends NavigationMixin(LightningElement){
    
    columns = [     
        {
        label: 'Supported Product Name',
        fieldName: 'supportedProductName',
    },
    {
        label: 'Product Focus Area',
        fieldName: 'mapPFA'
        
    }, 
    {
        label: 'Support Org Name',
        fieldName: 'orgNavigationUrl',
    },
    {
        label: 'Supported Product',
        fieldName: 'supportedProduct',
    },
  ];

  oppColumns = [
    {
        label: 'IPS Support ORG Admins',
        fieldName: 'orgAdminName',
    },
    {
        label: 'IPS Support ORG Admins Email',
        fieldName: 'supportedProduct',
    },
    {
        label: 'Product Focus Area',
        fieldName: 'mapPFA'
        
    }, 
    {
        label: 'Support Org Name',
        fieldName: 'orgNavigationUrl',
    },
];

    @api recordId;
    @track supportOrgName;
    @api isLightningMode;
    @track oppParId;
    @track checkBoolean=true;
    @track preSelectedRows = [];
    @track selectedSupportedProducts = [];
    @track dataselected = false;
    @track teamAddCheckBox = true;
    @track disableSubmit = true;
    @track requestJustification;
    @track createProjCheckbox = false;
    @track name;
    placeholder = "Type the name and click Search";
    @track oppotunityName;
    @track projectdata;
    @track mapRecords ; 
    @track oppTeamTable;
    @track showOppTable =false;
    @track isMapResultPresent = false;
    @track recordsToDisplay = 30;
    @track helpText;
    @track searchKey;
    @track isSearchResultPreset = false;
    @track searchResult;
    @track showSupportedProducts = false; 
    @track showSearchRecords;
    @track selectedProductId = [];
    //@track openModal= false;
    @track show = true;
    @track projstatus ='Active';
    // for Toast
    @track title;
    @track message;
    @track variant;
    // for Project
    @track noRecordsFound = false;
    @track projectid;
    @track ipsProjectid='';
    @track lookupSearchFieldNameProject = lookupSearchProjectFieldName;
    @track lookupQueryStringProject;
    @track accountIdString
    @track spinnerOn = false;
    hideCheckboxColumn = true;
    showRowNumberColumn = false;
    enableInfiniteLoading = true;
    numAndCheckboxBothCols = false;
    normalDataTable = false;
    numberOfRowsToShow = 5;
    heightInRem = 12;
    @track disableProjectEdit = false;
    @track Core_IPS_Project_DetailsLink = Core_IPS_Project_DetailsLink;
    @track Core_IPS_Project_DetailsTooltip = Core_IPS_Project_DetailsTooltip;
    @track Core_IPS_Project_ToolTip = Core_IPS_Project_ToolTip;
    @track Core_IPS_Supported_Product_HelpText = Core_IPS_Supported_Product_HelpText;
    @track pickListvalues;
    @track value = '';
    @track projectPicklistArray =[];
    @track helpText;
    @track errorList=[];//newly added
    @wire(getRecord, { recordId: '$recordId', fields: [NAME_FIELD] })
    OppRecord({ error, data }) {
        if (data) {
            this.oppotunityName = data.fields.Name.value;
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }   
    }
    connectedCallback(){
       this.setLookupQueries();
       this.show=false;
       this.ipsProjectid = '';
       this.createProjCheckbox = this.checkBoolean;  

    }

    setLookupQueries(){
        this.lookupQueryStringProject = 'select Core_IPS_Project__r.name from Core_IPS_Account__c where Core_IPS_Project__r.Core_Status__c =\''+this.projstatus+'\' AND Core_IPS_Project__r.name LIKE:key AND Core_Account__c IN (SELECT AccountId FROM Opportunity WHERE Id = \''+this.recordId+'\') order by Core_IPS_Project__r.CreatedDate DESC';
    }
    
   
//Search Key used at lightning-input-utility 
handleSearchKey(event) {
    this.searchKey = event.detail.value;
    if(this.searchKey !== undefined && this.searchKey !== null && this.searchKey !== '' && this.searchKey.length>0) {
      this.isSearchBtnDisable = false;
    } else {
      this.isSearchBtnDisable = true;
    }
  }

  // handle search used at lightning-input-utility
  handleSearch(){
    this.spinnerOn = true;
    this.mapRecords = undefined;
    this.showSearchRecords = undefined;
    this.showSupportedProducts = false;
    this.noRecordsFound = false;
    let searchableString;
    searchableString = this.searchKey;
        let searchQueryStr = 'SELECT Id,Core_Supported_Product_Name__c,Name,Core_Product_Application__c,Core_Support_Org_Name__c FROM Core_IPS_Supported_Product__c WHERE Core_Flag_Status__c != \'EOIS\' AND Core_Flag_Status__c != \'Par Hidden\' AND Core_Supported_Product_Name__c LIKE \'%'+searchableString+'%\' LIMIT 1000';
        getQueryResult({queryString : searchQueryStr})
        .then(data => {
            this.spinnerOn = false;
            if(data) {
                let dataWrapper = [];
                for(let i=0;i<data.length;i++) {
                    let obj = {
                        'Id' : data[i].Id,
                        'supportedProduct' : data[i].Name,
                        'supportedProductName' : data[i].Core_Supported_Product_Name__c,
                        'orgNavigationUrl' : data[i].Core_Support_Org_Name__c,
                        'mapPFA' : data[i].Core_Product_Application__c,
                    };
                   dataWrapper = [...dataWrapper, obj];
                }
                this.mapRecords = dataWrapper;
                this.showSearchRecords = this.mapRecords;
                this.showSupportedProducts = true;
            }
            if(this.mapRecords.length > 0 ){
                this.noRecordsFound = false;
            }
            else{
                this.noRecordsFound = true;
            }
        })
        .catch(error => {
            console.error('Core_IPS_Create_Opportunity_PAR ::: Error in handleSearch. Error : ', JSON.stringify(error));
            this.spinnerOn = false;
        })
        
}

getSelectedRecords(event){
    this.spinnerOn = true;
    this.selectedSupportedProducts = [];
    let data = event.detail.selectedRows;
    this.preSelectedRows = [];
	if(data !== undefined && data !== null && data !== '') {
        this.selectedSupportedProducts = Object.assign([], data);
        this.getOrgAdmin(); 
        this.dataselected = true;
    }

    if(this.selectedSupportedProducts.length == 0){
        this.dataselected = false; 
        this.disableSubmit = true;
    }
}
// checkbox
enableSubmit(event) {
    if (event.target.checked)
{
    this.disableSubmit=false;
}
else
{
    this.disableSubmit=true;
}
} 

// Opportunity Team Table
getOrgAdmin() {
    this.oppTeamTable = undefined;
    this.showOppTable = false;
    this.selectedProductId = this.selectedSupportedProducts; 
    let searchQueryStr = 'SELECT Core_Product_Organization__r.Core_Organization_Description__c,Core_Product_Organization__r.Core_IPS_Support_Org_Name__c, Core_Admin__c, Core_Admin__r.Email, Core_Admin__r.Name FROM Core_IPS_Product_Organization_Admin__c WHERE Core_Admin__r.isactive = true AND Core_Product_Organization__c IN (SELECT Core_Product_Organization__c FROM Core_IPS_Supported_Product__c WHERE Name IN ('+this.selectedProductId.map(selectedProduct=>{return '\''+selectedProduct.supportedProduct+'\''}).join(',')+') )'; //
    if(this.selectedProductId.length !== 0){
    getQueryResult({queryString : searchQueryStr})
    .then(data => {
        if(data && data.length >0) {
            this.supportOrgName = data[0].Core_Product_Organization__r.Core_IPS_Support_Org_Name__c;
            let dataWrapper = [];
            for(let i=0;i<data.length;i++) {
                let obj = {
                    'Id' : data[i].Id,
                    'supportedProduct' : data[i].Core_Admin__r.Email,
                    'orgNavigationUrl' : data[i].Core_Product_Organization__r.Core_IPS_Support_Org_Name__c,
                    'mapPFA' : data[i].Core_Product_Organization__r.Core_Organization_Description__c,
                    'orgAdminName' : data[i].Core_Admin__r.Name,
                    'AdminUsrId': data[i].Core_Admin__c
                };
               dataWrapper = [...dataWrapper, obj];
            }
            this.oppTeamTable = Object.assign([],dataWrapper);
            this.showOppTable = true;
            this.spinnerOn = false;
        }
        else{
            this.showToast('Please select other Product', 'No IPS Support ORG Admins found for selected Product!', 'info'); 
        }
    })
    .catch(error => {
        console.error('Core_IPS_Create_Opportunity_PAR ::: getOrgAdmin. Error : ', JSON.stringify(error));
        this.spinnerOn = false;
    })
}else{
    this.oppTeamTable = [];
    this.spinnerOn = false;
    
}

}

//
handleChangeProject(event) {
    var recorddetails;
    this.projectid = event.detail.recordId;
    this.recorddetails = event.detail.record;
    if(this.projectid != undefined){
        this.ipsProjectid = event.detail.record.Core_IPS_Project__c;
    } else {
        this.ipsProjectid ='';
    }
}

handleChange(event) {
    if (event.target.name === 'justification') {
        this.requestJustification = event.target.value;
    }
}
handleChangeNewProj(event) {
    
    if (event.target.name === 'createNewProject') { 
        this.selectedRecord = '';
        this.createProjCheckbox = event.target.checked;
        if(this.createProjCheckbox == true){
            this.show = false;
            this.projectid = undefined;
            this.ipsProjectid = '';
        }
        else if(this.createProjCheckbox == false){
            this.show = true;
            this.selectedRecord = '';
            this.disableProjectEdit = false; 
            this.ipsProjectid = '';
        }
    }
}
// Submit 
submit(){
    var selectProducts;
    var opprtunityTable;
    this.spinnerOn = true;
    var adminList=[];
    var prodList=[];
    var scrollOptions = {
                left: 0,
                top: 0,
                behavior: 'smooth'
            }
            window.scrollTo(scrollOptions);
    if(this.requestJustification == undefined || (this.requestJustification).trim() == ''){
        this.showToast('Error', 'Please enter Request Justification', 'Error');
        
    }
    else if(this.createProjCheckbox == false && (this.ipsProjectid =='')){
        this.showToast('Error', 'Please select existing IPS project or opt for new IPS Project creation', 'Error');
    }
    else{
    this.oppTeamTable.forEach(record => {
        adminList.push({'id':record.Id,'Core_Admin__c':record.AdminUsrId});
    })
    opprtunityTable = adminList;

    this.selectedSupportedProducts.forEach(record => {
        prodList.push({'id':record.Id,'name':record.supportedProductName});
    })
    selectProducts = prodList;

    var  oppPar = {
        'supportOrgName' : this.supportOrgName,
        'requestJust': this.requestJustification,
        'ipsPrjct': this.ipsProjectid, 
        'oppId':this.recordId,
        'productList': selectProducts, 
        'orgAdminList': opprtunityTable,
        'createProjCheckbox': this.createProjCheckbox
       
    }
    submitRecord({oppParJsonRecord : JSON.stringify(oppPar)})
    .then(result => {
        if (result !== undefined || result !== null) {
        this.showToast('Opportunity Create', 'Opportunity Created Succesfully !!!', 'success');
        this.oppParId = result;
        this.navigateToViewOppParRecord();
        }
        else{
            this.showToast('Error', 'Problem in creating Opportunity PAR.', 'Error');
            console.log('Error in SubmitRecord '); 
        }
        this.spinnerOn = false;
    })
    .catch(error => {
       this.errorList= error;
       let message;
            message = error.body.message;
        console.log('Error message is:',message);
        this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message,
                    duration:' 5000',
                    variant: 'error',
            }),
        ); 
        this.spinnerOn= false;
    });
    }

}
showToast(title,message,variant){
    this.spinnerOn = false; 
    this.title = title;
    this.message = message;
    this.variant = variant; 
    this.template.querySelector('c-core_-i-p-s_-custom-toast').showCustomNotice();
}

//Cancel
cancel() {
    var oppID = this.recordId;
    if(this.isLightningMode == true){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId, 
                objectApiName: 'Opportunity',
                actionName: 'view'
            },
        });
    }
    else{
        window.open('/'+oppID,'_Self');
    } 
}
// Navigate to Opp PAR Record
navigateToViewOppParRecord() {
    if(this.isLightningMode == true){ 
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.oppParId,
            objectApiName: 'Core_IPS_Opportunity_PAR__c',
            actionName: 'view'
        },
    });
}
else{
    window.open('/'+this.oppParId,'_Self');
}
}

}