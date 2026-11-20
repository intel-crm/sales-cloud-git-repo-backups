public class Core_ToastMessageController {
    
    public static boolean isCheck;
    public static boolean isCheck2;
   @AuraEnabled
    public static boolean getCheckBox(Id artId){
        system.debug('the reocrd id===>'+artId);
        Opportunity opp=[select id,name,Core_External_User__c from Opportunity where id =:artId];
       if(opp.Core_External_User__c == true ){
           isCheck = true;
        }
        system.debug('the return value===>'+isCheck);
        return isCheck;
    }
    @AuraEnabled
    public static boolean setcheckfalse(Id artId)
    {
       Opportunity opp=[select id,name,Core_External_User__c from Opportunity where id =:artId];
        if(opp.Core_External_User__c == true  ){
            opp.Core_External_User__c = false;
        }
        update opp;
        system.debug('the updated Account===>'+opp.Core_External_User__c);
        return null;
    }
}