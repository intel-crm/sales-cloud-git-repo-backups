({
    doInit : function(component, event, helper) {
        //get the name of object from the url.
        console.log('hello');
        component.set("v.maxRecordWarning",'');
        var radioList = [];
        radioList.push({
            label : $A.get("$Label.c.Core_Lead_ExportReportButton"),
            value : $A.get("$Label.c.Core_Lead_ExportReportButton")
        });
        radioList.push({
            label : $A.get("$Label.c.Core_Lead_ExportButton"),
            value : $A.get("$Label.c.Core_Lead_ExportButton")
        });
        component.set("v.buttonList", radioList);
        //call helper method to load the custom list views.
        helper.loadListViewIds(component, event);
    },
    
    onPicklistChange : function(component, event, helper) {
        //clear the error message for the popup dropdown.
        component.set("v.errorMsg",'');
        component.set("v.accessErrorMsg",'');
        component.set("v.maxRecordWarning",'');
        //get the selected list view id.
        var lstViewId = component.find("selectedViewId").get("v.value");
        var lstView = component.get("v.listViewResult"); 
        //get the list view name.
        var lstViewName=lstView.find(o => o.listViewId === lstViewId).label;
        //set the current list view id and name.
        component.set("v.currentListViewName", lstViewName);
        component.set("v.currentListViewId", lstViewId);
    },
    
    exportRecords : function(component, event, helper) {
        //get the selected list view id.
        var lstViewId = component.find("selectedViewId").get("v.value");
        var lstView = component.get("v.listViewResult");
        //get the list view name.
        var lstViewName=lstView.find(o => o.listViewId === lstViewId).label;
         //set the current list view id and name.
        component.set("v.currentListViewName", lstViewName);
        component.set("v.currentListViewId", lstViewId);
        //set the export type as csv/excel based on the button label.
        var exportBtnType = event.getSource().get("v.label");
        if(exportBtnType=='Export CSV'){
            component.set("v.exportType",'csv');
        }
        else{
            component.set("v.exportType",'excel');
        }        
        //set the loading to tru so that spinner comes up.
        component.set("v.isLoading",'true');
       //call the helper method to load records.
        helper.loadRecords(component, event);
    },
    
    handleShowModal : function(component, event, helper) {
        //call helper method to load the custom list views.
        helper.loadListViewIds(component, event);
        
        //set the modal popup to true for it to be visible.
        component.set("v.showModal",true);
    },
    
    handleHideModal : function(component, event, helper) {
         //set the modal popup to false for it to be hidden.
        component.set("v.showModal",false);
        //set error message empty and flag as false.
        component.set("v.errorMsg",'');
        component.set("v.accessErrorMsg",'');
        component.set("v.maxRecordWarning",'');
    },
    
    openReport : function(component, event, helper) {
        var reportLink = $A.get("$Label.c.Core_Partner_Community") + '/s/report/' + $A.get("$Label.c.Core_Lead_ExportReport_Id");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": reportLink
        });
        urlEvent.fire();
    },
   
})