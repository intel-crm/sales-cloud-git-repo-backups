public class InboundCreationForNonIpaAccount implements Queueable {
    private List<String> accountId;

    public InboundCreationForNonIpaAccount(List<String> accountId) {
        this.accountId = accountId;
    }

    public void execute(QueueableContext context) {
        Map<String,Core_Account_Group_Member__c> parentCagRec = new Map<String,Core_Account_Group_Member__c>();
        List<Core_OnePartner_Inbound_Message__c> listOfInboundOnePartner =  new List<Core_OnePartner_Inbound_Message__c>() ;
        Set<String> parentUcdSet = new Set<String>();
        List<Account> accRec= [Select id, Core_Business_Party_Idd__c, Core_Parent_Business_Party_Id__c from Account where id in:accountId];
        if(accRec!=null && !accRec.isEmpty()){
            for(Account acc: accRec){
                    parentUcdSet.add(acc.Core_Parent_Business_Party_Id__c);
            }
            if(parentUcdSet!=null && !parentUcdSet.isEmpty()){
                for(Core_Account_Group_Member__c agm : [SELECT Id,
                                                            Name,
                                                            Core_Partner_Account_Id__c, 
                                                            Core_Intel_Account_Id__c,
                                                            Core_Business_Party_Id__c,
                                                            Core_Partner_Account_Id__r.Core_OnePartnerID__c,
                                                            Core_Partner_Account_Id__r.Name,
                                                            Core_Inactive_Ind__c 
                                                            FROM Core_Account_Group_Member__c WHERE Core_Business_Party_Id__c in :parentUcdSet and Core_Inactive_Ind__c = false]){
                    if(parentUcdSet.contains(agm.Core_Business_Party_Id__c)){ // UCD change
                        parentCagRec.put(agm.Core_Business_Party_Id__c,agm);
                    }
                }
                for(Account acc : accRec){
                    if(!parentCagRec.IsEmpty() && parentCagRec.containskey(acc.Core_Parent_Business_Party_Id__c)){
                            Core_OnePartner_Inbound_Message__c  inboundOnePartner = new Core_OnePartner_Inbound_Message__c  () ;
                            inboundOnePartner.Core_OnePartnerID__c  = integer.valueof(parentCagRec.get(acc.Core_Parent_Business_Party_Id__c).Core_Partner_Account_Id__r.Core_OnePartnerID__c) ; 
                            inboundOnePartner.Core_OnePartner_Account_Name__c = parentCagRec.get(acc.Core_Parent_Business_Party_Id__c).Core_Partner_Account_Id__r.Name;
                            inboundOnePartner.Core_SalesCloud_AccountID__c = acc.id ;
                            inboundOnePartner.Core_Status__c = 'NEW';
                            inboundOnePartner.Core_PAG_Grouping_Method__c = 'GLBL';
                            inboundOnePartner.Core_CIM_ID__c  = Decimal.valueof(acc.Core_Business_Party_Id__c);
                            inboundOnePartner.Core_Effective_Start_Date_Time__c = System.now();
                            listOfInboundOnePartner.add(inboundOnePartner);
                    }            
                }
            }
        }
        if(!listOfInboundOnePartner.IsEmpty()){
            Database.SaveResult[] saveResultList = Database.insert(listOfInboundOnePartner, false);                
            List<PRM_Tracker__c> trackerList = new List<PRM_Tracker__c>();
            Map<id,Core_OnePartner_Inbound_Message__c> inboundRecMap = new Map<id,Core_OnePartner_Inbound_Message__c>(listOfInboundOnePartner);        
            for(Database.SaveResult result: saveResultList){//loop start
                if(result.isSuccess()){
                    Id sId = result.getId();
                    if(sId!=null && inboundRecMap.keySet().contains(sId) ){
                        PRM_Tracker__c tracker = new PRM_Tracker__c();
                        tracker.PRM_Type__c = 'OPID Updates';
                        tracker.PRM_Milestone__c = 'INBND_CRTD';
                        tracker.PRM_Location_Account__c = inboundRecMap.get(sId).Core_SalesCloud_AccountID__c;
                        tracker.PRM_Milestone_Display_Name__c = 'OPID Request Created';
                        tracker.PRM_Completed__c = true;
                        trackerList.add(tracker);    
                    }
                }
            }//loop ends here..
            if (!trackerList.isEmpty()) {
                insert trackerList;
            } 
        }
    }
}