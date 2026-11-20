({
    loadApprovalFlowAction: function (component, event, helper) {
        var result;
        var action = component.get("c.loadPFRRecord");
      
        action.setParams({
        "pfrId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            result = response.getReturnValue();
            var state = response.getState();
           if (state === "SUCCESS") {            
            if (result != null) {
                component.set('v.externalUser', result.userPermissionsPowerPartner);
                component.set('v.isOutcomebaseActivity', result.isOutcomebaseActivity);
                    // Set the new attribute for the dual role
                    component.set('v.isIPAAccountMgrAndPCTApprover', result.isIPAAccountMgrAndPCTApprover);
                
                // UPDATED: Store current PFR status and check if AI should be loaded
                if (result.pfrInstance && result.pfrInstance.Core_MDF_Fund_Request_Status__c) {
                    component.set('v.currentPFRStatus', result.pfrInstance.Core_MDF_Fund_Request_Status__c);
                    }
                    
                //US946280 : [Opal CCF/DCF] - Activity Edits - Activity Status = Pending Approval - Show Reject button for Internal Account Manager
                //Ramapriya - Approve/Reject/Recall button visibility for In-Progress Pending Review / In-Progress Pending Approval Status
                if((result.pfrInstance.Core_MDF_Program__c == 'Client' 
                || result.pfrInstance.Core_MDF_Program__c == 'Datacenter' 
                || (result.pfrInstance.Core_MDF_Program__c =='Intel Partner Alliance' && result.pfrInstance.Core_MDF_Proposal_Based_Ind__c==false)
                || result.pfrInstance.Core_MDF_Program__c == 'Ecosystem Extension Fund') 
                    && (((((result.isMarktngOwner ||  result.isFieldOwner) && !result.isAdditionalReviewer) || result.isIPAAccountMgr) && 
                    (result.pfrInstance.Core_MDF_Fund_Request_Status__c == $A.get("$Label.c.Core_MDF_Status_Pending_Approval_Nm") ||
                    result.pfrInstance.Core_MDF_Fund_Request_Status__c == $A.get("$Label.c.Core_MDF_PFR_Status_InProgress_PendingApproval") ||
                    ((result.pfrInstance.Core_MDF_Fund_Request_Status__c == $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview") || 
                      result.pfrInstance.Core_MDF_Fund_Request_Status__c == $A.get("$Label.c.Core_MDF_PFR_Status_InProgress_PendingReview")  ) &&
                    result.pfrInstance.Core_MDF_Approval_Step_Completed__c != 0)))                    
                   || (result.userPermissionsPowerPartner 
                       && result.pfrInstance.Core_MDF_Fund_Request_Status__c == $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"))
                    || result.userPermissionsEEFRecall)
                    && !result.isIPAAccountMgrAndPCTApprover){                   
                  
                    component.set('v.rejectInternalVisble', true);
                    component.set('v.buttonName', $A.get("$Label.c.Core_MDF_Activity_Recall_Nm"));
                    component.set('v.buttonValue', 'Recall');
                    component.set('v.buttonToBeVisible', true);  
                    component.set('v.showRecallOnly', true);  
                }
                
                //Changes by Ealisha for opal act approval process--start
                else if(result.isIntelActivityApprover){
                    component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                    component.set('v.buttonValue', 'Approve');
                    component.set('v.buttonToBeVisible', true);
                    component.set('v.isOpalActApprovalRequired', true);
                }
                 //Aswin
                else if(result.isAdditionalReviewer){
                    component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                    component.set('v.buttonValue', 'Approve');
                    component.set('v.buttonToBeVisible', true);
                    component.set('v.isOpalActApprovalRequired', true);
                }
                //Changes by Ealisha for opal act approval process--end
                
                else if (result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Review' && 
                    ('EMEA').includes(result.pfrInstance.Core_MDF_Region_nm__c) &&      
                    !result.approverAssigned && !result.userPermissionsPowerPartner && result.userEmeaReviewer) {
                     console.log('<EMEA>');
                    component.set('v.buttonName', $A.get("$Label.c.Core_MDF_Retail_SubmitForApproval"));
                    component.set('v.buttonValue', 'Submit for Approval');
                    component.set('v.buttonToBeVisible', true);
                }  else if(result.isAccountMng && result.approverAssigned && !result.isGeoLeadApprover && 
                           (result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Review' || result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Approval')
                            && result.pfrInstance.Core_MDF_Program__c == 'Retail Marketing Funds' /*&& result.pfrInstance.Core_MDF_Approval_Status_Stage_txt__c == 'Geo Marketing Lead'*/){
                  // US1072007 : [RMF] - Ability for RSM to Edit an Activity when in Geo Lead's Queue
                  // US1099159 : [RMF] - Change button Label
                  component.set('v.buttonName', $A.get("$Label.c.Core_MDF_Activity_Recall_Nm"));
                  component.set('v.buttonValue', 'Recall');
                  component.set('v.buttonToBeVisible', true);
                  component.set("v.commentsMandatory",false);
                  component.set('v.rejectInternalVisble', true);
                  component.set('v.isApprovalCommentsRequired', false); 
                } else if (result.userPermissionsPowerPartner && 
                           (result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Approval'
                        || result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'In-Progress Pending Approval' )){
                         
                    component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                    component.set('v.buttonValue', 'Approve');
                    component.set('v.buttonToBeVisible', true);
                }       
                //TWC702-1949: [Technical] [X-Platform] - Account Based PCT approvers
                else if(result.isUserPCTApprover && result.isPriceReviewer && result.pfrInstance.Core_MDF_Approval_Stage__c == 'Price Reviewer'
                            && (result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Review'
                                || result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'In-Progress Pending Review' )
                            ){
                    component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                    component.set('v.buttonValue', 'Approve');
                    component.set('v.buttonToBeVisible', true);
                    component.set('v.isPCTReviewer', true);
                  }
                    // New condition for dual-role functionality
                    else if (result.isIPAAccountMgrAndPCTApprover) {
                        component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                        component.set('v.buttonValue', 'Approve');
                        component.set('v.buttonToBeVisible', true);
                } 
                //IPA L1
                 else if (result.pfrInstance.Core_MDF_Program__c == 'Intel Partner Alliance' 
                          && result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Review'
                          && result.isLevel1Approver
                         && result.pfrInstance.Core_MDF_Proposal_Based_Ind__c == false){
                    component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                    component.set('v.buttonValue', 'Approve');
                    component.set('v.buttonToBeVisible', true);
                    component.set('v.isLevel1Approver', true);
                 }
                  else if (result.pfrInstance.Core_MDF_Program__c == 'Intel Partner Alliance' 
                          && (result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Review'
                          || result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'In-Progress Pending Review' )
                          && result.isPORApprover
                         && result.pfrInstance.Core_MDF_Proposal_Based_Ind__c == false){
                    component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                    component.set('v.buttonValue', 'Approve');
                    component.set('v.buttonToBeVisible', true);
                    component.set('v.isPORApprover', true);
                 }
                  else if (result.pfrInstance.Core_MDF_Program__c == 'Intel Partner Alliance' 
                          && (result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Review' 
                            || result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'In-Progress Pending Review' )
                          && result.isLevel2Approver
                         && result.pfrInstance.Core_MDF_Proposal_Based_Ind__c == false){
                    component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                    component.set('v.buttonValue', 'Approve');
                    component.set('v.buttonToBeVisible', true);
                    component.set('v.isLevel2Approver', true);
                 }
             
              else if (result.pfrInstance.Core_MDF_Program__c == 'Retail Marketing Funds'
              			&& result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Review'
                          && result.isGeoLeadApprover){
                    component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                    component.set('v.buttonValue', 'Approve');
                    component.set('v.buttonToBeVisible', true);
                    component.set('v.isGeoLeadApprover', true);
                } else if (result.pfrInstance.Core_MDF_Program__c == 'Ecosystem Extension Fund' 
                           && result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Review'){
                            if(result.isL1PrimaryPartnerApprover){
                                component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                                component.set('v.buttonValue', 'Approve');
                                component.set('v.buttonToBeVisible', true);
                                component.set('v.isL1PrimaryPartnerApprover', true);
                            } else if(result.isL1ActivatingPartnerApprover){
                                component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                                component.set('v.buttonValue', 'Approve');
                                component.set('v.buttonToBeVisible', true);
                                component.set('v.isL1ActivatingPartnerApprover', true);
                            }else if(result.isL2PrimaryApprover){
                                component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                                component.set('v.buttonValue', 'Approve');
                                component.set('v.buttonToBeVisible', true);
                                component.set('v.isL2PrimaryApprover', true);
                            } else if(result.isEEFPORApprover){
                                component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                                component.set('v.buttonValue', 'Approve');
                                component.set('v.buttonToBeVisible', true);
                                component.set('v.isPORApprover', true);
                            } else if(result.isEEFPCTApprover){
                                component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                                component.set('v.buttonValue', 'Approve');
                                component.set('v.buttonToBeVisible', true);
                                component.set('v.isPCTReviewer', true);
                            }
                } else if (result.pfrInstance.Core_MDF_Program__c == 'Ecosystem Extension Fund' 
                            && result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Approval'){
                        if(result.isPrimaryPartnerApprover){
                            component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                            component.set('v.buttonValue', 'Approve');
                            component.set('v.buttonToBeVisible', true);
                            component.set('v.isPrimaryPartnerApprover', true);
                        } else if(result.isActivatingPartnerApprover){
                            component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                            component.set('v.buttonValue', 'Approve');
                            component.set('v.buttonToBeVisible', true);
                            component.set('v.isActivatingPartnerApprover', true);
                        }
                }
                else {
                    component.set('v.buttonToBeVisible', false);
                }
                    // MOVED HERE: Set all permission flags first, then check AI permissions
                    component.set('v.isPCTReviewer', result.isUserPCTApprover && result.isPriceReviewer);
                    component.set('v.isLevel1Approver', result.isLevel1Approver);
                    component.set('v.isLevel2Approver', result.isLevel2Approver);
                    component.set('v.isPORApprover', result.isPORApprover);
                    component.set('v.isGeoLeadApprover', result.isGeoLeadApprover);
                    component.set('v.isRmfL1Approver', result.isRmfL1Approver);
                    component.set('v.isRmfL2Approver', result.isRmfL2Approver);
                    component.set('v.isAdditionalReviewer', result.isAdditionalReviewer);
                    component.set('v.isL1ActivatingPartnerApprover', result.isL1ActivatingPartnerApprover);
                    component.set('v.isL1PrimaryPartnerApprover', result.isL1PrimaryPartnerApprover);
                    component.set('v.isL2PrimaryApprover', result.isL2PrimaryApprover);
                    component.set('v.isPrimaryPartnerApprover', result.isPrimaryPartnerApprover);
                    component.set('v.isActivatingPartnerApprover', result.isActivatingPartnerApprover);
                    component.set('v.isOpalActApprovalRequired', result.isIntelActivityApprover || result.isAdditionalReviewer);
                    
                    // NOW check if user has approval permissions and load AI if needed
                    var hasApprovalPermissions = this.checkUserHasApprovalPermissions(component, result);
                    component.set('v.hasApprovalPermissions', hasApprovalPermissions);
                    
                    // NEW: Auto-load AI suggestion for Pending Review status and isoutcomebased activity
                   
                    if (result.pfrInstance.Core_MDF_Fund_Request_Status__c === 'Pending Review' && hasApprovalPermissions &&
                        result.pfrInstance.Core_MDF_Is_Outcome_Based_Ind__c === true) {
                        this.initializeAISuggestion(component);
                    }
                component.set('v.pfrMapInstance', result.pfrMapInstance);
          }
	  }
           else{
                var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                this.fireToastEvent(errorMessage, "5000", "error");
            }
        });
            $A.enqueueAction(action);
    },
    
    // UPDATED: Check if user has approval permissions
    checkUserHasApprovalPermissions: function(component, result) {
        var hasPermissions = (result.userPermissionsPowerPartner && !result.showRecallOnly) ||
               result.isGeoLeadApprover || (result.isUserPCTApprover && result.isPriceReviewer) || 
               result.isLevel1Approver || result.isLevel2Approver || result.isPORApprover || 
               result.isIntelActivityApprover || result.isAdditionalReviewer ||
               result.isL1PrimaryPartnerApprover || result.isL2PrimaryApprover ||
               result.isL1ActivatingPartnerApprover || result.isPrimaryPartnerApprover ||
               result.isActivatingPartnerApprover || result.isIPAAccountMgrAndPCTApprover ||
               result.isRmfL1Approver || result.isRmfL2Approver;
        
        return hasPermissions;
    },

    // NEW: Initialize AI suggestion for Pending Review records
    initializeAISuggestion: function(component) {
        component.set("v.isLoadingAISuggestion", true);
        
        var recordId = component.get("v.recordId");
        this.callAISuggestionService(component, recordId);
    },

    // UPDATED: AI Suggestion Service Method with proper table formatting
    callAISuggestionService: function(component, recordId) {
        
        // Call Apex method to get AI suggestion
        var action = component.get("c.getAISuggestionWithDecision");
        action.setParams({
            "recordId": recordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.isLoadingAISuggestion", false);
            
            if (state === "SUCCESS") {
                var aiResponse = response.getReturnValue();
                
                if (aiResponse && aiResponse.success) {
                    // UPDATED: Parse and format the actual AI response content
                    var formattedContent = this.parseAndFormatAIResponse(aiResponse.formattedContent, aiResponse.decision);
                    component.set("v.aiSuggestionText", formattedContent);
                    
                    // Set the AI decision for disclaimer
                    if (aiResponse.decision) {
                        component.set("v.aiDecision", aiResponse.decision);
                        component.set("v.showAIDisclaimer", true);
                        
                        // *** NEW: Store AI recommendation when successfully loaded ***
                        this.storeAIRecommendation(component, recordId, aiResponse.decision, aiResponse.formattedContent);
                    }
                } else {
                    this.handleAIError(component, aiResponse ? aiResponse.errorMessage : "No AI recommendation available");
                }
                
            } else {
                var errorMessage = "Unable to get AI recommendation";
                var errors = response.getError();
                
                if (errors && errors.length > 0) {
                    errorMessage = errors[0].message;
                }
                
                this.handleAIError(component, errorMessage);
            }
        });
        
        $A.enqueueAction(action);
    },

    /**
     * Store AI recommendation when it's first generated
     */
    storeAIRecommendation: function(component, recordId, aiDecision, aiDetails) {
        
        var action = component.get("c.storeAIRecommendation");
        action.setParams({
            recordId: recordId,
            aiRecommendation: aiDecision,
            aiDetails: aiDetails
        });
        
        $A.enqueueAction(action);
    },

    /**
     * Track AI recommendation usage when user makes a decision
     */
    trackRecommendationUsage: function(component, aiRecommendation, aiDetails, userDecision) {
        
        var recordId = component.get("v.recordId");
        
        var action = component.get("c.trackAIRecommendationUsage");
        action.setParams({
            recordId: recordId,
            aiRecommendation: aiRecommendation,
            aiDetails: aiDetails,
            userDecision: userDecision
        });
        
        $A.enqueueAction(action);
    },

    // NEW: Parse and format the actual AI response content
    parseAndFormatAIResponse: function(aiContent, decision) {
        
        var tableHtml = '<div class="slds-card slds-p-around_medium">';
        
        // Add decision header with color coding
        if (decision) {
            var decisionClass = '';
            var decisionText = decision.toUpperCase();
            
            // Color coding based on decision
            if (decisionText.includes('APPROVE')) {
                decisionClass = 'color: #4bca81; font-weight: bold;'; // Green
            } else if (decisionText.includes('REJECT')) {
                decisionClass = 'color: #ea001e; font-weight: bold;'; // Red
            } else if (decisionText.includes('REQUEST CLARIFICATION') || decisionText.includes('CLARIFICATION')) {
                decisionClass = 'color: #ffb75d; font-weight: bold;'; // Orange
            } else {
                decisionClass = 'color: #333; font-weight: bold;'; // Black for default
            }
            
            tableHtml += '<div class="slds-text-heading_small slds-m-bottom_medium" style="' + decisionClass + '">';
            tableHtml += 'Decision: ' + decisionText;
            tableHtml += '</div>';
        }
        
        // Create the table with borders
        tableHtml += '<table class="slds-table slds-table_cell-buffer slds-table_bordered slds-table_striped" style="border: 2px solid #dddbda; border-collapse: collapse;">';
        tableHtml += '<thead>';
        tableHtml += '<tr class="slds-line-height_reset" style="background-color: #f3f2f2;">';
        tableHtml += '<th class="slds-text-title_caps slds-p-around_small" scope="col" style="width: 25%; border: 1px solid #dddbda; font-weight: bold; color: #333;">FIELD</th>';
        tableHtml += '<th class="slds-text-title_caps slds-p-around_small" scope="col" style="width: 75%; border: 1px solid #dddbda; font-weight: bold; color: #333;">JUSTIFICATION</th>';
        tableHtml += '</tr>';
        tableHtml += '</thead>';
        tableHtml += '<tbody>';
        
        // Parse the AI response content to extract table data
        var violations = this.extractViolationsFromAIContent(aiContent);
        
        if (violations && violations.length > 0) {
            violations.forEach(function(violation) {
                tableHtml += '<tr>';
                tableHtml += '<td class="slds-p-around_small" style="border: 1px solid #dddbda; font-weight: bold; color: #333;">' + violation.field + '</td>';
                tableHtml += '<td class="slds-p-around_small" style="border: 1px solid #dddbda; color: #333;">' + violation.rule + '</td>';
                tableHtml += '</tr>';
            });
        } else {
            // If no violations found, show "No violations" message
            tableHtml += '<tr>';
            tableHtml += '<td class="slds-p-around_small" style="border: 1px solid #dddbda; font-weight: bold; color: #333;">None</td>';
            tableHtml += '<td class="slds-p-around_small" style="border: 1px solid #dddbda; color: #333;">No violations found</td>';
            tableHtml += '</tr>';
        }
        
        tableHtml += '</tbody>';
        tableHtml += '</table>';
        tableHtml += '</div>';
        
        return tableHtml;
    },

    // NEW: Extract violations from AI content using the actual response format
    extractViolationsFromAIContent: function(content) {
        var violations = [];
        
        if (!content) {
            return violations;
        }
        
        try {
            // Split content by lines and look for table rows
            var lines = content.split('\n');
            var inTable = false;
            
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim();
                
                // Skip empty lines and headers
                if (!line || line.includes('Field Name') || line.includes('----') || line.includes('Decision:') || line.includes('Justification:')) {
                    continue;
                }
                
                // Look for table rows with | separators (from your AI response format)
                if (line.includes('|') && !line.includes('Field Name')) {
                    // Parse the table row: | Field Name | Rule Violation Details |
                    var parts = line.split('|');
                    
                    if (parts.length >= 3) {
                        var field = parts[1].trim();
                        var rule = parts[2].trim();
                        
                        // Skip empty fields or header separators
                        if (field && rule && field !== '' && rule !== '' && !field.includes('-')) {
                            violations.push({
                                field: field,
                                rule: rule
                            });
                        }
                    }
                }
            }
            
        } catch (e) {
            // Fallback: If parsing fails, create a simple message
            violations.push({
                field: 'Parsing Error',
                rule: 'Unable to parse AI response. Please review the activity manually.'
            });
        }
        
        return violations;
    },

    // UPDATED: Handle AI errors with consistent styling
    handleAIError: function(component, errorMessage) {
        component.set("v.aiDecision", "Error");
        component.set("v.showAIDisclaimer", true);
        
        var errorHtml = '<div class="slds-card slds-p-around_medium slds-text-align_center">';
        errorHtml += '<div class="slds-text-heading_small slds-m-bottom_medium" style="color: #ea001e; font-weight: bold;">';
        errorHtml += 'Error loading AI recommendation';
        errorHtml += '</div>';
        errorHtml += '<p class="slds-m-bottom_small" style="color: #333;">' + errorMessage + '</p>';
        errorHtml += '<p style="color: #333;">Please proceed with manual review based on standard approval guidelines.</p>';
        errorHtml += '</div>';
        
        component.set("v.aiSuggestionText", errorHtml);
    },

    //Function to validate the approval comments heave been entered or not
    checkApprovalComment: function (component, pfrId, btnType) 
    {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: $A.get("$Label.c.Core_MDF_Error"),
            type: 'error',
            message: $A.get("$Label.c.Core_MDF_Approval_Comment_Error"), // Please provide a comment
            mode: 'sticky',
        });
        toastEvent.fire();

    },

    //Function that will called on click of the button
    onClickButton: function (component, pfrId, btnValue)
    {
       
        // Throw error only when rejection happens and comments are blank or empty or null
        if ((btnValue == 'Reject' && component.get("v.commentsMandatory")) && component.get("v.approvalComments") != null && $A.util.isEmpty(component.get("v.approvalComments").trim()))
        {
            component.set("v.disablebuttonName",false);
            this.toastMessage($A.get("$Label.c.Core_MDF_Error"),'error',$A.get("$Label.c.Core_MDF_Approval_Comment_Error"));
        }
        else{
            //TWC702-1949: [Technical] [X-Platform] - Account Based PCT approvers - Added PCT Reviewer
            if (btnValue == 'Approve' && !component.get('v.externalUser') && !component.get("v.isOpalActApprovalRequired") && !component.get("v.isPCTReviewer") && !component.get("v.isLevel1Approver") && !component.get("v.isLevel2Approver") && !component.get("v.isPORApprover") && !component.get("v.isGeoLeadApprover") && !component.get("v.isL1PrimaryPartnerApprover") && !component.get("v.isL2PrimaryApprover") && !component.get("v.isL1ActivatingPartnerApprover") && !component.get("v.isPrimaryPartnerApprover") && !component.get("v.isActivatingPartnerApprover") && !component.get("v.isIPAAccountMgrAndPCTApprover")){
             	this.sendActivityForExternalApproval(component); 
            //TWC702-1949: [Technical] [X-Platform] - Account Based PCT approvers - Added PCT Reviewer
            } else if ((btnValue == 'Approve' || btnValue == 'Reject' || btnValue == 'Recall') && (component.get('v.externalUser') || (component.get("v.rejectInternalVisble") || component.get("v.isOpalActApprovalRequired") || component.get("v.isPCTReviewer") || component.get("v.isLevel1Approver") || component.get("v.isLevel2Approver") || component.get("v.isPORApprover")||component.get("v.isGeoLeadApprover") || component.get("v.isL1PrimaryPartnerApprover") || component.get("v.isL2PrimaryApprover") || component.get("v.isL1ActivatingPartnerApprover") || component.get("v.isPrimaryPartnerApprover") || component.get("v.isActivatingPartnerApprover") || component.get("v.isIPAAccountMgrAndPCTApprover")))) {
                var mapInstance = component.get("v.pfrMapInstance");
                var mapStatusInstance = component.get("v.statusMapInstance");
                mapStatusInstance['Approval Action Comment'] = btnValue; //component.get("v.approvalComments");
                mapInstance[pfrId] = mapStatusInstance;                
                var aprAction = component.get("c.approveRejectActivity");
                aprAction.setParams({
                "mapValues": mapInstance,
                "approvalComments" : component.get("v.approvalComments"),
                "isExternal" : component.get('v.externalUser')
                })

                aprAction.setCallback(this, function (response) {
                    var stateSave = response.getState();
                    var res = response.getReturnValue();
                    var msgTxt = '';
                    var resValue = 'true';
                    
                    if(stateSave === "SUCCESS"){
                        if(res == resValue){
                        var msgTxt = '';
                        if (btnValue == 'Approve') {
                            msgTxt = $A.get("$Label.c.Core_MDF_Activity_Approved");
                        }  
                        else if (btnValue == 'Reject') {
                            msgTxt = $A.get("$Label.c.Core_MDF_Activity_Rejected");
                        } 
                        else if (btnValue == 'Recall') {
                            msgTxt = $A.get("$Label.c.Core_MDF_Activity_Recall_Msg");
                        }
                        // *** TRACK AI RECOMMENDATION ONLY AFTER ACTUAL APPROVAL SUCCESS ***
                        var aiDecision = component.get("v.aiDecision");
                        var aiDetails = component.get("v.aiSuggestionText");
                        if (aiDecision) {
                            this.trackRecommendationUsage(component, aiDecision, aiDetails, btnValue);
                        }                           
                    this.toastMessage($A.get("$Label.c.Core_MDF_Success"),'success',msgTxt);
                    this.windowTimeOut();
                    }else{
                      if (btnValue == 'Approve' || btnValue == 'Reject' || btnValue == 'Recall') {
                         msgTxt = res;
                      }
                         this.toastMessage("Error",'error',msgTxt);
                    	 this.windowTimeOut();
                   }          
                }      
                });    
                $A.enqueueAction(aprAction);               
 
                //Manasa
                //$A.get('e.force:refreshView').fire();
            }
            else if (btnValue == 'Submit for Approval') {
                var pfrIDs = [];
                pfrIDs.push(component.get("v.recordId"));
                var action = component.get("c.submitForApproval");
                action.setParams({
                    "pfrIds": pfrIDs,
                    "approvalComments" : component.get("v.approvalComments")
                })
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        
                        this.toastMessage($A.get("$Label.c.Core_MDF_SuccessToastTitle"),'success',$A.get("$Label.c.Core_MDF_Activity_SubmittedForApproval"));
                        this.windowTimeOut();
                    }
                });
                $A.enqueueAction(action);
            }
        }
    },
    toastMessage : function(toastTitleLabel,toastTypeLabel,toastMessageLabel){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: toastTitleLabel,
            type: toastTypeLabel,
            message: toastMessageLabel,
            mode: 'sticky',
        });
        toastEvent.fire();  
    },
    windowTimeOut : function(){
        window.setTimeout(
            $A.getCallback(function () {
                window.location.reload();
            }), 3000
        );
    },
    sendActivityForExternalApproval : function(component){
        var pfrIDs = [];
        pfrIDs.push(component.get("v.recordId"));
        var action = component.get("c.submitForApprovalClosed");
        action.setParams({
        "pfrIds": pfrIDs,
         "comments" : component.get("v.approvalComments")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.toastMessage($A.get("$Label.c.Core_MDF_SuccessToastTitle"),'success',$A.get("$Label.c.Core_MDF_Activity_Approved"));
                this.windowTimeOut();
            }
        });
        $A.enqueueAction(action);
    },
    //common toast event to handle success and error scenarios
    fireToastEvent: function (message, duration, type) {
        $A.get("e.force:closeQuickAction").fire();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: message,
            duration: duration,
            key: "info_alt",
            type: type,
            mode: 'sticky',
        });
        toastEvent.fire();
    }
})