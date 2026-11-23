({
	loadDocuments : function(component) {
		var action = component.get("c.fetchDocumentIds");
        var pfrId = component.get("v.recordId");
        var existIds = [];
        existIds = component.get("v.contentdocumentids");
        action.setParams({
            		"pfrId": pfrId,
            		"unsaveddocs": existIds
                });    
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var docIds = [];
            var vdata = [];
            if(state === 'SUCCESS'){
                var urlString = "";
                if(window.location.href.indexOf($A.get("$Label.c.Core_MDF_PartnerCommunityIdentifier ")) > -1) {
       				urlString = $A.get("$Label.c.Core_MDF_PFRCommunityLink") + 'sfc/servlet.shepherd/document/download/';
    			}
                else
                {
                    urlString = '/sfc/servlet.shepherd/document/download/';
                }
                
                response.getReturnValue().forEach(function(item){
                  docIds.push(item.ContentDocumentId);
                  item.docurl = urlString + item.ContentDocumentId +'?operationContext=S1';
                  vdata.push(item);
                });
                
                component.set("v.filedata", vdata);
            }
            else if(state === 'ERROR')
            {
                if (Array.isArray(response.getError()) && response.getError().length > 0) {
                    component.set('v.errormsg',response.getError()[0].message);
                    component.set('v.iserror',true);
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    deleteDocs : function (component,docIds)
    {
        var action = component.get("c.deleteDocumentIds");
        
        action.setParams({
            		"docIds": docIds
                });    
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                this.loadDocuments(component);
                //setting the parameters of event
                var upload = component.getEvent("fileuploadcheck");
                var docCounts = component.get("v.contentdocumentids");
                if (docCounts.length <= 0)
                {
                    component.set("v.uploadfilecheck",false);
                    component.set("v.contentdocumentids",null);
                }
                upload.setParams({
                    uploadFilesIds: component.get("v.contentdocumentids"),
                    fileUploaded : component.get("v.uploadfilecheck")
                }).fire();
            }
            else if(state === 'ERROR')
            {
                if (Array.isArray(response.getError()) && response.getError().length > 0) {
                    component.set('v.errormsg',response.getError()[0].message);
                    component.set('v.iserror',true);
                }
            }
        });
        
        $A.enqueueAction(action);
     }
    
})