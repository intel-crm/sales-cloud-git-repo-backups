({
    initiateComponent : function(component, event){ 
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.userInfo",userId);
        
        var recId = component.get("v.recordId");
        
            //Setting File formats
        var fileFormats = $A.get("$Label.c.Core_MDF_AllowedFileTypes").split(',');                          
        component.set("v.accept", fileFormats); 
                
        var isProofOfCostUploaded = false;
        var isProofOfBrandingUploaded = false;
        var isProofOfExcecutionUploaded = false;
        
        var docList;
        var untaggedDoc = [];
        
        var action = component.get("c.getAuditDocuments");
        console.log('recId:'+component.get("v.recordId")); 
        action.setParams({ recordId : recId, documentIdWithTitle:null});
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {                
                component.set("v.isResponseReceived",true);                                        
                var sObjectWrapper = res.getReturnValue();
                console.log('sObjectWrapper:',res.getReturnValue());
                if(sObjectWrapper != null ){
                    component.set("v.sObjectDocumentWrapper",sObjectWrapper);                                        
                    docList = sObjectWrapper.documentList;
                    component.set("v.auditDocument",docList);
                                       
                    if(docList != null){
                        for(let index in docList){
                            if(docList[index].Core_MDF_Proof_of_Cost__c != true && docList[index].Core_MDF_Proof_of_Branding__c != true && docList[index].Core_MDF_Proof_of_Execution__c != true){
                                untaggedDoc.push(docList[index]);    
                            }
                            
                            //Check all the file types are uploaded
                            if(docList[index].Core_MDF_Proof_of_Cost__c){
                                isProofOfCostUploaded = true;
                            }
                            if(docList[index].Core_MDF_Proof_of_Branding__c){
                                isProofOfBrandingUploaded = true;
                            }
                            if(docList[index].Core_MDF_Proof_of_Execution__c){
                                isProofOfExcecutionUploaded = true;
                            }                                                    
                        }                                                
                    }
                    
                    if(isProofOfCostUploaded){
                        component.set("v.isProofOfCostUploaded",true);
                    }
                    if(isProofOfBrandingUploaded){
                        component.set("v.isProofOfBrandingUploaded",true);
                    }
                    if(isProofOfExcecutionUploaded){
                        component.set("v.isProofOfExcecutionUploaded",true);
                    }                    
                    
                    if(isProofOfCostUploaded && isProofOfBrandingUploaded && isProofOfExcecutionUploaded){
                        component.set("v.isSubmitEnabled",true);
                    }
                    
                    if(untaggedDoc.length > 0){
                        component.set("v.auditDocument",untaggedDoc);
                        component.set("v.isOpen",true);                        
                    }                                                
                    
                    if(docList.length > 0){
                        component.set("v.isManageDocEnabled",true); 
                        
                    }                                                           
                }
            }
			else{                                    
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					message : $A.get("$Label.c.Core_MDF_Manage_Document_Exception_Error_Message"),                  
					duration:'5000',
					key: 'info_alt',
					type: 'error'
				}); 
				toastEvent.fire();
			}
		});
      /* var action = component.get('c.handleUploadFinished');
    	action.setCallback(component,
        function(response) {
            var state = response.getState();
            if (state === 'SUCCESS'){
                $A.get('e.force:refreshView').fire();
            }
        }
    ); */
		$A.enqueueAction(action);
        		//$A.enqueueAction(action2);

	},

    //On Susccessful upload Audit Document records will be created
    // isOpen attribute is set true, to open file selection model
    // Audit document will be updated once user click the save button.
    createObjectDocuments: function (component, event) { 
        component.set("v.isEnableCancel", false);
        component.set("v.isInsert", true);
        component.set("v.isManageDocEnabled",true);
        
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.userInfo",userId);
        
        var uploadedFiles = event.getParam("files");
        
        var uploadedDocId = [];
        
        var auditDocList = [];
        if(component.get("v.auditDocument").length > 0){
            auditDocList = auditDocList.concat(component.get("v.auditDocument"));
        }
        
        var isFileUploadOnClaimCreation = component.get("v.isFileUploadOnClaimCreation");
       
        
        for(var index=0; index < uploadedFiles.length; index++){
            
             if(isFileUploadOnClaimCreation){
                 
                auditDocList.push({'sobjectType':'Core_MDF_Audit_Document__c',
                                   'Core_MDF_Document_Title__c':uploadedFiles[index].name,
                                   'Core_MDF_Document_Id__c':uploadedFiles[index].documentId});
                 console.log('auditDocList'+JSON.stringify(auditDocList));
                component.set("v.contentdocumentids", uploadedFiles[index].documentId);
                 
                 }
          
            else{                
                uploadedDocId.push(uploadedFiles[index].documentId+';#'+uploadedFiles[index].name);
            }
            
        }
        
        //Set Audit Documents which are uploaded from Claim Creation
        if(isFileUploadOnClaimCreation){
            component.set("v.auditDocument",auditDocList);
            component.set("v.isOpen",true);
       
        }
        else{
            var documents = component.get("v.contentdocumentids");
            component.set("v.contentdocumentids",uploadedDocId);
            console.log('uploadedDocId'+uploadedDocId);
            var recId = component.get("v.recordId");
            var docList;
            var action = component.get("c.getAuditDocuments");
            action.setParams({ recordId : recId, documentIdWithTitle:uploadedDocId});
            action.setCallback(this, function(res) {
                var state = res.getState();
                    if (state === "SUCCESS") {
                       // alert('state'+state);
                    component.set("v.isResponseReceived",true);
                    var sObjectWrapper = res.getReturnValue();
                    if(sObjectWrapper != null ){
                        component.set("v.sObjectDocumentWrapper",sObjectWrapper);   
                        docList = sObjectWrapper.documentList;
                        component.set("v.auditDocument",docList);
                        //alert('doclist is '+docList);
                        if(docList != null ){
                            component.set("v.auditDocument",docList);
                            component.set("v.isOpen",true);
                            
                        }
                    }
                }
                else{                                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message : $A.get("$Label.c.Core_MDF_Manage_Document_Error_Message"),                  
                        duration:'5000',
                        key: 'info_alt',
                        type: 'error'
                    });                    
                }                
            });
            $A.enqueueAction(action);             
        }                                                              
    },
    
	// Enable/Disble submit button
    enableDisableSubmitButton: function(component, event) {
        var docList = component.get("v.auditDocument");
        var isSubmitEnabled = component.get("v.isSubmitEnabled");
        var isManageButtonClicked = component.get("v.isManageButtonClicked");
        
        var isProofOfCostUploaded = component.get("v.isProofOfCostUploaded");
        var isProofOfBrandingUploaded = component.get("v.isProofOfBrandingUploaded");
        var isProofOfExcecutionUploaded = component.get("v.isProofOfExcecutionUploaded");
        
        if(isManageButtonClicked){
            isProofOfCostUploaded = false;
            isProofOfBrandingUploaded = false;
            isProofOfExcecutionUploaded = false;             
        }
        //var indexvar = event.getSource().get("v.value");
          
                if(docList != null){                    
                    for(let index in docList){                
                        //Check all the file types are uploaded
                        var picklist = '';
                        if(docList[index].Core_MDF_Proof_of_Cost__c){
                            isProofOfCostUploaded = true;
                            picklist = 'Proof of Cost';
                            
                        }
                        if(docList[index].Core_MDF_Proof_of_Branding__c){
                            isProofOfBrandingUploaded = true;
                            picklist += ';'+'\n'+'Proof of Branding';
                            
                        }
                        if(docList[index].Core_MDF_Proof_of_Execution__c){
                            isProofOfExcecutionUploaded = true;
                            picklist += ';'+'\n'+'Proof of Execution';
                        } 
                        //alert("picklist"+picklist);
                        docList[index].Core_MDF_Document_Types__c = picklist; 
                    }   
                    console.log("debugging"+docList);
                    component.set("v.auditDocument",docList);
                    console.log("debugging11"+docList);
                    
                    
                    if(isProofOfCostUploaded && isProofOfBrandingUploaded && isProofOfExcecutionUploaded){
                        component.set("v.isSubmitEnabled",true);
                    }else{
                        component.set("v.isSubmitEnabled",false);
                    }        
                }
          /*  } 
        });           
        $A.enqueueAction(action);
    }*/
    
},
    
    updateObjectDocuments: function(component, event, helper) {
        component.set("v.isEnableCancel", false);
        var recId = component.get("v.recordId");
        var docList = component.get("v.auditDocument");
        var checkfileuploadcondition = component.get("v.checkfileuploadcondition");
        component.set("v.showToast",true);
        // Validation
        this.validateDocuments(component,docList);
        /*var isFileTypeSelected = true;
        for(var index = 0; index < docList.length; index++){
            if(docList[index].Core_MDF_Proof_of_Cost__c || docList[index].Core_MDF_Proof_of_Branding__c || docList[index].Core_MDF_Proof_of_Execution__c){
                
            }else{
                isFileTypeSelected = false;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message : $A.get("$Label.c.Core_MDF_Manage_Document_Error_Message"),                  
                    duration:'5000',
                    key: 'info_alt',
                    type: 'error'
                });
                toastEvent.fire();
                break;
            }
        }*/
      
        if(component.get("v.isFileUploadOnClaimCreation")){
           // console.log("isFileTypeSelected" + isFileTypeSelected);
            //check for if any doc type is selected
            if(component.get("v.isFileTypeSelected")){  
                //Close the doc selection modal
                component.set("v.isOpen",false);
                
            }
            else{
                component.set("v.isOpen",true);
            } 
            component.set("v.checkfileuploadcondition",true);
            
        }else{
            //Calling Server method to update Audit Documents
            if(component.get("v.isFileTypeSelected")){            
                var action = component.get("c.updateAuditDocument");
                var isInsert = component.get("v.isInsert");
                //Setting the Apex method Parameter
                action.setParams({auditDocList : docList});
                action.setCallback(this, function(res) {
                    var type;
                    var message='';
                    
                    var appRecId = component.get("v.recordId");
                    
                    if (!res.getReturnValue()) {
                        type = 'Success';                    
                        message = $A.get("$Label.c.Core_MDF_Manage_Document_Success_Message");
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": appRecId,
                            "slideDevName": "related"
                        });			
                        
                    }
                    else {
                        type = 'error';
                        message = $A.get("$Label.c.Core_MDF_Manage_Document_Exception_Error_Message");
                        component.set("v.isEnableCancel", true);                    
                    }
                    
                    //Display message 				
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: message,
                        duration:'3000',
                        key: 'info_alt',
                        type: type
                    });
                    toastEvent.fire();
                    var isSaveAndCloseClicked = component.get("v.isSaveAndCloseClicked");               
                    if(!res.getReturnValue() && isSaveAndCloseClicked){
                        navEvt.fire();
                        //Added by Shridhar to fix DE40941                    
                        setTimeout(function(){window.location.reload();},2000);                    
                    }
                });
                $A.enqueueAction(action);
            }            
        }
  
    }, 
    
    //Case Staus Will be Set to Under Review
    //SLA Start Date will be set current date 
    updateObjectAndDocument : function(component, event, helper) {
        var recId = component.get("v.recordId");
        var docList = component.get("v.auditDocument");
        var checkfileuploadcondition = component.get("v.checkfileuploadcondition");
        var isFileUploadOnClaimCreation = component.get("v.isFileUploadOnClaimCreation");
        component.set("v.showToast",true);
        // Validation
        this.validateDocuments(component,docList);
        //alert('isFileTypeSelected' +isFileTypeSelected);
        /*var isFileTypeSelected = true;
        for(var index = 0; index < docList.length; index++){
            if(docList[index].Core_MDF_Proof_of_Cost__c || docList[index].Core_MDF_Proof_of_Branding__c || docList[index].Core_MDF_Proof_of_Execution__c){
                
            }else{
                isFileTypeSelected = false;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message : $A.get("$Label.c.Core_MDF_Manage_Document_Error_Message"),                  
                    duration:'5000',
                    key: 'info_alt',
                    type: 'error'
                });
                toastEvent.fire();
                break;
            }
        } */   
                        
        if(component.get("v.isFileTypeSelected")){               
            
            var action = component.get("c.updateObjectAndDocuments");
            //Setting the Apex method Parameter            
            action.setParams({recordId : recId,auditDocList:docList});
            action.setCallback(this, function(res) {
                var state = res.getState();
                var type;
                var message='';
                
                var appRecId = component.get("v.recordId");
                if (!res.getReturnValue()) {
                    type = 'Success';  
                    message = $A.get("$Label.c.Core_MDF_Manage_Document_Submit_Success_Message"); 
                  
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": recId,
                        "slideDevName": "related"
                    });
                    
                }
                else {
                    type = 'error';
                    message = $A.get("$Label.c.Core_MDF_Manage_Document_Exception_Error_Message");
                    component.set("v.isEnableCancel", true);
                    
                }
                
                //Display message 				
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: message,
                    duration:'5000',
                    key: 'info_alt',
                    type: type
                });
                toastEvent.fire();
                if (!res.getReturnValue()){
                    
                    navEvt.fire();
                    //Added by Shridhar to fix DE40941
                    setTimeout(function(){window.location.reload();},2000);
                    }                	           
            });
            $A.enqueueAction(action);
        }
    },
    
    //This function will download all the POP documents
    autoDownload : function(component, event) {
        var docList = component.get("v.auditDocument"); 
        var sObjectWrapper = component.get("v.sObjectDocumentWrapper");  
        var listOfId = '';
        for(var index = 0; index < docList.length; index++){
                        
            var downloadURL = '';
            if(sObjectWrapper.isPartner){
                downloadURL = $Label.c.Core_MDF_PFRCommunityLink+'/sfc/servlet.shepherd/document/download/'+docList[index].Core_MDF_Document_Id__c +'?operationContext=S1';
            }
			else{
                downloadURL = '/sfc/servlet.shepherd/document/download/'+docList[index].Core_MDF_Document_Id__c +'?operationContext=S1';
            }
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": downloadURL
    		});
    		urlEvent.fire();
        }
    },
    
    updateMessageOnCase : function(component, event, helper) {
        var inputField = component.find('txtarea');
        var recId = component.get("v.recordId");
        var submitterComment = component.get("v.claimSubmitterMessage");
        
        if(submitterComment.length>255){
            inputField.setCustomValidity($A.get("$Label.c.Core_MDF_CharacterLimitExceedsErrorMSg"));
            inputField.reportValidity();
        }
        else{          
            component.set("v.loaded", false);
            var action = component.get("c.updateClaimSubmitterMsg");
            //Setting the Apex method Parameter            
            action.setParams({recordId : recId,submitterMessage:submitterComment});
            action.setCallback(this, function(res) {
                var state = res.getState();
                var type;
                var message='';
                 component.set("v.loaded",true);
                if(res.getReturnValue() && state=='SUCCESS') {
                    type = 'Success';  
                    message = $A.get("$Label.c.Core_MDF_Manage_Document_Success_Message");                
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": recId,
                    });				 
                }               
                else {
                    type = 'error';
                    message = $A.get("$Label.c.Core_MDF_Manage_Document_Exception_Error_Message");                    
                }
                
                //Display message 				
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: message,
                    duration:'5000',
                    key: 'info_alt',
                    type: type
                });
                toastEvent.fire();
               
                if (res.getReturnValue()){
                    navEvt.fire();
                    setTimeout(function(){window.location.reload();},5000);
                }                	           
            });
            $A.enqueueAction(action);        
        }
    },
    
 deleteDocs : function (component,docIds,documentids)
    {
        
        if(component.get("v.isFileUploadOnClaimCreation")){
            
        var action = component.get("c.deleteDocumentIds");
        
        action.setParams({
            		docIds: docIds
                });    
        
        action.setCallback(this, function(response) {
            var state = response.getState();
           
            if(state === 'SUCCESS'){
               
            var documents = component.get("v.auditDocument");
            documents.splice(documentids, 1);
            component.set("v.auditDocument", documents);
            if(documents.length == 0){
                component.set("v.isManageDocEnabled",false);
            }
          // alert('after filtered docs are  '+JSON.stringify(component.get("v.auditDocument")));
                       
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
    },
    
    validateDocuments: function(component,docsList){
        var toShowMessage = false;
        // Validation
        for(var index = 0; index < docsList.length; index++){
            if(docsList[index].Core_MDF_Proof_of_Cost__c || docsList[index].Core_MDF_Proof_of_Branding__c || docsList[index].Core_MDF_Proof_of_Execution__c){
                if(toShowMessage == false){
                    component.set("v.checkDocTypeSelected",false);
                    component.set("v.isFileTypeSelected", true); 
                }    
            }else{
                component.set("v.isFileTypeSelected", false);
                if(!component.get("v.showToast")){
                    component.set("v.checkDocTypeSelected",true);
                    toShowMessage = true;
                }
                if(component.get("v.showToast")){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message : $A.get("$Label.c.Core_MDF_Manage_Document_Error_Message"),                  
                        duration:'5000',
                        key: 'info_alt',
                        type: 'error'
                    });
                    toastEvent.fire();
                    break; 
                }
            }
        }
    },
    
    /* onCloseValidateDocuments: function(component,docsList){
    var fileTypeSelected ;
     for(var index = 0; index < docsList.length; index++){
          if(docsList[index].Core_MDF_Proof_of_Cost__c || docsList[index].Core_MDF_Proof_of_Branding__c || docsList[index].Core_MDF_Proof_of_Execution__c){
                fileTypeSelected =true; 
          }
          else{
                 fileTypeSelected =false;
                 var toastEvent = $A.get("e.force:showToast");
                 toastEvent.setParams({
                 message : $A.get("$Label.c.Core_MDF_Manage_Document_Error_Message"),                  
                 duration:'5000',
                 key: 'info_alt',
                 type: 'error'
                 });
                 toastEvent.fire();
                 break;  
          }
      }
        if(fileTypeSelected){  
                //Close the doc selection modal
                component.set("v.isOpen",false);
            }
            else{
                component.set("v.isOpen",true);
            } 
   }*/
})