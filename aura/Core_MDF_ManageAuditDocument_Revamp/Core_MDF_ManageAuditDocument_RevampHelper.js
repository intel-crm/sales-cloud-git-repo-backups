({
    initiateComponent: function (component, event, helper) {
        component.set("v.spinner", true);
        let userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.userInfo", userId);
        let recId = component.get("v.recordIdForPop");
        if(component.get("v.programName") == $A.get("$Label.c.Core_MDF_Co_GTM_program_name")) {
            component.set("v.isCoGTMProgram", true);
        }
        let partnerFundReqId = component.get("v.simpleNewClaim.RequestId"); //anushya TWC3117-14374
        let outComeBasedFlag = component.get("v.isOutcomeBasedActivity");  //anushya TWC3117-14374

        console.log("partnerFundReqId===",partnerFundReqId);
        console.log("outComeBasedFlag===",outComeBasedFlag);
        //Setting File formats
        let fileFormats = $A.get("$Label.c.Core_MDF_AllowedFileTypes").split(",");
        component.set("v.accept", fileFormats);
        let auditDocuments = component.get("v.auditDocument");
        let documentList = [];
        //apex call to get audit document details and user access
        let action = component.get("c.getAuditDocumentDetailsWrapper");
        //action.setParams({ recordId: recId });  //anushya TWC3117-14374
        action.setParams({ recordId: recId, outComeBasedFlag: outComeBasedFlag  }); //anushya TWC3117-14374
        action.setCallback(this, function (res) {
            let state = res.getState();
            if (state.toLowerCase() === "success") {
                let auditDocumentDetailsWrapper = res.getReturnValue();
                console.log('auditDocumentDetailsWrapper:::', auditDocumentDetailsWrapper);
                //third party rule engine call
                if(!component.get("v.isCoGTMProgram")) {
                     this.getThirdPartyDetails(component);
                }
                if (auditDocumentDetailsWrapper != null) {
                    component.set("v.auditDocumentDetailsWrapper", auditDocumentDetailsWrapper);
                    component.set("v.disableUploadFilesButton", auditDocumentDetailsWrapper.disableDocumentUploadSection);
                    component.set("v.showUploadFileSection", auditDocumentDetailsWrapper.showUploadFileSection);
                    component.set("v.isBulkClaim", auditDocumentDetailsWrapper.isBulkClaim);
                    component.set("v.isOutcomeBasedAccountBasedAct", auditDocumentDetailsWrapper.isOutComeBased);
                    if (auditDocuments.length > 0) {
                        documentList = documentList.concat(auditDocuments);
                    } else {
                        documentList = auditDocumentDetailsWrapper.documentList;
                    }
                    if (documentList.length > 0) {
                        component.set("v.auditDocument", documentList);
                        component.set("v.existingDocList", documentList);
                        component.set("v.existingAuditDocuments", JSON.parse(JSON.stringify(documentList)));//Added by VB - AI PIC Review
                        component.set("v.displayUploadedFiles", true);
                        component.set("v.disableManageDocumentButton", auditDocumentDetailsWrapper.disableDocumentUploadSection);
                    }
                    this.getDocumentDetails(component, documentList);
                    //to decide whether claim is eligible for PIC review or not
                    if (auditDocumentDetailsWrapper.isClaimEdit) {
                        this.submitForPIC(component);
                    }

                }
            } else {
                let message = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                component.set("v.spinner", false);
                this.displayToastMesages(message, "5000", "error");
            }
        });
        $A.enqueueAction(action);
    },

    //To check whether the  claim belongs to 3rd party or not
    getThirdPartyDetails: function (component, event, helper) {
        let claimDetails = component.get("v.simpleNewClaim");
        let action = component.get("c.isValidThirdPartyPOPClaim");

        var amountFields = {
            totalAmountLocal: component.get("v.simpleNewClaim.Core_MDF_Total_Invoice_Amount_Local__c"),
            costNotReimbursable: component.get("v.simpleNewClaim.Core_MDF_OtherCostsnotReimbursable_Local__c"),
            taxesLocal: component.get("v.simpleNewClaim.Core_MDF_Taxes_Local__c")
        };


        action.setParams({
            pfc: claimDetails,
            "amountFields": JSON.stringify(amountFields)
        });
        action.setCallback(this, function (res) {
            let state = res.getState();
            if (state.toLowerCase() === "success") {
                let isThirdPartyWrapper = res.getReturnValue();
                component.set("v.isThirdPartyClaim", isThirdPartyWrapper.isThirdPartyPOP);
                // Fire Third Party event to the Parent components -> Core_MDF_PFC_Create(create/clone/edit) and Core_MDF_ManageAuditDocumentWrapperComponent(claim detail page/bulk claim)
                let thirdPartyPOPEvent = $A.get("e.c:Core_MDF_ThirdPartyPOPEvent");
                thirdPartyPOPEvent.setParams({ "passData": isThirdPartyWrapper });
                thirdPartyPOPEvent.fire();
            } else {
                let message = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                component.set("v.spinner", false);
                this.displayToastMesages(message, "5000", "error");
            }

        });
        $A.enqueueAction(action);
    },

    //To check whether the claim is eligible for PIC Review or not based on the claim Status and display the submit for PIC PopUp accordingly
    //Used in Parent component  - Core_MDF_ManageAuditDocumentWrapperComponent, to be used in PFC_Create
    submitForPIC: function (component) {
        
        //component.set("v.spinner", true);
        let auditDocumentDetailsWrapper = component.get("v.auditDocumentDetailsWrapper");
        if (auditDocumentDetailsWrapper.isClaimEdit) {
            let action = component.get("c.checkClaimStatusForPICProcess");
            action.setParams({
                claimId: component.get("v.recordIdForPop")
            });
            action.setCallback(this, function (res) {
                let state = res.getState();
                if (state.toLowerCase() === "success") {

                    // let isClaimEligibleForPICReview = res.getReturnValue();
                    // component.set("v.isClaimEligibleForPICReview", isClaimEligibleForPICReview);

                    // Roshan TWC3117-16573
                    let picStatusWrapper = res.getReturnValue();
                    component.set("v.isClaimEligibleForPICReview", picStatusWrapper.isClaimAvailableForPIC);
                    component.set("v.isOutComeBased", picStatusWrapper.isOutComeBased);
                    component.set("v.spinner", false);
                } else {
                    var message = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                    component.set("v.spinner", false);
                    this.displayToastMesages(message, "5000", "error");
                }

            });
            $A.enqueueAction(action);
        }

    },

    // This method is executed after uploading a document
    createObjectDocuments: function (component, event) {
        let uploadedAuditDocList = [];
        let existingDocList;
        let contentDocumentIds = component.get("v.contentDocumentIds");
        let auditDocumentDetailsWrapper = component.get("v.auditDocumentDetailsWrapper");
        component.set("v.isManageDocEnabled", true);
        component.set("v.existingDocList", component.get("v.auditDocument"));
        //get the uploaded files
        let uploadedFiles = event.getParam("files");
        let uploadedFileNameWithoutExt;
        let encodedUploadedFileName;
        let encodedUploadedFileNameWithExt;
        let reduction = 0;
        let extPosition;
        let fileExt;
        //for the bulk claim and edit(using edit claim button, claim detail page), a new document property is set to true
        if (auditDocumentDetailsWrapper.isClaimEdit || component.get("v.isBulkClaim")) {
            uploadedFiles.map(uploadedFile => {
                var fileNameShorteningInd = $A.get("$Label.c.Core_MDF_SFTNameShortening_Ind");
                let uploadedFileName = uploadedFile.name;
                if (fileNameShorteningInd == 'True') {
                    if (uploadedFileName.includes('%')) {
                        uploadedFileName = uploadedFileName.replaceAll('%', 'pct');
                    }
                    extPosition = uploadedFileName.lastIndexOf(".");//extention position 
                    fileExt = uploadedFileName.substring(extPosition);
                    uploadedFileNameWithoutExt = uploadedFileName.substring(0, extPosition);
                    encodedUploadedFileName = encodeURI(uploadedFileNameWithoutExt);
                    encodedUploadedFileNameWithExt = encodeURI(uploadedFileName.replace(/[{}|\\^~[\]`"]/g, "_"));
                    while (encodedUploadedFileNameWithExt.length > 130) {
                        uploadedFileNameWithoutExt = uploadedFileNameWithoutExt.substring(0, 60 - reduction);
                        encodedUploadedFileName = encodeURI(uploadedFileNameWithoutExt);
                        encodedUploadedFileNameWithExt = encodeURI(uploadedFileNameWithoutExt + fileExt);
                        reduction = reduction + 5;
                    }
                }
                uploadedAuditDocList.push({
                    sobjectType: "Core_MDF_Audit_Document__c",
                    Core_MDF_Document_Title__c: uploadedFile.name,
                    Core_MDF_Download_Document_Title_txt__c: decodeURI(encodedUploadedFileNameWithExt),
                    Core_MDF_Encoded_Document_Title_txt__c: encodedUploadedFileNameWithExt,
                    Core_MDF_Document_Id__c: uploadedFile.documentId,
                    //Core_MDF_Document_Types__c: component.get("v.isCoGTMProgram") ? "Proof of Cost;Proof of Execution;Proof of Attribution" : "",//dk change
                    Core_MDF_Document_Types__c: (component.get("v.isCoGTMProgram") || component.get("v.isOutcomeBasedAccountBasedAct")) ? "Proof of Cost;Proof of Execution;Proof of Attribution" : "", //dk change && anushya TWC3117-14374
                    Core_MDF_Old_Document_Id__c: this.generateAppId(),
                    //Core_MDF_App_Document_Types_nm__c: component.get("v.isCoGTMProgram") ? "Proof of Cost;Proof of Execution;Proof of Attribution" : "",//dk change
                    Core_MDF_App_Document_Types_nm__c: (component.get("v.isCoGTMProgram") || component.get("v.isOutcomeBasedAccountBasedAct")) ? "Proof of Cost;Proof of Execution;Proof of Attribution" : "", // dk change && anushya TWC3117-14374
                    Core_MDF_ContentVersion_Id__c: uploadedFile.contentVersionId,
                    isNewDocument: true,
                });
                contentDocumentIds.push(uploadedFile.documentId);


            });
        } else {
            uploadedFiles.map(uploadedFile => {
                var fileNameShorteningInd = $A.get("$Label.c.Core_MDF_SFTNameShortening_Ind");//True//TRUE
                let uploadedFileName = uploadedFile.name;
                if (fileNameShorteningInd == 'True') {//have uppercase conversion and validate
                    if (uploadedFileName.includes('%')) {
                        uploadedFileName = uploadedFileName.replaceAll('%', 'pct');
                    }
                    extPosition = uploadedFileName.lastIndexOf(".");//extention position 
                    fileExt = uploadedFileName.substring(extPosition);
                    uploadedFileNameWithoutExt = uploadedFileName.substring(0, extPosition);
                    encodedUploadedFileName = encodeURI(uploadedFileNameWithoutExt);
                    encodedUploadedFileNameWithExt = encodeURI(uploadedFileName.replace(/[{}|\\^"~[\]`]/g, "_"));
                    while (encodedUploadedFileNameWithExt.length > 130) {
                        uploadedFileNameWithoutExt = uploadedFileNameWithoutExt.substring(0, 60 - reduction);
                        encodedUploadedFileName = encodeURI(uploadedFileNameWithoutExt);
                        encodedUploadedFileNameWithExt = encodeURI(uploadedFileNameWithoutExt + fileExt);
                        reduction = reduction + 5;
                    }
                }

                uploadedAuditDocList.push({
                    sobjectType: "Core_MDF_Audit_Document__c",
                    Core_MDF_Document_Title__c: uploadedFile.name,
                    Core_MDF_Download_Document_Title_txt__c: decodeURI(encodedUploadedFileNameWithExt),
                    Core_MDF_Encoded_Document_Title_txt__c: encodedUploadedFileNameWithExt,
                    Core_MDF_Document_Id__c: uploadedFile.documentId,
                    //Deafult Proof of Cost;Proof of Execution;Proof of Attribution for CoGTM
                    //Core_MDF_Document_Types__c: component.get("v.isCoGTMProgram") ? "Proof of Cost;Proof of Execution;Proof of Attribution" : "",
                    Core_MDF_Document_Types__c: (component.get("v.isCoGTMProgram") || component.get("v.isOutcomeBasedAccountBasedAct")) ? "Proof of Cost;Proof of Execution;Proof of Attribution" : "", //dk change && anushya TWC3117-14374
                    //Core_MDF_App_Document_Types_nm__c: component.get("v.isCoGTMProgram") ? "Proof of Cost;Proof of Execution;Proof of Attribution" : "",
                    Core_MDF_App_Document_Types_nm__c: (component.get("v.isCoGTMProgram") || component.get("v.isOutcomeBasedAccountBasedAct")) ? "Proof of Cost;Proof of Execution;Proof of Attribution" : "", // dk change && anushya TWC3117-14374
                    //Core_MDF_Document_Types__c: "",
                    Core_MDF_Old_Document_Id__c: this.generateAppId(),
                    //Core_MDF_App_Document_Types_nm__c: "",
                    Core_MDF_ContentVersion_Id__c: uploadedFile.contentVersionId,
                    isNewDocument: false,
                });
                contentDocumentIds.push(uploadedFile.documentId);

                //uploadedFile.contentvesionId where is it?
                //rename - old doc id to appfileId

            });
        }
        component.set("v.contentDocumentIds", contentDocumentIds);
        existingDocList = component.get("v.existingDocList").length > 0 ? component.get("v.existingDocList").concat(uploadedAuditDocList) : uploadedAuditDocList;
        component.set("v.auditDocument", existingDocList);
        component.set("v.existingDocList", existingDocList);
        this.getDocumentDetails(component, existingDocList);
        //Co-GTM -> Added by VB
        if (component.get("v.isCoGTMProgram") || component.get("v.isOutcomeBasedAccountBasedAct")) { //anushya TWC3117-14374
            component.set("v.isOpen", false);
            component.set("v.displayUploadedFiles", true);
            component.set("v.disableManageDocumentButton", false);//dk change
            this.checkForChangeInDocumentList(component);//dk change
        } else {
            component.set("v.isOpen", true);
        }
        component.set("v.showDeleteOption", true);
    },

    getDocumentDetails: function (component, documentList) {
        let recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        let budgetType;
        let programName;
        if ((component.get("v.auditDocumentDetailsWrapper.sObjName") == 'PartnerFundClaim') && component.get("v.auditDocumentDetailsWrapper.pfcRec.Id") != null) {
            //BudgetType fetched from sObjectDocumentWrapper in case of edit claim and in claim detail page based on the claim record id
            //budgetType = component.get("v.auditDocumentDetailsWrapper.pfcRec.Core_MDF_Budget_Type_Nm__c");
            budgetType = component.get("v.auditDocumentDetailsWrapper.pfcRec.Core_MDF_Budget_Type_Options_Nm__c"); //org health
            programName = component.get("v.auditDocumentDetailsWrapper.pfcRec.Core_MDF_Program__c");
        } else {
            //BugetType passed from Core_MDF_PFC_Create parent component in case of create,clone claim and bulk claim.
            budgetType = component.get("v.budgetType");
            programName = component.get("v.programName");
        }

        this.getDocNamesBasedOnProgOrBudget(component, programName, budgetType, documentList);
    },

    //To get the required document types based on prpgram and budget type
    getDocNamesBasedOnProgOrBudget: function (component, programName, budgetType, documentList) {
        let metadata = [];
        let typeOfDocuments = [];
        let documentTypeNames = [];
        let requiredDocumentTypes = [];
        let requiredDocumentTypesList = [];
        let reqMandatoryDocTypesToCreateAClaim = [];
        let claimStatus = component.get("v.auditDocumentDetailsWrapper.claimStatus");
        let action = component.get("c.fetchMetaDataRecords");
        let isDocSubmissionMandatory = false;
        action.setParams({
            programName: programName,
            budgetType: budgetType,
        });
        /** typeOfDocuments - To be used in Document Type selection Popup(the document types are displayed based on this)
         *  documentTypeNames - Holds the applicable document types irrespective of POP submission mandatory
         *  requiredDocumentTypes - Holds the mandatory document types based on the claim's program and budget type(used to display as text in UI - Mdantory document type message)
         *  reqMandatoryDocTypesToCreateAClaim - Holds the mandatory document types if POP submisson is mandatory
         *  requiredDocumentTypesList - Holds the mandatory document types based on the claim's program and budget type
         */
        action.setCallback(this, function (res) {
            let state = res.getState();
            if (state.toLowerCase() === "success") {
                metadata = res.getReturnValue();
                if (metadata.length > 0) {
                    metadata.map(mdt => {
                        typeOfDocuments.push({
                            documentNameLabel: mdt.Document_Type_Label,
                            documentName: mdt.Core_MDF_Document_Type_nm__c,
                            value: false
                        });

                        documentTypeNames.push(mdt.Core_MDF_Document_Type_nm__c);
                        if (mdt.Core_MDF_ReqforPOPSubmission_ind__c) {
                            reqMandatoryDocTypesToCreateAClaim.push(mdt.Core_MDF_Document_Type_nm__c);
                        }

                        if (mdt.Core_MDF_Req_Doc_Types_ind__c) {
                            requiredDocumentTypes.push(mdt.Document_Type_Label);
                            requiredDocumentTypesList.push(mdt.Core_MDF_Document_Type_nm__c);
                        } else {
                            //Aditya - PIC status update
                            if (claimStatus === $A.get("Core_MDF_Claim_Status_Payment_Clearance_Processing") || claimStatus === $A.get("$Label.c.Core_MDF_Claim_Status_PIC_Pending") || claimStatus === $A.get("$Label.c.Core_MDF_Claim_Status_Paid_and_PIC_Pending")) {
                                requiredDocumentTypesList.push(mdt.Core_MDF_Document_Type_nm__c);
                            }
                        }
                    });

                }
                //to decide on 100% POP -> create/clone/edit
                if (requiredDocumentTypesList.length === reqMandatoryDocTypesToCreateAClaim.length
                    && this.compareSelectedDocumentTypesVsRequiredDocumentTypes(requiredDocumentTypesList, reqMandatoryDocTypesToCreateAClaim)) {
                    isDocSubmissionMandatory = true;
                } else {
                    isDocSubmissionMandatory = false;
                }

                component.set("v.typeOfDocuments", typeOfDocuments);
                component.set("v.documentTypeNames", documentTypeNames);
                component.set("v.requiredDocumentTypes", requiredDocumentTypes.join('; '));
                component.set("v.reqMandatoryDocTypesToCreateAClaim", reqMandatoryDocTypesToCreateAClaim);
                component.set("v.isDocSubmissionMandatory", isDocSubmissionMandatory);
                //to check whether all the mandatory document types are selected or not
                this.getSelectedDocumentTypeDetails(component, documentList);
                component.set("v.spinner", false);
            } else {
                component.set("v.spinner", false);
                var message = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                this.displayToastMesages(message, "5000", "error");
            }
        });
        $A.enqueueAction(action);
    },

    //This method is executed either on selection/de-selection of document type checkbox
    updateDocumentTypeSelection: function (component, event, helper) {
        let reqMandatoryDocTypesToCreateAClaim = component.get("v.reqMandatoryDocTypesToCreateAClaim");
        let applicableDocumentTypes = component.get("v.documentTypeNames").join(';');
        let [selectedDocumentId, selectedDocumentType] = event.getParam("checkboxName").split(';#');
        let auditDocumentList = component.get("v.auditDocument");
        let selectedDocumentTypesList = [];
        let selectedDocTypes = [];
        let existingDocList = component.get("v.existingDocList");
        let selectedDocumentTypesOfAllAuditDocuments = component.get("v.selectedDocumentTypesOfAllAuditDocuments");
        let typeOfDocuments = component.get("v.typeOfDocuments");
        auditDocumentList.map(auditDoc => {
            auditDoc.Core_MDF_App_Document_Types_nm__c = applicableDocumentTypes;
            selectedDocumentTypesList = (!$A.util.isUndefinedOrNull(auditDoc.Core_MDF_Document_Types__c) && !$A.util.isEmpty(auditDoc.Core_MDF_Document_Types__c) && auditDoc.Core_MDF_Document_Types__c != "") ? auditDoc.Core_MDF_Document_Types__c.split(';') : [];
            if (auditDoc.Core_MDF_Document_Id__c === selectedDocumentId) {
                typeOfDocuments.find(docType => {
                    if (docType.documentName === selectedDocumentType) {
                        if (docType.value) {
                            selectedDocumentTypesList.push(selectedDocumentType);
                            selectedDocumentTypesOfAllAuditDocuments.push(selectedDocumentType);
                        } else {
                            selectedDocumentTypesList.splice(selectedDocumentTypesList.findIndex(dtype => dtype === selectedDocumentType), 1);
                            selectedDocumentTypesOfAllAuditDocuments.splice(selectedDocumentTypesOfAllAuditDocuments.findIndex(dtype => dtype === selectedDocumentType), 1);
                        }
                    }
                })
            }

            //selectedDocTypes = Array.from(new Set(selectedDocumentTypesOfAllAuditDocuments));
            auditDoc.Core_MDF_Document_Types__c = selectedDocumentTypesList.join(';');
            component.set("v.selectedDocumentTypesOfAllAuditDocuments", selectedDocumentTypesOfAllAuditDocuments);
        });
        component.set("v.auditDocument", auditDocumentList);
        //needed only for claim edit and claim detail page
        if (selectedDocumentTypesOfAllAuditDocuments.length > 0 && reqMandatoryDocTypesToCreateAClaim.length > 0 && this.compareSelectedDocumentTypesVsRequiredDocumentTypes(selectedDocumentTypesOfAllAuditDocuments, reqMandatoryDocTypesToCreateAClaim)) {
            component.set("v.isAllMandatoryDocumentTypesSubmitted", true);
        } else {
            component.set("v.isAllMandatoryDocumentTypesSubmitted", false);
        }
    },

    //To check whether the mandatory document types are selected or not
    compareSelectedDocumentTypesVsRequiredDocumentTypes: function (selectedDocTypes, reqMandatoryDocTypesToCreateAClaim) {
        let isAllMandatoryDocumentypesSelected = false;
        let isAllMandatoryDocumentypesNotSelected = false;
        for (let docType of reqMandatoryDocTypesToCreateAClaim) {
            if (!selectedDocTypes.includes(docType)) {
                isAllMandatoryDocumentypesNotSelected = true;
            } else {
                isAllMandatoryDocumentypesSelected = true;
            }
        }
        if (isAllMandatoryDocumentypesNotSelected) {
            return false;
        } else {
            return true;
        }
    },

    //This method is executed on click of save from Document type selection popup after uploading a document
    updateObjectDocuments: function (component, event, helper) {
        let auditDocList = component.get("v.auditDocument");
        let recId = component.get("v.recordIdForPop");
        let auditDocumentDetailsWrapper = component.get("v.auditDocumentDetailsWrapper");
        this.validateDocumentTypesSelection(component, auditDocList);
        let isAnyOneDocumentTypeSelectedOnEachDocument = component.get("v.isAnyOneDocumentTypeSelectedOnEachDocument");
        let docTypeArray = component.get("v.typeOfDocuments");
        if (isAnyOneDocumentTypeSelectedOnEachDocument) {
            component.set("v.disableManageDocumentButton", false);
            component.set("v.isOpen", false);
            //It is to check whether any new document is uploaded or existing document is edited.
            if (auditDocumentDetailsWrapper.isClaimEdit || auditDocumentDetailsWrapper.isBulkClaim) {
                this.checkForChangeInDocumentList(component);
            }
            component.set("v.auditDocument", component.get("v.existingDocList"));
            component.set("v.displayUploadedFiles", true);
        } else {
            let toastMessage = $A.get("$Label.c.Core_MDF_Manage_Document_Error_Message");
            this.displayToastMesages(toastMessage, "3000", "error");
        }
        component.set("v.typeOfDocuments", docTypeArray);
        // console.log("dhakshinesh doctype:",docTypeArray );
    },

    /*To Fire an event to parent  component(Core_MDF_ManageAuditDocumentWrapperComponent), 
    when a new doc is uploaded/existing doc is updated/no change to enable/disable the submit button(Bulk claim, claim detail page)*/
    checkForChangeInDocumentList: function (component) {
        let auditDocumentList = component.get("v.auditDocument");
        let existingAuditDocuments = component.get("v.existingAuditDocuments");
        let auditDocumentListToInsertOrUpdate = [];
        auditDocumentList.map(auditDoc => {
            if (auditDoc.isNewDocument) {
                let auditDocumentWrapper = {
                    isNewDocument: auditDoc.isNewDocument,
                    auditDocument: auditDoc,
                }
                auditDocumentListToInsertOrUpdate.push(auditDocumentWrapper);
            }
            let existingDoc = existingAuditDocuments.find(doc => doc.Core_MDF_Document_Id__c == auditDoc.Core_MDF_Document_Id__c);
            if (!$A.util.isUndefined(existingDoc) && !$A.util.isUndefinedOrNull(existingDoc.Core_MDF_Document_Types__c) && existingDoc.Core_MDF_Document_Types__c != "" && !$A.util.isEmpty(existingDoc.Core_MDF_Document_Types__c)) {
                let existingDocumentTypes = existingDoc.Core_MDF_Document_Types__c.toLowerCase().split(';').sort().toString();
                let auditDocumentTypes = auditDoc.Core_MDF_Document_Types__c.toLowerCase().split(';').sort().toString();
                if (existingDocumentTypes !== auditDocumentTypes) {
                    let auditDocumentWrapper = {
                        isNewDocument: false,
                        auditDocument: auditDoc,
                    };
                    auditDocumentListToInsertOrUpdate.push(auditDocumentWrapper);
                }
            }
            //Document type selection issue fix
            else if (!$A.util.isUndefined(existingDoc) && ($A.util.isUndefinedOrNull(existingDoc.Core_MDF_Document_Types__c) || $A.util.isEmpty(existingDoc.Core_MDF_Document_Types__c) || existingDoc.Core_MDF_Document_Types__c == "")) {
                let existingDocumentTypes = existingDoc.Core_MDF_Document_Types__c;
                let auditDocumentTypes = auditDoc.Core_MDF_Document_Types__c;
                if (existingDocumentTypes !== auditDocumentTypes) {
                    let auditDocumentWrapper = {
                        isNewDocument: false,
                        auditDocument: auditDoc,
                    };
                    auditDocumentListToInsertOrUpdate.push(auditDocumentWrapper);
                }

            }
        });
        // If is excuted on change to the audit document list, to enable the submit button
        // Else is executed on no new chnage to the audit document list, to disable the submit button
        // Example for Else - upload a new document/edit existing document and revert the changes (i.e delete the newly uploaded document)
        if (auditDocumentListToInsertOrUpdate.length > 0) {
            let enableSubmitButtonEvent = component.getEvent("enableSubmitButtonEvent");
            enableSubmitButtonEvent.setParams({ auditDocumentListToInsertOrUpdate: auditDocumentListToInsertOrUpdate, disableSubmitButton: false });
            enableSubmitButtonEvent.fire();
        } else {
            let enableSubmitButtonEvent = component.getEvent("enableSubmitButtonEvent");
            enableSubmitButtonEvent.setParams({ auditDocumentListToInsertOrUpdate: auditDocumentListToInsertOrUpdate, disableSubmitButton: true });
            enableSubmitButtonEvent.fire();
        }
        // console.log("dhakshinesh check for change in doc list:", auditDocumentList);
    },

    //To check whether one document type is selected on each file or not
    validateDocumentTypesSelection: function (component, auditDocList) {
        let noDocTypeSelected = false;
        auditDocList.length && auditDocList.map(auditDoc => {
            //either use allselecteddocument types or just iterate and get the value
            let documentTypes = [];
            if (!($A.util.isUndefinedOrNull(auditDoc.Core_MDF_Document_Types__c) && $A.util.isEmpty(auditDoc.Core_MDF_Document_Types__c)) && auditDoc.Core_MDF_Document_Types__c != "") {
                documentTypes.push(auditDoc.Core_MDF_Document_Types__c.includes(';') ? auditDoc.Core_MDF_Document_Types__c.split(';') : auditDoc.Core_MDF_Document_Types__c);
            } else {
                noDocTypeSelected = true;
            }
            if (documentTypes.length > 0 && !noDocTypeSelected) {
                component.set("v.isAnyOneDocumentTypeSelectedOnEachDocument", true);
            } else {
                component.set("v.isAnyOneDocumentTypeSelectedOnEachDocument", false);
                noDocTypeSelected = true;
            }
        });
        // console.log("dhakshinesh doctype line 482:",documentTypes );

    },

    //To delete a document - Create/clone/Bulk claim and Edit(claim detail page, edit claim) -> can deleted only the newly uploaded document
    deleteDocs: function (component, docId, docIndex) {
        component.set("v.spinner", true);
        let auditDocumentDetailsWrapper = component.get("v.auditDocumentDetailsWrapper");
        let isClaimEdit = auditDocumentDetailsWrapper.isClaimEdit;
        let claimId;
        if (isClaimEdit) {
            claimId = component.get("v.recordIdForPop");
        }
        var action = component.get("c.deleteDocumentIds");
        action.setParams({
            docId: docId,
        });

        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state.toLowerCase() === "success") {
                let documents = component.get("v.auditDocument");
                let contentDocumentIds = component.get("v.contentDocumentIds");
                documents.splice(docIndex, 1);
                contentDocumentIds.splice(contentDocumentIds.findIndex(documentId => documentId === docId), 1);
                component.set("v.contentDocumentIds", contentDocumentIds);
                component.set("v.auditDocument", documents);
                component.set("v.existingDocList", documents);
                if (documents.length == 0) {
                    component.set("v.disableManageDocumentButton", true);
                    component.set("v.isOpen", false);
                }
                if (auditDocumentDetailsWrapper.isClaimEdit || auditDocumentDetailsWrapper.isBulkClaim) {
                    this.checkForChangeInDocumentList(component);
                }
                this.getSelectedDocumentTypeDetails(component, component.get("v.auditDocument"));
                component.set("v.spinner", false);
            } else {
                let message = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                this.displayToastMesages(message, "5000", "error");
                component.set("v.spinner", false);
            }
        });

        $A.enqueueAction(action);
    },

    //To get the selected document types at claim level
    getSelectedDocumentTypeDetails: function (component, auditDocList) {
        let reqMandatoryDocTypesToCreateAClaim = component.get("v.reqMandatoryDocTypesToCreateAClaim");
        let selectedDocumentTypes = [];
        if (auditDocList.length > 0) {
            auditDocList.map(auditDoc => {
                if (!($A.util.isUndefinedOrNull(auditDoc.Core_MDF_Document_Types__c) && $A.util.isEmpty(auditDoc.Core_MDF_Document_Types__c)) && auditDoc.Core_MDF_Document_Types__c != "") {
                    if (auditDoc.Core_MDF_Document_Types__c.includes(';')) {
                        auditDoc.Core_MDF_Document_Types__c.split(';').map(audit => {
                            selectedDocumentTypes.push(audit);
                        });
                    } else {
                        selectedDocumentTypes.push(auditDoc.Core_MDF_Document_Types__c);
                    }
                }
            });
            component.set("v.selectedDocumentTypesOfAllAuditDocuments", selectedDocumentTypes);
            if (selectedDocumentTypes.length > 0 && reqMandatoryDocTypesToCreateAClaim.length > 0
                && this.compareSelectedDocumentTypesVsRequiredDocumentTypes(selectedDocumentTypes, reqMandatoryDocTypesToCreateAClaim)) {
                component.set("v.isAllMandatoryDocumentTypesSubmitted", true);
            } else {
                component.set("v.isAllMandatoryDocumentTypesSubmitted", false);
            }
        } else {
            component.set("v.isAllMandatoryDocumentTypesSubmitted", false);
        }

    },

    // To display the toat message on both success and failure scenarios
    displayToastMesages: function (errorMessage, duration, type) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: errorMessage,
            duration: duration,
            key: "info_alt",
            type: type
        });
        toastEvent.fire();
    },
    generateAESKey: function () {
        // Generate a random 128-bit (16 bytes) key
        var array = new Uint8Array(16);
        window.crypto.getRandomValues(array);
        return array;
    },

    byteArrayToHex: function (byteArray) {
        return Array.from(byteArray, function (byte) {
            return ('0' + (byte & 0xFF).toString(16)).slice(-2);
        }).join('');
    },

    formatDateTime: function (date) {
        let year = date.getFullYear();
        let month = (date.getMonth() + 1).toString().padStart(2, '0'); // Months are zero-indexed
        let day = date.getDate().toString().padStart(2, '0');
        let hours = date.getHours().toString().padStart(2, '0');
        let minutes = date.getMinutes().toString().padStart(2, '0');
        let seconds = date.getSeconds().toString().padStart(2, '0');

        return `${year}${month}${day} ${hours}${minutes}${seconds}`;// formating --::
    },

    deleteWhitespace: function (str) {
        // Remove all whitespace from a string
        return str.replace(/\s+/g, '');
    },

    generateAppId: function () {
        // Generate AES key
        var key = this.generateAESKey();
        // Convert byte array to hex string  hexadecimal (base 16) representation of the inputBlob .
        var hexKey = this.byteArrayToHex(key);
        // Get current timestamp
        var timestamp = this.formatDateTime(new Date());
        // Combine key and timestamp
        var guid = hexKey + timestamp;
        // Remove dashes and colons
        guid = guid.replace(/-/g, '');
        guid = guid.replace(/:/g, '');
        // Remove all whitespace
        var appId = this.deleteWhitespace(guid);
        return appId;
    }
})