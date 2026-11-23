public class Core_MDF_IUPGMReqStaging_ServiceHandler {

    public static void processRequests(List<Core_MDF_IUPGM_Request_Staging__c> records){

        System.debug('SERVICE HANDLER START');

        if(records == null || records.isEmpty()) return;

        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> toInsert =
            new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();

        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> toUpdate =
            new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();

        // Collect Users
        Set<Id> userIds = new Set<Id>();

        for(Core_MDF_IUPGM_Request_Staging__c rec : records){
            if(rec.Core_MDF_IUPGM_User_txt__c != null){
                userIds.add(rec.Core_MDF_IUPGM_User_txt__c);
            }
        }

        // Fetch Existing IUPGM
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> existingList = [
            SELECT Id,
                   Core_MDF_User_id__c,
                   Core_MDF_Role_nm__c,
                   Core_MDF_Program_nm__c,
                   Core_MDF_Account_id__c,
                   Core_MDF_All_Accounts_cd__c,
                   Core_MDF_Region_Sub_Region_nm__c,
                   Core_MDF_Budget_Type_nm__c,
                   Core_MDF_All_Budget_Type_Access_Ind__c,
                   Core_MDF_Active_Ind__c
            FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
            WHERE Core_MDF_User_id__c IN :userIds
        ];

        Map<String, List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>> existingMap =
            new Map<String, List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>>();

        for(Core_MDF_Int_Users_Partner_Geo_Mapping__c ex : existingList){

            String key = buildKey(
                ex.Core_MDF_User_id__c,
                ex.Core_MDF_Role_nm__c,
                ex.Core_MDF_Program_nm__c,
                ex.Core_MDF_Account_id__c
            );

            if(!existingMap.containsKey(key)){
                existingMap.put(key, new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>());
            }

            existingMap.get(key).add(ex);
        }

        // =============================
        // PROCESS EACH RECORD
        // =============================

        for(Core_MDF_IUPGM_Request_Staging__c rec : records){

            System.debug('Processing Record: ' + rec.Id);

            String key = buildKey(
                rec.Core_MDF_IUPGM_User_txt__c,
                rec.Core_MDF_IUPGM_Role_nm__c,
                rec.Core_MDF_IUPGM_Program_nm__c,
                rec.Core_MDF_IUPGM_Account_txt__c
            );

            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> existing =
                existingMap.get(key);

            IUPGM_State state = evaluateState(rec, existing);

            String action = getAction(rec, state);

            System.debug('Action Decided: ' + action);

            if(action == 'CREATE'){

                Core_MDF_Int_Users_Partner_Geo_Mapping__c newRec =
                    buildNewIUPGM(rec);

                toInsert.add(newRec);
            }
            else if(action == 'UPDATE'){

                mergeLogic(existing, rec, toUpdate);
            }
            else{
                System.debug('SKIPPED');
            }
        }

        if(!toInsert.isEmpty()){
            System.debug('Inserting IUPGM: ' + toInsert.size());
            insert toInsert;
        }

        if(!toUpdate.isEmpty()){
            System.debug('Updating IUPGM: ' + toUpdate.size());
            update toUpdate;
        }
    }

    // =============================
    // STATE CLASS
    // =============================

    public class IUPGM_State{
        public String recordExists;
        public String regionMode;
        public String budgetMode;
        public String allAccounts;
    }

    // =============================
    // EVALUATE STATE
    // =============================

    private static IUPGM_State evaluateState(
        Core_MDF_IUPGM_Request_Staging__c rec,
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> existing
    ){
        IUPGM_State state = new IUPGM_State();
    

        state.recordExists = (existing == null || existing.isEmpty()) ? 'NO' : 'YES';

        Set<String> newRegions = toSet(rec.Core_MDF_IUPGM_Region_Sub_Region_nm__c);
        Set<String> oldRegions = new Set<String>();

        Boolean hasAllAccounts = false;

        if(existing != null){
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c ex : existing){

                oldRegions.addAll(toSet(ex.Core_MDF_Region_Sub_Region_nm__c));

                if(ex.Core_MDF_All_Accounts_cd__c == 'Yes'){
                    hasAllAccounts = true;
                }
            }
        }

        state.allAccounts = hasAllAccounts ? 'YES' : 'NO';

        // REGION LOGIC
        if(oldRegions.contains('WW')){
            state.regionMode = 'FULL';
        }
        else if(oldRegions.containsAll(newRegions)){
            state.regionMode = 'FULL';
        }
        else if(!oldRegions.isEmpty()){
            state.regionMode = 'PARTIAL';
        }
        else{
            state.regionMode = 'NONE';
        }

        // BUDGET SIMPLIFIED
        state.budgetMode = 'PARTIAL';

        return state;
    }

    // =============================
    // METADATA ACTION
    // =============================

    private static String getAction(
        Core_MDF_IUPGM_Request_Staging__c rec,
        IUPGM_State state
    ){

        List<Core_MDF_IUPGM_Rule_Config__mdt> rules = [
            SELECT Core_MDF_Role__c, Core_MDF_Program__c, Core_MDF_Record_Exists__c,
                   Core_MDF_Region_Mode__c, Core_MDF_Budget_Mode__c,
                   Core_MDF_All_Accounts__c, Core_MDF_Action__c, Core_MDF_Priority__c
            FROM Core_MDF_IUPGM_Rule_Config__mdt
            ORDER BY Core_MDF_Priority__c ASC
        ];

        for(Core_MDF_IUPGM_Rule_Config__mdt rule : rules){

            if(match(rule, rec, state)){
                return rule.Core_MDF_Action__c;
            }
        }

        return 'SKIP';
    }

    private static Boolean match(
        Core_MDF_IUPGM_Rule_Config__mdt rule,
        Core_MDF_IUPGM_Request_Staging__c rec,
        IUPGM_State state
    ){
        return
            (rule.Core_MDF_Role__c == 'ANY' || rule.Core_MDF_Role__c == rec.Core_MDF_IUPGM_Role_nm__c) &&
            (rule.Core_MDF_Program__c == 'ANY' || rule.Core_MDF_Program__c == rec.Core_MDF_IUPGM_Program_nm__c) &&
            (rule.Core_MDF_Record_Exists__c == state.recordExists) &&
            (rule.Core_MDF_Region_Mode__c == state.regionMode || rule.Core_MDF_Region_Mode__c == 'ANY') &&
            (rule.Core_MDF_Budget_Mode__c == state.budgetMode || rule.Core_MDF_Budget_Mode__c == 'ANY') &&
            (rule.Core_MDF_All_Accounts__c == state.allAccounts || rule.Core_MDF_All_Accounts__c == 'ANY');
    }

    // =============================
    // CREATE
    // =============================

    private static Core_MDF_Int_Users_Partner_Geo_Mapping__c buildNewIUPGM(
        Core_MDF_IUPGM_Request_Staging__c rec
    ){
        Core_MDF_Int_Users_Partner_Geo_Mapping__c obj =
            new Core_MDF_Int_Users_Partner_Geo_Mapping__c();

        obj.Core_MDF_User_id__c = rec.Core_MDF_IUPGM_User_txt__c;
        obj.Core_MDF_Role_nm__c = rec.Core_MDF_IUPGM_Role_nm__c;
        obj.Core_MDF_Program_nm__c = rec.Core_MDF_IUPGM_Program_nm__c;
        obj.Core_MDF_Account_id__c = rec.Core_MDF_IUPGM_Account_txt__c;
        obj.Core_MDF_Region_Sub_Region_nm__c =
            rec.Core_MDF_IUPGM_Region_Sub_Region_nm__c;
        obj.Core_MDF_Active_Ind__c = true;

        return obj;
    }

    // =============================
    // UPDATE (MERGE)
    // =============================

    private static void mergeLogic(
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> existing,
        Core_MDF_IUPGM_Request_Staging__c rec,
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> toUpdate
    ){
        if(existing == null || existing.isEmpty()) return;

        Core_MDF_Int_Users_Partner_Geo_Mapping__c baseRec = existing[0];

        Set<String> regions = toSet(baseRec.Core_MDF_Region_Sub_Region_nm__c);
        regions.addAll(toSet(rec.Core_MDF_IUPGM_Region_Sub_Region_nm__c));

        baseRec.Core_MDF_Region_Sub_Region_nm__c =
            String.join(new List<String>(regions), ';');

        toUpdate.add(baseRec);
    }

    // =============================
    // HELPERS
    // =============================

    private static String buildKey(Id userId, String role, String program, Id accountId){
        return String.valueOf(userId) + '_' + role + '_' + program + '_' + String.valueOf(accountId);
    }

    private static Set<String> toSet(String val){
        if(String.isBlank(val)) return new Set<String>();
        return new Set<String>(val.split(';'));
    }
}