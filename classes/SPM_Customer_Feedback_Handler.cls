public class SPM_Customer_Feedback_Handler {
    /*public static void updateAccountDetail(List<SPM_Customer_Feedback__c> triggerList){
        system.debug('here');
        //List<id> cfIDs = new cfIDs;
        Map<id,list<string>> csToFTOwner = new Map<id,list<string>>();
        List<SPM_Account_Feedback__c> afList = new List<SPM_Account_Feedback__c>();
        List<SPM_Account_Feedback__c> toBeUpdated = new List<SPM_Account_Feedback__c>();
        Map<id,List<SPM_Account_Feedback__c>> csToAFMap = new Map<id,List<SPM_Account_Feedback__c>>();
        Map<id,string> afToFTOwner = new Map<id,string>();
        List<string> emailIds = new List<string>();
        try{          
            for(SPM_Customer_Feedback__c cf:triggerList){
                if(cf.Feedback__c == 'Keep'){
                    string val = cf.Feedback_Type__c + ';' + cf.Feedback_By__c;
                    if(csToFTOwner.containsKey(cf.Customer_ID__c)){
                        csToFTOwner.get(cf.Customer_ID__c).add(val);
                    }
                    else{
                        csToFTOwner.put(cf.Customer_ID__c, new List<String>{val});
                    }
                }
            } 
            
            system.debug('csToFTOwner: '+csToFTOwner);
            
            if(csToFTOwner.size()>0){
                afList = [select id, Feedback_Type__c, Account_ID__r.GM__c,Account_ID__r.VP__c,Account_ID__r.DR__c, Account_ID__r.SPM_Customer_ID__c from SPM_Account_Feedback__c 
                          where Account_ID__r.SPM_Customer_ID__c in: csToFTOwner.keyset()];
                
                for(SPM_Account_Feedback__c af: afList){
                    if(csToAFMap.containsKey(af.Account_ID__r.SPM_Customer_ID__c)){
                        csToAFMap.get(af.Account_ID__r.SPM_Customer_ID__c).add(af);
                    }
                    else{
                        csToAFMap.put(af.Account_ID__r.SPM_Customer_ID__c,new List<SPM_Account_Feedback__c>{af});
                    }   
                }  
                system.debug('afList: '+afList);
                
                for(id cfid:csToFTOwner.keyset()){
                    //DR;User id
                    //List<string> splitVal = csToFTOwner.get(cfid).split(';');
                    List<SPM_Account_Feedback__c> accfList = csToAFMap.get(cfid);
                    if(accfList.size()>0){
                        for(SPM_Account_Feedback__c af:accfList){
                            for(string csSplit : csToFTOwner.get(cfid)){
                                List<string> splitVal = csSplit.split(';');
                                if(splitVal[0] == 'DR' && af.Feedback_Type__c == splitVal[0] && af.Account_ID__r.DR__c == splitVal[1]){
                                    system.debug('Match 1');
                                    af.Feedback__c = 'Keep as is';
                                    toBeUpdated.add(af);
                                }
                                else if(splitVal[0] == 'VP' && af.Feedback_Type__c == splitVal[0] && af.Account_ID__r.VP__c == splitVal[1]){
                                    system.debug('Match 2');
                                    af.Feedback__c = 'Keep as is';
                                    toBeUpdated.add(af);
                                }
                                else if(splitVal[0] == 'GM' && af.Feedback_Type__c == splitVal[0] && af.Account_ID__r.GM__c == splitVal[1]){
                                    system.debug('Match 3');
                                    af.Feedback__c = 'Keep as is';
                                    toBeUpdated.add(af);
                                }         
                            } 
                        }
                    }
                    
                    
                }
            }
            system.debug('toBeUpdated: '+toBeUpdated);
            
            if(toBeUpdated.size()>0){
                
            }
        }
        catch(Exception ex) { 
            System.debug('Exception::: '+ex +ex.getLineNumber()); 
        }
    }*/
    
}