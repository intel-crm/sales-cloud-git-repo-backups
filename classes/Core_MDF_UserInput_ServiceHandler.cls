/****************************************************************************************************************************************
 * Class Name        : Core_MDF_UserInput_ServiceHandler
 * Test Class Name   : Core_MDF_UserInput_ServiceHandler_Test
 * Created Date      : 03/06/2026
 * Modification Log
 * Developer            Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Ramapriya       		03/15/2026         Service Class for handling trigger related functions on MDF User Input object.
 *****************************************************************************************************************************************/
public class Core_MDF_UserInput_ServiceHandler {

    public static void processUserInput(List<Core_MDF_User_Input__c> inputs){

        System.debug('===== START processUserInput =====');

        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> toInsert = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> toUpdate = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        List<Core_MDF_User_Input__c> stagingUpdates = new List<Core_MDF_User_Input__c>();
        List<Id> emailIds = new List<Id>();

        Set<Id> userIds = new Set<Id>();
        for(Core_MDF_User_Input__c rec : inputs){
            userIds.add(rec.Core_MDF_IUPGM_User__c);
        }

        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> existingList = [
            SELECT Id, Core_MDF_User_id__c, Core_MDF_Role_nm__c,
                   Core_MDF_Program_nm__c, Core_MDF_Account_id__c,
                   Core_MDF_All_Accounts_cd__c,
                   Core_MDF_Region_Sub_Region_nm__c,
                   Core_MDF_Budget_Type_nm__c,
                   Core_MDF_All_Budget_Type_Access_Ind__c,
                   Core_MDF_Active_Ind__c
            FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
            WHERE Core_MDF_User_id__c IN :userIds
        ];

        Map<String, List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>> mapKey = new Map<String, List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>>();

        for(Core_MDF_Int_Users_Partner_Geo_Mapping__c ex : existingList){
            String key = ex.Core_MDF_User_id__c + '_' + ex.Core_MDF_Role_nm__c + '_' + ex.Core_MDF_Program_nm__c;
            if(!mapKey.containsKey(key)){
                mapKey.put(key, new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>());
            }
            mapKey.get(key).add(ex);
        }

        for(Core_MDF_User_Input__c rec : inputs){

            try{

                System.debug('--- Processing Input: ' + rec);

                Core_MDF_User_Input__c w = rec.clone(false,true,false,false);
                normalizeInput(w);

                String key = w.Core_MDF_IUPGM_User__c + '_' + w.Core_MDF_IUPGM_Role__c + '_' + w.Core_MDF_IUPGM_Program__c;
                List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> matches = mapKey.get(key);

                if(matches == null || matches.isEmpty()){
                    System.debug('No existing record → INSERT');

                    toInsert.add(buildNew(w));
                    stagingUpdates.add(status(rec,'SUCCESS','Created'));
                    emailIds.add(rec.Id);
                    continue;
                }

                Core_MDF_Int_Users_Partner_Geo_Mapping__c primary;

                // ALL ACCOUNT PRIORITY
                if(w.Core_MDF_IUPGM_All_Account_Access__c == 'Yes'){
                    for(Core_MDF_Int_Users_Partner_Geo_Mapping__c ex : matches){
                        if(ex.Core_MDF_All_Accounts_cd__c == 'Yes'){
                            primary = ex;
                            break;
                        }
                    }
                }

                // SAME ACCOUNT
                if(primary == null){
                    for(Core_MDF_Int_Users_Partner_Geo_Mapping__c ex : matches){
                        if(ex.Core_MDF_Account_id__c == w.Core_MDF_IUPGM_Account__c){
                            primary = ex;
                            break;
                        }
                    }
                }

                // FALLBACK
                if(primary == null){
                    primary = matches[0];
                }

                System.debug('Primary selected: ' + primary.Id);

                // 🔥 DEACTIVATE OTHERS
                for(Core_MDF_Int_Users_Partner_Geo_Mapping__c ex : matches){
                    if(ex.Id != primary.Id && ex.Core_MDF_Active_Ind__c){
                        System.debug('Deactivating: ' + ex.Id);
                        ex.Core_MDF_Active_Ind__c = false;
                        toUpdate.add(ex);
                    }
                }

                Boolean changed = false;

                if(!primary.Core_MDF_Active_Ind__c){
                    primary.Core_MDF_Active_Ind__c = true;
                    changed = true;
                }

                // 🔥 REGION ENGINE (FINAL LOGIC)
                String newRegion = resolveRegion(
                    primary.Core_MDF_Region_Sub_Region_nm__c,
                    w.Core_MDF_IUPGM_Region_Sub_Region__c
                );

                System.debug('Resolved Region: ' + newRegion);

                if(newRegion != primary.Core_MDF_Region_Sub_Region_nm__c){
                    primary.Core_MDF_Region_Sub_Region_nm__c = newRegion;
                    changed = true;
                }

                // BUDGET
                if(w.Core_MDF_IUPGM_All_Budget_Type_Access__c){
                    if(!primary.Core_MDF_All_Budget_Type_Access_Ind__c){
                        primary.Core_MDF_All_Budget_Type_Access_Ind__c = true;
                        primary.Core_MDF_Budget_Type_nm__c = null;
                        changed = true;
                    }
                }

                if(changed){
                    toUpdate.add(primary);
                    stagingUpdates.add(status(rec,'UPDATED','Updated'));
                } else {
                    stagingUpdates.add(status(rec,'EXISTS','No change'));
                }

                emailIds.add(rec.Id);

            }catch(Exception e){
                System.debug('ERROR: ' + e.getMessage());
                stagingUpdates.add(status(rec,'FAILED',e.getMessage()));
                emailIds.add(rec.Id);
            }
        }

        if(!toInsert.isEmpty()){
            System.debug('Inserting: ' + toInsert);
            insert toInsert;
        }

        if(!toUpdate.isEmpty()){
            System.debug('Updating: ' + toUpdate);
            update toUpdate;
        }

        if(!stagingUpdates.isEmpty()){
            update stagingUpdates;
        }

        if(!emailIds.isEmpty()){
            System.debug('Enqueue Email Job');
            System.enqueueJob(new Core_MDF_EmailQueueable(emailIds));
        }
    }

    // =============================
    // 🔥 REGION ENGINE
    // =============================
    private static String resolveRegion(String oldVal, String newVal){

        Set<String> oldSet = toSet(oldVal);
        Set<String> newSet = toSet(newVal);

        // CASE 1: WW + new → REMOVE WW
        if(oldSet.contains('WW') && !newSet.contains('WW')){
            return String.join(new List<String>(newSet),';');
        }

        Set<String> merged = new Set<String>();
        merged.addAll(oldSet);
        merged.addAll(newSet);

        // CASE 2: ALL GEO → WW
        Set<String> allGeo = new Set<String>{'APJ','EMEA','PRC','ASMO','INDIA'};

        if(merged.containsAll(allGeo)){
            return 'WW';
        }

        // CASE 3: WW present → keep WW only
        if(merged.contains('WW')){
            return 'WW';
        }

        return String.join(new List<String>(merged),';');
    }

    private static void normalizeInput(Core_MDF_User_Input__c w){
        if(w.Core_MDF_IUPGM_All_Account_Access__c == 'Yes'){
            w.Core_MDF_IUPGM_Account__c = null;
        }
        if(w.Core_MDF_IUPGM_All_Budget_Type_Access__c){
            w.Core_MDF_IUPGM_Budget_Type__c = null;
        }
    }

    private static Core_MDF_Int_Users_Partner_Geo_Mapping__c buildNew(Core_MDF_User_Input__c w){

        Core_MDF_Int_Users_Partner_Geo_Mapping__c n = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();

        n.RecordTypeId = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c
            .getRecordTypeInfosByName()
            .get('Intel Partner Alliance')
            .getRecordTypeId();

        n.Core_MDF_User_id__c = w.Core_MDF_IUPGM_User__c;
        n.Core_MDF_Role_nm__c = w.Core_MDF_IUPGM_Role__c;
        n.Core_MDF_Program_nm__c = w.Core_MDF_IUPGM_Program__c;
        n.Core_MDF_Region_Sub_Region_nm__c = w.Core_MDF_IUPGM_Region_Sub_Region__c;

        if(w.Core_MDF_IUPGM_All_Account_Access__c == 'Yes'){
            n.Core_MDF_All_Accounts_cd__c = 'Yes';
        } else {
            n.Core_MDF_Account_id__c = w.Core_MDF_IUPGM_Account__c;
        }

        if(w.Core_MDF_IUPGM_All_Budget_Type_Access__c){
            n.Core_MDF_All_Budget_Type_Access_Ind__c = true;
        } else {
            n.Core_MDF_Budget_Type_nm__c = w.Core_MDF_IUPGM_Budget_Type__c;
        }

        n.Core_MDF_Active_Ind__c = true;

        return n;
    }

    private static Core_MDF_User_Input__c status(Core_MDF_User_Input__c rec,String s,String msg){
        return new Core_MDF_User_Input__c(
            Id=rec.Id,
            Core_MDF_Request_Status__c=s,
            Core_MDF_Request_Status_Message__c=msg
        );
    }

    private static Set<String> toSet(String val){
        if(String.isBlank(val)) return new Set<String>();
        return new Set<String>(val.split(';'));
    }
}