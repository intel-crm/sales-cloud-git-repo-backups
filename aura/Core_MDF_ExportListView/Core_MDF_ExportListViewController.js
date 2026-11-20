({
    doInit : function(component, event, helper) {
        //get the name of object from the url.
        var sPageURL = decodeURIComponent(window.location.href);
        var fields = sPageURL.split('/');
        var sObj = fields[(fields.length)-2];
        component.set("v.maxRecordWarning",'');
        //call helper method to load the custom list views.
        helper.loadListViewIds(component, event, sObj);
    },    
    onPicklistChange: function(component, event, helper) {     
        //clear the error message for the popup dropdown.
        component.set("v.errorMsg",'');
        component.set("v.accessErrorMsg",'');
        component.set("v.maxRecordWarning",'');
        //get the name of object from the url.
        var sPageURL = decodeURIComponent(window.location.href);
        var fields = sPageURL.split('/');
        var sObj = fields[(fields.length)-2];
        //get the selected list view id.
        var lstViewId = component.find("selectedViewId").get("v.value");
        var lstView = component.get("v.listViewResult"); 
        //get the list view name.
        var lstViewName=lstView.find(o => o.listViewId === lstViewId).label;
        //set the current list view id and name.
        component.set("v.currentListViewName", lstViewName);
        component.set("v.currentListViewId", lstViewId);
        
    },   
    exportRecords: function(component, event, helper) { 
       
        //get the name of object from the url.
        var sPageURL = decodeURIComponent(window.location.href);
        var fields = sPageURL.split('/');
        var sObj = fields[(fields.length)-2];
        //get the selected list view id.
        var lstViewId = component.find("selectedViewId").get("v.value");
        var lstView = component.get("v.listViewResult");
        //get the list view name.
        var lstViewName=lstView.find(o => o.listViewId === lstViewId).label;
         //set the current list view id and name.
        component.set("v.currentListViewName", lstViewName);
        component.set("v.currentListViewId", lstViewId);
        //set the export type as csv/excel based on the button label.
        var exportBtnType = event.getSource().get("v.title");
        if(exportBtnType=='Export To CSV'){
            component.set("v.exportType",'csv');
        }
        else{
            component.set("v.exportType",'excel');
        }        
        //set the loading to tru so that spinner comes up.
        component.set("v.isLoading",'true');
       //call the helper method to load records.
        helper.loadRecords(component, event, sObj); 
        
    },
    handleShowModal: function(component, event, helper) {
        //get the name of object from the url.
        var sPageURL = decodeURIComponent(window.location.href);
        var fields = sPageURL.split('/');
        var sObj = fields[(fields.length)-2];
        //call helper method to load the custom list views.
        helper.loadListViewIds(component, event, sObj);        
        
        //set the modal popup to true for it to be visible.      
        component.set("v.showModal",true);
        
    },
    handleHideModal: function(component, event, helper) {
         //set the modal popup to false for it to be hidden.
        component.set("v.showModal",false);
        //set error message empty and flag as false.
        component.set("v.errorMsg",'');
        component.set("v.accessErrorMsg",'');
        component.set("v.maxRecordWarning",'');
    },
   
})