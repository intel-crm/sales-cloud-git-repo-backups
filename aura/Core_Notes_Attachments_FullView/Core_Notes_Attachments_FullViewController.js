({
	doInit: function(component, event, helper) {
        var ntTitle = 'Notes & Attachments | Salesforce';
        document.title = ntTitle;
        var pageReference = component.get("v.pageReference");
        component.set("v.recordId", pageReference.state.c__recordId);
        component.set("v.loaded", false);
        var attSufix = "&operationContext=S1";
        component.set("v.attSuffix",attSufix);
        helper.getAccountDetails(component, event, helper);
        var action = component.get("c.getAllNotesAttachments");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            ntTitle = 'Notes & Attachments';
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                if(result.length == 0){
                    component.set("v.ntAttCount", result.length);
                }else{
                    component.set("v.ntAttCount", result.length);
                    component.set("v.ntAttList", result);
                }
                component.set("v.ntAttTitle", ntTitle);
            }else{
                console.log("Error on fetching notes & attachments "+JSON.stringify(response.getError()));
            }
            component.set("v.loaded", true);
        });
        $A.enqueueAction(action);
    },
    
    createNotePopup : function(component, event, helper) {
        component.set("v.isNote", true);
    },
    
    saveNote : function(component, event, helper) {
        component.set("v.loaded", false);
        var ntId = component.get("v.noteId");
        var notTitle = "";
        if(component.get("v.noteTitle") == ""){
            notTitle = "Untitled Note";
        }else{
            notTitle = component.get("v.noteTitle");
        }
        var ntDesc = component.get("v.noteDesc");
        var ntType = component.get("v.noteType");
        var act = component.get("c.closeModel");
        $A.enqueueAction(act);
        var action = component.get("c.createUpdateNote");
        action.setParams({
            "noteId" : ntId,
            "noteTitle" : notTitle,
            "noteDesc" : ntDesc,
            "noteType" : ntType,
            "parentId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            if(state === "SUCCESS"){
                var msg = "";
                if(ntId == ""){
                    msg = "Note created successfully.";
                }else{
                    msg = "Note updated successfully.";
                }
                toastEvent.setParams({
                    "type": "success",
                    "message": msg
                });
            }else{
                console.log("Error on creating note "+JSON.stringify(response.getError()));
                toastEvent.setParams({
                    "type": "error",
                    "message": JSON.stringify(response.getError())
                });
            }
            toastEvent.fire();
            component.set("v.loaded", true);
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    },
    
    handleUploadFinished : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    
    handleMenuSelect : function(component, event, helper) {
        var indx = event.getSource().get("v.tabindex");
        console.log('indx '+indx);
        var ntAttRecord = component.get("v.ntAttList["+indx+"]");
        var selectedMenu = event.detail.menuItem.get("v.value");
        console.log('selectedMenu-' + selectedMenu);
        switch(selectedMenu) {
            case "edit":
                component.set("v.noteId", ntAttRecord.docId);
                component.set("v.noteType", ntAttRecord.docType);
                component.set("v.noteTitle", ntAttRecord.docName);
                component.set("v.noteDesc", ntAttRecord.docDescription);
                var action = component.get("c.createNotePopup");
                $A.enqueueAction(action);
                break;
            case "download":
                var downloadUrl = "";
                if(ntAttRecord.docType == 'Attachment'){
                    downloadUrl = component.get("v.attDownloadUrl") + ntAttRecord.docId + '&operationContext=S1';
                }else{
                    downloadUrl = component.get("v.fileDownloadUrl") + ntAttRecord.docId + '?operationContext=S1';
                }
                window.open(downloadUrl, "_blank");
                break;
            case "delete":
                component.set("v.delRecType", ntAttRecord.docType);
                component.set("v.delRecId", ntAttRecord.docId);
                component.set("v.delRecName", ntAttRecord.docName);
                component.set("v.popUpType", "Delete");
                component.set("v.isOpenPopUp", true);
                break;
            case "makePublic":
                component.set("v.delRecType", ntAttRecord.docType);
                component.set("v.delRecId", ntAttRecord.docId);
                component.set("v.delRecName", ntAttRecord.docName);
                component.set("v.popUpType", "Public");
                component.set("v.isOpenPopUp", true);
                break;
            case "makePrivate":
                component.set("v.delRecType", ntAttRecord.docType);
                component.set("v.delRecId", ntAttRecord.docId);
                component.set("v.delRecName", ntAttRecord.docName);
                component.set("v.popUpType", "Private");
                component.set("v.isOpenPopUp", true);
                break;
        }
    },
    
    deleteRecord : function(component, event, helper) {
        component.set("v.loaded", false);
        var delRecType = component.get("v.delRecType");
        var delRecId = component.get("v.delRecId");
        var delRecName = component.get("v.delRecName");
        var act = component.get("c.closeDelModel");
        $A.enqueueAction(act);
        var action;
        if(delRecType == 'Note'){
            action = component.get("c.delNote");
        }else if(delRecType == 'Attachment'){
            action = component.get("c.delAttachment");
        }else if(delRecType == 'Enhanced Note'){
            action = component.get("c.delEnhancedNote");
        }else{
            action = component.get("c.delFile");
        }
        action.setParams({
            "recId" : delRecId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            if(state === "SUCCESS"){
                toastEvent.setParams({
                    "type": "success",
                    "message": delRecName + " deleted successfully."
                });
            }else{
                toastEvent.setParams({
                    "type": "error",
                    "message": JSON.stringify(response.getError())
                });
            }
            toastEvent.fire();
            component.set("v.loaded", true);
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    },
    
    changeAccessLevel : function(component, event, helper) {
        component.set("v.loaded", false);
        var recId = component.get("v.delRecId");
        var recType = component.get("v.delRecType");
        var desAccess = component.get("v.popUpType");
        var recName = component.get("v.delRecName");
        var act = component.get("c.closeDelModel");
        $A.enqueueAction(act);
        var action = component.get("c.updateAccessLevel");
        action.setParams({
            recordId : recId,
            recType : recType,
            desiredAccess : desAccess
        });
        action.setCallback(this, function(response){
            var toastEvent = $A.get("e.force:showToast");
            if(response.getState() === "SUCCESS"){
                toastEvent.setParams({
                    "type": "success",
                    "message": "Access level of " + recName + " has been set to " + desAccess + " successfully."
                });
            }else{
                toastEvent.setParams({
                    "type": "error",
                    "message": JSON.stringify(response.getError())
                });
            }
            toastEvent.fire();
            component.set("v.loaded", true);
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    },
    
    closeModel : function(component, event, helper) {
        component.set("v.isNote", false);
        component.set("v.noteType", "Enhanced Note");
        component.set("v.noteId", "");
        component.set("v.noteTitle", "");
        component.set("v.noteDesc", "");
    },
    
    closeDelModel : function(component, event, helper) {
        component.set("v.isOpenPopUp", false);
        component.set("v.popUpType", "");
        component.set("v.delRecType", "");
        component.set("v.delRecId", "");
        component.set("v.delRecName", "");
    }
})