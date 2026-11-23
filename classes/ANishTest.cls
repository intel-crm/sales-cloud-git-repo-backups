public class ANishTest {
    //test for VS
  @AuraEnabled
    public static History  fetchHistory(Id recordId){
        
       // List<History> historyData = new List<History>();
        History accHistoryList = new History();
         List<AccHistory> ah;
        List<AccHistory> listHist = new List<AccHistory>();
        Set<Id> contactParentID = new Set<Id>();
        Set<Id> benefitParentID = new Set<Id>();
        Set<Id> memberParentID = new Set<Id>();
        if (Schema.sObjectType.Account.isAccessible() && Schema.sObjectType.PRM_Account_Contact_Relationship__c.isAccessible() && Schema.sObjectType.PRM_AccountBenefitAssociation__c.isAccessible() && Schema.sObjectType.PRM_AccountChannelMembership__c.isAccessible()){
            Account acc= [Select Id, CreatedDate, Name,LastModifiedBy.Name,CreatedBy.Name, (Select Id,Name from Channel_Memberships1__r), (Select id,Name from AccountBenefitAssociations__r), (Select id,Name,PRM_Contact_Id__r.Name from Account_Contact_Relationships__r) from Account  where id =:recordId];
         /* if(Test.isRunningTest()){  //if TEST, create dummy AccHistory
         ah = new List<AccHistory>{}; //OldValue, NewValue not writeable
         ah.add(new AccHistory(AccountId=accountId, Field='Type'));
     }*/
            //System.debug('acc-->'+acc[0].Account_Contact_Relationships__r);
            //for(Account account : acc) {
            if(acc != null){
                // historyData.add(new History(acc));
                
                //}
                AccHistory singHistAcc = new AccHistory();
                // <strong>{!v.activity.objectname} - '{!v.activity.recordName}' is created by {!v.activity.accountUserName}.</strong>
                
                singHistAcc.linkDescriptionStart = 'Account - '+acc.Name+' is created by '+acc.CreatedBy.Name;
                //singHist.linkDescription = ' is removed from the account by '+acc.CreatedBy.Name;
                //singHist.linkLabel = ben.PRM_Partner_Benefit_Id__r.Name;
                
                // singHist.link ='/lightning/r/PRM_AccountBenefitAssociation__c/'+memHist.ParentId+'/view';
                
                singHistAcc.icon ='utility:switch';
                singHistAcc.iconArr = 'utility:record_create';
                singHistAcc.iconDwm = 'utility:down';
                singHistAcc.objectname = 'Account';
                singHistAcc.createddate = acc.createddate;
                singHistAcc.title = singHistAcc.linkDescriptionStart ;
                
                listHist.add(singHistAcc); 
                
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
                    List<PRM_Account_Contact_Relationship__c> contactResult = new List<PRM_Account_Contact_Relationship__c>();
                    //List<PRM_Account_Contact_Relationship__History> contactResult=[Select ParentId, id, createddate, field, oldvalue, newvalue, isdeleted from PRM_Account_Contact_Relationship__history where (field='created' or field='PRM_InActive_Ind__c' or field='PRM_Relationship_Id__c') and parentid in :contactParentID order by createddate desc];
                     contactResult=[select id,PRM_Contact_Id__r.Name,PRM_Relationship_Id__r.Name, (Select ParentId, id, createddate, createdby.name, field, oldvalue, newvalue, isdeleted from histories where (field='created' or field='PRM_InActive_Ind__c' or field='PRM_Relationship_Id__c') order by id desc ) from PRM_Account_Contact_Relationship__c  where id in :contactParentID order by id desc ];
                    System.debug('ani'+contactResult);
                     
                    if(contactResult.size()>0){
                        for(PRM_Account_Contact_Relationship__c con: contactResult)
                        {
                            System.debug('con'+con.histories);
                            for(PRM_Account_Contact_Relationship__History memHist :con.histories){
                                AccHistory singHist = new AccHistory();
                                if(memHist.field == 'PRM_Relationship_Id__c' && (memHist.NewValue == 'Primary Contact' || memHist.NewValue == 'Works for')){
                                    //<strong>Contact <a href="{!'/lightning/r/PRM_Account_Contact_Relationship__c/'+arc.ParentId+'/view'}" target="_blank">{!v.activity.contactName}</a> is changed from '{!arc.OldValue}' to '{!arc.NewValue}' by {!arc.CreatedBy.Name} </strong>
                                    singHist.linkDescriptionStart = 'Contact ';
                                    singHist.linkDescription = 'is changed from ' +memHist.OldValue+' to '+memHist.NewValue+' by'+ memHist.CreatedBy.Name; 
                                    singHist.linkLabel = con.PRM_Contact_Id__r.Name;
                                    singHist.link ='/lightning/r/PRM_Account_Contact_Relationship__c/'+memHist.ParentId+'/view'; 
                                    singHist.icon ='utility:switch';
                                    singHist.iconArr = 'utility:adduser';
                                    singHist.iconDwm = 'utility:down';
                                    singHist.objectname = 'AccountContactRelationship';
                                    singHist.createddate = memHist.createddate;
                                    singHist.title = singHist.linkDescriptionStart+singHist.linkLabel+singHist.linkDescription ;
                                    listHist.add(singHist); 
                                }
                                if(memHist.field  == 'PRM_InActive_Ind__c' && memHist.NewValue == 'true' ){
                                    //<strong>Contact <a href="{!'/lightning/r/PRM_Account_Contact_Relationship__c/'+arc.ParentId+'/view'}" target="_blank">{!v.activity.contactName}</a> is removed as '{!v.activity.contactRelation}' from the account by {!arc.CreatedBy.Name}</strong>
                                    singHist.linkDescriptionStart = 'Contact ';
                                    singHist.linkDescription = ' is removed as '+con.PRM_Relationship_Id__r.Name+' from the account by '+memHist.CreatedBy.Name;
                                    singHist.linkLabel =con.PRM_Contact_Id__r.Name;
                                    singHist.link ='/lightning/r/PRM_Account_Contact_Relationship__c/'+memHist.ParentId+'/view'; 
                                    singHist.icon ='utility:switch';
                                    singHist.iconArr = 'utility:adduser';
                                    singHist.iconDwm = 'utility:down';
                                    singHist.objectname = 'AccountContactRelationship';
                                    singHist.createddate = memHist.createddate;
                                    singHist.title = singHist.linkDescriptionStart+singHist.linkLabel+singHist.linkDescription ;
                                    listHist.add(singHist); 
                                }
                                if(memHist.field  == 'created'){
                                    //<strong>Contact <a href="{!'/lightning/r/PRM_Account_Contact_Relationship__c/'+arc.ParentId+'/view'}" target="_blank">{!v.activity.contactName}</a> is added as '{!v.activity.contactRelation}' to the Account by {!arc.CreatedBy.Name}</strong>
                                    singHist.linkDescriptionStart = 'Contact ';
                                    singHist.linkDescription = ' is added as '+con.PRM_Relationship_Id__r.Name+' to the account by '+memHist.CreatedBy.Name;
                                    singHist.linkLabel =con.PRM_Contact_Id__r.Name;
                                    singHist.link ='/lightning/r/PRM_Account_Contact_Relationship__c/'+memHist.ParentId+'/view'; 
                                    singHist.icon ='utility:switch';
                                    singHist.iconArr = 'utility:adduser';
                                    singHist.iconDwm = 'utility:down';
                                    singHist.objectname = 'AccountContactRelationship';
                                    singHist.createddate = memHist.createddate;
                                    singHist.title = singHist.linkDescriptionStart+singHist.linkLabel+singHist.linkDescription ;
                                    listHist.add(singHist); 
                                }
                                
                            }
                        }
                    } 
                }
                
                if(benefitParentID.size()>0)
                {
                    List<PRM_AccountBenefitAssociation__c> benefitResult = new List<PRM_AccountBenefitAssociation__c>();
                    //List<PRM_AccountBenefitAssociation__History> benefitResult=[Select ParentId, id, createddate, field, oldvalue, newvalue, isdeleted from PRM_AccountBenefitAssociation__History where (field='created' or field='PRM_Status_Nm__c') and parentid in :benefitParentID order by createddate desc];
                     benefitResult= [Select id,PRM_Partner_Benefit_Id__r.Name,(Select ParentId, id, createddate,createdby.name, field, oldvalue, newvalue, isdeleted from histories where (field='created' or field='PRM_Status_Nm__c') order by id desc ) from PRM_AccountBenefitAssociation__c  where id in:benefitParentID  order by id desc];
                    
                   
                    if(benefitResult.size()>0){
                        for(PRM_AccountBenefitAssociation__c ben: benefitResult)
                        {
                             System.debug('ben'+ben.histories);
                            for(PRM_AccountBenefitAssociation__History memHist  : ben.histories ){
                                AccHistory singHist = new AccHistory();
                                if(memHist.field == 'created'){
                                    // <strong>Account got a new  Benefit- <a href="{!'/lightning/r/PRM_AccountBenefitAssociation__c/'+aba.ParentId+'/view'}" target="_blank">'{!v.activity.benefitName}'</a> by {!aba.CreatedBy.Name}</strong>
                                    singHist.linkDescriptionStart = 'Account got a new  Benefit - ';
                                    singHist.linkDescription =' by '+ memHist.CreatedBy.Name;
                                    singHist.linkLabel = ben.PRM_Partner_Benefit_Id__r.Name;
                                    singHist.link ='/lightning/r/PRM_AccountBenefitAssociation__c/'+memHist.ParentId+'/view';
                                    singHist.icon ='utility:switch';
                                    singHist.iconArr = 'utility:jump_to_top';
                                    singHist.iconDwm = 'utility:down';
                                    singHist.objectname = 'AccountBenefitAssociation';
                                    singHist.createddate = memHist.createddate;
                                    singHist.title = singHist.linkDescriptionStart+singHist.linkLabel+singHist.linkDescription ;
                                    listHist.add(singHist); 
                                }
                                if(memHist.field  == 'PRM_Status_Nm__c' && memHist.NewValue == 'Inactive' ){
                                    //<strong>Benefit <a href="{!'/lightning/r/PRM_AccountBenefitAssociation__c/'+aba.ParentId+'/view'}" target="_blank">'{!v.activity.benefitName}'</a> is removed from the account by {!aba.CreatedBy.Name}</strong>
                                    singHist.linkDescriptionStart = 'Benefit ';
                                    singHist.linkDescription = ' is removed from the account by '+memHist.CreatedBy.Name;
                                    singHist.linkLabel = ben.PRM_Partner_Benefit_Id__r.Name;
                                    singHist.link ='/lightning/r/PRM_AccountBenefitAssociation__c/'+memHist.ParentId+'/view';
                                    singHist.icon ='utility:switch';
                                    singHist.iconArr = 'utility:jump_to_top';
                                    singHist.iconDwm = 'utility:down';
                                    singHist.objectname = 'AccountBenefitAssociation';
                                    singHist.createddate = memHist.createddate;
                                    singHist.title = singHist.linkDescriptionStart+singHist.linkLabel+singHist.linkDescription ;
                                    listHist.add(singHist); 
                                }
                                
                            }
                        }
                    }
                }
                
                if(memberParentID.size()>0)
                {
                    List<PRM_AccountChannelMembership__c> memberResult = new List<PRM_AccountChannelMembership__c>();
                    //List<PRM_AccountChannelMembership__History> memberResult=[Select ParentId, id, createddate, field, oldvalue, newvalue, isdeleted from PRM_AccountChannelMembership__history where (field='created' or field='PRM_Channel_Program_Level_Id__c') and parentId in:memberParentID order by createddate desc];
                      memberResult=[Select id,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,(Select ParentId, id, createddate,createdby.name, field, oldvalue, newvalue, isdeleted from histories where (field='created' or field='PRM_Channel_Program_Level_Id__c') order by id desc  ) from PRM_AccountChannelMembership__c where id in:memberParentID order by id desc];
                   
                    if(memberResult.size()>0){
                        for(PRM_AccountChannelMembership__c mem: memberResult)
                        {
                            System.debug('mem'+mem.histories);
                            for(PRM_AccountChannelMembership__History memHist:mem.histories){
                                AccHistory singHist = new AccHistory();
                                if(memHist.field == 'created'){
                                    // <strong><a href="{!'/lightning/r/PRM_AccountChannelMembership__c/'+acm.ParentId+'/view'}" target="_blank">'IPA Membership'</a> is added to Account in '{!v.activity.partnerRoleName}' role by {!acm.CreatedBy.Name}</strong>
                                    singHist.linkDescriptionStart = '';
                                    singHist.linkDescription =' is added to Account in '+mem.PRM_Partner_Role__c+' role by '+ memHist.CreatedBy.Name;
                                    singHist.linkLabel = 'IPA Membership';
                                    singHist.link ='/lightning/r/PRM_AccountChannelMembership__c/'+memHist.ParentId+'/view';      
                                    singHist.icon ='utility:switch';
                                    singHist.iconArr = 'utility:ribbon';
                                    singHist.iconDwm = 'utility:down';
                                    singHist.objectname = 'AccountChannelMembership';
                                    singHist.createddate = memHist.createddate;
                                    singHist.title = singHist.linkDescriptionStart+singHist.linkLabel+singHist.linkDescription ;
                                    listHist.add(singHist);
                                }
                                if(memHist.field  == 'PRM_Channel_Program_Level_Id__c' && (memHist.newvalue == 'Gold'|| memHist.newvalue == 'Titanium'|| memHist.newvalue == 'Platinum' ) ){
                                    // <strong>Account got upgraded to <a href="{!'/lightning/r/PRM_AccountChannelMembership__c/'+acm.ParentId+'/view'}" target="_blank">'{!acm.NewValue}'</a> Tier in '{!v.activity.partnerRoleName}' role by {!acm.CreatedBy.Name}</strong>
                                    singHist.linkDescriptionStart = 'Account got upgraded to ';
                                    singHist.linkDescription = ' Tier in '+mem.PRM_Partner_Role__c+' role by '+memHist.CreatedBy.Name;
                                    singHist.linkLabel = String.valueOf(memHist.NewValue);
                                    singHist.link ='/lightning/r/PRM_AccountChannelMembership__c/'+memHist.ParentId+'/view';      
                                    singHist.icon ='utility:switch';
                                    singHist.iconArr = 'utility:ribbon';
                                    singHist.iconDwm = 'utility:down';
                                    singHist.objectname = 'AccountChannelMembership';
                                    singHist.createddate = memHist.createddate;
                                    singHist.title = singHist.linkDescriptionStart+singHist.linkLabel+singHist.linkDescription ;
                                    listHist.add(singHist);
                                }
                                
                            }
                            // historyData.add(new History(mem));
                        }
                    }
                } 
                accHistoryList.objectName= 'Account';
                accHistoryList.accHist = listHist;
                if(!accHistoryList.accHist.isEmpty()){
                    accHistoryList.accHist.sort();
                }
                
                
            }
        }
        return accHistoryList;
    }
    
    
    public class History  {
        
        // @AuraEnabled  public Id id { get; set; }
        
        @AuraEnabled public String objectName{get; set;}
        @AuraEnabled public List<AccHistory> accHist {get; set;}
        //@AuraEnabled public string recordName {get; set;}
        
        // @AuraEnabled public string  contactName{get; set;}
        // @AuraEnabled public string  benefitName{get; set;}
        // @AuraEnabled public string partnerRoleName{get; set;}
        // @AuraEnabled public string partnerTierName{get; set;}
        // @AuraEnabled public string contactRelation{get; set; }
        // @AuraEnabled public string accountUserName{get; set; }
        
        
        
    }
    public class AccHistory implements Comparable{
        
        @AuraEnabled public datetime createddate { get; set; }
        //  @AuraEnabled public date  dateSort { get; set; }
        @AuraEnabled public string objectname  { get; set; }
        @AuraEnabled public string  linkDescription{get; set;}
        @AuraEnabled public string linkDescriptionStart{get; set;}
        @AuraEnabled public string  linkLabel{get; set;}
        @AuraEnabled public string  link{get; set;}
        @AuraEnabled public string  icon{get; set;}
        @AuraEnabled public string iconArr{get; set;}
        @AuraEnabled public string  iconDwm{get; set;}
        @AuraEnabled public string  title{get; set;}
        
        
        public Integer compareTo(Object objToCompare) {
            AccHistory that = (AccHistory)objToCompare;
            if(this.createddate == that.createddate){
                return 0;
            } else if(this.createddate > that.createddate){
                return -1;
            } else {
                return 1;
            }
            
        } 
    }
}