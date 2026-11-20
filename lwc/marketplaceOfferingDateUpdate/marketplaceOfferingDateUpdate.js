// IPA2.0 + US TWC4497-1631
// import { LightningElement, api, track } from 'lwc';
// import updateOfferingDates from '@salesforce/apex/PMP_OfferingDetailsController.updateOfferingDates';
// import endDateError from '@salesforce/label/c.PMP_End_Date_Less_Than_Start_Date_Error';
// import validFrom from '@salesforce/label/c.PMP_Offering_Valid_From';
// import validTo from '@salesforce/label/c.PMP_Offering_Valid_To'; 
// import submit from '@salesforce/label/c.PMP_LeadGen_Submit';
// import cancel from '@salesforce/label/c.Core_PMP_Cancel'; 
// import endDateEqualToStartDate from '@salesforce/label/c.PMP_End_Date_Equals_Start_Date_Error';
// import offeringValidityPeriod from '@salesforce/label/c.PMP_Offering_Validity_Period';
// import success from '@salesforce/label/c.PMP_Success';
// import successMessage from '@salesforce/label/c.PMP_offering_Updated_successfully';
// import error from '@salesforce/label/c.PMP_Error';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// export default class marketplaceOfferingDateUpdate extends LightningElement {
//     showSpinner = false;
//     @track startDate;
//     @track endDate;
//     @track enableSave;
//     @api offeringId;
//     @track saveDisabled = true;
//     @api get minStartDate(){
//         var today = new Date();
//         var dd = today.getDate();
//         var mm = today.getMonth()+1; //January is 0!
//         var yyyy = today.getFullYear();
//         if(dd<10){
//                 dd='0'+dd
//             } 
//             if(mm<10){
//                 mm='0'+mm
//             } 

//         today = yyyy+'-'+mm+'-'+dd;
//         return today;
//     }
//     @track minEndDate = this.minStartDate;
//     label = {
//         endDateError,
//         validFrom,
//         validTo,
//         submit,
//         cancel,
//         endDateEqualToStartDate,
//         offeringValidityPeriod,
//         success,
//         successMessage,
//         error
//     };
    
//     renderedCallback() {
//         //console.log('offId-->' ,this.offeringId);
//         //this.template.querySelectorAll('div').classList.add('custom');
//     }
    
//     handleSave() {
        
//         // checking the form validity before save
//         var validityCheck = this.checkValidity(); 

//         //commented for future use
//       /*  const formValid = [...this.template.querySelectorAll('lightning-input')]
//             .reduce((validSoFar, inputCmp) => {
//                         inputCmp.reportValidity();
//                         return validSoFar && inputCmp.checkValidity();
//             }, true); */
       
       
//         if( validityCheck ){
//           //  this.showSpinner = true;
//             var strtDt = new Date(this.startDate);           
//             var endDt = new Date(this.endDate);
           
//             updateOfferingDates({offering :{
//                 Id: this.offeringId, 
//                 PMP_Partner_Offering_Start_Dt__c: strtDt,
//                 PMP_Partner_Offering_End_Dt__c: endDt
//             }            
//             })
//             .then(() => {
//                 this.showToast(this.label.success,this.label.successMessage ,'success');
//               //  this.showSpinner = false;
//               this.dispatchEvent(new CustomEvent('closeModal',{
//                 detail: {
//                     showButton:false
//                     }
//             }));        
                
//             })
//             .catch((error) => {
//                 this.showToast(this.label.error,null,'error');
//             }); 
//         }
//         else{
//           //  this.showToast('Error!!','enter the required values','error');
//         }
        
//     }
//     //on change of fields values
//     handleChange(event){
//         //console.log(event.target.name +'-->'+event.target.value);
//         var name = event.target.name;
//         var value =event.target.value;
        
//         //console.log('validDate?-->' +isValidDate);
//         //setting the value entered to the corresponding attribute
//         this[event.target.name] = event.target.value;
//         //setting the save button to disabled, if any field value is blank
//         if(!value){
//             this.saveDisabled = true;
//         }
//         //to set the end date to 1 year from start date
//         else if(value && name == 'startDate' ){
//             var splitDate = value.split('-');
//             var dt = new Date();
//             //adding 1 year to the date and setting end date.
//             dt = parseInt(splitDate[0])+ 1 +'-'+splitDate[1] + '-'+splitDate[2] ;
//             this.endDate = dt;
//             this.minEndDate = splitDate[0] +'-'+splitDate[1] + '-'+parseInt(splitDate[2])+1;
//             this.saveDisabled = false;
//             //console.log('endDtDynamic.' ,this.endDate);
//         }
        
//     }
//     //Colse modal when cancel is clicked
//     handleCancel(event){
        
//         this.dispatchEvent(new CustomEvent('closeModal',{
//            detail: {
//             showButton:true
//             }
            
//         }));
//     }
    
//     //method to check the form validity
//     checkValidity(){
        
//         var strtDt;
//         var endDt; 
//         var valid = true; 
        
//         if(this.startDate){
//             strtDt = new Date(this.startDate);            
//             strtDt = strtDt.toISOString().slice(0,10);
//         }        
         
//         if(this.endDate){
//             endDt = new Date(this.endDate);
//             endDt = endDt.toISOString().slice(0,10);
//         }  
         
//         //console.log('startDate-->' +strtDt +'end-->' + endDt);
//         var endDateInput = this.template.querySelector("lightning-input[data-id='endDate']");
//         //if start date is after end date        
//         if(strtDt && endDt && strtDt > endDt){
//             endDateInput.setCustomValidity(this.label.endDateError); 
//             endDateInput.reportValidity();      
//             valid = false;
//         }
//         //if end date equal to start date
//         else if(strtDt && endDt && strtDt == endDt){            
            
//             endDateInput.setCustomValidity(this.label.endDateEqualToStartDate);
//             endDateInput.reportValidity();            
//             valid = false;
//         }
        
//         else{
//             //resetting any previous errors on the fields to blank
//             var allInputs = [...this.template.querySelectorAll('lightning-input')];
//             allInputs.forEach(function(inp){
//                 inp.setCustomValidity("");                
//                 inp.reportValidity();
//             })
//             this.saveDisabled = false;
//             valid = true;
            
//            // input.checkValidity();
//         }
//         console.log('formValid-->' +valid);
        
//         return valid;
//     } 
//     showToast(title,message,variant) {
//         const event = new ShowToastEvent({
//             title: title,
//             message: message,
//             variant:variant
//         });
//         this.dispatchEvent(event);
//     }
    

// }