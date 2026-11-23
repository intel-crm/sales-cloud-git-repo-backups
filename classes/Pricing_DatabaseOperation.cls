public without sharing class Pricing_DatabaseOperation {
    public static Database.SaveResult[] performInsert(List<SObject> recordLst,Boolean allOrNone,Boolean isCPQDisabled){
        try{
            disableCPQTrigger(isCPQDisabled);
            return Database.insert(recordLst,allOrNone);
        }catch(Exception exp){
            Pricing_Tender_Utility.logError(exp);
            return null;
        }finally{
            SBQQ.TriggerControl.enable();
            return null;
        }
    }
    public static Database.SaveResult[] performUpdate(List<SObject> recordLst,Boolean allOrNone,Boolean isCPQDisabled){
        try{
            disableCPQTrigger(isCPQDisabled);
            return Database.update(recordLst,allOrNone);
        }catch(Exception exp){
            Pricing_Tender_Utility.logError(exp);
            return null;
        }finally{
            SBQQ.TriggerControl.enable();
            return null;
        }
    }
    public static Database.UpsertResult[] performUpsert(List<SObject> recordLst,Boolean allOrNone,Boolean isCPQDisabled){
        try{
            disableCPQTrigger(isCPQDisabled);
            return Database.upsert(recordLst,allOrNone);
        }catch(Exception exp){
            Pricing_Tender_Utility.logError(exp);
            return null;
        }finally{
            SBQQ.TriggerControl.enable();
            return null;
        }
    }
    public static Database.DeleteResult[] performDelete(List<SObject> recordLst, Boolean allOrNone,Boolean isCPQDisabled){
        try{
            disableCPQTrigger(isCPQDisabled);
            return Database.delete(recordLst,allOrNone);
        }catch(Exception exp){
            Pricing_Tender_Utility.logError(exp);
            return null;
        }finally{
            SBQQ.TriggerControl.enable();
            return null;
        }
    }
    
    public static void disableCPQTrigger(Boolean isCPQDisabled){
        if(isCPQDisabled){
            SBQQ.TriggerControl.disable();
        }
    }
}