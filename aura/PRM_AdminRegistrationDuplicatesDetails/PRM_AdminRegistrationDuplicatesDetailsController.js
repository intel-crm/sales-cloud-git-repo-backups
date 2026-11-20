({
    doInit : function(component, event, helper) {
        helper.fetchAccountContact(component,event,helper);	
    },
    cimAccounts : function(component, event) {
        var selectedmap = component.get("v.selectedRowMap");
        //selectedmap.SelectedAccount =  JSON.stringify(component.get("v.selectedRowsList"));
        selectedmap.SelectedRow =  component.get("v.selectedRowsList");
        component.set("v.selectedRowMap",selectedmap);
        //alert('Final selected Map before returning-->'+JSON.stringify(selectedmap));
        console.log('Final before returning-->'+JSON.stringify(selectedmap));
        //return component.get("v.accountsCim"); 
        return selectedmap;
    },
    
    onNext : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber+1);
        helper.buildData(component, helper,event);
        var dTable = component.find('accsFoundTable');
        console.log('onNext selectedList'+component.get("v.selectedList"));
        dTable.set("v.selectedRows", component.get("v.selectedList"));
        console.log('Selected rows Id'+dTable.get("v.selectedRows"));
    },
    
    onPrev : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber-1);
        helper.buildData(component, helper,event);
        var dTable = component.find('accsFoundTable');
        console.log('onPrev selectedList'+component.get("v.selectedList"));
        dTable.set("v.selectedRows", component.get("v.selectedList"));
        
    },
    
    processMe : function(component, event, helper) {
        component.set("v.currentPageNumber", parseInt(event.target.name));
        helper.buildData(component, helper,event);
        var dTable = component.find('accsFoundTable');
        console.log('processMe selectedList'+component.get("v.selectedList"));
        dTable.set("v.selectedRows", component.get("v.selectedList"));
        
    },
    
    onFirst : function(component, event, helper) {        
        component.set("v.currentPageNumber", 1);
        helper.buildData(component, helper,event);
        var dTable = component.find('accsFoundTable');
        console.log('onFirst selectedList'+component.get("v.selectedList"));
        dTable.set("v.selectedRows", component.get("v.selectedList"));
    },
    
    onLast : function(component, event, helper) {        
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.buildData(component, helper,event);
        var dTable = component.find('accsFoundTable');
        console.log('onLast selectedList'+component.get("v.selectedList"));
        dTable.set("v.selectedRows", component.get("v.selectedList"));
        
    },
    
    updateSelectedText : function(component, event, helper) {
        //alert("Controller Select Rows");
        helper.selectedRow(component,event,helper);
    },
    
    clearEvent : function(component,event,helper){
        helper.clearResults(component,event,helper);
    }
    
})