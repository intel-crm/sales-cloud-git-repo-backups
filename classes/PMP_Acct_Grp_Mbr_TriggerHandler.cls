/**************************************************************************************
Apex Class Name : PMP_Acct_Grp_Mbr_TriggerHandler
Version     : 1.0 
Created Date: 24th June, 2019
Description : 
* Modification Log :
* Developer                     Date                     Description
* ----------------------------------------------------------------------------
* Usha                          24/06/2019               Original Version
*Anupam Agarwal                 12/08/2019               Added toggleIsPAGMember method to set the isPAGMember check on the Account
*Anupam Agarwal                 12/08/2019               Added beforeUpdate and beforeInsert methods to handle the MDA indicator and duplicate records related validations.
*Akshay More [Draco]            21-09-2021               Added condition to avoid clearing OPID at Account if non-Active Core_Account_Group_Member__c is deleted

*Akshay More [Draco]       23-08-2024     Added condition not to clear the OPID from Intel Account if it contains other Active Account-OPID relationships (upon PAG Delete in removeOnePartIdFromIntelAccOnDeletion method)
*************************************************************************************/
public without sharing class PMP_Acct_Grp_Mbr_TriggerHandler {
    
    public static Map<Id,sObject> objectsToInsert = new Map<Id,sObject>();
    public static Boolean objectsToInsertCounter = false;
    
    public static Map<Id,sObject> objectsToUpdate = new Map<Id,sObject>();
    public static Boolean objectsToUpdateCounter = false;
    public static boolean isFirstRunRollUpDown = true;
    public static boolean isFirstUpdateRunRollUpDown = true;    
    public static boolean isDoNotRunResponse = true;   
    
    
    
    public static Map<Id,sObject> objectsToDelete = new Map<Id,sObject>();
    public static Boolean objectsToDeleteCounter = false;
    
    public static void afterMethod(Map<Id,Core_Account_Group_Member__c> oldMap, List<Core_Account_Group_Member__c> newList){
        
        if(Trigger.isAfter){
            
            if (Trigger.isInsert || Trigger.isUpdate){
                
                Set<Id> accId=new Set<Id>();
                List<String> lstEntitlementIds = new List<String>();
                Map<id,Id> intelOpidAccMap = new Map<Id,Id>();
                
                for(Core_Account_Group_Member__c ce: newList){
                    if(((oldMap!=null && !oldMap.isEmpty() && oldMap.get(ce.Id).Core_Inactive_Ind__c !=ce.Core_Inactive_Ind__c ) ||(oldMap==null)) && ce.Core_Inactive_Ind__c==false){
		    
                    accId.add(ce.Core_Intel_Account_Id__c);
                        intelOpidAccMap.put(ce.Core_Intel_Account_Id__c,ce.Core_Partner_Account_Id__c);
                    }
                    
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
                    set<id> opidsFromCEs=new set<id>();
                    Map<Id,Set<Id>> intelAccContEntMap = new Map<Id,Set<Id>>();
                    List<Core_Contact_Entitlement__c> conEnt =[Select Core_Entitlement_Id__c,Core_Contact_Id__r.AccountId from 
                                                               Core_Contact_Entitlement__c 
                                                               where Core_Contact_Id__c IN : conId 
															   and Core_Selected__c =true 
            												   and Core_Status__c = 'Complete'
                                                               AND Core_Entitlement_Id__c IN :lstEntitlementIds];
					if(!conEnt.isEmpty()){
						for(Core_Contact_Entitlement__c ceMp: conEnt){
                            if(intelAccContEntMap.containsKey(ceMp.Core_Contact_Id__r.AccountId)){
                                intelAccContEntMap.get(ceMp.Core_Contact_Id__r.AccountId).add(ceMp.Id);
                            }else{
                                intelAccContEntMap.put(ceMp.Core_Contact_Id__r.AccountId,new Set<Id>{ceMp.id});
                            }
						}
					}							   
                    system.debug('opidsFromCEs'+opidsFromCEs);
                    
                    //if(!conEnt.isEmpty()){
                    Set<id> opidIdsToSetChangeInd = new Set<Id>();
                    List<Account> accToUpdate = new List<Account>();
                    if(intelAccContEntMap!=null && !intelAccContEntMap.isEmpty()){
                        for(Id intelAcc: intelAccContEntMap.keySet()){
                            if(intelOpidAccMap.containsKey(intelAcc)){
                                opidIdsToSetChangeInd.add(intelOpidAccMap.get(intelAcc));
                            }
                        }
                    }
                    //  FIX: correct condition
            	    if(!opidIdsToSetChangeInd.isEmpty()){
                        for(Account opidAcc : [Select Core_PMP_Membership_Change_Ind__c from Account where Id IN :opidIdsToSetChangeInd]){
                            if(opidAcc.Core_PMP_Membership_Change_Ind__c==false){
                                opidAcc.Core_PMP_Membership_Change_Ind__c=true;
                                accToUpdate.add(opidAcc);
                            }
                        }
                    }
                    
               /*for(Core_Account_Group_Member__c partneraccount : allPartnerAcc){ 
				if(opidsFromCEs.Contains(partneraccount.Core_Partner_Account_Id__c)){
                    system.debug('partneraccount.Core_Partner_Account_Id__c'+partneraccount.Core_Partner_Account_Id__c);
					 partneracctIds.add(partneraccount.Core_Partner_Account_Id__c);
				}
                       
                    }//end of for loop
                     system.debug('partneracctIds'+partneracctIds);
                    List<Account> Acc=[Select Core_PMP_Membership_Change_Ind__c from Account where Id IN :partneracctIds];
                    
                    
                    for(Account accRec : Acc){
                        if(accRec.Core_PMP_Membership_Change_Ind__c == false){
                            accRec.Core_PMP_Membership_Change_Ind__c =true ;
                            accToUpdate.add(accRec);      
                        } 
                    }//end of for loop*/
                    
                    //update accToUpdate ;
		    if(!accToUpdate.isEmpty()){
                    	Database.SaveResult[] accUpdateList = Database.update(accToUpdate, false);
        				PMP_Utility.logDmlErrors((Object[]) accUpdateList, 'PMP_Acct_Grp_Mbr_TriggerHandler-afterMethod'); 
                    }
                    //}//end of if
                    
                }//end of if
            }// end of isInsert and isUpdate
        }// end of isAfter
     }// end of afterMethod
    /** Remove One Partner Id from Intel Account when Inactive Indicator is checked and update One partner Id to Intel Account when Inactive Indicator is unchecked**/
    public static void populateOnePartnerIdOnIntelAccount(List<Core_Account_Group_Member__c> lstOfOPIDGrpMbr,  Map<Id, Core_Account_Group_Member__c> mapOldOpidGrmMbr){
        List<Account> lstAccToUpdate = new List<Account>();
        List<Id> listIntelAccountsIds = new List<Id>();
        Map<Id,Id> mapActiveInteltoOPIDIds = new Map<Id,Id>();
        for(Core_Account_Group_Member__c agm : lstOfOPIDGrpMbr){
            if(agm.Core_Intel_Account_Id__c != null){ //  null check
                listIntelAccountsIds.add(agm.Core_Intel_Account_Id__c);
            }
        }
        
        List<Core_Account_Group_Member__c> opidListToAcc = new List<Core_Account_Group_Member__c>([SELECT Id, Name, Core_Inactive_Ind__c, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c FROM Core_Account_Group_Member__c WHERE Core_Intel_Account_Id__c IN: listIntelAccountsIds]);
        for(Core_Account_Group_Member__c agm : opidListToAcc){
            if (!agm.Core_Inactive_Ind__c) {
                if(!mapActiveInteltoOPIDIds.containsKey(agm.Core_Intel_Account_Id__c)){
                    mapActiveInteltoOPIDIds.put(agm.Core_Intel_Account_Id__c,agm.Core_Partner_Account_Id__c);
                }
            }
        }
        
        for(Core_Account_Group_Member__c agm : lstOfOPIDGrpMbr) {
            if(mapOldOpidGrmMbr == null || 
               (agm.Core_Partner_Account_Id__c != mapOldOpidGrmMbr.get(agm.id).Core_Partner_Account_Id__c ||
                agm.Core_Intel_Account_Id__c != mapOldOpidGrmMbr.get(agm.id).Core_Intel_Account_Id__c || 
                agm.Core_Inactive_Ind__c != mapOldOpidGrmMbr.get(agm.id).Core_Inactive_Ind__c )) {
                    
                    Account acc = new Account();
                    acc.id = agm.Core_Intel_Account_Id__c;
                    acc.Core_IPA_One_Partner_Id__c = agm.Core_Inactive_Ind__c && !mapActiveInteltoOPIDIds.containsKey(agm.Core_Intel_Account_Id__c) ? '' : mapActiveInteltoOPIDIds.get(agm.Core_Intel_Account_Id__c);
                    if(!lstAccToUpdate.contains(acc)){
                        lstAccToUpdate.add(acc);      
                    }
                }
        }
        
        if(!lstAccToUpdate.isEmpty()){
            Database.SaveResult[] result = Database.update(lstAccToUpdate, false); 
            PMP_Utility.logDmlErrors((Object[]) result, 'PMP_Acct_Grp_Mbr_TriggerHandler-populateOnePartnerIdOnIntelAccount');
        }
    }
    
    /** Remove One Partner Id from Intel Account when OPId Group is deleted ***/
   /* public static void removeOnePartIdFromIntelAccOnDeletion(List<Core_Account_Group_Member__c> lstOfOPIDGrpMbr){
        Set<Account> lstAccToUpdate = new Set<Account>();
        List<Id> listIntelAccountsIds = new List<Id>();
        List<Id> listDeletedAGMIds = new List<Id>();
        Map<Id,Id> mapActiveInteltoOPIDIds = new Map<Id,Id>();
        for(Core_Account_Group_Member__c agm : lstOfOPIDGrpMbr){
            listIntelAccountsIds.add(agm.Core_Intel_Account_Id__c);
            listDeletedAGMIds.add(agm.Id);
        }
        
        List<Core_Account_Group_Member__c> opidListToAcc = new List<Core_Account_Group_Member__c>([SELECT Id, Name, Core_Inactive_Ind__c, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c FROM Core_Account_Group_Member__c WHERE Core_Intel_Account_Id__c IN: listIntelAccountsIds]);
        for(Core_Account_Group_Member__c agm : opidListToAcc){
            if (!agm.Core_Inactive_Ind__c && !listDeletedAGMIds.contains(agm.Id)){
                if(!mapActiveInteltoOPIDIds.containsKey(agm.Core_Intel_Account_Id__c)){
                    mapActiveInteltoOPIDIds.put(agm.Core_Intel_Account_Id__c,agm.Core_Partner_Account_Id__c);
                }
            }
        }
        for(Core_Account_Group_Member__c pag : lstOfOPIDGrpMbr){
                Account acc = new Account();
                acc.id = pag.Core_Intel_Account_Id__c;
                acc.Core_IPA_One_Partner_Id__c = !mapActiveInteltoOPIDIds.containsKey(pag.Core_Intel_Account_Id__c) ? '' : mapActiveInteltoOPIDIds.get(pag.Core_Intel_Account_Id__c);
                lstAccToUpdate.add(acc);
                Account pagAcc = new Account();
                pagAcc.Id = pag.Core_Partner_Account_Id__c;
                pagAcc.Core_PMP_Membership_Change_Ind__c = true;
                lstAccToUpdate.add(pagAcc);
        }  
        
        if(lstAccToUpdate.size()>0){
            Database.SaveResult[] result = Database.update(new List<Account>(lstAccToUpdate), false); 
            PMP_Utility.logDmlErrors((Object[]) result, 'PMP_Acct_Grp_Mbr_TriggerHandler-removeOnePartIdFromIntelAccOnDeletion');
        }
    }*/
    
  /*  public static void beforeMethod(List<Core_Account_Group_Member__c> oldList, List<Core_Account_Group_Member__c> newList){
        
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
            //update accToUpdate;  
             Database.SaveResult[] accUpdateList = Database.update(accToUpdate, false); 
             PMP_Utility.logDmlErrors((Object[]) accUpdateList, 'PMP_Acct_Grp_Mbr_TriggerHandler-beforeMethod');
             
            //}
        }                
        //}
    }*/
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
        Core_Account_Group_Member__c pagmOldValue =(PAGMOldMap != null) ? PAGMOldMap.get(pagm.Id) : null; // ✅ cached
	if(pagm.Id != null){

            
	    
	    if(pagm.Core_MDA_Ind__c == true &&(pagmOldValue != null && pagmOldValue.Core_MDA_Ind__c != pagm.Core_MDA_Ind__c)){
	    pagmList.add(pagm);
	    accountIds.add(pagm.Core_Partner_Account_Id__c);
	    }
	    
	    if(pagm.Core_MDA_Ind__c != true &&(pagmOldValue != null && pagmOldValue.Core_MDA_Ind__c != pagm.Core_MDA_Ind__c)){
	    pagmList.add(pagm);
	    accountIds.add(pagm.Core_Partner_Account_Id__c);
	    }
	    
	    if(!pagm.Core_Inactive_Ind__c &&pagmOldValue != null &&pagm.Core_Inactive_Ind__c != pagmOldValue.Core_Inactive_Ind__c){
	    pagmIntelActiveRecords.add(pagm.Core_Intel_Account_Id__c);
	    }

            if(pagm.Core_MDA_Ind__c == true &&pagmOldValue != null &&pagmOldValue.Core_MDA_Ind__c != pagm.Core_MDA_Ind__c &&pagm.Core_Inactive_Ind__c == true){

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
            //List<Core_Account_Group_Member__c> pagmRecordList = [Select Id, Core_Intel_Account_Id__c, Core_MDA_Ind__c, Core_Inactive_Ind__c from Core_Account_Group_Member__c where Core_Intel_Account_Id__c in :recordsToInactivate and Core_MDA_Ind__c = true];
            //if(pagmRecordList.size()>0){
                //for(Core_Account_Group_Member__c pagm:PAGMNewList){pagm.addError(System.label.PRM_Restrict_MDA_Removal);
                
            //}
            List<Account> intelAccRecords = [Select id, name, Core_Is_PAG_Member_Ind__c from Account where id in:recordsToInactivate];
            if(intelAccRecords.size()>0){
                for(Account acc : intelAccRecords){
                    acc.Core_Is_PAG_Member_Ind__c = false;
                    accToUpsert.add(acc); 
                }
            }
            if(accToUpsert.size()>0){
                //update accToUpsert;
                Database.SaveResult[] accUpsertList = Database.update(accToUpsert, false); 
             	PMP_Utility.logDmlErrors((Object[]) accUpsertList, 'PMP_Acct_Grp_Mbr_TriggerHandler-checkMDAIndicator');
            }
        }
    }
    
    public static void toggleIsPAGMember(List<Core_Account_Group_Member__c> PAGMNewList, Map<Id, Core_Account_Group_Member__c> PAGMOldMap){
        List<Id> pagmIntelAccRecords = new List<Id>();
        List<Account> accToUpsert = new List<Account>();
        Set<Id> oldIntelAccounts = new Set<Id>();
        for(Core_Account_Group_Member__c pagm:PAGMNewList){
        Core_Account_Group_Member__c pagmOldValue =(PAGMOldMap != null) ? PAGMOldMap.get(pagm.Id) : null; //  cached
	
	if(pagmOldValue == null){
	if(pagm.Core_Intel_Account_Id__c != null){ //  null safety
	pagmIntelAccRecords.add(pagm.Core_Intel_Account_Id__c);
	}
	}else{
	
	if(pagmOldValue.Core_Inactive_Ind__c != pagm.Core_Inactive_Ind__c && pagm.Core_Inactive_Ind__c == true){
	if(pagmOldValue.Core_Intel_Account_Id__c != null){
    		oldIntelAccounts.add(pagmOldValue.Core_Intel_Account_Id__c); // safety
	}
	} else if(pagmOldValue.Core_Inactive_Ind__c != pagm.Core_Inactive_Ind__c && pagm.Core_Inactive_Ind__c == false){
	if(pagm.Core_Intel_Account_Id__c != null){
	    pagmIntelAccRecords.add(pagm.Core_Intel_Account_Id__c);
	}
	} else if(pagm.Core_Intel_Account_Id__c != pagmOldValue.Core_Intel_Account_Id__c){
	if(pagmOldValue.Core_Intel_Account_Id__c != null){
	oldIntelAccounts.add(pagmOldValue.Core_Intel_Account_Id__c);
	}
	if(pagm.Core_Intel_Account_Id__c != null){
	pagmIntelAccRecords.add(pagm.Core_Intel_Account_Id__c);
                }
            }
        }
    }
        // Setting IsPAGMember to true for Intel Account when the PAG Member record is created
          //  Activate
    	    if(!pagmIntelAccRecords.isEmpty()){
            List<Account> intelAccRecords = [Select id,name, Core_Is_PAG_Member_Ind__c from Account where id in:pagmIntelAccRecords ];
            
                for(Account acc : intelAccRecords){

                    acc.Core_Is_PAG_Member_Ind__c = true;
                    accToUpsert.add(acc); 
                }
            }
        
        // Setting IsPAGMember to false when the Intel Account is changed on PAG Member record
           //  Deactivate
           if(!oldIntelAccounts.isEmpty()){
            List<Account> oldIntelAccRecords = [Select id,name, Core_Is_PAG_Member_Ind__c from Account where id in:oldIntelAccounts ];
            
                for(Account acc : oldIntelAccRecords){

                    acc.Core_Is_PAG_Member_Ind__c = false;
                    accToUpsert.add(acc); 
                }
            }
    
	//  Avoid empty DML
        if(!accToUpsert.isEmpty()){
            //update accToUpsert;
             Database.SaveResult[] accToUpsertList = Database.update(accToUpsert, false); 
             PMP_Utility.logDmlErrors((Object[]) accToUpsertList, 'PMP_Acct_Grp_Mbr_TriggerHandler-toggleIsPAGMember');
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
           Core_Account_Group_Member__c PAGOld =(oldMap != null) ? oldMap.get(PAGM.Id) : null; //  cached
            
            if((oldMap == null) ||(PAGOld != null &&PAGOld.Core_Inactive_Ind__c == true &&PAGOld.Core_Inactive_Ind__c != PAGM.Core_Inactive_Ind__c)){
	    if(PAGM.Core_Intel_Account_Id__c != null){ // null safety
	    	LocationAccntsIdset.add(PAGM.Core_Intel_Account_Id__c);
            }
	    if(PAGM.Core_Partner_Account_Id__c != null){
                OPIDAndLocationAccntsMap.add(PAGM.Core_Partner_Account_Id__c);
	    }
                OPIDmemberlist.add(PAGM);

            }
        }
        if(!OPIDAndLocationAccntsMap.isEmpty()){

            for(PRM_AccountLegalAgreemntAssociation__c ala :[select id, PRM_Account_Id__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c from PRM_AccountLegalAgreemntAssociation__c where PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c='IPA_TANDC' AND PRM_Account_Id__c IN:OPIDAndLocationAccntsMap]){
                if(OPIDAndLocationAccntsMap.contains(ala.PRM_Account_Id__c)){
                    OPIDsWithLegalAggrSet.add(ala.PRM_Account_Id__c);

                }
            }
            
        }
        for(Core_Account_Group_Member__c PAGMrec:OPIDmemberlist){
            if(!OPIDsWithLegalAggrSet.contains(PAGMrec.Core_Partner_Account_Id__c)){
                OPIDWithoutLegalAggrLocMap.put(PAGMrec.Core_Intel_Account_Id__c,PAGMrec.Core_Partner_Account_Id__c); 

            }
        }
        if(!OPIDWithoutLegalAggrLocMap.isEmpty()){
      Map<Id, PRM_AccountChannelMembership__c> ipaAccountIdACMMap = new Map<Id, PRM_AccountChannelMembership__c>();
      //Checking if location account is an IPA account i.e. it should have atleast one approved ACM
      for(PRM_AccountChannelMembership__c acm: [Select id, PRM_Account_Id__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c IN: OPIDWithoutLegalAggrLocMap.keyset() and PRM_Channel_Program_Id__r.Name = 'Intel Partner Alliance' and PRM_Status_Nm__c = 'Approved']){
        ipaAccountIdACMMap.put(acm.PRM_Account_Id__c, acm);  
      }
            // IPA Refresh 2.0 - TWC729-7874
           List<PRM_AccountLegalAgreemntAssociation__c> AccLegalAgrmnt = [
            SELECT Id, PRM_Signed_By_Email__c, PRM_Signed_By_Name__c,PRM_Account_Id__c, PRM_Agreement_Sign_Dt__c,PRM_Partner_Agreement_Id__c, PRM_InActive_Ind__c,PRM_Notes_Txt__c, PRM_Account_Id__r.Name FROM PRM_AccountLegalAgreemntAssociation__c WHERE PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c = 'IPA_TANDC' AND PRM_Account_Id__c IN :OPIDWithoutLegalAggrLocMap.keySet() ORDER BY CreatedDate ASC];


            for(PRM_AccountLegalAgreemntAssociation__c ala : AccLegalAgrmnt){
                //system.debug('ALA record'+ala);
        if(ipaAccountIdACMMap.containsKey(ala.PRM_Account_Id__c)){
          PRM_AccountLegalAgreemntAssociation__c OPIDAla = new PRM_AccountLegalAgreemntAssociation__c();
          
          OPIDAla.PRM_Account_Id__c= OPIDWithoutLegalAggrLocMap.get(ala.PRM_Account_Id__c);
          //IPA Refresh 2.0 - TWC729-7874
                OPIDAla.PRM_Signed_By_Email__c=ala.PRM_Signed_By_Email__c;
                OPIDAla.PRM_Signed_By_Name__c=ala.PRM_Signed_By_Name__c;

          OPIDAla.PRM_Agreement_Sign_Dt__c=ala.PRM_Agreement_Sign_Dt__c;
          OPIDAla.PRM_Partner_Agreement_Id__c=ala.PRM_Partner_Agreement_Id__c;
          OPIDAla.PRM_InActive_Ind__c=ala.PRM_InActive_Ind__c;
          OPIDAla.PRM_Notes_Txt__c = 'Terms and Condition acceptance rolled up from the location account' + ' ' + ala.PRM_Account_Id__r.name + ' '+'as part of T&C roll up.';
          if(!OPIDLegalAggrMap.containsKey(OPIDAla.PRM_Account_Id__c)){
            OPIDLegalAggrMap.put(OPIDWithoutLegalAggrLocMap.get(ala.PRM_Account_Id__c),OPIDAla);  
          }
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
            //insert(FinalLegalAggrList);
             Database.SaveResult[] finalAggrList = Database.insert(FinalLegalAggrList, false);
			 PMP_Utility.logDmlErrors((Object[]) finalAggrList, 'PMP_Acct_Grp_Mbr_TriggerHandler-PopulateLegalAgreeOnOPID');
            
            
        }
    }
    /**
        *  @description      : roll up/down IPA Membership Attributes
        *  @name             : retryIPRM_IPAR_rollUpDownIPAMembershipnboundProcessing
        *  @param            : List<Core_Account_Group_Member__c> pagNewList,Map<Id,Core_Account_Group_Member__c> oldMap
        *  @throws exception : NONE
        * @userstory         : TWC729-7917
    **/
    public static void PRM_IPAR_rollUpDownIPAMembership(List<Core_Account_Group_Member__c> pagNewList,Map<Id,Core_Account_Group_Member__c> oldMap){
        Id opidIpaMemAttrRecordId = Schema.SObjectType.PRM_IPAMembership_Attributes__c.getRecordTypeInfosByName().get('1PID Account Attributes').getRecordTypeId();
        Id inteIpaMemAttrRecordId = Schema.SObjectType.PRM_IPAMembership_Attributes__c.getRecordTypeInfosByName().get('Intel Account Attributes').getRecordTypeId();
        String logEntryMsg='';
        Set<Id> locationAcctIds = new Set<Id>();
        Set<Id> opidAcctIds = new Set<Id>();
        List<Core_Account_Group_Member__c> cagList = new List<Core_Account_Group_Member__c>();
        Set<Id> opidWithPriorAssociation = new Set<Id>();
        Set<Id> opidWithoutPriorAssociation = new Set<Id>();
        Map<String,Core_Account_Group_member__c> opidsWithOldestLocTemp = new Map<String,Core_Account_Group_member__c>();
        Set<Id> intelAndOpidAccts = new Set<Id>();
        Map<Id,PRM_IPAMembership_Attributes__c> opidMemAttMap = new Map<Id,PRM_IPAMembership_Attributes__c>();
        Map<Id,PRM_IPAMembership_Attributes__c> locMemAttMap = new Map<Id,PRM_IPAMembership_Attributes__c>();
        Set<id> acctsWithIpaMemAttr = new Set<id>();
        Set<id> opidtoRollDownToLoc = new Set<Id>();
        Set<Id> locRollUptoOpid= new Set<Id>();
        Map<Id,Id> opidWithoutPriorAssociationMap = new Map<Id,Id>();
        List<PRM_IPAMembership_Attributes__c> lisOfIpaMemAttribute = new List<PRM_IPAMembership_Attributes__c>();
        List<Core_Account_Group_Member__c> cagForRollDown = new List<Core_Account_Group_Member__c>();
        String errorMsg ='*****PRM_IPAR_rollUpDownIPAMembership*****';
        errorMsg+= 'pagNewList: '+pagNewList+'******';
        for(Core_Account_Group_Member__c cagNew:pagNewList) {
            Core_Account_Group_Member__c PAGOld ; //getting old values from map
            if(oldMap!=null && oldMap.size()>0){
                PAGOld = (Core_Account_Group_Member__c) oldMap.get(cagNew.id) ;
            }
            //CAGs of only IPA accounts are processed
            if((oldMap==null && cagNew.Core_Intel_Partner_Alliance_PartnerGroup__c==true && cagNew.Core_Inactive_Ind__c==false ) || ((oldMap!=null && oldMap.size()>0) &&((PAGOld.Core_Inactive_Ind__c==true) &&  (cagNew.Core_Intel_Partner_Alliance_PartnerGroup__c==true)&&(PAGOld.Core_Inactive_Ind__c != cagNew.Core_Inactive_Ind__c)))){
                locationAcctIds.add(cagNew.Core_Intel_Account_Id__c);  // adding specialties to a set
                opidAcctIds.add(cagNew.Core_Partner_Account_Id__c);
                cagList.add(cagNew);  
            }
        }
        errorMsg+= 'cagList: '+cagList+'******';
        //Query to fetch all the Intel accounts associated with the OPID
        if(!opidAcctIds.isEmpty() && !locationAcctIds.isEmpty()){
            for(Core_Account_Group_Member__c cag :[SELECT Name,Core_Partner_Account_Id__c,Core_Inactive_Ind__c,Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c  WHERE Core_Partner_Account_Id__c IN:opidAcctIds AND Core_Inactive_Ind__c=false AND Core_Intel_Partner_Alliance_PartnerGroup__c=true]){
                // In this below IF condition, we fetch all the Location account that are associated with OPID. If there are any additional Intel account associated with OPID apart from the Trigger.new Loc Id's, then we would say that OPID has had Prior Association
                if(!locationAcctIds.contains(cag.Core_Intel_Account_Id__c)){
                    opidWithPriorAssociation.add(cag.Core_Partner_Account_Id__c);
                }
                // The below Map will only have one location Id per OPID. The Location ID would be the first associated Location ID.This would be later used for Rollup. We would roll up the oldest amongst the trigger.new records.
                if(!opidsWithOldestLocTemp.containskey(cag.Core_Partner_Account_Id__c)){
                    opidsWithOldestLocTemp.put(cag.Core_Partner_Account_Id__c,cag);
                }
            }           
        }
        // The below set will have all the Id's. OPID and Location Ids. This would be used to query profile response so that we only use one SOQL for profile response object.
        intelAndOpidAccts.addall(opidAcctIds);  
        intelAndOpidAccts.addall(locationAcctIds);  

        // We would get the List of OPID's for which there was no Prior association to Location account         
        for(Core_Account_Group_Member__c cag:cagList){
            if(!opidWithPriorAssociation.contains(cag.Core_Partner_Account_Id__c)){
                opidWithoutPriorAssociation.add(cag.Core_Partner_Account_Id__c); 
            }
        }
        //querying all IPA Membership Attribute record for OPID and Intel Account
        if(!intelAndOpidAccts.IsEmpty()){
            for(PRM_IPAMembership_Attributes__c ipaMemAtt:[SELECT Id,RecordTypeId, PRM_Points_Not_Eligible_Reason_Txt__c, PRM_Points_Not_Eligible_Ind__c, PRM_Points_Not_Eligible_Dt__c, PRM_Component_Point_earning_excl_Ind__c, PRM_Component_Point_earning_excl_Dt__c, PRM_Branded_Point_earning_excl_Ind__c, PRM_Branded_Point_earning_excl_Dt__c, PRM_ODM_whiteboxPointEarning_excl_Ind__c, PRM_ODM_whiteboxPointEarning_excl_Dt__c, PRM_Registration_Source_Txt__c, PRM_Points_Opt_in_Ind__c, PRM_Points_Opt_in_Dt__c, PRM_Point_Status_Txt__c, PRM_Point_Status_Dt__c, PRM_Point_Status_Reason_Txt__c, PRM_Account_Id__c FROM PRM_IPAMembership_Attributes__c WHERE PRM_Account_Id__c IN:intelAndOpidAccts And PRM_Inactive_ind__c= false]){
                if(opidAcctIds.contains(ipaMemAtt.PRM_Account_Id__c)){
                    opidMemAttMap.put(ipaMemAtt.PRM_Account_Id__c,ipaMemAtt);
                }
                if(locationAcctIds.contains(ipaMemAtt.PRM_Account_Id__c)){
                    locMemAttMap.put(ipaMemAtt.PRM_Account_Id__c,ipaMemAtt);
                }
                acctsWithIpaMemAttr.add(ipaMemAtt.PRM_Account_Id__c);
            }
        }

        //identifying OPIDs with IPA membership attribute but no prior association
        if(!opidMemAttMap.IsEmpty() && !opidWithoutPriorAssociation.IsEmpty()){
            for(Id  opidAcc : opidMemAttMap.keySet()){
                if(opidWithoutPriorAssociation.contains(opidAcc))
                    acctsWithIpaMemAttr.add(opidAcc);                   
            }
        }
        
        // identifying opids to get IPA membership attribute through roll up
        if( !opidWithoutPriorAssociation.IsEmpty()){
            for(Id opidAcc : opidWithoutPriorAssociation ){
                if(!acctsWithIpaMemAttr.contains(opidAcc)){
                    locRollUptoOpid.add(opidAcc);
                }         
            }
        }
        
        //creating a map of first intel account and the opid it is associated to
        if(!locRollUptoOpid.isEmpty()){
            for(id  opidAcc: opidsWithOldestLocTemp.keyset()){
                if(locRollUptoOpid.contains(opidAcc)){
                    opidWithoutPriorAssociationMap.put(opidsWithOldestLocTemp.get(opidAcc).Core_Intel_Account_Id__c,opidAcc);
                }
            }
        }

        
        //creating new IPA membership attribute for OPID
        errorMsg+= 'opidWithoutPriorAssociationMap: '+opidWithoutPriorAssociationMap.size()+'******';
        if(!opidWithoutPriorAssociationMap.isEmpty() && !locMemAttMap.IsEmpty()){
            for(PRM_IPAMembership_Attributes__c  locIpaMemAtt : locMemAttMap.values()){

                if(opidWithoutPriorAssociationMap.containskey(locIpaMemAtt.PRM_Account_Id__c)){            
                    PRM_IPAMembership_Attributes__c opidIpaMemAtt = new PRM_IPAMembership_Attributes__c();                
                    opidIpaMemAtt = PRM_ProfileResponse.createIpaMembershipAttribute_IPAR(opidIpaMemAtt,locIpaMemAtt);
                    opidIpaMemAtt.PRM_Account_Id__c = opidWithoutPriorAssociationMap.get(locIpaMemAtt.PRM_Account_Id__c);
                    opidIpaMemAtt.RecordTypeId = opidIpaMemAttrRecordId;
                   
                    lisOfIpaMemAttribute.add(opidIpaMemAtt);                            
                }
            }
        }
        errorMsg+= 'lisOfIpaMemAttribute :'+lisOfIpaMemAttribute+'*****';

        //Roll Down Logic Starts here
        if(!opidMemAttMap.isEmpty()){
            // A Map with key as intel Id and value as OPID
            for(PRM_IPAMembership_Attributes__c opidIpaMemAtt : opidMemAttMap.values()){  
                               
                for(Core_Account_Group_Member__c cag : cagList ){  
                    if (opidIpaMemAtt.PRM_Account_Id__c == cag.Core_Partner_Account_Id__c ){
                        PRM_IPAMembership_Attributes__c locMemAttr = new PRM_IPAMembership_Attributes__c();
                        //if intel account already has a record we roll down to that record                                           
                        if (!locMemAttMap.keyset().isEmpty() && locMemAttMap.containskey(cag.Core_Intel_Account_Id__c)){
                            locMemAttr = locMemAttMap.get(cag.Core_Intel_Account_Id__c);
                            locMemAttr.PRM_Inactive_ind__c = false;
                            
                            
                        }else{//if intel account does not have a record then create new IPA membership attribute an roll down
                            locMemAttr.PRM_Account_Id__c= cag.Core_Intel_Account_Id__c;
                            locMemAttr.RecordTypeId =inteIpaMemAttrRecordId;
                            locMemAttr.PRM_Inactive_ind__c = false;
                        }   
                            locMemAttr = PRM_ProfileResponse.createIpaMembershipAttribute_IPAR(locMemAttr,opidIpaMemAtt);
                            lisOfIpaMemAttribute.add(locMemAttr);
                    }
                }
            }
        }
        errorMsg+= 'lisOfIpaMemAttribute :'+lisOfIpaMemAttribute+'*****';
        try{       
            if(!lisOfIpaMemAttribute.IsEmpty()){
                //upsert all ipa membership attributes for OPID and intel account
                Database.UpsertResult[] result = Database.upsert(lisOfIpaMemAttribute,false);
                PMP_Utility.logDmlErrors((Object[]) result, 'PMP_Acct_Grp_Mbr_TriggerHandler-PRM_IPAR_rollUpDownIPAMembership');
                /*for(Database.UpsertResult sr : result){
                    if(!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors()) {
                            errorMsg = errorMsg+err.getMessage()+' ';
                        } 
                        errorMsg= errorMsg+'\n';
                    }
                }*/
            }
        }catch(Exception ex){
            errorMsg=ex.getMessage();   
        }finally{
            Core_Log_Entry.logEntryWithDetails('OPID Inbound Batch','IPA','OPID Inbound Batch','Error','',errorMsg ,'', '', '');
        }
    }

    public static void RollUpLocFlagToOPID(List<Core_Account_Group_Member__c> PAGMNewList,Map<Id,Core_Account_Group_Member__c> oldMap){
        Set<id> LocationAccntsIdset = new Set<id>();// to store location accnts
        Set<id> OPIDAndLocationAccnts = new Set<id>();// to store OPID accnts
        List<Core_Account_Group_Member__c> OPIDmemberlist = new List<Core_Account_Group_Member__c>(); // to store PAGM id
        Set<ID> OPIDsWithPrfleRspnse= New Set<ID>();
        Set<String> StringOfQuestions= New Set<String>{'PRM_Component_point','PRM_Branded_Point','PRM_ODM_Whitebox_Point','PRM_Point_Not_Eligible','PRM_Opt_In','PRM_Status_date','PRM_Status'};
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
        // Map<id,PRM_Profile_Responses__c> FinalProfileRespnseListRollDown = new Map<id,PRM_Profile_Responses__c>();
       // Map<id,PRM_Profile_Responses__c> locResponseClearList = new Map<id,PRM_Profile_Responses__c>();
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

        //Iterate the Input
        for(Core_Account_Group_Member__c PAGM:PAGMNewList) {
           Core_Account_Group_Member__c PAGOld =(oldMap != null) ? oldMap.get(PAGM.Id) : null;

        

if((oldMap == null &&PAGM.Core_Intel_Partner_Alliance_PartnerGroup__c &&!PAGM.Core_Inactive_Ind__c)||(PAGOld != null &&PAGOld.Core_Inactive_Ind__c &&PAGM.Core_Intel_Partner_Alliance_PartnerGroup__c &&PAGOld.Core_Inactive_Ind__c != PAGM.Core_Inactive_Ind__c)){

            if(PAGM.Core_Intel_Account_Id__c != null)
                LocationAccntsIdset.add(PAGM.Core_Intel_Account_Id__c);

            if(PAGM.Core_Partner_Account_Id__c != null){
                OPIDAndLocationAccnts.add(PAGM.Core_Partner_Account_Id__c);
                OPIDsAllRolldown.add(PAGM.Core_Partner_Account_Id__c);
            }
                locationAndOpidMap.put(PAGM.Core_Intel_Account_Id__c,PAGM.Core_Partner_Account_Id__c);
                
                OPIDmemberlist.add(PAGM);  

            }
        }
        
        //Query to fetch all the Intel accounts associated with the OPID
        if(!OPIDAndLocationAccnts.isEmpty() && !LocationAccntsIdset.isEmpty() ){
            //query to identify OPID with prior assocaition and get the first association
            for(Core_Account_Group_Member__c CagMember :[SELECT Name,Core_Partner_Account_Id__c,Core_Inactive_Ind__c,Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c  WHERE Core_Partner_Account_Id__c IN:OPIDAndLocationAccnts AND Core_Inactive_Ind__c=false AND Core_Intel_Partner_Alliance_PartnerGroup__c=true]){
                // In this below IF condition, we fetch all the Location account that are associated with OPID. If there are any additional Intel account associated with OPID apart from the Trigger.new Loc Id's, then we would say that OPID has had Prior Association
                if(!LocationAccntsIdset.contains(CagMember.Core_Intel_Account_Id__c)){
                    OPIDsWithPriorAssociation.add(CagMember.Core_Partner_Account_Id__c);

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

        
        // We would get the List of OPID's for which there was no Prior association to Location account         
        for(Core_Account_Group_Member__c PAGMrec:OPIDmemberlist){
            if(!OPIDsWithPriorAssociation.contains(PAGMrec.Core_Partner_Account_Id__c)){
                OPIDWithoutPriorAssociation.add(PAGMrec.Core_Partner_Account_Id__c); 

                
            }
        }
        // Using the abive mentioned set, queried the respones object for all the account id's. We would split this on Loc and OPID.
        // This query would only fetch 5 records per account at max since we are dealing with only 5 responses now. This is done to avoid any bad data. If location or OPID has bad data. It will only take 5 records to rollup or rolldown.
        if(!opidAndLocationIds.IsEmpty()){
            for(PRM_Profile_Responses__c  OPIDTemp :[select PRM_Profile_Questions_Id__C, PRM_Profile_Questions_Id__r.PRM_Question_Cd__c ,PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c, PRM_Account_Id__c, PRM_View_History__c, PRM_Response_Txt__c,  PRM_InActive_Ind__c ,PRM_Question_Display_Text__c, PRM_Reason_Text__c, RecordTypeId from PRM_Profile_Responses__c where PRM_Account_Id__c  IN: opidAndLocationIds and PRM_Profile_Questions_Id__r.PRM_Question_Cd__c IN: StringOfQuestions order by createddate desc]){
                if(OPIDTemp != null && !responseLimitMap.containskey(OPIDTemp.PRM_Account_Id__c+OPIDTemp.PRM_Question_Display_Text__c)){
                    // The below IF condition to grt only 5 rsponses per account.
                    //if(!responseLimitMap.containskey(OPIDTemp.PRM_Account_Id__c+OPIDTemp.PRM_Question_Display_Text__c)){
                        responseLimitMap.put(OPIDTemp.PRM_Account_Id__c+OPIDTemp.PRM_Question_Display_Text__c,OPIDTemp);
                        if(OPIDAndLocationAccnts.contains(OPIDTemp.PRM_Account_Id__c) && responseQuestionsIdSet.contains(OPIDTemp.PRM_Question_Display_Text__c)) {

                            responseOpidLevel.add(OPIDTemp);
                            responseOpidStringSet.add(OPIDTemp.PRM_Account_Id__c+OPIDTemp.PRM_Question_Display_Text__c);
                            responseOpidStringMap.put(OPIDTemp.PRM_Account_Id__c+OPIDTemp.PRM_Question_Display_Text__c,OPIDTemp);
                        }
                        if(LocationAccntsIdset.contains(OPIDTemp.PRM_Account_Id__c) && responseQuestionsIdSet.contains(OPIDTemp.PRM_Question_Display_Text__c)){

                            responseLocLevel.add(OPIDTemp);
                            responseLocStringSet.add(OPIDTemp.PRM_Account_Id__c+OPIDTemp.PRM_Question_Display_Text__c);
                            responseLocStringMap.put(OPIDTemp.PRM_Account_Id__c+OPIDTemp.PRM_Question_Display_Text__c,OPIDTemp);
                        }  
                        
                    //}
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
            
            

            
            
            if(!FinalProfileRespnseList.isEmpty()){
                try
                {
                    //Insert FinalProfileRespnseList;
                    Database.SaveResult[] fpResList = Database.insert(FinalProfileRespnseList, false);
					PMP_Utility.logDmlErrors((Object[]) fpResList, 'PMP_Acct_Grp_Mbr_TriggerHandler-RollUpLocFlagToOPID');
                    
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

                }                
            }
        }
        

        
        
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
                                        if (tempPrf.PRM_Question_Display_Text__c == 'Points Not eligible' || tempPrf.PRM_Question_Display_Text__c == 'Point Status'){
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
                                if (tempPrf.PRM_Question_Display_Text__c == 'Points Not eligible' || tempPrf.PRM_Question_Display_Text__c == 'Point Status'){
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
                            if (tempPrf.PRM_Question_Display_Text__c == 'Points Not eligible' || tempPrf.PRM_Question_Display_Text__c == 'Point Status'){
                                OPIDPrf.PRM_Reason_Text__c= tempPrf.PRM_Reason_Text__c;
                            }  
                            FinalProfileRespnseListRollDown.add(OPIDPrf);
                            //     }
                        }    
                    }
                }
            }
        }

        
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

            if(!FinalProfileRespnseListRollDown.IsEmpty()){
                //upsert FinalProfileRespnseListRollDown;
                Database.UpsertResult[] FinalResList = Database.upsert(FinalProfileRespnseListRollDown,false);
                PMP_Utility.logDmlErrors((Object[]) FinalResList, 'PMP_Acct_Grp_Mbr_TriggerHandler-RollUpLocFlagToOPID');
            }   
            // Since there are no responses are OPID level, but if the location has some data. Then we would clear it to have it in sync with OPID.
            if(!locResponseClearList.IsEmpty()){
                //delete locResponseClearList ;
                Database.DeleteResult[] locClearList = Database.delete(locResponseClearList, false);
				PMP_Utility.logDmlErrors((Object[]) locClearList, 'PMP_Acct_Grp_Mbr_TriggerHandler-RollUpLocFlagToOPID');
            }
        }catch(Exception ex){
            PRM_ErrorUtilityClass.logError(ex);
        }  
       
        
        
    } 
    
    public static void createTrackerMilestonesForOPIDUpdates(List<Core_Account_Group_Member__c> cags, Map<Id,Core_Account_Group_Member__c> oldcagMap) {
        List<PRM_Tracker__c> trackers = new List<PRM_Tracker__c>();
        Core_CustomMetadataObjectController customMetadata = new Core_CustomMetadataObjectController('PRM_Tracker_steps__mdt'); 
        for (Core_Account_Group_Member__c cag: cags) {
            if (oldcagMap == null || (cag.Core_Inactive_Ind__c != oldcagMap.get(cag.Id).Core_Inactive_Ind__c)) {
                trackers.add(PRM_IPA_Utility.createTrackerInstance('OPID Updates',
                cag.Core_Inactive_Ind__c ? 'OPID_REMOVED':'OPID_ASSOCIATED',
                null,
                String.valueOf(cag.Core_Intel_Account_Id__c),
                String.valueOf(cag.Core_Partner_Account_Id__c),
                String.valueOf(cag.Core_Partner_Account_Id__c),
                '',
                '',
                true,
                '',
                ''
                ));
                
                trackers.add(PRM_IPA_Utility.createTrackerInstance('OPID Updates 1PID',
                cag.Core_Inactive_Ind__c ? 'LOC_DISASSC':'LOC_ASSC',
                null,
                String.valueOf(cag.Core_Intel_Account_Id__c),
                String.valueOf(cag.Core_Partner_Account_Id__c),
                String.valueOf(cag.Core_Partner_Account_Id__c),
                '',
                '',
                true,
                '',
                '',                
                cag.Core_Inactive_Ind__c?String.valueOf(customMetadata.getInstance('LOC_DISASSC').get('PRM_Milestone_Display_Name__c')):
                String.valueOf(customMetadata.getInstance('LOC_ASSC').get('PRM_Milestone_Display_Name__c'))                                             
                ));
            }
        }
        if (!trackers.isEmpty()) {
            //insert trackers;
            Database.SaveResult[] trackersList = Database.insert(trackers, false);
			PMP_Utility.logDmlErrors((Object[]) trackersList, 'PMP_Acct_Grp_Mbr_TriggerHandler-createTrackerMilestonesForOPIDUpdates');
        }
    }
    
    
}