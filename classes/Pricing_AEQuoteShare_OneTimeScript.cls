public class Pricing_AEQuoteShare_OneTimeScript {
    //Pricing_AEQuoteShare_OneTimeScript.createAEQuoteTeam();
    public static void createAEQuoteTeam(){
        Map<Id,Id> quoteAEIdsMap = new Map<Id,Id>();
        Map<Id,String> quoteAEEmailMap = new Map<Id,String>();
        Set<String> AEEmailIds = new Set<String>();
        List<Pricing_Quote_Team__c> quoteTeam = new List<Pricing_Quote_Team__c>();
        for(SBQQ__Quote__c quote : [SELECT Id,Name,Pricing_Intel_Account_Exec_Email_Txt__c,Pricing_Account_Executive_Nm__c,Pricing_Account_Executive_Nm__r.IsActive FROM SBQQ__Quote__c 
                                    WHERE Pricing_Intel_Account_Exec_Email_Txt__c!=null]){
                                        if(!String.isEmpty(quote.Pricing_Account_Executive_Nm__c) && quote.Pricing_Account_Executive_Nm__r.IsActive){
                                            quoteAEIdsMap.put(quote.Id, quote.Pricing_Account_Executive_Nm__c);              
                                        }else{
                                            quoteAEEmailMap.put(quote.Id, quote.Pricing_Intel_Account_Exec_Email_Txt__c);
                                            AEEmailIds.add(quote.Pricing_Intel_Account_Exec_Email_Txt__c);
                                        }                         
                                    }       
        for(Id quoteId : quoteAEIdsMap.keySet()){
            Pricing_Quote_Team__c quoteTM = new Pricing_Quote_Team__c();  
            quoteTM.Pricing_Quote_Id__c = quoteId;
            quoteTM.Pricing_Quote_Team_Member_Id__c = quoteAEIdsMap.get(quoteId);
            quoteTM.Pricing_Role_Nm__c = 'Account Executive'; 
            quoteTeam.add(quoteTM);
        }
        if(AEEmailIds.size() > 0){
            Map<String,Id> userEmailIdMap = new Map<String,Id>();
            for(User usr : [SELECT id,Email FROM User WHERE IsActive=True AND Email IN :AEEmailIds AND ContactId!=null]){
                userEmailIdMap.put(usr.Email, usr.Id);
            }
            if(userEmailIdMap.size() > 0){
                for(Id quoteId : quoteAEEmailMap.keySet()){
                    if(userEmailIdMap.containsKey(quoteAEEmailMap.get(quoteId))){
                        Pricing_Quote_Team__c quoteTM = new Pricing_Quote_Team__c();  
                        quoteTM.Pricing_Quote_Id__c = quoteId;
                        quoteTM.Pricing_Quote_Team_Member_Id__c = userEmailIdMap.get(quoteAEEmailMap.get(quoteId));
                        quoteTM.Pricing_Role_Nm__c = 'Account Executive'; 
                        quoteTeam.add(quoteTM);
                    }
                }
            }
        }
        system.debug('quoteTeam ==>'+quoteTeam.size());
        if(quoteTeam.size() > 0){
            insert quoteTeam;
            /*
            List<Pricing_Quote_Team__c> tempQuoteTeam = new List<Pricing_Quote_Team__c>();
             Integer i= 0;
            for(Pricing_Quote_Team__c qtm : quoteTeam){
               tempQuoteTeam.add(qtm);
                i++;
                if(i==200){
                    system.debug('Inserting Quote Team');
                    insert tempQuoteTeam;
                    tempQuoteTeam.clear();
                    i=0;
                }
            }
            if(tempQuoteTeam.size() > 0){
                insert tempQuoteTeam;
            }*/
        }
    }
    
}