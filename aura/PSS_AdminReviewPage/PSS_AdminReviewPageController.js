//IPA2.0: US-TWC729-7976
({
	helperMethod : function() {
		
	}
})
// ({
//     /*Get Admin Details on init*/
//     doInit : function(component, event, helper) {    
//         helper.getAdminDetails(component, helper);
//     },
    
//     /*Show/Hide Modal*/
//     toggleModal:function(component, event, helper) {
//         helper.handlerToggleModal(component,helper);
        
        
//     },
    
//     /*Get Selected Admin from the modal*/
//     handleChange:function(component, event, helper) {
//        // component.set("v.selectedAdmin","selectedAdmin"); //commented line 
//           component.set("v.selectedAdmin",component.find('adminModal').get('v.value'));

        
//     },
//     /*Get Admin Name based on the selected Id in the modal to display*/
//     modalSave:function(component, event, helper) {
//         var admin=component.get("v.admins").find(function(c){return c.Id==component.get("v.selectedAdmin");}); 
//         component.set("v.loggedInAdmin",admin.Name) ;
//         helper.handlerToggleModal(component,helper);
//     },
    
//     /*Get selected Offering Status (Admin Review, Update Requried, Approved, Rejected)*/
//     offeringStatusChange:function(component, event, helper) {
//        var status = component.find('adminOfferingStatus').get('v.value');
//         if(status=="On Hold"){
//             try{
//                 helper.autoPopulateFollowUpDate(component, event, helper);
//             }catch(e){
//                 console.log(e);
//             }
//           var followUpDate = component.find('date1').get('v.value');
//             if(!followUpDate){
//                 component.set('v.valid',false);
//                 component.set('v.required',true);
//             } 

//         }
//         else{
            
//             component.set('v.valid',true);
//             component.set('v.required',false);
//         }
//         component.set("v.selectedOfferingStatus",status);

//     },
    
//     surveyStatusChange:function(component, event, helper) {
//        component.set("v.selectedBenefitStatus",component.find('survey').get('v.value'));
       
//     },
    
//     dateChange:function(component, event, helper) {
//         let validDates = component.find("date1") ? [].concat(component.find("date1")) : [];
//         validDates= component.find("dateReviewScheduled") ? validDates.concat(component.find("dateReviewScheduled")) : validDates;
        
//         let dateValid = true;
//         validDates.forEach(function(input) {
//             if(!input.checkValidity()){
//                 dateValid=false;
//             } 
//         });
//         component.set('v.valid',dateValid);
//     },
    
//     activationcallChanges:function(component, event, helper){
//         component.set('v.ActivationCall',false);
//         helper.updateAdminChanges(component, event, helper);
//     },

//     cancelActivationChanges:function(component,event,helper){
//         component.set('v.ActivationCall',false);
//     },

//   /*Update changed details to offering (OfferingStatus, Admin)*/
//     saveAdminChanges:function(component, event, helper) {
        
//             /* Handling AIIP Conversion */
//             var arrString = component.get("v.selectedGenreList").toString();
//             var programs = arrString.split(";");
//             var conversion = true;
//             var aiipLabel = $A.get("$Label.c.PSS_AIIP_Value");
//             if(programs.length == 1 && programs[0] == aiipLabel && (component.get("v.selectedOfferingStatus") != 'Rejected')){
//                 conversion = false;
//             }
//             if(component.get("v.selectedGenreList").includes(aiipLabel)){
//                 component.set('v.aiipWarning',true); 
//             }
//             if(!conversion){
//                 var toastEvent = $A.get("e.force:showToast");
//                 if(toastEvent){
//                     toastEvent.setParams({
//                         "title": "Error",
//                         "message": $A.get("$Label.c.PSS_AIIP_Solution_Approval_Message"),
//                         "type":"error",
//                         "mode":'dismissible' 
//                     });
//                     toastEvent.fire();
//                 }   
//             }
//             if(conversion){
//                 if(component.get('v.valid')){
//                         if(component.get("v.selectedOfferingStatus") == 'Approved')
//                         {
//                         component.set('v.ActivationCall',true);
//                         }
//                         else{
//                         helper.updateAdminChanges(component,event, helper);
//                         }
//                 }
//                 else{
//                     alert('Please select the valid date');
//                 } 
//         }       
//     },
    
//     handleGenreChange: function (component, event, helper) {
//         //Get the Selected values  
//         var selectedValues = event.getParam("value");
        
//         //Update the Selected Values  
//         component.set("v.selectedGenreList", selectedValues);
//         var attributeList = JSON.parse(JSON.stringify(selectedValues));
//         component.set("v.finalGenre", attributeList.join(';')) ;
//     },
    
//     handleAttributeChange: function (component, event, helper) {
//         component.set("v.isTouched",true);
//         //Get the Selected values   
//         var selectedValues = event.getParam("value");        
//         //Update the Selected Values
//         component.set("v.selectedAttributeList", selectedValues);
//        var attributeList = JSON.parse(JSON.stringify(selectedValues));
//         component.set("v.finalAttribute", attributeList.join(';')) ;      
//     },
    
//     calculateImpactpathScore : function (component, event, helper){
//          helper.impactPathScoreChanges(component,event, helper);
//         }
    
// })