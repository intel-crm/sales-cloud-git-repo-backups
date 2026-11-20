public without sharing class Core_MDF_PFR_Approval
{  
    static final String APPROVE_BUTTON = 'Approve';
    static final String DECLINE_BUTTON = 'Decline';
    // Enhanced wrapper class for AI response with file support
    public class AIResponseWrapper {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String decision { get; set; }
        @AuraEnabled public String formattedContent { get; set; }
        @AuraEnabled public String errorMessage { get; set; }
        @AuraEnabled public List<String> filesAnalyzed { get; set; }
        @AuraEnabled public Boolean hasFileContent { get; set; }
        
        public AIResponseWrapper() {
            this.success = false;
            this.filesAnalyzed = new List<String>();
            this.hasFileContent = false;
        }
    }
    
    /**
     * Store AI recommendation when it's first generated
     */
    @AuraEnabled
    public static void storeAIRecommendation(Id recordId, String aiRecommendation, String aiDetails) {
        try {
                // Check if recommendation already exists for this record and user
            List<Core_MDF_AI_Recommendation_Tracking__c> existingRecs = [
                SELECT Id 
                FROM Core_MDF_AI_Recommendation_Tracking__c 
                WHERE Core_MDF_Activity__c = :recordId 
                AND Core_MDF_User__c = :UserInfo.getUserId()
                LIMIT 1
            ];
            
                // Only create if doesn't exist
            if (existingRecs.isEmpty()) {
                Core_MDF_AI_Recommendation_Tracking__c trackingRecord = new Core_MDF_AI_Recommendation_Tracking__c();
                trackingRecord.Core_MDF_Activity__c = recordId;
                trackingRecord.Core_MDF_User__c = UserInfo.getUserId();
                trackingRecord.Core_MDF_AI_Recommendation__c = aiRecommendation;
                trackingRecord.Core_MDF_AI_Recommendation_Details__c = aiDetails;
                trackingRecord.Core_MDF_AI_Source_Type__c = 'Approval Process';
                
                insert trackingRecord;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error storing recommendation: ' + e.getMessage());
        }
    }
    
    /**
     * Track AI recommendation usage when user makes a decision
     */
    @AuraEnabled
    public static void trackAIRecommendationUsage(Id recordId, String aiRecommendation, 
                                                String aiDetails, String userDecision) {
        try {
                // Find existing recommendation record
            List<Core_MDF_AI_Recommendation_Tracking__c> existingRecs = [
                SELECT Id, Core_MDF_AI_Recommendation__c, Core_MDF_User_Decision__c, 
                       Core_MDF_Recommendation_Used__c, Core_MDF_AI_Recommendation_Details__c,
                       Core_MDF_Approval_Stage__c,Core_MDF_Activity_Last_Modified_Date__c
                FROM Core_MDF_AI_Recommendation_Tracking__c 
                WHERE Core_MDF_Activity__c = :recordId 
                AND Core_MDF_User__c = :UserInfo.getUserId() ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            
            // If no tracking entry exists, AI suggestion was never shown to this user — nothing to track.
            if (existingRecs.isEmpty()) {
                return;
            }

            Core_MDF_AI_Recommendation_Tracking__c trackingRecord = existingRecs[0];

            // Use existing AI recommendation/details if not passed in
            if (String.isBlank(aiRecommendation) && String.isNotBlank(trackingRecord.Core_MDF_AI_Recommendation__c)) {
                aiRecommendation = trackingRecord.Core_MDF_AI_Recommendation__c;
            }
            if (String.isBlank(aiDetails) && String.isNotBlank(trackingRecord.Core_MDF_AI_Recommendation_Details__c)) {
                aiDetails = trackingRecord.Core_MDF_AI_Recommendation_Details__c;
            }
            
                // Update user decision and check if recommendation was used
                trackingRecord.Core_MDF_User_Decision__c = userDecision;
                trackingRecord.Core_MDF_Decision_Date__c = System.now();
                trackingRecord.Core_MDF_AI_Source_Type__c = 'Approval Process';
                
                // Calculate if recommendation was used
                Boolean wasUsed = isRecommendationUsed(aiRecommendation, userDecision);
                trackingRecord.Core_MDF_Recommendation_Used__c = wasUsed;
            
            upsert trackingRecord;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error tracking recommendation usage: ' + e.getMessage());
        }
    }
    
    /**
     * Helper method to determine if the AI recommendation was followed
     */
    private static Boolean isRecommendationUsed(String aiRecommendation, String userDecision) {
        if (String.isBlank(aiRecommendation) || String.isBlank(userDecision)) {
            return false;
        }
        
        String normalizedAI = aiRecommendation.toLowerCase().trim();
        String normalizedUser = userDecision.toLowerCase().trim();
        
        if ((normalizedAI.contains('approve') || normalizedAI.equals('approve')) && 
            (normalizedUser.contains('approve') || normalizedUser.equals('approve'))) {
            return true;
        }
        else if ((normalizedAI.contains('reject') || normalizedAI.equals('reject')) && 
                 (normalizedUser.contains('reject') || normalizedUser.equals('reject'))) {
            return true;
        }
        else if ((normalizedAI.contains('clarification') || normalizedAI.contains('request clarification')) && 
                 (normalizedUser.contains('clarification') || normalizedUser.contains('request clarification'))) {
            return true;
        }
        else if ((normalizedAI.contains('reject') || normalizedAI.equals('reject')) && 
                 (normalizedUser.contains('recall') || normalizedUser.equals('recall'))) {
            return true;
        }
        else if ((normalizedAI.contains('clarification') || normalizedAI.contains('request clarification')) && 
                 (normalizedUser.contains('reject') || normalizedUser.equals('reject'))) {
            return true;
        }
        else if ((normalizedAI.contains('clarification') || normalizedAI.contains('request clarification')) && 
                 (normalizedUser.contains('recall') || normalizedUser.equals('recall'))) {
            return true;
        }
        
        return false;
    }
    
    // Stamps Recall on the latest AI tracking entry if it exists and has no decision yet.
    @TestVisible
    private static void stampRecallOnLatestTrackingRecord(Id recordId) {
        try {
            List<Core_MDF_AI_Recommendation_Tracking__c> existingRecs = [
                SELECT Id, Core_MDF_AI_Recommendation__c, Core_MDF_User_Decision__c
                FROM Core_MDF_AI_Recommendation_Tracking__c
                WHERE Core_MDF_Activity__c = :recordId
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            
            if (existingRecs.isEmpty()) {
                // No tracking entry at all — AI was never viewed for this activity, nothing to stamp
                return;
            }
            
            Core_MDF_AI_Recommendation_Tracking__c trackingRecord = existingRecs[0];
            
            // Stamp only if no decision yet — approver viewed AI but hasn't acted before recall.
            if (String.isBlank(trackingRecord.Core_MDF_User_Decision__c)) {
                trackingRecord.Core_MDF_User_Decision__c = 'Recall';
                trackingRecord.Core_MDF_Decision_Date__c = System.now();
                trackingRecord.Core_MDF_Recommendation_Used__c = isRecommendationUsed(
                    trackingRecord.Core_MDF_AI_Recommendation__c, 'Recall');
                update trackingRecord;
            }
            // Decision already stamped — current approver acted before recall; nothing to overwrite
        } catch (Exception e) {
            // Do not fail the main approval process
        }
    }
    
    @AuraEnabled
    public static AIResponseWrapper getAISuggestionWithDecision(String recordId) {
        AIResponseWrapper wrapper = new AIResponseWrapper();
        
        try {
        // Check 1: Validate email whitelist + IPA + outcome-based + pending review
        if (!hasAIApprovalAccess(recordId)) {
                wrapper.success = false;
                wrapper.errorMessage = '';
                wrapper.decision = '';
                wrapper.formattedContent = '';
                return wrapper;
            }
            
            PartnerFundRequest currentPfr = getCurrentPFRRecord(recordId);
            
            if (currentPfr == null) {
                wrapper.errorMessage = 'Activity record not found. Please refresh and try again.';
                return wrapper;
            }
        // Validate Pending Review status, IPA Program, and Outcome-Based indicator
        String ipaProgram = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Prg_Name');
        
        if (currentPfr.Core_MDF_Fund_Request_Status__c != 'Pending Review' || 
            currentPfr.Core_MDF_Program__c != ipaProgram || 
            currentPfr.Core_MDF_Is_Outcome_Based_Ind__c != true) {
            
            // Provide specific error message based on which validation failed
            if (currentPfr.Core_MDF_Fund_Request_Status__c != 'Pending Review') {
                wrapper.errorMessage = 'AI recommendations are only available for activities in Pending Review status.';
            } else if (currentPfr.Core_MDF_Program__c != ipaProgram) {
                wrapper.errorMessage = 'AI recommendations are only available for IPA program activities.';
            } else if (currentPfr.Core_MDF_Is_Outcome_Based_Ind__c != true) {
                wrapper.errorMessage = 'AI recommendations are only available for outcome-based activities.';
            }
                return wrapper;
            }
            
            // Check activity level cache
            AIResponseWrapper cachedResponse = getCachedAIResponse(
                recordId,
                currentPfr.Core_MDF_Approval_Stage__c,
                currentPfr.LastModifiedDate
            );
            
            if (cachedResponse != null) {
                return cachedResponse;
            }
            
            // Get attached files
            String fileContent = '';
            List<String> contentDocumentIds = getAttachedFiles(recordId);
            
            if (!contentDocumentIds.isEmpty()) {
                fileContent = extractAndCleanFileContent(contentDocumentIds, wrapper);
            }
            
            // Get field-specific rules
            List<Core_MDF_CCP_Custom_Metadata_Utility__c> fieldSpecificRules = getFieldSpecificRulesFromMetadata(currentPfr);
            
            if (fieldSpecificRules.isEmpty()) {
                wrapper.errorMessage = 'No specific field validation rules configured for this program and region.';
                return wrapper;
            }
            
            // Build and call AI
            String promptData = buildEnhancedPrompt(currentPfr, fieldSpecificRules, fileContent);
            Core_MDF_GenAIProcessing.contentWrap aiResponse = Core_MDF_GenAIProcessing.getAIApprovalData(promptData);
            
            if(aiResponse != null && String.isNotBlank(aiResponse.contentFromChatGPT)) {
                String decision = extractDecisionFromAIResponse(aiResponse.contentFromChatGPT);
                String formattedResponse = formatEnhancedAIResponse(aiResponse);
                
                wrapper.success = true;
                wrapper.decision = decision;
                wrapper.formattedContent = formattedResponse;
                
                // Store AI recommendation
                try {
                    storeAIRecommendationWithStage(
                        recordId,
                        decision,
                        formattedResponse,
                        currentPfr.Core_MDF_Approval_Stage__c,
                        currentPfr.LastModifiedDate
                    );
                } catch (Exception storeEx) {
                }
            } else {
                wrapper.errorMessage = 'AI service returned empty response. Please try again later.';
            }
            
            return wrapper;
            
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            wrapper.errorMessage = 'Unable to generate AI recommendation: ' + e.getMessage();
            return wrapper;
        }
    }
    
    @TestVisible
    private static AIResponseWrapper getCachedAIResponse(String recordId, String currentApprovalStage, DateTime activityLastModified) {
        try {
            List<Core_MDF_AI_Recommendation_Tracking__c> existingRecs = [
                SELECT Id, Core_MDF_AI_Recommendation__c, Core_MDF_AI_Recommendation_Details__c,
                       Core_MDF_Approval_Stage__c, Core_MDF_Activity_Last_Modified_Date__c,Core_MDF_User__r.Name,
                       CreatedDate
                FROM Core_MDF_AI_Recommendation_Tracking__c
                WHERE Core_MDF_Activity__c = :recordId
                AND Core_MDF_Approval_Stage__c = :currentApprovalStage
                AND Core_MDF_Activity_Last_Modified_Date__c = :activityLastModified
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            
            if (existingRecs.isEmpty()) {
                return null;
            }
            
            Core_MDF_AI_Recommendation_Tracking__c cachedRec = existingRecs[0];
            
            if (String.isBlank(cachedRec.Core_MDF_AI_Recommendation__c) ||
                String.isBlank(cachedRec.Core_MDF_AI_Recommendation_Details__c)) {
                return null;
            }
            
            AIResponseWrapper cachedWrapper = new AIResponseWrapper();
            cachedWrapper.success = true;
            cachedWrapper.decision = cachedRec.Core_MDF_AI_Recommendation__c;
            cachedWrapper.formattedContent = cachedRec.Core_MDF_AI_Recommendation_Details__c;
            cachedWrapper.hasFileContent = false;
            
            return cachedWrapper;
            
        } catch (Exception e) {
            return null;
        }
    }
    
    @TestVisible
    private static void storeAIRecommendationWithStage(Id recordId, String aiRecommendation,
                                String aiDetails, String approvalStage, DateTime activityLastModified) {
        try {
                // Check if record already exists for same stage + same modified date
                // This prevents duplicate inserts if two users open simultaneously
            List<Core_MDF_AI_Recommendation_Tracking__c> existingRecs = [
                SELECT Id,Core_MDF_Approval_Stage__c,Core_MDF_Activity_Last_Modified_Date__c FROM Core_MDF_AI_Recommendation_Tracking__c
                WHERE Core_MDF_Activity__c = :recordId
                AND Core_MDF_Approval_Stage__c = :approvalStage
                AND Core_MDF_Activity_Last_Modified_Date__c = :activityLastModified
                LIMIT 1
            ];
            
            Core_MDF_AI_Recommendation_Tracking__c trackingRecord;
            
            if (!existingRecs.isEmpty()) {
                trackingRecord = existingRecs[0];
            } else {
                trackingRecord = new Core_MDF_AI_Recommendation_Tracking__c();
                trackingRecord.Core_MDF_Activity__c = recordId;
                trackingRecord.Core_MDF_User__c = UserInfo.getUserId();
            }
            
            trackingRecord.Core_MDF_AI_Recommendation__c = aiRecommendation;
            trackingRecord.Core_MDF_AI_Recommendation_Details__c = aiDetails;
            trackingRecord.Core_MDF_Approval_Stage__c = approvalStage;
            trackingRecord.Core_MDF_Activity_Last_Modified_Date__c = activityLastModified;
            trackingRecord.Core_MDF_AI_Source_Type__c = Label.Core_MDF_AI_Recommendation_Tracking;
            
            upsert trackingRecord;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error storing recommendation: ' + e.getMessage());
        }
    }
    
    // Get attached files for the activity record
    
    @TestVisible
    private static List<String> getAttachedFiles(String recordId) {
        try {
            List<String> contentDocumentIds = new List<String>();
            
            List<ContentDocumentLink> documentLinks = [
                SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :recordId
                AND ContentDocument.PublishStatus = 'P'
                ORDER BY ContentDocument.CreatedDate DESC
            ];
            
            for (ContentDocumentLink link : documentLinks) {
                contentDocumentIds.add(link.ContentDocumentId);
            }
            
            return contentDocumentIds;
        } catch (Exception e) {
            return new List<String>();
        }
    }
    
    // Extract and clean file content
    @TestVisible
    private static String extractAndCleanFileContent(List<String> contentDocumentIds, AIResponseWrapper wrapper) {
        String combinedContent = '';
        
        try {
            List<ContentVersion> versions = [
                SELECT Id, Title, FileExtension, VersionData, ContentSize
                FROM ContentVersion
                WHERE ContentDocumentId IN :contentDocumentIds
                AND IsLatest = true
                ORDER BY CreatedDate DESC
            ];
            
            for (ContentVersion cv : versions) {
                String fileText = extractTextFromFile(cv);
                
                if (String.isNotBlank(fileText)) {
                    String cleanedText = cleanFileContent(fileText);
                    combinedContent += '\n\n--- File: ' + cv.Title + '.' + cv.FileExtension + ' ---\n' + cleanedText;
                    wrapper.filesAnalyzed.add(cv.Title + '.' + cv.FileExtension);
                }
            }
            
            wrapper.hasFileContent = String.isNotBlank(combinedContent);
            
        } catch (Exception e) {
        }
        
        return combinedContent;
    }
    
    // Extract text from individual file
    @TestVisible
    private static String extractTextFromFile(ContentVersion cv) {
        String fileText = '';
        String ext = (cv.FileExtension != null) ? cv.FileExtension.toLowerCase() : '';
        
        try {
            if (ext == 'txt' || ext == 'csv' || ext == 'json' || ext == 'md' || ext == 'html') {
                fileText = cv.VersionData.toString();
            } else if (ext == 'xlsx' || ext == 'xls' || ext == 'xlsm' || ext == 'pdf' || ext == 'docx' || ext == 'pptx') {
                // OCR extraction for complex documents
                fileText = extractWithOCR(cv);
            } else {
                try {
                    fileText = cv.VersionData.toString();
                } catch (Exception e) {
                    fileText = '[Binary file - could not extract text: ' + cv.Title + ']';
                }
            }
            
            // Truncate if too long
            if (fileText.length() > 8000) {
                fileText = fileText.substring(0, 8000) + '\n... [content truncated]';
            }
            
        } catch (Exception e) {
            fileText = '[Error reading file: ' + cv.Title + ' - ' + e.getMessage() + ']';
        }
        
        return fileText;
    }
    
    // OCR extraction using existing infrastructure
    @TestVisible
    private static String extractWithOCR(ContentVersion cv) {
        String description = 'File: ' + cv.Title + '\n\n';
        
        try {
            if (cv.ContentSize > 2500000) {
                return description + '[File too large for processing]';
            }
            
            String base64Data = EncodingUtil.base64Encode(cv.VersionData);
            String outputWithOperationLocId = Core_MDF_FormRecognizerIntegration.readDocumentContents(base64Data);
            
            if (String.isBlank(outputWithOperationLocId)) {
                return description + '[Could not process file content]';
            }
            
            String prebuildReadText = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimEzy_PrebuildRead');
            String rawData = Core_MDF_FormRecognizerIntegration.getDocumentAsString(prebuildReadText, outputWithOperationLocId);
            
            if (String.isNotBlank(rawData)) {
                description += rawData;
            } else {
                description += '[No content could be extracted from file]';
            }
            
        } catch (Exception e) {
            description += '[Error processing file: ' + e.getMessage() + ']';
        }
        
        return description;
    }
    
    // Clean file content to prevent AI service issues
    @TestVisible
    private static String cleanFileContent(String content) {
        if (String.isBlank(content)) {
            return '';
        }
        
        // Use escapeJava() like in claim processing - this handles most JSON issues
        String cleaned = content.escapeJava();
        
        // Additional minimal cleaning for AI processing
        String finalCleaned = cleaned
            .replace('–', '-')
            .replace('—', '-')
            .replace('\u2018', '\'')
            .replace('\u2019', '\'')
            .replace('\u201C', '"')
            .replace('\u201D', '"')
            // Normalize whitespace (escapeJava handles most line breaks)      
            .replaceAll('\\s+', ' ')
            .trim();
        
        if (finalCleaned.length() > 4000) {
            finalCleaned = finalCleaned.substring(0, 4000) + ' [content truncated for AI processing]';
        }
        
        return finalCleaned;
    }
    
    @TestVisible
    private static String buildEnhancedPrompt(PartnerFundRequest currentPfr, 
                        List<Core_MDF_CCP_Custom_Metadata_Utility__c> fieldSpecificRules, String fileContent) {
        try {
            String currentActivityData = buildCurrentActivityData(currentPfr);
            
            if (String.isNotBlank(fileContent)) {
                String safeFileContent = fileContent.escapeJava();
                currentActivityData += '\\n\\nATTACHED DOCUMENTS CONTENT:\\n' + safeFileContent;
            }
            
            String fieldAnalysisPrompt = buildFieldAnalysisPrompt(fieldSpecificRules, String.isNotBlank(fileContent));
            
            String promptTemplate1 = Label.Core_MDF_FinalAI_Approval_Prompt1;
            String promptTemplate2 = Label.Core_MDF_FinalAI_Approval_Prompt2;
            String promptTemplate3 = Label.Core_MDF_FinalAI_Approval_Prompt3;
            
            String promptTemplate = promptTemplate1 + promptTemplate2 + promptTemplate3;
            
            promptTemplate = promptTemplate.replace('{{{currentActivityData}}}', currentActivityData);
            promptTemplate = promptTemplate.replace('{{{fieldSpecificAnalysis}}}', fieldAnalysisPrompt);
            promptTemplate = promptTemplate.replace('\r', '');
            
            return promptTemplate;
            
        } catch (Exception e) {
            throw e;
        }
    }
    
    @TestVisible
    private static String buildFieldAnalysisPrompt(List<Core_MDF_CCP_Custom_Metadata_Utility__c> fieldSpecificRules, Boolean hasFileContent) {
        String analysisPrompt = '';
        
        Map<String, List<Core_MDF_CCP_Custom_Metadata_Utility__c>> fieldRulesMap = new Map<String, List<Core_MDF_CCP_Custom_Metadata_Utility__c>>();
        
        for (Core_MDF_CCP_Custom_Metadata_Utility__c rule : fieldSpecificRules) {
            if (String.isNotBlank(rule.Core_MDF_Sub_Category__c) && String.isNotBlank(rule.Core_MDF_Value__c)) {
                String fieldName = rule.Core_MDF_Sub_Category__c;
                if (!fieldRulesMap.containsKey(fieldName)) {
                    fieldRulesMap.put(fieldName, new List<Core_MDF_CCP_Custom_Metadata_Utility__c>());
                }
                fieldRulesMap.get(fieldName).add(rule);
            }
        }
        
        for (String fieldName : fieldRulesMap.keySet()) {
            analysisPrompt += 'FIELD: ' + fieldName + '\\n';
            analysisPrompt += 'Validation Rules:\\n';
            
            Integer ruleNum = 1;
            for (Core_MDF_CCP_Custom_Metadata_Utility__c rule : fieldRulesMap.get(fieldName)) {
                String cleanRuleValue = rule.Core_MDF_Value__c.replace('\r', '');
                analysisPrompt += '  Rule ' + ruleNum + ': ' + cleanRuleValue + '\\n';
                ruleNum++;
            }
            analysisPrompt += '\\n';
        }
        
        analysisPrompt += '\\nANALYSIS INSTRUCTIONS:\\n';
        analysisPrompt += '1. Compare activity data against validation rules above\\n';
        analysisPrompt += '2. Identify any rule violations or compliance issues\\n';
        
        if (hasFileContent) {
            analysisPrompt += '3. IMPORTANT: Cross-reference activity data with attached document content\\n';
            analysisPrompt += '4. Flag any discrepancies between activity fields and document content\\n';
            analysisPrompt += '5. Use document content as supporting evidence for decisions\\n';
        }
        
        return analysisPrompt;
    }
    
    // Extract decision from AI response
    
    @TestVisible
    private static String extractDecisionFromAIResponse(String aiResponse) {
        if (String.isBlank(aiResponse)) {
            return 'No Decision Available';
        }
        
        try {
            String decisionPattern = '(?i)decision\\s*:?\\s*([^\\n\\r&]+)';
            Pattern p = Pattern.compile(decisionPattern);
            Matcher m = p.matcher(aiResponse);
            
            if (m.find()) {
                String decision = m.group(1).trim();
                decision = decision.replace('**', '')
                                  .replace('[', '')
                                  .replace(']', '')
                                  .replaceAll('[^\\x00-\\x7F]', '');
                
                if (decision.length() > 50) {
                    decision = decision.substring(0, 47) + '...';
                }
                return decision;
            }
            
            String lowerResponse = aiResponse.toLowerCase();
            if (lowerResponse.contains('approve')) {
                return 'Approve';
            } else if (lowerResponse.contains('reject')) {
                return 'Reject';
            } else if (lowerResponse.contains('clarification') || lowerResponse.contains('request')) {
                return 'Request Clarification';
            }
            
            return 'Review Required';
            
        } catch (Exception e) {
            return 'Decision Unavailable';
        }
    }
    
    @TestVisible
    private static String formatEnhancedAIResponse(Core_MDF_GenAIProcessing.contentWrap aiResponse) {
        try {
            if (aiResponse != null && String.isNotBlank(aiResponse.contentFromChatGPT)) {
                String formattedResponse = aiResponse.contentFromChatGPT
                    .replace('&', '\n')
                    .replace('**', '')
                    .replace('[', '')
                    .replace(']', '')
                    .replace('Justification:\n', '')
                    .replace('Justification:', '')
                    .replace('Rule Violation Details', 'Justification')
                    .replaceAll('[^\\x00-\\x7F]', '')
                    .replaceAll('(\r?\n){3,}', '\n\n')
                    .trim();
                
                if (formattedResponse.length() > 2500) {
                    formattedResponse = formattedResponse.substring(0, 2497) + '...';
                }
                
                return formattedResponse;
            } else {
                return 'AI Suggestion: No specific field analysis available. Please review based on standard field validation criteria and business requirements.';
            }
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            return 'AI Suggestion: Error formatting AI response. Please proceed with manual field validation.';
        }
    }
    
    @TestVisible
    private static PartnerFundRequest getCurrentPFRRecord(String recordId) {
        try {
            return [SELECT Id, Core_MDF_Program__c, Core_MDF_Fund_Request_Status__c, 
                    Core_MDF_Approval_Stage__c, RequestedAmount, Core_MDF_Budget_Type_nm__c,
                    Core_MDF_Region_nm__c, Core_MDF_Country_nm__c, Core_MDF_Activity_Description__c, 
                    Core_MDF_Activity_Classification_nm__c, Core_MDF_Sub_Region_nm__c,
                    Core_MDF_Host_Region_txt__c, Core_MDF_Start_Date__c, Core_MDF_End_Date__c,
                    Campaign.Name, ChannelPartner.Name, CreatedDate, Core_MDF_Proposal_Based_Ind__c,
                    Core_MDF_Price_reviewer_check_ind__c, Core_MDF_Approval_Step_Completed__c,
                    Title, Core_MDF_ATF_Flag_nm__c, Core_MDF_Brand_nm__c, Core_MDF_Technology_txt__c,
                    Core_MDF_Tactics_nm__c, Core_MDF_Budget_Amount_Local_amt__c, Core_MDF_Outcomes_nm__c,
                    Core_MDF_Is_Outcome_Based_Ind__c, Core_MDF_Priority_nm__c, Core_MDF_Focus_Area_nm__c,
                    BudgetId, LastModifiedDate
                    FROM PartnerFundRequest 
                    WHERE Id = :recordId LIMIT 1];
        } catch (QueryException e) {
            return null;
        }
    }
    
    // Get field-specific approval rules from Custom Metadata Utility
    @TestVisible
    private static List<Core_MDF_CCP_Custom_Metadata_Utility__c> getFieldSpecificRulesFromMetadata(PartnerFundRequest currentPfr) {
        try {
            String activityRegion = currentPfr.Core_MDF_Host_Region_txt__c;
            
            //Simplified region filter for comma-separated values
            String regionFilter = 'AND (Core_MDF_Region_Country__c = \'' + String.escapeSingleQuotes(activityRegion) + '\' ' +
                                 'OR Core_MDF_Region_Country__c LIKE \'' + String.escapeSingleQuotes(activityRegion) + ',%\' ' +
                                 'OR Core_MDF_Region_Country__c LIKE \'%,' + String.escapeSingleQuotes(activityRegion) + ',%\' ' +
                                 'OR Core_MDF_Region_Country__c LIKE \'%,' + String.escapeSingleQuotes(activityRegion) + '\')';
            
            String baseQuery = 'SELECT Id, Name, Core_MDF_Category__c, Core_MDF_Value__c, Core_MDF_Region_Country__c, ' +
                              'Core_MDF_Program__c, Core_MDF_Sub_Category__c, Core_MDF_Checkbox_Field_1_Ind__c, Core_MDF_Checkbox_Field_2_Ind__c ' +
                              'FROM Core_MDF_CCP_Custom_Metadata_Utility__c ' +
                              'WHERE Core_MDF_Category__c = \'AI Powered Approval Process\' ' +
                              'AND Core_MDF_Is_Active_Ind__c = true ' +
                              'AND Core_MDF_Sub_Category__c != null ' +
                              'AND Core_MDF_Sub_Category__c != \'\' ' +
                              regionFilter;
            
            List<Core_MDF_CCP_Custom_Metadata_Utility__c> allRules = new List<Core_MDF_CCP_Custom_Metadata_Utility__c>();
            
            // IPA Outcome-Based Activity Rules
            if (currentPfr.Core_MDF_Is_Outcome_Based_Ind__c == true) {
                String outcomeBaseQuery = baseQuery +
                    'AND Core_MDF_Program__c = \'' + String.escapeSingleQuotes(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Prg_Name')) + '\' ' +
                    'AND Core_MDF_Checkbox_Field_1_Ind__c = true ' +
                    'AND Core_MDF_Checkbox_Field_2_Ind__c = false ';
                
                allRules.addAll((List<Core_MDF_CCP_Custom_Metadata_Utility__c>) Core_MDF_Custom_Metadata_Utility.getCustomObjectRecordsUsingDynamicQuery(outcomeBaseQuery));
                // Incentive-specific rules
                if (String.isNotBlank(currentPfr.Core_MDF_Tactics_nm__c)
                    && currentPfr.Core_MDF_Tactics_nm__c.containsIgnoreCase('Incentive')) {
                    
                    String incentiveRuleQuery = baseQuery +
                        'AND Core_MDF_Program__c = \'' + String.escapeSingleQuotes(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Prg_Name')) + '\' ' +
                        'AND Core_MDF_Sub_Category__c = \'Core_MDF_Tactics_nm__c\' ' +
                        'AND Core_MDF_Checkbox_Field_1_Ind__c = true ' +
                        'AND Core_MDF_Checkbox_Field_2_Ind__c = true ';
                    
                    allRules.addAll((List<Core_MDF_CCP_Custom_Metadata_Utility__c>) Core_MDF_Custom_Metadata_Utility.getCustomObjectRecordsUsingDynamicQuery(incentiveRuleQuery));
                }
            } 
            
            return allRules;
            
        } catch (Exception e) {
            return new List<Core_MDF_CCP_Custom_Metadata_Utility__c>();
        }
    }
    
    @TestVisible
    private static String buildCurrentActivityData(PartnerFundRequest currentPfr) {
        String activityData = '';
        activityData += 'Activity ID: ' + (currentPfr.Id != null ? currentPfr.Id : 'Not Available') + '\\n';
        activityData += 'Program: ' + (currentPfr.Core_MDF_Program__c != null ? currentPfr.Core_MDF_Program__c : 'Not Provided') + '\\n';
        activityData += 'Activity Name: ' + (currentPfr.Title != null ? currentPfr.Title : 'Not Provided') + '\\n';
        activityData += 'Focus Area: ' + (currentPfr.Core_MDF_Focus_Area_nm__c != null ? currentPfr.Core_MDF_Focus_Area_nm__c : 'Not Provided') + '\\n';
        activityData += 'Start Date: ' + (currentPfr.Core_MDF_Start_Date__c != null ? String.valueOf(currentPfr.Core_MDF_Start_Date__c) : 'Not Provided') + '\\n';
        activityData += 'End Date: ' + (currentPfr.Core_MDF_End_Date__c != null ? String.valueOf(currentPfr.Core_MDF_End_Date__c) : 'Not Provided') + '\\n';
        activityData += 'Requested Amount: $' + (currentPfr.RequestedAmount != null ? String.valueOf(currentPfr.RequestedAmount) : '0') + '\\n';
        activityData += 'Budget Type: ' + (currentPfr.Core_MDF_Budget_Type_nm__c != null ? currentPfr.Core_MDF_Budget_Type_nm__c : 'Not Provided') + '\\n';
        activityData += 'Region: ' + (currentPfr.Core_MDF_Region_nm__c != null ? currentPfr.Core_MDF_Region_nm__c : 'Not Provided') + '\\n';
        activityData += 'Host Region: ' + (currentPfr.Core_MDF_Host_Region_txt__c != null ? currentPfr.Core_MDF_Host_Region_txt__c : 'Not Provided') + '\\n';
        activityData += 'Country: ' + (currentPfr.Core_MDF_Country_nm__c != null ? currentPfr.Core_MDF_Country_nm__c : 'Not Provided') + '\\n';
        activityData += 'Activity Classification: ' + (currentPfr.Core_MDF_Activity_Classification_nm__c != null ? currentPfr.Core_MDF_Activity_Classification_nm__c : 'Not Provided') + '\\n';
        activityData += 'Current Status: ' + (currentPfr.Core_MDF_Fund_Request_Status__c != null ? currentPfr.Core_MDF_Fund_Request_Status__c : 'Not Provided') + '\\n';
        activityData += 'Approval Stage: ' + (currentPfr.Core_MDF_Approval_Stage__c != null ? currentPfr.Core_MDF_Approval_Stage__c : 'Not Provided') + '\\n';
        activityData += 'Partner: ' + (currentPfr.ChannelPartner?.Name != null ? currentPfr.ChannelPartner.Name : 'Not Provided') + '\\n';
        activityData += 'Brand: ' + (currentPfr.Core_MDF_Brand_nm__c != null ? currentPfr.Core_MDF_Brand_nm__c : 'Not Provided') + '\\n';
        activityData += 'Priority: ' + (currentPfr.Core_MDF_Priority_nm__c != null ? currentPfr.Core_MDF_Priority_nm__c : 'Not Provided') + '\\n';
        activityData += 'Outcome Metric: ' + (currentPfr.Core_MDF_Outcomes_nm__c != null ? currentPfr.Core_MDF_Outcomes_nm__c : 'Not Provided') + '\\n';
        activityData += 'Tactic: ' + (currentPfr.Core_MDF_Tactics_nm__c != null ? currentPfr.Core_MDF_Tactics_nm__c : 'Not Provided') + '\\n';
        activityData += 'ATF Flag: ' + (currentPfr.Core_MDF_ATF_Flag_nm__c != null ? currentPfr.Core_MDF_ATF_Flag_nm__c : 'Not Provided') + '\\n';
        activityData += 'Technology: ' + (currentPfr.Core_MDF_Technology_txt__c != null ? currentPfr.Core_MDF_Technology_txt__c : 'Not Provided') + '\\n';
        activityData += 'Price Reviewer Required: ' + (currentPfr.Core_MDF_Price_reviewer_check_ind__c != null ? String.valueOf(currentPfr.Core_MDF_Price_reviewer_check_ind__c) : 'true') + '\\n';
        activityData += 'Approval Steps Completed: ' + (currentPfr.Core_MDF_Approval_Step_Completed__c != null ? String.valueOf(currentPfr.Core_MDF_Approval_Step_Completed__c) : '0');
        
        if (String.isNotBlank(currentPfr.Core_MDF_Activity_Description__c)) {
            String description = currentPfr.Core_MDF_Activity_Description__c.length() > 300 ? 
                currentPfr.Core_MDF_Activity_Description__c.substring(0, 300) + '...' : 
                currentPfr.Core_MDF_Activity_Description__c;
            activityData += '\\nDescription: ' + description;
        }
        
        // Focus Area + Budget Validation Block
        if (currentPfr.Core_MDF_Is_Outcome_Based_Ind__c == true && String.isNotBlank(currentPfr.Core_MDF_Focus_Area_nm__c) && currentPfr.BudgetId != null) {
            String focusAreaBudgetDetails = getFocusAreaBudgetDetails(currentPfr.BudgetId);
            activityData += '\\n\\nFOCUS AREA AND BUDGET VALIDATION DETAILS:\\n';
            activityData += 'Selected Focus Area on Activity: ' + currentPfr.Core_MDF_Focus_Area_nm__c + '\\n';
            activityData += focusAreaBudgetDetails;
            activityData += 'VALIDATION NOTE: Please validate the selected Focus Area and the associated budget details above against the Focus Area specific rules.';
        }
        
        if (currentPfr.Core_MDF_Is_Outcome_Based_Ind__c == true && String.isNotBlank(currentPfr.Core_MDF_Outcomes_nm__c)) {
            String activityOutcomeDetails = getActivityOutcomeDetails(currentPfr.Id);
            activityData += '\\n\\nOUTCOME METRIC AND ACTIVITY OUTCOME DETAILS:\\n';
            activityData += 'Selected Outcome Metric: ' + currentPfr.Core_MDF_Outcomes_nm__c + '\\n';
            activityData += activityOutcomeDetails;
            activityData += 'VALIDATION NOTE: Validate outcome metric, baseline and goal values against Outcome specific rules.';
        }
        //Incentive Segment Details Block
        if (currentPfr.Core_MDF_Is_Outcome_Based_Ind__c == true && String.isNotBlank(currentPfr.Core_MDF_Tactics_nm__c) && currentPfr.Core_MDF_Tactics_nm__c.containsIgnoreCase('Incentive')) {
            String incentiveSegmentDetails = getIncentiveSegmentDetails(currentPfr.Id);
            activityData += '\\n\\nINCENTIVE TACTIC - SEGMENT MAPPING DETAILS:\\n';
            activityData += 'Tactic Value on Activity: ' + currentPfr.Core_MDF_Tactics_nm__c + '\\n';
            activityData += incentiveSegmentDetails;
            activityData += 'VALIDATION NOTE: Please validate the incentive segment mapping details above against the Incentive specific rules.';
        }
        
        return activityData;
    }
    
    //Fetch budget details from PartnerMarketingBudget using BudgetId from the activity
    @TestVisible
    private static String getFocusAreaBudgetDetails(Id budgetId) {
        String budgetDetails = '';
        try {
            List<PartnerMarketingBudget> budgets = [
                SELECT Id, Title, Description, Core_MDF_Budget_Comments__c, Core_MDF_Program_Nm__c,
                       Core_MDF_Budget_Partner__c, Core_MDF_Budget_Type__c, StartDate, EndDate,
                       Amount, TotalAllocatedAmount
                FROM PartnerMarketingBudget
                WHERE Id = :budgetId
                LIMIT 1
            ];
            
            if (!budgets.isEmpty()) {
                PartnerMarketingBudget budget = budgets[0];
                budgetDetails += 'Budget Title: ' + (budget.Title != null ? budget.Title : 'Not Provided') + '\\n';
                budgetDetails += '  Budget Description: ' + (budget.Description != null ? budget.Description : 'Not Provided') + '\\n';
                budgetDetails += '  Budget Comments: ' + (budget.Core_MDF_Budget_Comments__c != null ? budget.Core_MDF_Budget_Comments__c : 'Not Provided') + '\\n';
                budgetDetails += '  Budget Program: ' + (budget.Core_MDF_Program_Nm__c != null ? budget.Core_MDF_Program_Nm__c : 'Not Provided') + '\\n';
                budgetDetails += '  Budget Partner: ' + (budget.Core_MDF_Budget_Partner__c != null ? budget.Core_MDF_Budget_Partner__c : 'Not Provided') + '\\n';
                budgetDetails += '  Budget Type: ' + (budget.Core_MDF_Budget_Type__c != null ? budget.Core_MDF_Budget_Type__c : 'Not Provided') + '\\n';
                budgetDetails += '  Budget Start Date: ' + (budget.StartDate != null ? String.valueOf(budget.StartDate) : 'Not Provided') + '\\n';
                budgetDetails += '  Budget End Date: ' + (budget.EndDate != null ? String.valueOf(budget.EndDate) : 'Not Provided') + '\\n';
                budgetDetails += '  Total Budget Amount: ' + (budget.Amount != null ? String.valueOf(budget.Amount) : 'Not Provided') + '\\n';
                budgetDetails += '  Total Allocated Amount: ' + (budget.TotalAllocatedAmount != null ? String.valueOf(budget.TotalAllocatedAmount) : 'Not Provided') + '\\n';
            } else {
                budgetDetails += 'Budget Details: No budget record found.\\n';
            }
        } catch (Exception e) {
            budgetDetails += 'Budget Details: Unable to retrieve.\\n';
        }
        return budgetDetails;
    }
    
    // Fetch Activity Outcome details related to the PFR record
    @TestVisible
    private static String getActivityOutcomeDetails(Id recordId) {
        String outcomeDetails = '';
        try {
            List<Core_MDF_Activity_Outcome__c> outcomeRecords = [
                SELECT Id, Name, Core_MDF_Active_Ind__c, Core_MDF_Baseline_Value_nbr__c,
                       Core_MDF_Goal_Value_nbr__c, Core_MDF_Outcome_Metric_nm__c,
                       Core_MDF_Baseline_Period_nm__c, Core_MDF_Result_Value_nbr__c
                FROM Core_MDF_Activity_Outcome__c
                WHERE Core_MDF_Activity_Id__c = :recordId
                ORDER BY Name ASC
            ];
            
            if (!outcomeRecords.isEmpty()) {
                outcomeDetails += 'Activity Outcome Records (' + outcomeRecords.size() + ' found):\\n';
                Integer outcomeNum = 1;
                for (Core_MDF_Activity_Outcome__c outcome : outcomeRecords) {
                      outcomeDetails += 'Outcome ' + outcomeNum + ':\\n';
                      outcomeDetails += 'Outcome Name: ' + (outcome.Name != null ? outcome.Name : 'Not Provided') + '\\n';
                      outcomeDetails += 'Outcome Metric: ' + (outcome.Core_MDF_Outcome_Metric_nm__c != null ? outcome.Core_MDF_Outcome_Metric_nm__c : 'Not Provided') + '\\n';
                      outcomeDetails += 'Is Active: ' + (outcome.Core_MDF_Active_Ind__c != null ? String.valueOf(outcome.Core_MDF_Active_Ind__c) : 'Not Provided') + '\\n';
                      outcomeDetails += 'Baseline Period: ' + (outcome.Core_MDF_Baseline_Period_nm__c != null ? outcome.Core_MDF_Baseline_Period_nm__c : 'Not Provided') + '\\n';
                      outcomeDetails += 'Baseline Value: ' + (outcome.Core_MDF_Baseline_Value_nbr__c != null ? String.valueOf(outcome.Core_MDF_Baseline_Value_nbr__c) : 'Not Provided') + '\\n';
                      outcomeDetails += 'Goal Value: ' + (outcome.Core_MDF_Goal_Value_nbr__c != null ? String.valueOf(outcome.Core_MDF_Goal_Value_nbr__c) : 'Not Provided') + '\\n';
                      outcomeDetails += 'Result Value: ' + (outcome.Core_MDF_Result_Value_nbr__c != null ? String.valueOf(outcome.Core_MDF_Result_Value_nbr__c) : 'Not Yet Available') + '\\n';
                    outcomeNum++;
                }
            } else {
                outcomeDetails += 'Activity Outcome Records: No outcome records found for this activity.\\n';
            }
        } catch (Exception e) {
            outcomeDetails += 'Activity Outcome Records: Unable to retrieve outcome details.\\n';
        }
        return outcomeDetails;
    }
    // Fetch Incentive Segment Mapping details - called only when Tactic contains "Incentive"
    @TestVisible
    private static String getIncentiveSegmentDetails(Id recordId) {
        String segmentDetails = '';
        try {
            List<Core_MDF_Activity_Segment_Mapping__c> segmentRecords = [
                SELECT Id,Core_MDF_Partner_Fund_Request_id__c, Core_MDF_Segment_Name_nm__c, Core_MDF_Active_ind__c,
                       Core_MDF_Minimum_Forecast_Volume_nbr__c, Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c,Core_MDF_SPIF_Notes_txt__c,Core_MDF_SPIF_Notes_internal_only_txt__c,
                       Core_MDF_Maximum_Bundled_Volume_nbr__c, Core_MDF_Maximum_Cost_of_Bundle_nbr__c,
                       Core_MDF_Estimated_Share_of_SPIF_amt__c
                FROM Core_MDF_Activity_Segment_Mapping__c
                WHERE Core_MDF_Partner_Fund_Request_id__c = :recordId
                ORDER BY Core_MDF_Segment_Name_nm__c ASC
            ];
            
            if (!segmentRecords.isEmpty()) {
                segmentDetails += 'Incentive Segment Mapping Records (' + segmentRecords.size() + ' record(s) found):\\n';
                Integer segmentNum = 1;
                for (Core_MDF_Activity_Segment_Mapping__c segment : segmentRecords) {
                        segmentDetails += 'Segment ' + segmentNum + ':\\n';
                        
                        // Send each field only if value is present
                        if (String.isNotBlank(segment.Core_MDF_Segment_Name_nm__c)) {
                            segmentDetails += '  Segment Name: ' + segment.Core_MDF_Segment_Name_nm__c + '\\n';
                        }
                        if (segment.Core_MDF_Active_ind__c != null) {
                            segmentDetails += '  Is Active: ' + String.valueOf(segment.Core_MDF_Active_ind__c) + '\\n';
                        }
                        if (segment.Core_MDF_Minimum_Forecast_Volume_nbr__c != null) {
                            segmentDetails += '  Minimum Forecast Volume: ' + String.valueOf(segment.Core_MDF_Minimum_Forecast_Volume_nbr__c) + '\\n';
                        }
                        if (segment.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c != null) {
                            segmentDetails += '  SPIF Amount (Dollar Per Unit): ' + String.valueOf(segment.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c) + '\\n';
                        }
                        if (String.isNotBlank(segment.Core_MDF_SPIF_Notes_txt__c)) {
                            segmentDetails += '  SPIF Notes: ' + segment.Core_MDF_SPIF_Notes_txt__c + '\\n';
                        }
                        if (String.isNotBlank(segment.Core_MDF_SPIF_Notes_internal_only_txt__c)) {
                            segmentDetails += '  SPIF Notes (Internal Only): ' + segment.Core_MDF_SPIF_Notes_internal_only_txt__c + '\\n';
                        }
                        if (segment.Core_MDF_Maximum_Bundled_Volume_nbr__c != null) {
                            segmentDetails += '  Maximum Bundled Volume: ' + String.valueOf(segment.Core_MDF_Maximum_Bundled_Volume_nbr__c) + '\\n';
                        }
                        if (segment.Core_MDF_Maximum_Cost_of_Bundle_nbr__c != null) {
                            segmentDetails += '  Maximum Cost of Bundle: ' + String.valueOf(segment.Core_MDF_Maximum_Cost_of_Bundle_nbr__c) + '\\n';
                        }
                        if (segment.Core_MDF_Estimated_Share_of_SPIF_amt__c != null) {
                            segmentDetails += '  Estimated Share of SPIF Amount: ' + String.valueOf(segment.Core_MDF_Estimated_Share_of_SPIF_amt__c) + '\\n';
                        }
                        
                        segmentNum++;
                    }
            } else {
                segmentDetails += 'No segment mapping records found.\\n';
            }
        } catch (Exception e) {
            segmentDetails += 'Incentive Segment Mapping Records: Unable to retrieve segment mapping details.\\n';
        }
        return segmentDetails;
    }
    /*****************************************************************************************************
Method Name : loadPFRRecord
@return     : Object
@parameters : PFR Record
Description : US106541 - Create Activity initial screen
Added By    : Sridhar on 3-Jun-2020
Modified By : Nuzhath Zaiba                  Date:  14/11/2019                  Changes:None
              Ramapriya                 07-25-2025                          Added status check as part of In-progress Activity Edit 
******************************************************************************************************/
    @AuraEnabled
    public static userPermissionApproval loadPFRRecord(String pfrId)
    {
        userPermissionApproval userPermissionApprovalPFR = new userPermissionApproval();
        userPermissionApprovalPFR.isUserPCTApprover = false;
         // ** NEW DUAL-ROLE PROPERTY **
        userPermissionApprovalPFR.isIPAAccountMgrAndPCTApprover = false;
        List<String> pfrIds = new List<String>();
       try{
        pfrIds.add(pfrId);
        List<String> ccfDcfProgramStrList = new List<String>();
        ccfDcfProgramStrList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCFDCF_RecordType_API_Name').split(',');
        List<String> opalBudgetTypeList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_OPAL_BudgetTypes').Split(';');  
        Boolean isLoggedInUserApprover = false;
        // US949836 : New Budget Type field changes replaced txt field with new global picklist field
        // US1072007 : [RMF] - Ability for RSM to Edit an Activity when in Geo Lead's Queue
            PartnerFundRequest pfrval= new PartnerFundRequest();
            List<PartnerFundRequest> pfrvalList = [SELECT Id,Core_MDF_Activity_CreatedByExternalUsr__c,Core_MDF_L1_Approver_Id__c,
                                                   Core_MDF_Approval_Step_Completed__c,ChannelPartnerId,Core_MDF_Host_Region_or_Region_txt__c,
                                                   ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Country_nm__c,
                                                   Core_MDF_Approval_Status_Stage_txt__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Region_nm__c,
                                                   Core_MDF_Fund_Request_Status__c,Core_MDF_Activity_Closure_Type__c,
                                                   recordtype.developername,Core_MDF_Program__c,Core_MDF_Activity_Classification_nm__c,Core_MDF_Proposal_Based_Ind__c,
                                                   Core_MDF_Approval_Stage__c,Core_MDF_Host_Region_txt__c,Campaign.Core_MDF_Account__r.Id,Core_MDF_Campaign_Ultimate_Account_Id__c,
                                                   Core_MDF_Ultimate_Account_Id__c,Core_MDF_Sub_Region_nm__c,Core_MDF_Additional_Review_Type_txt__c,Core_MDF_Is_Outcome_Based_Ind__c 
                                                FROM PartnerFundRequest 
                                               where Id IN: pfrIds LIMIT 1];
        if(pfrvalList != null && !pfrvalList.isEmpty()){
           pfrval = pfrvalList[0];
	   userPermissionApprovalPFR.isOutcomebaseActivity = pfrval.Core_MDF_Is_Outcome_Based_Ind__c; 
        }        
      /* ProcessInstanceWorkItem piwitm = [SELECT ProcessInstance.TargetObjectId, Id 
                                                  FROM ProcessInstanceWorkItem
                                                  WHERE ProcessInstance.Status = 'Pending' AND
                                                      ProcessInstance.TargetObjectId =: pfrId LIMIT 1];*/
        
         List<ProcessInstanceWorkItem> piwitmList = [SELECT ProcessInstance.TargetObjectId, Id 
                                                  FROM ProcessInstanceWorkItem
                                                  WHERE ProcessInstance.Status = 'Pending' AND
                                                      ProcessInstance.TargetObjectId =: pfrId LIMIT 1];
        
        ProcessInstanceWorkItem piwitm;
        if(piwitmList != null && !piwitmList.isEmpty()){
            piwitm = piwitmList[0];
        }
        List<String> ctryList = new List<String>();
        
        if(pfrval.Core_MDF_Country_nm__c != null && pfrval.Core_MDF_Country_nm__c.contains(';')){
            ctryList.addAll(pfrval.Core_MDF_Country_nm__c.split(';'));
        } 
        else{
            ctryList.add(pfrval.Core_MDF_Country_nm__c);
        }
       

        //TWC702-1949: [Technical] [X-Platform] - Account Based PCT approvers
        if(pfrval.Core_MDF_Approval_Stage__c != null && pfrval.Core_MDF_Approval_Stage__c == 'Price Reviewer'){
               //userPermissionApprovalPFR.isUserPCTApprover = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfrval.ChannelPartnerId, pfrval.recordType.DeveloperName, ctryList, pfrval.Core_MDF_Approval_Stage__c, UserInfo.getUserId());
                userPermissionApprovalPFR.isUserPCTApprover = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfrval,UserInfo.getUserId());
            // ** NEW DUAL-ROLE LOGIC **
                // Check if user is also an IPA Account Manager AND the designated approver for the PFR
                if(userPermissionApprovalPFR.isUserPCTApprover && isCustomPermissionAssigned('Core_MDF_CCP_Internal_IPA_Acct_Mgr')) {
                    userPermissionApprovalPFR.isIPAAccountMgrAndPCTApprover = true;
        }
	}
         else if(pfrval.Core_MDF_Approval_Stage__c != null && pfrval.Core_MDF_Approval_Stage__c == 'L1 Approval'){
          
                //userPermissionApprovalPFR.isLevel1Approver = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfrval.ChannelPartnerId, pfrval.recordType.DeveloperName, ctryList, pfrval.Core_MDF_Approval_Stage__c, UserInfo.getUserId());
             if(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name').equals(pfrval.Core_MDF_Program__c)){
           userPermissionApprovalPFR.isLevel1Approver = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover( pfrval,UserInfo.getUserId());
             }
            else {
                isLoggedInUserApprover = Core_MDF_GeneralPurpose_UI_Utility.isApprover(pfrval.ChannelPartnerId,pfrval.Campaign.Core_MDF_Account__r.Id,pfrval.recordType.DeveloperName,ctryList,pfrval.Core_MDF_Budget_Type_nm__c,UserInfo.getUserId());
            }
             
            // userPermissionApprovalPFR.isLevel1Approver = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover( pfrval,UserInfo.getUserId());
            
             /*if(opalBudgetTypeList.contains(pfrval.Core_MDF_Budget_Type_nm__c)){
                 isLoggedInUserApprover = userPermissionApprovalPFR.isLevel1Approver;
             }*/
        }
         else if(pfrval.Core_MDF_Approval_Stage__c != null && pfrval.Core_MDF_Approval_Stage__c == 'Program Office Reviewer'){
           
                userPermissionApprovalPFR.isPORApprover = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover( pfrval,UserInfo.getUserId()); 
         }
             else if(pfrval.Core_MDF_Approval_Stage__c != null && pfrval.Core_MDF_Approval_Stage__c == 'Geo Lead Approval'){
                    
                    userPermissionApprovalPFR.isGeoLeadApprover = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover( pfrval,UserInfo.getUserId());       
             }
           //Additional reviewer
        else if(pfrval.Core_MDF_Approval_Stage__c != null && pfrval.Core_MDF_Approval_Stage__c == 'Additional Reviewer'){
                    
                    userPermissionApprovalPFR.isAdditionalReviewer = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover( pfrval,UserInfo.getUserId());      
                    //userPermissionApprovalPFR.isAdditionalReviewer=true;  
             }

            else if(pfrval.Core_MDF_Approval_Stage__c != null && (pfrval.Core_MDF_Approval_Stage__c ==  Core_MDF_CCP_ConstantClass.L2_REGIONAL_MARKETING||pfrval.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L2_REGIONAL_SALES) &&  pfrval.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Prg_Name')){
                userPermissionApprovalPFR.isLevel2Approver = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfrval,UserInfo.getUserId()); 
            }
        else{
          
            isLoggedInUserApprover = Core_MDF_GeneralPurpose_UI_Utility.isApprover(pfrval.ChannelPartnerId,pfrval.Campaign.Core_MDF_Account__r.Id,pfrval.recordType.DeveloperName,ctryList,pfrval.Core_MDF_Budget_Type_nm__c,UserInfo.getUserId());
        }
        userPermissionApprovalPFR.pfrInstance = pfrval;
        String userId = UserInfo.getUserId();
        if (pfrval.recordtype.developername == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Record_Type_Devlpr_Name')){
                if(isCustomPermissionAssigned('Core_MDF_EmeaReviewer')) {
                    userPermissionApprovalPFR.userEmeaReviewer = true;
                    
                }else if(isCustomPermissionAssigned('Core_MDF_ExternalActivityApprover')){
                    
                    userPermissionApprovalPFR.userPermissionsPowerPartner = true;
                    
                }else if(isCustomPermissionAssigned('Core_MDF_CCP_Internal_RMF_Account_Manager')){
                   userPermissionApprovalPFR.isAccountMng = true; 
                }else if(isCustomPermissionAssigned('Core_MDF_PriceReviewer')) {  
                userPermissionApprovalPFR.isPriceReviewer = true; 
            }
            // EOL - commented below OR condition associated to Channel MDF
            }else if(ccfDcfProgramStrList.contains(pfrval.recordtype.developername)  || ((/*pfrval.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ChannelMDF_Program_Name') ||*/ pfrval.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Prg_Name')) && pfrval.Core_MDF_Proposal_Based_Ind__c == false)){
            //US821309 : [Opal] CCF and DCF - Client Acceptance - Added code for OPAL Client Acceptance
                if(isCustomPermissionAssigned('Core_MDF_CCP_Internal_IPA_Acct_Mgr')){
                   userPermissionApprovalPFR.isIPAAccountMgr=true;
                }
            if(isCustomPermissionAssigned('Core_MDF_CCP_External_Activity_Submitter') 
               || isCustomPermissionAssigned('Core_MDF_CCP_External_IPA_Activity_Manager')){  
                userPermissionApprovalPFR.userPermissionsPowerPartner = true; 
            }
            //TWC702-1949: [Technical] [X-Platform] - Account Based PCT approvers
            if(isCustomPermissionAssigned('Core_MDF_PriceReviewer')) { userPermissionApprovalPFR.isPriceReviewer = true;   
            }
            //US946280 : [Opal CCF/DCF] - Activity Edits - Activity Status = Pending Approval - Show Reject button for Internal Account Manager
           
            if((isCustomPermissionAssigned(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Field_Owner')) || isCustomPermissionAssigned(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Field_Owner'))) &&
               (pfrval.Core_MDF_Budget_Type_nm__c == 'MDF' || pfrval.Core_MDF_Budget_Type_nm__c == 'MDF+')){
                   userPermissionApprovalPFR.isFieldOwner = true;    
               }else if((isCustomPermissionAssigned(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Marketing_Owner')) || isCustomPermissionAssigned(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Marketing_Owner'))) &&
                        (pfrval.Core_MDF_Budget_Type_nm__c == 'OEM CMP' || pfrval.Core_MDF_Budget_Type_nm__c == 'Service Provider CMP')){userPermissionApprovalPFR.isMarktngOwner = true;    
            }
            //Opal approaval chnages-Ealisha
            //If budget type is opal and program is ccfdcf,
            //then based on acct all acct managers can approve/reject the activity 
            //along with the actual approval(tagged on the pfr)                     
            if(opalBudgetTypeList.contains(pfrval.Core_MDF_Budget_Type_nm__c)

              && pfrval.Core_MDF_Activity_CreatedByExternalUsr__c
              && piwitm != null && pfrval.Core_MDF_Fund_Request_Status__c == 'Pending Review' && UserInfo.getUserType() == 'Standard'
                && (pfrval.Core_MDF_Approval_Step_Completed__c == 0 && pfrval.Core_MDF_L1_Approver_Id__c == null)){
                    
                  if(isLoggedInUserApprover){
                      
                     userPermissionApprovalPFR.isIntelActivityApprover = true;
                  }
                }
            } else if(pfrval.recordtype.developername == Core_MDF_CCP_ConstantClass.PFR_EEF_RECORDTYPE
                     && pfrval.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_REVIEW_STATUS){
                if(pfrval.Core_MDF_Approval_Stage__c != null 
                    && pfrval.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L1_APPROVAL_PRIMARY_PARTNER
                    && isCustomPermissionAssigned('Core_MDF_CCP_Internal_EEF_Primary_Account_Manager')
                    && Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfrval,UserInfo.getUserId())){
                        userPermissionApprovalPFR.isL1PrimaryPartnerApprover= true;
                } else if(pfrval.Core_MDF_Approval_Stage__c != null 
                    && pfrval.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L1_APPROVAL_ACTIVATING_PARTNER
                    && isCustomPermissionAssigned('Core_MDF_CCP_Internal_EEF_Activating_Account_Manager')
                    && Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfrval,UserInfo.getUserId())){
                        userPermissionApprovalPFR.isL1ActivatingPartnerApprover = true;
                } else if(pfrval.Core_MDF_Approval_Stage__c != null 
                          && pfrval.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L2_PRIMARY_APPROVAL
                          && isCustomPermissionAssigned('Core_MDF_CCP_Internal_EEF_L2_Approver')
                          && Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfrval,UserInfo.getUserId())){
                            userPermissionApprovalPFR.isL2PrimaryApprover= true;
                } else if(pfrval.Core_MDF_Approval_Stage__c != null 
                          && pfrval.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.PROGRAM_OFFICE_REVIEWER
                          && isCustomPermissionAssigned('Core_MDF_CCP_Internal_Proposal_Activity_POR_Approver')
                          && userPermissionApprovalPFR.isPORApprover){
                            userPermissionApprovalPFR.isEEFPORApprover = true;
                } else if(pfrval.Core_MDF_Approval_Stage__c != null 
                          && pfrval.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.PRICE_REVIEWER
                          && isCustomPermissionAssigned('Core_MDF_PriceReviewer')
                          && userPermissionApprovalPFR.isUserPCTApprover){
                            userPermissionApprovalPFR.isEEFPCTApprover = true;
                }
            } else if(pfrval.recordtype.developername == Core_MDF_CCP_ConstantClass.PFR_EEF_RECORDTYPE
                       && pfrval.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS){
                    if(pfrval.Core_MDF_Approval_Stage__c != null 
                        && pfrval.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.CUSTOMER_ACCEPTANCE_PRIMARY_PARTNER
                        && isCustomPermissionAssigned('Core_MDF_CCP_EEF_Primary_Partner_User')){
                            userPermissionApprovalPFR.isPrimaryPartnerApprover = true;
                    } else if(pfrval.Core_MDF_Approval_Stage__c != null 
                        && pfrval.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.CUSTOMER_ACCEPTANCE_ACTIVATING_PARTNER
                        && isCustomPermissionAssigned('Core_MDF_CCP_EEF_Activating_Partner_User')){
                            userPermissionApprovalPFR.isActivatingPartnerApprover = true;
                }
            }   
              
        else{
            userPermissionApprovalPFR = null;
        }
            // Recall for EEF Program
            if(pfrval.recordtype.developername == Core_MDF_CCP_ConstantClass.PFR_EEF_RECORDTYPE
                        && (((pfrval.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_REVIEW_STATUS
                                || (pfrval.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS
                                    && pfrval.Core_MDF_Approval_Stage__c != Core_MDF_CCP_ConstantClass.CUSTOMER_ACCEPTANCE_ACTIVATING_PARTNER))
                                && isCustomPermissionAssigned('Core_MDF_CCP_External_EEF_Activity_Submitter'))
                        || ((pfrval.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS
                                || (pfrval.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_REVIEW_STATUS
                                        && pfrval.Core_MDF_Approval_Stage__c != Core_MDF_CCP_ConstantClass.L1_APPROVAL_PRIMARY_PARTNER))
                            && isCustomPermissionAssigned('Core_MDF_CCP_Internal_EEF_Primary_Account_Manager'))
                        || ((pfrval.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS
                                || (pfrval.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_REVIEW_STATUS
                                            && pfrval.Core_MDF_Approval_Stage__c != Core_MDF_CCP_ConstantClass.L1_APPROVAL_ACTIVATING_PARTNER))
                            && isCustomPermissionAssigned('Core_MDF_CCP_Internal_EEF_Activating_Account_Manager')))){ 
                userPermissionApprovalPFR.userPermissionsEEFRecall = true; 
            }
        //Add record type & budget type check       
        
            if(userPermissionApprovalPFR != null){
        userPermissionApprovalPFR.pfrMapInstance = new Map<Id,Map<String,String>>();
        userPermissionApprovalPFR.approverAssigned = isApproverAssigned(pfrId,userId,userPermissionApprovalPFR.userPermissionsPowerPartner);
            }
        //userPermissionApprovalPFR.statusMapInstance = new Map<String,String>();
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            
            throw new AuraHandledException(e.getMessage());
        } 
        return userPermissionApprovalPFR;
    }
    /*****************************************************************************************************
    Method Name:        isCustomPermissionAssigned
    @return  :          Boolean
    @parameters:        String - Custom Permission Name
    Description:        This method is used to check if the Custom permission is assigned to the User
    Added By:           Accenture SB
    Modified By:        Date:       Changes:
    ******************************************************************************************************/
    public static Boolean isCustomPermissionAssigned(String customPermissionNameStr){
        Boolean userHasPer = false;
        
        if(customPermissionNameStr != NULL && String.isNotBlank(customPermissionNameStr)){
            userHasPer =  FeatureManagement.checkPermission(customPermissionNameStr);
        }
        return userHasPer;
    }
    /*****************************************************************************************************
Method Name : hasAIApprovalAccess
@return     : Boolean
@parameters : None
Description : Checks if current user has AI approval access by verifying:
              1. User has general approval permissions (from approval roles/stages)
              2. User's email is in the Core_MDF_AI_Approval_Access_Settings custom label
Added By    : Gayathri
Modified By : 
******************************************************************************************************/
    @AuraEnabled
    public static Boolean hasAIApprovalAccess(String recordId) {
        try {
            String approvalEmails = Label.Core_MDF_AI_Approval_Access_Settings;
            String currentUserEmail = UserInfo.getUserEmail();
            
            if (String.isBlank(approvalEmails)) {
                return false;
            }
            
            List<String> emailList = new List<String>();
            for (String email : approvalEmails.split(',')) {
                emailList.add(email.trim().toLowerCase());
            }
            
            if (!emailList.contains(currentUserEmail.toLowerCase())) {
                return false;
            }
            
            PartnerFundRequest pfr = getCurrentPFRRecord(recordId);
            if (pfr == null) {
                return false;
            }
            
            String ipaProgram = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Prg_Name');
            return pfr.Core_MDF_Program__c == ipaProgram && 
                   pfr.Core_MDF_Is_Outcome_Based_Ind__c == true &&
                   pfr.Core_MDF_Fund_Request_Status__c == 'Pending Review';
                   
        } catch (Exception e) {
            return false;
        }
    }
    
    /*****************************************************************************************************
    Method Name :  Update PFR Record on Approval (Updates status to planned when External User Approves)
    Added By    : Sridhar on 3-Jun-2020
    Modified By : Nuzhath Zaiba                  Date:  14/11/2019                  Changes:None
    ******************************************************************************************************/
    @AuraEnabled
    public static Boolean submitForApprovalClosed(List<Id> pfrIds,String comments)
            {
        Boolean isSubmitted = false;
             List<String> pctPfrIds = new List<String>();    
        String pendingReview = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Status_PendingReview');
        String pendingApproval = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Approval_Nm');
        String retailApprovalProcess = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RetailApprovalProcess');        
        
        try{        
            Boolean inApprvlPrs = isApproverAssigned(pfrIds[0], null ,false);
            
            Map<Id,PartnerFundRequest> pfrMapToBeUpdated = new Map<Id,PartnerFundRequest>();            

            for(PartnerFundRequest pfr : [SELECT Id,Core_MDF_Program__c,Core_MDF_Approval_Step_Completed__c, Core_MDF_Fund_Request_Status__c,
                                          Core_MDF_Region_nm__c, RequestedAmount, Core_MDF_Price_reviewer_check_ind__c
                                          FROM PartnerFundRequest
                                          WHERE Id IN :pfrIds ]){
                                              
               
                if(pfr.RequestedAmount < 25000){ 
                    //US1098882: Replaced Core_MDF_Region_cd__c with Core_MDF_Region_nm__c
                    if(pfr.Core_MDF_Region_nm__c == 'EMEA' && !inApprvlPrs){
                        pfr.Core_MDF_Approval_Step_Completed__c = 1;   
                    }else{
                      pfr.Core_MDF_Approval_Step_Completed__c = 0;    
                    }                   
                    if(!pfr.Core_MDF_Price_reviewer_check_ind__c){
                        pfr.Core_MDF_Fund_Request_Status__c = pendingApproval;
                     }
                    else{
                        pfr.Core_MDF_Fund_Request_Status__c = pendingReview;
                        pctPfrIds.add(pfr.Id);
                    }
                }else if(pfr.RequestedAmount >= 25000 && pfr.RequestedAmount < 250000 ){
                    //US1098882: Replaced Core_MDF_Region_cd__c with Core_MDF_Region_nm__c
                    if(pfr.Core_MDF_Region_nm__c == 'EMEA' && !inApprvlPrs){  
                        pfr.Core_MDF_Approval_Step_Completed__c = 2;  
                    }else{
                      pfr.Core_MDF_Approval_Step_Completed__c = 1;    
                    } 
                    if(!pfr.Core_MDF_Price_reviewer_check_ind__c){
                        pfr.Core_MDF_Fund_Request_Status__c = pendingApproval;
                    }else{ 
                        pfr.Core_MDF_Fund_Request_Status__c = pendingReview;
                         pctPfrIds.add(pfr.Id);
                    }
                }else if(pfr.RequestedAmount >= 250000 ){
                    //US1098882: Replaced Core_MDF_Region_cd__c with Core_MDF_Region_nm__c
                    if(pfr.Core_MDF_Region_nm__c == 'EMEA' && !inApprvlPrs){                      pfr.Core_MDF_Approval_Step_Completed__c = 3;   
                    }else{
                      pfr.Core_MDF_Approval_Step_Completed__c = 2;    
                    }
                    if(!pfr.Core_MDF_Price_reviewer_check_ind__c){
                        pfr.Core_MDF_Fund_Request_Status__c = pendingApproval;
                    }else{
                        pfr.Core_MDF_Fund_Request_Status__c = pendingReview;
                        pctPfrIds.add(pfr.Id);
                    }
                }                            
                pfr.Core_MDF_Activity_Closure_Type__c = '';
                pfr.Core_MDF_No_Internal_Close_Date__c = null;  
                pfrMapToBeUpdated.put(pfr.Id,pfr);                
            }
            
            if(pfrMapToBeUpdated != NULL && pfrMapToBeUpdated.Size() > 0){
              
                
                List<Approval.ProcessWorkitemRequest> pwrList = new List<Approval.ProcessWorkitemRequest>(); 
                for(ProcessInstanceWorkItem piwitm : [SELECT ProcessInstance.TargetObjectId, Id 
                                                  FROM ProcessInstanceWorkItem
                                                  WHERE ProcessInstance.Status = 'Pending' AND
                                                      ProcessInstance.TargetObjectId IN:pfrMapToBeUpdated.keySet() LIMIT 1]){
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setAction('Approve');
                    ////[System Comment]- Approved by After The Fact Approver; [Approver Comment]- Test ATF
                    /*String commentsATF = '';
                    if(pfrMapToBeUpdated.get(piwitm.ProcessInstance.TargetObjectId).Core_MDF_Program__c == 'Retail Marketing Funds'){
                        commentsATF = '[System]- Approved by After The Fact Approver';
                    if(String.isNotBlank(comments)){
                        commentsATF = commentsATF + '; [Approver]- '+comments;                                            
                    }  
                    }
                    else{
                        commentsATF = comments;
                    }*/
                    req.setComments(comments);
                    req.setWorkitemId(piwitm.Id);
                    pwrList.add(req);
                }  
                 database.update(pfrMapToBeUpdated.values());
                if(pwrList != NULL && pwrList.Size() > 0){
                   List<Approval.ProcessResult> result = Approval.process(pwrList);
                }  
                
                if(pctPfrIds != NULL && pctPfrIds.Size()>0){
                  
                  for(ProcessInstance pi : [SELECT Id, TargetObjectId, Status
                                           FROM ProcessInstance
                                           WHERE TargetObjectId = :pctPfrIds 
                                           AND Status = 'Pending']){
                     
                     if(pctPfrIds.contains(pi.TargetObjectId)){                        
                         pctPfrIds.remove(pctPfrIds.indexOf(pi.TargetObjectId));
                         
                     }                           
                }
                    List<Approval.ProcessSubmitRequest> appRequests = new List<Approval.ProcessSubmitRequest> ();
                    for(Id pid: pctPfrIds){
                        
                        Approval.ProcessSubmitRequest appObj = new Approval.ProcessSubmitRequest();
                        appObj.setObjectId(pid);
                        appObj.setProcessDefinitionNameOrId(retailApprovalProcess);
                        appRequests.add(appObj);                                   
                    
                    }
                    if (appRequests.size()> 0){   
                            
                            Approval.ProcessResult[] result = Approval.process(appRequests);
                    }    
                    
                }
                              
            }                       
            
            isSubmitted = true;
        }catch (Exception e){ string errorlog = 'Submit for approval failed for activities->' + pfrIds + '-> Error->' + e; Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorlog,'submitForApproval Method'); throw e;}
        return isSubmitted;
    }
    /*****************************************************************************************************
    Method Name :  Update PFR Record on Approval (Updates status to planned when External User Approves)
    Added By    : Sridhar on 3-Jun-2020
    Modified By :                  Date:                   Changes:
    Nuzhath Zaiba                  14/11/2019              None
    ******************************************************************************************************/
    @AuraEnabled
    public static Boolean submitForApproval(List<Id> pfrIds,String approvalComments)
    {
        Map<id,PartnerFundRequest> mapPfr = new Map<id,PartnerFundRequest>();
        List<PartnerFundRequest> listPfr = new List<PartnerFundRequest>();
        List<PartnerFundRequest> pfrvals = new List<PartnerFundRequest>();
        String queryFields = '';
        String querystr = '';
        Boolean isSubmitted = false;
        try
        {
            // Read the field names from fieldset and query the values
            Schema.FieldSet fieldSet = Schema.SObjectType.PartnerFundRequest.FieldSets.Core_MDF_Approval_Field_Set;

            if (fieldSet != null){

                List<String> fields = new  List<String>();

                for(FieldSetMember field: fieldSet.getFields()) {
                    fields.add(field.getFieldPath());
                }
                queryFields = String.join(fields,',');

                querystr = String.format(
                    'SELECT {0} FROM {1} where id IN :pfrIds',
                    new List<String>{
                        String.escapeSingleQuotes(queryFields),
                            String.escapeSingleQuotes('PartnerFundRequest')
                            }
                );
                pfrvals = Database.query(querystr);
                
                for (PartnerFundRequest pfrl : pfrvals){
                    pfrl.Core_MDF_Completed_Approval_Level_Name__c = 'EMEA Reviewer' ;
                    mapPfr.put(pfrl.Id,pfrl); listPfr.add(pfrl);
                }
                
                if(listPfr != NULL && !listPfr.isEmpty()){
                    update listPfr;
                }
                	//Core_MDF_ProcessCCP_PartnerFundRequest.callApprovalProcess( mapPfr, listPfr, null,true); 
            }           
            isSubmitted = true;
        } catch (Exception e){ string errorlog = 'Submit for approval failed for activities->' + pfrIds + '-> Error->' + e; Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorlog,'submitForApproval Method'); throw e;}
        return isSubmitted;
    }

    /*****************************************************************************************************
    Method Name :  isApproverAssigned (Verify the assigned approvers from process instance object)
    Added By    : Sridhar on 3-Jun-2020
    Modified By : Nuzhath Zaiba                  Date:  14/11/2019                  Changes:None
    ******************************************************************************************************/

    @AuraEnabled
    public static Boolean isApproverAssigned(String pfrId, Id userId, Boolean isPartnerUser)
    {
        if (isPartnerUser){return [SELECT Id, TargetObjectId, Status, (select actorid from Workitems where actorid =: userId) FROM ProcessInstance WHERE TargetObjectId =: pfrId and Status =: 'Pending' limit 1].size() > 0;

                          }
        else{
            ProcessInstance[] processInsItem = [SELECT Id, TargetObjectId, Status FROM ProcessInstance WHERE TargetObjectId =: pfrId and Status =: 'Pending' limit 1]; return processInsItem.size() > 0;

        }
    }

    /*****************************************************************************************************
Method Name : approveRejectActivity (Handle the submit or reject actions)
Added By    : Sridhar on 3-Jun-2020
Modified By : Nuzhath Zaiba                  Date:  14/11/2019                  Changes:None
              Ramapriya Rajesh                      25/07/2025                  Added status check as part of 'In-Progress Activity edit'
******************************************************************************************************/
    @AuraEnabled
    public static String approveRejectActivity(Map<Id,Map<String,String>> mapValues,string approvalComments,Boolean isExternal)
    {
        Map<Id,Id>  piList = new Map<Id,Id>();
         List<PartnerFundRequest> pfrToUpdateList = new List<PartnerFundRequest>();
        List<Approval.ProcessWorkitemRequest> processWorkItemReqList = new  List<Approval.ProcessWorkitemRequest>();
        Map<Integer, Id> processIndexToPfrIdMap = new Map<Integer, Id>(); // FIX: Map to track which request belongs to which PFR 
        List<Id> pfrIds = new List<Id>();
        List<PartnerFundRequest> pfrsToBeUpdated = new List<PartnerFundRequest>();
        List<String> opalBudgetTypeList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_OPAL_BudgetTypes').Split(';');
        String msg = '';
        Boolean isFieldUpdate = false;
        List<String> L2_APPROVAL_STAGES=Core_MDF_CCP_ConstantClass.L2_APPROVAL_STAGES;
        
        // *** NEW: Variables for AI recommendation tracking ***
        Map<Id, String> pfrToUserDecisionMap = new Map<Id, String>();
        
        try {
            for(Id pfrId : mapValues.keySet()){
                pfrIds.add(pfrId);
            }
            for(ProcessInstanceWorkItem piwitm : [SELECT ProcessInstance.TargetObjectId,Id FROM ProcessInstanceWorkItem
                                                  WHERE ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId IN:pfrIds]){
                 piList.put(piwitm.ProcessInstance.TargetObjectId, piwitm.Id);
            }
            
            Map<Id,PartnerFundRequest> pfrInstMap = new Map<Id,PartnerFundRequest>();
            for(PartnerFundRequest pfr : [Select Id,Core_MDF_Budget_Type_nm__c,Core_MDF_Program__c,Core_MDF_External_Approval_Comment_txt__c,Core_MDF_Fund_Request_Status__c,Core_MDF_Approval_Stage__c,Core_MDF_IPA_Int_Approver_Comment_txt__c,Core_MDF_Proposal_Based_Ind__c
                                                   FROM PartnerFundRequest 
                                          WHERE Id IN :piList.keySet()]){
                                              pfrInstMap.put(pfr.Id,pfr);
                                          } 
            
            
            String comment, action, btnName = '';
            for(Id pfrId : piList.keySet()) { 
                
                Map<String,String> commentStatus = mapValues.get(pfrId);                
                for (String commentVal : commentStatus.keySet()){
                    
                    comment = commentVal;
                    btnName = commentStatus.get(comment);
                    
                    // *** NEW: Track user decision for AI recommendation tracking ***
                    pfrToUserDecisionMap.put(pfrId, btnName);
                    
                    //if internal user and status is pendign review then get the approval comment
                    
                    
                    if (btnName == 'Reject' || btnName == 'Recall'){
                        
                        action = 'Reject'; 
                        if(btnName == 'Reject' && (pfrInstMap.get(pfrId).Core_MDF_Approval_Stage__c == 'Price Reviewer' 
                                                   || pfrInstMap.get(pfrId).Core_MDF_Approval_Stage__c == 'L1 Approval' 
                                                   || pfrInstMap.get(pfrId).Core_MDF_Approval_Stage__c == 'L2 Approval' 
                                                   || pfrInstMap.get(pfrId).Core_MDF_Approval_Stage__c == 'L2 Regional Sales'  
                                                   || pfrInstMap.get(pfrId).Core_MDF_Approval_Stage__c == 'L2 Regional Marketing'
                                                   || pfrInstMap.get(pfrId).Core_MDF_Approval_Stage__c == 'Program Office Reviewer'
                                                   || pfrInstMap.get(pfrId).Core_MDF_Approval_Stage__c == 'L1 Approval (Primary Partner)'
                                                   || pfrInstMap.get(pfrId).Core_MDF_Approval_Stage__c == 'L1 Approval (Activating Partner)' 
                                                   || pfrInstMap.get(pfrId).Core_MDF_Approval_Stage__c == 'L2 Primary Approval'
                                                   || pfrInstMap.get(pfrId).Core_MDF_Fund_Request_Status__c == 'Pending Approval'
                                                   || pfrInstMap.get(pfrId).Core_MDF_Fund_Request_Status__c == 'In-Progress Pending Approval' ||
                                                   (pfrInstMap.get(pfrId).Core_MDF_Program__c == 'Retail Marketing Funds' && pfrInstMap.get(pfrId).Core_MDF_Fund_Request_Status__c == 'Pending Approval'))){
                                                       comment = approvalComments;
                                                       
                                                   }
                        else if(btnName == 'Recall') {
                            comment = approvalComments ;
                        }
                      
                        //Added by Ealisha--start
                    if(btnName == 'Reject' && opalBudgetTypeList.contains(pfrInstMap.get(pfrId).Core_MDF_Budget_Type_nm__c) && 
                       (pfrInstMap.get(pfrId).Core_MDF_Fund_Request_Status__c == 'Pending Review' || pfrInstMap.get(pfrId).Core_MDF_Fund_Request_Status__c == 'Pending Approval')){
                        action = 'Reject'; 
                        comment = approvalComments;
                    } 
                    //Added by Ealisha--end
                    }
                    
                    else if(btnName == 'Approve'&& (pfrInstMap.get(pfrId).Core_MDF_Fund_Request_Status__c == 'Pending Review' || pfrInstMap.get(pfrId).Core_MDF_Fund_Request_Status__c == 'Pending Approval' ||pfrInstMap.get(pfrId).Core_MDF_Fund_Request_Status__c == 'In-Progress Pending Review'||pfrInstMap.get(pfrId).Core_MDF_Fund_Request_Status__c == 'In-Progress Pending Approval')){
                        action = 'Approve'; 
                        comment = approvalComments;
                        if(pfrInstMap.get(pfrId).Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Prg_Name')
                           && pfrInstMap.get(pfrId).Core_MDF_Proposal_Based_Ind__c == false
                           && (pfrInstMap.get(pfrId).Core_MDF_Fund_Request_Status__c == 'Pending Review' || pfrInstMap.get(pfrId).Core_MDF_Fund_Request_Status__c == 'In-Progress Pending Review')
                           && (pfrInstMap.get(pfrId).Core_MDF_Approval_Stage__c != 'Price Reviewer')) {
                          PartnerFundRequest pfrObj = new PartnerFundRequest( 
                               Id = pfrId,
                               Core_MDF_IPA_Int_Approver_Comment_txt__c = approvalComments
                           );
                           pfrToUpdateList.add(pfrObj);
                               isFieldUpdate=true;
                           }
                    }
                    
                    else{          
                        
                        action = btnName;
                        
                    } 
                    break;
                }                
                // Approval.ProcessResult processResult = null;
                Approval.ProcessWorkitemRequest aprReq = new Approval.ProcessWorkitemRequest();
                aprReq.setComments(comment);
                aprReq.setAction(action);
                aprReq.setWorkitemId(piList.get(pfrId));
                aprReq.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                processIndexToPfrIdMap.put(processWorkItemReqList.size(), pfrId); // FIX: Track index to PFR mapping 
                processWorkItemReqList.add(aprReq);
              /*   processResult = Approval.process(aprReq);

if (processResult != null && !processResult.isSuccess()){

string errorlog = 'Approval failed for activiy ->' + pfrId + ';' ; 
for(Database.Error errDet : processResult.getErrors()){
errorlog += errDet.getMessage();
msg = errDet.getMessage();
} 
Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorlog,'approveRejectActivity Method');
return msg;
}*/
            }
            if( !pfrToUpdateList.isEmpty() && isFieldUpdate ){
                    
                Database.update(pfrToUpdateList);
            }
            
            // FIX: Process results and track which PFRs had successful approvals
            List<Approval.ProcessResult> processResultList = Approval.process(processWorkItemReqList);
            Set<Id> successfulPfrIds = new Set<Id>(); // FIX: Track which PFRs had successful approvals
            if(processResultList!=null && !processResultList.isEmpty()){
                for(Integer i = 0; i < processResultList.size(); i++){
                    Approval.ProcessResult processResult = processResultList[i];
                    if (processResult != null && !processResult.isSuccess()){
                        string errorlog = 'Approval failed for activiy ->' + processResult.getEntityId() + ';' ; 
                        for(Database.Error errDet : processResult.getErrors()){
                            errorlog += errDet.getMessage();
                            msg = errDet.getMessage();
                        } 
                        Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorlog,'approveRejectActivity Method');
                        return msg;  
                    } else {
                        // FIX: Track successful approval by getting PFR ID from index mapping
                        Id successfulPfrId = processIndexToPfrIdMap.get(i);
                        if(successfulPfrId != null) {
                            successfulPfrIds.add(successfulPfrId);
                        }
                }
            }
        }
           
            
            for(PartnerFundRequest pfrInst : [Select Id, Core_MDF_External_Approval_Comment_txt__c,Core_MDF_Internal_Approval_Comment_txt__c,Core_MDF_Approval_Stage__c,Core_MDF_Approval_Step_Completed__c,Core_MDF_Fund_Request_Status__c
                                              ,Core_MDF_Rejection_Comments_txt__c,Core_MDF_Program__c,Core_MDF_IPA_Int_Approver_Comment_txt__c,Core_MDF_Completed_Approval_Level_Name__c,Core_MDF_PriorValueOfStatus__c 
                                              FROM PartnerFundRequest 
                                              WHERE Id IN :piList.keySet()]){
                //Call method to append comments
                                                                                           
                if(isExternal){
                    pfrInst.Core_MDF_External_Approval_Comment_txt__c = populateApproverComments(btnName,pfrInst.Core_MDF_External_Approval_Comment_txt__c,approvalComments);
                }
                if (btnName == 'Reject'){
            		if(pfrInst.Core_MDF_PriorValueOfStatus__c == 'In-Progress Pending Review' || pfrInst.Core_MDF_PriorValueOfStatus__c == 'In-Progress Pending Approval' ){
                              pfrInst.Core_MDF_Fund_Request_Status__c = 'In-progress Revision Required';                       
                        }
                        else{
                                                          
                              pfrInst.Core_MDF_Fund_Request_Status__c = 'Revision Required';
                        }
                    pfrInst.Core_MDF_Approval_Step_Completed__c = 0;
                }
                                                  if( action == 'Reject' && pfrInst.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM){
                                                    
                                                        pfrInst.Status = 'Draft';
                                                      
                                                  }
                                                  
                                                  else if((pfrInst.Core_MDF_Approval_Step_Completed__c == 1 ||
                                                  L2_APPROVAL_STAGES.contains( pfrInst.Core_MDF_Completed_Approval_Level_Name__c)) 
                                                          && btnName == 'Approve' && string.isNotBlank(approvalComments)){
                                                      
                     pfrInst.Core_MDF_Internal_Approval_Comment_txt__c = approvalComments;
                 }
                                                  if(pfrInst.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Prg_Name')){
                                                     
                                                       pfrInst.Core_MDF_IPA_Int_Approver_Comment_txt__c = '';
                                                  }
                pfrsToBeUpdated.add(pfrInst);
               
            }   
            
            if(pfrsToBeUpdated != NULL && !pfrsToBeUpdated.isEmpty()){
                update pfrsToBeUpdated;
                 msg = 'true';
            // Track AI decision only for PFRs that succeeded in the workflow
            for(PartnerFundRequest updatedPfr : pfrsToBeUpdated) {
                String userDecision = pfrToUserDecisionMap.get(updatedPfr.Id);
                if(successfulPfrIds.contains(updatedPfr.Id) && String.isNotBlank(userDecision)) {
                    try {
                        if('Recall'.equalsIgnoreCase(userDecision)) {
                            stampRecallOnLatestTrackingRecord(updatedPfr.Id);
                        } else {
                            // Approve / Reject: stamp per-user tracking as before
                            trackAIRecommendationUsage(updatedPfr.Id, null, null, userDecision);
                        }
                    } catch(Exception trackEx) {
                        // Do not fail the main approval process
                    }
                }
                }
            }
        } catch (Exception e) {string logerror = '';logerror += 'PFRIDs->' + string.join(pfrIds, ',->');logerror += e.getLineNumber() + '->';logerror += e.getMessage() + '->';
                               Core_MDF_CCP_UtilityClass.logErrorinLogObject(logerror,'approveRejectActivity Method');
                               msg = e.getMessage().contains(Label.Core_MDF_AutoBudgetTransfer_ErrorMsg) ? Label.Core_MDF_AutoBudgetTransfer_ErrorMsg:e.getMessage();

                               return msg;
                              }
        return msg;
    }
    /*****************************************************************************************************
    Method Name :   populateApproverComments
    @return     :   String
    @parameters :   String - buttonType
    String - existingApprovalComments
    String - approvalComments
    Description :   The method concatenates Approve or Rejection informatio along with approval comments and with existing comments(if present)
    Created By  :   Nuzhath Zaiba                  Date:  04/15/2020
    ******************************************************************************************************/
    public static String populateApproverComments(String buttonType, String previousExternalApprovalComments,String externalApproverComments){
        String externalApprovalRejectionComments = '';
        String concatenateCommentswithApprovalOrRejectionInfo;

        //Custom Label used below
        //Core_MDF_Retail_Approve - approve
        //Core_MDF_Activity_Decline  - Decline,
        //Core_MDF_Retail_Approval_Comments - Approval Comments : , Core_MDF_Activity_Decline_Comments - Decline Comments : ,

        //Appends Approval or Rejection comments with appropriate Info And Not need to concatinate if Approval Comment is blank or null
        
        if(buttonType.equalsIgnoreCase(APPROVE_BUTTON)){
            if(String.isNotBlank(externalApproverComments)){
                //If Approvers Approves Activity prefix comments with 'Approval Comments :'
                concatenateCommentswithApprovalOrRejectionInfo = 'Approval Comments' +' ' + DateTime.now() +' (GMT) : '+ externalApproverComments;
            }else{    concatenateCommentswithApprovalOrRejectionInfo = 'Approval Comments'  +' '+ DateTime.now() +' (GMT) : ' +' No Comments provided';
            
                 }
           
        }else if(buttonType.equalsIgnoreCase(DECLINE_BUTTON)){
            String userType = UserInfo.getUserType();
            //If Approvers Declines Activity prefix comments with 'Decline Comments :'
            if(String.isNotBlank(userType) && userType != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Partner_User_Type')){
                concatenateCommentswithApprovalOrRejectionInfo = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Decline_Comments') + ' ' +DateTime.now() +' (GMT)' + ', ' +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Intel_System_User') + ' : ' + externalApproverComments;
            }else{ concatenateCommentswithApprovalOrRejectionInfo = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Decline_Comments') + ' '+ DateTime.now() +' (GMT) : ' + externalApproverComments;
            }
        }
        //Check if external comments field of PFR has info, then concatenate the existing comments and new comments
        if(String.isNotBlank(previousExternalApprovalComments)){
            externalApprovalRejectionComments = concatenateCommentswithApprovalOrRejectionInfo +'\n' +previousExternalApprovalComments ;
        }else{
            externalApprovalRejectionComments = concatenateCommentswithApprovalOrRejectionInfo;
        }
       
        return externalApprovalRejectionComments;
    }
    /*****************************************************************************************************
    Method Name : isApproverActive
    Date:  14/4/2021                
    ******************************************************************************************************/
    @AuraEnabled
    public static Boolean isApproverActive(String recId,String userId) 
    {Boolean returnValue = true;
     userPermissionApproval pfrval = new userPermissionApproval();
     
     try{
         PartnerFundRequest pfr = [Select Id,ChannelPartnerId,Core_MDF_Region_nm__c,Core_MDF_Sub_Region_nm__c,Core_MDF_Approval_Step_Completed__c,
                                   Core_MDF_Ultimate_Account_Id__c,Core_MDF_Program__c, Core_MDF_Country_nm__c, Core_MDF_Approval_Stage__c,
                                   Core_MDF_Activity_Classification_nm__c,Core_MDF_Host_Region_txt__c,Core_MDF_Proposal_Based_Ind__c,
                                   Core_MDF_Fund_Request_Status__c,Core_MDF_Activity_CreatedByExternalUsr__c, recordtype.developername,Campaign.Core_MDF_Account__r.Id,
                                   Core_MDF_Budget_Type_nm__c,Core_MDF_Additional_Review_Type_txt__c,Core_MDF_Host_Region_or_Region_txt__c,Core_MDF_Campaign_Ultimate_Account_Id__c,Campaign.Core_MDF_Account__c
                                   FROM PartnerFundRequest 
                                   WHERE Id =:recId];
 
         
	 String accId = pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM && pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.CUSTOMER_ACCEPTANCE_PRIMARY_PARTNER ? String.valueOf(pfr.Campaign.Core_MDF_Account__c) : String.valueOf(pfr.ChannelPartnerId);
         String country = pfr.Core_MDF_Country_nm__c; 
         List<String> countryList = country.split(';');
         if(pfr.Core_MDF_Fund_Request_Status__c == 'Pending Approval' || pfr.Core_MDF_Fund_Request_Status__c == 'In-Progress Pending Approval'){
             returnValue = Core_MDF_GeneralPurpose_UI_Utility.isSubmitterActive(accId,userId);
         }
         else if(pfr.Core_MDF_Fund_Request_Status__c == 'Pending Review' || pfr.Core_MDF_Fund_Request_Status__c == 'In-Progress Pending Review'){
             if(pfr.Core_MDF_Approval_Stage__c =='Price Reviewer'){
                 //returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(accId,pfr.recordType.DeveloperName,countryList,pfr.Core_MDF_Approval_Stage__c,userId);
                 returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfr,userId);
         }
         else if(pfr.Core_MDF_Approval_Stage__c =='L1 Approval'){
                 //returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(accId,pfr.recordType.DeveloperName,countryList,pfr.Core_MDF_Approval_Stage__c,userId);
                 returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfr,userId);
                 
                 if(!returnValue && (pfr.Core_MDF_Approval_Step_Completed__c == 0 && pfr.Core_MDF_Activity_CreatedByExternalUsr__c)){
                     returnValue = Core_MDF_GeneralPurpose_UI_Utility.isApprover(pfr.ChannelPartnerId,pfr.Campaign.Core_MDF_Account__r.Id,pfr.recordType.DeveloperName,countryList,pfr.Core_MDF_Budget_Type_nm__c,userId);
                 }
             }
  
             else if(pfr.Core_MDF_Approval_Stage__c != null && (pfr.Core_MDF_Approval_Stage__c == 'L2 Regional Marketing'||pfr.Core_MDF_Approval_Stage__c == 'L2 Regional Sales') &&  pfr.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Prg_Name')){
                // returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApproverByActivityClassification(pfr,UserInfo.getUserId()); 
                                  returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfr,userId);
      
         }
             else if(pfr.Core_MDF_Approval_Stage__c =='Program Office Reviewer'){
              //   returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(accId,pfr.recordType.DeveloperName,countryList,pfr.Core_MDF_Approval_Stage__c,userId);
                returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfr,userId);
             }
            else if (pfr.Core_MDF_Approval_Step_Completed__c == 0 && pfr.Core_MDF_Activity_CreatedByExternalUsr__c){
                 returnValue = Core_MDF_GeneralPurpose_UI_Utility.isApprover(pfr.ChannelPartnerId,pfr.Campaign.Core_MDF_Account__r.Id,pfr.recordType.DeveloperName,countryList,pfr.Core_MDF_Budget_Type_nm__c,userId);
            } 
            // To check the approver have the valid IUPGM or not
            else if(pfr.Core_MDF_Approval_Stage__c != null && pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L1_APPROVAL_ACTIVATING_PARTNER){
                returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfr,userId);
            } else if(pfr.Core_MDF_Approval_Stage__c != null && pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L1_APPROVAL_PRIMARY_PARTNER){
                returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfr,userId);
            } else if(pfr.Core_MDF_Approval_Stage__c != null && pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L2_PRIMARY_APPROVAL){
                returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfr,userId);
            }
        }
         else {
             if(pfr.Core_MDF_Program__c == 'Retail Marketing Funds' && pfr.Core_MDF_Fund_Request_Status__c == 'Closed') 
             {returnValue = true;}
             else
             {returnValue = false;}
         }
     }
     catch(Exception e){
         Core_MDF_CCP_UtilityClass.logError(e);
         throw new AuraHandledException(e.getMessage());
     }
     return returnValue;
    } 
    
       
   
    /*****************************************************************************************************
    Method Name :   userPermissionApproval (Created a Wrapper to reduce the server side call)
    Added By    : Sridhar on 3-Jun-2020
    Modified By : Nuzhath Zaiba                  Date:  14/11/2019                  Changes:None
    ******************************************************************************************************/
    public class userPermissionApproval{
        //Added by Ealisha--start
        @AuraEnabled
        public Boolean isIntelActivityApprover = false;
        //Added by Ealisha--end
        @AuraEnabled
        public Boolean userPermissionsPowerPartner = false;
        @AuraEnabled
        public Boolean userEmeaReviewer = false;
        @AuraEnabled
        public Boolean userMDFFact = false; 
        @AuraEnabled
        public PartnerFundRequest pfrInstance;
        @AuraEnabled
        public Boolean approverAssigned = false;
        @AuraEnabled
        public Map<Id,Map<String,String>> pfrMapInstance;
        @AuraEnabled
        public Boolean isUserPCTApprover = false;
        @AuraEnabled
        public Boolean isFieldOwner = false;
        @AuraEnabled
        public Boolean isMarktngOwner = false;
        @AuraEnabled
        public Boolean isAccountMng = false;
    @AuraEnabled
        public Boolean isIPAAccountMgr = false;
        @AuraEnabled
        public Boolean isPriceReviewer = false;
        @AuraEnabled
        public Boolean isLevel1Approver = false;
        @AuraEnabled
        public Boolean isLevel2Approver = false;
         @AuraEnabled
        public Boolean isPORApprover = false;
        @AuraEnabled
        public Boolean isGeoLeadApprover = false;
        @AuraEnabled
        public Boolean isL1ActivatingPartnerApprover = false;
        @AuraEnabled
        public Boolean isL1PrimaryPartnerApprover = false;
        @AuraEnabled
        public Boolean isL2PrimaryApprover = false;  
        @AuraEnabled
        public Boolean isEEFPORApprover = false; 
        @AuraEnabled
        public Boolean isEEFPCTApprover = false;
        @AuraEnabled
        public Boolean isPrimaryPartnerApprover = false; 
        @AuraEnabled
        public Boolean isActivatingPartnerApprover = false;
        @AuraEnabled
        public Boolean userPermissionsEEFRecall = false;
        @AuraEnabled
        public Boolean isAdditionalReviewer = false;
        @AuraEnabled
        public Boolean isIPAAccountMgrAndPCTApprover = false;
        @AuraEnabled
        public Boolean isOutcomebaseActivity = false;
    }
}