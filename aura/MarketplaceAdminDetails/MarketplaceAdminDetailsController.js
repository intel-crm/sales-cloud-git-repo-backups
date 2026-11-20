({
    
	/*Get Admin Details on init*/
   /* doInit : function(component, event, helper) {    
      helper.getAdminDetails(component, helper);    
  },*/
    
    /*Show/Hide Modal*/
   /* toggleModal:function(component, event, helper) {
        helper.handlerToggleModal(component,helper);
      
    },
    */
    /*Get Selected Admin from the modal*/
   /* handleChange:function(component, event, helper) {
        component.set("v.selectedAdmin",component.find('adminModal').get('v.value'));
        
    },*/

    /*Get Admin Name based on the selected Id in the modal to display*/
    /*modalSave:function(component, event, helper) {
        var admin=component.get("v.admins").find(function(c){return c.Id==component.get("v.selectedAdmin");}); 
        component.set("v.loggedInAdmin",admin.Name) ;
        helper.handlerToggleModal(component,helper);
    },*/
    
    /*Get selected Offering Status (Admin Review, Update Requried, Approved, Rejected)*/
    /*offeringStatusChange:function(component, event, helper) {
        if(component.find('adminOfferingStatus').get('v.value')=="Retired"){
            component.set("v.showRetiredComments",true);
        }else{
            component.set("v.showRetiredComments",false);
            component.set("v.RetiredComments","");
        }
        
         component.set("v.selectedOfferingStatus",component.find('adminOfferingStatus').get('v.value'));
    },*/
    
    /*Update changed details to offering (OfferingStatus, Admin)*/
    /*saveAdminChanges:function(component, event, helper) {
        if(component.find('comments') && !component.find('comments').get('v.value') && component.find('adminOfferingStatus').get('v.value')=="Retired"){
        	
    		var toastEvent = $A.get("e.force:showToast");
    		toastEvent.setParams({
        	"title": "Please fill comments!",
        	"message": "Comments are required"
    		});
    		toastEvent.fire();
            
        }else{ 
            helper.handlerSaveAdminChanges(component,event, helper);
            window.localStorage.setItem('hideSave', false);
            window.localStorage.setItem('hideSaveDesc', false);
            window.localStorage.setItem('hideSaveCompany', false);
        }    
    },*/
  
})