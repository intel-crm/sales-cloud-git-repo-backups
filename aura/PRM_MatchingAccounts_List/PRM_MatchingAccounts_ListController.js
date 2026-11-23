({ 
    doInit : function(component, event, helper) {
        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", 1);
        helper.fetchAccount(component,event,helper);
    },
    
    onNext : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber+1);
        helper.buildData(component, helper,event);
        var dTable = component.find('accountTable');
        dTable.set("v.selectedRows", component.get("v.selectedList"));
        
    },
    
    onPrev : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber-1);
        helper.buildData(component, helper,event);
        var dTable = component.find('accountTable');
        dTable.set("v.selectedRows", component.get("v.selectedList"));
        
    },
    
    processMe : function(component, event, helper) {
        component.set("v.currentPageNumber", parseInt(event.target.name));
        helper.buildData(component, helper,event);
        var dTable = component.find('accountTable');
        dTable.set("v.selectedRows", component.get("v.selectedList"));
    },
    
    onFirst : function(component, event, helper) {        
        component.set("v.currentPageNumber", 1);
        helper.buildData(component, helper,event);
        var dTable = component.find('accountTable');
        dTable.set("v.selectedRows", component.get("v.selectedList"));
    },
    
    onLast : function(component, event, helper) {        
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.buildData(component, helper,event);
        var dTable = component.find('accountTable');
        dTable.set("v.selectedRows", component.get("v.selectedList"));
    },
    
    updateSelectedText : function(component,event,helper){
        helper.selectedRow(component,event,helper);
    },
    
    handleClick : function(component,event,helper){
        var button = '';
        helper.click(component,event,helper,button);
    },
    
    changeAccountInput : function(component,event,helper){
        var id = component.find("accountInput").get("v.value");
        var button = component.find('submit');
        console.log('id'+id);
        component.set("v.ErrorMessage","");
        if(id == ''){
            button.set('v.disabled',true);
        }
        else{            
            button.set('v.disabled',false);
        }
    },
    
    submitAccount : function(component,event,helper){
        helper.reuseAccount(component,event,helper);
    },
    
    backButton : function(component,event,helper){
        component.set("v.displayDuplicateAccounts",true);
        component.find("accountInput").set("v.value", component.get("v.accId"));
        component.find("submit").set("v.disabled",false);
        component.set("v.confirmationDuplicateScreen",false);
    },
    
    confirmButton : function(component,event,helper){
        var button = 'confirm';
        helper.click(component,event,helper,button);
    }
    
})