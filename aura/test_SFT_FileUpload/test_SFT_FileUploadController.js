({
    doInit : function(component, event, helper) {
        var action = component.get("c.returnClassic");
         let recordId = component.get("v.recordId");
        //let recordId = "0RBg00000009KJGGA2";
        action.setParams({recId: recordId});
        action.setCallback(this,function(response){
            console.log('till1 ',response.getReturnValue());
                if (response.getState() === "SUCCESS"){
                    console.log('till ',response.getReturnValue());
                    component.set('v.URL', response.getReturnValue());
                }
            });
        $A.enqueueAction(action);
    },
    openSFT : function(component, event, helper) {
        var action = component.get("c.returnClassic");
        let recordId = component.get("v.recordId");
        action.setParams({recId: recordId});
        action.setCallback(this,function(response){
            console.log('till2 ',response.getReturnValue());
                if (response.getState() === "SUCCESS"){
                    component.set("v.showUploadFileSection", true);
                    component.set("v.isModalOpen", true);
                }
            });
        $A.enqueueAction(action);
    },
    auditDocInsertion : function(component, event, helper) {
        var myAttribute = component.get("v.myAttribute");
        var action = component.get("c.auditDocumentInsertion");
        let recordId = component.get("v.recordId");
        var name = 'asdfghjk';
        //action.setParams({"name": name});
        action.setParams({ "myString" : myAttribute });
        action.setCallback(this,function(response){
            console.log('till ',response.getReturnValue());
                if (response.getState() === "SUCCESS"){
                    //component.set("v.showUploadFileSection", true);
                    component.set("v.isModalOpen", false);
                }
            });
        $A.enqueueAction(action);
    },
    openModel: function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },
    closeModal: function(component, event, helper) { 
        component.set("v.isModalOpen", false);
    },

    // component.set("v.showUploadFileSection", true);
});