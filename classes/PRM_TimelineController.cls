public class PRM_TimelineController {
    
     @AuraEnabled
    public static List<History>  fetchHistory(Id recordId){
        
        List<History> historyData = new List<History>();
        
        Set<Id> contactParentID = new Set<Id>();
        Set<Id> benefitParentID = new Set<Id>();
        Set<Id> memberParentID = new Set<Id>();
        if (Schema.sObjectType.Account.isAccessible() && Schema.sObjectType.PRM_Account_Contact_Relationship__c.isAccessible() && Schema.sObjectType.PRM_AccountBenefitAssociation__c.isAccessible() && Schema.sObjectType.PRM_AccountChannelMembership__c.isAccessible()){
        Account acc= [Select Id, CreatedDate, Name,LastModifiedBy.Name,CreatedBy.Name, (Select Id,Name from Channel_Memberships1__r), (Select id,Name from AccountBenefitAssociations__r), (Select id,Name,PRM_Contact_Id__r.Name from Account_Contact_Relationships__r) from Account  where id =:recordId];
        //System.debug('acc-->'+acc[0].Account_Contact_Relationships__r);
        //for(Account account : acc) {
        if(acc != null){
           // historyData.add(new History(acc));
            
            //}
            
            if(acc.Account_Contact_Relationships__r != null)
            {
                for(PRM_Account_Contact_Relationship__c c:acc.Account_Contact_Relationships__r) 
                {
                    contactParentID.add(c.Id);
                    // historyData.add(new History(c));
                    
                }
            }
            
            if(acc.AccountBenefitAssociations__r != null)
            {
                for(PRM_AccountBenefitAssociation__c b:acc.AccountBenefitAssociations__r)
                {
                    benefitParentID.add(b.Id);
                }
            }   
            
            if(acc.Channel_Memberships1__r != null)
            {
                for(PRM_AccountChannelMembership__c m : acc.Channel_Memberships1__r)
                {
                    memberParentID.add(m.Id);
                }           
            }        
            
            if(contactParentID.size()>0)
            {               
              //List<PRM_Account_Contact_Relationship__History> contactResult=[Select ParentId, id, createddate, field, oldvalue, newvalue, isdeleted from PRM_Account_Contact_Relationship__history where (field='created' or field='PRM_InActive_Ind__c' or field='PRM_Relationship_Id__c') and parentid in :contactParentID order by createddate desc];
                List<PRM_Account_Contact_Relationship__c> contactResult=[select id,PRM_Contact_Id__r.Name,PRM_Relationship_Id__r.Name, (Select ParentId, id, createddate, createdby.name, field, oldvalue, newvalue, isdeleted from histories where (field='created' or field='PRM_InActive_Ind__c' or field='PRM_Relationship_Id__c') order by createddate desc ) from PRM_Account_Contact_Relationship__c  where id in :contactParentID order by createddate desc];
                System.debug('ani'+contactResult);
                for(PRM_Account_Contact_Relationship__c con: contactResult)
                {
                    historyData.add(new History(con));
                }				
            }
            
            if(benefitParentID.size()>0)
            {
              //List<PRM_AccountBenefitAssociation__History> benefitResult=[Select ParentId, id, createddate, field, oldvalue, newvalue, isdeleted from PRM_AccountBenefitAssociation__History where (field='created' or field='PRM_Status_Nm__c') and parentid in :benefitParentID order by createddate desc];
                List<PRM_AccountBenefitAssociation__c> benefitResult= [Select id,PRM_Partner_Benefit_Id__r.Name,(Select ParentId, id, createddate,createdby.name, field, oldvalue, newvalue, isdeleted from histories where (field='created' or field='PRM_Status_Nm__c') order by createddate desc) from PRM_AccountBenefitAssociation__c  where id in:benefitParentID order by createddate desc];
                for(PRM_AccountBenefitAssociation__c ben: benefitResult)
                {
                    historyData.add(new History(ben));
                }
            }
            
            if(memberParentID.size()>0)
            {
              //List<PRM_AccountChannelMembership__History> memberResult=[Select ParentId, id, createddate, field, oldvalue, newvalue, isdeleted from PRM_AccountChannelMembership__history where (field='created' or field='PRM_Channel_Program_Level_Id__c') and parentId in:memberParentID order by createddate desc];
            
                List<PRM_AccountChannelMembership__c> memberResult=[Select id,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,(Select ParentId, id, createddate,createdby.name, field, oldvalue, newvalue, isdeleted from histories where (field='created' or field='PRM_Channel_Program_Level_Id__c') order by createddate desc ) from PRM_AccountChannelMembership__c where id in:memberParentID order by createddate desc];
                for(PRM_AccountChannelMembership__c mem: memberResult)
                {
                    historyData.add(new History(mem));
                }
            }
            historyData.add(new History(acc));
        }
        }
        return historyData;
    }
    
    
    public class History {
        
        @AuraEnabled  public Id id { get; set; }
       // @AuraEnabled  public String newvalue { get; set; }
       // @AuraEnabled  public String oldvalue { get; set; }
       // @AuraEnabled  public String field { get; set; }
        @AuraEnabled public datetime createddate { get; set; }
        @AuraEnabled public string objectname  { get; set; }
        @AuraEnabled public string recordName {get; set;}
        @AuraEnabled public string  contactName{get; set;}
        @AuraEnabled public string  benefitName{get; set;}
        @AuraEnabled public string partnerRoleName{get; set;}
        @AuraEnabled public string partnerTierName{get; set;}
        @AuraEnabled public string contactRelation{get; set; }
        @AuraEnabled public string accountUserName{get; set; }
        
        
        @AuraEnabled public List<PRM_Account_Contact_Relationship__History>  acrHistory{get; set;}
        @AuraEnabled public List<PRM_AccountBenefitAssociation__History>  abaHistory{get; set;}
        @AuraEnabled public List<PRM_AccountChannelMembership__History> acmHistory{get; set;}
        
        
        public History(Account account) {
            this.id = account.Id;
            this.createddate = account.createdDate;
            this.objectname = 'Account';
            this.accountUserName=account.CreatedBy.Name;
            this.recordName = account.Name;
            
        }    
        
             
        public History(PRM_Account_Contact_Relationship__c con) {
            
            //this.acrHistory =  con.Histories;
            //String mergeData =  '{\n';
            this.objectname = 'PRM_Account_Contact_Relationship__c'; 
            this.contactName = con.PRM_Contact_Id__r.Name; 
            this.contactRelation=con.PRM_Relationship_Id__r.Name;
            this.acrHistory = con.Histories;
                      
        }
        
        public History(PRM_AccountBenefitAssociation__c benefit) {
            this.objectname='PRM_AccountBenefitAssociation__c';
            this.benefitName=benefit.PRM_Partner_Benefit_Id__r.Name;
            this.abaHistory= benefit.Histories;
        }
   
        
        public History(PRM_AccountChannelMembership__c mem) {
            this.objectname='PRM_AccountChannelMembership__c';
            this.partnerTierName=mem.PRM_Channel_Program_Level_Id__r.Name;
            this.partnerRoleName=mem.PRM_Partner_Role__c;
            this.acmHistory=mem.Histories;
        }
        
        /*public History(PRM_AccountBenefitAssociation__history benefit) {
            this.id = benefit.ParentId;
            this.field = benefit.field;
            this.createddate = benefit.createdDate;
            this.newvalue = String.valueof(benefit.newValue);
            this.oldvalue = String.valueof(benefit.oldValue);
           this.objectname = 'PRM_AccountBenefitAssociation__c';
           // this.benefitName = benefit.PRM_Partner_Benefit_Id__r.Name;
            //this.abaHistory = benefit.Histories;
            
        }
        
             
        public History(PRM_AccountChannelMembership__history mem) {
            this.id = mem.ParentId;
            this.field = mem.field;
            this.createddate = mem.createdDate;
            this.newvalue = String.valueof(mem.newValue);
            this.oldvalue = String.valueof(mem.oldValue);
            this.objectname = 'PRM_AccountChannelMembership__c';
            
        } */
    }

}