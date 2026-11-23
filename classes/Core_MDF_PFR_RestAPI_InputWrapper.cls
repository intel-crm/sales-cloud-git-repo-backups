/**
 * @description Parses inbound activity payloads, resolves lookup aliases, and produces typed
 * PartnerFundRequest records plus structured validation failures.
 * Multi-Segment SPIF Seller Incentive Support - ENHANCED
 */
public inherited sharing class Core_MDF_PFR_RestAPI_InputWrapper {
    private static final String CAMPAIGN_REFERENCE_FIELD = 'Core_MDF_Campaign_Reference_Number__c';
    private static final String BUDGET_REFERENCE_FIELD = 'Core_MDF_budget_ref_nbr__c';
    private static final String MEMBER_ACCEPTOR_FIELD = 'Core_MDF_Member_Acceptor_Id__c';
    private static final String CHANNEL_PARTNER_FIELD = 'ChannelPartnerId';
    private static final String SALES_READINESS_ACTIVITY_CATEGORY_NORMALIZED = 'salesreadiness';
    private static final String TECH_SALES_ACTIVITY_CATEGORY_NORMALIZED = 'technicalsales';
    private static final String TECH_SALES_GOVERNMENT_NEXUS_FALLBACK_MESSAGE =
        'Remove entry in government entities as you have selected Technical Sales in ActivityCategory.';

    public List<PartnerFundRequest> partnerfundrequests { get; set; }
    public List<Core_MDF_PFR_RestAPI_Response.ErrorContent> validationFailures { get; set; }
    public List<FileUpload> fileUploads { get; set; }
    public Map<String, Decimal> ecosystemPartnerAllocations { get; set; }
    public List<SegmentInputDetail> segments { get; set; }

    /**
     * Returns parsed PartnerFundRequest records, or an empty list when the wrapper has none.
     */
    public List<PartnerFundRequest> getPartnerFundRequests() {
        return partnerfundrequests != null
            ? partnerfundrequests
            : new List<PartnerFundRequest>();
    }

    /**
     * Returns the inline file uploads supplied in the "Files" node, or an empty list when none.
     */
    public List<FileUpload> getFileUploads() {
        return fileUploads != null ? fileUploads : new List<FileUpload>();
    }

    /**
     * Returns ecosystem partner percentage allocations (partner name -> percentage), or empty map when none.
     */
    public Map<String, Decimal> getEcosystemPartnerAllocations() {
        return ecosystemPartnerAllocations != null ? ecosystemPartnerAllocations : new Map<String, Decimal>();
    }

    /**
     * Returns validation failures collected while parsing, or an empty list when there are none.
     */
    public List<Core_MDF_PFR_RestAPI_Response.ErrorContent> getValidationFailures() {
        return validationFailures != null
            ? validationFailures
            : new List<Core_MDF_PFR_RestAPI_Response.ErrorContent>();
    }
    
    /**
     * Returns parsed segments for multi-segment SPIF, or empty list when none.
     */
    public List<SegmentInputDetail> getSegments() {
        return segments != null ? segments : new List<SegmentInputDetail>();
    }
    
    /**
     * Returns parsed segment payloads as maps for utility validation.
     */
    public List<Map<String, Object>> getSegmentMaps() {
        List<Map<String, Object>> segmentMaps = new List<Map<String, Object>>();
        for (SegmentInputDetail segment : getSegments()) {
            if (segment != null) {
                segmentMaps.add(segment.toMap());
            }
        }
        return segmentMaps;
    }

    /**
     * Converts REST segment payloads to the JSON shape consumed by Core_MDF_SegmentParser.
     */
    public String getSegmentProductString() {
        List<Map<String, Object>> parserSegments = new List<Map<String, Object>>();
        for (SegmentInputDetail segment : getSegments()) {
            if (segment == null) {
                continue;
            }
            Map<String, Object> parserSegment = new Map<String, Object>();
            parserSegment.put('segmentId', segment.segmentName);
            parserSegment.put('Core_MDF_Segment_Name_nm', segment.segmentName);
            parserSegment.put('Core_MDF_Minimum_Forecast_Volume_nbr', segment.minimumForecastVolume == null ? null : String.valueOf(segment.minimumForecastVolume));
            parserSegment.put('Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr', segment.incentiveAmountPerUnit == null ? null : String.valueOf(segment.incentiveAmountPerUnit));
            parserSegment.put('Core_MDF_Maximum_Bundled_Volume_nbr', segment.maximumBundledVolume == null ? null : String.valueOf(segment.maximumBundledVolume));
            parserSegment.put('Core_MDF_Maximum_Cost_of_Bundle_nbr', segment.maximumCostOfBundle == null ? null : String.valueOf(segment.maximumCostOfBundle));
            Decimal estimatedShare;
            if (segment.maximumBundledVolume != null && segment.maximumCostOfBundle != null) {
                estimatedShare = segment.maximumBundledVolume * segment.maximumCostOfBundle;
            } else if (segment.minimumForecastVolume != null && segment.incentiveAmountPerUnit != null) {
                estimatedShare = segment.minimumForecastVolume * segment.incentiveAmountPerUnit;
            }
            parserSegment.put('Core_MDF_Estimated_Share_of_SPIF_amt', estimatedShare == null ? null : String.valueOf(estimatedShare.setScale(2, System.RoundingMode.HALF_UP)));
            parserSegment.put('productIdSet', segment.productIds == null ? new List<String>() : segment.productIds);
            parserSegments.add(parserSegment);
        }
        return parserSegments.isEmpty() ? null : JSON.serialize(parserSegments);
    }

    /**
     * Parses the REST request body, resolves configured lookup aliases, and separates valid PFR records from parsing failures.
     *
     * @param reqBody The raw JSON request body.
     */
    public static Core_MDF_PFR_RestAPI_InputWrapper parse(String reqBody) {
        Core_MDF_PFR_RestAPI_InputWrapper wrapper = new Core_MDF_PFR_RestAPI_InputWrapper();
        wrapper.partnerfundrequests = new List<PartnerFundRequest>();
        wrapper.validationFailures = new List<Core_MDF_PFR_RestAPI_Response.ErrorContent>();
        wrapper.segments = new List<SegmentInputDetail>();

        if (String.isBlank(reqBody)) {
            return wrapper;
        }

        // Guardrail: reject payloads that repeat the same activity field key, because JSON parsing
        // would otherwise silently keep one value and lose the others.
        List<String> duplicateFields = findDuplicateActivityFields(reqBody);
        if (!duplicateFields.isEmpty()) {
            wrapper.validationFailures.add(
                buildFailure(null,new List<String>{Core_MDF_PFR_RestAPI_Constants.formatError(
                    Core_MDF_PFR_RestAPI_Constants.ERR_9014_INVALID_FIELD_VAL,
                            new List<String>{ 'Duplicate field(s) in activity payload: ' + String.join(duplicateFields, ', ') })}));
            return wrapper;
        }

        Object rawPayload = JSON.deserializeUntyped(reqBody);
        if (!(rawPayload instanceof Map<String, Object>)) {
            // Error when root is not JSON object
            wrapper.validationFailures.add(buildFailure(null, new List<String>{ Core_MDF_PFR_RestAPI_Constants.ERR_9010_INVALID_JSON_BODY }));
            return wrapper;
        }

        // Root node must contain a single "activity" object.
        Map<String, Object> payloadMap = (Map<String, Object>) rawPayload;
        ActivityWrapper dto = extractActivity(payloadMap, wrapper);
        if (dto == null) {
            return wrapper;
        }

        List<String> errors = new List<String>();
        if (String.isNotBlank(dto.PartnerContact) && !Pattern.matches(
            '^[A-Za-z0-9_%+\'-]+(?:\\.[A-Za-z0-9_%+\'-]+)*@[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?(?:\\.[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?)+$',
            dto.PartnerContact
        )) {
            errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(
                Core_MDF_PFR_RestAPI_Constants.ERR_9014_INVALID_FIELD_VAL,
                new List<String>{ 'PartnerContact must be a valid email address.' }
            ));
        }
        errors.addAll(validateConditionalIncentiveFields(dto, payloadMap, wrapper));
        if (!errors.isEmpty()) {
            wrapper.validationFailures.add(buildFailure(dto.ActivityName, errors));
            return wrapper;
        }

        // Mandatory-field validation is skipped on update (partial updates are allowed).
        if (!'update'.equalsIgnoreCase(Core_MDF_PFR_RestAPI.actionType)) {
            errors.addAll(validateRequiredFields(dto));
        }

        // Resolve the friendly lookup names into record Ids.
        Map<String, Id> resolvedIds = new Map<String, Id>();
        errors.addAll(resolveLookups(dto, resolvedIds));

        if (!errors.isEmpty()) {
            wrapper.validationFailures.add(buildFailure(dto.ActivityName, errors));
            return wrapper;
        }

        try {
            // Build the PartnerFundRequest directly from the DTO, then stamp the resolved lookup Ids.
            PartnerFundRequest record = dto.toRecord();
            for (String field : resolvedIds.keySet()) {
                record.put(field, resolvedIds.get(field));
            }
            wrapper.partnerfundrequests.add(record);
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            // A bad typed value (e.g. an invalid date) -> per-record invalid field error.
            wrapper.validationFailures.add(
                buildFailure(dto.ActivityName, new List<String>{ Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9014_INVALID_FIELD_VAL, new List<String>{ e.getMessage() }) })
            );
        }

        return wrapper;
    }

    private static List<String> validateConditionalIncentiveFields(ActivityWrapper dto, Map<String, Object> payloadMap, Core_MDF_PFR_RestAPI_InputWrapper wrapper) {
        List<String> errors = new List<String>();

        if (isTechnicalSalesWithGovernmentInvolvement(dto)) {
            String formattedError = Core_MDF_PFR_RestAPI_Constants.formatError(
                Core_MDF_PFR_RestAPI_Constants.ERR_9202_TECH_SALES_GOVERNMENT_NEXUS_NOT_ALLOWED,
                null
            );
            errors.add(formattedError != Core_MDF_PFR_RestAPI_Constants.ERR_9202_TECH_SALES_GOVERNMENT_NEXUS_NOT_ALLOWED
                ? formattedError
                : Core_MDF_PFR_RestAPI_Constants.ERR_9202_TECH_SALES_GOVERNMENT_NEXUS_NOT_ALLOWED + ': ' + TECH_SALES_GOVERNMENT_NEXUS_FALLBACK_MESSAGE);
        }

        Boolean usesIncentiveValidationRules = usesIncentiveValidationRules(dto);
        Boolean hasSegmentValues = hasEnteredSegments(payloadMap);

        // Contest/Sweepstakes types: REQUIRE winner fields
        Boolean requiresWinnerFields =
            usesIncentiveValidationRules &&
            (isBuyerWinnerParticipantRequiredType(dto.ActivityTypes) || isSellerWinnerParticipantRequiredType(dto.ActivityTypes));

        // Segment-type activities (Bundle/Target): FORBID winner fields, REQUIRE segments
        Boolean forbidsWinnerFields =
            usesIncentiveValidationRules && isSegmentRequiredType(dto.ActivityTypes);

        // Contest/Sweepstakes types forbid segment data
        Boolean forbidsSegments =
            usesIncentiveValidationRules &&
            (isBuyerWinnerParticipantRequiredType(dto.ActivityTypes) || isSellerWinnerParticipantRequiredType(dto.ActivityTypes));

        // ===== VALIDATION 1: Segment-type activities must NOT have winner fields =====
        if (forbidsWinnerFields && hasAnyWinnerField(dto)) {
            errors.add('NumberOfWinners and NumberOfExpectedParticipants should not be provided when Activity type = Offer-Bundle/Offer-Target/SPIF- Target/SPIF-Volume');
            return errors;
        }

        // ===== VALIDATION 2: Contest/Sweepstakes types must not have segment data =====
        if (forbidsSegments && hasSegmentValues) {
            errors.add('Segments should not be provided when Activity type = Offer- Contest/Offer-Sweepstakes/SPIF- Contest');
            return errors;
        }

        // ===== VALIDATION 3: Contest/Sweepstakes types REQUIRE winner fields =====
        if (requiresWinnerFields) {
            if (dto.NumberOfWinners == null || dto.NumberOfExpectedParticipants == null) {
                errors.add('NumberOfWinners and NumberOfExpectedParticipants is required when Activity type=Offer- Contest/Offer-Sweepstakes/SPIF- Contest');
            }
            if (dto.NumberOfWinners != null && dto.NumberOfExpectedParticipants != null && dto.NumberOfWinners > dto.NumberOfExpectedParticipants) {
                errors.add('Number of Winners cannot be greater than Number of Expected Participants.');
            }
            if (dto.NumberOfWinners != null && dto.NumberOfExpectedParticipants != null && dto.NumberOfExpectedParticipants > 0
                && dto.NumberOfWinners > (dto.NumberOfExpectedParticipants * 0.33)) {
                errors.add('Winner % should not be greater than 33%');
            }
        }

        // ===== VALIDATION 4: Segment-type activities REQUIRE segments =====
        if (forbidsWinnerFields) {
            if (!hasSegmentValues) {
                errors.add('Segment is required when Activity type = Offer-Bundle/Offer-Target/SPIF- Target/SPIF-Volume');
                return errors;
            }
            parseRootSegments(payloadMap, wrapper);
            if (!wrapper.validationFailures.isEmpty()) {
                errors.addAll(wrapper.validationFailures[0].errors);
                wrapper.validationFailures.clear();
            }
        }

        return errors;
    }

    private static Boolean isBuyerIncentive(ActivityWrapper dto) {
        if (dto == null || String.isBlank(dto.ActivityCategory)) {
            return false;
        }
        String normalizedCategory = normalizeIncentiveValue(dto.ActivityCategory);
        return normalizedCategory == 'buyerincentive';
    }

    private static Boolean isSellerIncentive(ActivityWrapper dto) {
        if (dto == null || String.isBlank(dto.ActivityCategory)) {
            return false;
        }
        String normalizedCategory = normalizeIncentiveValue(dto.ActivityCategory);
        return normalizedCategory == 'sellerincentive';
    }

    private static Boolean isSalesReadiness(ActivityWrapper dto) {
        if (dto == null || String.isBlank(dto.ActivityCategory)) {
            return false;
        }
        String normalizedCategory = normalizeIncentiveValue(dto.ActivityCategory);
        return normalizedCategory == SALES_READINESS_ACTIVITY_CATEGORY_NORMALIZED;
    }

    private static Boolean isTechnicalSales(ActivityWrapper dto) {
        if (dto == null || String.isBlank(dto.ActivityCategory)) {
            return false;
        }
        String normalizedCategory = normalizeIncentiveValue(dto.ActivityCategory);
        return normalizedCategory == TECH_SALES_ACTIVITY_CATEGORY_NORMALIZED;
    }

    private static Boolean usesIncentiveValidationRules(ActivityWrapper dto) {
        return isBuyerIncentive(dto) || isSellerIncentive(dto) || isSalesReadiness(dto) || isTechnicalSales(dto);
    }

    private static Boolean hasAnyWinnerField(ActivityWrapper dto) {
        return dto != null && (dto.NumberOfWinners != null || dto.NumberOfExpectedParticipants != null);
    }

    private static Boolean hasEnteredSegments(Map<String, Object> payloadMap) {
        if (payloadMap == null || !payloadMap.containsKey('Segments')) {
            return false;
        }
        Object segmentsObj = payloadMap.get('Segments');
        if (segmentsObj == null) {
            return false;
        }
        if (segmentsObj instanceof List<Object>) {
            for (Object rawSegment : (List<Object>) segmentsObj) {
                if (hasEnteredSegmentValue(rawSegment)) {
                    return true;
                }
            }
            return false;
        }
        return true;
    }

    private static Boolean hasEnteredSegmentValue(Object rawSegment) {
        if (!(rawSegment instanceof Map<String, Object>)) {
            return rawSegment != null;
        }

        Map<String, Object> segmentMap = (Map<String, Object>) rawSegment;
        if (isEnteredValue(segmentMap.get('SegmentName'))
            || isEnteredValue(segmentMap.get('MinimumForecastVolume'))
            || isEnteredValue(segmentMap.get('IncentiveAmountPerUnit'))
            || isEnteredValue(segmentMap.get('MaximumBundledVolume'))
            || isEnteredValue(segmentMap.get('MaximumCostOfBundle'))) {
            return true;
        }

        Object productIdsObj = segmentMap.get('ProductIds');
        if (productIdsObj instanceof List<Object>) {
            for (Object productId : (List<Object>) productIdsObj) {
                if (isEnteredValue(productId)) {
                    return true;
                }
            }
            return false;
        }
        return isEnteredValue(productIdsObj);
    }

    private static Boolean isEnteredValue(Object value) {
        return value != null && !(value instanceof String && String.isBlank((String) value));
    }

    private static Boolean isBuyerWinnerParticipantRequiredType(String activityType) {
        Set<String> requiredTypes = new Set<String>{ 'offercontest', 'offersweepstakes' };
        return requiredTypes.contains(normalizeIncentiveValue(activityType));
    }

    private static Boolean isSellerWinnerParticipantRequiredType(String activityType) {
        Set<String> requiredTypes = new Set<String>{ 'spifcontest' };
        return requiredTypes.contains(normalizeIncentiveValue(activityType));
    }

    private static Boolean isSegmentRequiredType(String activityType) {
        Set<String> requiredTypes = new Set<String>{ 'offerbundle', 'offertarget', 'spiftarget', 'spifvolume' };
        return requiredTypes.contains(normalizeIncentiveValue(activityType));
    }

    private static String normalizeIncentiveValue(String value) {
        return String.isBlank(value) ? '' : value.replaceAll('[^A-Za-z0-9]', '').toLowerCase();
    }

    private static Boolean isTechnicalSalesWithGovernmentInvolvement(ActivityWrapper dto) {
        return dto != null
            && normalizeIncentiveValue(dto.ActivityCategory) == TECH_SALES_ACTIVITY_CATEGORY_NORMALIZED
            && String.isNotBlank(dto.GovernmentInvolvement);
    }

    private static void parseRootSegments(Map<String, Object> payloadMap, Core_MDF_PFR_RestAPI_InputWrapper wrapper) {
        Object segmentsObj = payloadMap != null ? payloadMap.get('Segments') : null;
        if (segmentsObj == null) {
            return;
        }
        if (!(segmentsObj instanceof List<Object>)) {
            wrapper.validationFailures.add(buildFailure(null, new List<String>{ 'Segments must be an array of segment objects' }));
            return;
        }

        List<Object> segmentsList = (List<Object>) segmentsObj;
        if (segmentsList.isEmpty()) {
            wrapper.validationFailures.add(buildFailure(null, new List<String>{ Core_MDF_PFR_RestAPI_Constants.MISSING_SEGMENTS }));
            return;
        }
        if (segmentsList.size() > 10) {
            wrapper.validationFailures.add(buildFailure(null, new List<String>{ Core_MDF_PFR_RestAPI_Constants.INVALID_SEGMENT_COUNT }));
            return;
        }

        Set<String> seenSegments = new Set<String>();
        List<String> errors = new List<String>();
        for (Integer i = 0; i < segmentsList.size(); i++) {
            if (!(segmentsList[i] instanceof Map<String, Object>)) {
                errors.add('Segment ' + i + ' is not a valid object');
                continue;
            }
            SegmentInputDetail segment = parseSegmentDetail((Map<String, Object>) segmentsList[i], i, errors);
            if (segment == null) {
                continue;
            }
            String normalizedSegmentName = segment.segmentName.trim().toLowerCase();
            if (seenSegments.contains(normalizedSegmentName)) {
                errors.add('Duplicate segment: ' + segment.segmentName);
                continue;
            }
            seenSegments.add(normalizedSegmentName);
            wrapper.segments.add(segment);
        }
        if (!errors.isEmpty()) {
            wrapper.validationFailures.add(buildFailure(null, errors));
            return;
        }
        errors.addAll(validateSegmentProductIds(wrapper.segments));
        if (!errors.isEmpty()) {
            wrapper.validationFailures.add(buildFailure(null, errors));
        }
    }

    private static List<String> validateSegmentProductIds(List<SegmentInputDetail> segments) {
        List<String> errors = new List<String>();
        if (segments == null || segments.isEmpty()) {
            return errors;
        }

        Set<Id> productIds = new Set<Id>();
        Map<String, String> rawProductIdById = new Map<String, String>();
        for (SegmentInputDetail segment : segments) {
            if (segment == null || segment.productIds == null) {
                continue;
            }
            for (String rawProductId : segment.productIds) {
                try {
                    Id productId = Id.valueOf(rawProductId);
                    if (productId.getSObjectType() != Product2.SObjectType) {
                        errors.add('ProductIds value "' + rawProductId + '" is not a Product2 Id.');
                        continue;
                    }
                    productIds.add(productId);
                    rawProductIdById.put(String.valueOf(productId), rawProductId);
                } catch (Exception e) {
                    Core_MDF_CCP_UtilityClass.logError(e);
                    errors.add('ProductIds value "' + rawProductId + '" is not a valid Salesforce Id.');
                }
            }
        }

        if (productIds.isEmpty()) {
            return errors;
        }

        Set<Id> existingProductIds = new Set<Id>();
        for (Product2 productRecord : [SELECT Id FROM Product2 WHERE Id IN :productIds]) {
            existingProductIds.add(productRecord.Id);
        }
        for (Id productId : productIds) {
            if (!existingProductIds.contains(productId)) {
                errors.add('ProductIds value "' + rawProductIdById.get(String.valueOf(productId)) + '" was not found in Product2.');
            }
        }
        return errors;
    }

    /**
     * Returns any duplicate field names found inside the top-level "activity" JSON object.
     * Keys outside the activity object are ignored.
     */
    private static List<String> findDuplicateActivityFields(String reqBody) {
        List<String> duplicates = new List<String>();
        if (String.isBlank(reqBody)) {
            return duplicates;
        }

        Map<String, Integer> keyCounts = new Map<String, Integer>();
        try {
            JSONParser parser = JSON.createParser(reqBody);
            Boolean inActivityObject = false;
            Integer activityDepth = 0;

            while (parser.nextToken() != null) {
                JSONToken token = parser.getCurrentToken();

                if (token == JSONToken.FIELD_NAME) {
                    String fieldName = parser.getText();

                    // Enter the top-level activity object.
                    if (!inActivityObject && fieldName == 'activity') {
                        JSONToken valueToken = parser.nextToken();
                        if (valueToken == JSONToken.START_OBJECT) {
                            inActivityObject = true;
                            activityDepth = 1;
                        }
                        continue;
                    }

                    // Count keys only inside the activity object.
                    if (inActivityObject) {
                        keyCounts.put(fieldName, keyCounts.containsKey(fieldName) ? keyCounts.get(fieldName) + 1 : 1);
                    }
                } else if (inActivityObject) {
                    if (token == JSONToken.START_OBJECT) {
                        activityDepth++;
                    } else if (token == JSONToken.END_OBJECT) {
                        activityDepth--;
                        if (activityDepth == 0) {
                            break;
                        }
                    }
                }
            }
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            // Ignore malformed JSON here; parse() already returns a structured invalid-body error.
            return duplicates;
        }

        for (String key : keyCounts.keySet()) {
            if (keyCounts.get(key) > 1) {
                duplicates.add(key);
            }
        }
        return duplicates;
    }

    /**
     * Reads the single "activity" object from the request root node and deserializes it into the
     * strongly-typed ActivityWrapper DTO. Returns null when no activity node is present.
     *
     * @param payload The deserialized request body root map.
     */
    private static ActivityWrapper extractActivity(Map<String, Object> payload, Core_MDF_PFR_RestAPI_InputWrapper wrapper) {
        Object activityNode = payload.get('activity');
        if (!(activityNode instanceof Map<String, Object>)) {
            // Preserve prior behaviour: a missing activity node yields no records.
            if (activityNode == null) {
                return null;
            }
            return (ActivityWrapper) JSON.deserialize(JSON.serialize(activityNode), ActivityWrapper.class);
        }

        Map<String, Object> activityMap = (Map<String, Object>) activityNode;

        // "Currency" is a reserved keyword in Apex so we map it to our DTO-safe field name.
        if (activityMap.containsKey('Currency') && !activityMap.containsKey('Currency_x')) {
            activityMap.put('Currency_x', activityMap.remove('Currency'));
        }

        mapActivityFieldAlias(activityMap, 'Number of Winners', 'NumberOfWinners');
        mapActivityFieldAlias(activityMap, 'NumberOfPotentialWinners', 'NumberOfWinners');
        mapActivityFieldAlias(activityMap, 'Number of Potential Winners', 'NumberOfWinners');
        mapActivityFieldAlias(activityMap, 'Number of Expected Participants', 'NumberOfExpectedParticipants');
        normalizeBlankDecimalFields(activityMap, new List<String>{
            'ActivitySpendingLimitLocal',
            'ReimbursementAmt',
            'RequestedAmount',
            'NumberOfWinners',
            'NumberOfExpectedParticipants'
        });

        mapQuestionField(
            activityMap,
            'Is this Activity targeting government entities or state-owned enterprises or having key participants from government entities or state-owned enterprises or their employees?',
            'GovernmentInvolvement'
        );
        Boolean isTechnicalSalesCategory = normalizeIncentiveValue(String.valueOf(activityMap.get('ActivityCategory'))) == TECH_SALES_ACTIVITY_CATEGORY_NORMALIZED;
        if (!isTechnicalSalesCategory && (!activityMap.containsKey('GovernmentInvolvement') || String.isBlank(String.valueOf(activityMap.get('GovernmentInvolvement'))))) {
            activityMap.put('GovernmentInvolvement', 'No');
        }
        mapQuestionField(
            activityMap,
            'Does your event include one or more Competitive Elements?',
            'CompetitiveElements'
        );

        // Extract any inline file uploads and remove the "Files" node BEFORE deserializing the DTO, so the
        // (potentially large) base64 file content is never duplicated through the DTO JSON round-trip.
        wrapper.fileUploads = extractFileUploads(activityMap.get('Files'));
        activityMap.remove('Files');

        // Extract ecosystem partner allocations and remove the node BEFORE deserializing the DTO
        wrapper.ecosystemPartnerAllocations = extractEcosystemPartnerAllocations(activityMap.get('EcosystemPartnerAllocations'));
        if (wrapper.ecosystemPartnerAllocations.isEmpty()) {
            wrapper.ecosystemPartnerAllocations = extractLegacyEcoPercentageAllocation(
                activityMap.get('EcosystemPartner'),
                activityMap.get('EcoPercentageAllocation')
            );
        }
        activityMap.remove('EcosystemPartnerAllocations');
        activityMap.remove('EcoPercentageAllocation');

        return (ActivityWrapper) JSON.deserialize(JSON.serialize(activityMap), ActivityWrapper.class);
    }

    private static void mapQuestionField(Map<String, Object> activityMap, String questionKey, String dtoFieldName) {
        if (activityMap.containsKey(questionKey) && !activityMap.containsKey(dtoFieldName)) {
            activityMap.put(dtoFieldName, activityMap.get(questionKey));
        }
    }

    private static void mapActivityFieldAlias(Map<String, Object> activityMap, String sourceKey, String dtoFieldName) {
        if (activityMap.containsKey(sourceKey) && !activityMap.containsKey(dtoFieldName)) {
            activityMap.put(dtoFieldName, activityMap.get(sourceKey));
        }
    }

    private static void normalizeBlankDecimalFields(Map<String, Object> activityMap, List<String> fieldNames) {
        for (String fieldName : fieldNames) {
            if (activityMap.containsKey(fieldName) && activityMap.get(fieldName) instanceof String && String.isBlank((String) activityMap.get(fieldName))) {
                activityMap.put(fieldName, null);
            }
        }
    }

    /**
     * Parses the optional "EcosystemPartnerAllocations" node (a single object or an array of objects)
     * into a map of partner name to percentage allocation.
     * Returns an empty map when no allocations are present or the node is malformed.
     */
    private static Map<String, Decimal> extractEcosystemPartnerAllocations(Object allocationsNode) {
        Map<String, Decimal> allocations = new Map<String, Decimal>();
        if (allocationsNode == null) {
            return allocations;
        }
        List<Object> rawAllocations = allocationsNode instanceof List<Object>
            ? (List<Object>) allocationsNode
            : new List<Object>{ allocationsNode };
        for (Object raw : rawAllocations) {
            if (raw instanceof Map<String, Object>) {
                Map<String, Object> allocMap = (Map<String, Object>) raw;
                String partner = stringFromMap(allocMap, 'partner');
                Object percentObj = allocMap.get('percent');
                if (String.isNotBlank(partner) && percentObj != null) {
                    try {
                        Decimal percent = Decimal.valueOf(String.valueOf(percentObj));
                        allocations.put(partner.trim(), percent);
                    } catch (Exception e) {
                        Core_MDF_CCP_UtilityClass.logError(e);
                        // Skip malformed percentage values
                    }
                }
            }
        }
        return allocations;
    }

    /**
     * Parses the legacy scalar "EcoPercentageAllocation" field and maps it to selected ecosystem partners.
     * This keeps older payloads such as "EcosystemPartner": "Partner A", "EcoPercentageAllocation": "100" working.
     */
    private static Map<String, Decimal> extractLegacyEcoPercentageAllocation(Object ecosystemPartnerNode, Object percentNode) {
        Map<String, Decimal> allocations = new Map<String, Decimal>();
        if (ecosystemPartnerNode == null || percentNode == null) {
            return allocations;
        }

        String ecosystemPartners = String.valueOf(ecosystemPartnerNode);
        if (String.isBlank(ecosystemPartners)) {
            return allocations;
        }

        List<String> partners = new List<String>();
        for (String partner : ecosystemPartners.split(';')) {
            if (String.isNotBlank(partner)) {
                partners.add(partner.trim());
            }
        }
        if (partners.isEmpty()) {
            return allocations;
        }

        if (isBlankEcoPercentageAllocation(percentNode)) {
            for (String partner : partners) {
                allocations.put(partner, 0);
            }
            return allocations;
        }

        List<Decimal> percentages = parsePercentageValues(percentNode);
        if (percentages.isEmpty()) {
            return allocations;
        }

        if (percentages.size() == partners.size()) {
            for (Integer index = 0; index < partners.size(); index++) {
                allocations.put(partners[index], percentages[index]);
            }
            return allocations;
        }

        if (percentages.size() == 1) {
            for (String partner : partners) {
                allocations.put(partner, percentages[0]);
            }
        }
        return allocations;
    }

    private static Boolean isBlankEcoPercentageAllocation(Object percentNode) {
        if (percentNode == null) {
            return true;
        }
        if (percentNode instanceof List<Object>) {
            for (Object rawValue : (List<Object>) percentNode) {
                if (rawValue != null && String.isNotBlank(String.valueOf(rawValue))) {
                    return false;
                }
            }
            return true;
        }
        return String.isBlank(String.valueOf(percentNode));
    }

    private static List<Decimal> parsePercentageValues(Object percentNode) {
        List<Decimal> percentages = new List<Decimal>();
        if (percentNode == null) {
            return percentages;
        }

        List<Object> rawValues = new List<Object>();
        if (percentNode instanceof List<Object>) {
            rawValues.addAll((List<Object>) percentNode);
        } else {
            String rawText = String.valueOf(percentNode);
            if (String.isBlank(rawText)) {
                return percentages;
            }
            String delimiter = rawText.contains(';') ? ';' : rawText.contains(',') ? ',' : null;
            if (delimiter == null) {
                rawValues.add(rawText);
            } else {
                for (String token : rawText.split(delimiter)) {
                    rawValues.add(token);
                }
            }
        }

        for (Object rawValue : rawValues) {
            if (rawValue != null && String.isNotBlank(String.valueOf(rawValue))) {
                try {
                    percentages.add(Decimal.valueOf(String.valueOf(rawValue).trim()));
                } catch (Exception e) {
                    Core_MDF_CCP_UtilityClass.logError(e);
                    return new List<Decimal>();
                }
            }
        }
        return percentages;
    }

    /**
     * Parses the optional inline "Files" node (a single object or an array of objects) into a list of
     * FileUpload values. Returns an empty list when no files are present or the node is malformed.
     */
    private static List<FileUpload> extractFileUploads(Object filesNode) {
        List<FileUpload> uploads = new List<FileUpload>();
        if (filesNode == null) {
            return uploads;
        }
        List<Object> rawFiles = filesNode instanceof List<Object>
            ? (List<Object>) filesNode
            : new List<Object>{ filesNode };
        for (Object raw : rawFiles) {
            if (raw instanceof Map<String, Object>) {
                Map<String, Object> fileMap = (Map<String, Object>) raw;
                FileUpload upload = new FileUpload();
                upload.FileName = stringFromMap(fileMap, 'FileName');
                upload.file = stringFromMap(fileMap, 'file');
                upload.comment = stringFromMap(fileMap, 'comment');
                uploads.add(upload);
            }
        }
        return uploads;
    }

    /**
     * Reads a String value from a map by key, returning null when the key is absent or the value is null.
     */
    private static String stringFromMap(Map<String, Object> source, String key) {
        Object value = source.get(key);
        return value == null ? null : String.valueOf(value);
    }

    /**
     * Validates that every mandatory activity field is present and non-blank, returning one
     * ERR-9015 error per missing field. Mirrors the prior required-field behaviour exactly.
     */
    private static List<String> validateRequiredFields(ActivityWrapper dto) {
        List<String> errors = new List<String>();
        addRequiredError(errors, 'Title', dto.ActivityName);
        addRequiredError(errors, 'Activity Description', dto.ActivityDescription);
        addRequiredError(errors, 'Start Date', dto.StartDate);
        addRequiredError(errors, 'End Date', dto.EndDate);
        addRequiredError(errors, 'Budget Type', dto.BudgetType);
        addRequiredError(errors, 'Budget Amount Local', dto.ActivitySpendingLimitLocal);
        addRequiredError(errors, 'Product Type', dto.ProductType);
        addRequiredError(errors, 'Budget Reference Number', dto.BudgetReferenceNumber);
        addRequiredError(errors, 'Industry', dto.Industry);
        addRequiredError(errors, 'Member Acceptor', dto.MemberAcceptorUsername);
        addRequiredError(errors, 'Currency', dto.Currency_x);
        return errors;
    }

    /**
     * Adds an ERR-9015 error for the given display name when the value is null or blank.
     */
    private static void addRequiredError(List<String> errors, String displayName, Object value) {
        if (value == null || String.isBlank(String.valueOf(value))) {
            errors.add(
                Core_MDF_PFR_RestAPI_Constants.formatError(
                    Core_MDF_PFR_RestAPI_Constants.ERR_9015_REQUIRED_FIELD_MISSING,
                    new List<String>{ displayName }
                )
            );
        }
    }

    /**
     * Resolves each friendly reference name on the DTO into a record Id, returning any
     * unresolved/ambiguous lookup errors and filling resolvedIds (keyed by target field API name):
     *   CampaignReferenceNumber -> CampaignId, AccountName -> ChannelPartnerId,
     *   IntelApproverUsername -> Core_MDF_Intel_Activity_Owner_Id__c, BudgetReferenceNumber -> BudgetId,
     *   MemberAcceptorUsername -> Core_MDF_Member_Acceptor_Id__c.
     *   (Record Type is derived from the Campaign program in the Utility, not from the payload.)
     */
    private static List<String> resolveLookups(ActivityWrapper dto, Map<String, Id> resolvedIds) {
        List<String> errors = new List<String>();
        resolveCampaignReference(resolvedIds, errors, dto.Campaign);
        resolveAccountReference(resolvedIds, errors, dto.AccountName);
        // Record Type is no longer supplied by the external system; it is derived from the Campaign
        // program inside Core_MDF_PFR_RestAPI_Utility. The friendly "Program" payload field is removed.
        resolveIntelApproverLookup(resolvedIds, errors, dto.IntelApproverUsername);
        resolveLookup(resolvedIds, errors, dto.BudgetReferenceNumber, 'BudgetId', 'PartnerMarketingBudget', BUDGET_REFERENCE_FIELD, 'budget reference number');
        // Member Acceptor is resolved last so the resolved Channel Partner Id is available
        // for surfacing the list of eligible usernames when the submitted username cannot be resolved.
        resolveMemberAcceptorLookup(resolvedIds, errors, dto.MemberAcceptorUsername);
        return errors;
    }

    private static void resolveCampaignReference(Map<String, Id> resolvedIds, List<String> errors, String value) {
        if (String.isBlank(value)) {
            return;
        }
        String val = value.trim();
        List<Campaign> campaigns = new List<Campaign>();
        Id campaignId = parseCampaignId(val);
        if (campaignId != null) {
            campaigns = [SELECT Id FROM Campaign WHERE Id = :campaignId LIMIT 1];
        } else {
            campaigns = [SELECT Id FROM Campaign WHERE Core_MDF_Campaign_Reference_Number__c = :val LIMIT 2];
        }

        if (campaigns.isEmpty()) {
            errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9012_UNRESOLVED_LOOKUP, new List<String>{ 'CampaignId', 'campaign id or campaign reference number', val }));
        } else if (campaigns.size() > 1) {
            errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9013_MULTIPLE_MATCHES, new List<String>{ 'CampaignId', 'campaign reference number', val }));
        } else {
            resolvedIds.put('CampaignId', campaigns[0].Id);
        }
    }

    private static void resolveAccountReference(Map<String, Id> resolvedIds, List<String> errors, String value) {
        if (String.isBlank(value)) {
            return;
        }
        String val = value.trim();
        Campaign campaignContext = getCampaignAccountContext(resolvedIds.get('CampaignId'));
        List<Account> accounts = new List<Account>();
        Id accountId = parseAccountId(val);

        if (accountId != null) {
            accounts = queryActiveAccounts(accountId, null, campaignContext, 1);
        } else {
            accounts = queryActiveAccounts(null, val, campaignContext, 2);
        }

        if (accounts.isEmpty()) {
            errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9012_UNRESOLVED_LOOKUP, new List<String>{ CHANNEL_PARTNER_FIELD, 'active account id or account name in the campaign hierarchy', val }));
        } else if (accounts.size() > 1) {
            errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9013_MULTIPLE_MATCHES, new List<String>{ CHANNEL_PARTNER_FIELD, 'account name in the campaign hierarchy', val }));
        } else {
            resolvedIds.put(CHANNEL_PARTNER_FIELD, accounts[0].Id);
        }
    }

    private static Campaign getCampaignAccountContext(Id campaignId) {
        if (campaignId == null) {
            return null;
        }
        List<Campaign> campaigns = [
            SELECT Id, Core_MDF_Account__c, Core_MDF_Program__c,Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c 
            FROM Campaign
            WHERE Id = :campaignId
            LIMIT 1
        ];
        return campaigns.isEmpty() ? null : campaigns[0];
    }

    private static List<Account> queryActiveAccounts(Id accountId, String accountName, Campaign campaignContext, Integer rowLimit) {
        if (campaignContext != null && campaignContext.Core_MDF_Account__c != null && String.isNotBlank(campaignContext.Core_MDF_Program__c)) {
            if (accountId != null) {
                return [
                    SELECT Id
                    FROM Account
                    WHERE Id = :accountId
                      AND Core_MDF_Active_Ind__c = true
                      AND Core_MDF_CoMarketing_Ultimate_Account__c =: campaignContext.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c
                      AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c = :campaignContext.Core_MDF_Program__c
                    LIMIT :rowLimit
                ];
            }
            return [
                SELECT Id
                FROM Account
                WHERE Name = :accountName
                  AND Core_MDF_Active_Ind__c = true
                      AND Core_MDF_CoMarketing_Ultimate_Account__c =: campaignContext.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c
                      AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c = :campaignContext.Core_MDF_Program__c
                    LIMIT :rowLimit
            ];
        }

        if (accountId != null) {
            return [SELECT Id FROM Account WHERE Id = :accountId AND Core_MDF_Active_Ind__c = true LIMIT :rowLimit];
        }
        return [SELECT Id FROM Account WHERE Name = :accountName AND Core_MDF_Active_Ind__c = true LIMIT :rowLimit];
    }

    /**
     * Resolves the friendly MemberAcceptorUsername into a User Id with eligibility validation.
     * Verifies that the user is active, has PNUM mapping for the channel partner, and holds
     * the required permission set. When validation fails, enriches error with eligible usernames.
     */
    private static void resolveMemberAcceptorLookup(Map<String, Id> resolvedIds, List<String> errors, String value) {
        if (String.isBlank(value)) {
            return;
        }
        if (!User.SObjectType.getDescribe().isAccessible()) {
            errors.add('Insufficient read access to User records.');
            return;
        }
        String val = value.trim();
        Id userId = parseUserId(val);
        
        // Try to find user by ID or Username
        List<User> users = new List<User>();
        if (userId != null) {
            users = [SELECT Id, Username FROM User WHERE Id = :userId LIMIT 1];
        } else {
            users = [SELECT Id, Username FROM User WHERE Username = :val LIMIT 1];
        }
        
        if (users.isEmpty()) {
            // User not found
            Id accountId = resolvedIds.get('ChannelPartnerId');
            String baseError = Core_MDF_PFR_RestAPI_Constants.formatError(
                Core_MDF_PFR_RestAPI_Constants.ERR_9012_UNRESOLVED_LOOKUP,
                new List<String>{ MEMBER_ACCEPTOR_FIELD, 'member acceptor username', val });
            errors.add(Core_MDF_PFR_RestAPI_Utility.withMemberAcceptorAllowedValues(baseError, accountId));
            return;
        } else if (users.size() > 1) {
            errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(
                Core_MDF_PFR_RestAPI_Constants.ERR_9013_MULTIPLE_MATCHES,
                new List<String>{ MEMBER_ACCEPTOR_FIELD, 'member acceptor username', val }));
            return;
        }
        
        Id accountId = resolvedIds.get('ChannelPartnerId');
        Id foundUserId = users[0].Id;
        
        // Validate user eligibility (active, PNUM mapping, permission set)
        String validationError = Core_MDF_PFR_RestAPI_Utility.validateMemberAcceptorEligibility(foundUserId, accountId);
        if (String.isNotBlank(validationError)) {
            String enrichedError = Core_MDF_PFR_RestAPI_Utility.withMemberAcceptorAllowedValues(validationError, accountId);
            errors.add(enrichedError);
            return;
        }
        
        resolvedIds.put(MEMBER_ACCEPTOR_FIELD, foundUserId);
    }

    /**
     * Resolves the friendly IntelApproverUsername into a User Id with eligibility validation.
     * Verifies that the user is active and has Intel Approver role mapping.
     */
    private static void resolveIntelApproverLookup(Map<String, Id> resolvedIds, List<String> errors, String value) {
        if (String.isBlank(value)) {
            return;
        }
        if (!User.SObjectType.getDescribe().isAccessible()) {
            errors.add('Insufficient read access to User records.');
            return;
        }
        String val = value.trim();
        Id userId = parseUserId(val);
        
        // Try to find user by ID or Username
        List<User> users = new List<User>();
        if (userId != null) {
            users = [SELECT Id, Username FROM User WHERE Id = :userId LIMIT 1];
        } else {
            users = [SELECT Id, Username FROM User WHERE Username = :val LIMIT 1];
        }
        
        if (users.isEmpty()) {
            // User not found - get campaign to fetch eligible Intel approvers
            Id campaignId = resolvedIds.get('CampaignId');
            Campaign campaignRecord = getCampaignForIntelApproverAllowedValues(campaignId);
            
            String baseError = Core_MDF_PFR_RestAPI_Constants.formatError(
                Core_MDF_PFR_RestAPI_Constants.ERR_9012_UNRESOLVED_LOOKUP,
                new List<String>{ 'Core_MDF_Intel_Activity_Owner_Id__c', 'intel approver username', val });
            String enrichedError = withIntelApproverAllowedValues(baseError, campaignRecord);
            errors.add(enrichedError);
            return;
        } else if (users.size() > 1) {
            errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(
                Core_MDF_PFR_RestAPI_Constants.ERR_9013_MULTIPLE_MATCHES,
                new List<String>{ 'Core_MDF_Intel_Activity_Owner_Id__c', 'intel approver username', val }));
            return;
        }
        
        Id foundUserId = users[0].Id;
        
        // Validate Intel Approver eligibility (active, region match with campaign)
        Id campaignId2 = resolvedIds.get('CampaignId');
        Campaign campaignRecord2 = getCampaignForIntelApproverAllowedValues(campaignId2);
        
        String validationError = Core_MDF_PFR_RestAPI_Utility.validateIntelApproverEligibility(foundUserId, campaignRecord2);
        if (String.isNotBlank(validationError)) {
            String enrichedError = withIntelApproverAllowedValues(validationError, campaignRecord2);
            errors.add(enrichedError);
            return;
        }
        
        resolvedIds.put('Core_MDF_Intel_Activity_Owner_Id__c', foundUserId);
    }

    private static Campaign getCampaignForIntelApproverAllowedValues(Id campaignId) {
        if (campaignId == null) {
            return null;
        }

        List<Campaign> campaigns = [
            SELECT Id, Core_MDF_Account__c, Core_MDF_Market__c, Core_MDF_Program__c
            FROM Campaign
            WHERE Id = :campaignId
            LIMIT 1
        ];
        return campaigns.isEmpty() ? null : campaigns[0];
    }

    private static String withIntelApproverAllowedValues(String baseMessage, Campaign campaignRecord) {
        List<Core_MDF_PFR_RestAPI_PicklistValues.UserDetail> userDetails = Core_MDF_PFR_RestAPI_PicklistValues.getIntelApproverUsers(campaignRecord);
        if (userDetails.isEmpty()) {
            return baseMessage;
        }

        List<String> numberedValues = new List<String>();
        for (Integer index = 0; index < userDetails.size(); index++) {
            numberedValues.add((index + 1) + '. ' + JSON.serialize(userDetails[index]));
        }
        return '###FieldName:IntelApproverUsername###' + baseMessage + ' Allowed values:\n' + String.join(numberedValues, '\n');
    }

    /**
     * Resolves one friendly reference value into a record Id. Adds a structured error when the value
     * resolves to zero or to multiple records, otherwise stores the Id under the target lookup field.
     */
    private static void resolveLookup(Map<String, Id> resolvedIds, List<String> errors, String value, String targetField, String objectApiName, String matchField, String label) {
        if (String.isBlank(value)) {
            return;
        }
        String val = value.trim();
        if (objectApiName == 'User') {
            Id userId = parseUserId(val);
            if (userId != null) {
                List<User> usersById = [SELECT Id FROM User WHERE Id = :userId LIMIT 1];
                if (!usersById.isEmpty()) {
                    resolvedIds.put(targetField, usersById[0].Id);
                    return;
                }
            }
        }
        String query = 'SELECT Id FROM ' + objectApiName + ' WHERE ' + matchField + ' = :val';
        if (objectApiName == 'RecordType') {
            query += ' AND SObjectType = \'PartnerFundRequest\'';
        }
        List<SObject> records = Database.query(query);
        if (records.isEmpty()) {
            errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9012_UNRESOLVED_LOOKUP, new List<String>{ targetField, label, val }));
        } else if (records.size() > 1) {
            errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9013_MULTIPLE_MATCHES, new List<String>{ targetField, label, val }));
        } else {
            resolvedIds.put(targetField, records[0].Id);
        }
    }

    private static Id parseUserId(String value) {
        if (String.isBlank(value)) {
            return null;
        }
        try {
            Id parsedId = Id.valueOf(value.trim());
            return parsedId.getSObjectType() == User.SObjectType ? parsedId : null;
        } catch (Exception e) {
            return null;
        }
    }

    private static Id parseCampaignId(String value) {
        return parseSObjectId(value, Campaign.SObjectType);
    }

    private static Id parseAccountId(String value) {
        return parseSObjectId(value, Account.SObjectType);
    }

    private static Id parseSObjectId(String value, Schema.SObjectType sObjectType) {
        if (String.isBlank(value)) {
            return null;
        }
        try {
            Id parsedId = Id.valueOf(value.trim());
            return parsedId.getSObjectType() == sObjectType ? parsedId : null;
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Creates a response failure item for one rejected request record.
     */
    private static Core_MDF_PFR_RestAPI_Response.ErrorContent buildFailure(String title, List<String> errors) {
        Core_MDF_PFR_RestAPI_Response.ErrorContent failure = new Core_MDF_PFR_RestAPI_Response.ErrorContent();
        failure.pfrName = title;
        failure.errors.addAll(errors);
        return failure;
    }

    /**
     * Strongly-typed DTO for the inbound "activity" payload. The external system sends user-friendly
     * field names which are deserialized directly into this wrapper (same approach as the PFC
     * Core_MDF_PFC_APIUtil.ClaimWrapper). toRecord() maps the friendly values directly onto a
     * PartnerFundRequest so the existing validation and DML pipeline continues to work unchanged.
     */
    public class ActivityWrapper {

        // ---- Lookup reference values (resolved into record Ids downstream) ----
        public String Campaign;
        public String AccountName;
        public String BudgetReferenceNumber;
        public String MemberAcceptorUsername;
        public String MemberOwner;
        public String IntelApproverUsername;

        // ---- Direct PartnerFundRequest field values ----
        public String ActivityName;
        public String ActivityDescription;
        public String StartDate;
        public String EndDate;
        public String Priority;
        public String BudgetType;
        public Decimal ActivitySpendingLimitLocal;
        public String ReimbursementRate;
        public String TargetAudience;
        public String Country;
        public String Brand;
        public String ProductType;
        public String ActivityCategory;
        public String ActivityTypes;
        public String EcosystemPartner;
        public String Industry;
        public Decimal ReimbursementAmt;
        public Decimal RequestedAmount;
        public String Currency_x; // "Currency" in JSON; Apex reserved-word-safe alias
        public String DomainType;
        public String EventName;
        public String OtherEventName;
        public String ActivitySubType;
        public String OtherEcosystemPartner;
        public String PartnerContact;
        public String GovernmentInvolvement;
        public String CompetitiveElements;
        public Decimal NumberOfWinners;
        public Decimal NumberOfExpectedParticipants;

        /**
         * Builds the PartnerFundRequest directly from the DTO. Only non-null values are applied, so on
         * update any field not supplied in the payload is left unchanged (identical to the prior
         * behaviour). Typed values (dates) are converted here; an invalid value throws and is surfaced
         * as ERR-9014 by the caller. Lookup Ids are stamped onto the record separately after resolution.
         */
        public PartnerFundRequest toRecord() {
            PartnerFundRequest pfr = new PartnerFundRequest();
            applyValue(pfr, 'Title', ActivityName);
            applyValue(pfr, 'Core_MDF_Activity_Description__c', ActivityDescription);
            applyValue(pfr, 'Core_MDF_Start_Date__c', toDate(StartDate));
            applyValue(pfr, 'Core_MDF_End_Date__c', toDate(EndDate));
            applyValue(pfr, 'Core_MDF_Member_Owner_txt__c', MemberOwner);
            applyValue(pfr, 'Core_MDF_Priorities__c', Priority);
            applyValue(pfr, 'Core_MDF_Budget_Type_nm__c', BudgetType);
            applyValue(pfr, 'Core_MDF_Budget_Amount_Local_amt__c', ActivitySpendingLimitLocal);
            applyValue(pfr, 'Core_MDF_Reimbursement_Rate_txt__c', ReimbursementRate);
            applyValue(pfr, 'Core_MDF_TargetAudience__c', TargetAudience);
            applyValue(pfr, 'Core_MDF_Country_nm__c', Country);
            applyValue(pfr, 'Core_MDF_Brand_nm__c', Brand);
            applyValue(pfr, 'Core_MDF_ProductType__c', ProductType);
            applyValue(pfr, 'Core_MDF_ActivityCategory__c', ActivityCategory);
            applyValue(pfr, 'Core_MDF_Activity_Types__c', ActivityTypes);
            applyValue(pfr, 'Core_MDF_Channel_Partner__c', EcosystemPartner);
            applyValue(pfr, 'Core_MDF_Channel_Partner_Led__c', true);
            applyValue(pfr, 'Core_MDF_Industry_Multi_nm__c', Industry);
            applyValue(pfr, 'Core_MDF_MDFReimbursement_Amt__c', ReimbursementAmt);
            applyValue(pfr, 'Core_MDF_Budget_Currency_cd__c', Currency_x);
            applyValue(pfr, 'Core_MDF_Domain_Type_nm__c', DomainType);
            applyValue(pfr, 'Core_MDF_Event_Name_nm__c', EventName);
            applyValue(pfr, 'Core_MDF_Other_Event_Name_txt__c', OtherEventName);
            applyValue(pfr, 'Core_MDF_Activity_SubType_nm__c', ActivitySubType);
            applyValue(pfr, 'Core_MDF_Other_Channel_Partner__c', OtherEcosystemPartner);
            applyValue(pfr, 'Core_MDF_Partner_Contact_txt__c', PartnerContact);
            applyValue(pfr, 'Core_MDF_Government_Nexus__c', String.isBlank(GovernmentInvolvement) ? 'No' : GovernmentInvolvement);
            applyValue(pfr, 'Core_MDF_Competitive_Elements__c', String.isBlank(CompetitiveElements) ? 'No' : CompetitiveElements);
            applyValue(pfr, 'Core_MDF_Num_of_Potential_Winners_nbr__c', NumberOfWinners);
            applyValue(pfr, 'Core_MDF_No_of_Expected_Participants_nbr__c', NumberOfExpectedParticipants);
            
            return pfr;
        }

        /**
         * Applies a value to the record only when it is not null, leaving unspecified fields unchanged.
         */
        private void applyValue(PartnerFundRequest pfr, String field, Object value) {
            if (value != null) {
                pfr.put(field, value);
            }
        }

        /**
         * Converts an ISO date string ("yyyy-MM-dd") to a Date using the same parsing as JSON
         * deserialization, so an invalid value throws (reported as ERR-9014). Returns null when blank.
         */
        private Date toDate(String value) {
            return String.isBlank(value) ? null : (Date) JSON.deserialize('"' + value + '"', Date.class);
        }
    }

    /**
     * Inline file upload supplied in the activity payload's "Files" node. "file" holds the base64-encoded
     * file body and "comment" is optional. Files are attached best-effort after the activity is created
     * and never block activity creation.
     */
    public class FileUpload {
        public String FileName;
        public String file;
        public String comment;
    }

    // ===== SEGMENT INPUT DETAIL WRAPPER - APPENDED =====
    /**
     * Wrapper for individual segment details in SPIF multi-segment request
     * Supports multiple products per segment with full validation and field mapping
     * 
     * Field Mappings:
     * - segmentName → Core_MDF_Segment_Name_nm__c (Activity_Segment_Mapping)
     * - minimumForecastVolume → Core_MDF_Minimum_Forecast_Volume_nbr__c
     * - incentiveAmountPerUnit → Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c
     * - productIds → Core_MDF_Segment_Product_Mapping__c.Core_MDF_Product_id__c
     */
    public class SegmentInputDetail {
        public String segmentName { get; set; }
        public Decimal minimumForecastVolume { get; set; }
        public Decimal incentiveAmountPerUnit { get; set; }
        public Decimal maximumBundledVolume { get; set; }
        public Decimal maximumCostOfBundle { get; set; }
        public List<String> productIds { get; set; }
        
        public SegmentInputDetail() {
            this.productIds = new List<String>();
        }
        
        /**
         * Get segment details as map for external consumption
         * @return Map representation of segment
         */
        public Map<String, Object> toMap() {
            Map<String, Object> segMap = new Map<String, Object>();
            segMap.put('SegmentName', this.segmentName);
            segMap.put('MinimumForecastVolume', this.minimumForecastVolume);
            segMap.put('IncentiveAmountPerUnit', this.incentiveAmountPerUnit);
            segMap.put('MaximumBundledVolume', this.maximumBundledVolume);
            segMap.put('MaximumCostOfBundle', this.maximumCostOfBundle);
            segMap.put('ProductIds', this.productIds);
            return segMap;
        }
    }
    
    /**
     * Parse individual segment from map with field mapping
     * @param segMap - Segment data map
     * @param index - Segment index
     * @param errors - Error collection
     * @return SegmentInputDetail or null if parse error
     */
    private static SegmentInputDetail parseSegmentDetail(Map<String, Object> segMap, Integer index, List<String> errors) {
        try {
            SegmentInputDetail segment = new SegmentInputDetail();
            
            // Parse segment name
            segment.segmentName = stringFromMap(segMap, 'SegmentName');
            if (String.isBlank(segment.segmentName)) {
                errors.add('Segment ' + index + ': Segment name is required');
                return null;
            }
            
            Boolean hasBundleValues = isEnteredValue(segMap.get('MaximumBundledVolume')) || isEnteredValue(segMap.get('MaximumCostOfBundle'));
            if (hasBundleValues) {
                if (isEnteredValue(segMap.get('MinimumForecastVolume')) || isEnteredValue(segMap.get('IncentiveAmountPerUnit'))) {
                    errors.add('Segment ' + index + ': Provide either bundle values or forecast/incentive values, not both.');
                    return null;
                }
                segment.maximumBundledVolume = convertToDecimal(segMap.get('MaximumBundledVolume'));
                segment.maximumCostOfBundle = convertToDecimal(segMap.get('MaximumCostOfBundle'));
                if (segment.maximumBundledVolume == null || segment.maximumBundledVolume <= 0
                    || segment.maximumCostOfBundle == null || segment.maximumCostOfBundle <= 0) {
                    errors.add('Segment ' + index + ': MaximumBundledVolume and MaximumCostOfBundle must both be valid numbers greater than zero.');
                    return null;
                }
            } else {
	            // Parse minimum forecast volume
	            Object forecastObj = segMap.get('MinimumForecastVolume');
	            segment.minimumForecastVolume = convertToDecimal(forecastObj);
	            if (segment.minimumForecastVolume == null) {
	                errors.add('Segment ' + index + ': ' + Core_MDF_PFR_RestAPI_Constants.MISSING_SEGMENT_FORECAST);
	                return null;
	            }
	            if (segment.minimumForecastVolume <= 0) {
	                errors.add('Segment ' + index + ': ' + Core_MDF_PFR_RestAPI_Constants.INVALID_SEGMENT_FORECAST);
	                return null;
	            }
            
	            // Parse incentive amount
	            Object incentiveObj = segMap.get('IncentiveAmountPerUnit');
	            segment.incentiveAmountPerUnit = convertToDecimal(incentiveObj);
	            if (segment.incentiveAmountPerUnit == null) {
	                errors.add('Segment ' + index + ': ' + Core_MDF_PFR_RestAPI_Constants.MISSING_SEGMENT_INCENTIVE);
	                return null;
	            }
	            if (segment.incentiveAmountPerUnit <= 0) {
	                errors.add('Segment ' + index + ': ' + Core_MDF_PFR_RestAPI_Constants.INVALID_SEGMENT_INCENTIVE);
	                return null;
	            }
            }
            
            // Parse product IDs
            Object prodIdsObj = segMap.get('ProductIds');
            if (prodIdsObj instanceof List<Object>) {
                List<Object> prodList = (List<Object>) prodIdsObj;
                Set<String> seenProducts = new Set<String>();
                
                if (prodList.isEmpty()) {
                    errors.add('Segment ' + index + ': At least one product ID is required');
                    return null;
                }
                
                for (Integer j = 0; j < prodList.size(); j++) {
                    String prodIdStr = prodList.get(j) == null ? null : String.valueOf(prodList.get(j)).trim();
                    
                    if (String.isBlank(prodIdStr)) {
                        errors.add('Segment ' + index + ': Product ID at position ' + j + ' is blank');
                        continue;
                    }
                    
                    // Check for duplicate products in segment
                    if (seenProducts.contains(prodIdStr)) {
                        errors.add('Segment ' + index + ': Duplicate product ID - ' + prodIdStr);
                        continue;
                    }
                    
                    seenProducts.add(prodIdStr);
                    segment.productIds.add(prodIdStr);
                }
                
                if (segment.productIds.isEmpty()) {
                    errors.add('Segment ' + index + ': No valid product IDs found');
                    return null;
                }
            } else if (prodIdsObj != null) {
                errors.add('Segment ' + index + ': ProductIds must be an array');
                return null;
            } else {
                errors.add('Segment ' + index + ': ProductIds array is required');
                return null;
            }
            
            return segment;
            
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            errors.add('Segment ' + index + ': Error parsing - ' + e.getMessage());
            return null;
        }
    }
    
    /**
     * Convert Object to Decimal safely
     * @param value - Value to convert
     * @return Decimal or null
     */
    private static Decimal convertToDecimal(Object value) {
        if (value == null) {
            return null;
        }
        try {
            if (value instanceof Decimal) {
                return (Decimal) value;
            }
            if (value instanceof Integer) {
                return Decimal.valueOf((Integer) value);
            }
            if (value instanceof Double) {
                return Decimal.valueOf((Double) value);
            }
            if (value instanceof String) {
                String strVal = ((String) value).trim();
                if (String.isNotBlank(strVal)) {
                    return Decimal.valueOf(strVal);
                }
            }
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            return null;
        }
        return null;
    }
}