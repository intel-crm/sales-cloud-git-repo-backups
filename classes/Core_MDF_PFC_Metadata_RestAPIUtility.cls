/* ----------------------------------------------------------------------------------
 * Class Name      : Core_MDF_PFC_Metadata_RestAPIUtility
 * Description     : Resolves PartnerFundClaim context from an activity ID, activity number, escalation ID, or program name.
 * ---------------------------------------------------------------------------------- */
public without sharing class Core_MDF_PFC_Metadata_RestAPIUtility {

    public static final String CLAIM_TYPE_LATE_CLAIM = 'Late Claim';
    public static final String CLAIM_TYPE_NORMAL = 'Normal';
    public static final String PARTNER_FUND_CLAIM_OBJECT_API_NAME = 'PartnerFundClaim';
    public static final String CONFIG_USER_TYPE = 'External User';
    public static final String FIELD_VIEW_API_CREATE = 'API Create';
    public static final String FIELD_VIEW_API_UPDATE = 'API Update';
    public static final String FIELD_CLAIM_SUBMITTER = 'Core_MDF_Claim_Submitter_Id__c';
    public static final String FIELD_BANK_LOOKUP     = 'Core_MDF_Bank__c';
    public static final String FIELD_CLAIM_COUNTRY   = 'Core_MDF_Country_Location_nm__c';
    public static final Map<String, Schema.SObjectField> PARTNER_FUND_CLAIM_FIELDS = PartnerFundClaim.SObjectType.getDescribe().fields.getMap();
    private static final Map<String, List<LabelValue>> PICKLIST_VALUE_CACHE = new Map<String, List<LabelValue>>();
    private static final Map<String, Schema.DescribeFieldResult> FIELD_DESCRIBE_CACHE = new Map<String, Schema.DescribeFieldResult>();
    private static final Integer ID_LEN_15 = 15;
    private static final Integer ID_LEN_18 = 18;
    private static final String ACTIVITY_ID_PREFIX = '0RJ';
    private static final String ESCALATION_ID_PREFIX = 'a4S';
    private static final String ID_PATTERN = '^[a-zA-Z0-9]+$';
    private static Set<String> bankStatusSet;
    public static final String ERROR_CODE_CATEGORY = 'Claim Metadata';
    public static final String SUCCESS_MESSAGE = 'Claim metadata retrieved successfully.';
    public static final String ERROR_MESSAGE   = 'Unable to retrieve claim metadata.';
    public static final String SUCCESS_CODE              = '200';
    public static final String ERROR_CODE_NO_PARAMS      = '6001';
    public static final String ERROR_CODE_INVALID_PROG   = '6002';
	public static final String ERROR_CODE_NO_ACTIVITY    = '6003';
    public static final String ERROR_CODE_NO_ESCALATION  = '6004';
    public static final String ERROR_CODE_ACTIVITY_NF    = '6005';
    public static final String ERROR_CODE_ESCALATION_NF  = '6006';
    public static final String ERROR_CODE_APP_ERROR      = '6007';
    public static final String ERROR_CODE_INVALID_CLAIM_TYPE ='6008';
    public static final String ERROR_CODE_INVALID_CLAIM_ID = '6009';
    public static final String ERROR_CODE_CLAIM_NOT_EDITABLE = '6010';
    public static final String PARAM_ACTIVITY_ID_OR_NUMBER = 'activityIdOrNumber';
    public static final String PARAM_CLAIM_TYPE = 'claimType';
    public static final String PARAM_ESCALATION_ID = 'escalationId';
    public static final String PARAM_PROGRAM_NAME = 'programName';
    public static final String PARAM_CLAIM_ID = 'claimId';
    public static final String PARAM_CLAIM_STATUS = 'claimStatus';
    public static final String PARAM_ACTION = 'action';
    public static final String ACTION_CREATE = 'create';
    public static final String ACTION_UPDATE = 'update';
    public static final String FIELD_ACTIVITY_REQUEST_LOOKUP = 'RequestId';
    public static final String FIELD_ESCALATION_ID = 'Core_MDF_Escalation_Id__c';
    public static final String FIELD_DOCUMENTS = 'documents';
    public static final Set<String> VALID_PARAMS = new Set<String>{PARAM_ACTION, PARAM_CLAIM_TYPE, PARAM_ACTIVITY_ID_OR_NUMBER, PARAM_ESCALATION_ID, PARAM_PROGRAM_NAME, PARAM_CLAIM_ID, PARAM_CLAIM_STATUS};
    public static final Map<Schema.DisplayType, String> FLD_TYPE_MAP = new Map<Schema.DisplayType, String>{
        Schema.DisplayType.REFERENCE => 'Lookup',
        Schema.DisplayType.PICKLIST => 'Picklist',
        Schema.DisplayType.MULTIPICKLIST => 'Picklist',
        Schema.DisplayType.DATE => 'Date',
        Schema.DisplayType.DATETIME => 'Date',
        Schema.DisplayType.CURRENCY => 'Decimal',
        Schema.DisplayType.DOUBLE => 'Decimal',
        Schema.DisplayType.INTEGER => 'Decimal',
        Schema.DisplayType.LONG => 'Decimal',
        Schema.DisplayType.PERCENT => 'Decimal',
        Schema.DisplayType.BOOLEAN => 'Boolean'
    };    
    
    /** Generic label/value pair used for picklists, submitters, banks, and countries. */
    public class LabelValue {
        public String label;
        public String value;
        public LabelValue(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    /** Input parameters for context resolution. Add new fields here for future extension. */
    public class ResolveParams {
        public String clmType;
        public String actId;
        public String actNum;
        public String escId;
        public String progNm;
        public String action;
    }

    /** Resolved context for a PartnerFundClaim activity, escalation, or program. */
    public class ActivityContext {
        public String  clmType;
        public String  actId;
        public String  actNum;
        public Boolean actIdInput = false;
        public String  escId;
        public String  budgetType;
        public String  progTechNm;
        public String  progNm;
        public Boolean progEligible = true;
        public Boolean recFound = false;
        public String  resolutionError;
        public List<LabelValue> clmSubmitters = new List<LabelValue>();
        public List<LabelValue> bankSupNum = new List<LabelValue>();
        public List<LabelValue> clmCountry = new List<LabelValue>();
    }

    /**************************************************************
* Method Name: resolve
* Parameters: ResolveParams params
* Description: Resolves an ActivityContext from the supplied params. Returns recFound=true only if the requested records were found.
				Sets resolutionError if a specific record type was not found.
**************************************************************/
    public static ActivityContext resolve(ResolveParams params) {
        ActivityContext ctx = new ActivityContext();
        if (params == null) { return ctx; }
        try {
            if ((String.isBlank(params.clmType) && String.isNotBlank(params.escId)) || CLAIM_TYPE_LATE_CLAIM.equalsIgnoreCase(params.clmType)) {
                if(!isValidId(params.escId,CLAIM_TYPE_LATE_CLAIM)){
                    ctx.resolutionError = 'ESCALATION_NOT_FOUND';
                    return ctx;
                }
                ctx.escId = params.escId;
                Id escId = Id.valueOf(params.escId);
                List<Core_MDF_Escalation__c> results = [SELECT Core_MDF_Co_Marketing_Activity_id__c, Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Activity_Number__c, Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Country_nm__c, Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Budget_Type_nm__c, Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId, Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_Channel_Program__r.Name,Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Program__c FROM Core_MDF_Escalation__c WHERE Id = :escId LIMIT 1];
                if (results.isEmpty()) {
                    ctx.resolutionError = 'ESCALATION_NOT_FOUND';
                    return ctx;
                }
                ctx.recFound = true;
                Core_MDF_Escalation__c esc = results[0];
                if (esc.Core_MDF_Co_Marketing_Activity_id__c != null) {
                    populateFromActivity(ctx, esc.Core_MDF_Co_Marketing_Activity_id__r);
                }
            } else if ((String.isBlank(params.clmType) && (String.isNotBlank(params.actNum) || String.isNotBlank(params.actId)))|| CLAIM_TYPE_NORMAL.equalsIgnoreCase(params.clmType)) {
                ctx.actIdInput = String.isNotBlank(params.actId);
                List<PartnerFundRequest> results;
                if (String.isNotBlank(params.actNum)) {
                    results = [SELECT Id, Core_MDF_Budget_Type_nm__c, Core_MDF_Activity_Number__c, Core_MDF_Country_nm__c, ChannelPartnerId, ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,ChannelPartner.Core_MDF_Channel_Program__r.Name,Core_MDF_Program__c FROM PartnerFundRequest WHERE Core_MDF_Activity_Number__c = :params.actNum LIMIT 1];
                } else {
                    if(!isValidId(params.actId,CLAIM_TYPE_NORMAL)) {
                    	ctx.resolutionError = 'ACTIVITY_NOT_FOUND';
                    	return ctx;
                	}
                    Id pfrId = Id.valueOf(params.actId);
                    results = [SELECT Id, Core_MDF_Budget_Type_nm__c, Core_MDF_Activity_Number__c, Core_MDF_Country_nm__c, ChannelPartnerId, ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,ChannelPartner.Core_MDF_Channel_Program__r.Name,Core_MDF_Program__c FROM PartnerFundRequest WHERE Id = :pfrId LIMIT 1];
                }
                if (results.isEmpty()) {
                    ctx.resolutionError = 'ACTIVITY_NOT_FOUND';
                    return ctx;
                }
                ctx.recFound = true;
                populateFromActivity(ctx, results[0]);
            } else {
                populateFromProgNm(ctx, params.progNm, params.action);
                if (ctx.progEligible) { ctx.recFound = true; }
            }
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        return ctx;
    }
    /**************************************************************
* Method Name: isValidId
* Parameters: String recordId, String clmType
* Description: Returns true if recordId is a valid Salesforce ID (15/18 chars, alphanumeric) whose 3-char prefix matches the expected claim type.
**************************************************************/
    private static Boolean isValidId(String recordId, String clmType) {
        if (String.isBlank(recordId)) { return false; }
        String n = recordId.trim();
        Integer len = n.length();
        if ((len != ID_LEN_15 && len != ID_LEN_18) || !Pattern.matches(ID_PATTERN, n)) { 
            return false; 
        }
        try {
            String prefix = String.valueOf(Id.valueOf(n)).substring(0, 3);
            return (clmType == CLAIM_TYPE_LATE_CLAIM && prefix == ESCALATION_ID_PREFIX) || (clmType == CLAIM_TYPE_NORMAL && prefix == ACTIVITY_ID_PREFIX);
        } catch (Exception ex) { 
            return false; 
        }
    }
    /**************************************************************
* Method Name: populateFromActivity
* Parameters: ActivityContext ctx, PartnerFundRequest pfr
* Description: Populates ctx from a PartnerFundRequest record: activity fields, bank, country, and submitters.
**************************************************************/
    private static void populateFromActivity(ActivityContext ctx, PartnerFundRequest pfr) {
        if (pfr == null) { 
            return; 
        }
        ctx.actId = String.valueOf(pfr.Id);
        ctx.actNum = pfr.Core_MDF_Activity_Number__c;
        ctx.budgetType = pfr.Core_MDF_Budget_Type_nm__c;
        ctx.clmCountry = buildActivityCountries(pfr.Core_MDF_Country_nm__c);
        ctx.bankSupNum = buildBankSupNum(pfr.ChannelPartnerId);
        if (pfr.ChannelPartner != null && pfr.ChannelPartner.Core_MDF_Channel_Program__r != null) {
            ctx.progTechNm = pfr.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c;
            ctx.progNm = pfr.ChannelPartner.Core_MDF_Channel_Program__r.Name;
        }
        ctx.progNm = pfr.Core_MDF_Program__c;
        Id ultimateAccId = pfr.ChannelPartner != null ? pfr.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c : null;
        ctx.clmSubmitters = buildClmSubmitterVal(ultimateAccId, ctx.progTechNm);
    }

/**************************************************************
* Method Name: populateFromProgNm
* Parameters: ActivityContext ctx, String progNm, String action
* Description: Program is eligible only when claim field configuration (Core_MDF_Custom_Layout_Configurations__c) exists for it.
**************************************************************/
    private static void populateFromProgNm(ActivityContext ctx, String progNm, String action) {
        ctx.progEligible = false;
        if (String.isBlank(progNm)) { 
            return; 
        }
        String fieldView = resolveFieldViewForAction(action);
        if (String.isBlank(fieldView)) {
            return;
        }
        List<Core_MDF_Custom_Layout_Configurations__c> configs = [SELECT Id FROM Core_MDF_Custom_Layout_Configurations__c WHERE Core_MDF_Object_API_Name_txt__c = :PARTNER_FUND_CLAIM_OBJECT_API_NAME
              AND Core_MDF_User_Type_nm__c = :CONFIG_USER_TYPE AND Core_MDF_Record_Type_Name_txt__c = :progNm AND API_Visibility__c = true AND Core_MDF_Section_id__r.Core_MDF_Field_View_nm__c = :fieldView WITH SYSTEM_MODE LIMIT 1];
        if (configs.isEmpty()) { 
            return; 
        }
        ctx.progEligible = true;
		ctx.progTechNm = progNm;
        ctx.progNm = progNm;
    }
    
    private static String resolveFieldViewForAction(String action) {
        if (ACTION_CREATE.equalsIgnoreCase(action)) {
            return FIELD_VIEW_API_CREATE;
        }
        if (ACTION_UPDATE.equalsIgnoreCase(action)) {
            return FIELD_VIEW_API_UPDATE;
        }
        return null;
    }

    public static List<LabelValue> buildActivityCountries(String actCountryVal) {
        List<LabelValue> countries = new List<LabelValue>();
        if (String.isBlank(actCountryVal)) { 
            return countries; 
        }
        Map<String, String> countryMap = new Map<String, String>();
        for (LabelValue item : getStaticLabelValues(FIELD_CLAIM_COUNTRY)) {
            if (item != null && String.isNotBlank(item.value)) {
                countryMap.put(item.value, item.label);
            }
        }
        Set<String> seen = new Set<String>();
        for (String apiValue : actCountryVal.split(';')) {
            String country = String.isBlank(apiValue) ? null : apiValue.trim();
            if (String.isBlank(country) || seen.contains(country.toLowerCase())) { 
                continue; 
            }
            seen.add(country.toLowerCase());
            String label = countryMap.containsKey(country) ? countryMap.get(country) : country;
            countries.add(new LabelValue(label, country));
        }
        return countries;
    }

/**************************************************************
* Method Name: buildClmSubmitterVal
* Parameters: Id ultimateAccId, String techProgNm
* Description: Calls Core_MDF_PartnerFundClaim.fetchClaimSubmitters to resolve eligible submitter users.
**************************************************************/
    public static List<LabelValue> buildClmSubmitterVal(Id ultimateAccId, String techProgNm) {
        List<LabelValue> values = new List<LabelValue>();
        if (ultimateAccId == null || String.isBlank(techProgNm)) { 
            return values; 
        }
        try {
            List<Id> submitterIds = Core_MDF_PartnerFundClaim.fetchClaimSubmitters(ultimateAccId, techProgNm);
            if (submitterIds == null || submitterIds.isEmpty()) { 
                return values; 
            }
            for (User u : [SELECT Id, Name FROM User WHERE Id IN :submitterIds ORDER BY Name]) {
                values.add(new LabelValue(String.isNotBlank(u.Name) ? u.Name : String.valueOf(u.Id), String.valueOf(u.Id)));
            }
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        return values;
    }

/**************************************************************
* Method Name: buildBankSupNum
* Parameters: Id accountId
* Description: Returns active bank records associated with the given account.
**************************************************************/
    public static List<LabelValue> buildBankSupNum(Id accountId) {
        List<LabelValue> values = new List<LabelValue>();
        if (accountId == null) { 
            return values; 
        }
        try {
            if (bankStatusSet == null) {
                bankStatusSet = new Set<String>();
                String bankStatus = System.Label.Core_MDF_Claim_Bank_StatusList;
                if (!String.isBlank(bankStatus)) {
                    for (String s : bankStatus.split(';')) { 
                        if (String.isNotBlank(s)) { 
                            bankStatusSet.add(s.trim()); 
                        } 
                    }
                }
            }
            List<Core_MDF_Account_Bank_Mapping__c> mappings = [SELECT Core_MDF_Bank__c, Core_MDF_Bank__r.Name, Core_MDF_Bank__r.Core_MDF_Supplier_Number__c FROM Core_MDF_Account_Bank_Mapping__c WHERE Core_MDF_Account__c = :accountId AND Core_MDF_Active_ind__c = true AND Core_MDF_Bank__r.Core_MDF_Bank_Status__c IN :bankStatusSet];
            Map<Id, LabelValue> banksById = new Map<Id, LabelValue>();
            for (Core_MDF_Account_Bank_Mapping__c row : mappings) {
                if (row.Core_MDF_Bank__c == null || String.isBlank(row.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c)) {
                    continue; 
                }
                String supplierNumber = row.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c.trim();
                String bankLabel = String.isNotBlank(row.Core_MDF_Bank__r.Name) ? row.Core_MDF_Bank__r.Name.trim() : supplierNumber;
                if (!banksById.containsKey(row.Core_MDF_Bank__c)) {
                    banksById.put(row.Core_MDF_Bank__c, new LabelValue(bankLabel, supplierNumber));
                }
            }
            List<Id> bankIds = new List<Id>(banksById.keySet());
            bankIds.sort();
            for (Id bankId : bankIds) {
                values.add(banksById.get(bankId));
            }
        } catch (Exception ex) { 
            Core_MDF_CCP_UtilityClass.logError(ex); 
        }
        return values;
    }

    public static List<LabelValue> getStaticLabelValues(String fieldAPIName) {
        if (String.isBlank(fieldAPIName)) { 
            return new List<LabelValue>(); 
        }
        if (PICKLIST_VALUE_CACHE.containsKey(fieldAPIName)) { 
            return copyLabelValues(PICKLIST_VALUE_CACHE.get(fieldAPIName)); 
        }
        List<LabelValue> values = new List<LabelValue>();
        try {
            if (PARTNER_FUND_CLAIM_FIELDS.containsKey(fieldAPIName)) {
                Schema.DescribeFieldResult fd = getFieldDescribe(fieldAPIName);
                if (fd.getType() == Schema.DisplayType.PICKLIST || fd.getType() == Schema.DisplayType.MULTIPICKLIST) {
                    for (Schema.PicklistEntry entry : fd.getPicklistValues()) { 
                        values.add(new LabelValue(entry.getLabel(), entry.getValue())); 
                    }
                }
            }
        } catch (Exception ex) { 
            Core_MDF_CCP_UtilityClass.logError(ex); 
        }
        PICKLIST_VALUE_CACHE.put(fieldAPIName, copyLabelValues(values));
        return values;
    }

    private static Schema.DescribeFieldResult getFieldDescribe(String fieldAPIName) {
        if (FIELD_DESCRIBE_CACHE.containsKey(fieldAPIName)) {
            return FIELD_DESCRIBE_CACHE.get(fieldAPIName);
        }
        Schema.DescribeFieldResult fieldDescribe = PARTNER_FUND_CLAIM_FIELDS.get(fieldAPIName).getDescribe();
        FIELD_DESCRIBE_CACHE.put(fieldAPIName, fieldDescribe);
        return fieldDescribe;
    }

    private static List<LabelValue> copyLabelValues(List<LabelValue> src) {
        List<LabelValue> lstVal = new List<LabelValue>();
        if (src != null) { 
            for (LabelValue lv : src) { 
                if (lv != null) { 
                    lstVal.add(new LabelValue(lv.label, lv.value)); 
                } 
            } 
        }
        return lstVal;
    }
}