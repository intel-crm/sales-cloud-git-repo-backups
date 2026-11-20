import { LightningElement, track, wire, api} from 'lwc';
import Name from '@salesforce/schema/Core_Solution_Areas__c.Name';
import Core_Solution_Type__c from '@salesforce/schema/Core_Solution_Areas__c.Core_Solution_Type__c';
import Core_Concatenated_Solution_Partners__c from '@salesforce/schema/Core_Solution_Areas__c.Core_Concatenated_Solution_Partners__c';
import Core_Solution_Description__c from '@salesforce/schema/Core_Solution_Areas__c.Core_Solution_Description__c';
import Core_Version__c from '@salesforce/schema/Core_Solution_Areas__c.Core_Version__c';
import Core_End_Customer_Solution__c from '@salesforce/schema/Core_Solution_Areas__c.Core_End_Customer_Solution__c';
import Core_Solution_owner_email__c from '@salesforce/schema/Core_Solution_Areas__c.Core_Solution_owner_email__c';
import Core_Content_Link__c from '@salesforce/schema/Core_Solution_Areas__c.Core_Content_Link__c';
import Core_Application_Workload__c from '@salesforce/schema/Core_Solution_Areas__c.Core_Application_Workload__c';
import Core_Industry_Use_Case__c from '@salesforce/schema/Core_Solution_Areas__c.Core_Industry_Use_Case__c';
import Core_Technology_Enabled__c from '@salesforce/schema/Core_Solution_Areas__c.Core_Technology_Enabled__c';
import Core_Industry__c from '@salesforce/schema/Core_Solution_Areas__c.Core_Industry__c';
import Core_Region_of_availability__c from '@salesforce/schema/Core_Solution_Areas__c.Core_Region_of_availability__c';
import Core_Deal_Visible__c from '@salesforce/schema/Core_Solution_Areas__c.Core_Deal_Visible__c';
import Core_Design_Visible__c from '@salesforce/schema/Core_Solution_Areas__c.Core_Design_Visible__c';
import Core_Status__c from '@salesforce/schema/Core_Solution_Areas__c.Core_Status__c';
import Core_Most_Recent_Status_Change_Date__c from '@salesforce/schema/Core_Solution_Areas__c.Core_Most_Recent_Status_Change_Date__c';
import CreatedById from '@salesforce/schema/Core_Solution_Areas__c.CreatedById';
import CreatedDate from '@salesforce/schema/Core_Solution_Areas__c.CreatedDate';
import LastModifiedById from '@salesforce/schema/Core_Solution_Areas__c.LastModifiedById';
import LastModifiedDate from '@salesforce/schema/Core_Solution_Areas__c.LastModifiedDate';
import searchSolutionStorage from '@salesforce/apex/Core_AddSolutionArea.searchSolutionStorage';
import createOppSolution from '@salesforce/apex/Core_AddSolutionArea.createOppSolution';

import showOpptySolution from '@salesforce/apex/Core_AddSolutionArea.showOpptySolution'; //TWC3123-5794
import hideTabMessage from '@salesforce/label/c.Core_HideSolutionsTab'; //TWC3123-5794

import { getRecordNotifyChange } from 'lightning/uiRecordApi';
//import sendEmailController from '@salesforce/apex/Core_AddSolutionArea.sendEmailController';  AAQ solution
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import NewSolution from '@salesforce/label/c.Core_AAQSolutions_NewSolution';  //AAQ solution

import Objects_Type_AWL from "@salesforce/apex/Core_AddSolutionArea.Get_Types_Application_Workload"; 
import Objects_Type_TE from "@salesforce/apex/Core_AddSolutionArea.Get_Types_TechnologyEnabled"; 
import Objects_Type_IUC from "@salesforce/apex/Core_AddSolutionArea.Get_Types_Industry_UseCase"; 
import searchHelpText from "@salesforce/label/c.Core_SolSearchHelpText";
//import Objects_Type_SP from "@salesforce/apex/Core_AddSolutionArea.Get_Types_Concatenated_Solution_Partners"; 

const DELAY = 50;

const actions = [
  { label: 'Show details', name: 'show_details' }
];

const columns = [
  {type: "button", label: 'View', initialWidth: 30, typeAttributes: {
    label: '',
    name: 'View',
    value: 'view',
    iconPosition: 'left',
    iconName:'utility:preview',
    variant:'base'
}},
  { label: 'Solution', fieldName: 'Id', initialWidth: 180, type: 'url', typeAttributes: { label:{fieldName: 'Name'}, target: '_blank'} },
  { label: 'Application/Workload',initialWidth: 180, fieldName: 'Core_Application_Workload__c'},
  { label: 'Industry Use Case(s)',initialWidth: 180, fieldName: 'Core_Industry_Use_Case__c'},
  { label: 'Technology Enabled', initialWidth: 180,fieldName: 'Core_Technology_Enabled__c'},
  { label: 'Solution Description',initialWidth: 180, fieldName: 'Core_Solution_Description__c'},
  { label: 'Solution Type', initialWidth: 180,fieldName: 'Core_Solution_Type__c'},
 	{ label: 'Solution Partners',initialWidth: 180, fieldName: 'Core_Concatenated_Solution_Partners__c'},
  { label: 'End Customer Solution', initialWidth: 180,fieldName: 'Core_End_Customer_Solution__c'},
  { label: 'Industry', initialWidth: 180,fieldName: 'Core_Industry__c'},
  { label: 'Solution owner email', initialWidth: 180,fieldName: 'Core_Solution_owner_email__c'},
  { label: 'Content Link',initialWidth: 180, fieldName: 'Core_Content_Link__c'},
  { label: 'Region of availability',initialWidth: 180, fieldName: 'Core_Region_of_availability__c'},
	{ label: 'Version', initialWidth: 180,fieldName: 'Core_Version__c'}
];


export default class Core_AddSolutionArea extends LightningElement {

  label = {
    searchHelpText,
    hideTabMessage //TWC3123-5794
  };
@track isRecordOpen = false;
@track TypeOptions_AWL;
@track TypeOptions_TE;
@track TypeOptions_IUC;
//@track TypeOptions_SP;
partnersol = [Name,Core_Solution_Type__c,Core_Concatenated_Solution_Partners__c,Core_Solution_Description__c,Core_Version__c,Core_End_Customer_Solution__c,Core_Solution_owner_email__c,Core_Content_Link__c,Core_Application_Workload__c,Core_Industry_Use_Case__c,Core_Technology_Enabled__c,Core_Industry__c,Core_Region_of_availability__c,Core_Deal_Visible__c,Core_Design_Visible__c,Core_Status__c,Core_Most_Recent_Status_Change_Date__c,CreatedById,CreatedDate,LastModifiedById,LastModifiedDate];
Sa_AWL_Search = '';
Sa_TE_Search = '';
Sa_IUC_Search = '';
Sa_SP_Search = '';

AWL_Search = '';
TE_Search = '';
IUC_Search = '';
SP_Search = '';
Txt_Search = '';
columns = columns;
  
  SaAreaName = '';
  SaAreaOwnerEmail = '';
  SaAreaDescription = '';
  SaAreaType = '';
  SaAreaTitle = '';
 availablesolutions;
  disableBool = true;
@track page = 1; 
@track totalPage = 0;
isPageChanged = false;
@track allSelectedRows = [];
@track data;
  @track startingRecord = 1;
  @track endingRecord = 0; 
  @track pageSize = 100; 
  @track totalRecountCount = 0;
  initialLoad = true;
  isModalOpen=false;
  emailSent=false;
  msgBody=false;
  @track body='';
  disableBtn = true;
  mapoppNameVsOpp = new Map();

@api isPCC=false; //TWC3123-5794

  @track isLoading = false;
@track SaList= [];
  selectedSolAreaIds =[];
@api recordId;
@track recId;
	
		@wire (searchSolutionStorage, {
      oppoIds: '$recordId',
      SaStrType: '$SaAreaType',
      SaStrEmail: '$SaAreaOwnerEmail',
      SaStrIUC: '$Sa_IUC_Search',        
      SaStrAWL: '$Sa_AWL_Search',
      SaStrTE: '$Sa_TE_Search',
      SaStrSP: '$Sa_SP_Search'
    }) SolutionList({error, data}){   
    if(data){
        //this.SaList=data;  
         let totalSol = [];
            data.forEach( ( data ) => {
                let solRec = Object.assign( {}, data );  
                solRec.Id = '/' + solRec.Id;
                totalSol.push( solRec );
                
            });
           
        this.availablesolutions = totalSol; 
        this.processRecords(data); 
    }
    else if(error){
        this.er = error;
    }      
}

//TWC3123-5794
connectedCallback(){ 
    showOpptySolution({ recordId :  this.recordId})
        .then(result => { 
            if (result!= null){
                this.isPCC = result; 
            }  
        })
};

callRowAction(event) { 
	this.recId = event.detail.row.Id.replace('/','');
  this.isRecordOpen = true;
}


closeModalPopUp() {
  this.isRecordOpen = false;
}

/*@wire(Objects_Type_SP, {oppoIds:'$recordId'})
WiredObjects_Type_SP({ error, data }) {

    if (data) {
        try {

            let options = [];
            for (var cnt in data) { 
                let words = data[cnt].split('|');
             
                 options.push({ label: words[0], value: words[1]  });
            }          
            this.TypeOptions_SP = options;
             
        } catch (error) {
            console.error('check error here Objects_Type_SP', error);
        }
    } else if (error) {
        console.error('check error here Objects_Type_SP', error);
    }

}*/

  @wire(Objects_Type_AWL, {})
    WiredObjects_Type_AWL({ error, data }) {
 
        if (data) {
            try {

                let options = [];
                for (var cnt in data) { 
                    let words = data[cnt].split('|');
                 
                     options.push({ label: words[0], value: words[1]  });
                }          
                this.TypeOptions_AWL = options;
                 
            } catch (error) {
                console.error('check error here Objects_Type_AWL', error);
            }
        } else if (error) {
            console.error('check error here Objects_Type_AWL', error);
        }
    
    }
  @wire(Objects_Type_TE, {})
    WiredObjects_Type_TE({ error, data }) {
 
        if (data) {
            try {

                let options = [];
                for (var cnt in data) { 
                    let words = data[cnt].split('|');
                 
                     options.push({ label: words[0], value: words[1]  });
                }          
                this.TypeOptions_TE = options;
                 
            } catch (error) {
                console.error('check error here Objects_Type_TE', error);
            }
        } else if (error) {
            console.error('check error here Objects_Type_TE', error);
        }
    
    }

     @wire(Objects_Type_IUC, {})
    WiredObjects_Type_IUC({ error, data }) {
 
        if (data) {
            try {

                let options = [];
                for (var cnt in data) { 
                    let words = data[cnt].split('|');
                
                    options.push({ label: words[0], value: words[1]  });
                }          
                this.TypeOptions_IUC = options;
                 
            } catch (error) {
                console.error('check error here Objects_Type_IUC', error);
            }
        } else if (error) {
            console.error('check error here Objects_Type_IUC', error);
        }
    
    }

processRecords(data){
      this.items = data;
          this.totalRecountCount = data.length; 
          this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
          
          this.data = this.items.slice(0,this.pageSize); 
          this.endingRecord = this.pageSize;
          this.columns = columns;
  }

  processSelectedRows(selectedOpps){
      var newMap = new Map();
      for(var i=0; i<selectedOpps.length;i++){
          if(!this.allSelectedRows.includes(selectedOpps[i])){
              this.allSelectedRows.push(selectedOpps[i]);
          }
          this.mapoppNameVsOpp.set(selectedOpps[i].Name, selectedOpps[i]);
          newMap.set(selectedOpps[i].Name, selectedOpps[i]);
      }
      for(let [key,value] of this.mapoppNameVsOpp.entries()){
          if(newMap.size<=0 || (!newMap.has(key) && this.initialLoad)){
              const index = this.allSelectedRows.indexOf(value);
              if (index > -1) {
                  this.allSelectedRows.splice(index, 1); 
              }
          }
      }
  }

handleSelected( event ) {
        
        const selectedRows = event.detail.selectedRows;

        if ( selectedRows.length > 0 ) {
            
            this.disableBool = false;

        } else {
            
            this.disableBool = true;
            
        }

    }
  getSelectedSolStorage() {
    this.isLoading = true;
    this.selectedSolAreaIds = [];  
    var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
    if(selectedRecords.length > 0){
        
        selectedRecords.forEach(currentItem => {
            var str = currentItem.Id;
            str = str.replace('/','');
            this.selectedSolAreaIds.push(str);
        });
      
      createOppSolution({OppId:this.recordId, solAreaIds:this.selectedSolAreaIds})
      .then(res=>{                
                      const event = new ShowToastEvent({
                      
                      message: res,
                      variant: 'success',
                      mode: 'dismissable'
                        
  });this.isLoading = false;
 eval("$A.get('e.force:refreshView').fire();");
  this.dispatchEvent(event);
                  }).catch(error=>
                  {
                   this.showToast('Solutions could not be added because of the opportunity validation:', error.body.message, 'error');
                   this.isLoading = false;
                  return;
                  
                  })


} // window.location.reload(); 

      
    }
  
 showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    } 


searchSolutionAreaText(event){
   
    const searchString = event.target.value;
    this.Txt_Search =    searchString;

    this.delayTimeout = setTimeout(() => {
		
//	Utility = new utilityModule();

    this.Sa_AWL_Search = this.AWL_Search;
    this.Sa_TE_Search = this.TE_Search;
    this.Sa_IUC_Search = this.IUC_Search;
    this.Sa_SP_Search = this.SP_Search;
    this.SaAreaType = this.Txt_Search;

    }, DELAY);
}

searchSolutionAreaAction(event){

//	Utility = new utilityModule();
    window.clearTimeout(this.delayTimeout);
    this.delayTimeout = setTimeout(() => {

    this.Sa_AWL_Search = this.AWL_Search;
    this.Sa_TE_Search = this.TE_Search;
    this.Sa_IUC_Search = this.IUC_Search;
    this.Sa_SP_Search = this.SP_Search;
    this.SaAreaType = this.Txt_Search;

    }, DELAY);
}

searchSolutionAreaAction_AWL(event){
 
		
		 this.template.querySelectorAll('lightning-combobox').forEach(each => {
      	if(each.name=='Search_Appln_wkld') 
				 {
						 this.AWL_Search = each.value;
				 }
				 if(each.name=='Search_Indus_usecase') 
				 {
						 this.IUC_Search = each.value;
				 }
				 if(each.name=='Search_Tech_enabled') 
				 {
						 this.TE_Search = each.value;
				 }	
         if(each.name=='Search_Sol_Partner') 
				 {
						 this.SP_Search = each.value;
				 }	
				
    });
 	this.template.querySelectorAll('lightning-input').forEach(each => {
       
					 if(each.name=='Search_Txt') 
				 {
						 this.Txt_Search = each.value;
				 }	
    });


   window.clearTimeout(this.delayTimeout);
    this.delayTimeout = setTimeout(() => {

//	Utility = new utilityModule();
    this.Sa_AWL_Search = this.AWL_Search;
    this.Sa_TE_Search = this.TE_Search;
    this.Sa_IUC_Search = this.IUC_Search;
    this.Sa_SP_Search = this.SP_Search;
    this.SaAreaType = this.Txt_Search;
			
    }, DELAY);
    
}

searchSolutionAreaAction_IUC(event){
 
 this.template.querySelectorAll('lightning-combobox').forEach(each => {
      	if(each.name=='Search_Appln_wkld') 
				 {
						 this.AWL_Search = each.value;
				 }
				 if(each.name=='Search_Indus_usecase') 
				 {
						 this.IUC_Search = each.value;
				 }
				 if(each.name=='Search_Tech_enabled') 
				 {
						 this.TE_Search = each.value;
				 }
         if(each.name=='Search_Sol_Partner') 
				 {
						 this.SP_Search = each.value;
				 }			
				
    });
		  this.template.querySelectorAll('lightning-input').forEach(each => {
       
					 if(each.name=='Search_Txt') 
				 {
						 this.Txt_Search = each.value;
				 }	
    });


  window.clearTimeout(this.delayTimeout);
    this.delayTimeout = setTimeout(() => {
	
//	Utility = new utilityModule();
    this.Sa_AWL_Search = this.AWL_Search;
    this.Sa_TE_Search = this.TE_Search;
    this.Sa_IUC_Search = this.IUC_Search;
    this.Sa_SP_Search = this.SP_Search;
    this.SaAreaType = this.Txt_Search;

    }, DELAY);
}
		
searchSolutionAreaAction_SP(event){

  const spsearchString = event.target.value;
  this.SP_Search =    spsearchString; 

  this.delayTimeout = setTimeout(() => {
//Utility = new utilityModule();
  this.Sa_AWL_Search = this.AWL_Search;
  this.Sa_TE_Search = this.TE_Search;
  this.Sa_IUC_Search = this.IUC_Search;
  this.Sa_SP_Search = this.SP_Search;
  this.SaAreaType = this.Txt_Search;

  }, DELAY);
  /*this.template.querySelectorAll('lightning-combobox').forEach(each => {
         if(each.name=='Search_Appln_wkld') 
          {
              this.AWL_Search = each.value;
          }
          if(each.name=='Search_Indus_usecase') 
          {
              this.IUC_Search = each.value;
          }
          if(each.name=='Search_Tech_enabled') 
          {
              this.TE_Search = each.value;
          }
          if(each.name=='Search_Sol_Partner') 
          {
              this.SP_Search = each.value;
          }			
         
     });
       this.template.querySelectorAll('lightning-input').forEach(each => {
        
            if(each.name=='Search_Txt') 
          {
              this.Txt_Search = each.value;
          }	
     });
 
 
   window.clearTimeout(this.delayTimeout);
     this.delayTimeout = setTimeout(() => {
 
     this.Sa_AWL_Search = this.AWL_Search;
     this.Sa_TE_Search = this.TE_Search;
     this.Sa_IUC_Search = this.IUC_Search;
     this.Sa_SP_Search = this.SP_Search;
     this.SaAreaType = this.Txt_Search;
     }, DELAY);*/
 }

searchSolutionAreaAction_TE(event){    
   
 this.template.querySelectorAll('lightning-combobox').forEach(each => {
      	if(each.name=='Search_Appln_wkld') 
				 {
						 this.AWL_Search = each.value;
				 }
				 if(each.name=='Search_Indus_usecase') 
				 {
						 this.IUC_Search = each.value;
				 }
				 if(each.name=='Search_Tech_enabled') 
				 {
						 this.TE_Search = each.value;
				 }	
         if(each.name=='Search_Sol_Partner') 
				 {
						 this.SP_Search = each.value;
				 }		
				
    });
		this.template.querySelectorAll('lightning-input').forEach(each => {
     
					 if(each.name=='Search_Txt') 
				 {
						 this.Txt_Search = each.value;
				 }	
    });
    
  window.clearTimeout(this.delayTimeout);
    this.delayTimeout = setTimeout(() => {
//	Utility = new utilityModule();
    this.Sa_AWL_Search = this.AWL_Search;
    this.Sa_TE_Search = this.TE_Search;
    this.Sa_IUC_Search = this.IUC_Search;
    this.Sa_SP_Search = this.SP_Search;
    this.SaAreaType = this.Txt_Search;

    }, DELAY);
}


handleClearEntry() {
    this.template.querySelectorAll('lightning-input').forEach(each => {
        each.value = '';
    });
    this.template.querySelectorAll('lightning-combobox').forEach(each => {
        each.value = null;

    });

    this.Sa_AWL_Search = '';
    this.Sa_TE_Search = '';
    this.Sa_IUC_Search = '';
    this.Sa_SP_Search = '';
    this.SaAreaType = '';
    this.AWL_Search = '';
    this.TE_Search = '';
    this.SP_Search = '';
    this.IUC_Search = '';
    this.Txt_Search = '';
}



//clicking on previous button this method will be called
  previousHandler() {
      this.isPageChanged = true;
      if (this.page > 1) {
          this.page = this.page - 1; //decrease page by 1
          this.displayRecordPerPage(this.page);
      }
        var selectedIds = [];
        for(var i=0; i<this.allSelectedRows.length;i++){
          selectedIds.push(this.allSelectedRows[i].Id);
        }
      this.template.querySelector(
          '[data-id="table"]'
        ).selectedRows = selectedIds;
  }

  //clicking on next button this method will be called
  nextHandler() {
      this.isPageChanged = true;
      if((this.page<this.totalPage) && this.page !== this.totalPage){
          this.page = this.page + 1; //increase page by 1
          this.displayRecordPerPage(this.page);            
      }
        var selectedIds = [];
        for(var i=0; i<this.allSelectedRows.length;i++){
          selectedIds.push(this.allSelectedRows[i].Id);
        }
      this.template.querySelector(
          '[data-id="table"]'
        ).selectedRows = selectedIds;
  }

  //this method displays records page by page
  displayRecordPerPage(page){

      this.startingRecord = ((page -1) * this.pageSize) ;
      this.endingRecord = (this.pageSize * page);

      this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                          ? this.totalRecountCount : this.endingRecord; 

      this.data = this.items.slice(this.startingRecord, this.endingRecord);
      this.startingRecord = this.startingRecord + 1;
  }
  
  openModal(){
    this.isModalOpen = true;
    //this.body =NewSolution;  //AAQ solution
    this.disableBtn=true;
  }

  closeModal(){
    this.isModalOpen = false;
  }
  
  handleBodyChange(event) {
    this.body = event.target.value;
    if(!(this.body!== '' && this.body!== null && this.body.trim().length > 0 && this.body!== undefined)){
      this.disableBtn=true;
    }else{
      this.disableBtn=false;
    }
    
  }

  handleEmailRequest(event){
  if(!(this.body!== '' && this.body!== null && this.body.trim().length > 0 && this.body!== undefined)){
    this.disableBtn=true;
  }else{
        sendEmailController({ emailDetailStr: this.body})
                  .then(() => {
                    this.isModalOpen = false;
                        const evt = new ShowToastEvent({
                            title: 'Email Sent!',
                            message: 'You have successfully requested for New Solution.',
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                  })
                  .catch((error) => {
                      console.error("Error in sendEmailController:", error);
                      const evt = new ShowToastEvent({
                        title: 'Error Occured!',
                        message: 'Unable to Proceed with the request due to some error.Please contact your Salesforce Administrator.',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                  });
              }
      }
}