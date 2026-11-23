({
    initiateComponent : function(component, event){ 
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.userInfo",userId);
        
        var recId = component.get("v.recordId");
        
        //Setting File formats
        var fileFormats = $A.get("$Label.c.Core_MDF_AllowedFileTypes").split(',');                          
        component.set("v.accept", fileFormats); 
        
        /*
        var isProofOfCostUploaded = false;
        var isProofOfBrandingUploaded = false;
        var isProofOfExcecutionUploaded = false;*/
        
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
                            //if(docList[index].Core_MDF_Proof_of_Cost__c != true && docList[index].Core_MDF_Proof_of_Branding__c != true && docList[index].Core_MDF_Proof_of_Execution__c != true){
                            if(docList[index].Core_MDF_Document_Types__c == null){
                                untaggedDoc.push(docList[index]);    
                            }
                            
                            //Check all the file types are uploaded
                            /* if(docList[index].Core_MDF_Proof_of_Cost__c){
                                isProofOfCostUploaded = true;*/
                            if(docList[index].Core_MDF_Document_Types__c != null){
                                this.getDocName(component,event,docList);
                            }
                            /*
                            if(docList[index].Core_MDF_Proof_of_Branding__c){
                                isProofOfBrandingUploaded = true;
                            }
                            if(docList[index].Core_MDF_Proof_of_Execution__c){
                                isProofOfExcecutionUploaded = true;
                            }  */                                                
                        }                                                
                    }
                    /*
                    if(isProofOfCostUploaded){
                        component.set("v.isProofOfCostUploaded",true);
                    }
                    if(isProofOfBrandingUploaded){
                        component.set("v.isProofOfBrandingUploaded",true);
                    }
                    if(isProofOfExcecutionUploaded){
                        component.set("v.isProofOfExcecutionUploaded",true);
                    } */
                    
                    /*
                    if(isProofOfCostUploaded && isProofOfBrandingUploaded && isProofOfExcecutionUploaded){
                        component.set("v.isSubmitEnabled",true);
                    }*/
                    
                    if(untaggedDoc.length > 0){
                        component.set("v.auditDocument",untaggedDoc);
                        //component.set("v.isOpen",true);                        
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
                                   'Core_MDF_Document_Id__c':uploadedFiles[index].documentId,
                                   'Core_MDF_Document_Types__c':'',
                                   'Core_MDF_App_Document_Types_nm__c':''});
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
            console.log("v.sObjectDocumentWrapper", component.get("v.sObjectDocumentWrapper"));
            this.getDocName(component,event, auditDocList);
            
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
                            this.getDocName(component,event, docList);
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
        var docTypeNamesArray = component.get("v.docTypeName");
        var docTypeNames = docTypeNamesArray.join(';');
        console.log("docTypeNames:"+docTypeNames);
        // Get the Document List Uploaded by the User 
        var docList = component.get("v.auditDocument");
        console.log("docList::",component.get("v.auditDocument"));
        var docIdAndTypeOfList = event.getSource().get('v.name').split(";#");
        console.log("line 235: ",event.getSource().get('v.name').split(";#"));
        var docTypeArray = component.get("v.typeOfDocument");
        console.log("type of Doc :",component.get("v.typeOfDocument"));
        
        // Based on the selection we will populate the docList ::
        // typeofDoc attribute contains the JSON with the selections made by the user 
        // If the User uploaded any document: 
        /*var isProofOfCostUploaded = component.get("v.isProofOfCostUploaded");
        var isProofOfBrandingUploaded = component.get("v.isProofOfBrandingUploaded");
        var isProofOfExcecutionUploaded = component.get("v.isProofOfExcecutionUploaded");
        
        if(isManageButtonClicked){
            isProofOfCostUploaded = false;
            isProofOfBrandingUploaded = false;
            isProofOfExcecutionUploaded = false;             
        }*/
        //var indexvar = event.getSource().get("v.value");
        /*
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
            } 
        });           
        $A.enqueueAction(action);
    }*/
        if(docList != null){ 
            var selectedDocumentTypesArray = [];
            // Loop over the documents uploaded 
            for(let docIndex in docList){
                // assign the already selected doc types or initialize as blank
                selectedDocumentTypesArray = (docList[docIndex].Core_MDF_Document_Types__c != '') ? docList[docIndex].Core_MDF_Document_Types__c.split(';'):[];
                // assign the available doc types for all documents
                docList[docIndex].Core_MDF_App_Document_Types_nm__c = docTypeNames;
                // loop on the doctypes based on the Type Of Doc JSON 
                for(let docTypeIndex in docTypeArray){
                    // match the docId from docList with the events docId 
                    if(docList[docIndex].Core_MDF_Document_Id__c == docIdAndTypeOfList[0]){
                        // match the value as well as the docType from the typeOfDoc JSON
                        if(docTypeArray[docTypeIndex].Value == true && docTypeArray[docTypeIndex].DocName == docIdAndTypeOfList[1]){
                            selectedDocumentTypesArray.push(docTypeArray[docTypeIndex].DocName);
                        }else if(docTypeArray[docTypeIndex].Value == false && docTypeArray[docTypeIndex].DocName == docIdAndTypeOfList[1]){
                            selectedDocumentTypesArray.splice(selectedDocumentTypesArray.indexOf(docTypeArray[docTypeIndex].DocName),1);
                        }
                    }
                }
                docList[docIndex].Core_MDF_Document_Types__c = selectedDocumentTypesArray.join(';');
                console.log('doc types selected for doc:' +docIndex+':'+ docList[docIndex].Core_MDF_Document_Types__c);
                console.log('doc types Avail for doc:' +docIndex+':'+docList[docIndex].Core_MDF_App_Document_Types_nm__c);
            }
        }
        
        // Handle the enablement of Submit button when all types of documents are selected 
        var flag = 0;
        var docTypesNotToBeCompared=[];
        for(let docs in docList){
            for(let docTypes in docTypeNamesArray){
                if(docList[docs].Core_MDF_Document_Types__c.includes(docTypeNamesArray[docTypes])
                   && (!docTypesNotToBeCompared.includes(docTypeNamesArray[docTypes])  
                       || docTypesNotToBeCompared.length == 0))
                {
                    flag++;
                    docTypesNotToBeCompared.push(docTypeNamesArray[docTypes]);
                }
            }
        }
        if(flag == docTypeNamesArray.length){
            component.set("v.isSubmitEnabled",true);
        }else{component.set("v.isSubmitEnabled",false);}
        console.log('Submit button Enabled:'+component.get("v.isSubmitEnabled"));
        
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
            //if(docsList[index].Core_MDF_Proof_of_Cost__c || docsList[index].Core_MDF_Proof_of_Branding__c || docsList[index].Core_MDF_Proof_of_Execution__c){
            if(docsList[index].Core_MDF_Document_Types__c != null){ 
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
   
    getDocName: function(component,event,docList){
        
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var budgetType = component.get("v.budgetType");
        console.log('budgetType ::', budgetType);
        var recId = component.get("v.recordId");
        console.log('recId ::', recId);
        var pfcRTName = component.get("v.sObjectDocumentWrapper.pfcRec.Core_MDF_Program__c");
        var cseProgramName = component.get("v.sObjectDocumentWrapper.cseRec.Core_MDF_Channel_Program_txt__c");
        var actBudType = component.get("v.sObjectDocumentWrapper.pfcRec.Request.Core_MDF_Budget_Type_txt__c");
        var cseBudType = component.get("v.sObjectDocumentWrapper.cseRec.Core_MDF_Budget_Type_Txt__c");
        console.log('actBudType ::', actBudType);
        console.log('cseBudType ::', cseBudType);
        //console.log('clmBudType ::', clmBudType);
        if(docList != null){
            for(let index in docList){
                var docTypesSelected = docList[index].Core_MDF_Document_Types__c;
                component.set("v.docTypesSelected",docTypesSelected)
                console.log('docTypesSelectedingetDocName::',docTypesSelected);
            }
        }
        
        if(recId == null && budgetType != null){
            console.log('1');
            this.getDocNamesBasedOnProgOrBudget(component,event, null,recordTypeDeveloperName,budgetType);    
        }
        if(recId == null && budgetType == null){
            console.log('2');
            this.getDocNamesBasedOnProgOrBudget(component,event, null,recordTypeDeveloperName,null);    
        }
        if(pfcRTName != null && actBudType != null){
            console.log('3');
            // component.set("v.recordtypeDeveloperName",pfcRTName);
            this.getDocNamesBasedOnProgOrBudget(component,event, recId,pfcRTName,actBudType);   
        }
        if(pfcRTName != null && actBudType == null){
            console.log('4');
            // component.set("v.recordtypeDeveloperName",pfcRTName);
            this.getDocNamesBasedOnProgOrBudget(component,event, recId,pfcRTName,null);
        }
        if(cseProgramName != null && cseBudType != null){
            console.log('5');
            // component.set("v.recordtypeDeveloperName",cseProgramName);
            this.getDocNamesBasedOnProgOrBudget(component,event, recId,cseProgramName,cseBudType);
        }
        if(cseProgramName != null && cseBudType == null){
            console.log('6');
            //component.set("v.recordtypeDeveloperName",cseProgramName);
            this.getDocNamesBasedOnProgOrBudget(component,event, recId,cseProgramName,null); 
        }
        //  $A.enqueueAction(action);        
    },
    
    getDocNamesBasedOnProgOrBudget: function(component,event,recordId1,recData1,budType1){
        console.log('recordId1',recordId1);
        console.log('recData1',recData1);
        console.log('budType1',budType1);
        var typeOfDoc = [];
        var docName = [];
        var documentType =[];
        var metadata = [];
        var metadataresult;
        var apiName = [];
        var docTypesSelected = component.get("v.docTypesSelected");
        console.log('docTypesSelected@659',docTypesSelected);
        var action = component.get("c.fetchMetaDataRecords");
        action.setParams({recordId : recordId1, recData : recData1, budType : budType1});
        action.setCallback(this, function(response) {
            metadataresult = response.getReturnValue(); 
            component.set("v.metadataWrapper",metadataresult);
            var mdtWrpr = component.get("v.metadataWrapper");
            var metadata = JSON.stringify(mdtWrpr);
            console.log('metadataresult',metadataresult);
            if(metadataresult != null){
                for(var dt in metadataresult.metadataWrapperList){
                    console.log('Includes:'+docTypesSelected.includes(metadataresult.metadataWrapperList[dt].Core_MDF_Document_Type_nm__c));
                    if(docTypesSelected != null && docTypesSelected.includes(metadataresult.metadataWrapperList[dt].Core_MDF_Document_Type_nm__c)){
                        var todJSON = {'DocName':metadataresult.metadataWrapperList[dt].Core_MDF_Document_Type_nm__c,
                                       'Value':true
                                      }
                        //documentType.push(metadataresult.metadataWrapperList[dt].Core_MDF_Document_Type_nm__c);
                        }else{
                            var todJSON = {'DocName':metadataresult.metadataWrapperList[dt].Core_MDF_Document_Type_nm__c,
                                           'Value':false   
                                          }
                            //docName.push(metadataresult.metadataWrapperList[dt].Core_MDF_Document_Type_nm__c);
                            }
                    typeOfDoc.push(todJSON);
                    docName.push(metadataresult.metadataWrapperList[dt].Core_MDF_Document_Type_nm__c);
                }
                if(typeOfDoc != null){
                    component.set("v.typeOfDocument",typeOfDoc);
                    console.log("type of Doc:",typeOfDoc);
                }
                /* if(documentType!= null){
                    component.set("v.documentType1",documentType);
                    console.log("documentType:" , documentType);
                }*/
                if(docName!= null){
                    component.set("v.docTypeName",docName);
                    console.log("docName:" , docName);
                }
                /*if(apiName!= null){
                    component.set("v.apiName",apiName);
                    
                }*/
            }
        });   
        $A.enqueueAction(action);
    },
})