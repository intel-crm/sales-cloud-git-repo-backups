/**************************************************************************************
Apex Class Name : PMP_Acct_Grp_Mbr_TriggerHandler
Version     : 1.0 
Created Date: 24th June, 2019
Description : 
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Usha                 24/06/2019               Original Version

*Anupam Agarwal             12/08/2019               Added toggleIsPAGMember method to set
the isPAGMember check on the Account
*Anupam Agarwal             12/08/2019               Added beforeUpdate and beforeInsert methods
to handle the MDA indicator and duplicate records related validations.
*Akshay More [Draco]        21-09-2021              Added condition to avoid clearing OPID at Account if non-Active Core_Account_Group_Member__c is deleted
*************************************************************************************/
public without sharing class PMP_Acct_Grp_Mbr_TriggerHandler {
    
    public static Map<Id,sObject> objectsToInsert = new Map<Id,sObject>();
    public static Boolean objectsToInsertCounter = false;
    
    public static Map<Id,sObject> objectsToUpdate = new Map<Id,sObject>();
    public static Boolean objectsToUpdateCounter = false;
    public static boolean isFirstRunRollUpDown = true;
    public static boolean isFirstUpdateRunRollUpDown = true;    
    
    
    
    public static Map<Id,sObject> objectsToDelete = new Map<Id,sObject>();
    public static Boolean objectsToDeleteCounter = false;
    
    public static void afterMethod(List<Core_Account_Group_Member__c> oldList, List<Core_Account_Group_Member__c> newList){
        
        if(Trigger.isAfter){
            
            if (Trigger.isInsert || Trigger.isUpdate){
                
                System.debug(' ++++++++++++++++ Method++++++ =' + newList);
                Set<Id> accId=new Set<Id>();
                List<String> lstEntitlementIds = new List<String>();
                
                for(Core_Account_Group_Member__c ce: newList){
                    accId.add(ce.Core_Intel_Account_Id__c);
                }
                
                if(accId !=null){
                    
                    List<Contact> conList = [Select Id  from Contact  where AccountId  IN :accId];
                    Set<ID> conId = new Set<ID>();
                    Set<ID> partneracctIds=new Set<ID>();
                    
                    for (Contact conRec : conList) {
                        conId.add(conRec.Id);
                    }
                    
                    List<Core_Entitlement__c> entitlementDetails = new List<Core_Entitlement__c>();
                    String Core_Entitlement_Id_Label = System.Label.PMP_External_Entitlement_Ids;
                    
                    if(!Test.isRunningTest()){
                        lstEntitlementIds = Core_Entitlement_Id_Label.split(';');
                        
                    }else{
                        //Querying Entitlement Detail
                        entitlementDetails = [SELECT Id, Name, Core_Display_Name__c FROM Core_Entitlement__c];
                        for(Core_Entitlement__c coreEntitlement : entitlementDetails){
                            lstEntitlementIds.add(coreEntitlement.Id);
                        }
                    }
                    
                    List<Core_Contact_Entitlement__c> conEnt =[Select Core_Entitlement_Id__c from Core_Contact_Entitlement__c 
                                                               where Core_Contact_Id__c IN : conId 
                                                               AND Core_Entitlement_Id__c IN :lstEntitlementIds];
                    
                    
                    //if(!conEnt.isEmpty()){
                    System.debug('Trigger.isInsert || Trigger.isUpdate > conEnt = ' + conEnt);
                    List<Core_Account_Group_Member__c>  allPartnerAcc = [SELECT Id, Core_Partner_Account_Id__c,
                                                                         Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c 
                                                                         WHERE Core_Intel_Account_Id__c IN:accId ];
                    
                    for(Core_Account_Group_Member__c partneraccount : allPartnerAcc){                                   
                        partneracctIds.add(partneraccount.Core_Partner_Account_Id__c);
                    }//end of for loop
                    
                    List<Account> Acc=[Select Core_PMP_Membership_Change_Ind__c from Account where Id IN :partneracctIds];
                    List<Account> accToUpdate = new List<Account>();
                    
                    for(Account accRec : Acc){
                        if(accRec.Core_PMP_Membership_Change_Ind__c == false){
                            accRec.Core_PMP_Membership_Change_Ind__c =true ;
                            accToUpdate.add(accRec);      
                        } 
                    }//end of for loop
                    
                    update accToUpdate ; 
                    
                    //}//end of if
                    
                }//end of if
            }// end of isInsert and isUpdate
        }// end of isAfter
    }// end of afterMethod
    /** Remove One Partner Id from Intel Account when Inactive Indicator is checked and update One partner Id to Intel Account when Inactive Indicator is unchecked**/
    //Updated by Manikanta
       public static void populateOnePartnerIdOnIntelAccount(List<Core_Account_Group_Member__c> lstOfOPIDGrpMbr,  Map<Id, Core_Account_Group_Member__c> mapOldOpidGrmMbr){
           
           List<Account> lstAccToUpdate = new List<Account>();
           
           for(Core_Account_Group_Member__c agm : lstOfOPIDGrpMbr) {
               
               if(mapOldOpidGrmMbr == null || 
                  (agm.Core_Partner_Account_Id__c != mapOldOpidGrmMbr.get(agm.id).Core_Partner_Account_Id__c ||
                   agm.Core_Intel_Account_Id__c != mapOldOpidGrmMbr.get(agm.id).Core_Intel_Account_Id__c || 
                   agm.Core_Inactive_Ind__c != mapOldOpidGrmMbr.get(agm.id).Core_Inactive_Ind__c )) {
                       
                       Account acc = new Account();
                       acc.id = agm.Core_Intel_Account_Id__c;
                       acc.Core_IPA_One_Partner_Id__c = agm.Core_Inactive_Ind__c ? '' : agm.Core_Partner_Account_Id__c;
                       if(!lstAccToUpdate.contains(acc)){
                           lstAccToUpdate.add(acc);      
                       }
                   }
           }
           
           if(!lstAccToUpdate.isEmpty()){
               Database.update(lstAccToUpdate, false); 
           }
       }
    
   /** Remove One Partner Id from Intel Account when OPId Group is deleted ***/
    //Updated by Manikanta
    //Updated by Akshay to avoid clearing OPID at Account if non-Active Core_Account_Group_Member__c is deleted [21-09-2021]
    public static void removeOnePartIdFromIntelAccOnDeletion(List<Core_Account_Group_Member__c> lstOfOPIDGrpMbr){
        List<Account> lstAccToUpdate = new List<Account>();
        for(Core_Account_Group_Member__c pag : lstOfOPIDGrpMbr){
            if(pag.Core_Inactive_Ind__c == false){ //Condition added by Akshay 21-09-2021
                Account acc = new Account();
                acc.id = pag.Core_Intel_Account_Id__c;
                acc.Core_IPA_One_Partner_Id__c='';
                lstAccToUpdate.add(acc);
                Account pagAcc = new Account();
                pagAcc.Id = pag.Core_Partner_Account_Id__c;
                pagAcc.Core_PMP_Membership_Change_Ind__c = true;
                lstAccToUpdate.add(pagAcc);
            }
        }  
        
        if(lstAccToUpdate.size()>0){
            Database.update(lstAccToUpdate, false); 
        }
    }
    
    public static void beforeMethod(List<Core_Account_Group_Member__c> oldList, List<Core_Account_Group_Member__c> newList){
        
        //if (Trigger.isDelete){
        
        Set<Id> accId=new Set<Id>();
        List<String> lstEntitlementIds = new List<String>();
        for(Core_Account_Group_Member__c ce: oldList){
            accId.add(ce.Core_Intel_Account_Id__c);
        }
        
        if(accId !=null){
            List<Contact> conList = [Select Id  from Contact  where AccountId IN :accId];   
            Set<ID> conId = new Set<ID>();
            Set<ID> partneracctIds=new Set<ID>();
            for (Contact conRec : conList) {
                conId.add(conRec.Id);
            }
            
            List<Core_Entitlement__c> entitlementDetails = new List<Core_Entitlement__c>();
            String Core_Entitlement_Id_Label = System.Label.PMP_External_Entitlement_Ids;
            
            if(!Test.isRunningTest()){
                lstEntitlementIds = Core_Entitlement_Id_Label.split(';');
            }else{
                //Querying Entitlement Detail
                entitlementDetails = [SELECT Id, Name, Core_Display_Name__c FROM Core_Entitlement__c];
                for(Core_Entitlement__c coreEntitlement : entitlementDetails){
                    lstEntitlementIds.add(coreEntitlement.Id);
                }
            }
            
            List<Core_Contact_Entitlement__c> conEnt =[Select Core_Entitlement_Id__c from Core_Contact_Entitlement__c 
                                                       where Core_Contact_Id__c IN : conId 
                                                       AND Core_Entitlement_Id__c = :lstEntitlementIds];
            
            //if(!conEnt.isEmpty()){
            
            System.debug('conEnt = ' + conEnt);
            
            List<Core_Account_Group_Member__c>  allPartnerAcc = [SELECT Id, Core_Partner_Account_Id__c,
                                                                 Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c 
                                                                 WHERE Core_Intel_Account_Id__c IN :accId 
                                                                 AND Core_Inactive_Ind__c = true];
            
            for(Core_Account_Group_Member__c partneraccount : allPartnerAcc){                                           
                partneracctIds.add(partneraccount.Core_Partner_Account_Id__c);
            }
            
            List<Account> Acc=[Select Core_PMP_Membership_Change_Ind__c from Account where Id IN :partneracctIds];
            List<Account> accToUpdate = new List<Account>();
            
            for(Account accRec : Acc){
                if(accRec.Core_PMP_Membership_Change_Ind__c == false){     
                    accRec.Core_PMP_Membership_Change_Ind__c = true ;
                    accToUpdate.add(accRec);      
                }                       
            }
            update accToUpdate;   
            //}
        }                
        //}
    }
    public static void checkMDAIndicator(List<Core_Account_Group_Member__c> PAGMNewList, Map<Id, Core_Account_Group_Member__c> PAGMOldMap)
    {   
        Set<String> accountIds = new Set<String>();
        Set<String> recordsToInactivate = new Set<String>();
        Set<String> idSet= new Set<String>();
        Set<Id> activeIntelIdSet= new Set<Id>();
        List<Account> accToUpsert = new List<Account>();
        List<Core_Account_Group_Member__c> pagmList = new List<Core_Account_Group_Member__c>();
        List<Id> pagmIntelActiveRecords = new List<Id>();
        for(Core_Account_Group_Member__c pagm:PAGMNewList){
            //To check if the Update Operation is performed
            if(pagm.Id !=null){
                //To check if the Intel Account Lookup is updated
                Core_Account_Group_Member__c pagmOldValue = PAGMOldMap.get(pagm.Id);

                //Checking if Non-MDA is updated to MDA record             
                if(pagm.Core_MDA_Ind__c ==true && (pagmOldValue.Core_MDA_Ind__c != pagm.Core_MDA_Ind__c)) {
                    pagmList.add(pagm);
                    accountIds.add(pagm.Core_Partner_Account_Id__c);
                }
                //Checking if MDA is updated to Non-MDA record   
                if(pagm.Core_MDA_Ind__c !=true && (pagmOldValue.Core_MDA_Ind__c != pagm.Core_MDA_Ind__c)) {
                    pagmList.add(pagm);
                    accountIds.add(pagm.Core_Partner_Account_Id__c);
                }
                //To check if the same Intel Account is active with more than 1 Partner Account
                if(pagm.Core_Inactive_Ind__c == false && pagm.Core_Inactive_Ind__c != pagmOldValue.Core_Inactive_Ind__c){
                    pagmIntelActiveRecords.add(pagm.Core_Intel_Account_Id__c);
                }
                //Validation to restrict the user from modifying the Inactive record to a MDA 
                if(pagm.Core_MDA_Ind__c == true && (pagmOldValue.Core_MDA_Ind__c != pagm.Core_MDA_Ind__c) && pagm.Core_Inactive_Ind__c == true) { 
                    pagm.addError(System.label.PRM_checkMDA_Error); 
                }
                //To check if the Inactive Indicator is set for MDA Members
                if(pagm.Core_MDA_Ind__c == true && (pagmOldValue.Core_Inactive_Ind__c != pagm.Core_Inactive_Ind__c) && pagm.Core_Inactive_Ind__c == true) {
                    recordsToInactivate.add(pagm.Core_Intel_Account_Id__c);
                }
                
                //To check if Inactive Indicator needs to be set for Non MDA Members
                else if(pagm.Core_MDA_Ind__c != true && (pagmOldValue.Core_Inactive_Ind__c != pagm.Core_Inactive_Ind__c) && pagm.Core_Inactive_Ind__c == true){
                    recordsToInactivate.add(pagm.Core_Intel_Account_Id__c);
                }
            }
            //To check if the Insert Operation is performed
            else{
                //To check if MDA is set while Record creation;
                if (!pagm.Core_Inactive_Ind__c) {
                    pagmIntelActiveRecords.add(pagm.Core_Intel_Account_Id__c);
                }
                if(pagm.Core_MDA_Ind__c == true){
                    pagmList.add(pagm);
                    accountIds.add(pagm.Core_Partner_Account_Id__c);
                }
                //To restrict the user from Creating an Inactive PAG Record
                if(pagm.Core_Inactive_Ind__c == true){
                    pagm.addError(System.label.PRM_Inactive_While_Creation_Error);
                }
            }
        }
        //To check if a particular Intel account is Active in only one PAG
        if(pagmIntelActiveRecords.size()>0){
            for(Core_Account_Group_Member__c intelAccRecords : [Select id, Core_Intel_Account_Id__c,Core_Inactive_Ind__c from Core_Account_Group_Member__c where Core_Intel_Account_Id__c in:pagmIntelActiveRecords AND Core_Inactive_Ind__c=false]){
                activeIntelIdSet.add(intelAccRecords.Core_Intel_Account_Id__c);
            }
            if(!activeIntelIdSet.IsEmpty()){
                for(Core_Account_Group_Member__c pagmRecord : PAGMNewList){
                    if(activeIntelIdSet.contains(pagmRecord.Core_Intel_Account_Id__c)){
                        pagmRecord.addError(System.label.PRM_Multiple_PAG_Error); 
                    }
                }
            } 
        }
        
        //To check if Only one MDA is present for a Partner Account Group
        if(pagmList.size()>0){
            List<Core_Account_Group_Member__c> pagmRecordList = [Select Id, Core_Partner_Account_Id__c, Core_MDA_Ind__c from Core_Account_Group_Member__c where Core_Partner_Account_Id__c in :accountIds and Core_MDA_Ind__c = true];
            for(Core_Account_Group_Member__c pag : pagmRecordList){
                idSet.add(pag.id);
            }
            for(Core_Account_Group_Member__c pagmRecord : PAGMNewList){
                if(pagmRecord.Id !=null){
                    
                    if(pagmRecordList.size()>=1 && !idSet.contains(pagmRecord.id)){pagmRecord.addError(System.label.PRM_One_MDA_In_PAG);
                                                                                  }else if(pagmRecordList.size() >= 1  && idSet.contains(pagmRecord.id)) {
                                                                                      //To check if the Last MDA Record is inactivated for a PAG                                                                  
                                                                                      pagmRecord.addError(System.label.PRM_Restrict_Last_MDA_Removal);
                                                                                  }
                }else{
                    //To check if Only one MDA is present for a Partner Account Group
                    if(pagmRecordList.size()>=1){pagmRecord.addError(System.label.PRM_One_MDA_In_PAG);
                                                }
                }
            }
        }
        //To check if a MDA Record is inactivated for PAG
        if(recordsToInactivate.size()>0){
            List<Core_Account_Group_Member__c> pagmRecordList = [Select Id, Core_Intel_Account_Id__c, Core_MDA_Ind__c, Core_Inactive_Ind__c from Core_Account_Group_Member__c where Core_Intel_Account_Id__c in :recordsToInactivate and Core_MDA_Ind__c = true];
            if(pagmRecordList.size()>0){
                //for(Core_Account_Group_Member__c pagm:PAGMNewList){pagm.addError(System.label.PRM_Restrict_MDA_Removal);
                                                                  
            }
            List<Account> intelAccRecords = [Select id, name, Core_Is_PAG_Member_Ind__c from Account where id in:recordsToInactivate];
            if(intelAccRecords.size()>0){
                for(Account acc : intelAccRecords){
                    acc.Core_Is_PAG_Member_Ind__c = false;
                    accToUpsert.add(acc); 
                }
            }
            if(accToUpsert.size()>0){
                update accToUpsert;
            }
        }
    }
    
    public static void toggleIsPAGMember(List<Core_Account_Group_Member__c> PAGMNewList, Map<Id, Core_Account_Group_Member__c> PAGMOldMap){
        List<Id> pagmIntelAccRecords = new List<Id>();
        List<Account> accToUpsert = new List<Account>();
        Set<Id> oldIntelAccounts = new Set<Id>();
        for(Core_Account_Group_Member__c pagm:PAGMNewList){
            if(PAGMOldMap == null){
                pagmIntelAccRecords.add(pagm.Core_Intel_Account_Id__c);
            }else{
                Core_Account_Group_Member__c pagmOldValue = PAGMOldMap.get(pagm.Id);
                if(pagmOldValue.Core_Inactive_Ind__c != pagm.Core_Inactive_Ind__c && pagm.Core_Inactive_Ind__c == true){
                    oldIntelAccounts.add(pagmOldValue.Core_Intel_Account_Id__c);
                } else if(pagmOldValue.Core_Inactive_Ind__c != pagm.Core_Inactive_Ind__c && pagm.Core_Inactive_Ind__c == false){
                    pagmIntelAccRecords.add(pagm.Core_Intel_Account_Id__c);
                } else if (pagm.Core_Intel_Account_Id__c !=pagmOldvalue.Core_Intel_Account_Id__c){
                    oldIntelAccounts.add(pagmOldValue.Core_Intel_Account_Id__c);
                    pagmIntelAccRecords.add(pagm.Core_Intel_Account_Id__c);
                }
            }
        }
        // Setting IsPAGMember to true for Intel Account when the PAG Member record is created
        if(pagmIntelAccRecords.size()>0){
            List<Account> intelAccRecords = [Select id,name, Core_Is_PAG_Member_Ind__c from Account where id in:pagmIntelAccRecords ];
            if(intelAccRecords.size()>0){
                for(Account acc : intelAccRecords){
                    System.debug('Hi from created');
                    acc.Core_Is_PAG_Member_Ind__c = true;
                    accToUpsert.add(acc); 
                }
            }
        }
        // Setting IsPAGMember to false when the Intel Account is changed on PAG Member record
        if(oldIntelAccounts.size()>0){
            List<Account> oldIntelAccRecords = [Select id,name, Core_Is_PAG_Member_Ind__c from Account where id in:oldIntelAccounts ];
            if(oldIntelAccRecords.size()>0){
                for(Account acc : oldIntelAccRecords){
                    System.debug('Hi from changed');
                    acc.Core_Is_PAG_Member_Ind__c = false;
                    accToUpsert.add(acc); 
                }
            }
        }
        if(accToUpsert.size()>0){
            update accToUpsert;
        }
    }
    public static void PopulateLegalAgreeOnOPID(List<Core_Account_Group_Member__c> PAGMNewList,Map<Id,Core_Account_Group_Member__c> oldMap){
        Set<String> LocationAccntsIdset = new Set<String>();// to store location accnts
        Set<id> OPIDAndLocationAccntsMap = new Set<id>();// to store OPID accnts
        List<Core_Account_Group_Member__c> OPIDmemberlist = new List<Core_Account_Group_Member__c>(); // to store PAGM id
        Set<ID> OPIDsWithLegalAggrSet= New Set<ID>();
        Map<id,id> OPIDWithoutLegalAggrLocMap= New Map<id,id>();
        Map<id,PRM_AccountLegalAgreemntAssociation__c> OPIDLegalAggrMap= New Map<id,PRM_AccountLegalAgreemntAssociation__c>();
        List<PRM_AccountLegalAgreemntAssociation__c> FinalLegalAggrList= New List<PRM_AccountLegalAgreemntAssociation__c>();
        
        for(Core_Account_Group_Member__c PAGM:PAGMNewList) {
            Core_Account_Group_Member__c PAGOld ; //getting old values from map
            if(oldMap!=null && oldMap.size()>0)
            { PAGOld = (Core_Account_Group_Member__c) oldMap.get(PAGM.id) ;}
            if((oldMap==null) || ((oldMap!=null && oldMap.size()>0) &&((PAGOld.Core_Inactive_Ind__c==true) && (PAGOld.Core_Inactive_Ind__c != PAGM.Core_Inactive_Ind__c))))
            {
                LocationAccntsIdset.add(PAGM.Core_Intel_Account_Id__c);  // adding specialties to a set
                OPIDAndLocationAccntsMap.add(PAGM.Core_Partner_Account_Id__c);
                OPIDmemberlist.add(PAGM);
                system.debug('LocationAccntsIdset'+LocationAccntsIdset);
                system.debug('OPIDAndLocationAccntsMap'+OPIDAndLocationAccntsMap);
            }
        }
        if(!OPIDAndLocationAccntsMap.isEmpty()){
            system.debug('OPIDAndLocationAccntsMap'+OPIDAndLocationAccntsMap);
            for(PRM_AccountLegalAgreemntAssociation__c ala :[select id, PRM_Account_Id__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c from PRM_AccountLegalAgreemntAssociation__c where PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c='IPA_TANDC'AND PRM_Account_Id__c IN:OPIDAndLocationAccntsMap]){
                if(OPIDAndLocationAccntsMap.contains(ala.PRM_Account_Id__c)){
                    OPIDsWithLegalAggrSet.add(ala.PRM_Account_Id__c);
                    system.debug('OPIDsWithLegal aggrements'+OPIDsWithLegalAggrSet); 
                }
            }
            
        }
        for(Core_Account_Group_Member__c PAGMrec:OPIDmemberlist){
            if(!OPIDsWithLegalAggrSet.contains(PAGMrec.Core_Partner_Account_Id__c)){
                OPIDWithoutLegalAggrLocMap.put(PAGMrec.Core_Intel_Account_Id__c,PAGMrec.Core_Partner_Account_Id__c); 
                system.debug('OPIDWithoutLegalAggrLocMap'+OPIDWithoutLegalAggrLocMap);  
            }
        }
        if(!OPIDWithoutLegalAggrLocMap.isEmpty()){ 
            for(PRM_AccountLegalAgreemntAssociation__c ala :[select id,PRM_Contact__c, PRM_Account_Id__c,PRM_Agreement_Sign_Dt__c,PRM_Partner_Agreement_Id__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c,PRM_InActive_Ind__c,PRM_Notes_Txt__c,PRM_Account_Id__r.name from PRM_AccountLegalAgreemntAssociation__c where PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c='IPA_TANDC' AND PRM_Account_Id__c IN:OPIDWithoutLegalAggrLocMap.keyset() Order by Createddate Asc]){
                system.debug('ALA record'+ala);
                PRM_AccountLegalAgreemntAssociation__c OPIDAla = new PRM_AccountLegalAgreemntAssociation__c();
                 
                OPIDAla.PRM_Account_Id__c= OPIDWithoutLegalAggrLocMap.get(ala.PRM_Account_Id__c);
                OPIDAla.PRM_Contact__c=ala.PRM_Contact__c;
                OPIDAla.PRM_Agreement_Sign_Dt__c=ala.PRM_Agreement_Sign_Dt__c;
                OPIDAla.PRM_Partner_Agreement_Id__c=ala.PRM_Partner_Agreement_Id__c;
                OPIDAla.PRM_InActive_Ind__c=ala.PRM_InActive_Ind__c;
                OPIDAla.PRM_Notes_Txt__c = 'Terms and Condition acceptance rolled up from the location account' + ' ' + ala.PRM_Account_Id__r.name + ' '+'as part of T&C roll up.';
                if(!OPIDLegalAggrMap.containsKey(OPIDAla.PRM_Account_Id__c)){
                  OPIDLegalAggrMap.put(OPIDWithoutLegalAggrLocMap.get(ala.PRM_Account_Id__c),OPIDAla);  
                }
                
               // FinalLegalAggrList.add(OPIDAla);
            }
        }
        if(!OPIDLegalAggrMap.isEmpty()){
            For(PRM_AccountLegalAgreemntAssociation__c Ala:OPIDLegalAggrMap.values()){
               FinalLegalAggrList.add(Ala); 
            } 
        }
        if(!FinalLegalAggrList.isEmpty()){
            insert(FinalLegalAggrList);
            system.debug('FinalLegalAggrList'+FinalLegalAggrList);
        }
    }
    
    public static void RollUpLocFlagToOPID(List<Core_Account_Group_Member__c> PAGMNewList,Map<Id,Core_Account_Group_Member__c> oldMap){
        Set<id> LocationAccntsIdset = new Set<id>();// to store location accnts
        Set<id> OPIDAndLocationAccnts = new Set<id>();// to store OPID accnts
        List<Core_Account_Group_Member__c> OPIDmemberlist = new List<Core_Account_Group_Member__c>(); // to store PAGM id
        Set<ID> OPIDsWithPrfleRspnse= New Set<ID>();
        Set<String> StringOfQuestions= New Set<String>{'PRM_Component_point','PRM_Branded_Point','PRM_ODM_Whitebox_Point','PRM_Point_Not_Eligible','PRM_Opt_In'};
        Integer Count = 1;
        Set<ID> OPIDAcctValidForRollUp= New Set<ID>();
        Set<ID> OPIDsWithPriorAssociation= New Set<ID>();      
        Set<ID> OPIDsAllRolldown = New Set<ID>();  
        Set<ID> opidAndLocationIds = New Set<ID>();  
        Set<ID> OPIDWithoutPriorAssociation= New Set<ID>(); 
        Set<ID> OPIDtoClearBeforeInsert= New Set<ID>(); 
        Set<ID> OPIDAlrdyAvlbleAtRspnse= New Set<ID>();
        Set<ID> OPIDtoLocRollDownAddntnal= New Set<ID>();
        Set<ID> OPIDRollUpFromLoc= New Set<ID>();
        Set<ID> locationIdsResponseCheck = New Set<ID>();
        Set<ID> locationIntelAccts = New Set<ID>();
        
        Boolean RollDown = false ;
        //   Boolean DisablePointsFlag = false;
        Map<id,Core_Account_Group_Member__c> OPIDsWithOldestLocTemp= New Map<id,Core_Account_Group_Member__c>();
        Map<String,PRM_Profile_Responses__c> responseLimitMap = New Map<String,PRM_Profile_Responses__c>();        
        Map<id,id> OPIDsWithOldestLocMap = New Map<id,id>();
        Map<id,id> locationAndOpidMap = New Map<id,id>();
        Map<id,id> OPIDsWithOutPriorAssociationMap = New Map<id,id>();        
        Map<String,PRM_Profile_Responses__c> ProfileRespnseListforLocMap= New Map<String,PRM_Profile_Responses__c>();
        Map<String,PRM_Profile_Responses__c> ProfileResponseListForRollDownMap= New Map<String,PRM_Profile_Responses__c>();
        Map<String,PRM_Profile_Responses__c> responseLocStringMap = New Map<String,PRM_Profile_Responses__c>();
        Map<String,PRM_Profile_Responses__c> responseOpidStringMap = New Map<String,PRM_Profile_Responses__c>();
        
        List<Core_Account_Group_Member__c> LocationAccountListForRollDown= New List<Core_Account_Group_Member__c>();    
        List<Core_Account_Group_Member__c> LocationIDListToRollDownWithOPID= New List<Core_Account_Group_Member__c>();                               
        List<PRM_Profile_Responses__c> ProfileResponseListForRollDown= New List<PRM_Profile_Responses__c>();    
        List<PRM_Profile_Responses__c> OPIDToDelete= New List<PRM_Profile_Responses__c>();
        List<PRM_Profile_Responses__c> FinalProfileRespnseList= New List<PRM_Profile_Responses__c>();
        List<PRM_Profile_Responses__c> FinalProfileRespnseListRollDown= New List<PRM_Profile_Responses__c>();
        //Map<id,PRM_Profile_Responses__c> FinalProfileRespnseListRollDown = new Map<id,PRM_Profile_Responses__c>();
        //Map<id,PRM_Profile_Responses__c> locResponseClearList = new Map<id,PRM_Profile_Responses__c>();
        List<PRM_Profile_Responses__c> ProfileRespnseListforLoc= New List<PRM_Profile_Responses__c>();
        Map<id,list<PRM_Profile_Responses__c>> allreponsesLocationLevelMap2 = new Map<id,list<PRM_Profile_Responses__c>>();
        Map<id,set<string>> allreponsesLocationLevelMap = new Map<id,set<string>>();  
        List<PRM_Profile_Responses__c> responseOpidLevel = New List<PRM_Profile_Responses__c>();
        List<PRM_Profile_Responses__c> responseLocLevel = New List<PRM_Profile_Responses__c>();
         List<PRM_Profile_Responses__c> locResponseClearList = New List<PRM_Profile_Responses__c>();
        
        String responseQuestions = System.Label.PRM_Response_Questions;
        Set<String> responseQuestionsIdSet = new Set<String>();
        Set<String> responseOpidStringSet = new Set<String>();
        Set<String> responseLocStringSet = new Set<String>();
        
        for(String str: responseQuestions.split(';')){
            responseQuestionsIdSet.add(str);
        }
        system.debug('responseQuestionsIdSet value is '+responseQuestionsIdSet);
        //Iterate the Input
        for(Core_Account_Group_Member__c PAGM:PAGMNewList) {
            Core_Account_Group_Member__c PAGOld ; //getting old values from map
            if(oldMap!=null && oldMap.size()>0)
            { PAGOld = (Core_Account_Group_Member__c) oldMap.get(PAGM.id) ;}
            if((oldMap==null && PAGM.Core_Intel_Partner_Alliance_PartnerGroup__c==true && PAGM.Core_Inactive_Ind__c==false ) || ((oldMap!=null && oldMap.size()>0) &&((PAGOld.Core_Inactive_Ind__c==true) &&  (PAGM.Core_Intel_Partner_Alliance_PartnerGroup__c==true)&&(PAGOld.Core_Inactive_Ind__c != PAGM.Core_Inactive_Ind__c))))
            {
                LocationAccntsIdset.add(PAGM.Core_Intel_Account_Id__c);  // adding specialties to a set
                OPIDAndLocationAccnts.add(PAGM.Core_Partner_Account_Id__c);
                OPIDsAllRolldown.add(PAGM.Core_Partner_Account_Id__c);
                locationAndOpidMap.put(PAGM.Core_Intel_Account_Id__c,PAGM.Core_Partner_Account_Id__c);
                
                OPIDmemberlist.add(PAGM);  
                system.debug('OPIDAndLocationAccntsMap'+OPIDAndLocationAccnts);
            }
        }
        //Query to fetch all the Intel accounts associated with the OPID
        if(!OPIDAndLocationAccnts.isEmpty() && !LocationAccntsIdset.isEmpty() ){
            for(Core_Account_Group_Member__c CagMember :[SELECT Name,Core_Partner_Account_Id__c,Core_Inactive_Ind__c,Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c  WHERE Core_Partner_Account_Id__c IN:OPIDAndLocationAccnts AND Core_Inactive_Ind__c=false AND Core_Intel_Partner_Alliance_PartnerGroup__c=true]){
                // In this below IF condition, we fetch all the Location account that are associated with OPID. If there are any additional Intel account associated with OPID apart from the Trigger.new Loc Id's, then we would say that OPID has had Prior Association
                if(!LocationAccntsIdset.contains(CagMember.Core_Intel_Account_Id__c)){
                    OPIDsWithPriorAssociation.add(CagMember.Core_Partner_Account_Id__c);
                    system.debug('OPIDsWithPriorAssociation '+OPIDsWithPriorAssociation); 
                }
                // The below Map will only have one location Id per OPID. The Location ID would be the first associated Location ID.This would be later used for Rollup. We would roll up the oldest amongst the trigger.new records.
                if(!OPIDsWithOldestLocTemp.containskey(CagMember.Core_Partner_Account_Id__c)){
                    OPIDsWithOldestLocTemp.put(CagMember.Core_Partner_Account_Id__c,CagMember);
                    OPIDsWithOldestLocMap.put(CagMember.Core_Intel_Account_Id__c,CagMember.Core_Partner_Account_Id__c);
                }
                //It will add all the Intel accounts to the below field.  
                //But the below Id set will have all Loc's associated with the account
                locationIntelAccts.add(CagMember.Core_Intel_Account_Id__c);
                LocationIDListToRollDownWithOPID.add(CagMember);
            }           
        }
        
        // The below set will have all the Id's. OPID and Location Ids. This would be used to query profile response so that we only use one SOQL for profile response object.
        opidAndLocationIds.addall(OPIDAndLocationAccnts);  
        opidAndLocationIds.addall(LocationAccntsIdset);  
        system.debug('The vallue of OPIDAndLocationAccnts '+OPIDAndLocationAccnts+'The count is - '+OPIDAndLocationAccnts.size());
        system.debug('The vallue of LocationAccntsIdset - '+LocationAccntsIdset+'Thhe count is   - '+LocationAccntsIdset.size());
        system.debug('The vallue of opidAndLocationIds  - '+opidAndLocationIds+'The coubt is    - '+opidAndLocationIds.size());
        
        // We would get the List of OPID's for which there was no Prior association to Location account         
        for(Core_Account_Group_Member__c PAGMrec:OPIDmemberlist){
            if(!OPIDsWithPriorAssociation.contains(PAGMrec.Core_Partner_Account_Id__c)){
                OPIDWithoutPriorAssociation.add(PAGMrec.Core_Partner_Account_Id__c); 
                system.debug('OPIDWithoutPriorAssociation'+OPIDWithoutPriorAssociation);  
                system.debug('Javo - Valid scenario,there is a new acount created ');
                
            }
        }
        // Using the abive mentioned set, queried the respones object for all the account id's. We would split this on Loc and OPID.
        // This query would only fetch 5 records per account at max since we are dealing with only 5 responses now. This is done to avoid any bad data. If location or OPID has bad data. It will only take 5 records to rollup or rolldown.
        if(!opidAndLocationIds.IsEmpty()){
            for(PRM_Profile_Responses__c  OPIDTemp :[select PRM_Profile_Questions_Id__C, PRM_Profile_Questions_Id__r.PRM_Question_Cd__c ,PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c, PRM_Account_Id__c, PRM_View_History__c, PRM_Response_Txt__c,  PRM_InActive_Ind__c ,PRM_Question_Display_Text__c, PRM_Reason_Text__c, RecordTypeId from PRM_Profile_Responses__c where PRM_Account_Id__c  IN: opidAndLocationIds and PRM_Profile_Questions_Id__r.PRM_Question_Cd__c IN: StringOfQuestions order by createddate desc]){
                if(OPIDTemp != null){
                    // The below IF condition to grt only 5 rsponses per account.
                    if(!responseLimitMap.containskey(OPIDTemp.PRM_Account_Id__c+OPIDTemp.PRM_Question_Display_Text__c)){
                        responseLimitMap.put(OPIDTemp.PRM_Account_Id__c+OPIDTemp.PRM_Question_Display_Text__c,OPIDTemp);
                        if(OPIDAndLocationAccnts.contains(OPIDTemp.PRM_Account_Id__c) && responseQuestionsIdSet.contains(OPIDTemp.PRM_Question_Display_Text__c)) {
                            system.debug('the value of OPID OPIDTemp.PRM_Question_Display_Text__c is '+OPIDTemp.PRM_Question_Display_Text__c);
                            responseOpidLevel.add(OPIDTemp);
                            responseOpidStringSet.add(OPIDTemp.PRM_Account_Id__c+OPIDTemp.PRM_Question_Display_Text__c);
                            responseOpidStringMap.put(OPIDTemp.PRM_Account_Id__c+OPIDTemp.PRM_Question_Display_Text__c,OPIDTemp);
                        }
                        if(LocationAccntsIdset.contains(OPIDTemp.PRM_Account_Id__c) && responseQuestionsIdSet.contains(OPIDTemp.PRM_Question_Display_Text__c)){
                            system.debug('the value of Loc  PRM_Question_Display_Text__c is '+OPIDTemp.PRM_Question_Display_Text__c);
                            responseLocLevel.add(OPIDTemp);
                            responseLocStringSet.add(OPIDTemp.PRM_Account_Id__c+OPIDTemp.PRM_Question_Display_Text__c);
                            responseLocStringMap.put(OPIDTemp.PRM_Account_Id__c+OPIDTemp.PRM_Question_Display_Text__c,OPIDTemp);
                        }  
                    }
                }
                OPIDAlrdyAvlbleAtRspnse.add(OPIDTemp.PRM_Account_Id__c);                   
            }                        
        }
        
        // Just to check if OPID has any flag.
        if(!responseOpidLevel.IsEmpty() && !OPIDWithoutPriorAssociation.IsEmpty()){
            for(PRM_Profile_Responses__c  OPIDTemp : responseOpidLevel){
                if(OPIDWithoutPriorAssociation.contains(OPIDTemp.PRM_Account_Id__c) && responseQuestionsIdSet.contains(OPIDTemp.PRM_Question_Display_Text__c))
                    OPIDAlrdyAvlbleAtRspnse.add(OPIDTemp.PRM_Account_Id__c);                   
            }
        }
        
        // using the above list, filtering the OPID's that have flags and the one's that doesn't
        if( !OPIDWithoutPriorAssociation.IsEmpty()){
            for(ID OPIDRspnse : OPIDWithoutPriorAssociation ){
                if(OPIDAlrdyAvlbleAtRspnse.contains(OPIDRspnse)){
                    OPIDtoLocRollDownAddntnal.add(OPIDRspnse);               
                }else{
                    OPIDRollUpFromLoc.add(OPIDRspnse);
                }         
            }
        }
        
        // In Case of Rollup, it will have the oldest loc account value.
        if(!OPIDRollUpFromLoc.isEmpty()){
            for(id  Opid: OPIDsWithOldestLocTemp.keyset()){
                if(OPIDRollUpFromLoc.contains(Opid)){
                    OPIDsWithOutPriorAssociationMap.put(OPIDsWithOldestLocTemp.get(Opid).Core_Intel_Account_Id__c,Opid);
                }
            }
        }
        
        if(!OPIDsWithOutPriorAssociationMap.isEmpty() && !responseLocLevel.IsEmpty()){
            for(PRM_Profile_Responses__c  prf : responseLocLevel){
                if(OPIDsWithOutPriorAssociationMap.containskey(prf.PRM_Account_Id__c) && responseQuestionsIdSet.contains(prf.PRM_Question_Display_Text__c) ){
                    ProfileRespnseListforLoc.add(prf);               
                    system.debug('PRF record'+prf);
                    system.debug('Loop Count'+count);
                    Count = Count + 1 ;
                    PRM_Profile_Responses__c OPIDPrf = new PRM_Profile_Responses__c();                
                    OPIDPrf.PRM_Account_Id__c= OPIDsWithOutPriorAssociationMap.get(prf.PRM_Account_Id__c);
                    OPIDPrf.PRM_Profile_Questions_Id__C = prf.PRM_Profile_Questions_Id__c;
                    OPIDPrf.PRM_Response_Txt__c=prf.PRM_Response_Txt__c;
                    OPIDPrf.PRM_Reason_Text__c=prf.PRM_Reason_Text__c;
                    FinalProfileRespnseList.add(OPIDPrf);               
                    //  OPIDtoClearBeforeInsert.add(OPIDsWithOutPriorAssociationMap.get(Prf.PRM_Account_Id__c));               
                }
            }
            system.Debug('List of Profile Response are' +FinalProfileRespnseList) ;
            system.debug('OPIDtoClearBeforeInsert'+ OPIDtoClearBeforeInsert);
            system.Debug('List of Profile Response for loc' +ProfileRespnseListforLoc) ;
            
            if(!FinalProfileRespnseList.isEmpty()){
                try
                {
                    Insert FinalProfileRespnseList;
                    
                }catch(Exception ex){
                    PRM_ErrorUtilityClass.logError(ex);
                }
            }
        }
        //     Roll Down Logic Starts here
        if(!OPIDsAllRolldown.isEmpty()){ 
            for(Core_Account_Group_Member__c PAGMrec:OPIDmemberlist){
                if(OPIDsAllRolldown.contains(PAGMrec.Core_Partner_Account_Id__c)){
                    LocationAccountListForRollDown.add(PAGMrec); 
                    locationIdsResponseCheck.add(PAGMrec.Core_Intel_Account_Id__c);
                    system.debug('LocationAccountListForRollDown'+LocationAccountListForRollDown);  
                    system.debug('Javo - List of Prior Association Location and OPIDs ');
                }                
            }
        }
        system.debug('The value of responseOpidLevel in roll on is'+responseOpidLevel);
        system.debug('The value of responseLocLevel in roll on is'+responseLocLevel);
        system.debug('The value of responseOpidStringSet in roll on is'+responseOpidStringSet);
        system.debug('The value of responseLocStringSet in roll on is'+responseLocStringSet);
        // Get all the responses for the OPID 
        if(!responseLocLevel.IsEmpty()){
            for(PRM_Profile_Responses__c LocRespnse: responseLocLevel){
                if(allreponsesLocationLevelMap.keyset().contains(LocRespnse.PRM_Account_Id__c)){
                    // this map will have unique contacts with their latest email log version
                    // 
                    set<string> tempString = allreponsesLocationLevelMap.get(LocRespnse.PRM_Account_Id__c);
                    List<PRM_Profile_Responses__c> listProf = allreponsesLocationLevelMap2.get(LocRespnse.PRM_Account_Id__c);
                    listProf.add(LocRespnse);
                    tempString.add(LocRespnse.PRM_Question_Display_Text__c);
                    allreponsesLocationLevelMap.put(LocRespnse.PRM_Account_Id__c, tempString);
                    allreponsesLocationLevelMap2.put(LocRespnse.PRM_Account_Id__c, listProf);
                    
                }
                else{
                    allreponsesLocationLevelMap.put(LocRespnse.PRM_Account_Id__c,new set<string>{LocRespnse.PRM_Question_Display_Text__c}) ;
                    allreponsesLocationLevelMap2.put(LocRespnse.PRM_Account_Id__c,new List<PRM_Profile_Responses__c>{LocRespnse} ) ;
                }                
            }
        }
        system.debug('The value of allreponsesLocationLevelMap'+allreponsesLocationLevelMap);
        system.debug('The value of allreponsesLocationLevelMap2'+allreponsesLocationLevelMap2);
        
        if(!responseOpidLevel.isEmpty()){
            // A Map with key as intel Id and value as OPID
            for(PRM_Profile_Responses__c tempPrf : responseOpidLevel){  
                for(Core_Account_Group_Member__c tempCag : LocationAccountListForRollDown ){  
                    if (tempPrf.PRM_Account_Id__c == tempCag.Core_Partner_Account_Id__c ){
                        if (!allreponsesLocationLevelMap.keyset().isEmpty() && allreponsesLocationLevelMap.containskey(tempCag.Core_Intel_Account_Id__c)){
                            
                            if(allreponsesLocationLevelMap.get(tempCag.Core_Intel_Account_Id__c).contains(tempPrf.PRM_Question_Display_Text__c)){
                                
                                for(PRM_Profile_Responses__c locResponseLoop  : allreponsesLocationLevelMap2.get(tempCag.Core_Intel_Account_Id__c)){
                                    
                                    if(locResponseLoop.PRM_Question_Display_Text__c == tempPrf.PRM_Question_Display_Text__c){
                                        PRM_Profile_Responses__c OPIDPrf = new PRM_Profile_Responses__c();
                                        OPIDPrf.id      = locResponseLoop.id ;
                                        OPIDPrf.PRM_Response_Txt__c=tempPrf.PRM_Response_Txt__c;
                                        if (tempPrf.PRM_Question_Display_Text__c == 'Points Not eligible'){
                                            OPIDPrf.PRM_Reason_Text__c= tempPrf.PRM_Reason_Text__c;
                                        }
                                        FinalProfileRespnseListRollDown.add(OPIDPrf);
                                    }
                                }
                            }
                            else{
                                //Roll Down only for the 5 responses
                                //     if(responseQuestionsIdSet.contains(tempPrf.PRM_Question_Display_Text__c)){
                                PRM_Profile_Responses__c OPIDPrf = new PRM_Profile_Responses__c();
                                OPIDPrf.PRM_Account_Id__c= tempCag.Core_Intel_Account_Id__c;
                                OPIDPrf.PRM_Profile_Questions_Id__C = tempPrf.PRM_Profile_Questions_Id__c;
                                OPIDPrf.PRM_Response_Txt__c=tempPrf.PRM_Response_Txt__c;
                                if (tempPrf.PRM_Question_Display_Text__c == 'Points Not eligible'){
                                    OPIDPrf.PRM_Reason_Text__c= tempPrf.PRM_Reason_Text__c;
                                }  
                                FinalProfileRespnseListRollDown.add(OPIDPrf);
                                //     }
                                
                            }
                        }                        
                        else{
                            //Roll Down only for the 5 responses
                            //    if(responseQuestionsIdSet.contains(tempPrf.PRM_Question_Display_Text__c)){
                            PRM_Profile_Responses__c OPIDPrf = new PRM_Profile_Responses__c();
                            OPIDPrf.PRM_Account_Id__c= tempCag.Core_Intel_Account_Id__c;
                            OPIDPrf.PRM_Profile_Questions_Id__C = tempPrf.PRM_Profile_Questions_Id__c;
                            OPIDPrf.PRM_Response_Txt__c=tempPrf.PRM_Response_Txt__c;
                            if (tempPrf.PRM_Question_Display_Text__c == 'Points Not eligible'){
                                OPIDPrf.PRM_Reason_Text__c= tempPrf.PRM_Reason_Text__c;
                            }  
                            FinalProfileRespnseListRollDown.add(OPIDPrf);
                            //     }
                        }    
                    }
                }
            }
        }
        system.debug('The value of FinalProfileRespnseListRollDown'+FinalProfileRespnseListRollDown);
        
        // List of records which has no response at OPID but response at location. This would clear such records as OPID must be in Sync with Location
        if(!responseLocStringMap.IsEmpty()  && !responseOpidStringMap.IsEmpty()){
            for(string response : responseLocStringMap.keyset()){
                if(!responseOpidStringMap.containskey(locationAndOpidMap.get(responseLocStringMap.get(response).PRM_Account_Id__c)+responseLocStringMap.get(response).PRM_Question_Display_Text__c)){
                    locResponseClearList.add(responseLocStringMap.get(response));          
                }
            }
        }
        try
        {       
            system.debug('The value of FinalProfileRespnseListRollDown'+FinalProfileRespnseListRollDown);
            if(!FinalProfileRespnseListRollDown.IsEmpty()){
                upsert FinalProfileRespnseListRollDown;
            }   
            // Since there are no responses are OPID level, but if the location has some data. Then we would clear it to have it in sync with OPID.
            if(!locResponseClearList.IsEmpty()){
                delete locResponseClearList ;
            }
        }catch(Exception ex){
            PRM_ErrorUtilityClass.logError(ex);
        }          
    }     
    
    
}