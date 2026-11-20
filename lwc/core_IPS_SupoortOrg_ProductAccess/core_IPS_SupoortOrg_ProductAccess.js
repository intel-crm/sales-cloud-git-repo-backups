import { LightningElement, track, api, wire } from 'lwc';
// import { CurrentPageReference } from 'lightning/navigation';
import searchAccounts from '@salesforce/apex/Core_IPS_MapCreationController_LWC.searchAccounts';
import searchProducts from '@salesforce/apex/Core_IPS_MapCreationController_LWC.searchProducts';
import getLineItemsmethod from '@salesforce/apex/Core_IPS_MapCreationController_LWC.getLineItemsmethod';
import createMapNew from '@salesforce/apex/Core_IPS_MapCreationController_LWC.createMapNew';
import errormessage from '@salesforce/apex/Core_IPS_MapCreationController_LWC.errormessage';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import Core_IPS_Upload_Attachment_LEX from '@salesforce/resourceUrl/Core_IPS_Upload_Attachment_LEX';
import { loadStyle } from "lightning/platformResourceLoader";
import UcdToggleSwitch from "@salesforce/label/c.Core_IPS_UCD_Toggle_Switch";




export default class Core_IPS_SupoortOrg_ProductAccess extends NavigationMixin(LightningElement) {

   //US964686-- 30/4/2024 -- Farooq -- Replaced CIM ID with Businesss_Party_Id
   columns = [
      {
         label: 'Account Name', fieldName: 'accountLink', type: 'url',
         typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
      },
      //US964686-- 30/4/2024 -- Farooq -- Replaced CIM ID with Businesss_Party_Id
      { label: 'Unified Id', fieldName: 'Core_Business_Party_Id__c', type: 'Text' },
      { label: 'Account Owner', fieldName: 'accOwnerLink', type: 'url',
         typeAttributes: {
            label: {fieldName: 'accOwnerName'}, target: '_blank' }, 
      },
      { label: 'Region', fieldName: 'Core_Geo__c', type: 'Text' },
      { label: 'Sub Region', fieldName: 'Core_Sub_Geo__c', type: 'Text' },
      { label: 'Sales Segment', fieldName: 'Core_Sales_Segment__c', type: 'Text' },
      { label: 'Industry', fieldName: 'Industry', type: 'Picklist' },
   ];
   
   
   columnsProd = [
      { label: 'Supported Product Name', fieldName: 'Name', type: 'text' },
      { label: 'Code Name', fieldName: 'Core_Code_Name__c', type: 'text' },
      { label: 'Product Name EPM ID', fieldName: 'Core_Product_Name_EPM_ID__c', type: 'text' },

   ]


   lineItemsColumns = [
      { label: 'Supported Product Name', fieldName: 'prodName', type: 'text' },
      { label: 'Account Name', fieldName: 'accName', type: 'text' },
      { label: 'Support Org Name', fieldName: 'prodOrgName', type: 'text' },
      { label: 'Approval Type', fieldName: 'FlagStatus', type: 'text' },
      {
         label: 'Support Tier', fieldName: 'SupportTier', type: 'picklist',
         typeAttributes: {
            placeholder: 'Select Tier', options: [
               { label: 'Tier1', value: 'Tier1' },
               { label: 'Tier2', value: 'Tier2' },
               { label: 'Tier3', value: 'Tier3' },
            ]
         }
      },
      {
         label: 'Subscription Expiration Date', fieldName: 'subExpDate', type: 'date', editable: true,
         typeAttributes: {
            year: "numeric",
            month: "2-digit",
            day: "2-digit"
         }
      },
   ]


   get tierOptions() {
      return [
         { label: 'Tier1', value: 'Tier1' },
         { label: 'Tier2', value: 'Tier2' },
         { label: 'Tier3', value: 'Tier3' },
      ]
   }

   accList = [];
   listofAccounts = [];
   listofProducts = [];
  productSearchedList = [];
   // @api recordId;
   @track id;
   @track isResultsAvailable = false;
   @track slicedAccList;
   @track mapNameSearchText;
   @track isSecondScreen = false;
   @track isFirstScreen = true;
   @track searchProductValue = '';
   activeSectionsPageTwo = ['A', 'B'];
   @track isProdResultsAvailable = false;
   @track isProdRowsSelected = true;
   @track isAccRowsSelected = true;
   @track isThirdScreen = false;
   mapProdToSupProd1;
   @track isLoading = false;
   @track updateDataTable = false;
   rowLimit = 10;
   rowOffSet = 0;
   rowLimit1 = 10;
   rowOffSet1 = 0;
   loadAccounts = false;
   loadProducts = false;
   enableAccountInfinite = true;
   enableProductInfinite = true;
   isSearch=null;
   @track currentPageReference;

   @wire(CurrentPageReference)
   setCurrentPageReference(currentPageReference) {
      this.currentPageReference = currentPageReference;
      console.log('current page reference');
      setTimeout(() => {
         console.log('printing after 1000 ms ');
         this.accountSearchText = '';
          this.mapNameSearchText = '';
      }, 1000);
      this.accountSearchText = '';
      this.mapNameSearchText = '';
      this.listofAccounts = [];
      this.isResultsAvailable = false;
   }

   refreshProparties(){
      
   }

   userPresent = false;
   showdata = false;
   connectedCallback() {
      
      if(this.columns.length >= 6 && UcdToggleSwitch === '0') {
         this.columns[1] = { label: 'CIM ID', fieldName: 'Core_CIM_ID__c', type: 'text',sortable: true};
   
     }
     console.log(JSON.stringify(this.columns));
      errormessage({orgID:this.recId})
        .then(result => {
            console.log('Result ',result);
            this.userPresent = result;
            this.showdata = true;
            
        })
        .catch(error => {
            console.log('error',error);
        })
      loadStyle(this, Core_IPS_Upload_Attachment_LEX)

         .then(result => {
            
         });
   }

   get recId() {
      return this.currentPageReference?.state?.c__recordId;
   }

   handleCancel(event) {
      this[NavigationMixin.Navigate]({
         type: 'standard__recordPage',
         attributes: {
            recordId: this.recId,
            objectApiName: 'Core_IPS_Product_Organization__c',
            actionName: 'view'
         }
      })
   }

   // countAccountCalls = 0;
   @track accountSearchText = '';
   handleAccountSearch(event) {
      
   
      this.accountSearchText = event.target.value;
      
      
      
      // if (event.keyCode === 13) {
      //    this.isLoading = true;
      //    this.listofAccounts = [];
      //    this.selectedAccountsRows = [];
      //    this.rowLimit = 10;
      //    this.rowOffSet = 0;
      //    this.enableAccountInfinite = true;
         
      //    if (this.accountSearchText) {
      //       return searchAccounts({ searchText: this.accountSearchText,limitSize : this.rowLimit, offset : this.rowOffSet })
      //          .then(async (response) => {
      //             // this.countAccountCalls++;
      //             // 
      //             console.log('response acount result', response);
      //             this.accList = [];
      //             this.slicedAccList = [];
      //             let accList1 = response;
      //             await accList1.forEach(record => {
      //                let accObj = { ...record };
      //                console.log('printing owner', accObj['Owner'].Name);
      //                 accObj['accOwnerName'] = accObj['Owner'].Name;
      //                 accObj['accOwnerLink'] = '/'+accObj['OwnerId'];
      //                accObj['accountLink'] = '/lightning/r/Account/' + accObj['Id'] + '/view';
      //                this.accList.push(accObj);
      //             })
      //             this.listofAccounts = [...this.listofAccounts, ...this.accList];
      //             if(this.listofAccounts.length == 0){
      //                const evt = new ShowToastEvent({
      //                   title: "ERROR!!!",
      //                   message: 'No Account records found!',
      //                   variant: 'error',
      //                });
      //                this.isLoading = false;
      //                this.dispatchEvent(evt);
      //                return null;
      //             }

      //             this.isResultsAvailable = true;
      //             if(this.accList.length < 10){
      //                this.handleInfiniteLoading();
      //             }
                  
      //            // this.updateDataTable = this.updateDataTable ? false : true;
                  
      //             this.isLoading = false;
                  
      //          })
      //          .catch(error => {
                  
      //             this.isLoading = false;
      //          })
      //    }
      // }

   }


   handleAccountSearchOnClick(event) {
      
      if(this.loadAccounts == false){
         this.listofAccounts = [];
         this.selectedAccountsRows = [];
         this.rowLimit = 10;
         this.rowOffSet = 0;
         this.enableAccountInfinite = true;
      }
      if (this.mapNameSearchText == '' || this.mapNameSearchText == null || this.mapNameSearchText == undefined) {
         
         const evt = new ShowToastEvent({
            title: "ERROR!!!",
            message: 'Please enter MAP Name',
            variant: 'error',
         });
         this.dispatchEvent(evt);

         return;
      }
      console.log('event MM');
      if(this.isSearch!=false){
         console.log('Inside EventLabel');
         if(event.target.label == 'Search'){
            this.isLoading = true;
         }
      }   
      this.isSearch = true;
      if (this.accountSearchText != null || this.accountSearchText != undefined || this.accountSearchText == '') {
         return searchAccounts({ searchText: this.accountSearchText,limitSize : this.rowLimit, offset : this.rowOffSet })
            .then(response => {
               console.log(JSON.stringify(response));
               let accList1 = response;
               this.accList = [];
               this.slicedAccList = [];
               accList1.forEach(record => {
                  let accObj = { ...record };
                  accObj['accOwnerName'] = accObj['Owner'].Name;
                  accObj['accOwnerLink'] = '/'+accObj['OwnerId'];
                  accObj['accountLink'] = '/lightning/r/Account/' + accObj['Id'] + '/view';
                  this.accList.push(accObj);
               })
               this.listofAccounts = [...this.listofAccounts, ...this.accList];
               this.isLoading = false;
               if(this.listofAccounts.length == 0){
                  const evt = new ShowToastEvent({
                     title: "ERROR!!!",
                     message: 'No Account records found!',
                     variant: 'error',
                  });
                  this.isLoading = false;
                  this.dispatchEvent(evt);
                  return null;
               }
               
               this.isResultsAvailable = true;
               if(this.accList.length < 10){
                  this.handleInfiniteLoading();
               }
             
            })
            .catch(error => {
               
               this.isLoading = false;
            })
      }

   }
   targetDatatable;
   handleLoadMore(event) {
         this.loadAccounts = true;
          const { target } = event;
          target.isLoading = true;
          this.targetDatatable = event.target;
          this.rowOffSet = this.rowOffSet + this.rowLimit;
          console.log('eventLM----',);
          this.isSearch = false;
          this.handleAccountSearchOnClick()
         .then(()=> {
             this.targetDatatable.isLoading = false;
             this.loadAccounts = false;
          }); 
      
  }
   handleInfiniteLoading(){
        
        this.enableAccountInfinite = false;
        this.enableProductInfinite = false;
   }
   
   handleMapChange(event) {
      
      
      this.mapNameSearchText = event.target.value;
   }

   handleGoProducts() {
      this.isFirstScreen = false;
      this.isSecondScreen = true;
   }


   handleBackToAccounts(event) {
      this.searchProductValue = '';
      this.isProdResultsAvailable = false;
      this.listofProducts = [];
      this.selectedProductRows = [];
      this.selectedAccountsRows = [];
      this.isAccRowsSelected = true;
      this.isProdRowsSelected = true;
      this.rowLimit1 = 10;
      this.rowOffSet1 = 0;
      this.isSecondScreen = false;
      this.isFirstScreen = true;
   }

   @track selectedAccountsRows;
   getSelectedRow(event) {
      this.selectedAccountsRows = event.detail.selectedRows;
      
      if (this.selectedAccountsRows.length >= 1) {
         this.isAccRowsSelected = false
      }
      else {
         this.isAccRowsSelected = true;
      }

   }

   @track selectedProductRows;
   getSelectedProductRows(event) {
      this.selectedProductRows = event.detail.selectedRows;
      
      
      if (this.selectedProductRows.length >= 1) {
         
         this.isProdRowsSelected = false;
      }
      else {
         
         this.isProdRowsSelected = true;
      }
   }

   handleProductValueSearch(event) {
    
      if(this.loadProducts == false){
         this.listofProducts = [];
         this.selectedProductRows = [];
         this.rowLimit1 = 10;
         this.rowOffSet1 = 0;
         this.enableProductInfinite = true;
      }
      
      return searchProducts({ id: this.recId, searchTextProd: this.searchProductValue,limitSize : this.rowLimit1, offset : this.rowOffSet1 })
         .then(response => {
            this.productSearchedList = [];
            
            this.productSearchedList = response.searchProducts;
            this.mapProdToSupProd1 = response.mapProdToSupProd1;
            
            
            this.listofProducts = [...this.listofProducts, ...this.productSearchedList];
            
           
            if(this.productSearchedList.length < 10){
               this.handleInfiniteLoading();
            }
            if(this.listofProducts.length == 0){
               const evt = new ShowToastEvent({
                  title: "ERROR!!!",
                  message: 'No Product records found!',
                  variant: 'error',
               });
               this.dispatchEvent(evt);
               this.isLoading = false;
               return null;
            }
            this.isProdResultsAvailable = true;

         })
         .catch(error => {
            
            this.isLoading = false;
         })

   }
   handleLoadMoreProducts(event) {
         this.loadProducts = true;
          const { target } = event;
          target.isLoading = true;
          this.targetDatatable = event.target;
          this.rowOffSet1 = this.rowOffSet1 + this.rowLimit1;
          
          this.handleProductValueSearch()
         .then(()=> {
             this.targetDatatable.isLoading = false;
             this.loadProducts = false;
          }); 
      
  }

   @track slicedProductList;
   
   handleSearchProductChange(event) {
      this.searchProductValue = event.target.value;

      
      if (event.keyCode === 13) {
         this.isLoading = true;
        
         this.listofProducts = [];
         this.selectedProductRows = [];
         this.rowLimit1 = 10;
         this.rowOffSet1 = 0;
         this.enableProductInfinite = true;
         return searchProducts({ id: this.recId, searchTextProd: this.searchProductValue,limitSize : this.rowLimit1, offset : this.rowOffSet1 })
            .then(response => {               
               this.productSearchedList = [];
               this.productSearchedList = response.searchProducts;
               this.mapProdToSupProd1 = response.mapProdToSupProd1;
               this.listofProducts = [...this.listofProducts, ...this.productSearchedList];
               
               
              
               if(this.productSearchedList.length < 10){
                  this.handleInfiniteLoading();
               }
               this.isLoading = false;
               if(this.listofProducts.length == 0){
                  const evt = new ShowToastEvent({
                     title: "ERROR!!!",
                     message: 'No Product records found!',
                     variant: 'error',
                  });
                  this.dispatchEvent(evt);
                  return null;
               }
               this.isProdResultsAvailable = true;
               
            })
            .catch(error => {
               
               this.isLoading = false;
            })

      }

   }


   handleReviewSelections(event) {
      this.isSecondScreen = false;
      this.isThirdScreen = true;
      this.lineItems();
      this.isResultLineItems = true;
   }

   listOfLineItems = [];
   listOfLineItems1 = [];
   lineItems() {
      

      var modData = [];
      getLineItemsmethod({ accountsselected: this.selectedAccountsRows, prodselected: this.selectedProductRows, prodOrgRecId: this.recId, mapProdToSupProd1: this.mapProdToSupProd1 })
         .then(response => {
            
            this.listOfLineItems1 = response;
            let i = 1;
            this.listOfLineItems1.forEach(res => {
               let data = { ...res };
               
               
               

               data['accName'] = data.acc.Name;
               data['prodName'] = data.prod.Name;
               data['subExpDate'] = null;

               data['keyId'] = i++;
               data['isHide'] = data?.enabledForSubscriptions ? null : 'slds-hide'

               
               
               
               try {
                  modData.push(data);
               }
               catch (e) {
                  
               }
            })
            
            
            this.listOfLineItems = modData;
            
            if (this.listOfLineItems.length <= 5) {
               
               this.slicedLineItems = this.listOfLineItems;
            }
            else {
               this.slicedLineItems = this.listOfLineItems.slice(0, 5);
            }

         })
         .catch(error => {
            
         });

   }

   @track slicedLineItems;
   handlePaginatorChangeofLineItem(event) {
      this.slicedLineItems = event.detail;
      
   }

   @track isResultLineItems = false;
   handleSubmitProductAccess(event) {
      //pending
      this.isLoading = true;
      this.createRecordofMap();

   }

   handleBackToAccountsformScreenThree(event) {
      this.searchProductValue = '';
      this.isProdResultsAvailable = false;
      this.listofProducts = [];
      this.selectedProductRows = [];
      this.selectedAccountsRows = [];
      this.listOfLineItems = [];
      this.isAccRowsSelected = true;
      this.isProdRowsSelected = true;
      this.rowLimit1 = 10;
      this.rowOffSet1 = 0;
      this.isThirdScreen = false;
      this.isFirstScreen = true;
   }

   createdMapRecord;
   createRecordofMap() {
      
      createMapNew({ lineItemsList1: this.listOfLineItems1, mapProdToSupProd2: this.mapProdToSupProd1, searchMapNameText: this.mapNameSearchText, prodOrgRecId: this.recId })
         .then(response => {
            
            
            
            this.createdMapRecord = response;
            this.isLoading = false;
            this.navigateToCreateMapPage();
         })
         .catch(error => {
            
            this.isLoading = false;
         })


   }

   addSubDateAndSelectedTier() {

   }

   @track selectedTier;
   @track selectedSubExpDetail;

   handleSubExpDateChange(event) {
      
      
      this.selectedSubExpDetail = event.target.value;




   }

   handleSelectTierChange(event) {
      
      
      this.selectedTier = event.detail.value;
      let count = 0;
      this.listOfLineItems.forEach(res => {
         

         if (event.target.name == res.keyId) {
            
            res['selectedTier'] = this.selectedTier;

         }
         

         if (count == 0) {
            this.listOfLineItems = [];
            this.listOfLineItems = { ...res };
            count++;
         }
         else {
            this.listOfLineItems = [...this.listOfLineItems, { ...res }];
         }
      })
      
      

   }

   navigateToCreateMapPage() {
      this[NavigationMixin.Navigate]({
         type: 'standard__recordPage',
         attributes: {
            recordId: this.createdMapRecord.Id,
            objectApiName: 'Core_IPS_MAP_PAR__c',
            actionName: 'view'
         }
      });
   }

}