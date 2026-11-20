import { LightningElement, track, wire, api } from 'lwc';   

import getRecord from "@salesforce/apex/Core_CloneSolutionArea.getRecord"; 
import CreateRecord from "@salesforce/apex/Core_CloneSolutionArea.CreateRecord"; 

import Objects_Type_AWL from "@salesforce/apex/Core_CloneSolutionArea.Get_Types_Application_Workload"; 
import Objects_Type_TE from "@salesforce/apex/Core_CloneSolutionArea.Get_Types_TechnologyEnabled"; 
import Objects_Type_IUC from "@salesforce/apex/Core_CloneSolutionArea.Get_Types_Industry_UseCase"; 

import TypeOptions_Industry from "@salesforce/apex/Core_CloneSolutionArea.Get_Types_Industry"; 
import TypeOptions_RA from "@salesforce/apex/Core_CloneSolutionArea.Get_Types_Region_Availability"; 
import TypeOptions_Status from "@salesforce/apex/Core_CloneSolutionArea.Get_Types_Status";
import TypeOptions_SolutionType from "@salesforce/apex/Core_CloneSolutionArea.Get_Types_SolutionType"; 

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
 
export default class Solution_Clone extends NavigationMixin(LightningElement) {

  
@api recordId;
@track l_All_Types;
@track TypeOptions;
@track TypeOptions_AWL;
@track TypeOptions_TE;
@track TypeOptions_IUC;

@track TypeOptions_Industry;
@track TypeOptions_RA;
@track TypeOptions_Status;
@track TypeOptions_SolutionType;

@api objectApiName;
@track Core_Solution_Areas__c;
//@track Solution_Areas= {};
@track SolutionData= {};
@track Name;
@track Core_Solution_Description__c;
@track Core_Version__c;
@track Core_Solution_owner_email__c;
@track test;
@track R_Id;
@track allSV_Application_Workload = [];
@track allSV_Industry = [];
@track allSV_IndustryUseCase = [];
@track allSV_Technology_Enabled = [];
@track allSV_Region_Availability = [];
Solution_Areas= {};
str_comma=',';
str_semi=';';
Cloned_Soln_ID='';
    disableButton= false;
    showBool = true;
    Clone_Partners = false;
    showHideTab= false;
    showErrors= false;
    showWarnings = false;
    ValidationFlag = true;
     SV_Industry='';
     SV_Status='';
     SV_Solution_Type='';
     SV_Name='';
     SV_Industry_Use_Case='';
     SV_End_Customer_Solution='';
     SV_Technology_Enabled='';
     SV_Region_of_availability = '';
     SV_Version='';
     SV_Application_Workload='';
     SV_DealVisible='';
     SV_DesignVisible='';
     SV_Description='';
     SV_Solution_owner_email='';
     SV_Content_Link='';
     Error_Message='';
     Validation_Message='';
@wire(getRecord, { Solution_AreaId: '$recordId' }) 
    wiredRecord({ error, data }) {
        
        if (error) {
            let message = 'Unknown error';
          
        } else if (data) {

          try{

            if (data!= null)   
            {    
             
            this.SolutionData= data[0];
           
            this.SV_Application_Workload = this.SolutionData.Core_Application_Workload__c;
            this.SV_Industry =  this.SolutionData.Core_Industry__c;            
            this.SV_Industry_Use_Case   =  this.SolutionData.Core_Industry_Use_Case__c;
            this.SV_Technology_Enabled =  this.SolutionData.Core_Technology_Enabled__c;
            this.SV_Region_of_availability =  this.SolutionData.Core_Region_of_availability__c; 
            this.SV_Status = this.SolutionData.Core_Status__c;
            this.SV_Solution_Type = this.SolutionData.Core_Solution_Type__c;   
            this.SV_Name = this.SolutionData.Name;              
            this.SV_End_Customer_Solution = this.SolutionData.Core_End_Customer_Solution__c;
            this.SV_Version = this.SolutionData.Core_Version__c;           
            this.SV_DealVisible = this.SolutionData.Core_Deal_Visible__c;
            this.SV_DesignVisible = this.SolutionData.Core_Design_Visible__c;
            this.SV_Description = this.SolutionData.Core_Solution_Description__c;
            this.SV_Solution_owner_email = this.SolutionData.Core_Solution_owner_email__c;
            this.SV_Content_Link = this.SolutionData.Core_Content_Link__c;
            
            
            if(this.SolutionData.Core_Application_Workload__c!= null )
            {
                this.allSV_Application_Workload=  this.SolutionData.Core_Application_Workload__c.split(';');
                
            }
           
              if(this.SolutionData.Core_Industry__c!= null )
            {
                this.allSV_Industry=  this.SolutionData.Core_Industry__c.split(';');
               
            }
          
              if(this.SolutionData.Core_Industry_Use_Case__c!= null )
            {
                  this.allSV_IndustryUseCase=  this.SolutionData.Core_Industry_Use_Case__c.split(';');
                  
            }
           
              if(this.SolutionData.Core_Technology_Enabled__c!= null )
            {
                this.allSV_Technology_Enabled=  this.SolutionData.Core_Technology_Enabled__c.split(';');
                
            }
        
              if(this.SolutionData.Core_Region_of_availability__c!= null )
            {
               this.allSV_Region_Availability=  this.SolutionData.Core_Region_of_availability__c.split(';');

              
            }       
           

            }
			
			}
			catch (error) {
           
                console.error('check error here getRecord', error);
            }
            }
            
            
        }
   
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


    @wire(TypeOptions_Industry, {})
    WiredObjects_Type_Industry({ error, data }) {
 
        if (data) {
            try {

                let options = [];
                for (var cnt in data) {
                   let words = data[cnt].split('|');                
                    options.push({ label: words[0], value: words[1]  });
                }          
                this.TypeOptions_Industry = options;
                 
            } catch (error) {
                console.error('check error here WiredObjects_Type_Industry', error);
            }
        } else if (error) {
            console.error('check error here WiredObjects_Type_Industry', error);
        }
    
    }


  @wire(TypeOptions_Industry, {})
    WiredObjects_Type_Industry({ error, data }) {
 
        if (data) {
            try {

                let options = [];
                for (var cnt in data) {
                   let words = data[cnt].split('|');                
                    options.push({ label: words[0], value: words[1]  });
                }          
                this.TypeOptions_AWL = options;
                 
            } catch (error) {
                console.error('check error here TypeOptions_Industry', error);
            }
        } else if (error) {
            console.error('check error here TypeOptions_Industry', error);
        }
    
    }


  @wire(TypeOptions_Industry, {})
    WiredObjects_Type_Industry({ error, data }) {
 
        if (data) {
            try {

                let options = [];
                for (var cnt in data) {
                   let words = data[cnt].split('|');                
                    options.push({ label: words[0], value: words[1]  });
                }          
                this.TypeOptions_Industry = options;
                 
            } catch (error) {
                console.error('check error here TypeOptions_Industry', error);
            }
        } else if (error) {
            console.error('check error here TypeOptions_Industry', error);
        }
    
    }



@wire(TypeOptions_RA, {})
    WiredObjects_Type_RA({ error, data }) {
 
        if (data) {
            try {

                let options = [];
                for (var cnt in data) {
                   let words = data[cnt].split('|');
                
                    options.push({ label: words[0], value: words[1]  });
                }          
                this.TypeOptions_RA = options;
                 
            } catch (error) {
                console.error('check error here TypeOptions_RA', error);
            }
        } else if (error) {
            console.error('check error here TypeOptions_RA', error);
        }
    
    }



@wire(TypeOptions_Status, {})
    WiredObjects_Type_Status({ error, data }) {
 
        if (data) {
            try {

                let options = [];
                for (var cnt in data) {
                   let words = data[cnt].split('|');
                
                    options.push({ label: words[0], value: words[1]  });
                }          
                this.TypeOptions_Status = options;
                 
            } catch (error) {
                console.error('check error here TypeOptions_Status', error);
            }
        } else if (error) {
            console.error('check error here TypeOptions_Status', error);
        }
    
    }
   

    @wire(TypeOptions_SolutionType, {})
    WiredObjects_SolutionType({ error, data }) {
 
        if (data) {
             try {

                let options = [];
                for (var cnt in data) {
                   let words = data[cnt].split('|');
                
                    options.push({ label: words[0], value: words[1]  });
                }          
                this.TypeOptions_SolutionType = options;
                 
            } catch (error) {
                console.error('check error here AWL', error);
            }
        } else if (error) {
            console.error('check error here', error);
        }
 
    }
 
    handleTypeChange(event){
        var Picklist_Value = event.target.value;        
    }

   
    handleChange_Application_Workload(event){
        this.SV_Application_Workload = event.target.value;      
    }

   
     
    
   navigateToSolutionPage() {   
    
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.Cloned_Soln_ID,  
            objectApiName: 'Core_Solution_Areas__c',          
            actionName: 'view'           
        }
    });
    /*
    .then(result => {
        console.log('Error: ', error);
        //alert(JSON.stringify(error.body.message ));
      this.Error_Message=  JSON.stringify(error.body.message);
      this.dispatchEvent(
        new ShowToastEvent({
            title: 'Success',
            message:  ' Solution Clone '+ this.Cloned_Soln_ID + ' completed successfully',
            variant: 'success'
        })
   ) });
  */


    }

   
    handleChange_Status(event){
        this.SV_Status = event.target.value;
        
    }

 
    handleChange_Industry(event){

        this.SV_Industry = event.target.value;
        
        
    }


    handleChange_Solution_Type(event){
        this.SV_Solution_Type = event.target.value;
    }

    handle_EndCustomerSolution(event){
       
        this.SV_End_Customer_Solution = event.target.value;
    }


     handle_IUC(event){
        this.SV_Industry_Use_Case = event.target.value;
      
       
    }

     handle_DealVisible(event){
       
        this.SV_DealVisible = event.target.checked;
       
    }

     handle_DesignVisible(event){
        this.SV_DesignVisible = event.target.checked;
      
       
    }

     handle_Content_Link(event){
        this.SV_Content_Link = event.target.value;
       
    }

    handle_Solution_owner_email(event){
        this.SV_Solution_owner_email = event.target.value;
       
    }

     handle_EndCustomerSolution(event){
        this.SV_EndCustomerSolution = event.target.value;
       
    }
    handle_Description(event){
        this.SV_Description = event.target.value;
       
    }       
    

      handle_TE(event){
        this.SV_Technology_Enabled = event.target.value;
    }

     handle_RA(event){
        this.SV_Region_of_availability = event.target.value;
        
    }
      handle_Partner(event){
        this.Clone_Partners = event.target.checked;
    }
       handle_Name(event){
        this.SV_Name = event.target.value;
    }

    handle_Version(event){
        this.SV_Version = event.target.value;
    }


     get Options_EndCustomerSolution()
    {
            return [
                {label: 'Yes', value: 'Yes'},
                {label: 'No', value: 'No'}
            ];

    }
/*
        listOptions = [
        { value: '1', label: 'Option 1' },
        { value: '2', label: 'Option 2' },
        { value: '3', label: 'Option 3' },
        { value: '4', label: 'Option 4' },
        { value: '5', label: 'Option 5' },
        { value: '6', label: 'Option 6' },
        { value: '7', label: 'Option 7' },
        { value: '8', label: 'Option 8' },
    ];

    defaultOptions = ['7', '2', '3'];

    requiredOptions = ['2', '7'];
*/
    handleChange(event) {
        // Get the list of the "value" attribute on all the selected options
        const selectedOptionsList = event.detail.value;
    
    }

    
    handleSuccess(e) {
        // Close the modal window and display a success toast
        this.dispatchEvent(new CloseActionScreenEvent());
        this.isDeleted__c = true;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message:  ' Solution Clone '+ this.Cloned_Soln_ID + ' completed successfully',
                variant: 'success'
            })
        );
   }

     handleError(e) {
        // Close the modal window and display a success toast
        this.dispatchEvent(new CloseActionScreenEvent());
        this.isDeleted__c = true;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message:  'handleErrorhandleErrorhandleErrorhandleErrorhandleError Solution Clone failed pls validate the errors ' ,
                variant: 'sticky'
            })
        );
   }


    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }


    
    

   

    handleSubmit(event){
        this.disableButton = true;
        this.showWarnings = false;
       
         
         this.template.querySelectorAll('lightning-input-field').forEach(element => {
            element.reportValidity();
           
        });
        
        try{
           
        this.Solution_Areas.Name = this.SV_Name;       
        this.Solution_Areas.Core_Version__c = this.SV_Version;   
         if  (   this.SV_Application_Workload != null ) 
       { 
        this.Solution_Areas.Core_Application_Workload__c='';
        const result = Array.isArray(this.SV_Application_Workload);     
        if (!result)   
       {
        this.Solution_Areas.Core_Application_Workload__c = this.SV_Application_Workload.toString();
       } 
       else
       {
        for (let i = 0; i < this.SV_Application_Workload.length; i++) {
            if (i != this.SV_Application_Workload.length)
            {
                if (this.Solution_Areas.Core_Application_Workload__c != null )
                {
                    this.Solution_Areas.Core_Application_Workload__c = this.Solution_Areas.Core_Application_Workload__c + this.SV_Application_Workload[i] + ';';
                }
                else
                {
                    this.Solution_Areas.Core_Application_Workload__c = this.SV_Application_Workload[i] + ';';
                }
                
            }
            if (i == this.SV_Application_Workload.length)
            {
                this.Solution_Areas.Core_Application_Workload__c =  this.SV_Application_Workload[i] ;

            }
            
          } 
        }
        //this.Solution_Areas.Core_Application_Workload__c = this.SV_Application_Workload.toString().replace(/,/g,';');  
       }         
         if  ( this.SV_Industry != null ) 
       { 
        this.Solution_Areas.Core_Industry__c ='';
        const result = Array.isArray(this.SV_Industry);     
        if (!result)   
       {
        this.Solution_Areas.Core_Industry__c = this.SV_Industry.toString();
       }
       else{

        for (let i = 0; i < this.SV_Industry.length; i++) {
            if (i != this.SV_Industry.length)
            {
                if (this.Solution_Areas.Core_Industry__c != null )
                {
                    this.Solution_Areas.Core_Industry__c = this.Solution_Areas.Core_Industry__c + this.SV_Industry[i] + ';';
                }
                else{

                    this.Solution_Areas.Core_Industry__c =  this.SV_Industry[i] + ';';
                }
           
            }
            if (i == this.SV_Industry.length)
            {
                this.Solution_Areas.Core_Industry__c =  this.SV_Industry[i] ;

            }
            
          } 
        }

       // this.Solution_Areas.Core_Industry__c = this.SV_Industry.toString().replace(/,/g,';');
       }
        
       
        this.Solution_Areas.Core_Status__c = this.SV_Status;    
         if  ( this.SV_Solution_Type != null ) 
       {     
          
        this.Solution_Areas.Core_Solution_Type__c = this.SV_Solution_Type.toString();  
       }        
       
        if  ( this.SV_Industry_Use_Case != null) 
       { 
        this.Solution_Areas.Core_Industry_Use_Case__c ='';
        const result = Array.isArray(this.SV_Industry_Use_Case);  

        if (!result)   
       {
        this.Solution_Areas.Core_Industry_Use_Case__c = this.SV_Industry_Use_Case.toString();
       }
       else{

        for (let i = 0; i < this.SV_Industry_Use_Case.length; i++) {
            if (i != this.SV_Industry_Use_Case.length)
            {
                if (this.Solution_Areas.Core_Industry_Use_Case__c != null )
                {
                    this.Solution_Areas.Core_Industry_Use_Case__c = this.Solution_Areas.Core_Industry_Use_Case__c + this.SV_Industry_Use_Case[i] + ';';
                }
                else{

                    this.Solution_Areas.Core_Industry_Use_Case__c =  this.SV_Industry_Use_Case[i] + ';';
                }
              
            }
            if (i == this.SV_Industry_Use_Case.length)
            {
                this.Solution_Areas.Core_Industry_Use_Case__c =  this.SV_Industry_Use_Case[i] ;

            }
            
          } 
        }
        
        //this.Solution_Areas.Core_Industry_Use_Case__c = this.SV_Industry_Use_Case.toString().replace(/,/g,';');  
       }
       
      
        this.Solution_Areas.Core_End_Customer_Solution__c= this.SV_End_Customer_Solution;   
         if  ( this.SV_Technology_Enabled != null) 
       { 
        
        const result = Array.isArray(this.SV_Technology_Enabled);  
        this.Solution_Areas.Core_Technology_Enabled__c ='';   
        if (!result)   
       {
        this.Solution_Areas.Core_Technology_Enabled__c = this.SV_Technology_Enabled.toString();
       }
       else{

        for (let i = 0; i < this.SV_Technology_Enabled.length; i++) {
            if (i != this.SV_Technology_Enabled.length)
            {
                if (this.Solution_Areas.Core_Technology_Enabled__c != null )
                {
                    this.Solution_Areas.Core_Technology_Enabled__c = this.Solution_Areas.Core_Technology_Enabled__c + this.SV_Technology_Enabled[i] + ';';
                }
                else
                {
                    this.Solution_Areas.Core_Technology_Enabled__c =  this.SV_Technology_Enabled[i] + ';';
                }
                
            }
            if (i == this.SV_Technology_Enabled.length)
            {
                this.Solution_Areas.Core_Technology_Enabled__c =  this.SV_Technology_Enabled[i] ;

            }
            
          } 
        }
       // this.Solution_Areas.Core_Technology_Enabled__c = this.SV_Technology_Enabled.toString().replace(/,/g,';');
       }
           if  (this.SV_Region_of_availability != null ) 
       {  
        this.Solution_Areas.Core_Region_of_availability__c = this.SV_Region_of_availability.toString().replace(/,/g,';');
       }

                
        this.Solution_Areas.Core_Design_Visible__c= this.SV_DesignVisible;
      
        this.Solution_Areas.Core_Deal_Visible__c= this.SV_DealVisible;
       
        this.Solution_Areas.Core_Content_Link__c= this.SV_Content_Link;
       
        this.Solution_Areas.Core_Solution_owner_email__c= this.SV_Solution_owner_email;
        this.Solution_Areas.Core_Solution_Description__c= this.SV_Description;
       

        this.Validation_Message = "";
        this.ValidationFlag = true;
        if (  this.Solution_Areas.Name==null )  
        {
            this.Validation_Message = "Solution Name ";            
            this.ValidationFlag = false;

        }
        if (  this.Solution_Areas.Name!=null && this.Solution_Areas.Name.length > 80)  
        {
            this.Validation_Message = "Solution Name max length is 80 characters ";            
            this.ValidationFlag = false;

        }
        if (  this.Solution_Areas.Name!=null && this.Solution_Areas.Name.length == 0)  
        {
            this.Validation_Message = "Solution Name ";            
            this.ValidationFlag = false;

        }

       if  ( this.Solution_Areas.Core_Application_Workload__c == null   || this.Solution_Areas.Core_Application_Workload__c.length == 0 ) 
       {
        this.Validation_Message =   this.Validation_Message  +  ", Application Workload ";
        this.ValidationFlag = false;

       }   
       
       
        if (  this.Solution_Areas.Core_Solution_Description__c == null ) 
        {
            this.Validation_Message =   this.Validation_Message  +  ", Solution Description ";
            this.ValidationFlag = false;

        }

        if (  this.Solution_Areas.Core_Solution_Description__c != null && this.Solution_Areas.Core_Solution_Description__c.length == 0) 
        {
            this.Validation_Message =   this.Validation_Message  +  ", Solution Description ";
            this.ValidationFlag = false;

        }
              
       if (  this.Solution_Areas.Core_Solution_Type__c == null )  
        {
            this.Validation_Message =   this.Validation_Message  +  ", Solution Type ";
            this.ValidationFlag = false;

        }

        if (this.Solution_Areas.Core_Solution_owner_email__c == null )  
        {
            this.Validation_Message =   this.Validation_Message  +  ", Solution Owner Email ";
            this.ValidationFlag = false;
        }

        if (this.Solution_Areas.Core_Solution_owner_email__c != null && this.Solution_Areas.Core_Solution_owner_email__c.length == 0)  
        {
            this.Validation_Message =   this.Validation_Message  +  ", Solution Owner Email ";
            this.ValidationFlag = false;
        }
        if (  this.Solution_Areas.Core_Technology_Enabled__c == null  || this.Solution_Areas.Core_Technology_Enabled__c.length == 0)  
        {
            this.Validation_Message =   this.Validation_Message  +  ", Technology Enabled ";
            this.ValidationFlag = false;
        }
        if ( this.Solution_Areas.Core_Region_of_availability__c == null || this.Solution_Areas.Core_Region_of_availability__c.length == 0)       
        {
            
            
            this.Validation_Message =   this.Validation_Message  +  ", Region of Availability ";
            this.ValidationFlag = false;

        }
       
        }
          catch (error) {
            this.ValidationFlag = false;
            console.error('check error here ', error);
        }


        if (this.ValidationFlag)
        {
        
         let field = event.detail.fields;
      
        
       // console.log('fields  ====> ' + JSON.stringify(field ));
            CreateRecord({
            Solution_AreaId: this.SolutionData.Id,
            Solution: this.Solution_Areas,
            create_partner: this.Clone_Partners
            })
            .then(result => {
                if (result !== null || result !== undefined) {
                
                     console.log('Result  ====> ' + result);
                     this.Cloned_Soln_ID = result;                   
                     
                    this.navigateToSolutionPage(); 
                    this.template.querySelector('lightning-record-edit-form').submit(field);
                }
            })
            .catch(error => {
                            console.log('Error: ', error);
                         this.showWarnings = true;
                         // alert(this.showWarnings);
                          this.Error_Message =  JSON.stringify(error.body.message);
                            this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Error Message',
                                            message:  JSON.stringify(error.body.message) ,
                                            variant: 'Error',
                                            mode: 'Sticky' 
                                        })
                                    );
                                    }); 
                                    this.disableButton= false;    
      
        }
        else {
           // debugger;
           this.showWarnings = true;
           //alert(this.showWarnings);
           this.Error_Message = 'Enter all the required fields of Solution :: '+  this.Validation_Message;
            this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error Message',
                message:  'Enter all the required fields of Solution :: '+  this.Validation_Message ,
                variant: 'Error',
                mode: 'Sticky' 
            })
        );
        this.disableButton= false;
        
    }
    
       
     }
}