public without sharing class Core_MDF_AccountSearchController {

    @AuraEnabled
    public static AccountWrapper searchAccounts(Id accountId) {
		Map<String,String> prgmAbbNameMap = new Map<String,String>();
        if (accountId == null) {
            return null;
        }

        try {
            Account acc = [
                SELECT Id, Name, BillingCountry, BillingState, BillingPostalCode,Core_Unified_Global_Customer_BP_Id__c, Core_MDF_CoMarketingActive__c,Core_MDF_CoMarketingAgency__c,Core_Intel_Partner_Alliance_PartnerGroup__c FROM Account WHERE Id = :accountId LIMIT 1];
            for(Core_MDF_ChannelProgram__mdt cpm : [SELECT Core_MDF_Abbreviated_ProgramName_txt__c, Core_MDF_Technical_Program_Name__c
                                                    FROM Core_MDF_ChannelProgram__mdt WHERE Core_MDF_Technical_Program_Name__c != 'All Campaign Fields'])
            {
                prgmAbbNameMap.put(cpm.Core_MDF_Technical_Program_Name__c,cpm.Core_MDF_Abbreviated_ProgramName_txt__c);
            }
            Set<String> programNames = new Set<String>();
			Map<String, String> pgmNameToVCMap = new Map<String, String>();
            for (Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Core_MDF_Account__r.Name,Core_MDF_Works_For__c, Core_MDF_Works_For__r.Name, Core_MDF_Virtual_Corp_nm__r.Name, Core_MDF_Channel_Program__r.Name, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c FROM Core_MDF_Partner_Group_Mapping__c WHERE Core_MDF_Account__c = :accountId AND Core_MDF_Inactive_Ind__c = FALSE AND Core_MDF_Type_of_Access__c = 'External' ORDER BY Core_MDF_Channel_Program__r.Name]) {
                if (pgm.Core_MDF_Channel_Program__r != null) {
                    programNames.add(pgm.Core_MDF_Channel_Program__r.Name);                    
                }
                String abbreviatedCode = prgmAbbNameMap.get(pgm.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c);
                String vcName = pgm.Core_MDF_Virtual_Corp_nm__c != null ? pgm.Core_MDF_Virtual_Corp_nm__r.Name : pgm.Core_MDF_Works_For__c != null ? abbreviatedCode + '-' + pgm.Core_MDF_Works_For__r.Name : abbreviatedCode + '-' + pgm.Core_MDF_Account__r.Name;
                pgmNameToVCMap.put(pgm.Core_MDF_Channel_Program__r.Name,vcName); 
            }            
            String programs = programNames.isEmpty()? null: String.join(new List<String>(programNames), ', ');
                        
            // Program Map from Label
            Map<String, String> programToRT = getProgramToRecordTypeMap();
			system.debug('programToRT::'+programToRT);
            
            /*List<String> programList = new List<String>(programToRT.keySet());
            programList.sort();*/
            // All programs configured in label
            Set<String> configuredPrograms = programToRT.keySet();
            
            // User accessible programs
            Set<String> accessiblePrograms = new Set<String>();
            
            for (ChannelProgram cp : [SELECT id, Name FROM ChannelProgram WHERE Core_MDF_Technical_Program_Name__c != null WITH USER_MODE LIMIT 50]) {
                if (configuredPrograms.contains(cp.Name)) {
                    accessiblePrograms.add(cp.Name);
                }
            }
            
            List<String> programList = new List<String>(accessiblePrograms);
            programList.sort();
            
            return new AccountWrapper(acc,programs,programList,pgmNameToVCMap);

        }catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);return null;}
    }

    // Get RecordTypeId based on Program
    @AuraEnabled(cacheable=true)
    public static Id getRecordTypeIdByProgram(String programName) {

        if (String.isBlank(programName)){ return null;}

        Map<String, String> programToRT = getProgramToRecordTypeMap();

        if (!programToRT.containsKey(programName)){ return null;}

        String devName = programToRT.get(programName);

        Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Core_MDF_Account_Onboarding__c.getRecordTypeInfosByDeveloperName();

        if (rtMap.containsKey(devName)) {
            return rtMap.get(devName).getRecordTypeId();
        }

        return null;
    }

    // Parse Label → Map
    private static Map<String, String> getProgramToRecordTypeMap() {

        Map<String, String> result = new Map<String, String>();

        String labelVal = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ProgToAccOnboardingRecType');

        if (String.isBlank(labelVal)){ return result;}

        for (String pair : labelVal.split(',')) {
            List<String> parts = pair.split('=');
            if (parts.size() == 2) {
                result.put(parts[0].trim(), parts[1].trim());
            }
        }

        return result;
    }

    // WRAPPER
    public class AccountWrapper {
        @AuraEnabled public Id Id;
        @AuraEnabled public String name;
        @AuraEnabled public String billingCountry;
        @AuraEnabled public String billingState;
        @AuraEnabled public String billingPostalCode;
        @AuraEnabled public String unifiedBPId;
        @AuraEnabled public Boolean comarketingActive;
        @AuraEnabled public Boolean comarketingAgency;
        @AuraEnabled public Boolean ipaAccount;
        @AuraEnabled public String onboardedPrograms;
        @AuraEnabled public List<String> programOptions;
        @AuraEnabled public Map<String,String> pgmNameToVCMap;

        public AccountWrapper(Account acc, String programs, List<String> programOptions, Map<String,String> pgmNameToVCMap) {
            if (acc == null) return;

            this.Id = acc.Id;
            this.name = acc.Name;
            this.billingCountry = acc.BillingCountry;
            this.billingState = acc.BillingState;
            this.billingPostalCode = acc.BillingPostalCode;
            this.unifiedBPId = acc.Core_Unified_Global_Customer_BP_Id__c;
            this.comarketingActive = acc.Core_MDF_CoMarketingActive__c;
            this.comarketingAgency = acc.Core_MDF_CoMarketingAgency__c;
            this.ipaAccount = acc.Core_Intel_Partner_Alliance_PartnerGroup__c;
            this.onboardedPrograms = programs;
            this.programOptions = programOptions;
            this.pgmNameToVCMap = pgmNameToVCMap;
        }
    }
}