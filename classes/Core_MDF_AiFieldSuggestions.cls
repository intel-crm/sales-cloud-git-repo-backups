public with sharing class Core_MDF_AiFieldSuggestions {
    // ═══════════════════════════════════════════════════════════════════════════════
    // PUBLIC METHODS
    // ═══════════════════════════════════════════════════════════════════════════════
    @AuraEnabled
    public static Map<String, Object> analyzeDescriptionWithAI(String description, String recordTypeDeveloperName, Map<String, Object> picklistValues) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            if (String.isBlank(description)) {
                result.put('success', false);
                result.put('error', 'Description is required');
                return result;
            }
            Map<String, Object> aiResponse = makeAICallout(description, picklistValues);
            if (aiResponse.containsKey('error')) {
                result.put('success', false);
                result.put('error', (String)aiResponse.get('error'));
            } else {
                result.put('success', true);
                result.put('data', aiResponse);
            }
        } catch (Exception e) {
            result.put('success', false);
            result.put('error', 'An error occurred during AI analysis: ' + e.getMessage());
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> analyzeFileWithAI(List<String> contentDocumentIds, String recordTypeDeveloperName, Map<String, Object> picklistValues) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            if (contentDocumentIds == null || contentDocumentIds.isEmpty()) {
                result.put('success', false);
                result.put('error', 'No files provided');
                return result;
            }
            List<ContentVersion> versions = [
                SELECT Id, Title, FileExtension, VersionData, ContentSize FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds
            ];
            if (versions.isEmpty()) {
                result.put('success', false);
                result.put('error', 'Could not retrieve file content from Salesforce');
                return result;
            }
            FileExtractionResult extractionResult = extractTextFromFiles(versions);
            if (String.isBlank(extractionResult.combinedText)) {
                result.put('success', false);
                result.put('error', 'Could not extract readable content from the uploaded file(s).');
                return result;
            }
            Map<String, Object> aiResponse = makeAICalloutForFile(extractionResult.combinedText, picklistValues, extractionResult.processedFiles);
            if (aiResponse.containsKey('error')) {
                result.put('success', false);
                result.put('error', (String)aiResponse.get('error'));
            } else {
                result.put('success', true);
                result.put('data', aiResponse);
                result.put('filesAnalyzed', extractionResult.processedFiles);
                result.put('rawData', extractionResult.rawDataJson);
            }   
        } catch (Exception e) {
            result.put('success', false);
            result.put('error', 'An error occurred during file analysis: ' + e.getMessage());
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> analyzeCombinedContent(String description, List<String> contentDocumentIds, String recordTypeDeveloperName, Map<String, Object> picklistValues) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            Boolean hasDescription = String.isNotBlank(description);
            Boolean hasFiles = contentDocumentIds != null && !contentDocumentIds.isEmpty();
            if (!hasDescription && !hasFiles) {
                result.put('success', false);
                result.put('error', 'Either description or files are required');
                return result;
            }
            String combinedContent = '';
            String combinedRawData = '';
            List<String> processedFiles = new List<String>();
            if (hasDescription) {
                combinedContent += 'DESCRIPTION ANALYSIS:\n' + description + '\n\n';
            }
            if (hasFiles) {
                List<ContentVersion> versions = [
                    SELECT Id, Title, FileExtension, VersionData, ContentSize
                    FROM ContentVersion
                    WHERE ContentDocumentId IN :contentDocumentIds
                ];
                if (!versions.isEmpty()) {
                    FileExtractionResult extractionResult = extractTextFromFiles(versions);
                    if (String.isNotBlank(extractionResult.combinedText)) {
                        combinedContent += 'FILE ANALYSIS:\n' + extractionResult.combinedText;
                        processedFiles = extractionResult.processedFiles;
                        combinedRawData = extractionResult.rawDataJson;
                    }
                }
            }
            if (String.isBlank(combinedContent)) {
                result.put('success', false);
                result.put('error', 'No content could be extracted for analysis');
                return result;
            }
            Map<String, Object> aiResponse = makeCombinedAICallout(combinedContent, picklistValues, hasDescription, hasFiles, processedFiles);
            if (aiResponse.containsKey('error')) {
                result.put('success', false);
                result.put('error', (String)aiResponse.get('error'));
            } else {
                result.put('success', true);
                result.put('data', aiResponse);
                result.put('filesAnalyzed', processedFiles);
                result.put('rawData', combinedRawData);
                result.put('analysisType', hasDescription && hasFiles ? 'combined' : (hasDescription ? 'description' : 'files'));
            }
        } catch (Exception e) {
            result.put('success', false);
            result.put('error', 'An error occurred during combined analysis: ' + e.getMessage());
        }
        return result;
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // COMMON AI INFRASTRUCTURE METHODS
    // ═══════════════════════════════════════════════════════════════════════════════
    
    private static Core_MDF_CCP_Custom_Metadata_Utility__c getAIConfig() {
        List<Core_MDF_CCP_Custom_Metadata_Utility__c> configs = [
            SELECT Core_MDF_Field_2_txt__c, Core_MDF_Field_3_txt__c, Core_MDF_Field_4_txt__c, Core_MDF_Field_5_txt__c, Core_MDF_Field_6_txt__c
            FROM Core_MDF_CCP_Custom_Metadata_Utility__c
            WHERE Core_MDF_Category__c = 'AI_PROMPT_CONFIG' AND Core_MDF_Is_Active_Ind__c = true
            LIMIT 1
        ];
        if (configs.isEmpty()) {
            throw new AuraHandledException('AI configuration not found. Please ensure an active AI_PROMPT_CONFIG record exists.');
        }
        return configs[0];
    }

    private static HttpRequest buildAIRequest(String systemMessage, String prompt, String endpoint, Integer maxTokens, Decimal temperature, Integer timeoutMs) {
        Map<String, Object> aiRequest = new Map<String, Object>{
            'messages' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'role' => 'system',
                    'content' => systemMessage
                },
                new Map<String, Object>{
                    'role' => 'user',
                    'content' => prompt
                }
            },
            'max_tokens' => maxTokens,
            'temperature' => temperature
        };
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(aiRequest));
        req.setTimeout(timeoutMs);
        return req;
    }

    private static Map<String, Object> executeAICallout(String prompt, Map<String, Object> availablePicklistValues, String sourceContent) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            Core_MDF_CCP_Custom_Metadata_Utility__c configRecord = getAIConfig();
            String systemMessage = configRecord.Core_MDF_Field_2_txt__c;
            Integer maxTokens = Integer.valueOf(configRecord.Core_MDF_Field_3_txt__c);
            Decimal temperature = Decimal.valueOf(configRecord.Core_MDF_Field_4_txt__c);
            String endpoint = configRecord.Core_MDF_Field_5_txt__c;
            Integer timeoutMs = Integer.valueOf(configRecord.Core_MDF_Field_6_txt__c);
            HttpRequest req = buildAIRequest(systemMessage, prompt, endpoint, maxTokens, temperature, timeoutMs);
            Http http = new Http();
            HttpResponse res = http.send(req);
            system.debug('@@@response: ' + res.getBody());
            system.debug('@@@response1: ' + req.getBody());
            if (res.getStatusCode() == 200) {
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                result = parseAIResponse(responseBody);
                result = sanitizePicklistFields(result, availablePicklistValues, sourceContent);
            } else {
                result.put('error', 'AI service returned status: ' + res.getStatusCode() + ' - ' + res.getBody());
            }
        } catch (Exception e) {
            result.put('error', 'Failed to connect to AI service: ' + e.getMessage());
        }
        return result;
    }

    private static Map<String, Object> parseAIResponse(Map<String, Object> aiResponse) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            List<Object> choices = (List<Object>)aiResponse.get('choices');
            if (choices != null && !choices.isEmpty()) {
                Map<String, Object> firstChoice = (Map<String, Object>)choices[0];
                Map<String, Object> message = (Map<String, Object>)firstChoice.get('message');
                String content = (String)message.get('content');               
                if (String.isNotBlank(content)) {
                    content = content.replaceAll('```json', '').replaceAll('```', '').trim();
                    Integer startIndex = content.indexOf('{');
                    Integer endIndex = content.lastIndexOf('}');
                    if (startIndex >= 0 && endIndex > startIndex) {
                        String jsonContent = content.substring(startIndex, endIndex + 1);
                        Map<String, Object> aiData = (Map<String, Object>)JSON.deserializeUntyped(jsonContent);
                        result.putAll(aiData);
                    } else {
                        result.put('error', 'Invalid JSON format in AI response');
                    }
                }
            }
        } catch (Exception e) {
            result.put('error', 'Failed to parse AI response: ' + e.getMessage());
        }
        return result;
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // SERVER-SIDE PICKLIST SANITIZER
    // Layer 1 (all fields): blocks any value not in the sent availablePicklistValues.
    // Layer 2 (brands + technologies only): blocks any value whose normalized form
    //   does not appear as a substring in the normalized source content.
    //   This prevents GPT-4o semantic inference, e.g.:
    //     "Confidential Computing" → Intel® SGX™  (NOT in content → blocked)
    //     "Intel Xeon Scalable processors" → Intel® 4th Gen Xeon® (not verbatim → blocked)
    // ═══════════════════════════════════════════════════════════════════════════════

    // Strip all non-alphanumeric characters so ®, ™, (, ) etc. do not cause mismatches.
    private static String normalizeForContentCheck(String input) {
        if (String.isBlank(input)) return '';
        return input
            .replaceAll('[^a-zA-Z0-9 ]', ' ')
            .replaceAll('\\s+', ' ')
            .trim()
            .toLowerCase();
    }

    // Returns true when the normalized picklist value is confirmed by the source content.
    // Two-tier check:
    //   Tier A – exact substring: the full normalized picklist label appears verbatim in
    //            the content (e.g. "intel xeon scalable processors" in content → direct pass).
    //   Tier B – max-2-keyword match: extract at most 2 discriminating keywords from the
    //            picklist label, skipping:
    //              • generation ordinals (words starting with a digit, e.g. "4th", "12th")
    //              • noise suffixes (gen, generation, processors, platform, technology, etc.)
    //            Brand/technology labels follow the pattern:
    //              "Intel® [GenOrdinal] <Family>™ [Qualifier] [Type]"
    //            After normalization and noise-skipping the first 2 keywords are always
    //              ["intel", "<family>"]  e.g. ["intel","core"], ["intel","xeon"], ["intel","vpro"]
    //            BOTH must appear as whole words in the content. This means:
    //              • "Intel Core Series 3" in description → matches ALL Intel® Core™ labels
    //              • "Intel Xeon" in description → matches ALL Intel® Xeon® labels
    //              • "Intel Core" in description → blocks Intel® Xeon®, Intel® vPro® etc.
    //              • "Confidential Computing" (no "sgx") → blocks Intel® SGX™
    private static Boolean contentMatchesPicklistValue(String normalizedContent, String normalizedPicklistVal) {
        if (normalizedContent.contains(normalizedPicklistVal)) return true;

        List<String> picklistWords = normalizedPicklistVal.split('\\s+');
        Set<String> contentWordSet = new Set<String>(normalizedContent.split('\\s+'));

        // Generic suffix/qualifier words that are not product discriminators.
        Set<String> noiseWords = new Set<String>{
            'gen', 'generation',
            'processors', 'processor',
            'platform', 'technology', 'technologies',
            'solutions', 'solution',
            'systems', 'system',
            'graphics', 'accelerator', 'accelerators',
            'products', 'product', 'series', 'edition'
        };

        // Extract at most 2 discriminating keywords (skip noise and ordinals starting with a digit).
        List<String> keyWords = new List<String>();
        for (String w : picklistWords) {
            if (w.length() > 2
                    && !noiseWords.contains(w)
                    && !w.substring(0, 1).isNumeric()) {
                keyWords.add(w);
                if (keyWords.size() == 2) break;
            }
        }
        if (keyWords.isEmpty()) return false;

        // ALL extracted key words must appear in the content.
        for (String kw : keyWords) {
            if (!contentWordSet.contains(kw)) return false;
        }
        return true;
    }

    private static Map<String, Object> sanitizePicklistFields(Map<String, Object> aiResult, Map<String, Object> availablePicklistValues, String sourceContent) {
        // Multi-value picklist fields — AI must return only exact string matches
        List<String> arrayFields = new List<String>{
            'brands', 'technologies'
        };
        // Single-value picklist fields
        // outcomeMetrics is included here because the UI only allows one selection,
        // even though the underlying field is a multi-select picklist.
        List<String> singleFields = new List<String>{ 'focusArea', 'priority' };

        // outcomeMetrics: validate against available options and cap to exactly one value.
        // The AI may return an array or a single string — handle both cases.
        Object outcomeAiValue = aiResult.get('outcomeMetrics');
        Object outcomeAvailable = availablePicklistValues.get('outcomeMetrics');
        if (outcomeAvailable instanceof List<Object>) {
            Set<String> validOutcomeOptions = new Set<String>();
            for (Object opt : (List<Object>) outcomeAvailable) {
                if (opt instanceof String) validOutcomeOptions.add((String) opt);
            }
            String resolvedOutcome = null;
            if (outcomeAiValue instanceof List<Object>) {
                // AI returned an array — take the first valid entry
                for (Object val : (List<Object>) outcomeAiValue) {
                    if (val instanceof String && validOutcomeOptions.contains((String) val)) {
                        resolvedOutcome = (String) val;
                        break;
                    }
                }
            } else if (outcomeAiValue instanceof String && validOutcomeOptions.contains((String) outcomeAiValue)) {
                resolvedOutcome = (String) outcomeAiValue;
            }
            // Always store as a single-element list (or empty) so downstream LWC code
            // that expects List<String> for outcomeMetrics continues to work correctly.
            aiResult.put('outcomeMetrics', resolvedOutcome != null ? new List<String>{ resolvedOutcome } : new List<String>());
        }

        // Fields that also require the value to appear (normalized) in the source content.
        // Tactics and country are intentionally excluded — they support keyword inference.
        Set<String> contentCheckedFields = new Set<String>{ 'brands', 'technologies' };

        String normalizedContent = normalizeForContentCheck(sourceContent);

        for (String fieldName : arrayFields) {
            Object aiValue = aiResult.get(fieldName);
            if (!(aiValue instanceof List<Object>)) continue;

            Object availableObj = availablePicklistValues.get(fieldName);
            if (!(availableObj instanceof List<Object>)) continue;

            Set<String> validOptions = new Set<String>();
            for (Object opt : (List<Object>) availableObj) {
                if (opt instanceof String) validOptions.add((String) opt);
            }

            Boolean applyContentCheck = contentCheckedFields.contains(fieldName) && String.isNotBlank(normalizedContent);

            List<Object> filtered = new List<Object>();
            Set<String> addedValues = new Set<String>();
            for (Object val : (List<Object>) aiValue) {
                if (!(val instanceof String)) continue;
                String strVal = (String) val;
                // Layer 1: must be an exact picklist option
                if (!validOptions.contains(strVal)) continue;
                // Layer 2 (brands/technologies only): value must be confirmed by source content.
                // Uses both exact substring and keyword-overlap matching so that indirect
                // references like "Intel Xeon" in the description can match a full picklist
                // label such as "Intel® 4th Gen Xeon® Scalable Processors".
                if (applyContentCheck) {
                    String normalizedVal = normalizeForContentCheck(strVal);
                    if (String.isBlank(normalizedVal) || !contentMatchesPicklistValue(normalizedContent, normalizedVal)) continue;
                }
                filtered.add(strVal);
                addedValues.add(strVal);
            }

            // Keyword-based augmentation: scan ALL available picklist options against the
            // source content to surface matches the AI may have missed.
            // This handles cases like "Intel Core Series 3" in the description matching
            // multiple picklist labels (e.g. "Intel® Core™ Series 3 Processors",
            // "Intel® Core™ Ultra Series 3") even when the AI only returned one value.
            if (applyContentCheck) {
                for (Object opt : (List<Object>) availableObj) {
                    if (!(opt instanceof String)) continue;
                    String optStr = (String) opt;
                    if (addedValues.contains(optStr)) continue;
                    String normalizedOpt = normalizeForContentCheck(optStr);
                    if (String.isNotBlank(normalizedOpt) && contentMatchesPicklistValue(normalizedContent, normalizedOpt)) {
                        filtered.add(optStr);
                        addedValues.add(optStr);
                    }
                }
            }

            aiResult.put(fieldName, filtered);
        }

        for (String fieldName : singleFields) {
            Object aiValue = aiResult.get(fieldName);
            if (!(aiValue instanceof String)) continue;

            Object availableObj = availablePicklistValues.get(fieldName);
            if (!(availableObj instanceof List<Object>)) continue;

            Set<String> validOptions = new Set<String>();
            for (Object opt : (List<Object>) availableObj) {
                if (opt instanceof String) validOptions.add((String) opt);
            }

            if (!validOptions.contains((String) aiValue)) {
                aiResult.put(fieldName, null);
            }
        }

        // Override focusArea with keyword detection when an explicit match exists in the
        // source content. This ensures the AI suggestion is consistent with the Aura form,
        // which uses the same regex-based priority logic via detectFocusAreaFromContent().
        // The AI tends to semantically infer focus area from contextual signals (e.g. Xeon,
        // OpenShift) even when an explicit keyword like "client computing" is present.
        if (String.isNotBlank(sourceContent)) {
            String keywordFocusArea = detectFocusAreaKeyword(sourceContent);
            if (keywordFocusArea != null) {
                aiResult.put('focusArea', keywordFocusArea);
            }
        }

        return aiResult;
    }

    // Returns the first focus area whose keyword pattern matches in the content,
    // or null if no keyword is found. Unlike detectFocusAreaFromContent(), this method
    // does NOT return a default — null means "no explicit keyword detected".
    private static String detectFocusAreaKeyword(String content) {
        if (String.isBlank(content)) return null;
        List<String> priorityOrder = new List<String>{
            'Client Computing', 'Data Center', 'Networking & Telco', 'Edge'
        };
        Map<String, String> focusAreaPatterns = new Map<String, String>{
            // Explicit labels + Intel product/brand keywords mirroring the JS determineFocusAreaFromDescription()
            //Akash - 2807
            'Client Computing'   => '(?i)\\bclient\\s+computing\\b|\\bclient-computing\\b|\\bclientcomputing\\b',
            'Data Center'        => '(?i)\\bdata\\s+cent(?:er|re)\\b|\\bdatacent(?:er|re)\\b|\\bdata-cent(?:er|re)\\b',
            'Networking & Telco' => '(?i)\\bnetworking\\s*&\\s*telco\\b|\\bnetworking\\s+and\\s+telco\\b',
            'Edge'               => '(?i)\\bedge\\b'
        };
        for (String focusArea : priorityOrder) {
            Pattern p = Pattern.compile(focusAreaPatterns.get(focusArea));
            Matcher m = p.matcher(content);
            if (m.find()) return focusArea;
        }
        return null;
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // SPECIFIC AI CALLOUT METHODS
    // ═══════════════════════════════════════════════════════════════════════════════
    
    private static Map<String, Object> makeAICallout(String description, Map<String, Object> availablePicklistValues) {
        String prompt = buildAIPrompt(description, availablePicklistValues);
        system.debug('AI Prompt:DESC ' + prompt);
        return executeAICallout(prompt, availablePicklistValues, description);
    }

    private static Map<String, Object> makeAICalloutForFile(String fileContent, Map<String, Object> availablePicklistValues, List<String> fileNames) {
        String prompt = buildFileAIPrompt(fileContent, availablePicklistValues, fileNames);
        // Pass null so sanitizePicklistFields skips the content-check layer (Layer 2)
        // for file input — file text is too large and produces too many false matches.
        system.debug('AI Prompt:File ' + prompt);
        return executeAICallout(prompt, availablePicklistValues, null);
    }

    private static Map<String, Object> makeCombinedAICallout(String combinedContent, Map<String, Object> availablePicklistValues, Boolean hasDescription, Boolean hasFiles, List<String> fileNames) {
        String prompt = buildCombinedAIPrompt(combinedContent, availablePicklistValues, hasDescription, hasFiles, fileNames);
        // Pass null so sanitizePicklistFields skips the content-check layer (Layer 2)
        // for combined input — file portion causes too many false keyword matches.
        system.debug('AI Prompt:Combined ' + prompt);
        return executeAICallout(prompt, availablePicklistValues, combinedContent);
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // METADATA LOADING AND PROMPT BUILDING METHODS
    // ═══════════════════════════════════════════════════════════════════════════════
    
    private static Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> loadPromptMetadata() {
        Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap = new Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c>();

        for (Core_MDF_CCP_Custom_Metadata_Utility__c rec : [
            SELECT Core_MDF_Category__c,Core_MDF_Field_1_txt__c, Core_MDF_Field_2_txt__c,Core_MDF_Field_3_txt__c, Core_MDF_Field_4_txt__c,Core_MDF_Field_5_txt__c, Core_MDF_Field_6_txt__c,Core_MDF_Field_7_txt__c, Core_MDF_Field_8_txt__c,Core_MDF_Field_9_txt__c, Core_MDF_Field_10_txt__c,Core_MDF_Field_11_txt__c, Core_MDF_Field_12_txt__c,Core_MDF_Field_13_txt__c, Core_MDF_Field_14_txt__c,Core_MDF_Field_15_txt__c, Core_MDF_Field_16_txt__c FROM Core_MDF_CCP_Custom_Metadata_Utility__c
            WHERE Core_MDF_Category__c IN ('AI_PROMPT_INTRO', 'AI_PROMPT_JSON_STRUCTURE', 'AI_PROMPT_RULES', 'AI_PROMPT_FIELD_SPECIFIC','AI_PROMPT_PICKLIST_RULES', 'AI_PROMPT_PICKLIST_SENSITIVITY', 'AI_PROMPT_EXTRACTION_PROCESS','AI_PROMPT_VERIFICATION', 'AI_PROMPT_DOCUMENT_EXTRACTION', 'AI_PROMPT_ENHANCED_EXTRACTION','AI_PROMPT_ENHANCED_EXTRACTION_PART2', 'AI_PROMPT_SCANNING_PATTERNS', 'AI_PROMPT_SCANNING_PATTERNS_PART2','AI_PROMPT_RESPONSE_FORMAT', 'AI_PROMPT_RESPONSE_FORMAT_PART2', 'AI_PROMPT_ENHANCED_RULES','AI_PROMPT_COMBINED_ANALYSIS', 'AI_PROMPT_FINAL_INSTRUCTIONS', 'AI_PROMPT_FILE_INTRO','AI_PROMPT_ANALYSIS_MODES', 'AI_PROMPT_COMBINED_RULES', 'AI_PROMPT_ADDITIONAL_EXTRACTION','AI_PROMPT_ADDITIONAL_EXTRACTION_PART2', 'AI_PROMPT_ADDITIONAL_EXTRACTION_PART3', 'AI_PROMPT_ADDITIONAL_EXTRACTION_PART4','AI_PROMPT_BRAND_TECH_RULES', 'AI_PROMPT_DATE_GUARD')
            AND Core_MDF_Is_Active_Ind__c = true
        ]) {
            metaMap.put(rec.Core_MDF_Category__c, rec);
        }
        return metaMap;
    }

    private static String buildIntroSection(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap) {
        Core_MDF_CCP_Custom_Metadata_Utility__c introRec = metaMap.get('AI_PROMPT_INTRO');
        if (introRec != null) {
            return introRec.Core_MDF_Field_1_txt__c + ' ' +
                   introRec.Core_MDF_Field_2_txt__c + ' ' +
                   introRec.Core_MDF_Field_3_txt__c + '\n\n' +
                   introRec.Core_MDF_Field_4_txt__c + '\n' +
                   introRec.Core_MDF_Field_5_txt__c + '\n\n';
        }
        return 'SMART AI ANALYSIS - Intel MDF Campaign Field Extraction\n\n';
    }

    private static String buildPicklistOptionsSection(Map<String, Object> availablePicklistValues) {
        String section = 'Available Picklist Options:\n';
        for (String fieldName : availablePicklistValues.keySet()) {
            Object fieldValues = availablePicklistValues.get(fieldName);
            if (fieldValues instanceof List<Object>) {
                List<Object> valueList = (List<Object>) fieldValues;
                if (!valueList.isEmpty()) {
                    section += fieldName + ': ' + String.join(getStringList(valueList), ', ') + '\n';
                }
            }
        }
        return section;
    }

    // NEW METHOD: Build 2026 Priority Options section from metadata
    private static String build2026PriorityOptionsSection(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap) {
        Core_MDF_CCP_Custom_Metadata_Utility__c fieldRec = metaMap.get('AI_PROMPT_FIELD_SPECIFIC');
        if (fieldRec == null) return '';
        
        String section = '';
        if (String.isNotBlank(fieldRec.Core_MDF_Field_12_txt__c) && String.isNotBlank(fieldRec.Core_MDF_Field_13_txt__c)) {
            section += '\n' + fieldRec.Core_MDF_Field_12_txt__c + '\n';
            section += fieldRec.Core_MDF_Field_13_txt__c + '\n';
        }
        return section;
    }

    private static String buildPicklistMatchingRules(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap) {
        String rules = '\n=== ';
        Core_MDF_CCP_Custom_Metadata_Utility__c picklistRulesRec = metaMap.get('AI_PROMPT_PICKLIST_RULES');
        Core_MDF_CCP_Custom_Metadata_Utility__c sensitivityRec = metaMap.get('AI_PROMPT_PICKLIST_SENSITIVITY');
        if (picklistRulesRec != null) {
            rules += picklistRulesRec.Core_MDF_Field_1_txt__c + ' ===\n';
            rules += picklistRulesRec.Core_MDF_Field_2_txt__c + '\n\n';
            rules += '1. **' + picklistRulesRec.Core_MDF_Field_3_txt__c + '**:\n';
            rules += '   - ' + picklistRulesRec.Core_MDF_Field_4_txt__c + '\n';
            rules += '   - ' + picklistRulesRec.Core_MDF_Field_5_txt__c + '\n';
            rules += '   - ' + picklistRulesRec.Core_MDF_Field_6_txt__c + '\n';
            rules += '   - ' + picklistRulesRec.Core_MDF_Field_7_txt__c + '\n\n';
            rules += '2. **' + picklistRulesRec.Core_MDF_Field_8_txt__c + '**:\n';
            rules += '   ' + picklistRulesRec.Core_MDF_Field_9_txt__c + '\n';
            rules += '   ' + picklistRulesRec.Core_MDF_Field_10_txt__c + '\n';
            rules += '   ' + picklistRulesRec.Core_MDF_Field_11_txt__c + '\n';
            rules += '   ' + picklistRulesRec.Core_MDF_Field_12_txt__c + '\n\n';
            rules += '3. **' + picklistRulesRec.Core_MDF_Field_13_txt__c + '**:\n';
            rules += '   - ' + picklistRulesRec.Core_MDF_Field_14_txt__c + '\n';
            rules += '   - ' + picklistRulesRec.Core_MDF_Field_15_txt__c + '\n';
            rules += '   - ' + picklistRulesRec.Core_MDF_Field_16_txt__c + '\n';
        }
        
        if (sensitivityRec != null) {
            rules += '   - ' + sensitivityRec.Core_MDF_Field_1_txt__c + '\n';
            rules += '   - ' + sensitivityRec.Core_MDF_Field_2_txt__c + '\n\n';
            rules += '4. **' + sensitivityRec.Core_MDF_Field_3_txt__c + '**:\n';
            rules += '   - ' + sensitivityRec.Core_MDF_Field_4_txt__c + '\n';
            rules += '   - ' + sensitivityRec.Core_MDF_Field_5_txt__c + '\n';
            rules += '   - ' + sensitivityRec.Core_MDF_Field_6_txt__c + '\n';
            rules += '   - ' + sensitivityRec.Core_MDF_Field_7_txt__c + '\n\n';
            rules += '5. **' + sensitivityRec.Core_MDF_Field_8_txt__c + '**:\n';
            rules += '   - ' + sensitivityRec.Core_MDF_Field_9_txt__c + '\n';
            rules += '   - ' + sensitivityRec.Core_MDF_Field_10_txt__c + '\n';
            rules += '   - ' + sensitivityRec.Core_MDF_Field_11_txt__c + '\n';
            rules += '   - ' + sensitivityRec.Core_MDF_Field_12_txt__c + '\n\n';
            rules += '6. ' + sensitivityRec.Core_MDF_Field_13_txt__c + '\n\n';
            rules += '7. ' + sensitivityRec.Core_MDF_Field_14_txt__c + '\n\n';
        }
        return rules;
    }

    private static String buildGenericPicklistExtractionProcess(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap) {
        String process = '=== ';
        Core_MDF_CCP_Custom_Metadata_Utility__c extractionRec = metaMap.get('AI_PROMPT_EXTRACTION_PROCESS');
        if (extractionRec != null) {
            process += extractionRec.Core_MDF_Field_1_txt__c + ' ===\n';
            process += extractionRec.Core_MDF_Field_2_txt__c + '\n\n';
            process += '1. **' + extractionRec.Core_MDF_Field_3_txt__c + '**\n';
            process += '2. **' + extractionRec.Core_MDF_Field_4_txt__c + '**\n';
            process += '3. **' + extractionRec.Core_MDF_Field_5_txt__c + '**\n';
            process += '4. **' + extractionRec.Core_MDF_Field_6_txt__c + '**\n';
            process += '5. **' + extractionRec.Core_MDF_Field_7_txt__c + '**\n\n';
            process += extractionRec.Core_MDF_Field_8_txt__c + '\n\n';
            process += extractionRec.Core_MDF_Field_9_txt__c + '\n\n';
            process += extractionRec.Core_MDF_Field_10_txt__c + '\n\n';
        }
        return process;
    }

    private static String buildJSONStructureSection(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap) {
        Core_MDF_CCP_Custom_Metadata_Utility__c jsonRec = metaMap.get('AI_PROMPT_JSON_STRUCTURE');
        if (jsonRec == null) return '';
        String section = jsonRec.Core_MDF_Field_1_txt__c + '\n';
        List<String> part1Fields = jsonRec.Core_MDF_Field_2_txt__c.split(',');
        List<String> part2Fields = jsonRec.Core_MDF_Field_3_txt__c.split(',');
        List<String> allJsonFields = new List<String>();
        allJsonFields.addAll(part1Fields);
        allJsonFields.addAll(part2Fields);
        // Ensure AI returns newly supported fields even if metadata is not updated yet.
        List<String> additionalFields = new List<String>{
            'account', 'tacticMetrics', 'goalValues', 'spendingAmount', 'spendingPercentage', 'outcomeActivityValues'
        };
        Set<String> existingFields = new Set<String>();
        for (String existingField : allJsonFields) {
            if (String.isNotBlank(existingField)) {
                existingFields.add(existingField.trim());
            }
        }
        for (String requiredField : additionalFields) {
            if (!existingFields.contains(requiredField)) {
                allJsonFields.add(requiredField);
            }
        }
        // outcomeMetrics is excluded from arrayFields — the UI allows only one selection,
        // so it is rendered as a single "exact_match_or_null" string in the JSON schema.
        Set<String> arrayFields = new Set<String>{
            'country','targetAudience','brands','technologies',
            'initiatives','ecosystemPartners','productTypes','tactics'
        };
        Set<String> objectFields = new Set<String>{
            'account','tacticMetrics','goalValues'
        };
        section += '{\n';
        for (Integer i = 0; i < allJsonFields.size(); i++) {
            String f = allJsonFields[i].trim();
            String valueHint;
            if (arrayFields.contains(f)) {
                valueHint = '["exact_matches_array"]';
            } else if (objectFields.contains(f)) {
                valueHint = '{"key":"value_or_number"}';
            } else if (f == 'outcomeActivityValues') {
                valueHint = '{"outcomeMetric":"string","baselineValue":number_or_null,"goalValue":number_or_null,"baselinePeriod":"Same period as this campaign, one year before|one half before|one quarter before|null"}';
            } else if (f == 'spendingAmount' || f == 'spendingPercentage' || f.endsWith('Confidence')) {
                valueHint = 'number_or_null';
            } else {
                valueHint = '"exact_match_or_null"';
            }
            section += '  "' + f + '": ' + valueHint;
            if (i < allJsonFields.size() - 1) section += ',';
            section += '\n';
        }
        section += '}\n\n';
        return section;
    }

    private static String buildAdditionalFieldExtractionRules(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap) {
        List<String> partKeys = new List<String>{
            'AI_PROMPT_ADDITIONAL_EXTRACTION',
            'AI_PROMPT_ADDITIONAL_EXTRACTION_PART2',
            'AI_PROMPT_ADDITIONAL_EXTRACTION_PART3',
            'AI_PROMPT_ADDITIONAL_EXTRACTION_PART4'
        };
        if (!metaMap.containsKey('AI_PROMPT_ADDITIONAL_EXTRACTION')) return '';
        String rules = '';
        for (String partKey : partKeys) {
            Core_MDF_CCP_Custom_Metadata_Utility__c rec = metaMap.get(partKey);
            if (rec == null) continue;
            for (Integer i = 1; i <= 16; i++) {
                String fieldName = 'Core_MDF_Field_' + i + '_txt__c';
                String fieldValue = (String)rec.get(fieldName);
                if (String.isNotBlank(fieldValue)) {
                    rules += fieldValue + '\n';
                }
            }
        }
        return rules;
    }

    // UPDATED METHOD: Build field-specific validation rules from metadata
    private static String buildFieldSpecificValidationRules(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap) {
        Core_MDF_CCP_Custom_Metadata_Utility__c fieldRec = metaMap.get('AI_PROMPT_FIELD_SPECIFIC');
        if (fieldRec == null) return '';
        
        String rules = buildDateExtractionGuard(metaMap);
        rules += fieldRec.Core_MDF_Field_1_txt__c + '\n\n';
        
        // Campaign Name section
        if (String.isNotBlank(fieldRec.Core_MDF_Field_2_txt__c) && String.isNotBlank(fieldRec.Core_MDF_Field_5_txt__c)) {
            rules += fieldRec.Core_MDF_Field_2_txt__c + '\n' + fieldRec.Core_MDF_Field_5_txt__c + '\n\n';
        }
        
        // Start Date section
        if (String.isNotBlank(fieldRec.Core_MDF_Field_3_txt__c) && String.isNotBlank(fieldRec.Core_MDF_Field_6_txt__c)) {
            rules += fieldRec.Core_MDF_Field_3_txt__c + '\n' + fieldRec.Core_MDF_Field_6_txt__c + '\n\n';
        }
        
        // End Date section
        if (String.isNotBlank(fieldRec.Core_MDF_Field_4_txt__c) && String.isNotBlank(fieldRec.Core_MDF_Field_7_txt__c)) {
            rules += fieldRec.Core_MDF_Field_4_txt__c + '\n' + fieldRec.Core_MDF_Field_7_txt__c + '\n\n';
        }
        
        //Focus Area section
        if (String.isNotBlank(fieldRec.Core_MDF_Field_8_txt__c) && String.isNotBlank(fieldRec.Core_MDF_Field_9_txt__c)) {
            rules += fieldRec.Core_MDF_Field_8_txt__c + '\n' + fieldRec.Core_MDF_Field_9_txt__c + '\n\n';
        }
        
        // Priority section
        if (String.isNotBlank(fieldRec.Core_MDF_Field_10_txt__c) && String.isNotBlank(fieldRec.Core_MDF_Field_11_txt__c)) {
            rules += fieldRec.Core_MDF_Field_10_txt__c + '\n' + fieldRec.Core_MDF_Field_11_txt__c + '\n\n';
        }
        
        return rules;
    }

    private static String buildGeneralRulesSection(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap) {
        Core_MDF_CCP_Custom_Metadata_Utility__c rulesRec = metaMap.get('AI_PROMPT_RULES');
        if (rulesRec == null) return '';
        String rules = 'GENERAL RULES:\n';
        List<String> ruleFields = new List<String>{
            rulesRec.Core_MDF_Field_1_txt__c, rulesRec.Core_MDF_Field_2_txt__c,
            rulesRec.Core_MDF_Field_3_txt__c, rulesRec.Core_MDF_Field_4_txt__c,
            rulesRec.Core_MDF_Field_5_txt__c, rulesRec.Core_MDF_Field_6_txt__c,
            rulesRec.Core_MDF_Field_7_txt__c, rulesRec.Core_MDF_Field_8_txt__c,
            rulesRec.Core_MDF_Field_9_txt__c, rulesRec.Core_MDF_Field_10_txt__c,
            rulesRec.Core_MDF_Field_11_txt__c, rulesRec.Core_MDF_Field_12_txt__c
        };
        Integer ruleNum = 1;
        for (String rule : ruleFields) {
            if (String.isNotBlank(rule)) {
                rules += ruleNum++ + '. ' + rule + '\n';
            }
        }
        return rules;
    }

    private static String buildFinalVerificationSection(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap) {
        String verification = '\n=== ';
        Core_MDF_CCP_Custom_Metadata_Utility__c verificationRec = metaMap.get('AI_PROMPT_VERIFICATION');
        if (verificationRec != null) {
            verification += verificationRec.Core_MDF_Field_1_txt__c + ' ===\n';
            verification += verificationRec.Core_MDF_Field_2_txt__c + '\n';
            verification += '- ' + verificationRec.Core_MDF_Field_3_txt__c + '\n';
            verification += '- ' + verificationRec.Core_MDF_Field_4_txt__c + '\n';
            verification += '- ' + verificationRec.Core_MDF_Field_5_txt__c + '\n';
            verification += verificationRec.Core_MDF_Field_6_txt__c + '\n\n';
        }
        return verification;
    }

    private static String buildEnhancedDocumentTypeExtractionRules(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap) {
        String rules = '=== ';
        Core_MDF_CCP_Custom_Metadata_Utility__c docRec = metaMap.get('AI_PROMPT_DOCUMENT_EXTRACTION');
        if (docRec != null) {
            rules += docRec.Core_MDF_Field_1_txt__c + ' ===\n';
            rules += docRec.Core_MDF_Field_2_txt__c + '\n\n';
            rules += docRec.Core_MDF_Field_3_txt__c + '\n';
            rules += '- ' + docRec.Core_MDF_Field_4_txt__c + '\n';
            rules += '- ' + docRec.Core_MDF_Field_5_txt__c + '\n';
            rules += '- ' + docRec.Core_MDF_Field_6_txt__c + '\n';
            rules += '- ' + docRec.Core_MDF_Field_7_txt__c + '\n';
            rules += '- ' + docRec.Core_MDF_Field_8_txt__c + '\n';
            rules += '- ' + docRec.Core_MDF_Field_9_txt__c + '\n';
            rules += '- ' + docRec.Core_MDF_Field_10_txt__c + '\n';
            rules += '- ' + docRec.Core_MDF_Field_11_txt__c + '\n\n';
            rules += docRec.Core_MDF_Field_12_txt__c + '\n';
            rules += '**' + docRec.Core_MDF_Field_13_txt__c + '**\n';
            rules += '- ' + docRec.Core_MDF_Field_14_txt__c + '\n';
            rules += '- ' + docRec.Core_MDF_Field_15_txt__c + '\n';
            rules += '- ' + docRec.Core_MDF_Field_16_txt__c + '\n\n';
        }
        return rules;
    }

    private static String buildEnhancedPicklistExtractionProcess(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap) {
        String process = '\n=== ';
        Core_MDF_CCP_Custom_Metadata_Utility__c enhancedRec = metaMap.get('AI_PROMPT_ENHANCED_EXTRACTION');
        Core_MDF_CCP_Custom_Metadata_Utility__c enhancedPart2Rec = metaMap.get('AI_PROMPT_ENHANCED_EXTRACTION_PART2');
        if (enhancedRec != null) {
            process += enhancedRec.Core_MDF_Field_1_txt__c + ' ===\n';
            process += enhancedRec.Core_MDF_Field_2_txt__c + '\n\n';
            process += '**' + enhancedRec.Core_MDF_Field_3_txt__c + '**\n';
            process += '1. ' + enhancedRec.Core_MDF_Field_4_txt__c + '\n';
            process += '2. ' + enhancedRec.Core_MDF_Field_5_txt__c + '\n';
            process += '3. ' + enhancedRec.Core_MDF_Field_6_txt__c + '\n';
            process += '4. ' + enhancedRec.Core_MDF_Field_7_txt__c + '\n\n';
            process += '**' + enhancedRec.Core_MDF_Field_8_txt__c + '**\n';
            process += '1. ' + enhancedRec.Core_MDF_Field_9_txt__c + '\n';
            process += '2. ' + enhancedRec.Core_MDF_Field_10_txt__c + '\n';
            process += '3. ' + enhancedRec.Core_MDF_Field_11_txt__c + '\n';
            process += '4. ' + enhancedRec.Core_MDF_Field_12_txt__c + '\n\n';
            process += '**' + enhancedRec.Core_MDF_Field_13_txt__c + '**\n';
            process += '1. ' + enhancedRec.Core_MDF_Field_14_txt__c + '\n';
            process += '2. ' + enhancedRec.Core_MDF_Field_15_txt__c + '\n';
            process += '3. ' + enhancedRec.Core_MDF_Field_16_txt__c + '\n';
        }
        
        if (enhancedPart2Rec != null) {
            process += '4. ' + enhancedPart2Rec.Core_MDF_Field_1_txt__c + '\n\n';
            process += '**' + enhancedPart2Rec.Core_MDF_Field_2_txt__c + '**\n';
            process += '1. ' + enhancedPart2Rec.Core_MDF_Field_3_txt__c + '\n';
            process += '2. ' + enhancedPart2Rec.Core_MDF_Field_4_txt__c + '\n';
            process += '3. ' + enhancedPart2Rec.Core_MDF_Field_5_txt__c + '\n';
            process += '4. ' + enhancedPart2Rec.Core_MDF_Field_6_txt__c + '\n\n';
        }
        
        return process;
    }

    private static String buildDocumentTypeScanningPatterns(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap) {
        String patterns = '=== ';
        Core_MDF_CCP_Custom_Metadata_Utility__c scanRec = metaMap.get('AI_PROMPT_SCANNING_PATTERNS');
        Core_MDF_CCP_Custom_Metadata_Utility__c scanPart2Rec = metaMap.get('AI_PROMPT_SCANNING_PATTERNS_PART2');
        if (scanRec != null) {
            patterns += scanRec.Core_MDF_Field_1_txt__c + ' ===\n';
            patterns += '\n**' + scanRec.Core_MDF_Field_2_txt__c + '**:\n';
            patterns += '- ' + scanRec.Core_MDF_Field_3_txt__c + '\n';
            patterns += '- ' + scanRec.Core_MDF_Field_4_txt__c + '\n';
            patterns += '- ' + scanRec.Core_MDF_Field_5_txt__c + '\n';
            patterns += '- ' + scanRec.Core_MDF_Field_6_txt__c + '\n';
            patterns += '- ' + scanRec.Core_MDF_Field_7_txt__c + '\n\n';
            patterns += '**' + scanRec.Core_MDF_Field_8_txt__c + '**:\n';
            patterns += '- ' + scanRec.Core_MDF_Field_9_txt__c + '\n';
            patterns += '- ' + scanRec.Core_MDF_Field_10_txt__c + '\n';
            patterns += '- ' + scanRec.Core_MDF_Field_11_txt__c + '\n';
            patterns += '- ' + scanRec.Core_MDF_Field_12_txt__c + '\n';
            patterns += '- ' + scanRec.Core_MDF_Field_13_txt__c + '\n\n';
            patterns += '**' + scanRec.Core_MDF_Field_14_txt__c + '**:\n';
            patterns += '- ' + scanRec.Core_MDF_Field_15_txt__c + '\n';
            patterns += '- ' + scanRec.Core_MDF_Field_16_txt__c + '\n';
        }
        
        if (scanPart2Rec != null) {
            patterns += '- ' + scanPart2Rec.Core_MDF_Field_1_txt__c + '\n';
            patterns += '- ' + scanPart2Rec.Core_MDF_Field_2_txt__c + '\n';
            patterns += '- ' + scanPart2Rec.Core_MDF_Field_3_txt__c + '\n\n';
        }
        return patterns;
    }

    private static String buildFileResponseFormat(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap) {
        String format = '\n=== ';
        Core_MDF_CCP_Custom_Metadata_Utility__c formatRec = metaMap.get('AI_PROMPT_RESPONSE_FORMAT');
        Core_MDF_CCP_Custom_Metadata_Utility__c formatPart2Rec = metaMap.get('AI_PROMPT_RESPONSE_FORMAT_PART2');
        if (formatRec != null) {
            format += formatRec.Core_MDF_Field_1_txt__c + ' ===\n';
            format += formatRec.Core_MDF_Field_2_txt__c + '\n';
            format += '{\n';
            format += '  ' + formatRec.Core_MDF_Field_3_txt__c + '\n';
            format += '  ' + formatRec.Core_MDF_Field_4_txt__c + '\n';
            format += '  ' + formatRec.Core_MDF_Field_5_txt__c + '\n';
            format += '  ' + formatRec.Core_MDF_Field_6_txt__c + '\n';
            format += '  ' + formatRec.Core_MDF_Field_7_txt__c + '\n';
            format += '  ' + formatRec.Core_MDF_Field_8_txt__c + '\n';
            format += '  ' + formatRec.Core_MDF_Field_9_txt__c + '\n';
            format += '  ' + formatRec.Core_MDF_Field_10_txt__c + '\n';
            format += '  ' + formatRec.Core_MDF_Field_11_txt__c + '\n';
            format += '  ' + formatRec.Core_MDF_Field_12_txt__c + '\n';
            format += '  ' + formatRec.Core_MDF_Field_13_txt__c + '\n';
            format += '  ' + formatRec.Core_MDF_Field_14_txt__c + '\n';
            format += '  ' + formatRec.Core_MDF_Field_15_txt__c + '\n';
            format += '  ' + formatRec.Core_MDF_Field_16_txt__c + '\n';
        }
        
        if (formatPart2Rec != null) {
            format += '  ' + formatPart2Rec.Core_MDF_Field_1_txt__c + '\n';
            format += '  ' + formatPart2Rec.Core_MDF_Field_2_txt__c + '\n';
            format += '  ' + formatPart2Rec.Core_MDF_Field_3_txt__c + '\n';
            format += '  ' + formatPart2Rec.Core_MDF_Field_4_txt__c + '\n';
            format += '  ' + formatPart2Rec.Core_MDF_Field_5_txt__c + '\n';
            format += '  ' + formatPart2Rec.Core_MDF_Field_6_txt__c + '\n';
            format += '  ' + formatPart2Rec.Core_MDF_Field_7_txt__c + '\n';
            format += '  ' + formatPart2Rec.Core_MDF_Field_8_txt__c + '\n';
            format += '  ' + formatPart2Rec.Core_MDF_Field_9_txt__c + '\n';
            format += '  ' + formatPart2Rec.Core_MDF_Field_10_txt__c + '\n';
            format += '  ' + formatPart2Rec.Core_MDF_Field_11_txt__c + '\n';
            for (Integer i = 12; i <= 16; i++) {
                String fieldValue = (String) formatPart2Rec.get('Core_MDF_Field_' + i + '_txt__c');
                if (String.isNotBlank(fieldValue)) {
                    format += '  ' + fieldValue + '\n';
                }
            }
            format += '}\n\n';
        }
        
        return format;
    }

    private static String buildEnhancedRulesForNonExcel(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap) {
        Core_MDF_CCP_Custom_Metadata_Utility__c rulesRec = metaMap.get('AI_PROMPT_ENHANCED_RULES');
        if (rulesRec == null) return '';
        String rules = rulesRec.Core_MDF_Field_1_txt__c + '\n';
        for (Integer i = 2; i <= 11; i++) {
            String fieldName = 'Core_MDF_Field_' + i + '_txt__c';
            String fieldValue = (String)rulesRec.get(fieldName);
            if (String.isNotBlank(fieldValue)) {
                rules += (i-1) + '. **' + fieldValue + '**\n';
            }
        }
        rules += '\n';
        return rules;
    }

    private static String buildCombinedAnalysisInstructions(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap) {
        String instructions = '=== ';
        Core_MDF_CCP_Custom_Metadata_Utility__c combinedRec = metaMap.get('AI_PROMPT_COMBINED_ANALYSIS');
        if (combinedRec != null) {
            instructions += combinedRec.Core_MDF_Field_1_txt__c + ' ===\n';
            instructions += combinedRec.Core_MDF_Field_2_txt__c + '\n\n';
            instructions += '**' + combinedRec.Core_MDF_Field_3_txt__c + '**:\n';
            instructions += '- **' + combinedRec.Core_MDF_Field_4_txt__c + '**\n';
            instructions += '- **' + combinedRec.Core_MDF_Field_5_txt__c + '**\n';
            instructions += '- **' + combinedRec.Core_MDF_Field_6_txt__c + '**\n';
            instructions += '- **' + combinedRec.Core_MDF_Field_7_txt__c + '**\n\n';            
            instructions += '**' + combinedRec.Core_MDF_Field_8_txt__c + '**:\n';
            instructions += '- ' + combinedRec.Core_MDF_Field_9_txt__c + '\n';
            instructions += '- ' + combinedRec.Core_MDF_Field_10_txt__c + '\n';
            instructions += '- ' + combinedRec.Core_MDF_Field_11_txt__c + '\n';
            instructions += '- ' + combinedRec.Core_MDF_Field_12_txt__c + '\n\n';
        }
        return instructions;
    }

    private static String buildEnhancedFinalInstructionsForNonExcel(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap) {
        String instructions = '=== ';
        Core_MDF_CCP_Custom_Metadata_Utility__c finalRec = metaMap.get('AI_PROMPT_FINAL_INSTRUCTIONS');
        if (finalRec != null) {
            instructions += finalRec.Core_MDF_Field_1_txt__c + ' ===\n';
            instructions += finalRec.Core_MDF_Field_2_txt__c + '\n';
            for (Integer i = 3; i <= 8; i++) {
                String fieldName = 'Core_MDF_Field_' + i + '_txt__c';
                String fieldValue = (String)finalRec.get(fieldName);
                if (String.isNotBlank(fieldValue)) {
                    instructions += (i-2) + '. **' + fieldValue + '**\n';
                }
            }
            instructions += '\n';
        }
        return instructions;
    }

    // NEW METADATA-DRIVEN HELPER METHODS
    private static String buildFileIntroSection(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap, List<String> fileNames) {
        Core_MDF_CCP_Custom_Metadata_Utility__c fileIntroRec = metaMap.get('AI_PROMPT_FILE_INTRO');
        if (fileIntroRec == null) return '';
        String intro = fileIntroRec.Core_MDF_Field_1_txt__c + ' ';
        intro += fileIntroRec.Core_MDF_Field_2_txt__c + '\n\n';
        intro += fileIntroRec.Core_MDF_Field_3_txt__c + ' ' + String.join(fileNames, ', ') + '\n\n';
        return intro;
    }

    private static String buildDocumentContentSection(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap, String fileContent) {
        Core_MDF_CCP_Custom_Metadata_Utility__c fileIntroRec = metaMap.get('AI_PROMPT_FILE_INTRO');
        if (fileIntroRec == null) return '';
        String section = fileIntroRec.Core_MDF_Field_4_txt__c + '\n';
        section += fileContent + '\n\n';
        return section;
    }

    private static String buildFileClosingSection(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap) {
        Core_MDF_CCP_Custom_Metadata_Utility__c fileIntroRec = metaMap.get('AI_PROMPT_FILE_INTRO');
        if (fileIntroRec == null) return '';
        return fileIntroRec.Core_MDF_Field_5_txt__c;
    }

    private static String buildAnalysisModeSection(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap, Boolean hasDescription, Boolean hasFiles, List<String> fileNames) {
        Core_MDF_CCP_Custom_Metadata_Utility__c analysisRec = metaMap.get('AI_PROMPT_ANALYSIS_MODES');
        if (analysisRec == null) return '';
        String section = '';
        if (hasDescription && hasFiles) {
            section += analysisRec.Core_MDF_Field_1_txt__c + '\n';
            section += analysisRec.Core_MDF_Field_2_txt__c + '\n';
            section += analysisRec.Core_MDF_Field_3_txt__c + '\n';
            section += '- ' + analysisRec.Core_MDF_Field_4_txt__c + '\n';
            section += '- ' + analysisRec.Core_MDF_Field_5_txt__c + '\n';
            section += '- ' + analysisRec.Core_MDF_Field_6_txt__c + '\n';
            section += '- ' + analysisRec.Core_MDF_Field_7_txt__c + '\n';
            section += '- ' + analysisRec.Core_MDF_Field_8_txt__c + '\n';
            section += 'Files analyzed: ' + String.join(fileNames, ', ') + '\n\n';
        } else if (hasDescription) {
            section += analysisRec.Core_MDF_Field_9_txt__c + '\n';
            section += analysisRec.Core_MDF_Field_10_txt__c + '\n\n';
        } else {
            section += analysisRec.Core_MDF_Field_11_txt__c + '\n';
            section += analysisRec.Core_MDF_Field_12_txt__c + '\n';
            section += 'Files analyzed: ' + String.join(fileNames, ', ') + '\n\n';
        }
        return section;
    }

    private static String buildContentToAnalyzeSection(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap, String combinedContent) {
        Core_MDF_CCP_Custom_Metadata_Utility__c analysisRec = metaMap.get('AI_PROMPT_ANALYSIS_MODES');
        if (analysisRec == null) return '';
        String section = analysisRec.Core_MDF_Field_13_txt__c + '\n';
        section += combinedContent + '\n\n';
        return section;
    }

    private static String buildCombinedRulesSection(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap) {
        Core_MDF_CCP_Custom_Metadata_Utility__c combinedRulesRec = metaMap.get('AI_PROMPT_COMBINED_RULES');
        if (combinedRulesRec == null) return '';
        String rules = '12. ' + combinedRulesRec.Core_MDF_Field_1_txt__c + '\n';
        rules += '13. ' + combinedRulesRec.Core_MDF_Field_2_txt__c + '\n';
        rules += '14. ' + combinedRulesRec.Core_MDF_Field_3_txt__c + '\n';
        return rules;
    }

    private static String buildDateExtractionGuard(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap) {
        Integer yr     = Date.today().year();
        Integer nxtYr  = yr + 1;
        String  mon    = String.valueOf(Date.today().month()).leftPad(2, '0');
        String  dy     = String.valueOf(Date.today().day()).leftPad(2, '0');
        String  todayStr = yr + '-' + mon + '-' + dy;
        String  yrStr    = String.valueOf(yr);
        String  nxtYrStr = String.valueOf(nxtYr);

        Core_MDF_CCP_Custom_Metadata_Utility__c rec = metaMap.get('AI_PROMPT_DATE_GUARD');
        if (rec == null) return '';

        String rules = '\n' + rec.Core_MDF_Field_1_txt__c + '\n';
        rules += 'Today\'s date: ' + todayStr + '\n';
        rules += rec.Core_MDF_Field_2_txt__c + '\n';
        rules += rec.Core_MDF_Field_3_txt__c + '\n';
        rules += rec.Core_MDF_Field_4_txt__c + '\n';
        rules += rec.Core_MDF_Field_5_txt__c + '\n';
        rules += rec.Core_MDF_Field_6_txt__c.replace('{YEAR}', yrStr) + '\n';
        rules += rec.Core_MDF_Field_7_txt__c.replace('{YEAR}', yrStr).replace('{NEXT_YEAR}', nxtYrStr);
        rules += rec.Core_MDF_Field_8_txt__c.replace('{YEAR}', yrStr) + '\n\n';
        return rules;
    }

    private static String buildBrandTechnologySectionBoundaryRules(Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap) {
        Core_MDF_CCP_Custom_Metadata_Utility__c rec = metaMap.get('AI_PROMPT_BRAND_TECH_RULES');
        if (rec == null) return '';
        String rules = '\n=== ' + rec.Core_MDF_Field_1_txt__c + ' ===\n';
        rules += rec.Core_MDF_Field_2_txt__c + '\n\n';
        // Tier 1
        rules += rec.Core_MDF_Field_3_txt__c + '\n';
        rules += '1. ' + rec.Core_MDF_Field_4_txt__c + '\n\n';
        rules += '2. ' + rec.Core_MDF_Field_5_txt__c + '\n\n';
        rules += '3. ' + rec.Core_MDF_Field_6_txt__c + '\n\n';
        // Tier 2
        rules += rec.Core_MDF_Field_7_txt__c + '\n';
        rules += rec.Core_MDF_Field_8_txt__c + '\n\n';
        rules += '4. ' + rec.Core_MDF_Field_9_txt__c + '\n\n';
        rules += '5. ' + rec.Core_MDF_Field_10_txt__c + '\n\n';
        rules += '6. ' + rec.Core_MDF_Field_11_txt__c + '\n\n';
        // Tier 3
        rules += rec.Core_MDF_Field_12_txt__c + '\n';
        rules += rec.Core_MDF_Field_13_txt__c + '\n\n';
        rules += '7. ' + rec.Core_MDF_Field_14_txt__c + '\n\n';
        rules += '8. ' + rec.Core_MDF_Field_15_txt__c + '\n\n';
        rules += '9. ' + rec.Core_MDF_Field_16_txt__c + '\n\n';
        return rules;
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // SPECIFIC PROMPT BUILDERS - NOW FULLY METADATA-DRIVEN
    // ═══════════════════════════════════════════════════════════════════════════════
    
    // UPDATED: Added 2026 Priority Options section and Brand/Technology section boundary rules
    private static String buildAIPrompt(String description, Map<String, Object> availablePicklistValues) {
        Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap = loadPromptMetadata(); 
        String prompt = buildIntroSection(metaMap);
        prompt += 'Description: "' + description + '"\n\n';
        prompt += buildPicklistOptionsSection(availablePicklistValues);
        prompt += build2026PriorityOptionsSection(metaMap);  // ADDED THIS LINE
        prompt += buildBrandTechnologySectionBoundaryRules(metaMap);
        prompt += buildPicklistMatchingRules(metaMap);
        prompt += buildGenericPicklistExtractionProcess(metaMap);
        prompt += buildJSONStructureSection(metaMap);
        prompt += buildAdditionalFieldExtractionRules(metaMap);
        prompt += buildFieldSpecificValidationRules(metaMap);
        prompt += buildGeneralRulesSection(metaMap);
        prompt += buildFinalVerificationSection(metaMap);
        return prompt;
    }

    // UPDATED: Added 2026 Priority Options section and Brand/Technology section boundary rules
    private static String buildFileAIPrompt(String fileContent, Map<String, Object> availablePicklistValues, List<String> fileNames) {
        Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap = loadPromptMetadata();
        String prompt = buildFileIntroSection(metaMap, fileNames);
        prompt += buildDocumentContentSection(metaMap, fileContent);
        prompt += buildEnhancedDocumentTypeExtractionRules(metaMap);
        prompt += buildPicklistMatchingRules(metaMap);
        prompt += buildPicklistOptionsSection(availablePicklistValues);
        prompt += build2026PriorityOptionsSection(metaMap);  // ADDED THIS LINE
        prompt += buildBrandTechnologySectionBoundaryRules(metaMap);
        prompt += buildEnhancedPicklistExtractionProcess(metaMap);
        prompt += buildDocumentTypeScanningPatterns(metaMap);
        prompt += buildFileResponseFormat(metaMap);
        prompt += buildAdditionalFieldExtractionRules(metaMap);
        prompt += buildDateExtractionGuard(metaMap);
        prompt += buildFinalVerificationSection(metaMap);
        prompt += buildEnhancedRulesForNonExcel(metaMap);
        prompt += buildFileClosingSection(metaMap);
        return prompt;
    }

    // UPDATED: Added 2026 Priority Options section and Brand/Technology section boundary rules
    private static String buildCombinedAIPrompt(String combinedContent, Map<String, Object> availablePicklistValues, Boolean hasDescription, Boolean hasFiles, List<String> fileNames) {
        Map<String, Core_MDF_CCP_Custom_Metadata_Utility__c> metaMap = loadPromptMetadata();
        String prompt = buildIntroSection(metaMap);
        prompt += buildAnalysisModeSection(metaMap, hasDescription, hasFiles, fileNames);
        prompt += buildContentToAnalyzeSection(metaMap, combinedContent);
        if (hasFiles) {
            prompt += buildEnhancedDocumentTypeExtractionRules(metaMap);
        }
        prompt += buildPicklistOptionsSection(availablePicklistValues);
        prompt += build2026PriorityOptionsSection(metaMap);  // ADDED THIS LINE
        prompt += buildBrandTechnologySectionBoundaryRules(metaMap);
        prompt += buildPicklistMatchingRules(metaMap);
        prompt += buildEnhancedPicklistExtractionProcess(metaMap);       
        if (hasDescription && hasFiles) {
            prompt += buildCombinedAnalysisInstructions(metaMap);
        }
        prompt += buildJSONStructureSection(metaMap);
        prompt += buildAdditionalFieldExtractionRules(metaMap);
        prompt += buildFieldSpecificValidationRules(metaMap);
        prompt += buildGeneralRulesSection(metaMap);
        if (hasDescription && hasFiles) {
            prompt += buildCombinedRulesSection(metaMap);
        }
        prompt += buildFinalVerificationSection(metaMap);
        if (hasFiles) {
            prompt += buildEnhancedFinalInstructionsForNonExcel(metaMap);
        }
        return prompt;
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // FILE PROCESSING METHODS
    // ═══════════════════════════════════════════════════════════════════════════════
    
    public class FileExtractionResult {
        public String combinedText;
        public List<String> processedFiles;
        public String rawDataJson;
        
        public FileExtractionResult() {
            this.combinedText = '';
            this.processedFiles = new List<String>();
            this.rawDataJson = '';
        }
    }

    private static FileExtractionResult extractTextFromFiles(List<ContentVersion> versions) {
        FileExtractionResult result = new FileExtractionResult();
        List<Map<String, Object>> filesRawData = new List<Map<String, Object>>();
        for (ContentVersion cv : versions) {
            String fileText = extractTextFromFile(cv);
            if (String.isNotBlank(fileText)) {
                result.combinedText += '\n\n--- File: ' + cv.Title + '.' + cv.FileExtension + ' ---\n' + fileText;
                result.processedFiles.add(cv.Title + '.' + cv.FileExtension);  
                Map<String, Object> fileData = new Map<String, Object>();
                fileData.put('fileName', cv.Title);
                fileData.put('fileExtension', cv.FileExtension);
                fileData.put('fullFileName', cv.Title + '.' + cv.FileExtension);
                fileData.put('contentSize', cv.ContentSize);
                fileData.put('extractedText', fileText);
                fileData.put('extractionMethod', getExtractionMethod(cv.FileExtension));
                fileData.put('extractedAt', DateTime.now().format('yyyy-MM-dd HH:mm:ss'));
                filesRawData.add(fileData);
            }
        }
        Map<String, Object> rawDataJson = new Map<String, Object>();
        rawDataJson.put('totalFiles', filesRawData.size());
        rawDataJson.put('processedAt', DateTime.now().format('yyyy-MM-dd HH:mm:ss'));
        rawDataJson.put('files', filesRawData);
        result.rawDataJson = JSON.serialize(rawDataJson);
        return result;
    }

    private static String getExtractionMethod(String fileExtension) {
        if (String.isBlank(fileExtension)) {
            return 'unknown';
        }
        String ext = fileExtension.toLowerCase();
        if (ext == 'txt' || ext == 'csv' || ext == 'json' || ext == 'md' || ext == 'html') {
            return 'direct_text_read';
        } else if (ext == 'xlsx' || ext == 'xls' || ext == 'xlsm' || 
                   ext == 'pdf' || ext == 'docx' || ext == 'pptx') {
            return 'azure_ocr_extraction';
        } else {
            return 'generic_text_extraction';
        }
    }

    private static String extractTextFromFile(ContentVersion cv) {
        String fileText = '';
        String ext = (cv.FileExtension != null) ? cv.FileExtension.toLowerCase() : '';
        try {
            if (ext == 'txt' || ext == 'csv' || ext == 'json' || ext == 'md' || ext == 'html') {
                fileText = cv.VersionData.toString(); 
            } else if (ext == 'xlsx' || ext == 'xls' || ext == 'xlsm' || 
                       ext == 'pdf' || ext == 'docx' || ext == 'pptx') {
                fileText = extractDocumentWithOCR(cv);
            } else {
                try {
                    fileText = cv.VersionData.toString();
                } catch (Exception e) {
                    fileText = '[Binary file - could not extract text: ' + cv.Title + ']';
                }
            }
        } catch (Exception e) {
            fileText = '[Error reading file: ' + cv.Title + ']';
        }
        if (fileText.length() > 8000) {
            fileText = fileText.substring(0, 8000) + '\n... [content truncated]';
        }
        return fileText;
    }

    private static String extractDocumentWithOCR(ContentVersion cv) {
        String ext = (cv.FileExtension != null) ? cv.FileExtension.toLowerCase() : '';
        String description = getDocumentTypeDescription(ext, cv.Title);
        try {
            if (cv.ContentSize > 2500000) {
                return description + '[File too large for OCR processing]';
            }
            String base64Data = EncodingUtil.base64Encode(cv.VersionData);
            String outputWithOperationLocId = Core_MDF_FormRecognizerIntegration.readDocumentContents(base64Data);
            if (String.isBlank(outputWithOperationLocId)) {
                Core_MDF_CCP_UtilityClass.logErrorAsNormal('Operation Location Id is blank in Azure OCR Endpoint for ' + ext + ' file', 'Core_MDF_AI_Tracking__c');
                return description + getDocumentFallbackHint(ext);
            }
            String prebuildReadText = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimEzy_PrebuildRead');
            String rawData = Core_MDF_FormRecognizerIntegration.getDocumentAsString(prebuildReadText, outputWithOperationLocId);
            if (String.isNotBlank(rawData)) {
                description += 'OCR Extracted Content:\n';
                description += rawData;
            } else {
                description += getDocumentFallbackHint(ext);
            }
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            description += getDocumentFallbackHint(ext);
        }
        return description;
    }

    private static String getDocumentTypeDescription(String ext, String title) {
        String description = '';
        switch on ext {
            when 'xlsx', 'xls', 'xlsm' {
                description = 'Intel MDF Outcome-Based Campaign Planning Template\n';
            }
            when 'pdf' {
                description = 'PDF Document Analysis\n';
            }
            when 'docx' {
                description = 'Word Document Analysis\n';
            }
            when 'pptx' {
                description = 'PowerPoint Presentation Analysis\n';
            }
            when else {
                description = 'Document Analysis\n';
            }
        }
        description += 'File: ' + title + '\n\n';
        return description;
    }

    private static String getDocumentFallbackHint(String ext) {
        String hintt = '';
        switch on ext {
            when 'xlsx', 'xls', 'xlsm' {
                hintt = buildMDFTemplateHint();
            }
            when 'pdf' {
                hintt = 'PDF document structure (content could not be extracted):\n';
                hintt += 'This may contain campaign information, budget details, timelines, or other relevant data.\n';
                hintt += 'Common sections might include: Executive Summary, Campaign Overview, Budget Breakdown, Timeline, KPIs\n';
            }
            when 'docx' {
                hintt = 'Word document structure (content could not be extracted):\n';
                hintt += 'This may contain campaign proposals, detailed descriptions, or planning documents.\n';
                hintt += 'Common sections might include: Campaign Name, Description, Objectives, Budget, Timeline, Target Audience\n';
            }
            when 'pptx' {
                hintt = 'PowerPoint presentation structure (content could not be extracted):\n';
                hintt += 'This may contain campaign presentations with slides covering strategy, budget, and execution plans.\n';
                hintt += 'Common slides might include: Title, Overview, Strategy, Budget, Timeline, Success Metrics\n';
            }
            when else {
                hintt = 'Document content could not be extracted. This may contain relevant campaign or business information.\n';
            }
        }
        return hintt;
    }

    private static String buildMDFTemplateHint() {
        String hintt = 'Standard Intel MDF template structure (cell values could not be extracted):\n';
        hintt += 'Row 1: Campaign Name\n';
        hintt += 'Row 4: Campaign Description\n';
        hintt += 'Row 5: Priority (dropdown)\n';
        hintt += 'Row 6: Outcome Metrics (dropdown)\n';
        hintt += 'Row 10+: Tactic | Activity Description | Total Spending ($) | Intel Spending ($) | Tactics Metrics\n';
        hintt += 'IMPORTANT: Use the "Intel Spending ($)" column value as spendingAmount — NOT "Total Spending ($)".\n';
        hintt += 'Note: Tactic values include Event, Training, Digital Media, Incentive, Lead Cultivation, Technical Activation, Funded Headcount\n';
        return hintt;
    }

    private static Boolean isPrintable(String value) {
        if (String.isBlank(value)) return false;
        Integer nonPrintable = 0;
        Integer checkLength = Math.min(value.length(), 50);
        for (Integer i = 0; i < checkLength; i++) {
            Integer charCode = value.charAt(i);
            if (charCode < 32 && charCode != 9 && charCode != 10 && charCode != 13) {
                nonPrintable++;
            }
        }
        return (nonPrintable < 3);
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // UTILITY METHODS
    // ═══════════════════════════════════════════════════════════════════════════════
    
    private static List<String> getStringList(List<Object> objectList) {
        List<String> stringList = new List<String>();
        for (Object obj : objectList) {
            if (obj instanceof String) {
                stringList.add((String)obj);
            }
        }
        return stringList;
    }

    @AuraEnabled
    public static Map<String, Object> detectFocusAreaFromFile(List<String> contentDocumentIds) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            if (contentDocumentIds == null || contentDocumentIds.isEmpty()) {
                result.put('success', false);
                result.put('error', 'No files provided');
                return result;
            }
            // Get file content
            List<ContentVersion> versions = [
                SELECT Id, Title, FileExtension, VersionData, ContentSize FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds LIMIT 1
            ];
            if (versions.isEmpty()) {
                result.put('success', false);
                result.put('error', 'Could not retrieve file content');
                return result;
            }
            // Extract text from file
            String fileContent = extractTextFromFile(versions[0]);
            if (String.isBlank(fileContent)) {
                result.put('success', false);
                result.put('error', 'Could not extract text from file');
                return result;
            }
            // Detect focus area from content
            String detectedFocusArea = detectFocusAreaFromContent(fileContent);
            result.put('success', true);
            result.put('focusArea', detectedFocusArea);
            result.put('content', fileContent.length() > 500 ? fileContent.substring(0, 500) + '...' : fileContent);
        } catch (Exception e) {
            result.put('success', false);
            result.put('error', 'Error processing file: ' + e.getMessage());
        }
        return result;
    }

    private static String detectFocusAreaFromContent(String content) {
        String keyword = detectFocusAreaKeyword(content);
        return keyword != null ? keyword : 'Client Computing';
    }
}