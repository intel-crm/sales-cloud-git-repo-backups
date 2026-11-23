({
	// Function called on the upload finish to fetch Ids and files name and toast message
    handleUploadFinished : function(component, event, helper) {
        var uploadedFiles = event.getParam("files");
        
        var documentids = [];
        var contents = component.get("v.contentdocumentids");
        
        // Restore the existing document id's when upload the new set of files
        if (contents != null)
        {
        	for (var dc = 0; dc<contents.length; dc++)
            {
                if (documentids.indexOf(contents[dc] == -1))
                {
                    documentids.push(contents[dc]);
                }
            }    
        }
                
        if(uploadedFiles.length > 0){
            component.set("v.uploadfilecheck",true)
        }
        for(var i = 0; i < uploadedFiles.length; i++){
        	documentids.push(uploadedFiles[i].documentId);
        } 
        component.set("v.contentdocumentids", documentids);
        helper.loadDocuments(component);
        
        //setting the parameters of event
        var upload = component.getEvent("fileuploadcheck");
        
        upload.setParams({
            uploadFilesIds: component.get("v.contentdocumentids"),
            fileUploaded : component.get("v.uploadfilecheck")
        }).fire();
        
        var fileName = uploadedFiles[0].name;
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "File "+fileName+" Uploaded successfully."
        });
        toastEvent.fire();
    },
    
    // Function called on the load of the compoent
    doInit : function(component, event, helper) {
    	var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.userInfo",userId);
        
        var fileTypes = [];
        var fileTypesLabel = "";
        fileTypesLabel = $A.get("$Label.c.Core_MDF_AllowedFileTypes");
        var fileTypes = fileTypesLabel.split(",");
        component.set("v.accept",fileTypes);
        
        component.set('v.errormsg','');
        component.set('v.iserror',false);
        
        helper.loadDocuments(component);
	},
    deleteSelected : function(component,event,helper){
        var userconfrm = confirm($A.get("$Label.c.Core_MDF_Delete_Confirm"));
        if (userconfrm)
        {
            var dataId = event.currentTarget.getAttribute("data-Id");
            component.set("v.selectedDocumentId" , dataId); 
            
            var docIdsToDel = [];
            docIdsToDel.push(dataId);
            
            var documentids = [];
            documentids = component.get("v.contentdocumentids");
            
            var filtered = documentids.filter(function(value, index, arr){
    			return value != dataId;
			});
            
            component.set("v.contentdocumentids",filtered);
            helper.deleteDocs(component,docIdsToDel);
             
        }
    }
})