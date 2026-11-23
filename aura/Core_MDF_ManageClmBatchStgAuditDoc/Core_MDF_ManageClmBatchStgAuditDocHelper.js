({
    initiateComponent: function (component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.userInfo", userId);
        var recId = component.get("v.recordIdForPop");
        //Setting File formats
        var fileFormats = $A.get("$Label.c.Core_MDF_AllowedFileTypes").split(",");
        component.set("v.accept", fileFormats);

        var docList = [];
        var auditDoc = component.get("v.auditDocument");
        var untaggedDoc = [];
        var action = component.get("c.getAuditDocuments");
        
        action.setParams({ recordId: recId, documentIdWithTitle: null });
        action.setCallback(this, function (res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                component.set("v.isResponseReceived", true);
                var sObjectWrapper = res.getReturnValue();
                var editClaim = component.get('v.editClaimId');
                
                if (sObjectWrapper != null || (!$A.util.isUndefinedOrNull(auditDoc) && auditDoc.length > 0)){
                    if (sObjectWrapper != null){
                        component.set("v.sObjectDocumentWrapper", sObjectWrapper);
                    }

                    if(!$A.util.isUndefinedOrNull(auditDoc) && auditDoc.length > 0){
                        docList = docList.concat(auditDoc);
                        console.log('docs '+docList);
                        component.set("v.checkfileuploadcondition", true);
                    }
                    else{
                        docList = sObjectWrapper.documentList;
                        //NP - Fix for file upload not loading on init
                        if(editClaim != null && docList.length > 0){
							component.set("v.checkfileuploadcondition", true);
                    	}
                    }

                    component.set("v.auditDocument", docList);                    
                    if (docList != null) {                        
                        // Existing documents are stored in existingDocList
                        component.set("v.existingDocList",docList);
                        
                        // calling the getDocName function
                        this.getDocName(component, event, docList); 
                        window.setTimeout(
                            $A.getCallback(function() {
                                helper.getDocListOnLoadOfPage(component, event, docList);
                            }),3000
                        );                       
                    }
                                        
                }
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: $A.get(
                        "$Label.c.Core_MDF_Manage_Document_Exception_Error_Message"
                    ),
                    duration: "5000",
                    key: "info_alt",
                    type: "error"
                });
                console.log("a1");
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        console.log('1');
    },
    
    getDocListOnLoadOfPage : function(component,event ,docList){
        // Getting the Required document types for POP Submission
        var reqDocTypesForEnablingSubmitBtn = component.get("v.reqDocTypesForEnablingSubmitBtn"); 
        var reqDocTypeNamesArray = component.get("v.reqDocNameList");
        var docTypesNotToBeCompared = [];
        var flag = 0;
        var testFlag = 0;
        var untaggedDoc = [];
        var docTypeNamesArray = component.get("v.docTypeName"); // Getting the applicable document types
        //console.log("test::" + !$A.util.isUndefinedOrNull(docTypeNamesArray));
        if(!$A.util.isUndefinedOrNull(docTypeNamesArray)){
            var docTypeNames = docTypeNamesArray.join(";");
        }
        var isFileDeleted = component.get("v.isfileDeleted");
		/*var savenc = component.get("v.isSaveAndCloseClicked");
        var save1 = component.get("v.isDocSave");
        console.log('Save',save1);        
        console.log('Save and Close',savenc);*/
        
        if(docList != null && !$A.util.isUndefinedOrNull(docTypeNamesArray)){
            console.log('doc list is '+docList);
            for (let index in docList) {
                console.log("Core_MDF_Document_Types__c::" , docList[index].Core_MDF_Document_Types__c.length);
                if (($A.util.isUndefinedOrNull(docList[index].Core_MDF_Document_Types__c) || docList[index].Core_MDF_Document_Types__c.length == 0) && isFileDeleted == false) {
                    untaggedDoc.push(docList[index]);
                    docList[index].Core_MDF_App_Document_Types_nm__c = docTypeNames;
                    docList[index].Core_MDF_Document_Types__c = [];
                    console.log('Core_MDF_App_Document_Types_nm__c '+ docList[index].Core_MDF_App_Document_Types_nm__c);
                }
                //Check all the file types are uploaded
                //console.log("doc len::" , docList[index].Core_MDF_Document_Types__c.length);
                if (!$A.util.isUndefinedOrNull(docList[index].Core_MDF_Document_Types__c) && docList[index].Core_MDF_Document_Types__c.length > 0 && isFileDeleted == false) {
                    //console.log('inside if');  
                    //console.log('reqDocTypesForEnablingSubmitBtn1::',component.get("v.reqDocTypesForEnablingSubmitBtn"));  
                    // Loop over the required document types for claim submission
                    for (let docTypes in reqDocTypesForEnablingSubmitBtn) {

                        if (docList[index].Core_MDF_Document_Types__c.includes(reqDocTypesForEnablingSubmitBtn[docTypes]) &&
                            (!docTypesNotToBeCompared.includes(reqDocTypesForEnablingSubmitBtn[docTypes]) ||
                             docTypesNotToBeCompared.length == 0)
                           ) {
                            //console.log('inside for');
                            flag++;
                            docTypesNotToBeCompared.push(reqDocTypesForEnablingSubmitBtn[docTypes]);
                        }
                    } 
                }
                if(isFileDeleted && !$A.util.isUndefinedOrNull(reqDocTypeNamesArray) && reqDocTypeNamesArray.length >0){
                    // Loop over the required document types for claim submission
                    for (let docTypes in reqDocTypeNamesArray) {
                        if (docList[index].Core_MDF_Document_Types__c.includes(reqDocTypeNamesArray[docTypes]) &&
                            (!docTypesNotToBeCompared.includes(reqDocTypeNamesArray[docTypes]) ||
                             docTypesNotToBeCompared.length == 0)
                           ) {
                            testFlag++;
                            docTypesNotToBeCompared.push(reqDocTypeNamesArray[docTypes]);
                        }
                    }
                    // comparing the flag value with required document types for claim creation length
                    if (testFlag == reqDocTypeNamesArray.length) {
                        component.set("v.isSaveEnabled", true);
                    } else {
                        component.set("v.isSaveEnabled", false);
                    } 
                    console.log("Save button Enabled@:" + component.get("v.isSaveEnabled"));
                }
            }
        }
        //console.log("untaggedDoc@:" , untaggedDoc.length);
        // Condition to open modal if document type is not selected
        if (!$A.util.isUndefinedOrNull(untaggedDoc) && untaggedDoc.length > 0) {
            component.set("v.auditDocument", untaggedDoc);
            component.set("v.isOpen",true);
        }
        //console.log("reqDocTypesForEnablingSubmitBtn@:" , reqDocTypesForEnablingSubmitBtn.length);
        // Condition for enabling submit button
        if (!$A.util.isUndefinedOrNull(reqDocTypesForEnablingSubmitBtn) && reqDocTypesForEnablingSubmitBtn.length > 0) {
            console.log('inside if cond');
            if (flag == reqDocTypesForEnablingSubmitBtn.length) {
                component.set("v.isSubmitEnabled", true);                
            } else {
                component.set("v.isSubmitEnabled", false);
            }
            console.log("Submit button Enabledindoinit@:" + component.get("v.isSubmitEnabled"));
        }
        //console.log("docList@:" , docList.length);
        // Condition to enable manage documents button
        if (!$A.util.isUndefinedOrNull(docList) && docList.length > 0) {
            component.set("v.isManageDocEnabled", true);
        }
    },

    // On Susccessful upload Audit Document records will be created
    // isOpen attribute is set true, to open file selection model
    // Audit document will be updated once user click the save button.
    createObjectDocuments: function (component, event) {
        component.set("v.isEnableCancel", false);
        component.set("v.isInsert", true);
        component.set("v.isManageDocEnabled", true);
        // console.log("SAveCheck->>"+component.get("v.isDocSave"));
        
        
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.userInfo", userId);

        var uploadedFiles = event.getParam("files");

        var uploadedDocId = [];

        var auditDocList = [];
        if (component.get("v.auditDocument").length > 0) {
            auditDocList = auditDocList.concat(component.get("v.auditDocument"));
            // Existing documents are stored in existingDocList
            component.set("v.existingDocList",auditDocList);
        }
		
        var isFileUploadOnClaimCreation = component.get("v.isFileUploadOnClaimCreation");

        for (var index = 0; index < uploadedFiles.length; index++) {
            if (isFileUploadOnClaimCreation) {
                auditDocList.push({
                    sobjectType: "Core_MDF_Audit_Document__c",
                    Core_MDF_Document_Title__c: uploadedFiles[index].name,
                    Core_MDF_Document_Id__c: uploadedFiles[index].documentId,
                    Core_MDF_Document_Types__c: "",
                    Core_MDF_App_Document_Types_nm__c: ""
                });
                //console.log("auditDocList" + JSON.stringify(auditDocList));
                component.set("v.contentdocumentids", uploadedFiles[index].documentId);
            } else {
                uploadedDocId.push(
                    uploadedFiles[index].documentId + ";#" + uploadedFiles[index].name
                );
            }
        }

        //Set Audit Documents which are uploaded from Claim Creation
        if (isFileUploadOnClaimCreation) {
            component.set("v.auditDocument", auditDocList);
            component.set("v.isOpen", true);
            // Setting the value to true, if the file is uploaded from claim creation
            component.set("v.fileOnClaimCreationSide",true); 
            // calling the getDocName function
            this.getDocName(component, event, auditDocList);
        } else {
            var documents = component.get("v.contentdocumentids");
            component.set("v.contentdocumentids", uploadedDocId);
            var recId = component.get("v.recordIdForPop");
            var docList;
            var action = component.get("c.getAuditDocuments");
            action.setParams({ recordId: recId, documentIdWithTitle: uploadedDocId });
            action.setCallback(this, function (res) {
                var state = res.getState();
                if (state === "SUCCESS") {
                    component.set("v.isResponseReceived", true);
                    var sObjectWrapper = res.getReturnValue();
                    if (sObjectWrapper != null) {
                        component.set("v.sObjectDocumentWrapper", sObjectWrapper);
                        docList = sObjectWrapper.documentList;
                        component.set("v.auditDocument", docList);
                        if (docList != null) {
                            component.set("v.auditDocument", docList);
                            console.log('@@docList'+docList);
                            // calling the getDocName function
                            this.getDocName(component, event, docList);
                            component.set("v.isOpen", true);
                        }
                    }
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: $A.get("$Label.c.Core_MDF_Manage_Document_Error_Message"),
                        duration: "5000",
                        key: "info_alt",
                        type: "error"
                    });
                }
            });
            $A.enqueueAction(action);
        }
    },

    // Enable/Disble submit button
    enableDisableSubmitButton: function (component, event) {
        var isSubmitEnabled = component.get("v.isSubmitEnabled");
        // Getting the applicable document types
        var docTypeNamesArray = component.get("v.docTypeName");
        var docTypeNames = docTypeNamesArray.join(";");
        // Get the Required Document Types List for claim submission
        var reqDocTypeNamesArray = component.get("v.reqDocNameList");
        // Get the Required Document Types List for Enabling/Disabling Submit Button
        var reqDocTypesForEnablingSubmitBtn = component.get("v.reqDocTypesForEnablingSubmitBtn");
        // Get the Document List Uploaded by the User
        var docList = component.get("v.auditDocument");
        // Splitting the Document Id and Document Types
        var docIdAndTypeOfList = event.getParam("checkboxName").split(";#");
        // Getting the typeOfDocument values
        var docTypeArray = component.get("v.typeOfDocument");
        
        if (docList != null) {
            var selectedDocumentTypesArray = [];
            // Loop over the documents uploaded
            for (let docIndex in docList) {
                // assign the already selected doc types or initialize as blank
                selectedDocumentTypesArray = docList[docIndex].Core_MDF_Document_Types__c != "" ? docList[docIndex].Core_MDF_Document_Types__c.split(";") : [];
                // assign the applicable doc types for all documents
                docList[docIndex].Core_MDF_App_Document_Types_nm__c = docTypeNames;
                // loop on the doctypes based on the Type Of Doc JSON
                for (let docTypeIndex in docTypeArray) {
                    // match the docId from docList with the events docId
                    if (docList[docIndex].Core_MDF_Document_Id__c == docIdAndTypeOfList[0]) {
                        // match the value as well as the docType from the typeOfDoc JSON 
                        if (docTypeArray[docTypeIndex].Value == true && docTypeArray[docTypeIndex].DocName == docIdAndTypeOfList[1]) {
                            selectedDocumentTypesArray.push(docTypeArray[docTypeIndex].DocName);
                        } else if (
                            docTypeArray[docTypeIndex].Value == false &&
                            docTypeArray[docTypeIndex].DocName == docIdAndTypeOfList[1]
                        ) {
                            selectedDocumentTypesArray.splice(selectedDocumentTypesArray.indexOf(docTypeArray[docTypeIndex].DocName), 1);
                            // below condition is used to check whether Mandatory checkbox got unchecked or not
                            if(reqDocTypeNamesArray.length >0 && component.get("v.fileOnClaimCreationSide") == false){
                                component.set("v.isMandateDocsUnchecked",true);
                            }
                            console.log("isMandateDocsUnchecked :"+ component.get("v.isMandateDocsUnchecked"));
                        }
                    }
                }
                docList[docIndex].Core_MDF_Document_Types__c = selectedDocumentTypesArray.join(";");
            }
            component.set("v.auditDocument",docList);            
        }
        
        var flag = 0;
        var docTypesNotToBeCompared = [];
        // code for enabling save button on Claim creation page
        // loop on the docList
        for (let docs in docList) {
            if(reqDocTypeNamesArray.length >0){                
                // Loop over the required document types for claim submission
                for (let docTypes in reqDocTypeNamesArray) {
                    if (docList[docs].Core_MDF_Document_Types__c.includes(reqDocTypeNamesArray[docTypes]) &&
                        (!docTypesNotToBeCompared.includes(reqDocTypeNamesArray[docTypes]) ||
                         docTypesNotToBeCompared.length == 0)
                       ) {
                        flag++;
                        docTypesNotToBeCompared.push(reqDocTypeNamesArray[docTypes]);
                    }
                }
                // comparing the flag value with required document types for claim creation length
                if (flag == reqDocTypeNamesArray.length) {
                    component.set("v.isSaveEnabled", true);
                } else {
                    component.set("v.isSaveEnabled", false);
                } 
                console.log("Save button Enabled@:" + component.get("v.isSaveEnabled"));
            }
        }
        console.log("fileOnClaimCreationSide@ :"+ component.get("v.fileOnClaimCreationSide"));
        
        // Checking if it is from claim creation side or not
        if (component.get("v.fileOnClaimCreationSide") == false) {
            var existingDocList = docList.concat(component.get("v.existingDocList"));
            // Handle the enablement of Submit button when all types of documents are selected
            for (let docs in existingDocList) {                
                // Loop over the required document types for POP submission
                for (let docTypes in reqDocTypesForEnablingSubmitBtn) {
                    if (existingDocList[docs].Core_MDF_Document_Types__c.includes(reqDocTypesForEnablingSubmitBtn[docTypes]) &&
                        (!docTypesNotToBeCompared.includes(reqDocTypesForEnablingSubmitBtn[docTypes]) ||
                         docTypesNotToBeCompared.length == 0)
                       ) {
                        flag++;
                        docTypesNotToBeCompared.push(reqDocTypesForEnablingSubmitBtn[docTypes]);
                        console.log("docTypesNotToBeCompared:", docTypesNotToBeCompared);
                        console.log("flag for submit:", flag);
                    }
                }
            }   
            // comparing the flag value with required document types for POP submission length
            if (reqDocTypesForEnablingSubmitBtn.length > 0) {
                if (flag == reqDocTypesForEnablingSubmitBtn.length) {
                    component.set("v.isSubmitEnabled", true);
                } else {
                    component.set("v.isSubmitEnabled", false);
                }
                console.log("Submit button Enabled@:" + component.get("v.isSubmitEnabled"));
            }
        }
    },

    updateObjectDocuments: function (component, event, helper) {
        component.set("v.isEnableCancel", false);
        var recId = component.get("v.recordIdForPop");
        var docList = component.get("v.auditDocument");
        var checkfileuploadcondition = component.get("v.checkfileuploadcondition");
        var docTypeArray = component.get("v.typeOfDocument");
        component.set("v.showToast", true);
        // Validation
        this.validateDocuments(component, docList);
		if (component.get("v.isFileUploadOnClaimCreation")) {
            if (component.get("v.isFileTypeSelected")) {
                //Close the doc selection modal
                component.set("v.isOpen", false);
            } else {
                component.set("v.isOpen", true);
            }
            component.set("v.checkfileuploadcondition", true);
        } else {
            //Calling Server method to update Audit Documents
            if (component.get("v.isFileTypeSelected")) {
                if(component.get("v.isSubmitEnabled") == false && component.get("v.isMandateDocsUnchecked")){
                    component.set("v.isOpen", true);
                    var toastEvent = $A.get("e.force:showToast");
                    var message = $A.get("$Label.c.Core_MDF_Mandatory_DocTypes_Uncheck_Error_Message");
                    toastEvent.setParams({
                        message: message,
                        duration: "5000",
                        key: "info_alt",
                        type: "error"
                    });
                    toastEvent.fire();
                }else{
                    
                    var action = component.get("c.updateAuditDocument");
                    var isInsert = component.get("v.isInsert");
                    /*
                    //KS
                    for(let i =0 ; i<docList.length;i++){
                        if(docList.length>0 && docList != null && docList !='undefined')
                        docList[i].Core_MDF_Document_Upload_Status_txt__c="Document Saved";
                    }
                    console.log("KS->>"+JSON.stringify(docList));*/
                    
                    //Setting the Apex method Parameter
                    action.setParams({auditDocList: docList });
                    action.setCallback(this, function (res) {
                        var type;
                        var message = "";
                        
                        var appRecId = component.get("v.recordIdForPop");
                        if (!res.getReturnValue()) {
                            type = "Success";
                            message = $A.get(
                                "$Label.c.Core_MDF_Manage_Document_Success_Message"
                            );
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                recordId: appRecId,
                                slideDevName: "related"
                            });
                        } else {
                            type = "error";
                            message = $A.get(
                                "$Label.c.Core_MDF_Manage_Document_Exception_Error_Message"
                            );
                            console.log("a2");
                            component.set("v.isEnableCancel", true);
                        }
                        
                        //Display message
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            message: message,
                            duration: "3000",
                            key: "info_alt",
                            type: type
                        });
                        toastEvent.fire();
                        var isSaveAndCloseClicked = component.get("v.isSaveAndCloseClicked");
                        if (!res.getReturnValue() && isSaveAndCloseClicked) {
                            navEvt.fire();
                            //Added by Shridhar to fix DE40941
                            setTimeout(function () {
                                window.location.reload();
                            }, 2000);
                        }
                    });
                    $A.enqueueAction(action);
                }
            }
        }
        component.set("v.typeOfDocument",docTypeArray);
    },

    //Case Staus Will be Set to Under Review
    //SLA Start Date will be set current date
    updateObjectAndDocument: function (component, event, helper) {
        var recId = component.get("v.recordIdForPop");
        var docList = component.get("v.auditDocument");
        var checkfileuploadcondition = component.get("v.checkfileuploadcondition");
        var isFileUploadOnClaimCreation = component.get("v.isFileUploadOnClaimCreation");
        component.set("v.showToast", true);
        // Validation
        this.validateDocuments(component, docList);

        if (component.get("v.isFileTypeSelected")) {
            var action = component.get("c.updateObjectAndDocuments");
            /*
            //KS
                    for(let i =0 ; i<docList.length;i++){
                        if(docList.length>0 && docList != null && docList !='undefined')
                        docList[i].Core_MDF_Document_Upload_Status_txt__c="Document Submitted";
                    }
                    console.log("KS1->>"+JSON.stringify(docList));*/
            //Setting the Apex method Parameter
            action.setParams({ recordId: recId, auditDocList: docList });
            action.setCallback(this, function (res) {
                var state = res.getState();
                var type;
                var message = "";

                var appRecId = component.get("v.recordIdForPop");
                if (!res.getReturnValue()) {
                    type = "Success";
                    message = $A.get(
                        "$Label.c.Core_MDF_Manage_Document_Submit_Success_Message"
                    );

                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        recordId: recId,
                        slideDevName: "related"
                    });
                } else {
                    type = "error";
                    message = $A.get(
                        "$Label.c.Core_MDF_Manage_Document_Exception_Error_Message"
                    );
                    console.log("a3");
                    component.set("v.isEnableCancel", true);
                }

                //Display message
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: message,
                    duration: "5000",
                    key: "info_alt",
                    type: type
                });
                toastEvent.fire();
                if (!res.getReturnValue()) {
                    navEvt.fire();
                    //Added by Shridhar to fix DE40941
                    setTimeout(function () {
                        window.location.reload();
                    }, 2000);
                }
            });
            $A.enqueueAction(action);
        }
    },

    //This function will download all the POP documents
    autoDownload: function (component, event) {
        var docList = component.get("v.auditDocument");
        var sObjectWrapper = component.get("v.sObjectDocumentWrapper");
        var listOfId = "";
        for (var index = 0; index < docList.length; index++) {
            var downloadURL = "";
            if (sObjectWrapper.isPartner) {
                downloadURL =
                    $Label.c.Core_MDF_PFRCommunityLink +
                    "/sfc/servlet.shepherd/document/download/" +
                    docList[index].Core_MDF_Document_Id__c +
                    "?operationContext=S1";
            } else {
                downloadURL =
                    "/sfc/servlet.shepherd/document/download/" +
                    docList[index].Core_MDF_Document_Id__c +
                    "?operationContext=S1";
            }
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                url: downloadURL
            });
            urlEvent.fire();
        }
    },

    updateMessageOnCase: function (component, event, helper) {
        var inputField = component.find("txtarea");
        var recId = component.get("v.recordId");
        var submitterComment = component.get("v.claimSubmitterMessage");

        if (submitterComment.length > 255) {
            inputField.setCustomValidity(
                $A.get("$Label.c.Core_MDF_CharacterLimitExceedsErrorMSg")
            );
            inputField.reportValidity();
        } else {
            component.set("v.loaded", false);
            var action = component.get("c.updateClaimSubmitterMsg");
            //Setting the Apex method Parameter
            action.setParams({ recordId: recId, submitterMessage: submitterComment });
            action.setCallback(this, function (res) {
                var state = res.getState();
                var type;
                var message = "";
                component.set("v.loaded", true);
                if (res.getReturnValue() && state == "SUCCESS") {
                    type = "Success";
                    message = $A.get("$Label.c.Core_MDF_Manage_Document_Success_Message");
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        recordId: recId
                    });
                } else {
                    type = "error";
                    message = $A.get(
                        "$Label.c.Core_MDF_Manage_Document_Exception_Error_Message"
                    );
                    console.log("a4");
                }

                //Display message
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: message,
                    duration: "5000",
                    key: "info_alt",
                    type: type
                });
                toastEvent.fire();

                if (res.getReturnValue()) {
                    navEvt.fire();
                    setTimeout(function () {
                        window.location.reload();
                    }, 5000);
                }
            });
            $A.enqueueAction(action);
        }
    },

    deleteDocs: function (component, docIds, documentids) {
        if (component.get("v.isFileUploadOnClaimCreation")) {
            var action = component.get("c.deleteDocumentIds");

            action.setParams({
                docIds: docIds
            });

            action.setCallback(this, function (response) {
                var state = response.getState();

                if (state === "SUCCESS") {
                    var documents = component.get("v.auditDocument");
                    documents.splice(documentids, 1);
                    component.set("v.auditDocument", documents);
                    component.set("v.isfileDeleted", true);
                    if (documents.length == 0) {
                        component.set("v.isManageDocEnabled", false);
                    }
                    console.log('after filtered docs are  '+JSON.stringify(component.get("v.auditDocument")));
                    this.getDocListOnLoadOfPage(component, event, component.get("v.auditDocument"));
                } else if (state === "ERROR") {
                    if (
                        Array.isArray(response.getError()) &&
                        response.getError().length > 0
                    ) {
                        component.set("v.errormsg", response.getError()[0].message);
                        component.set("v.iserror", true);
                    }
                }
            });

            $A.enqueueAction(action);
        }
    },

    validateDocuments: function (component, docsList) {
        var toShowMessage = false;
        // Validation
        for (var index = 0; index < docsList.length; index++) {
            //if(docsList[index].Core_MDF_Proof_of_Cost__c || docsList[index].Core_MDF_Proof_of_Branding__c || docsList[index].Core_MDF_Proof_of_Execution__c){
            // checking if selected document types length is greater than 0 
            if (docsList[index].Core_MDF_Document_Types__c.length > 0) {
                if (toShowMessage == false) {
                    component.set("v.checkDocTypeSelected", false);
                    component.set("v.isFileTypeSelected", true);
                }
            } else {
                component.set("v.isFileTypeSelected", false);
                if (!component.get("v.showToast")) {
                    component.set("v.checkDocTypeSelected", true);
                    toShowMessage = true;
                }
                if (component.get("v.showToast")) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: $A.get("$Label.c.Core_MDF_Manage_Document_Error_Message"),
                        duration: "5000",
                        key: "info_alt",
                        type: "error"
                    });
                    toastEvent.fire();
                    break;
                }
            }
        }
    },

    getDocName: function (component, event, docList) {
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        console.log("recordTypeDeveloperName :"+recordTypeDeveloperName);
        var budgetType = component.get("v.budgetType");
        console.log("budgetType :"+budgetType);
        //budget type check to fetch error msg for Claim for CCF/DCF
        var  budgetTypeVal;
        
        /*if(budgetType ==  $A.get("$Label.c.Core_MDF_BudgetType_MDF") || budgetType ==  $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")){
            budgetTypeVal = budgetType;
        }else{
            budgetTypeVal = null;
        }*/
        
        var applBudTypes = $A.get("$Label.c.Core_MDF_ActivityBudgetTypesForAllocationCheck").split(";"); //MDF;MDF+
        if(applBudTypes.includes(budgetType)){	
            budgetTypeVal = budgetType;  
        }else{
            budgetTypeVal = null;
        }
        
        var recId = component.get("v.recordIdForPop");
        var sObjectType = component.get("v.sobjectType");
        var pfcRTName = component.get("v.sObjectDocumentWrapper.pfcRec.Core_MDF_Program__c");
        var cseProgramName = component.get("v.sObjectDocumentWrapper.cseRec.Core_MDF_Channel_Program_txt__c");
        var actBudType = component.get("v.sObjectDocumentWrapper.pfcRec.Core_MDF_Budget_Type_Nm__c");
        var cseBudType = component.get("v.sObjectDocumentWrapper.cseRec.Core_MDF_Budget_Type_Txt__c");
       // Below condition is used to check if recordId is null
        // Claim creation side
        if ($A.util.isUndefinedOrNull(recId) ) {
           this.getDocNamesBasedOnProgOrBudget(component, event, null, recordTypeDeveloperName, budgetTypeVal);
        }
        // for bulk claim
        if(sObjectType == 'Core_MDF_Claim_Batch_Stage__c'){
            this.getDocNamesBasedOnProgOrBudget(component, event, recId, recordTypeDeveloperName, budgetTypeVal);
        }
        // Below condition is used to check if Claim's Program is not null
        // Claim details side
        if (pfcRTName != null) {
            this.getDocNamesBasedOnProgOrBudget(component, event, recId, pfcRTName, null);
        }
        // Below condition is used to check if Case's Program is not null
        // Case details side
        if (cseProgramName != null) {
            this.getDocNamesBasedOnProgOrBudget(component, event, recId, cseProgramName, null);
        }
    },

    // Function called to fetch the document types from metadata
    getDocNamesBasedOnProgOrBudget: function (component, event, recordId1, recData1, budType1) {
        var typeOfDoc = [];
        var docName = [];
        var metadata = [];
        var metadataresult;
        var reqDocName = [];
        var reqDocTypeName = [];
        var reqDocsForSubmitBtn = [];
        var action = component.get("c.fetchMetaDataRecords");
        action.setParams({recordId: recordId1, recData: recData1, budType: budType1});
        action.setCallback(this, function (response) {
            metadataresult = response.getReturnValue();
            //component.set("v.metadataWrapper", metadataresult);
            var mdtWrpr = component.get("v.metadataWrapper");
            var metadata = JSON.stringify(mdtWrpr);
            if (metadataresult != null) {
                for (var dt in metadataresult.metadataWrapperList) { 
                    // Preparing a wrapper with DocumentType Label, Document Type and Value
                    var todJSON = {
                        DocNameLabel: metadataresult.metadataWrapperList[dt].Document_Type_Label,
                        DocName: metadataresult.metadataWrapperList[dt].Core_MDF_Document_Type_nm__c,
                        Value: false
                    };
                    typeOfDoc.push(todJSON);
                    docName.push(metadataresult.metadataWrapperList[dt].Core_MDF_Document_Type_nm__c);
                    // Checking the required doc types for claim submission
                    if (metadataresult.metadataWrapperList[dt].Core_MDF_Req_Doc_Types_ind__c == true) {
                        reqDocName.push(metadataresult.metadataWrapperList[dt].Document_Type_Label);
                        reqDocTypeName.push(metadataresult.metadataWrapperList[dt].Core_MDF_Document_Type_nm__c);
                    }
                    // Checking the required doc types for POP submission
                    if (metadataresult.metadataWrapperList[dt].Core_MDF_ReqforPOPSubmission_ind__c == true) {
                        reqDocsForSubmitBtn.push(metadataresult.metadataWrapperList[dt].Core_MDF_Document_Type_nm__c);
                    }
                }
                if (typeOfDoc != null) {
                    component.set("v.typeOfDocument", typeOfDoc);
                }
                if (docName != null) {
                    // Applicable document types are stored in docTypeName
                    component.set("v.docTypeName", docName);
                    //console.log('docTypeName !@:',component.get("v.docTypeName"));
                }
                if (reqDocName != null) {
                    // Required document types are stored in reqDocName with semicolon separated
                    var reqDocTypeNames = reqDocName.join('; ');
                    component.set("v.reqDocName", reqDocTypeNames);
                }
                if (reqDocTypeName != null) {
                    // Required document types list for claim submission are stored in reqDocNameList
                    component.set("v.reqDocNameList", reqDocTypeName);
                    //console.log('reqDocTypeName !@:',component.get("v.reqDocTypeName"));
                }
                if (reqDocsForSubmitBtn != null) {
                    // Required document types for POP submission are stored in reqDocTypesForEnablingSubmitBtn
                    component.set("v.reqDocTypesForEnablingSubmitBtn", reqDocsForSubmitBtn);
                    //console.log('reqDocTypesForEnablingSubmitBtn !@:',component.get("v.reqDocTypesForEnablingSubmitBtn"));
                }
            }
        });
        $A.enqueueAction(action);
    }
});