({
    doInit : function(component, event, helper) {
        //get the name of object from the url.
        var action = component.get('c.sObjectNames');
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var data = response.getReturnValue();
                var sobjectName = [];
                var hyperlinkFields = [];
                for(var i=0; i<data.length; i++){
                    
                    sobjectName.push(data[i].sobjectName);
                    
                    hyperlinkFields.push(data[i].hypersinkFields);
                    
                }
                
                let unique = [...new Set(sobjectName)];
                
                component.set("v.sObjectList",unique);
                component.set("v.urlFields",hyperlinkFields);
                
                var objList = component.get('v.sObjectList');
                var pathname = window.location;
                pathname = pathname.toString();                
                for(var i=0; i<objList.length; i++){
                    
                    if(pathname.includes(objList[i])){
                        
                        component.set("v.sObjectName",objList[i]);
                         break;
                    }
                  
                }
            }
        });
        $A.enqueueAction(action); 
        
        
        
        component.set("v.maxRecordWarning",'');
        var radioList = [];
        
        radioList.push({
            label : $A.get("$Label.c.PMP_ExportButton"),
            value : $A.get("$Label.c.PMP_ExportButton")
        });
        component.set("v.buttonList", radioList);
        //call helper method to load the custom list views.
        helper.loadListViewIds(component, event);
        //helper.hyperlinkFields(component, event);
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
        // var lstViewName=lstView.find(o => o.listViewId === lstViewId).label;
        
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
        //helper.executebach(component, event);
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
    }
})