/****************************************************************************************************
Apex Class Name : QuoteBusinessLogic
Version         : 1.0 
Created Date    : 01/05/2020
Function        : This class is used used as part of Quote trigger
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Biswa                     01/05/2020               Created
*****************************************************************************************************/
public without sharing class QuoteBusinessLogic{
    
    public static boolean isQTMChanged = true;
    public static boolean isQuoteClone = false;
    public static Boolean isPartnerUser = false;
    public static Set<Id> quotePrimaryContactUpdateIds = new Set<Id>();
    public static Set<Id> contactAccountIdSet = new Set<Id>();
    public static Set<String> quoteIdWithExistingFSE = new Set<String>();
    private static User currentUser =  [SELECT Id,ContactId,contact.accountId,contact.Account.Name,contact.Email,Core_User_Profile_Name__c, (SELECT Id, PermissionSet.Name, AssigneeId, Assignee.ContactId FROM PermissionSetAssignments)
                                        FROM User WHERE Id =: UserInfo.getUserId() and IsActive = true];
    private static Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
    private static Id qtmRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Quote_Team__c',Label.Pricing_Tender_Quote_Team_RecordType);

    public static Map<id,SBQQ__Quote__c> quotesMap = new Map<id,SBQQ__Quote__c>();
    public static Map<Id,Account> accountIdtoRecordMap = new Map<Id, Account>();
    public static Map<Id, Opportunity> quoteIdToOppRecdMap = new Map<Id, Opportunity>();
    public static Map<Id, Set<Id>> quoteIdtoProdMap = new Map<Id, Set<Id>>();
    public static Boolean isVolumeExceptionCheck = false;
    public static Boolean isQuotFirstSubmission = false;
    public static Boolean skipMethodExecution = false;
    public static Set<Id> quoteIdsWithInvalidEndCustomerOpportunityId = new Set<Id>();
    /**
    * @description Share the Quote with Account Team Members
    * @author Subhanku | 12-19-2022 
    * @param List<sObject> quoteList 
    **/
    public static void shareQuotes(List<sObject> quoteList){
        if(quoteList!=null && !quoteList.isEmpty()){
            Map<Id, SBQQ__Quote__c> pvtMap = new Map<Id, SBQQ__Quote__c>((List<SBQQ__Quote__c>)quoteList);
            Map<Id,Set<Id>> quoteIdToTPTIdMap = new Map<Id,Set<Id>>();
            List<SBQQ__Quote__Share> quoteShares = new List<SBQQ__Quote__Share>();
            List<Pricing_Comments__Share> commentShares = new List<Pricing_Comments__Share>();
            List<Pricing_Quote_Line_Status_Age__Share> TPTShare = new List<Pricing_Quote_Line_Status_Age__Share>();
            // Get list of accountId's
            Set<Id> accountIds = new Set<Id>();
            for(SBQQ__Quote__c quote : pvtMap.values()){
                accountIds.add(quote.SBQQ__Account__c);
            }
            if(!accountIds.isEmpty()){
                for(Pricing_Quote_Line_Status_Age__c TPTRec : [SELECT Id,Pricing_TPT_Quote_Line_Number__r.SBQQ__Quote__c from Pricing_Quote_Line_Status_Age__c where Pricing_TPT_Quote_Line_Number__r.SBQQ__Quote__r.SBQQ__Account__c =: accountIds
                                                               and Pricing_TPT_Quote_Line_Number__r.SBQQ__Quote__c IN:pvtMap.keySet()]){
                                                                   if(!quoteIdToTPTIdMap.containsKey(TPTRec.Pricing_TPT_Quote_Line_Number__r.SBQQ__Quote__c)){
                                                                       quoteIdToTPTIdMap.put(TPTRec.Pricing_TPT_Quote_Line_Number__r.SBQQ__Quote__c,new Set<Id>{TPTRec.Id});
                                                                   }else{
                                                                       quoteIdToTPTIdMap.get(TPTRec.Pricing_TPT_Quote_Line_Number__r.SBQQ__Quote__c).add(TPTRec.Id);
                                                                   }
                                                               }
            }
            Map<Id,Set<Id>> accountToGroupIdMap = new  Map<Id,Set<Id>>();
            Map<Id,Set<Id>> accountTPTToGroupIdMap = new  Map<Id,Set<Id>>();
            Set<Id> externalGroupIdSet = new  Set<Id>();
            // Get the Map of Quote and Comments
            Map<Id,SBQQ__Quote__c> mapQuotesWithComments = new Map<Id,SBQQ__Quote__c>([SELECT Id, (SELECT Id FROM Comments__r where recordtypeid =: commentRecordTypeId) from SBQQ__Quote__c WHERE Id IN:pvtMap.keySet()]);
            for(Core_MDF_Partner_Group_Mapping__c partnerGroup : [select Id,Core_MDF_Account__c,Core_MDF_Channel_Program_Name_Txt__c,Core_MDF_Group_Id__c,Core_MDF_Type_of_Access__c from Core_MDF_Partner_Group_Mapping__c where
                                                                  Core_MDF_Channel_Program_Name_Txt__c =: Label.Pricing_Tender_PGM_Channel and   Core_MDF_Account__c in : accountIds and Core_MDF_Group_Id__c!=null]){
                                                                      if(!accountToGroupIdMap.containsKey(partnerGroup.Core_MDF_Account__c)){
                                                                          accountToGroupIdMap.put(partnerGroup.Core_MDF_Account__c,new Set<Id>{partnerGroup.Core_MDF_Group_Id__c});
                                                                      }
                                                                      else {
                                                                          accountToGroupIdMap.get(partnerGroup.Core_MDF_Account__c).add(partnerGroup.Core_MDF_Group_Id__c);
                                                                      }
                                                                      if(!accountTPTToGroupIdMap.containsKey(partnerGroup.Core_MDF_Account__c) && partnerGroup.Core_MDF_Type_of_Access__c == Label.Pricing_Tender_PGM_Type){
                                                                          accountTPTToGroupIdMap.put(partnerGroup.Core_MDF_Account__c,new Set<Id>{partnerGroup.Core_MDF_Group_Id__c});
                                                                      }
                                                                      else if(partnerGroup.Core_MDF_Type_of_Access__c == Label.Pricing_Tender_PGM_Type) {
                                                                          accountTPTToGroupIdMap.get(partnerGroup.Core_MDF_Account__c).add(partnerGroup.Core_MDF_Group_Id__c);
                                                                      }
                                                                      if(partnerGroup.Core_MDF_Type_of_Access__c == 'External'){
                                                                          externalGroupIdSet.add(partnerGroup.Core_MDF_Group_Id__c);
                                                                      }
                                                                  }
            
            for(SBQQ__Quote__c pvt : pvtMap.values()){
                if(accountToGroupIdMap.containsKey(pvt.SBQQ__Account__c) && !(accountToGroupIdMap.get(pvt.SBQQ__Account__c)).isEmpty()){ 
                    createQuoteAndCmntShare(pvt.Id,externalGroupIdSet,accountToGroupIdMap.get(pvt.SBQQ__Account__c),false,mapQuotesWithComments,quoteShares,commentShares);
                }
                if(accountTPTToGroupIdMap.containsKey(pvt.SBQQ__Account__c) && !(accountTPTToGroupIdMap.get(pvt.SBQQ__Account__c)).isEmpty()){ 
                    for(id grpId : accountTPTToGroupIdMap.get(pvt.SBQQ__Account__c)){
                        if(quoteIdToTPTIdMap.containsKey(pvt.Id)){
                            for(Id TPTId : quoteIdToTPTIdMap.get(pvt.Id)){
                                TPTShare.add(new Pricing_Quote_Line_Status_Age__Share(
                                    ParentId = TPTId,
                                    UserOrGroupId = grpId,
                                    AccessLevel = 'Read',
                                    RowCause = Schema.Pricing_Quote_Line_Status_Age__Share.RowCause.Manual
                                ));
                            }
                        }
                    }
                }
            }
            List<Core_Log_Entry__c> logEntryList = new List<Core_Log_Entry__c>();
            if(!quoteShares.isEmpty()){
                Database.SaveResult[] result = Database.insert(quoteShares ,false);
                logEntryList.addAll(getLogEntryRec(result,'Quote Share'));
            }       
            if(!commentShares.isEmpty()){
                Database.SaveResult[] result = Database.insert(commentShares ,false);
                logEntryList.addAll(getLogEntryRec(result,'Comment Share'));
            }            
            if(!TPTShare.isEmpty()){
                Database.SaveResult[] result = Database.insert(TPTShare ,false);
                logEntryList.addAll(getLogEntryRec(result,'TPT Share'));
            }
            if(!logEntryList.isEmpty()){
                insert logEntryList;
            }
        }
    }
    
    /**
    * @description Method to Share Records with AE and Sales Rep Synchronization
    * @author Subhanku | 12-19-2022 
    * @param List<sObject> quoteList 
    * @param Map<Id Set<Id>> quoteIdToAESalesRepShareMap 
    **/
    public static void shareQuotesCommentsWithAESalesRep(List<sObject> quoteList, Map<Id,Set<Id>> quoteIdToAESalesRepShareMap){
        if(quoteList!=null && !quoteList.isEmpty()){
            Map<Id, SBQQ__Quote__c> pvtMap = new Map<Id, SBQQ__Quote__c>((List<SBQQ__Quote__c>)quoteList);
            List<SBQQ__Quote__Share> quoteShares = new List<SBQQ__Quote__Share>();
            List<Pricing_Comments__Share> commentShares = new List<Pricing_Comments__Share>();
            
            // Get the Map of Quote and Comments
            Map<Id,SBQQ__Quote__c> mapQuotesWithComments = new Map<Id,SBQQ__Quote__c>([SELECT Id, (SELECT Id FROM Comments__r where recordtypeid =: commentRecordTypeId) from SBQQ__Quote__c WHERE Id IN:pvtMap.keySet()]);
            
            for(SBQQ__Quote__c pvt : pvtMap.values()){
                if(quoteIdToAESalesRepShareMap.containsKey(pvt.id)){
                    createQuoteAndCmntShare(pvt.Id,null,quoteIdToAESalesRepShareMap.get(pvt.id),true,mapQuotesWithComments,quoteShares,commentShares);
                }   
            }
            List<Core_Log_Entry__c> logEntryList = new List<Core_Log_Entry__c>();
            if(!quoteShares.isEmpty()){
                Database.SaveResult[] result = Database.insert(quoteShares ,false);
                logEntryList.addAll(getLogEntryRec(result,'Quote Share')); 
            }      
            if(!commentShares.isEmpty()){
                Database.SaveResult[] result = Database.insert(commentShares ,false);
                logEntryList.addALL(getLogEntryRec(result,'Comment Share')); 
            }
            
            if(!logEntryList.isEmpty()){
                insert logEntryList;
            }
        }
    }
    
    public static List<Core_Log_Entry__c> getLogEntryRec(Database.SaveResult[] result,String scope){
        List<Core_Log_Entry__c> logEntryLst = new List<Core_Log_Entry__c>();
        String errorMsg ='';
        for(database.SaveResult sr : result){
            if(!sr.issuccess()){
                for(Database.Error err : sr.getErrors()) {
                    errorMsg = err.getMessage();
                }
                core_log_entry__c logEntry = new core_log_entry__c();
                logEntry.Core_sObjectId__c = sr.getId();
                logEntry.Core_Details__c = errorMsg;
                logEntry.Core_Origin__c =  Label.Pricing_IQR_Program_Name;
                logEntry.Core_Project__c = Label.Pricing_IQR_Program_Name;
                logEntry.Core_Severity__c = 'Critical';
                logEntry.Core_Support_Email__c = Label.Pricing_IQR_Support_Email;
                logEntry.Core_Support_Link__c = Label.Pricing_IQR_Support_Link;
                logEntry.Core_Scope__c = scope;
                logEntry.Core_When__c = system.now();
                logEntryLst.add(logEntry); 
            }
        }
        return logEntryLst.isEmpty() ? new List<Core_Log_Entry__c>() : logEntryLst;
    }
    
    /**
    * @description Check if Primary Contact Changes and call the Future Method to update the Owner 
    * @author Subhanku | 12-19-2022 
    * @param List<SBQQ__Quote__c> lstquote 
    * @param Boolean isInsert 
    * @param Map<id SBQQ__Quote__c> oldMap 
    **/
    public static void checkChangeInPrimaryContact(List<SBQQ__Quote__c> lstquote, Boolean isInsert,Map<id,SBQQ__Quote__c> oldMap){
        if(lstquote!=null && !lstquote.isEmpty()){
            Map<Id,Set<Id>> quoteIdToAESalesRepShareMap =new Map<Id,Set<Id>>();
            Set<id> userContactIds = new Set<id>();
            List<SBQQ__Quote__c> quoteListWithOwnerChange = new List<SBQQ__Quote__c>();
            Set<Id> quoteSetWithOwnerChange = new Set<Id>();
            Map<Id,SBQQ__Quote__c> quoteIdToRecMap = new Map<Id,SBQQ__Quote__c>();
            List<SBQQ__Quote__c> quoteListWithPrimaryContactChange = new List<SBQQ__Quote__c>();
            Map<Id,SBQQ__Quote__c> quoteIdToQuoteMap = new Map<Id,SBQQ__Quote__c>();
            Map<Id,Id> quoteCommentShareToDeleteMap = new Map<Id,Id>();
            Boolean isUpdate = !isInsert;
            // Track Quotes where Unified Global End Customer changed and is not null
            Map<Id, SBQQ__Quote__c> ugEndCustomerChangedQuotes = new Map<Id, SBQQ__Quote__c>();
            List<SBQQ__Quote__c> quoteList = new  List<SBQQ__Quote__c>();
            
            Boolean currentUserIsAE = false;
            Boolean currentUserIsSalesRep = false;
            Boolean currentUserIsITS = false;
            Map<Id,String> quoteIdAEEmailAddToQTMMap = new Map<Id,String>();
            Map<Id,String> quoteIdAEEmailRemoveQTMMap = new Map<Id,String>();
            Map<Id,Id> quoteIdAEUserIdMap = new Map<Id,Id>();
            Map<Id,Id> quoteIdAEUserIdRemoveMap = new Map<Id,Id>();
            Map<Id,Id> quoteIdITSAddToQTMMap = new Map<Id,Id>();
            Map<Id,Id> quoteIdFSEUserIdAddQTMMap = new Map<Id,Id>();
            Map<Id,Id> quoteIdFSEUserIdRemoveQTMMap = new Map<Id,Id>();
            List<Pricing_Quote_Team__c> qtmTobeInserted = new List<Pricing_Quote_Team__c>();
            List<Pricing_Quote_Team__c> qtmToBeDeleted = new List<Pricing_Quote_Team__c>();
            Map<Id,SBQQ__Quote__c> quotewithOwnerChangeMap = new Map<Id,SBQQ__Quote__c>();
            List<Id> quoteIdForOnHoldUpdate = new List<Id>();
      List<Pricing_Quote_Hold_Status_Age__c> insertOnHoldRec = new List<Pricing_Quote_Hold_Status_Age__c>();
           
            
            Id currentLoggedInUserId = currentUser.Id;
            for(PermissionSetAssignment ps : currentUser.PermissionSetAssignments){
                if(ps.PermissionSet.Name == Label.Pricing_Tender_PermissionSets_TenderAccountExecutive){
                    currentUserIsAE = true;
                } 
                if(ps.PermissionSet.Name == Label.Pricing_Tender_PermissionSets_TenderUser){
                    currentUserIsSalesRep = true;
                }
                if(ps.PermissionSet.Name == Label.Pricing_Tender_Permission_Set_IT_Specialist){
                    currentUserIsITS = true;
                }
            }
            if(isInsert){
                Set<Id> salesRepMemberAccountIdSet = new Set<Id>();
                if(currentUserIsSalesRep){
                    for(AccountTeamMember accTeam : [SELECT Id,AccountId from AccountTeamMember where UserId =: currentLoggedInUserId]){
                        salesRepMemberAccountIdSet.add(accTeam.AccountId);
                    }
                }
                for (SBQQ__Quote__c quote : lstquote) {
                    //Current Logged in user is a AE or SalesRep provide Access 
                    if(currentUserIsAE || (currentUserIsSalesRep && salesRepMemberAccountIdSet.contains(quote.SBQQ__Account__c))){
                        addToAEorSalesRepShareMap(quote.Id,currentLoggedInUserId,quoteIdToAESalesRepShareMap);
                    }
                    if (quote.Pricing_Account_Executive_Nm__c != null){
                        quoteIdToQuoteMap.put(quote.id,quote);
                        addToAEorSalesRepShareMap(quote.Id,quote.Pricing_Account_Executive_Nm__c,quoteIdToAESalesRepShareMap);
                    }
                    if(currentUserIsAE && currentLoggedInUserId != quote.Pricing_Account_Executive_Nm__c){
                        quoteCommentShareToDeleteMap.put(quote.Id,currentLoggedInUserId);
                    }
                     // Citrus: Auto Populate Intel Account Executive and Intel Account Executive Email
                    if(quote.Pricing_Unified_Global_End_Customer_Nm__c != null){
                    	ugEndCustomerChangedQuotes.put(quote.Pricing_Unified_Global_End_Customer_Nm__c, quote);
                    }
                    
                    if (quote.SBQQ__SalesRep__c != null){
                        quoteIdToQuoteMap.put(quote.id,quote);
                        addToAEorSalesRepShareMap(quote.Id,quote.SBQQ__SalesRep__c,quoteIdToAESalesRepShareMap);
                        quoteIdFSEUserIdAddQTMMap.put(quote.Id,quote.SBQQ__SalesRep__c);
                    }
                    
                    if (quote.SBQQ__PrimaryContact__c != null){
                        quoteIdToQuoteMap.put(quote.id,quote);
                        userContactIds.add(quote.SBQQ__PrimaryContact__c); 
                        quoteListWithPrimaryContactChange.add(quote);
                    }
                    if(quote.Pricing_Intel_Account_Exec_Email_Txt__c != null){
                        quoteIdAEEmailAddToQTMMap.put(quote.Id,quote.Pricing_Intel_Account_Exec_Email_Txt__c);    //Add primary AE as a default Quote Team Member          
                        if(quote.Pricing_Intel_Account_Exec_Email_Txt__c == quote.Pricing_Intel_Sales_Rep_Email_Txt__c){
                            quote.Pricing_Intel_Account_Exec_Email_Txt__c.addError(Label.Pricing_Duplicate_FSE_Error);
                        }
                    }
                    if(currentUserIsITS){
                        quoteIdITSAddToQTMMap.put(quote.Id,UserInfo.getUserId());         //Add ITS to Quote Team on creation of Quote
                    }
                }
                if(!quoteIdITSAddToQTMMap.isEmpty()){
                    qtmTobeInserted.addAll(createITSDefaultQuoteTeamMember(quoteIdITSAddToQTMMap));
                }
                //Citrus change insert
                if(!ugEndCustomerChangedQuotes.isEmpty()){
                    autoPopulateIntelAccountExceutive(ugEndCustomerChangedQuotes,lstquote);
                }

            }
            if(isUpdate){ 
                for (SBQQ__Quote__c quote : lstquote) {

                    if(currentUserIsAE || currentUserIsSalesRep){
                        addToAEorSalesRepShareMap(quote.Id,currentLoggedInUserId,quoteIdToAESalesRepShareMap);
                    }
                    //When Owner Changes all user access are removed
                    if (oldMap.get(quote.id).ownerId != quote.ownerId && quote.ownerId != null){
                        quoteListWithOwnerChange.add(quote);   //List of Quotes whose Ownerid has changed
                        quoteSetWithOwnerChange.add(quote.Id);
                        quoteIdToQuoteMap.put(quote.Id,quote);
                        quotewithOwnerChangeMap.put(quote.Id,quote);
                        
                        //If AE changes Along with Quote Owner share the record Synchronously with Previous AE and Current AE
                        if (oldMap.get(quote.id).Pricing_Account_Executive_Nm__c != quote.Pricing_Account_Executive_Nm__c && oldMap.get(quote.id).Pricing_Account_Executive_Nm__c != null){
                            addToAEorSalesRepShareMap(quote.Id,oldMap.get(quote.id).Pricing_Account_Executive_Nm__c,quoteIdToAESalesRepShareMap);
                            quoteCommentShareToDeleteMap.put(quote.Id,oldMap.get(quote.id).Pricing_Account_Executive_Nm__c);
                        }
                        if(quote.Pricing_Account_Executive_Nm__c != null){
                            addToAEorSalesRepShareMap(quote.Id,quote.Pricing_Account_Executive_Nm__c,quoteIdToAESalesRepShareMap);
                        }
                        
                        //If SalesRep Changes Along with Quote Owner share the record Synchronously with Previous SalesRep and Current SalesRep
                        if (oldMap.get(quote.id).SBQQ__SalesRep__c != quote.SBQQ__SalesRep__c && oldMap.get(quote.id).SBQQ__SalesRep__c != null){
                            addToAEorSalesRepShareMap(quote.Id,oldMap.get(quote.id).SBQQ__SalesRep__c,quoteIdToAESalesRepShareMap);         
                        }
                        
                        if(quote.SBQQ__SalesRep__c != null){
                            addToAEorSalesRepShareMap(quote.Id,quote.SBQQ__SalesRep__c,quoteIdToAESalesRepShareMap);
                        }
                    }else{
                        //If AE changes share the record Synchronously with Previous AE and Current AE
                        if (oldMap.get(quote.id).Pricing_Account_Executive_Nm__c != quote.Pricing_Account_Executive_Nm__c){
                            quoteIdToQuoteMap.put(quote.id,quote);
                            if(quote.Pricing_Account_Executive_Nm__c != null){
                                addToAEorSalesRepShareMap(quote.Id,quote.Pricing_Account_Executive_Nm__c,quoteIdToAESalesRepShareMap);
                            }
                            if(oldMap.get(quote.id).Pricing_Account_Executive_Nm__c != null){
                                quoteCommentShareToDeleteMap.put(quote.Id,oldMap.get(quote.id).Pricing_Account_Executive_Nm__c);
                            }
                        }
                    }
                    //Removal or Update of Quote Team Member based on QuoteAE
                    if(oldMap.get(quote.id).Pricing_Intel_Account_Exec_Email_Txt__c  != quote.Pricing_Intel_Account_Exec_Email_Txt__c){                         
                        if(quote.Pricing_Intel_Account_Exec_Email_Txt__c != null){                           
                            quoteIdAEEmailAddToQTMMap.put(quote.Id,quote.Pricing_Intel_Account_Exec_Email_Txt__c);
                            quoteIdAEEmailRemoveQTMMap.put(quote.Id,oldMap.get(quote.id).Pricing_Intel_Account_Exec_Email_Txt__c);
                        }else{
                            quoteIdAEEmailRemoveQTMMap.put(quote.Id,oldMap.get(quote.id).Pricing_Intel_Account_Exec_Email_Txt__c);
                        }
                        
                    }
                    if(oldMap.get(quote.id).SBQQ__SalesRep__c  != quote.SBQQ__SalesRep__c){
                        if(quote.SBQQ__SalesRep__c != null){                           
                            quoteIdFSEUserIdAddQTMMap.put(quote.id,quote.SBQQ__SalesRep__c);
                            quoteIdFSEUserIdRemoveQTMMap.put(quote.Id,oldMap.get(quote.id).SBQQ__SalesRep__c);
                        }else{
                            quoteIdFSEUserIdRemoveQTMMap.put(quote.Id,oldMap.get(quote.id).SBQQ__SalesRep__c);
                        }
                    }
                    // Citrus: Auto Populate Intel Account Executive and Intel Account Executive Email on update
                    if(oldMap.get(quote.id).Pricing_Unified_Global_End_Customer_Nm__c != quote.Pricing_Unified_Global_End_Customer_Nm__c && quote.Pricing_Unified_Global_End_Customer_Nm__c != null){
                        ugEndCustomerChangedQuotes.put(quote.Pricing_Unified_Global_End_Customer_Nm__c, quote);
                    }
                    if(oldMap.get(quote.id).Pricing_On_Hold_Cb__c != quote.Pricing_On_Hold_Cb__c && quote.Pricing_On_Hold_Cb__c == true){
                        Pricing_Quote_Hold_Status_Age__c onHoldEntry = new Pricing_Quote_Hold_Status_Age__c();
                        onHoldEntry.Pricing_QuoteOnHold__c = quote.Id;
                        onHoldEntry.Pricing_Is_On_Hold__c = quote.Pricing_On_Hold_Cb__c;
                        onHoldEntry.Pricing_Quote_On_Hold_Comment__c = quote.Pricing_On_Hold_Comment__c;
                        onHoldEntry.Pricing_QuoteOnHold_Start_Time__c = System.now();
                        onHoldEntry.Pricing_QuoteOnHold_User_Role__c = currentUserIsSalesRep ? 'SDM' : 'Pricing Manager';
                        insertOnHoldRec.add(onHoldEntry);
                    }
                    
                    if((oldMap.get(quote.id).Pricing_On_Hold_Cb__c != quote.Pricing_On_Hold_Cb__c && quote.Pricing_On_Hold_Cb__c == false) || (oldMap.get(quote.id).Pricing_On_Hold_Comment__c != quote.Pricing_On_Hold_Comment__c)){
                        quoteIdForOnHoldUpdate.add(quote.id);
                    }
                }

                if(!insertOnHoldRec.isEmpty()){
                    insert insertOnHoldRec;
                }
                
                if(!quotewithOwnerChangeMap.isEmpty()){
                    updateOwneronComments(quotewithOwnerChangeMap);
                }
                if(!quoteSetWithOwnerChange.isEmpty()){
                    //Provide access again to Quote Team on Owner Change
                    Pricing_QuoteTeam_Trigger_Handler.createQuoteSharesOnOwnerChange(quoteSetWithOwnerChange);
                } 
                
                if(!quoteIdForOnHoldUpdate.isEmpty()){
                    updateQuoteHoldHistory(quoteIdForOnHoldUpdate);
                }
                
                // Citrus: Auto Populate Intel Account Executive and Intel Account Executive Email
                autoPopulateIntelAccountExceutive(ugEndCustomerChangedQuotes,lstquote);
               
                skipMethodExecution = false;
            }
            
            if(!quoteIdFSEUserIdAddQTMMap.isEmpty()){   
                List<Pricing_Quote_Team__c> fseToBeInserted = createFSEDefaultQuoteTeamMember(quoteIdFSEUserIdAddQTMMap, lstquote, isUpdate);
                if(fseToBeInserted.size() > 0){
                    qtmTobeInserted.addAll(fseToBeInserted);
                }
            }
            
            //if FSE Is getting updated call the reassign method
            if(!quoteIdFSEUserIdAddQTMMap.isEmpty() && !quoteIdFSEUserIdRemoveQTMMap.isEmpty() && isUpdate){
                reassignApprovalRecords(quoteIdFSEUserIdRemoveQTMMap, quoteIdFSEUserIdAddQTMMap, lstquote); 
            }
            
            //Platform Events to quoteSharing
            if(!quoteSetWithOwnerChange.isEmpty()){
                QuoteBusinessLogic.publishIQR(quoteSetWithOwnerChange,Label.Pricing_IQR_Event_Action_Quote_Share);
            }
            
            if(!quoteIdAEEmailAddToQTMMap.isEmpty() && isQTMChanged){
                quoteIdAEUserIdMap = getQuoteIdUserIdMap(quoteIdAEEmailAddToQTMMap);                 
                qtmTobeInserted.addAll(createAEQuoteTeamMember(quoteIdAEUserIdMap, lstquote, isUpdate));               
            }
            
            if(qtmTobeInserted.size() > 0){
                Pricing_QuoteTeam_Trigger_Handler.isInertedFromQuoteTriggerorApi = true;
                insert qtmTobeInserted;
            }
            if(!quoteIdAEEmailRemoveQTMMap.isEmpty()){
                quoteIdAEUserIdRemoveMap = getQuoteIdUserIdMap(quoteIdAEEmailRemoveQTMMap);
                qtmToBeDeleted.addAll(removeAEQuoteTeamMember(quoteIdAEUserIdRemoveMap, lstquote, false));
            }            
            
            if(!quoteIdFSEUserIdRemoveQTMMap.isEmpty()){
                qtmToBeDeleted.addAll(updateFSEQuoteTeamMember(quoteIdFSEUserIdRemoveQTMMap));
            }
            
            if(!qtmToBeDeleted.isEmpty()){
                delete qtmToBeDeleted;
            }
            
            if(!quoteIdToAESalesRepShareMap.isEmpty()){
                //Share Quote and Comments with SalesRep and AE Synchronously
                shareQuotesCommentsWithAESalesRep((List<SBQQ__Quote__c>)quoteIdToQuoteMap.values(),quoteIdToAESalesRepShareMap);
            }
            if(!quoteCommentShareToDeleteMap.isEmpty() && !System.isBatch()){
                //Future Method to Delete the Old AE Sharing Records
                deleteShareQuoteFuture(quoteCommentShareToDeleteMap);
            }
            if(!quotePrimaryContactUpdateIds.isEmpty() && !Test.isRunningTest()){
                changeOwnerId(isInsert ? quoteIdToQuoteMap.keySet() :quotePrimaryContactUpdateIds);
            }
            
        }
        
    }
    
    /**
* @description Resolve Intel Account for Quotes by Unified Global End Customer change
* @param Map<Id, SBQQ__Quote__c> ugEndCustomerChangedQuotes
* @return Map<Id, Account> QuoteId to Intel Account record
*/
    private static Map<Id, Account> getIntelAccByUnifiedEndCustomer(Map<Id, SBQQ__Quote__c> ugEndCustomerChangedQuotes){
        Map<Id, Account> quoteToIntelAccMap = new Map<Id, Account>();
        Set<String> accountOwnerEmail = new Set<String>();
        Map<String, Id> accountExecutiveAssignment = new Map<String, Id>();
        Map<String, Id> userEmailToUserHaveAEPermission = new Map<String, Id>();
        Set<String> validEmailIds = new Set<String>();      
        Map<String, Account> ownerEmailToAccount = new Map<String, Account>();
        if(ugEndCustomerChangedQuotes.isEmpty()){
            return quoteToIntelAccMap;
        }
        
        //Query Unified End Customer Country Mapping records (L2) for the L2 Ids on the quotes
        Map<Id, Pricing_UnifiedEndCustomerCountryMapping__c> l2IdToRecMap = new Map<Id, Pricing_UnifiedEndCustomerCountryMapping__c>(
            [SELECT Id, Pricing_RequestID__c,Pricing_RequestID__r.Core_Parent_Business_Party_Id__c
             FROM Pricing_UnifiedEndCustomerCountryMapping__c
             WHERE Id IN :ugEndCustomerChangedQuotes.keySet()]
        );
        
        //Collect Parent Unified Id (Parent Business Party Id )
        Set<String> parentUnifiedIds = new Set<String>();
        for(Id qId : ugEndCustomerChangedQuotes.keySet()){
            if(l2IdToRecMap.containsKey(qId) && l2IdToRecMap.get(qId).Pricing_RequestID__c!=null && String.isNotBlank(l2IdToRecMap.get(qId).Pricing_RequestID__r.Core_Parent_Business_Party_Id__c) ){
                parentUnifiedIds.add(l2IdToRecMap.get(qId).Pricing_RequestID__r.Core_Parent_Business_Party_Id__c);
            }
        }
        if(parentUnifiedIds.isEmpty()){
            return quoteToIntelAccMap;
        }
        
        //Query Intel Accounts with Business Party Id and Record Type = Intel Account
        Id intelRtId = Pricing_Tender_Utility.getRecordTypeId('Account', 'Mastered_Account');
        Map<String, Account> bpIdToAccount = new Map<String, Account>();
        for(Account acc : [SELECT Id, OwnerId, Owner.Email, Core_Business_Party_Id__c,Core_Covered_Account__c
                           FROM Account
                           WHERE Core_Business_Party_Id__c IN :parentUnifiedIds and RecordTypeId = :intelRtId and Core_Covered_Account__c = true]){
                               if(acc.Owner!=null && String.isNotBlank(acc.Owner.Email)){
                                   accountOwnerEmail.add(acc.Owner.Email);
                                   ownerEmailToAccount.put(acc.Owner.Email , acc);
                               }
                           }
        
        getAccountExecutiveMap(accountOwnerEmail, accountExecutiveAssignment, validEmailIds, userEmailToUserHaveAEPermission);
        skipMethodExecution = true;
        
        for(String ownerEmail : ownerEmailToAccount.keyset()){
            
            
            if(validEmailIds.contains(ownerEmail) && userEmailToUserHaveAEPermission.containsKey(ownerEmail) && String.isNotBlank(ownerEmailToAccount.get(ownerEmail).Core_Business_Party_Id__c)){
                bpIdToAccount.put(ownerEmailToAccount.get(ownerEmail).Core_Business_Party_Id__c, ownerEmailToAccount.get(ownerEmail));
            }
        }
        
        //Map back Intel Account to respective Quotes
        for(Id ugECId : ugEndCustomerChangedQuotes.keySet()){
            Pricing_UnifiedEndCustomerCountryMapping__c l2Record = l2IdToRecMap.get(ugECId);
            if(l2Record != null && bpIdToAccount.containsKey(l2Record.Pricing_RequestID__r.Core_Parent_Business_Party_Id__c)){
                quoteToIntelAccMap.put(ugEndCustomerChangedQuotes.get(ugECId).Id, bpIdToAccount.get(l2Record.Pricing_RequestID__r.Core_Parent_Business_Party_Id__c));
            }
        }
        return quoteToIntelAccMap;
    }    
    @future
    public static void updateQuoteHoldHistory(List<Id> quoteIdForOnHoldUpdate){
        List<Pricing_Quote_Hold_Status_Age__c> onHoldRec = [select id,Pricing_QuoteOnHold__r.Pricing_On_Hold_Comment__c,Pricing_QuoteOnHold__r.Pricing_On_Hold_Cb__c from Pricing_Quote_Hold_Status_Age__c where Pricing_QuoteOnHold__c in : quoteIdForOnHoldUpdate and Pricing_Is_On_Hold__c = true and Pricing_QuoteOnHold_End_Time__c = null order by createdDate desc];
        for(Pricing_Quote_Hold_Status_Age__c onHold: onHoldRec){
            if(onHold.Pricing_QuoteOnHold__r.Pricing_On_Hold_Cb__c){
                onHold.Pricing_Quote_On_Hold_Comment__c = onHold.Pricing_QuoteOnHold__r.Pricing_On_Hold_Comment__c;
            }
            else{
                onHold.Pricing_Is_On_Hold__c = false;
                onHold.Pricing_QuoteOnHold_End_Time__c = System.now();
                onHold.Pricing_Quote_On_Hold_Comment__c = onHold.Pricing_QuoteOnHold__r.Pricing_On_Hold_Comment__c;
            }
        }
        SBQQ.TriggerControl.disable();
        update onHoldRec;
        SBQQ.TriggerControl.enable();
    }

    @future
    public Static void changeOwnerId(Set<Id> quoteIdLst){
        List<SBQQ__Quote__c> quotePrimaryContactUpdate = new List<SBQQ__Quote__c>([select id,Pricing_Primary_Contact_Email__c from SBQQ__Quote__c where id in : quoteIdLst]);
        List<String> primaryEmailList = new List<String>();
        for(SBQQ__Quote__c quote: quotePrimaryContactUpdate){
            primaryEmailList.add(quote.Pricing_Primary_Contact_Email__c);
        }
        Map<String,Id> emailToUsrIdMap = new Map<String,Id>(); 
        for(User usr: [select id,Email from User where Email IN :primaryEmailList]){
            emailToUsrIdMap.put(usr.email,usr.id);
        }
        for(SBQQ__Quote__c quote: quotePrimaryContactUpdate){
            quote.OwnerId = emailToUsrIdMap.get(quote.Pricing_Primary_Contact_Email__c);
        }
        try {
             SBQQ.TriggerControl.disable();
            update quotePrimaryContactUpdate;
            SBQQ.TriggerControl.enable();
        } catch (exception ex){
              Pricing_Tender_Utility.logError(ex);
        }
    }
    
    /**
    * @description delete quote shares after removing the AE
    * @author Subhanku | 12-19-2022 
    * @param Map<Id Id> aeoldQuoteIdMap 
    **/
    @future
    public static void deleteShareQuoteFuture(Map<Id,Id> aeoldQuoteIdMap){
        List<SBQQ__Quote__Share> quoteShareList=new List<SBQQ__Quote__Share>();
        List<Pricing_Comments__Share> commentShareList=new List<Pricing_Comments__Share>();
        List<Pricing_Quote_Line_Status_Age__Share> TPTShareList = new List<Pricing_Quote_Line_Status_Age__Share>();
        if(!aeoldQuoteIdMap.isEmpty()){
            for(SBQQ__Quote__Share share : [select id,ParentId,UserOrGroupId,RowCause from SBQQ__Quote__Share where ParentId IN : aeoldQuoteIdMap.keySet() and UserOrGroupId IN : aeoldQuoteIdMap.values() and RowCause =: Schema.SBQQ__Quote__Share.RowCause.Manual]){ 
                if(aeoldQuoteIdMap.containsKey(share.ParentId) && share.UserOrGroupId == aeoldQuoteIdMap.get(share.ParentId)){
                    quoteShareList.add(share);
                }
            }
            for(Pricing_Comments__Share commentShare : [select id,ParentId,Parent.Pricing_Quote__c,UserOrGroupId,RowCause from Pricing_Comments__Share where Parent.recordtypeid =: commentRecordTypeId and Parent.Pricing_Quote__c IN : aeoldQuoteIdMap.keySet() and UserOrGroupId IN : aeoldQuoteIdMap.values() and RowCause =: Schema.SBQQ__Quote__Share.RowCause.Manual]){
                if(aeoldQuoteIdMap.containsKey(commentShare.Parent.Pricing_Quote__c) && commentShare.UserOrGroupId == aeoldQuoteIdMap.get(commentShare.Parent.Pricing_Quote__c)){
                    commentShareList.add(commentShare);
                }
            }
            //TPT share records added to list for deletion.
            for(Pricing_Quote_Line_Status_Age__Share TPTShareRec : [SELECT Id, ParentId,Parent.Pricing_TPT_Quote_Line_Number__r.SBQQ__Quote__r.SBQQ__Account__c,
                                                                    Parent.Pricing_TPT_Quote_Line_Number__r.SBQQ__Quote__r.Pricing_Account_Executive_Nm__c,
                                                                    UserOrGroupId, AccessLevel, RowCause FROM Pricing_Quote_Line_Status_Age__Share where 
                                                                    Parent.Pricing_TPT_Quote_Line_Number__r.SBQQ__Quote__c IN : aeoldQuoteIdMap.keySet() 
                                                                    and UserOrGroupId IN : aeoldQuoteIdMap.values() and RowCause =: Schema.Pricing_Quote_Line_Status_Age__Share.RowCause.Manual]){
                                                                        if(aeoldQuoteIdMap.containsKey(TPTShareRec.Parent.Pricing_TPT_Quote_Line_Number__r.SBQQ__Quote__c)
                                                                           && aeoldQuoteIdMap.get(TPTShareRec.Parent.Pricing_TPT_Quote_Line_Number__r.SBQQ__Quote__c) == TPTShareRec.UserOrGroupId){
                                                                               TPTShareList.add(TPTShareRec);
                                                                           }
                                                                    }
            
            if(!quoteShareList.isEmpty()){
                delete quoteShareList;
            }
            if(!commentShareList.isEmpty()){
                delete commentShareList;
            }
            if(!TPTShareList.isEmpty()){
                delete TPTShareList;
            }
        }
    }
    
    /**
    * @description: Get the list of Quote Comments questions set from the custom metadata
    * @author Bharath | 05-26-2022 
    * @param
    * @return List<Core_CPQ_Tender_Comments__mdt>> 
    **/
    private static Map<String,List<Core_CPQ_Tender_Comments__mdt>> RetrieveComments(){
        List<Core_CPQ_Tender_Comments__mdt> result = new List<Core_CPQ_Tender_Comments__mdt>();
        Map<String,List<Core_CPQ_Tender_Comments__mdt>> commentsMetaDataMap = new Map<String,List<Core_CPQ_Tender_Comments__mdt>>();
        try{
            result = [select Pricing_Question__c,Label,Pricing_Business_Unit_Pkl__c,Pricing_Required_Ind__c,Pricing_Comment_Ref_Id__c 
                      from Core_CPQ_Tender_Comments__mdt ORDER BY Label LIMIT 50];
            commentsMetaDataMap.put(Label.Pricing_Tender_CCG_Quote,new List<Core_CPQ_Tender_Comments__mdt>());
            commentsMetaDataMap.put(Label.Pricing_Tender_Standard_Quote,new List<Core_CPQ_Tender_Comments__mdt>());
            for(Core_CPQ_Tender_Comments__mdt comm: result){
                if(comm.Pricing_Business_Unit_Pkl__c == Label.Pricing_Tender_CCG_Quote){
                    commentsMetaDataMap.get(Label.Pricing_Tender_CCG_Quote).add(comm);
                }
                else{
                    commentsMetaDataMap.get(Label.Pricing_Tender_Standard_Quote).add(comm);
                }
            }
        }catch(exception ex){Pricing_Tender_Utility.logError(ex);}
        return commentsMetaDataMap;
    }
    
    /**
    * @description: Method to insert Quote Comments and associate the quote comments to the Quote on after insert of the Quote record
    * @author Bharath | 05-26-2022 
    * @param List<SBQQ__Quote__c> lstquote
    * @return 
    **/
    public static void updateQuoteCommnents(List<SBQQ__Quote__c> lstquote){
        if(lstquote!=null && !lstquote.isEmpty()){
            List<Pricing_Comments__c> tobeInserted = new List<Pricing_Comments__c>();
            Map<String,List<Core_CPQ_Tender_Comments__mdt>> metadata = RetrieveComments();        
            Map<Id, SBQQ__Quote__c> mapQuoteDtls = new Map<Id, SBQQ__Quote__c>();
            try{
                Map<Id, SBQQ__Quote__c> lstquoteMap = new Map<Id, SBQQ__Quote__c>(lstquote);
                List<SBQQ__Quote__c> listQuote = [SELECT Id,OwnerId FROM SBQQ__Quote__c WHERE Id IN: lstquoteMap.keyset()];
                For(SBQQ__Quote__c quote:listQuote){
                    if(quote.OwnerId != null){
                        mapQuoteDtls.put(quote.Id,quote);
                    }
                }
                Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosById();
                
                for(SBQQ__Quote__c qt:lstquote){
                    if(rtMap.get(qt.RecordTypeId).getDeveloperName() == Label.Pricing_Tender_Quote_RecordType_Edit || rtMap.get(qt.RecordTypeId).getDeveloperName() == Label.Pricing_Tender_Client_Quote_RecordType_Edit){
                        for(Core_CPQ_Tender_Comments__mdt mdt:metadata.get((qt.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_Quote || qt.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote)?Label.Pricing_Tender_Standard_Quote:Label.Pricing_Tender_CCG_Quote)){
                            Pricing_Comments__c record = new Pricing_Comments__c();
                            record.Pricing_Quote__c = qt.Id;
                            record.Pricing_Question__c = mdt.Pricing_Question__c;
                            record.Pricing_Required_Ind__c = mdt.Pricing_Required_Ind__c;
                            record.Pricing_Comment_Ref_Id__c = mdt.Pricing_Comment_Ref_Id__c;
                            record.OwnerId = mapQuoteDtls.get(qt.Id).OwnerId;
                            record.recordtypeid = commentRecordTypeId;
                            tobeInserted.add(record);
                        }
                    }
                }
                
                if(toBeInserted.size() > 0){
                    Database.insert(toBeInserted, false);
                }                                   
            }catch(exception ex){Pricing_Tender_Utility.logError(ex);}  
        }
    }
    
    
    /**
    * @description Insert Document Share Record on After Insert of Quote
    * @author Subhanku | 12-19-2022 
    * @param List<SBQQ__Quote__c> lstquote 
    **/
    public static void insertDocumentShareOnQuote(List<SBQQ__Quote__c> lstquote){
        if(lstquote!=null && !lstquote.isEmpty()){
            List<Pricing_Document__c> docInsertList=new List<Pricing_Document__c>();
            Group shareQueue = null;
            try{
                if(shareQueue == null){
                    shareQueue = [Select Id from Group where DeveloperName =:Label.Pricing_Document_Queue_Name];
                } 
                for(SBQQ__Quote__c qt : lstquote){
                    Pricing_Document__c record = new Pricing_Document__c();
                    record.Name = qt.Pricing_Program_Type_Nm__c == 'Financial Incentive' ? Label.Pricing_Financial_Incentive_Document_Share_Record_Name : Label.Pricing_Document_Share_Record_Name;
                    record.Pricing_Quote_Id__c = qt.Id;
                    record.OwnerId = shareQueue.Id;
                    docInsertList.add(record);
                }       
                if(docInsertList.size()>0){
                    Database.insert(docInsertList, false); 
                }
            }catch(exception ex){Pricing_Tender_Utility.logError(ex);}  
        }  
    }
    
    //-----------------------Start - Refactored code------------------------------------------------------------------------------------//
    /**
    * @description Method called from before trigger to update the quote details based on values
    * @author Subhanku | 12-19-2022 
    * @param List<SBQQ__Quote__c> lstquote 
    * @param Boolean isInsert 
    * @param Map<Id SBQQ__Quote__c> oldMap 
    **/
    public static void updateQuoteDetails(List<SBQQ__Quote__c> lstquote, Boolean isInsert,Map<Id,SBQQ__Quote__c> oldMap) {
        if(lstquote!=null && !lstquote.isEmpty()){
            try{
                Id partnerAccountId;
                boolean hasAPIPermissionSet = false;
                Set<id> userContactIds = new Set<id>();
                // Variables for Sales rep validation and assigment
                Set<String> oemEmailIds = new Set<String>();
                Map<String, PermissionSetAssignment> salesRepAssignment = new Map<String, PermissionSetAssignment>();
                // Variables for Account executive
                Set<String> accountExecutiveEmailId = new Set<String>();
                Map<String, Id> accountExecutiveAssignment = new Map<String, Id>();
                Map<String, Id> accountExecutiveSelfAssignment = new Map<String, Id>();
                Set<String> validEmailIdSet = new Set<String>();
                
                // Variable to store contact details and user object details
                Map<Id, User> userContactDtls = new Map<Id, User>();
                
                // Opportunity validation variables
                Map<String,id> opportunityIdToQuoteId = new Map<String,id>();
                Map<String, Opportunity> opportunityDetails = new Map<String, Opportunity>();
                Map<Id,Set<String>> accountIdToSalesRepEmailMap = new Map<Id,Set<String>>();
                Map<Id,Set<String>> accountToValidEmailMap = new Map<Id,Set<String>>();
                Boolean isUpdate = !isInsert;
                Set<Id> accountIdSet = new Set<Id>();
                Map<Id,String> accountIdNameMap = new Map<Id,String>();
                Set<Id> endCustomerIdSet = new Set<Id>();
                Map<Id,String> endCustomerIdNameMap = new Map<Id,String>();
                Set<Id> accountIdSVDSet = new Set<Id>();
                Map<Id,Integer> accountIdSVDQuoteNumberMap = new Map<Id,Integer>();
                Boolean isFSEUser = false;
                Boolean isRPMUser = false;
                Map<Id,Boolean> quoteIdtoIsFSEUserMap = new Map<Id,Boolean>();
                Set<String> userEmailSetFI = new Set<String>();
                Map<String,Id> userEmailtoIdMapFI = new Map<String,Id>();
                Boolean isFIQuote = false;
                
                Id EditId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Edit);
                Id EditIdClient = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Client_Quote_RecordType_Edit);
                Id SubmittedIdFinancialIncentive = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_FinancialIncentive_Quote_RecordType_Submitted);
                Id ReadOnlyIdFinancialIncentive = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_FinancialIncentive_Quote_RecordType_ReadOnly);
                
                Map<Id,Id> quoteIdAEUserIdRemoveMap = new Map<Id,Id>();
                //List to update Unified Global End customer name on Quote
                List<SBQQ__Quote__c> updateUnifiedEndQuoteList = new List<SBQQ__Quote__c>();
                List<String> primaryEmailList = new List<String>();
                List<String> primaryContactIdList = new List<String>();
                
                for (SBQQ__Quote__c quote : lstquote){
                    quotesMap.put(quote.id,quote);
                    if(quote.Pricing_Primary_Contact_Email__c != null){
                        primaryEmailList.add (quote.Pricing_Primary_Contact_Email__c);
                    }
                    if(quote.SBQQ__PrimaryContact__c != null){
                        primaryContactIdList.add (quote.SBQQ__PrimaryContact__c);
                    }
                   
                    
                    //Low Touch No Touch
                    if (isUpdate && quote.Pricing_Route_Rule_Name_Txt__c != oldMap.get(quote.Id).Pricing_Route_Rule_Name_Txt__c && !String.isBlank(quote.Pricing_Pricing_Manager__c) 
                         && (quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_Quote || quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote)) {
                            quote.Pricing_Pricing_Manager_Group_Name_Txt__c = null;
                            quote.Pricing_Pricing_Manager_Group_Label_Txt__c = null;
                           
                        }else if (isUpdate && quote.Pricing_Route_Rule_Name_Txt__c != oldMap.get(quote.Id).Pricing_Route_Rule_Name_Txt__c && !String.isBlank(quote.Pricing_Pricing_Manager_Group_Name_Txt__c) 
                         && (quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_Quote || quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote)) {
                            quote.Pricing_Pricing_Manager__c = null;
                           
                        }
                    if (isUpdate && FeatureManagement.checkPermission('Pricing_Tender_Regional_Pricing_Manager') && quote.Pricing_Route_Rule_Name_Txt__c == oldMap.get(quote.Id).Pricing_Route_Rule_Name_Txt__c && quote.Pricing_Pricing_Manager__c != oldMap.get(quote.Id).Pricing_Pricing_Manager__c && !String.isBlank(quote.Pricing_ReRouting_Reason_Nm__c) &&
                        (quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_Quote || quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote)) {
                            quote.Pricing_Route_Rule_Name_Txt__c = null;
                            quote.Pricing_Pricing_Manager_Group_Name_Txt__c = null;
                            quote.Pricing_Pricing_Manager_Group_Label_Txt__c = null;
                            quote.Pricing_Route_Rule_Id_Txt__c = null;
                        }
                }
               
                List<String> apiUserPermissionSets = label.Pricing_IQR_API_UserPermissionSets.split(',');
                for (PermissionSetAssignment psa : currentUser.PermissionSetAssignments) {
                    if(apiUserPermissionSets.contains(psa.PermissionSet.Name)){
                        hasAPIPermissionSet = true;
                    }
                    if(psa.PermissionSet.Name == Label.Pricing_Tender_PermissionSets_TenderUser) {
                        isFSEUser = true;
                    }
                    if(psa.PermissionSet.Name == Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager) {
                        isRPMUser = true;
                    }
                }

                for(Pricing_Quote_Hold_Status_Age__c quoteHoldAge: [Select Id, Pricing_QuoteOnHold__c, Pricing_QuoteOnHold_User_Role__c
                                                                    FROM Pricing_Quote_Hold_Status_Age__c WHERE Pricing_QuoteOnHold__c IN: quotesMap.keySet() AND Pricing_Is_On_Hold__c = true ORDER By CreatedDate DESC]){
                                                                  
                                                                    if(quoteHoldAge.Pricing_QuoteOnHold_User_Role__c == 'SDM'){
                                                                        quoteIdtoIsFSEUserMap.put(quoteHoldAge.Pricing_QuoteOnHold__c, true);
                                                                    }
                                                                    else{
                                                                        quoteIdtoIsFSEUserMap.put(quoteHoldAge.Pricing_QuoteOnHold__c, false);
                                                                    }
                }
                
                if(currentUser.Core_User_Profile_Name__c == Label.Pricing_Tender_Profiles_Partner && !hasAPIPermissionSet){
                    partnerAccountId = currentUser.contact.accountId;
                    isPartnerUser = true;
                    userContactIds.add(currentUser.ContactId);
                    contactAccountIdSet.add(currentUser.ContactId);
                }
                
                Map<String,Id> emailToContactIdMap = new Map<String,Id>();
                Map<Id,String> contactIdToEmailMap = new Map<Id,String>(); 
                for(Contact con: [select id,Email,AccountId from Contact where Email IN :primaryEmailList or Id IN :primaryContactIdList]){
                    emailToContactIdMap.put(con.email,con.id);
                    contactIdToEmailMap.put(con.id,con.email);
                    if(con.AccountId == partnerAccountId){
                        contactAccountIdSet.add(con.id);
                    }
                }
                
                if(isInsert){
                    // Get the price book Id
                    Id priceBookId = [SELECT Id FROM Pricebook2 WHERE Name = 'DCG Price Book' LIMIT 1].Id;
                    
                    for (SBQQ__Quote__c quote : lstquote){

                        if(quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote) {
                            isFIQuote = true;
                        }

                        // TWC1972-4065 : Remove special sequence characters in text fields
                        quote.Pricing_Customer_Nm__c = String.isBlank(quote.Pricing_Customer_Nm__c) ? quote.Pricing_Customer_Nm__c : String.valueOf(quote.Pricing_Customer_Nm__c.unescapeJava()).replaceAll('[\\t\\n\\r]', '').replaceAll( '\\s+', ' ');
                        quote.Pricing_Project_Name_Nm__c = String.isBlank(quote.Pricing_Project_Name_Nm__c) ? quote.Pricing_Project_Name_Nm__c : String.valueOf(quote.Pricing_Project_Name_Nm__c.unescapeJava()).replaceAll('[\\t\\n\\r]', '').replaceAll( '\\s+', ' ');
                        
                        populatePrimaryContactAndAccount(quote,partnerAccountId,userContactIds,emailToContactIdMap,contactIdToEmailMap);
                        
                        //To populate folio name
                        accountIdSet.add(quote.SBQQ__Account__c);
                        if(quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote && !accountIdSVDSet.contains(quote.SBQQ__Account__c)){
                            accountIdSVDSet.add(quote.SBQQ__Account__c);
                        }

                        if(quote.Pricing_Customer_Nm__c == null){
                            endCustomerIdSet.add(quote.Pricing_End_Customer__c);
                        }
                        
                        if(quote.Pricing_Intel_Sales_Rep_Email_Txt__c != null){
                            oemEmailIds.add(quote.Pricing_Intel_Sales_Rep_Email_Txt__c);
                            userEmailSetFI.add(quote.Pricing_Intel_Sales_Rep_Email_Txt__c); //FI
                            if(quote.SBQQ__Account__c != null){
                                getAccountToSalesRepEmailMap(quote,quote.Pricing_Intel_Sales_Rep_Email_Txt__c,accountIdToSalesRepEmailMap);
                            }
                        }
                        
                        if(quote.Pricing_Intel_Account_Exec_Email_Txt__c != null ){
                            accountExecutiveEmailId.add(quote.Pricing_Intel_Account_Exec_Email_Txt__c);
                            userEmailSetFI.add(quote.Pricing_Intel_Account_Exec_Email_Txt__c); //FI
                        }else{
                            accountExecutiveEmailId.add(UserInfo.getUserEmail());
                        } 
                        // Assign initial status price book and recordtypeid
                        quote.SBQQ__Status__c = quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote?Label.Pricing_Tender_Quote_Status_Submitted:Label.Pricing_Tender_Quote_Status_Draft;
                        quote.RecordTypeId = quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ? EditIdClient : quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote ? SubmittedIdFinancialIncentive : EditId;
                        quote.SBQQ__PricebookId__c = priceBookId;
                        quote.SBQQ__QuoteTemplateId__c = quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote? Label.Pricing_FI_QuoteLetterEmailNotificationTemplate:Label.Pricing_Quote_Template;

                        //To update Unified Global End customer on Insert
                        if(quote.Pricing_End_Customer__c!=null && quote.Pricing_Customer_Nm__c == null && !updateUnifiedEndQuoteList.contains(quote)){
                            updateUnifiedEndQuoteList.add(quote);
                        }
                    }

                    //Populate folio Id Name
                    if(!accountIdSet.isEmpty()){
                        getAccountToNameMap(accountIdSet,accountIdNameMap);
                    }

                    if(!endCustomerIdSet.isEmpty()){
                        getEndCustIdToNameMap(endCustomerIdSet,endCustomerIdNameMap);
                    }
                    
                    if(!userContactIds.isEmpty()){
                        getUsrContactDtlsMap(userContactIds,userContactDtls);
                    }

                    //Check Cap size volume for SVD Quotes
                    if(!accountIdSVDSet.isEmpty()){
                        getSVDCapSizeMap(accountIdSVDSet,accountIdSVDQuoteNumberMap);
                    }

                    //Populate Account Name for Quote Letter
                   if(!quotesMap.isEmpty()){
                        accountNamePopulate(quotesMap, accountIdtoRecordMap,false);
                    } 
                    
                    //Check Cap size volume for SVD Quotes 
                    if(!accountIdSVDQuoteNumberMap.isEmpty()){
                        checkSVDMaxVolume(accountIdSVDQuoteNumberMap,lstquote);
                    }
                    

                    // Get sales rep assignment
                    if(!hasAPIPermissionSet){
                    accountToValidEmailMap = getSalesrepMap(oemEmailIds, accountIdToSalesRepEmailMap, salesRepAssignment);
                    }
                    getAccountExecutiveMap(accountExecutiveEmailId, accountExecutiveAssignment, validEmailIdSet, accountExecutiveSelfAssignment);
                    if(isFIQuote){
                        getUserIdsMapFI(userEmailSetFI, userEmailtoIdMapFI);
                    }

                    // Validate PrimaryContact, SalesRep, AccountExecutive
                    for(SBQQ__Quote__c quote2 : lstquote) {
                        if(quote2.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote) {
                            quote2.SBQQ__SalesRep__c = userEmailtoIdMapFI.containsKey(quote2.Pricing_Intel_Sales_Rep_Email_Txt__c) ? userEmailtoIdMapFI.get(quote2.Pricing_Intel_Sales_Rep_Email_Txt__c) : quote2.SBQQ__SalesRep__c;
                            quote2.Pricing_Account_Executive_Nm__c = userEmailtoIdMapFI.containsKey(quote2.Pricing_Intel_Account_Exec_Email_Txt__c) ? userEmailtoIdMapFI.get(quote2.Pricing_Intel_Account_Exec_Email_Txt__c) : '';
                        }
                        if(quote2.Pricing_Program_Type_Nm__c != Label.Pricing_Tender_FinancialIncentive_Quote){
                            validatePrimaryContact(userContactDtls, quote2);
                            validateAccountExecutive(accountExecutiveAssignment, quote2, accountExecutiveSelfAssignment, quote2.Pricing_Intel_Sales_Rep_Email_Txt__c);
                            checkValidAccountExecutiveEmail(validEmailIdSet, quote2);
                            }
                        if(!hasAPIPermissionSet && quote2.Pricing_Program_Type_Nm__c != Label.Pricing_Tender_FinancialIncentive_Quote && quote2.Pricing_Intel_Sales_Rep_Email_Txt__c != null && !TriggerHandler.isActive('Pricing_Prevent_Sales_Rep_Validation')){
                            validateSalesRep(accountToValidEmailMap, quote2,salesRepAssignment); 
                        }         
                        //Populate Folio Id Name
                        if(quote2.Pricing_My_Deals_Folio_Name_Nm__c == null && quote2.Pricing_Program_Type_Nm__c != Label.Pricing_Tender_FinancialIncentive_Quote) {
                            populateFolioIdAndName(quote2,accountIdNameMap,endCustomerIdNameMap);
                        }

                        //Validate Quote Text Area fields and throw error if Non latin characters are present 
                        validateQuoteTextFieldsForLatinChars(quote2,oldMap,true); 
                    }  
                }

                if(isUpdate){
                    Set<Id> quoteIdWithSalesRepChange = new Set<Id>();
                    Set<Id> quoteIdWithPrimaryContactChange = new Set<Id>();
                    Set<Id> quoteIdWithOwnerChange = new Set<Id>();
                    Set<Id> quoteIdWithaccountExecutiveChange = new Set<Id>();
                    Set<Id> contactIdWithDrafterLimitedSet = new Set<Id>();
                    Set<Id> allPrimaryContactIds = new Set<Id>();                    
                    Map<Id,Decimal> quoteIdWithPrecedenceNumber = new Map<Id,Decimal>();
                    Map<Decimal,String> quoteLineNumberToStatusMap = new Map<Decimal,String>(); 
                    Map<Decimal,String> quoteLineNumberToRecordTypeMap = new Map<Decimal,String>();
                    Map<Decimal,String> quoteLineNumberToClientRecordTypeMap = new Map<Decimal,String>();
                    Map<Decimal,String> quoteLineNumberToFinancialIncentiveRecordTypeMap = new Map<Decimal,String>();
                    Map<String,Id> oppIdtoQuoteIdMap = new Map<String,Id>();
                    Map<Id, Boolean> quoteIdwithProdMap = new Map<Id, Boolean>();
                    Map<Id, Boolean> quoteIdvalidEndCustomerMap = new Map<Id, Boolean>();
                    Set<String> accountIds = new Set<String>();
                    
                    getQuoteStatusAndRecTypeMap(quoteLineNumberToStatusMap,quoteLineNumberToRecordTypeMap,quoteLineNumberToClientRecordTypeMap,quoteLineNumberToFinancialIncentiveRecordTypeMap,SubmittedIdFinancialIncentive,ReadOnlyIdFinancialIncentive,EditId,EditIdClient);
                    
                    Set<Id> quoteIdWithFolioNameChangeSet = new Set<Id>();
                    Set<Id> quoteIdWithFolioErrorSet = new Set<Id>(); 
                    Set<Id> quoteIdWithStartDatechange = new Set<Id>();
                    List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();

                    for (SBQQ__Quote__c quote : lstquote){

                        // TWC1972-4065 : Remove special sequence characters in text field
                        quote.Pricing_Customer_Nm__c = (!String.isBlank(quote.Pricing_Customer_Nm__c) && quote.Pricing_Customer_Nm__c != oldMap.get(quote.Id).Pricing_Customer_Nm__c) ? String.valueOf(quote.Pricing_Customer_Nm__c.unescapeJava()).replaceAll('[\\t\\n\\r]', '').replaceAll( '\\s+', ' ') : quote.Pricing_Customer_Nm__c;
                        quote.Pricing_Project_Name_Nm__c = !String.isBlank(quote.Pricing_Project_Name_Nm__c) && quote.Pricing_Project_Name_Nm__c != oldMap.get(quote.Id).Pricing_Project_Name_Nm__c ? String.valueOf(quote.Pricing_Project_Name_Nm__c.unescapeJava()).replaceAll('[\\t\\n\\r]', '').replaceAll( '\\s+', ' ') : quote.Pricing_Project_Name_Nm__c;

                        if(quote.Pricing_My_Deals_Folio_Name_Nm__c != oldMap.get(quote.Id).Pricing_My_Deals_Folio_Name_Nm__c){
                            if(quote.Pricing_Folio_ID_Nm__c != null){
                                quoteIdWithFolioErrorSet.add(quote.Id);        
                            }else{                                                                                    
                                quoteIdWithFolioNameChangeSet.add(quote.Id);
                            }
                        }
                        
                        if(quote.Pricing_ShipmentStDate_Dt__c != oldMap.get(quote.Id).Pricing_ShipmentStDate_Dt__c && !hasAPIPermissionSet){
                            quoteIdWithStartDatechange.add(quote.Id);
                        }

                        if(quote.Pricing_Intel_Sales_Rep_Email_Txt__c == null){
                            quote.SBQQ__SalesRep__c = null;
                        }

                        // Sales rep is mandatory field, get thos with only changes for validation
                        if(quote.Pricing_Intel_Sales_Rep_Email_Txt__c != null && oldMap.get(quote.id).Pricing_Intel_Sales_Rep_Email_Txt__c != quote.Pricing_Intel_Sales_Rep_Email_Txt__c){
                            oemEmailIds.add(quote.Pricing_Intel_Sales_Rep_Email_Txt__c);
                            quoteIdWithSalesRepChange.add(quote.Id);
                            if(quote.SBQQ__Account__c != null){
                                getAccountToSalesRepEmailMap(quote,quote.Pricing_Intel_Sales_Rep_Email_Txt__c,accountIdToSalesRepEmailMap);
                            }
                        }   

                        // Account executive is not a mandatory field, get thos with only changes for validation or make AE lookup bnull               
                        if(quote.Pricing_Intel_Account_Exec_Email_Txt__c != null){
                            accountExecutiveEmailId.add(quote.Pricing_Intel_Account_Exec_Email_Txt__c);
                            quoteIdWithaccountExecutiveChange.add(quote.Id);
                            //only for Tender Quotes this validation should show
                            if(quote.Pricing_Intel_Account_Exec_Email_Txt__c == quote.Pricing_Intel_Sales_Rep_Email_Txt__c && quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_Quote_Program){
                                quote.Pricing_Intel_Account_Exec_Email_Txt__c.addError(Label.Pricing_Duplicate_FSE_Error);
                            }
                        }else {
                            quote.Pricing_Account_Executive_Nm__c = null;
                        }

                        // opportunity field is non mandatory fields
                        if(quote.Pricing_End_Customer_Opportunity_Txt__c != null){
                            opportunityIdToQuoteId.put(quote.Pricing_End_Customer_Opportunity_Txt__c,quote.id);
                        }

                        checkOwnerAndPrimaryContactChange(oldMap,quote,userContactIds,allPrimaryContactIds,quoteIdWithPrimaryContactChange,quoteIdWithOwnerChange,emailToContactIdMap,contactIdToEmailMap);
                        //Change Primary contact if Primary contact is Drafter or Drafter Limited on Submission
                        if((oldMap.get(quote.id).Pricing_Status_Precedence_Number__c==10) && (quote.Pricing_Status_Precedence_Number__c ==30 || quote.Pricing_Status_Precedence_Number__c ==40)){
                            quoteIdWithPrecedenceNumber.put(quote.id,quote.Pricing_Status_Precedence_Number__c);
                        }

                        //Update Unified Global End Customer if End Customer/End customer region is changed
                        if(((oldMap.get(quote.id).Pricing_End_Customer__c!=quote.Pricing_End_Customer__c && quote.Pricing_Customer_Nm__c == null) ||
                            oldMap.get(quote.id).Pricing_End_Customer_Country_Nm__c!=quote.Pricing_End_Customer_Country_Nm__c )&& !updateUnifiedEndQuoteList.contains(quote)){
                                updateUnifiedEndQuoteList.add(quote);
                        }

                        if((oldMap.get(quote.id).Pricing_Customer_Nm__c!=quote.Pricing_Customer_Nm__c) && quote.Pricing_Customer_Nm__c!=null){
                            quote.Pricing_Unified_Global_End_Customer_Nm__c = null;                            
                        }
                        //validate quoteline products with opportunity line item products
                        if(((oldMap.get(quote.id).Pricing_End_Customer_Opportunity_Txt__c != quote.Pricing_End_Customer_Opportunity_Txt__c && quote.Pricing_End_Customer_Opportunity_Txt__c != null) || (oldMap.get(quote.id).SBQQ__Opportunity2__c != quote.SBQQ__Opportunity2__c && quote.SBQQ__Opportunity2__c != null)) && quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_Quote_Program){
                            oppIdtoQuoteIdMap.put(quote.Pricing_End_Customer_Opportunity_Txt__c, quote.id);
                        }
                        
                        if(oldMap.get(quote.id).Pricing_On_Hold_Cb__c != quote.Pricing_On_Hold_Cb__c && quote.Pricing_On_Hold_Cb__c == false && isFSEUser != quoteIdtoIsFSEUserMap.get(quote.Id) && currentUser.Core_User_Profile_Name__c != 'IT Admin') {
                            String personaErrorLabel = label.Pricing_Persona_On_Hold_Error_Msg;
                            String role = isFSEUser ? 'Regional Pricing Manager' : 'SDM/FSE';                         
                            quote.addError(personaErrorLabel.replace('{1}', role));
                        }
                        //Added for On Hold Comment validation
                        if((oldMap.get(quote.id).Pricing_On_Hold_Cb__c != quote.Pricing_On_Hold_Cb__c && quote.Pricing_On_Hold_Cb__c == true && String.isBlank(quote.Pricing_On_Hold_Comment__c)) || (quote.Pricing_On_Hold_Cb__c == true && oldmap.get(quote.Id).Pricing_On_Hold_Comment__c != quote.Pricing_On_Hold_Comment__c && String.isblank(quote.Pricing_On_Hold_Comment__c))){
                            quote.addError(label.Pricing_Tender_Hold_Comments_Mandatory_Error_Message);
                        }
                    }

                    if(!allPrimaryContactIds.isEmpty()){
                        getUsrDtlsMapAndDrafterSet(userContactIds,allPrimaryContactIds,contactIdWithDrafterLimitedSet,userContactDtls);
                    }

                    if(!hasAPIPermissionSet && !oemEmailIds.isEmpty()) {              
                        accountToValidEmailMap = getSalesrepMap(oemEmailIds,accountIdToSalesRepEmailMap, salesRepAssignment);
                    }
                   
                    if(!accountExecutiveEmailId.isEmpty() && !skipMethodExecution) {              
                        getAccountExecutiveMap(accountExecutiveEmailId, accountExecutiveAssignment, validEmailIdSet ,accountExecutiveSelfAssignment);
                    }
                    
                    // If opportunity id is not empty get opportunity map 
                    if(!opportunityIdToQuoteId.isEmpty()){
                        getOpportunityMap(opportunityIdToQuoteId,opportunityDetails,quoteIdToOppRecdMap,false);
                    }

                    if(!quoteIdWithFolioNameChangeSet.isEmpty()){
                        checkForIntegrationError(quoteIdWithFolioNameChangeSet,quoteIdWithFolioErrorSet);               
                    }

                    if(!oppIdtoQuoteIdMap.isEmpty()){
                        validateQLIProductagainstOpportunityProduct(oppIdtoQuoteIdMap, quoteIdwithProdMap);
                        getOpportunityMap(oppIdtoQuoteIdMap,opportunityDetails,quoteIdToOppRecdMap,true);
                        validateEndCustOfQuoteAndOppty(oppIdtoQuoteIdMap,quoteIdvalidEndCustomerMap);
                    }

                    Map<Id,List<SBQQ__QuoteLine__c>> quotelineStartDateChange = new Map<Id,List<SBQQ__QuoteLine__c>>();
                    if(!quoteIdWithStartDatechange.isEmpty()) {
                        getQuoteToStartDateMap(quoteIdWithStartDatechange,quotelineStartDateChange);
                    }

                    for (SBQQ__Quote__c quote : lstquote){
                        if(quoteIdWithFolioErrorSet.contains(quote.Id)){
                            quote.addError(Label.Pricing_Folio_Validation_Error_Message);
                        }
                        if(!hasAPIPermissionSet && quote.Pricing_Program_Type_Nm__c != Label.Pricing_Tender_FinancialIncentive_Quote && quoteIdWithSalesRepChange.contains(quote.Id) && quote.Pricing_Intel_Sales_Rep_Email_Txt__c != null){
                            validateSalesRep(accountToValidEmailMap,quote,salesRepAssignment);
                        }
                        if(quoteIdWithaccountExecutiveChange.contains(quote.Id) && (quote.Pricing_Intel_Account_Exec_Email_Txt__c != oldMap.get(quote.Id).Pricing_Intel_Account_Exec_Email_Txt__c) && !skipMethodExecution){
                            validateAccountExecutive(accountExecutiveAssignment, quote, accountExecutiveSelfAssignment, quote.Pricing_Intel_Sales_Rep_Email_Txt__c);
                            checkValidAccountExecutiveEmail(validEmailIdSet, quote); 
                        }
                        if(!quoteIdWithPrecedenceNumber.isEmpty()&& !contactIdWithDrafterLimitedSet.isEmpty())
                        {
                            checkPrimaryContactIsDrafterLimited(quoteIdWithPrecedenceNumber,contactIdWithDrafterLimitedSet,quote,currentUser);          
                        }
                        if(quote.Pricing_Program_Type_Nm__c != Label.Pricing_Tender_FinancialIncentive_Quote && quoteIdWithPrimaryContactChange.contains(quote.Id)){
                            validatePrimaryContact(userContactDtls, quote);
                            if(quote.SBQQ__Status__c != 'Draft' && !contactIdWithDrafterLimitedSet.isEmpty() && contactIdWithDrafterLimitedSet.contains(quote.SBQQ__PrimaryContact__c)){
                                quote.addError(Label.Pricing_Tender_Drafter_Limited_Primary_Contact_Error_Message);
                            }                  
                        }
                        
                        if(quoteIdWithStartDatechange.contains(quote.Id) && quotelineStartDateChange.containsKey(quote.Id)) {
                            validateStartDate(quotelineStartDateChange.get(quote.id),quote);
                        }
                        if(quoteIdWithOwnerChange.contains(quote.Id) && userContactDtls.containsKey(quote.SBQQ__PrimaryContact__c) && 
                           quote.ownerid != userContactDtls.get(quote.SBQQ__PrimaryContact__c).Id){
                               quote.addError(Label.Pricing_Tender_Owner_Change_Error);
                           }
                        if(!quoteIdsWithInvalidEndCustomerOpportunityId.contains(quote.Id)){
                             validateOpportunity(opportunityDetails, quote);
			}     
                        if(!isQuotFirstSubmission){  
                        statusRevertFix( quote,quoteLineNumberToStatusMap,quoteLineNumberToRecordTypeMap,quoteLineNumberToClientRecordTypeMap,quoteLineNumberToFinancialIncentiveRecordTypeMap);
                        }
                        //Validate Quote Text fields and throw error if Non latin character is present
                        validateQuoteTextFieldsForLatinChars(quote,oldMap,false);
                        
                        //on first Quote submission if overall qty is less then minimum then check checkbox Pricing_Volume_Exception_Quota_Cb__c
                        if(oldMap.get(quote.id).SBQQ__Status__c != quote.SBQQ__Status__c && quote.SBQQ__Status__c == 'Submitted'  && isVolumeExceptionCheck){
                            quote.Pricing_Volume_Exception_Quota_Cb__c = true;
                        }

                        //when RPM/SDM unchecks Pricing_Exclude_from_Volume_Excep_Quota__c will check again quota and if quota exists then allow or throw error
                        if((isRPMUser || isFSEUser) && ((oldMap.get(quote.id).Pricing_Exclude_from_Volume_Excep_Quota__c != quote.Pricing_Exclude_from_Volume_Excep_Quota__c && quote.Pricing_Exclude_from_Volume_Excep_Quota__c == false)|| (oldMap.get(quote.id).Pricing_Quota_Exclusion_Reason__c != quote.Pricing_Quota_Exclusion_Reason__c && quote.Pricing_Quota_Exclusion_Reason__c == null)) && quote.Pricing_Program_Type_Nm__c != Label.Pricing_Tender_Small_Volume_Quote){
                            accountIds.add(quote.SBQQ__Account__c);
                        }
                        
                        // Validate if Quoteline is present or not for validating against Opportunity Product
                        if(quoteIdtoProdMap.isEmpty() && ((oldMap.get(quote.id).Pricing_End_Customer_Opportunity_Txt__c != quote.Pricing_End_Customer_Opportunity_Txt__c && quote.Pricing_End_Customer_Opportunity_Txt__c != null) || (oldMap.get(quote.id).SBQQ__Opportunity2__c != quote.SBQQ__Opportunity2__c && quote.SBQQ__Opportunity2__c != null)) && quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_Quote_Program){
                            quote.addError(Label.Pricing_No_QL_For_Opportunity);
                        }
                        //Validate if no Opportunity Products are present for validating against Quote Line product 
                        else if(quoteIdwithProdMap.isEmpty() && ((oldMap.get(quote.id).Pricing_End_Customer_Opportunity_Txt__c != quote.Pricing_End_Customer_Opportunity_Txt__c && quote.Pricing_End_Customer_Opportunity_Txt__c != null) || (oldMap.get(quote.id).SBQQ__Opportunity2__c != quote.SBQQ__Opportunity2__c && quote.SBQQ__Opportunity2__c != null)) && quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_Quote_Program){
                            quote.addError(Label.Pricing_No_OppLineItems_For_Opportunity);
                        }
                        // Validate if one of the same product is present in both Opportunity and Quoteline 
                        else if(quoteIdwithProdMap.containsKey(quote.id) && quoteIdwithProdMap.get(quote.id)){
                            quote.addError(Label.Pricing_QlProduct_To_OppLineProduct_Mismatch);
                        }
                        
                        if(quoteIdvalidEndCustomerMap.containskey(quote.id)){
                            quote.Pricing_Invalid_End_Customer_cb__c = quoteIdvalidEndCustomerMap.get(quote.id);
                        }
                        
                        if((oldMap.get(quote.Id).Pricing_Customer_Nm__c!=quote.Pricing_Customer_Nm__c || oldMap.get(quote.Id).Pricing_End_Customer__c!=quote.Pricing_End_Customer__c)
                           || (oldMap.get(quote.Id).Pricing_End_Customer_Country_Nm__c != quote.Pricing_End_Customer_Country_Nm__c) || (oldMap.get(quote.Id).Pricing_Project_Name_Nm__c != quote.Pricing_Project_Name_Nm__c)
                           || (oldMap.get(quote.Id).SBQQ__Account__c != quote.SBQQ__Account__c) ||(oldMap.get(quote.Id).SBQQ__PrimaryContact__c != quote.SBQQ__PrimaryContact__c)
                           || (oldMap.get(quote.Id).Pricing_Region_Nm__c != quote.Pricing_Region_Nm__c)||(oldMap.get(quote.Id).SBQQ__SalesRep__c != quote.SBQQ__SalesRep__c) 
                           || (oldMap.get(quote.Id).Pricing_Server_Deal_Type_Nm__c != quote.Pricing_Server_Deal_Type_Nm__c) || (oldMap.get(quote.Id).Pricing_Market_Segment_values_Nm__c != quote.Pricing_Market_Segment_values_Nm__c)){
                            QuoteLineBusinessLogic.changeTwinField = true;
                        }
                    }
                    if(accountIds.size() > 0){
                        validateExcludeVolExcepQuota(accountIds,lstquote);
                    }
                }

                //Unified End Customer
                if(!updateUnifiedEndQuoteList.isEmpty()){
                    updateUnifiedEndCustomerQuote(updateUnifiedEndQuoteList);
                }
            } catch(exception ex){Pricing_Tender_Utility.logError(ex);}
        }
    }         
    

    /**
    * @description Method to throw error  when ever Pricing_Exclude_from_Volume_Excep_Quota__c is uncheck and Volume Quota is exhausted.
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 02-05-2025 
    * @param accountIds 
    * @param lstquote 
    **/
    public static void validateExcludeVolExcepQuota(Set<String> accountIds,List<SBQQ__Quote__c> lstquote){
        Map<String,String> quoteCreationAllowed = new Map<String,String>(Pricing_Manage_Small_Volume_Deal.capSizeCheckToCreation(accountIds,false)); 
        if(!quoteCreationAllowed.isEmpty()){
            for(SBQQ__Quote__c quote : lstquote){
                if((quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote || quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_Quote) && quoteCreationAllowed.containsKey(quote.Pricing_Program_Type_Nm__c) && quoteCreationAllowed.get(quote.Pricing_Program_Type_Nm__c).split(':')[0] == 'false'){
                    String quantityError = Label.Pricing_ExcludeQuotaErrorMsg;
                    quote.addError(quantityError);
                }else{
                    quote.Pricing_Quota_Exclusion_Reason__c = null;
                }
            }
        }
    }

    /**
    * @description : Method to populate Simplified Name on Quote from Pricing_Account_To_CIM_ID_Mapping__mdt Metadata on insertion of Quote and update at QuoteLetter Generation if there is any change in Names and Type.
    * @author Divya Gangasaram | 07-19-2023 
    *  @param Map<Id,SBQQ__Quote__c> quotesMap
    * @param Map<Id, Account> accountIdtoRecordMap
    * @param Boolean isSaveQuote 
    **/
    public static void accountNamePopulate(Map<Id,SBQQ__Quote__c> quotesMap, Map<Id, Account> accountIdtoRecordMap,Boolean isSaveQuote){
        if(!quotesMap.isEmpty()){
            List<SBQQ__Quote__c> quoteListToUpdate = new List<SBQQ__Quote__c>();
            String accountId;
            for(SBQQ__Quote__c quote : quotesMap.values()){
                accountId = 'Id_' +quote.SBQQ__Account__c;
                if(accountIdtoRecordMap.containsKey(quote.SBQQ__Account__c)){
                    if(Pricing_Account_To_CIM_ID_Mapping__mdt.getAll().containsKey(accountId) && !String.isBlank(Pricing_Account_To_CIM_ID_Mapping__mdt.getInstance(accountId).Pricing_Unified_Customer_Aggregatio_Type__c) &&  accountId == Pricing_Account_To_CIM_ID_Mapping__mdt.getInstance(accountId).DeveloperName){
                        String unifiedCustomerType = Pricing_Account_To_CIM_ID_Mapping__mdt.getInstance(accountId).Pricing_Unified_Customer_Aggregatio_Type__c;
                        
                        if(unifiedCustomerType == 'Global' && !String.isBlank(accountIdtoRecordMap.get(quote.SBQQ__Account__c).Core_Unified_Global_Customer_Name__c)){        
                            quote.Pricing_Account_Simplified_Name__c = accountIdtoRecordMap.get(quote.SBQQ__Account__c).Core_Unified_Global_Customer_Name__c;
                        }
                        else if(unifiedCustomerType == 'Intermediate' && !String.isBlank(accountIdtoRecordMap.get(quote.SBQQ__Account__c).Core_Unified_Intermediate_Customer_Name__c)){
                            quote.Pricing_Account_Simplified_Name__c = accountIdtoRecordMap.get(quote.SBQQ__Account__c).Core_Unified_Intermediate_Customer_Name__c;
                        }
                        else if(unifiedCustomerType == 'Intermediate Level 2' && !String.isBlank(accountIdtoRecordMap.get(quote.SBQQ__Account__c).Core_Unified_Intermdt_Customer_2_Name__c)){
                            quote.Pricing_Account_Simplified_Name__c = accountIdtoRecordMap.get(quote.SBQQ__Account__c).Core_Unified_Intermdt_Customer_2_Name__c;
                        }
                        else{
                            quote.Pricing_Account_Simplified_Name__c = accountIdtoRecordMap.get(quote.SBQQ__Account__c).Name;
                        }
                    } 
                    else{
                        
                        quote.Pricing_Account_Simplified_Name__c = accountIdtoRecordMap.get(quote.SBQQ__Account__c).Name;
                    }
                    
                    if(isSaveQuote){
                    quoteListToUpdate.add(quote);
                    }
                }
            } 
            if(!quoteListToUpdate.isEmpty()){
                SBQQ.TriggerControl.disable();
                update quoteListToUpdate;
                SBQQ.TriggerControl.enable();
            }
        }  
    }
    
    /**
    * @description Method to check if Primary Contact is Drafter Limited on submission
    * @author Subhanku | 12-19-2022 
    * @param Map<Id Decimal> quoteIdWithPrecedenceNumber 
    * @param Set<Id> contactIdWithDrafterLimitedSet 
    * @param SBQQ__Quote__c quote 
    * @param User currentUser 
    **/
    private static void checkPrimaryContactIsDrafterLimited(Map<Id,Decimal> quoteIdWithPrecedenceNumber,Set<Id> contactIdWithDrafterLimitedSet,SBQQ__Quote__c quote,User currentUser){       
        if(!String.isEmpty(quote.SBQQ__PrimaryContact__c) && contactIdWithDrafterLimitedSet.contains(quote.SBQQ__PrimaryContact__c)){
            if(quoteIdWithPrecedenceNumber.get(quote.id) == 40){
                quote.SBQQ__PrimaryContact__c.addError(Label.Pricing_Tender_Drafter_Limited_Primary_Contact_Error_Message);
            }
            else{
                quote.SBQQ__PrimaryContact__c=currentUser.ContactId;
                quote.OwnerId = currentUser.Id;
            }
        }
    }
    
    
    /**
    * @description method to check if primary contact is valid and then change the owner
    * @author Subhanku | 12-19-2022 
    * @param Map<Id User> userContactDtls 
    * @param SBQQ__Quote__c quote 
    **/
    private static void validatePrimaryContact(Map<Id, User> userContactDtls,  SBQQ__Quote__c quote){
        if(userContactDtls.get(quote.SBQQ__PrimaryContact__c) != null  && userContactDtls.get(quote.SBQQ__PrimaryContact__c).PermissionSetAssignments.size()>0){
            if(!isPartnerUser && quote.SBQQ__PrimaryContact__c != null){
                quote.OwnerId = userContactDtls.get(quote.SBQQ__PrimaryContact__c).Id;
            }else if(isPartnerUser && contactAccountIdSet.contains(quote.SBQQ__PrimaryContact__c)){
                quotePrimaryContactUpdateIds.add(quote.Id);
            }
            else if (isPartnerUser && !contactAccountIdSet.contains(quote.SBQQ__PrimaryContact__c)){
                quote.addError(Label.Pricing_Tender_Quote_Primary_Contact_Error_Message);
            }
        }
        else{
            quote.addError(Label.Pricing_Tender_Quote_Primary_Contact_Error_Message);
        }
    }
    
    
    /**
    * @description method to check if sales rep is valid then assign to respective field
    * @author Subhanku | 12-19-2022 
    * @param Map<Id Set<String>> accountToValidEmailMap 
    * @param SBQQ__Quote__c quote 
    * @param Map<String PermissionSetAssignment> salesRepAssignment 
    **/
    private static void validateSalesRep(Map<Id,Set<String>> accountToValidEmailMap, SBQQ__Quote__c quote ,Map<String, PermissionSetAssignment> salesRepAssignment){
        if(accountToValidEmailMap.containsKey(quote.SBQQ__Account__c) && 
        accountToValidEmailMap.get(quote.SBQQ__Account__c).contains(quote.Pricing_Intel_Sales_Rep_Email_Txt__c) &&
        salesRepAssignment.containsKey(quote.Pricing_Intel_Sales_Rep_Email_Txt__c)){
            quote.SBQQ__SalesRep__c = salesRepAssignment.get(quote.Pricing_Intel_Sales_Rep_Email_Txt__c).AssigneeId;        
        }else{
            quote.Pricing_Intel_Sales_Rep_Email_Txt__c.addError(Label.Pricing_Tender_Quote_Sales_Rep_Error_Message);
        }  
    }
    
    /**
    * @description method to validate the pricing start date of quote and quoteline pricing end date
    * @author Subhanku | 12-19-2022 
    * @param List<SBQQ__QuoteLine__c> quoteListList 
    **/
    private static void validateStartDate(List<SBQQ__QuoteLine__c> quoteLineList,SBQQ__Quote__c quote){
        if(quote.Pricing_ShipmentStDate_Dt__c != null){                
            for(SBQQ__QuoteLine__c ql: quoteLineList){
                if(quote.Pricing_ShipmentStDate_Dt__c > ql.Pricing_End_Date_dt__c){ 
                    quote.addError(Label.Pricing_QuoteStartDate_Error_Message);
                }
            }
        }
    }
    
    /**
    * @description method to check if AE is valid then assign to respective field
    * @author Subhanku | 12-19-2022 
    * @param Map<String Id> accountExecutiveAssignment 
    * @param SBQQ__Quote__c quote 
    * @param Map<String Id> accountExecutiveSelfAssignment 
    * @param String salesRepEmailId 
    **/
    private static void validateAccountExecutive(Map<String, Id> accountExecutiveAssignment, SBQQ__Quote__c quote,Map<String, Id> accountExecutiveSelfAssignment, String salesRepEmailId){
        if(accountExecutiveAssignment.get(quote.Pricing_Intel_Account_Exec_Email_Txt__c) != null){
            quote.Pricing_Account_Executive_Nm__c = accountExecutiveAssignment.get(quote.Pricing_Intel_Account_Exec_Email_Txt__c);                        
        }else if( (String.isEmpty(salesRepEmailId) || (!String.isEmpty(salesRepEmailId) && UserInfo.getUserEmail()!=salesRepEmailId)) && accountExecutiveSelfAssignment.get(UserInfo.getUserEmail()) != null){
            quote.Pricing_Account_Executive_Nm__c = accountExecutiveSelfAssignment.get(UserInfo.getUserEmail());
            quote.Pricing_Intel_Account_Exec_Email_Txt__c = UserInfo.getUserEmail();
        }else if(!String.isBlank(quote.Pricing_Intel_Account_Exec_Email_Txt__c)){
            quote.Pricing_Account_Executive_Nm__c = null;
        }
    }
    
    /**
    * @description method to get sales rep with valid PS
    * @author Subhanku | 12-19-2022 
    * @param Set<String> oemEmailIds 
    * @param Map<Id Set<String>> accountIdToSalesRepEmailMap 
    * @param Map<String PermissionSetAssignment> salesRepAssignment 
    * @return Map<Id, Set<String>> 
    **/
    public static Map<Id,Set<String>> getSalesrepMap(Set<String> oemEmailIds, Map<Id,Set<String>> accountIdToSalesRepEmailMap , Map<String, PermissionSetAssignment> salesRepAssignment){
        Set<Id> userIdSet = new Set<Id>();
               Map<Id,Set<String>> accountToValidEmailMap = new Map<Id,Set<String>>();
        // Get sales rep details from Supplied Sales rep emails
                List<PermissionSetAssignment> salesRepAssignmentDtl = new List<PermissionSetAssignment>([SELECT Assignee.Email,PermissionSet.Name,AssigneeId
                                                                                                 FROM PermissionSetAssignment 
                                                                                                 WHERE Assignee.Email IN :oemEmailIds AND Assignee.IsActive = true
                                                                                                 AND PermissionSet.Name =:Label.Pricing_Tender_PermissionSets_TenderUser]);
        // Get the map of <EmailId, SalesRep PermissionSet> 
        
        For(PermissionSetAssignment sea:salesRepAssignmentDtl){
            userIdSet.add(sea.AssigneeId);
            salesRepAssignment.put(sea.Assignee.Email,sea);
        }
        
        if(!userIdSet.isEmpty() && !accountIdToSalesRepEmailMap.isEmpty()){
            for(AccountTeamMember accTeam : [SELECT Id,User.Email,AccountId from AccountTeamMember where AccountId IN : 
                                             accountIdToSalesRepEmailMap.keySet() AND UserId IN: userIdSet]){
                                                 if(!accountToValidEmailMap.containsKey(accTeam.AccountId)){                                      
                                                     accountToValidEmailMap.put(accTeam.AccountId, new Set<String>{accTeam.User.Email}); 
                                                 }else{
                                                     accountToValidEmailMap.get(accTeam.AccountId).add(accTeam.User.Email);
                                                 }
                                             }
        }
        return accountToValidEmailMap;
    }
    
    /**
    * @description method to get AE with valid PS
    * @author Subhanku | 12-19-2022 
    * @param Set<String> accountExecutiveEmailId 
    * @param Map<String Id> accountExecutiveAssignment 
    * @param Set<String> validEmailIdSet 
    * @param Map<String Id> accountExecutiveSelfAssignment 
    **/
    private static void getAccountExecutiveMap(Set<String> accountExecutiveEmailId, Map<String, Id> accountExecutiveAssignment, Set<String> validEmailIdSet,Map<String, Id> accountExecutiveSelfAssignment){
        // Boolean shareToNonAE = TriggerHandler.isActive('Pricing_Share_to_Non_AE');
        Set<String> allPermissionsExceptAE = new Set<String>((Label.Pricing_Permission_Set_Except_AE).split(':'));
        Set<String> allPermissions = new Set<String>();
        allPermissions.add(Label.Pricing_Tender_PermissionSets_TenderAccountExecutive);
        allPermissions.addAll(allPermissionsExceptAE);
        
        // Get account executive values 
        List<User> accountExecutiveDtl =  new List<User>([SELECT Id, Email,(SELECT Assignee.Email,PermissionSet.Name,AssigneeId FROM 
                                                                            PermissionSetAssignments WHERE Assignee.Email IN :accountExecutiveEmailId AND 
                                                                            Assignee.IsActive = true AND PermissionSet.Name IN: allPermissions) FROM User 
                                                          where Email IN: accountExecutiveEmailId and IsActive = true]);
        //Boolean updateAE;
        for(User userRec : accountExecutiveDtl){
            Boolean updateAE = false;
            validEmailIdSet.add(userRec.Email);
            for(PermissionSetAssignment aea : userRec.PermissionSetAssignments){
                if(aea.PermissionSet.Name == Label.Pricing_Tender_PermissionSets_TenderAccountExecutive){
                    updateAE = true;
                    accountExecutiveSelfAssignment.put(userRec.Email, userRec.Id);
                    break;
                }
            }
            if(updateAE){
                accountExecutiveAssignment.put(userRec.Email, userRec.Id);
            }
        }
    }
    
        /**
    * @description method to check valid AE email
    * @author Subhanku | 12-19-2022 
    * @param Set<String> validEmailIdSet 
    * @param SBQQ__Quote__c quote 
    **/
    private static void checkValidAccountExecutiveEmail(Set<String> validEmailIdSet, SBQQ__Quote__c quote){
        if(quote.Pricing_Intel_Account_Exec_Email_Txt__c!=null && (!validEmailIdSet.contains(quote.Pricing_Intel_Account_Exec_Email_Txt__c))){
            quote.addError(Label.Pricing_Invalid_Account_Executive_Error);
        }
    }
    
    /**
    * @description method to get valid quote Id to User Id map
    * @author Subhanku | 12-19-2022 
    * @param Map<Id String> quoteIdToEmailMap 
    * @return Map<Id, Id> 
    **/
    private static Map<Id,Id> getQuoteIdUserIdMap(Map<Id,String> quoteIdToEmailMap){
        Map<String,Id> userEmailToUserIdMap = new Map<String,Id>();
        Map<Id,Id> quoteIdToUserIdMap = new Map<Id,Id>();
        if(!quoteIdToEmailMap.isEmpty()){   
            for(User userRec :[SELECT Id,Email from User where Email IN : quoteIdToEmailMap.values() and IsActive = true]){
                userEmailToUserIdMap.put(userRec.Email,userRec.Id);
            }
            for(Id quoteId : quoteIdToEmailMap.keySet()){
                if(userEmailToUserIdMap.containsKey(quoteIdToEmailMap.get(quoteId))){
                    quoteIdToUserIdMap.put(quoteId,userEmailToUserIdMap.get(quoteIdToEmailMap.get(quoteId)));
                }
            }
        }        
        return quoteIdToUserIdMap;
    }
    //check if end customer opportunity id field value is valid and map it to opportunity lookup
    private static void validateOpportunity(Map<string, Opportunity> opportunityDetails, SBQQ__Quote__c quote){
        if(opportunityDetails.get(quote.Pricing_End_Customer_Opportunity_Txt__c) == null && 
           !String.isBlank(quote.Pricing_End_Customer_Opportunity_Txt__c)){
               quote.Pricing_End_Customer_Opportunity_Txt__c.addError(Label.Pricing_Tender_Quote_Opportunity_Error_Message);
           }
    } 
    
    
    /**
    * @description method called after insert to publish an event for Quote and Comment Share
    * @author Subhanku | 12-19-2022 
    * @param Set<Id> quoteIdSet 
    * @param String eventName 
    **/
    public static void publishIQR(Set<Id> quoteIdSet,String eventName){
        // List to hold event objects to be published.
        List<Pricing_IQR_Event__e> newsEventList = new List<Pricing_IQR_Event__e>();
        // Create event objects.
        String quoteIdStr;
        if(!quoteIdSet.isEmpty()){
            List<Id> quoteIdList = new List<Id>();
            quoteIdList.addAll(quoteIdSet);
            quoteIdStr = String.join(quoteIdList,',');
        }
        if(quoteIdStr != null){
            // Add event objects to the list.
            newsEventList.add(new Pricing_IQR_Event__e(
                Pricing_QuoteId_Txt__c = quoteIdStr,
                Pricing_IQR_Action_Nm__c = eventName                              
            ));
            
            // Call method to publish events.
            List<Database.SaveResult> results = EventBus.publish(newsEventList);
        }
    }
        
    /**
    * @description Insert Quote AE as default Quote Team member
    * @author Subhanku | 12-19-2022 
    * @param Map<Id Id> quoteIdAEUserIdMap 
    * @param List<SBQQ__Quote__c> lstquote 
    * @param boolean addDuplicateError 
    * @return List<Pricing_Quote_Team__c> 
    **/
    public static List<Pricing_Quote_Team__c> createAEQuoteTeamMember(Map<Id,Id> quoteIdAEUserIdMap, List<SBQQ__Quote__c> lstquote, boolean addDuplicateError){       
        List<Pricing_Quote_Team__c> newAEQuoteTeamList = new List<Pricing_Quote_Team__c>();
        Map<Id,Id> quoteIdAEUserIdAddQTMMap = quoteIdAEUserIdMap;
        List<Id> quoteIdList = new List<Id>();
        List<Pricing_Quote_Team__c> quoteTeamMembersList = [Select Id,Pricing_Quote_Team_Member_Id__r.Email,Pricing_Quote_Team_Member_Id__r.Name,Pricing_Quote_Team_Member_Id__c,Pricing_Quote_Id__c,Pricing_Role_Nm__c from Pricing_Quote_Team__c where Pricing_Quote_Id__c IN :quoteIdAEUserIdMap.keySet()];
        
        for(SBQQ__Quote__c quote:lstquote){
            quoteIdList.add(quote.Id);
        }
        
        for(Pricing_Quote_Team__c qtm : quoteTeamMembersList){            
            if(quoteIdAEUserIdMap.containskey(qtm.Pricing_Quote_Id__c)  && qtm.Pricing_Quote_Team_Member_Id__c == quoteIdAEUserIdMap.get(qtm.Pricing_Quote_Id__c)){                
                quoteIdAEUserIdAddQTMMap.remove(qtm.Pricing_Quote_Id__c);
                if(addDuplicateError && qtm.Pricing_Role_Nm__c == Label.Pricing_Quote_Team_Role_ITS){
                    lstquote.get(quoteIdList.indexOf(qtm.Pricing_Quote_Id__c)).addError(Label.Pricing_Duplicate_Account_Executive_Error);
                }
                if(addDuplicateError && qtm.Pricing_Role_Nm__c == Label.Pricing_Quote_Team_Role_FSE){
                    lstquote.get(quoteIdList.indexOf(qtm.Pricing_Quote_Id__c)).addError(Label.Pricing_Restrict_AE_if_FSE_Present_error);
                }
            }
        }
        
        for(Id quoteId :quoteIdAEUserIdAddQTMMap.keySet() ){
            Pricing_Quote_Team__c newQTM = new Pricing_Quote_Team__c();
            newQTM.Pricing_Quote_Id__c=quoteId;
            newQTM.Pricing_Role_Nm__c = Label.Pricing_Quote_Team_Role_Account_Executive;
            newQTM.Pricing_Quote_Team_Member_Id__c=quoteIdAEUserIdAddQTMMap.get(quoteId);
            newQTM.RecordTypeId = qtmRecordTypeId;
            newAEQuoteTeamList.add(newQTM);        
        } 
        return newAEQuoteTeamList;        
    }
    
    
    /**
    * @description If Quote AE is updated, update Quote Team member
    * @author Subhanku | 12-19-2022 
    * @param Map<Id Id> quoteIdAEUserIdRemoveMap 
    * @param List<SBQQ__Quote__c> lstquote 
    * @param boolean isBefore 
    **/
    public static List<Pricing_Quote_Team__c> removeAEQuoteTeamMember(Map<Id,Id> quoteIdAEUserIdRemoveMap, List<SBQQ__Quote__c> lstquote, boolean isBefore){
        if(isQTMChanged){
            List<Pricing_Quote_Team__c> removeAEQuoteTeamList = new List<Pricing_Quote_Team__c>();
            List<Id> quoteIdList = new List<Id>();
            List<Pricing_Quote_Team__c> quoteTeamMembersList = [Select Id,Pricing_Quote_Team_Member_Id__r.Email,Pricing_Grant_Access_Ind__c,Pricing_Quote_Team_Member_Id__c,Pricing_Quote_Id__c,Pricing_Role_Nm__c from Pricing_Quote_Team__c where Pricing_Quote_Id__c IN :quoteIdAEUserIdRemoveMap.keySet() and Pricing_Role_Nm__c = :Label.Pricing_Quote_Team_Role_Account_Executive];
            Map<Id, List<Pricing_Quote_Team__c>> quoteToQTMmap = new Map<Id, List<Pricing_Quote_Team__c>>();
            
            if(isBefore){
                for(SBQQ__Quote__c quote:lstquote){
                    quoteIdList.add(quote.Id);
                    List<Pricing_Quote_Team__c> qtmList = new List<Pricing_Quote_Team__c>();
                    for(Pricing_Quote_Team__c qtm:quoteTeamMembersList){
                        if(qtm.Pricing_Quote_Id__c == quote.Id){
                            qtmList.add(qtm);
                        }
                    }
                    quoteToQTMmap.put(quote.Id, qtmList);
                }
            }
            
            for(Pricing_Quote_Team__c qtm:quoteTeamMembersList){
                if((quoteIdAEUserIdRemoveMap.containskey(qtm.Pricing_Quote_Id__c)  && qtm.Pricing_Quote_Team_Member_Id__c == quoteIdAEUserIdRemoveMap.get(qtm.Pricing_Quote_Id__c) && qtm.Pricing_Role_Nm__c ==Label.Pricing_Quote_Team_Role_Account_Executive )){
                    
                    if(isBefore){
                        Pricing_Quote_Team__c defaultAE = new Pricing_Quote_Team__c();
                        if(quoteToQTMmap.get(qtm.Pricing_Quote_Id__c)[0].Id != qtm.Id){
                            defaultAE = quoteToQTMmap.get(qtm.Pricing_Quote_Id__c)[0];
                        }else if(quoteToQTMmap.get(qtm.Pricing_Quote_Id__c).size() == 2){
                            defaultAE = quoteToQTMmap.get(qtm.Pricing_Quote_Id__c)[1];
                        }
                        if(quoteToQTMmap.get(qtm.Pricing_Quote_Id__c).size() > 1){
                            for(Pricing_Quote_Team__c qtmnew:quoteToQTMmap.get(qtm.Pricing_Quote_Id__c)){
                                if(qtmnew.Id != qtm.Id && qtmnew.Pricing_Grant_Access_Ind__c == true){
                                    defaultAE = qtmNew;
                                    break;
                                }
                            }
                        }
                        lstquote.get(quoteIdList.indexOf(qtm.Pricing_Quote_Id__c)).Pricing_Intel_Account_Exec_Email_Txt__c = defaultAE.Pricing_Quote_Team_Member_Id__r.Email;
                    }else{
                        removeAEQuoteTeamList.add(qtm);
                    }
                }
            }
            if(removeAEQuoteTeamList.size()>0 && !isBefore){
                //delete removeAEQuoteTeamList;
                return removeAEQuoteTeamList;
            }
        }
        return new List<Pricing_Quote_Team__c>();
    }
    
    /**
    * @description method to create default ITS QuoteTeam Member
    * @author Subhanku | 12-19-2022 
    * @param Map<Id Id> quoteIdITSUserIdMap 
    **/
    public static List<Pricing_Quote_Team__c> createITSDefaultQuoteTeamMember(Map<Id,Id> quoteIdITSUserIdMap){
        List<Pricing_Quote_Team__c> newITSQuoteTeamList = new List<Pricing_Quote_Team__c>();
        for(Id quoteId : quoteIdITSUserIdMap.keySet()){
            Pricing_Quote_Team__c newQTM = new Pricing_Quote_Team__c();
            newQTM.Pricing_Quote_Id__c=quoteId;
            newQTM.Pricing_Role_Nm__c =Label.Pricing_Quote_Team_Role_ITS;
            newQTM.Pricing_Quote_Team_Member_Id__c=quoteIdITSUserIdMap.get(quoteId);
            newQTM.RecordTypeId = qtmRecordTypeId;
            newITSQuoteTeamList.add(newQTM);
        }
        return newITSQuoteTeamList;
    }
    
    
    /**
    * @description Method to add primary FSE to Quote Team
    * @author Subhanku | 12-19-2022 
    * @param Map<Id Id> quoteIdFSEUserIdAddQTMMap 
    * @param List<SBQQ__Quote__c> lstquote 
    * @param boolean addDuplicateError 
    * @return List<Pricing_Quote_Team__c> 
    **/
    public static List<Pricing_Quote_Team__c> createFSEDefaultQuoteTeamMember(Map<Id,Id> quoteIdFSEUserIdAddQTMMap, List<SBQQ__Quote__c> lstquote, boolean addDuplicateError){
        List<Pricing_Quote_Team__c> newFSEQuoteTeamList = new List<Pricing_Quote_Team__c>();
        Map<Id,Id> quoteIdFSEUserIdQTMMap = quoteIdFSEUserIdAddQTMMap;
        List<Pricing_Quote_Team__c> quoteTeamMembersList = [Select Id,Pricing_Quote_Team_Member_Id__r.Email,Pricing_Quote_Team_Member_Id__r.Name,Pricing_Quote_Team_Member_Id__c,Pricing_Quote_Id__c,Pricing_Role_Nm__c from Pricing_Quote_Team__c where Pricing_Quote_Id__c IN :quoteIdFSEUserIdAddQTMMap.keySet()];
        List<Id> quoteIdList = new List<Id>();
        for(SBQQ__Quote__c quote:lstquote){
            quoteIdList.add(quote.Id);
        }
        
        for(Pricing_Quote_Team__c qtm : quoteTeamMembersList){            
            if(quoteIdFSEUserIdAddQTMMap.containskey(qtm.Pricing_Quote_Id__c)  && qtm.Pricing_Quote_Team_Member_Id__c == quoteIdFSEUserIdAddQTMMap.get(qtm.Pricing_Quote_Id__c)){                
                //Remove FSE from Map to be inserted if already present in Quote Team.
                quoteIdWithExistingFSE.add(qtm.Pricing_Quote_Id__c);
                quoteIdFSEUserIdQTMMap.remove(qtm.Pricing_Quote_Id__c);
                if((qtm.Pricing_Role_Nm__c == Label.Pricing_Quote_Team_Role_Account_Executive || qtm.Pricing_Role_Nm__c == Label.Pricing_Quote_Team_Role_ITS)){
                    lstquote.get(quoteIdList.indexOf(qtm.Pricing_Quote_Id__c)).addError(Label.Pricing_Duplicate_FSE_Error);
                }   
            }
        }
        
        for(Id quoteId : quoteIdFSEUserIdQTMMap.keySet()){
            Pricing_Quote_Team__c newQTM = new Pricing_Quote_Team__c();
            newQTM.Pricing_Quote_Id__c = quoteId;
            newQTM.Pricing_Role_Nm__c = Label.Pricing_Quote_Team_Role_FSE;
            newQTM.Pricing_Quote_Team_Member_Id__c = quoteIdFSEUserIdQTMMap.get(quoteId);
            newQTM.RecordTypeId = qtmRecordTypeId;
            newFSEQuoteTeamList.add(newQTM);
        }
        return newFSEQuoteTeamList;
    }
    
    /**
    * @description Method to udpate primary FSE in Quote Team if updated on Quote
    * @author Subhanku | 12-19-2022 
    * @param Map<Id Id> quoteIdFSEUserIdRemoveQTMMap 
    **/
    public static List<Pricing_Quote_Team__c> updateFSEQuoteTeamMember(Map<Id,Id> quoteIdFSEUserIdRemoveQTMMap){
        if(isQTMChanged){
            List<Pricing_Quote_Team__c> removeQTMList = new List<Pricing_Quote_Team__c>([Select id,Pricing_Quote_Id__c,Pricing_Quote_Team_Member_Id__c,Pricing_Role_Nm__c from Pricing_Quote_Team__c where Pricing_Quote_Id__c IN :quoteIdFSEUserIdRemoveQTMMap.keySet() and Pricing_Role_Nm__c =: Label.Pricing_Quote_Team_Role_FSE]);
            List<Pricing_Quote_Team__c> fseQTMToRemoveList = new List<Pricing_Quote_Team__c>();
            for(Pricing_Quote_Team__c qtm:removeQTMList){
                if(qtm.Pricing_Quote_Team_Member_Id__c == quoteIdFSEUserIdRemoveQTMMap.get(qtm.Pricing_Quote_Id__c) && qtm.Pricing_Role_Nm__c ==Label.Pricing_Quote_Team_Role_FSE && !quoteIdWithExistingFSE.contains(qtm.Pricing_Quote_Id__c)){
                    fseQTMToRemoveList.add(qtm);    
                }
            }
            if(!fseQTMToRemoveList.isEmpty()){
                //delete fseQTMToRemoveList;
                return fseQTMToRemoveList;
            }
        }
        return new List<Pricing_Quote_Team__c>();
    }

    /**
    * @description Method to reassign pending approval records on Quote FSE update
    * @author Subhanku | 12-19-2022 
    * @param Map<Id Id> quoteIdOldFseMap 
    * @param Map<Id Id> quoteIdNewFseMap 
    * @param List<SBQQ__Quote__c> lstquote 
    **/
    public static void reassignApprovalRecords(Map<Id,Id> quoteIdOldFseMap, Map<Id,Id> quoteIdNewFseMap, List<SBQQ__Quote__c> lstquote){
        List<Approval.ProcessWorkitemRequest> approvalRequestList = new List<Approval.ProcessWorkitemRequest>();
        Map<Id,Id> quoteLineIdQuoteIdMap = new Map <Id,Id>();
        List<ProcessInstanceWorkitem> updatedPWItems = new List<ProcessInstanceWorkitem>(); 
        Map<Id,Id> pwitemMapQuoteLineIdMap =new Map<Id,Id>();
        for(SBQQ__QuoteLine__c qli:[SELECT id,SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__Status__c  FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :quoteIdOldFseMap.keySet() AND SBQQ__Quote__r.SBQQ__Status__c !=: Label.Pricing_Tender_Quote_Status_Draft])
        {
            quoteLineIdQuoteIdMap.put(qli.Id,qli.SBQQ__Quote__c);//All quotes except draft and their quotelines for which FSE is changed
        } 
        if(quoteLineIdQuoteIdMap.size() > 0){
            List<ProcessInstanceWorkitem> pendingPWItems = [SELECT Id,ActorId,ProcessInstance.TargetObjectId,OriginalActorId
                                                            FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :quoteLineIdQuoteIdMap.keySet()
                                                            AND ProcessInstance.Status = 'Pending'];
            
            for(ProcessInstanceWorkitem pwItem : pendingPWItems){
                pwitemMapQuoteLineIdMap.put(pwItem.Id,pwItem.ProcessInstance.TargetObjectId);
                if(!quoteIdWithExistingFSE.contains(quoteLineIdQuoteIdMap.get(pwItem.ProcessInstance.TargetObjectId))){
                    if(quoteIdNewFseMap.get(quoteLineIdQuoteIdMap.get(pwItem.ProcessInstance.TargetObjectId))== pwItem.ActorId){ 
                        //if there is any pending work instance with the new fse present reject the existing work item 
                        Approval.ProcessWorkitemRequest result = new Approval.ProcessWorkitemRequest();
                        result.setComments(Label.Pricing_Tender_QuoteLine_Action_Reject);
                        result.setAction(Label.Pricing_Tender_QuoteLine_Action_Reject);
                        result.setWorkitemId(pwItem.Id);  
                        approvalRequestList.add(result);
                    }else if(quoteIdOldFseMap.get(quoteLineIdQuoteIdMap.get(pwItem.ProcessInstance.TargetObjectId)) == pwItem.ActorId){
                        // reassign the pending work item of old fse to the new fse 
                        pwItem.OriginalActorId = quoteIdNewFseMap.get(quoteLineIdQuoteIdMap.get(pwItem.ProcessInstance.TargetObjectId));
                        pwItem.ActorId = quoteIdNewFseMap.get(quoteLineIdQuoteIdMap.get(pwItem.ProcessInstance.TargetObjectId));
                        if(!updatedPWItems.contains(pwItem)){
                            updatedPWItems.add(pwItem);
                        }    
                    }
                }
            }
            try{
                if(updatedPWItems.size() > 0){
                    SBQQ.TriggerControl.disable();
                    update updatedPWItems;
                    SBQQ.TriggerControl.enable();
                    Pricing_QuoteTeam_Trigger_Handler.isApprovalReassign = true;
                } 
                
                if(approvalRequestList.size() > 0){
                    Approval.process(approvalRequestList);
                }   
            } 
            catch(exception ex){
                Pricing_Tender_Utility.logError(ex);
                for( Integer i = 0; i < ex.getNumDml(); i++ ){
                    for(SBQQ__Quote__c quote : lstquote){
                        if(quote.Id == quoteLineIdQuoteIdMap.get(pwitemMapQuoteLineIdMap.get(ex.getDmlId( i )))){
                            quote.addError(Label.Pricing_FSE_Reassign_After_Submission_Error);
                        }     
                    }
                }
            }
        }
    }
    
    /**
    * @description Method to check if Non-Latin characters are present in Text fields
    * @author Subhanku | 12-19-2022 
    * @param SBQQ__Quote__c quote 
    * @param Map<Id SBQQ__Quote__c> oldMap 
    * @param Boolean isInsert 
    **/
    public static void validateQuoteTextFieldsForLatinChars(SBQQ__Quote__c quote,Map<Id,SBQQ__Quote__c> oldMap, Boolean isInsert){
        try{
            Set<String> quoteTextFields = new Set < String > ((Label.Pricing_Tender_Quote_Text_Fields).split(':'));
            if(quoteTextFields.size()>0){
                for(String field:quoteTextFields){
                    String fieldValue = '';
                    if(isInsert){
                        if(quote.get(field) != null){
                            fieldValue = (String)quote.get(field);
                        }
                    }else{
                        if((String)quote.get(field) != (String)oldMap.get(quote.Id).get(field)){
                            fieldValue = (String)quote.get(field);
                        }
                    }
                    if(!String.isEmpty(fieldValue)){
                        if(Pricing_Tender_Utility.validateNonLatinChars(fieldValue)){
                            quote.addError(field,Label.Pricing_Non_Latin_Char_Validation_Error);
                        }
                    }
                }
            }
        }catch(exception ex){
            Pricing_Tender_Utility.logError(ex);
        }
    }
    
    
    /**
    * @description Method to update CPQ Opportunity field
    * @author Subhanku | 12-19-2022 
    * @param List<SBQQ__Quote__c> lstQuote 
    **/
    public static void updateCPQOpportunityField(List<SBQQ__Quote__c> lstQuote, Map<Id,SBQQ__Quote__c>oldQuoteMap)
    {
        if(lstQuote != null && !lstquote.isEmpty()){
            for(SBQQ__Quote__c q: lstQuote){ 
                Boolean endCustomerOpportunityChanged = q.Pricing_End_Customer_Opportunity_Txt__c != oldQuoteMap.get(q.Id).Pricing_End_Customer_Opportunity_Txt__c;
                Boolean cpqOpportunityChanged = q.SBQQ__Opportunity2__c != oldQuoteMap.get(q.Id).SBQQ__Opportunity2__c;

                if(endCustomerOpportunityChanged && !isValidEndCustomerOpportunityId(q)){
                    quoteIdsWithInvalidEndCustomerOpportunityId.add(q.Id);
                    continue;
                }

                if(!String.isBlank(q.Pricing_End_Customer_Opportunity_Txt__c) && q.SBQQ__Opportunity2__c != null && endCustomerOpportunityChanged && cpqOpportunityChanged){
                    q.addError(Label.Pricing_opportunityDependentFieldsErrorMsg);
                }
                else if(endCustomerOpportunityChanged){
                    q.SBQQ__Opportunity2__c = q.Pricing_End_Customer_Opportunity_Txt__c;
                }
                else if(cpqOpportunityChanged){
                    q.Pricing_End_Customer_Opportunity_Txt__c = q.SBQQ__Opportunity2__c;
                }
                                             
            }
            
        }        
    }
    
    
    /**
    * @description Method to update Unified Global End Customer on Quote 
    * @author Subhanku | 12-19-2022 
    * @param List<SBQQ__Quote__c> quoteList 
    **/
    public static void updateUnifiedEndCustomerQuote(List<SBQQ__Quote__c> quoteList) {
        //Map to store the L1 Ids along with the different combinations of L2 SFId and End Customer Country
        Map<String,Map<String,String>> mapOfL1L2Country = new Map<String,Map<String,String>>(); //Map<L1Id,Map<Country,L2ObjId>> ---> L1Id=>{Country1=>L2ObjId} 
        Map<String,String> endCustomerL1IdMap = new Map<String,String>(); //Map of L1SFID to L1Ids from Quotes that were updated
        Set<String> endCustomerL1SFIdSet = new Set<String>(); //Set of L1 SFIDs from Quotes that were updated
        Set<String> endCustomerL1IdSet = new Set<String>();  //Set of L1 IDs from Quotes that were updated
        Map<String,Pricing_UnifiedEndCustomerAccountMapping__c> endCustomerRecordMap = new Map<String,Pricing_UnifiedEndCustomerAccountMapping__c>(); //Map of L1 SFIDs to L1 Records from Quotes that were updated
        List<Pricing_UnifiedEndCustomerAccountMapping__c> L1RecordtoAdd = new List<Pricing_UnifiedEndCustomerAccountMapping__c>(); //List of L1 Records to add
        Set<String> endCustomerNameIdset = new Set<String>();
        Set<Id> accountId = new Set<Id>();
        
        if(!quoteList.isEmpty()){
            for(SBQQ__Quote__c quote: quoteList){
                endCustomerL1SFIdSet.add(quote.Pricing_End_Customer__c);   //Set of L1 SFIDs from Quotes that were updated
                if(quote.Pricing_Customer_Nm__c == null){
                    endCustomerNameIdset.add(quote.Pricing_End_Customer_Name__c);
                    accountId.add(quote.SBQQ__Account__c);
                }
            }
            for(Pricing_UnifiedEndCustomerAccountMapping__c uniEndCustomer : [Select Id, Name, Pricing_Account_Nm__c, Pricing_Unified_EndCustomer_Id__c FROM Pricing_UnifiedEndCustomerAccountMapping__c where Name IN:endCustomerNameIdset]){
                if(endCustomerL1SFIdSet.contains(uniEndCustomer.Id)){
                    endCustomerL1IdMap.put(uniEndCustomer.Id,uniEndCustomer.Pricing_Unified_EndCustomer_Id__c); //Map of L1 Object rec Id and L1 Ids
                    if(!endCustomerL1IdSet.contains(uniEndCustomer.Pricing_Unified_EndCustomer_Id__c)){
                        endCustomerL1IdSet.add(uniEndCustomer.Pricing_Unified_EndCustomer_Id__c);  //Set of L1 IDs from Quotes that were updated
                    }
                }
                if(accountId.contains(uniEndCustomer.Pricing_Account_Nm__c) && endCustomerNameIdset.contains(uniEndCustomer.Name)){
                    endCustomerRecordMap.put(uniEndCustomer.Pricing_Account_Nm__c,uniEndCustomer);
                }
            }
            for(Pricing_UnifiedEndCustomerCountryMapping__c uniRec: [SELECT Id,Name, Pricing_Country_Nm__c,Pricing_Unified_EndCustomer_Id__c,Pricing_Unified_Country_EndCustomer_Id__c, 
                                                                     Pricing_Unified_EndCustomer_Act_Mapping__c,Pricing_Unified_EndCustomer_Act_Mapping__r.Pricing_Unified_EndCustomer_Id__c
                                                                     FROM Pricing_UnifiedEndCustomerCountryMapping__c WHERE Pricing_Unified_EndCustomer_Act_Mapping__r.Pricing_Unified_EndCustomer_Id__c IN:endCustomerL1IdSet ]){
                                                                         //If mapOfL1L2Country contains L1 Id as a key
                                                                         if(mapOfL1L2Country.containsKey(uniRec.Pricing_Unified_EndCustomer_Act_Mapping__r.Pricing_Unified_EndCustomer_Id__c)){
                                                                             if(!mapOfL1L2Country.get(uniRec.Pricing_Unified_EndCustomer_Act_Mapping__r.Pricing_Unified_EndCustomer_Id__c).containsKey(uniRec.Pricing_Country_Nm__c)){  //If the value map of L1Id key does not contain country then add the country and l2 SFId combination
                                                                                 mapOfL1L2Country.get(uniRec.Pricing_Unified_EndCustomer_Act_Mapping__r.Pricing_Unified_EndCustomer_Id__c).put(uniRec.Pricing_Country_Nm__c,uniRec.Id);
                                                                             }
                                                                         }else{ //If L1 Id not present in the Map add new value
                                                                             mapOfL1L2Country.put(uniRec.Pricing_Unified_EndCustomer_Act_Mapping__r.Pricing_Unified_EndCustomer_Id__c,new Map<String,String>{uniRec.Pricing_Country_Nm__c => uniRec.Id});
                                                                         }
                                                                         
                                                                     }
            //Update the Quote Unified Global End Customer
            for(SBQQ__Quote__c quote: quoteList){
                if(!mapOfL1L2Country.isEmpty()){ //i.e. if L1 id and country combination present 
                    //Check if mapOfL1L2Country contains L1 Id and the country combination
                    if(mapOfL1L2Country.containsKey(endCustomerL1IdMap.get(quote.Pricing_End_Customer__c)) && mapOfL1L2Country.get(endCustomerL1IdMap.get(quote.Pricing_End_Customer__c)).containsKey(quote.Pricing_End_Customer_Country_Nm__c)){
                        quote.Pricing_Unified_Global_End_Customer_Nm__c = mapOfL1L2Country.get(endCustomerL1IdMap.get(quote.Pricing_End_Customer__c)).get(quote.Pricing_End_Customer_Country_Nm__c);
                        //Create L1 Record if Quote's Account and L1's account is different  
                        if(endCustomerRecordMap == null || !endCustomerRecordMap.containsKey(quote.SBQQ__Account__c)){
                            Pricing_UnifiedEndCustomerAccountMapping__c newEndCustAccountL1 = new Pricing_UnifiedEndCustomerAccountMapping__c();
                            newEndCustAccountL1.Name = quote.Pricing_End_Customer_Name__c;
                            newEndCustAccountL1.Pricing_Account_Nm__c = quote.SBQQ__Account__c;  //To insert the L1 account for the Quote's account
                            newEndCustAccountL1.Pricing_Active_cb__c = true;
                            newEndCustAccountL1.Pricing_Unified_EndCustomer_Id__c = endCustomerL1IdMap.get(quote.Pricing_End_Customer__c);
                            L1RecordtoAdd.add(newEndCustAccountL1);
                        }
                    }else {
                        //if there is no match in the L2 object
                        quote.Pricing_Unified_Global_End_Customer_Nm__c = null;
                        
                    }
                }else{
                    //if mapOfL1L2Country is empty
                    quote.Pricing_Unified_Global_End_Customer_Nm__c = null;                    
                }
            }
            if(!L1RecordtoAdd.isEmpty()){
                insert L1RecordtoAdd;
            }
        } 
    } 
    
    /**
    * @description Check Cap size volume for SVD Quotes
    * @author Subhanku | 12-19-2022 
    * @param Map<Id Integer> accountIdSVDQuoteNumberMap 
    * @param List<SBQQ__Quote__c> quotes 
    **/
    public static void checkSVDMaxVolume(Map<Id,Integer> accountIdSVDQuoteNumberMap,List<SBQQ__Quote__c> quotes){
        List<Pricing_QuoteProgram_CAPSize__c> quoteProgramList = [SELECT Id,Pricing_Account_Id__c,Pricing_Active_cb__c,Pricing_Small_Deal_CAP_size_Number__c FROM Pricing_QuoteProgram_CAPSize__c WHERE Pricing_Account_Id__c IN: accountIdSVDQuoteNumberMap.keySet() AND Pricing_Active_cb__c = true ];
        Map<Id,Integer> accountIdSVDCAPsizeMap = new Map<Id,Integer>();
        if(quoteProgramList.size() > 0) {
            for(Pricing_QuoteProgram_CAPSize__c qp : quoteProgramList){
                if(accountIdSVDQuoteNumberMap.containsKey(qp.Pricing_Account_Id__c) && !accountIdSVDCAPsizeMap.containsKey(qp.Pricing_Account_Id__c)){
                    accountIdSVDCAPsizeMap.put(qp.Pricing_Account_Id__c,Integer.valueOf(qp.Pricing_Small_Deal_CAP_size_Number__c));
                }
            }
        } 
        for(SBQQ__Quote__c quote: quotes){
            if(quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote){
                if(!accountIdSVDCAPsizeMap.isEmpty() && accountIdSVDCAPsizeMap.containsKey(quote.SBQQ__Account__c) && accountIdSVDCAPsizeMap.get(quote.SBQQ__Account__c) <= accountIdSVDQuoteNumberMap.get(quote.SBQQ__Account__c)){
                    quote.addError(Label.Pricing_Tender_Cap_Size_Quarter_Limit_Error+' ('+accountIdSVDCAPsizeMap.get(quote.SBQQ__Account__c)+' Quotes).');
                }
                if(!accountIdSVDCAPsizeMap.containsKey(quote.SBQQ__Account__c)){
                    //Check if the SVD Quote's Account is included in the Custom Setting, if not present, throw an error
                    quote.addError(Label.Pricing_Tender_SVD_Invalid_Account);
                }
            }
        }
    }


    /**
    * @description - Method to update Comment record's owner when Quote record owner is updated
    * @author Sandeep Chamate | 08-21-2023 
    * @param quotesIdtoRecMap - quote Id to Record Map
    **/
    public static void updateOwneronComments(Map<Id, SBQQ__Quote__c> quotesIdtoRecMap){
        List<Pricing_Comments__c> commentListtoUpdate = new List<Pricing_Comments__c>();
        for(Pricing_Comments__c cmt: [SELECT Id,OwnerId,Pricing_Quote__c FROM Pricing_Comments__c WHERE Pricing_Quote__c IN: quotesIdtoRecMap.keySet()]){
            cmt.OwnerId = quotesIdtoRecMap.get(cmt.Pricing_Quote__c).OwnerId;
            commentListtoUpdate.add(cmt);
        }
        if(commentListtoUpdate.size() > 0){
             SBQQ.TriggerControl.disable();
            update commentListtoUpdate;
            SBQQ.TriggerControl.enable();
        }
    }

    /**
    * @description Method to populate User Ids Map for AE and Sales Rep for Financial Incentive
    * @author Sandeep Chamate | 02-23-2024 
    * @param userEmailSet 
    * @param userEmailtoIdMapFI 
    **/
    public static void getUserIdsMapFI(Set<String> userEmailSet, Map<String, Id> userEmailtoIdMapFI) {
        for(User usr : [SELECT Id,Email,IsActive FROM User WHERE Email IN: userEmailSet AND IsActive = true]) {
            userEmailtoIdMapFI.put(usr.Email, usr.Id);
        }
    }

    //-----------------------Refactored Methods------------------------------------------------------------------------------------// 
    
    /**
    * @description create share record for parent id and user or group Id
    * @author Subhanku | 02-22-2023 
    * @param Id quoteId 
    * @param Set<Id> externalGroupIdSet 
    * @param Set<Id> userOrGroupId 
    * @param Boolean isAEShare 
    * @param Map<Id SBQQ__Quote__c> mapQuotesWithComments 
    * @param List<SBQQ__Quote__Share> quoteShares 
    * @param List<Pricing_Comments__Share> commentShares 
    **/
    public static void createQuoteAndCmntShare(Id quoteId,Set<Id> externalGroupIdSet,Set<Id> userOrGroupId,Boolean isAEShare,Map<Id,SBQQ__Quote__c> mapQuotesWithComments,List<SBQQ__Quote__Share> quoteShares,List<Pricing_Comments__Share> commentShares){
        for(id userId : userOrGroupId){
            quoteShares.add(new SBQQ__Quote__Share(ParentId = quoteId,
                                                   UserOrGroupId = userId,
                                                   AccessLevel = 'edit',
                                                   RowCause = (isAEShare ? Schema.Pricing_Comments__Share.RowCause.Manual : (externalGroupIdSet.contains(userId) ? Schema.SBQQ__Quote__Share.RowCause.Pricing_Partner_Group_Mapping__c : Schema.SBQQ__Quote__Share.RowCause.Pricing_Account_Team_Group__c ))));
            
            // Get the child comments from Map object for a Quote Id(one quote can have multiple comments)
            List<Pricing_Comments__c> comments = mapQuotesWithComments.get(quoteId).Comments__r;
            if(!comments.isEmpty()){
                // looping through each Comment for each team member
                for(Pricing_Comments__c comment : comments){
                    commentShares.add(new Pricing_Comments__Share(ParentId = comment.Id,
                                                                  UserOrGroupId = userId,
                                                                  AccessLevel = 'edit',
                                                                  RowCause = (isAEShare ? Schema.Pricing_Comments__Share.RowCause.Manual : (externalGroupIdSet.contains(userId) ? Schema.SBQQ__Quote__Share.RowCause.Pricing_Partner_Group_Mapping__c : Schema.SBQQ__Quote__Share.RowCause.Pricing_Account_Team_Group__c))));
                }
            }
        }
    }
    
    /**
    * @description add quote id to user id in Map for share creation
    * @author Subhanku | 02-22-2023 
    * @param Id quoteId 
    * @param Id userId 
    **/
    public static void addToAEorSalesRepShareMap(Id quoteId,Id userId,Map<Id,Set<Id>> quoteIdToAESalesRepShareMap){
        if(!quoteIdToAESalesRepShareMap.containsKey(quoteId)){
            quoteIdToAESalesRepShareMap.put(quoteId,new Set<Id>{userId});
        }
        else{
            quoteIdToAESalesRepShareMap.get(quoteId).add(userId);
        }
    }

    /**
    * @description populate quote account and primary contact
    * @author Subhanku | 02-22-2023 
    * @param SBQQ__Quote__c quote 
    * @param Id partnerAccountId 
    * @param Set<id> userContactIds 
    * @param Map<String Id> emailToContactIdMap 
    * @param Map<Id String> contactIdToEmailMap 
    **/
    public static void populatePrimaryContactAndAccount(SBQQ__Quote__c quote,Id partnerAccountId,Set<id> userContactIds,Map<String,Id> emailToContactIdMap,Map<Id,String> contactIdToEmailMap){
        if(isPartnerUser || quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote){
            quote.SBQQ__Account__c = String.isNotBlank(partnerAccountId) ? partnerAccountId : quote.SBQQ__Account__c;
            //for primary contact email field 
            if(quote.Pricing_Primary_Contact_Email__c != null){
                quote.SBQQ__PrimaryContact__c = emailToContactIdMap.get(quote.Pricing_Primary_Contact_Email__c);
                userContactIds.add(quote.SBQQ__PrimaryContact__c);
            }else{
                quote.SBQQ__PrimaryContact__c = String.isNotBlank(currentUser.ContactId) ? currentUser.ContactId : quote.SBQQ__PrimaryContact__c;
                quote.Pricing_Primary_Contact_Email__c = String.isNotBlank(currentUser.contact.Email) ? currentUser.contact.Email : contactIdToEmailMap.get(quote.SBQQ__PrimaryContact__c);
            }
            quote.OwnerId = currentUser.Id;
        }else if(quote.SBQQ__PrimaryContact__c != null){
            userContactIds.add(quote.SBQQ__PrimaryContact__c); 
            quote.Pricing_Primary_Contact_Email__c = contactIdToEmailMap.get(quote.SBQQ__PrimaryContact__c);
        }
    }

    /**
    * @description creating quote account to quote salesRep Map for validating sales rep
    * @author Subhanku | 02-22-2023 
    * @param SBQQ__Quote__c quote 
    * @param String salesRepEmail 
    * @param Map<Id Set<String>> accountIdToSalesRepEmailMap 
    **/
    public static void getAccountToSalesRepEmailMap(SBQQ__Quote__c quote,String salesRepEmail,Map<Id,Set<String>> accountIdToSalesRepEmailMap){
        if(!accountIdToSalesRepEmailMap.containsKey(quote.SBQQ__Account__c)){
            accountIdToSalesRepEmailMap.put(quote.SBQQ__Account__c,new Set<String>{salesRepEmail});
        }else{
            accountIdToSalesRepEmailMap.get(quote.SBQQ__Account__c).add(salesRepEmail);
        }
    }

    /**
    * @description creating quote account to name Map
    * @author Subhanku | 02-22-2023 
    * @param Set<Id> accountIdSet 
    * @param Map<Id String> accountIdNameMap 
    **/
    public static void getAccountToNameMap(Set<Id> accountIdSet,Map<Id,String> accountIdNameMap){
        for(Account acc:[SELECT Id, Name, Core_Customer_Aggregation_Type__c, Core_Unified_Intermediate_Customer_Name__c,Core_Unified_Global_Customer_Name__c ,Core_Unified_Intermdt_Customer_2_Name__c 
                         FROM Account WHERE id IN:accountIdSet]){
            if(!accountIdNameMap.containsKey(acc.Id)){
                accountIdNameMap.put(acc.Id,acc.Name);
                accountIdtoRecordMap.put(acc.Id, acc);
            }
        }
    }

    /**
    * @description creating endcustomer id to name Map 
    * @author Subhanku | 02-22-2023 
    * @param Set<Id> endCustomerIdSet 
    * @param Map<Id String> endCustomerIdNameMap 
    **/
    public static void getEndCustIdToNameMap(Set<Id> endCustomerIdSet,Map<Id,String> endCustomerIdNameMap){
        for(Pricing_UnifiedEndCustomerAccountMapping__c endCustomer:[SELECT Id, Name FROM Pricing_UnifiedEndCustomerAccountMapping__c WHERE id IN:endCustomerIdSet]){
            if(!endCustomerIdNameMap.containsKey(endCustomer.Id)){
                endCustomerIdNameMap.put(endCustomer.Id,endCustomer.Name);
            }
        }
    }

    /**
    * @description creating user contact id to user Map for validating primary contact
    * @author Subhanku | 02-22-2023 
    * @param Set<id> userContactIds 
    * @param Map<Id User> userContactDtls 
    **/
    public static void getUsrContactDtlsMap(Set<id> userContactIds,Map<Id, User> userContactDtls){
        For(User usr : [SELECT Id,ContactId,contact.accountid,Core_User_Profile_Name__c, (SELECT Id, PermissionSet.Name, AssigneeId, Assignee.ContactId
                                                                                          FROM PermissionSetAssignments WHERE PermissionSet.Name IN: Label.Pricing_Tender_PermissionSets_AllExternal.Split(':'))
                        FROM User WHERE ContactId IN :userContactIds and IsActive = true]){
                            userContactDtls.put(usr.ContactId,usr);
                        }
    }

    /**
    * @description creating account to cap size map for checking svd cap size
    * @author Subhanku | 02-22-2023 
    * @param Set<Id> accountIdSVDSet 
    * @param Map<Id Integer> accountIdSVDQuoteNumberMap 
    **/
    public static void getSVDCapSizeMap(Set<Id> accountIdSVDSet,Map<Id,Integer> accountIdSVDQuoteNumberMap){
        for(AggregateResult aggResult : [SELECT SBQQ__Account__c,count(Id) FROM SBQQ__Quote__c WHERE Pricing_Program_Type_Nm__c =: Label.Pricing_Tender_Small_Volume_Quote 
                                         AND CreatedDate = THIS_QUARTER AND SBQQ__Account__c IN :accountIdSVDSet AND
                                         SBQQ__Status__c IN: Label.Pricing_QuoteStatus_AllPicklistValues_Except_Rejected.split(':') GROUP BY SBQQ__Account__c]){
                                             accountIdSVDQuoteNumberMap.put((Id)aggResult.get('SBQQ__Account__c'),(Integer)aggResult.get('expr0'));  
                                             
                                         }
    }

    /**
    * @description populate quote Folio name
    * @author Subhanku | 02-22-2023 
    * @param SBQQ__Quote__c quote2 
    * @param Map<Id String> accountIdNameMap 
    **/
    public static void populateFolioIdAndName(SBQQ__Quote__c quote2,Map<Id,String> accountIdNameMap,Map<Id,String> endCustomerIdNameMap){
        String endCustomer = '';
        if(quote2.Pricing_Customer_Nm__c!=null){
            endCustomer = quote2.Pricing_Customer_Nm__c;
        }else{
            endCustomer = endCustomerIdNameMap.get(quote2.Pricing_End_Customer__c);
        }
        quote2.Pricing_My_Deals_Folio_Name_Nm__c = accountIdNameMap.get(quote2.SBQQ__Account__c) + ' - '+quote2.Pricing_Region_Nm__c + ' - ' +endCustomer + ' - ' + system.now();
        quote2.Pricing_My_Deals_Folio_Name_Nm__c.substring(0, Math.min(quote2.Pricing_My_Deals_Folio_Name_Nm__c.length(), Integer.valueOf(Label.Pricing_Folio_Name_Limit)));
    }

    /**
    * @description creating status and recordtype Map
    * @author Subhanku | 02-22-2023 
    * @param Map<Decimal String> quoteLineNumberToStatusMap 
    * @param Map<Decimal String> quoteLineNumberToRecordTypeMap 
    * @param Map<Decimal String> quoteLineNumberToClientRecordTypeMap 
    **/
    public static void getQuoteStatusAndRecTypeMap(Map<Decimal,String> quoteLineNumberToStatusMap,Map<Decimal,String> quoteLineNumberToRecordTypeMap,Map<Decimal,String> quoteLineNumberToClientRecordTypeMap,Map<Decimal,String> quoteLineNumberToFinancialIncentiveRecordTypeMap,Id SubmittedIdFinancialIncentive,Id ReadOnlyIdFinancialIncentive,Id EditId,Id EditIdClient){
        Id submittedId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Submitted);
        Id readOnlyId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_ReadOnly);
        Id submittedIdClient = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Client_Quote_RecordType_Submitted);
        Id readOnlyIdClient = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Client_Quote_RecordType_ReadOnly);
        
        quoteLineNumberToStatusMap.put(10,Label.Pricing_Tender_Quote_Status_Draft); 
        quoteLineNumberToStatusMap.put(20,Label.Pricing_Tender_Quote_Status_Rejected);
        quoteLineNumberToStatusMap.put(30,Label.Pricing_Tender_Quote_Status_Submitted);
        quoteLineNumberToStatusMap.put(40,Label.Pricing_Tender_Quote_Status_Submitted);
        quoteLineNumberToStatusMap.put(45,Label.Pricing_Tender_Quote_Status_Submitted);
        quoteLineNumberToStatusMap.put(50,Label.Pricing_Tender_Quote_Status_Approved);
        quoteLineNumberToStatusMap.put(60,Label.Pricing_Tender_Quote_Status_Lost);
        quoteLineNumberToStatusMap.put(70,Label.Pricing_Tender_Quote_Status_Won);
        
        quoteLineNumberToRecordTypeMap.put(10,EditId); 
        quoteLineNumberToRecordTypeMap.put(20,submittedId);
        quoteLineNumberToRecordTypeMap.put(30,submittedId);
        quoteLineNumberToRecordTypeMap.put(40,submittedId);
        quoteLineNumberToRecordTypeMap.put(45,readOnlyId); //For Integration ReadOnly Status Update
        quoteLineNumberToRecordTypeMap.put(50,readOnlyId);
        quoteLineNumberToRecordTypeMap.put(60,readOnlyId);
        quoteLineNumberToRecordTypeMap.put(70,readOnlyId);
        
        quoteLineNumberToClientRecordTypeMap.put(10,EditIdClient); 
        quoteLineNumberToClientRecordTypeMap.put(20,submittedIdClient);
        quoteLineNumberToClientRecordTypeMap.put(30,submittedIdClient);
        quoteLineNumberToClientRecordTypeMap.put(40,submittedIdClient);
        quoteLineNumberToClientRecordTypeMap.put(45,readOnlyIdClient); //For Integration ReadOnly Status Update
        quoteLineNumberToClientRecordTypeMap.put(50,readOnlyIdClient);
        quoteLineNumberToClientRecordTypeMap.put(60,readOnlyIdClient);
        quoteLineNumberToClientRecordTypeMap.put(70,readOnlyIdClient);

        quoteLineNumberToFinancialIncentiveRecordTypeMap.put(20,SubmittedIdFinancialIncentive);
        quoteLineNumberToFinancialIncentiveRecordTypeMap.put(30,SubmittedIdFinancialIncentive);
        quoteLineNumberToFinancialIncentiveRecordTypeMap.put(40,SubmittedIdFinancialIncentive);
        quoteLineNumberToFinancialIncentiveRecordTypeMap.put(45,ReadOnlyIdFinancialIncentive); //For Integration ReadOnly Status Update
        quoteLineNumberToFinancialIncentiveRecordTypeMap.put(50,ReadOnlyIdFinancialIncentive);
        quoteLineNumberToFinancialIncentiveRecordTypeMap.put(60,ReadOnlyIdFinancialIncentive);
        quoteLineNumberToFinancialIncentiveRecordTypeMap.put(70,ReadOnlyIdFinancialIncentive);
    }

    /**
    * @description check for Owner change or Primary Contact Change
    * @author Subhanku | 02-22-2023 
    * @param Map<Id SBQQ__Quote__c> oldMap 
    * @param SBQQ__Quote__c quote 
    * @param Set<id> userContactIds 
    * @param Set<Id> allPrimaryContactIds 
    * @param Set<Id> quoteIdWithPrimaryContactChange 
    * @param Set<Id> quoteIdWithOwnerChange 
    * @param Map<String Id> emailToContactIdMap 
    * @param Map<Id String> contactIdToEmailMap 
    **/
    public static void checkOwnerAndPrimaryContactChange(Map<Id,SBQQ__Quote__c> oldMap,SBQQ__Quote__c quote,Set<id> userContactIds,Set<Id> allPrimaryContactIds,Set<Id> quoteIdWithPrimaryContactChange,Set<Id> quoteIdWithOwnerChange,Map<String,Id> emailToContactIdMap,Map<Id,String> contactIdToEmailMap){
        // Capture owner change to prevent from user actions from Change Owner OOB functionality
        if (oldMap.get(quote.id).ownerid != quote.ownerid && quote.SBQQ__PrimaryContact__c != null) {
            userContactIds.add(quote.SBQQ__PrimaryContact__c); 
            quoteIdWithOwnerChange.add(quote.Id);
        }
        //Primary Contact Email change
        if (oldMap.get(quote.id).Pricing_Primary_Contact_Email__c != quote.Pricing_Primary_Contact_Email__c){
            if(quote.Pricing_Primary_Contact_Email__c == null){
                quote.Pricing_Primary_Contact_Email__c = currentUser.contact.Email;
                quote.SBQQ__PrimaryContact__c = currentUser.ContactId;
            }else{
                quote.SBQQ__PrimaryContact__c = emailToContactIdMap.get(quote.Pricing_Primary_Contact_Email__c); 
            } 
            quoteIdWithPrimaryContactChange.add(quote.Id); 
            userContactIds.add(quote.SBQQ__PrimaryContact__c);  
        }
        if (oldMap.get(quote.id).SBQQ__PrimaryContact__c != quote.SBQQ__PrimaryContact__c && quote.SBQQ__PrimaryContact__c != null && contactIdToEmailMap.get(quote.SBQQ__PrimaryContact__c) != null){
            quote.Pricing_Primary_Contact_Email__c = contactIdToEmailMap.get(quote.SBQQ__PrimaryContact__c);
        }
        //Check if Primary Contact Changes and update the Owner
        if (oldMap.get(quote.id).SBQQ__PrimaryContact__c != quote.SBQQ__PrimaryContact__c && quote.SBQQ__PrimaryContact__c != null){
            quoteIdWithPrimaryContactChange.add(quote.Id);
            userContactIds.add(quote.SBQQ__PrimaryContact__c);
        }
        if( quote.SBQQ__PrimaryContact__c != null){
            allPrimaryContactIds.add(quote.SBQQ__PrimaryContact__c);
        }
    }

    /**
    * @description creating user contact id to user map and drafter primary contact set to validate Primary contact
    * @author Subhanku | 02-22-2023 
    * @param Set<id> userContactIds 
    * @param Set<Id> allPrimaryContactIds 
    * @param Set<Id> contactIdWithDrafterLimitedSet 
    * @param Map<Id User> userContactDtls 
    * @return staic 
    **/
    public static void getUsrDtlsMapAndDrafterSet(Set<id> userContactIds,Set<Id> allPrimaryContactIds,Set<Id> contactIdWithDrafterLimitedSet,Map<Id,User> userContactDtls){
        For(User usr: [SELECT Id,ContactId,contact.accountid,Core_User_Profile_Name__c,(SELECT PermissionSet.Name,AssigneeId FROM PermissionSetAssignments WHERE PermissionSet.Name IN: Label.Pricing_Tender_PermissionSets_AllExternal.Split(':')) 
                       FROM User WHERE ContactId IN :allPrimaryContactIds and IsActive = true]){
                           if(userContactIds.contains(usr.ContactId)){
                               userContactDtls.put(usr.ContactId,usr);
                           }
                           for(PermissionSetAssignment psa: usr.PermissionSetAssignments){
                               if(psa.PermissionSet.Name == Label.Pricing_Tender_PermissionSets_TenderDrafterLimited){
                                   contactIdWithDrafterLimitedSet.add(usr.ContactId);
                               }
                           }
                       }
    }

    /**
    * @description creating Map of opportunity id to opportunity to validate opportunity and populate
    * @author Subhanku | 02-22-2023 
    * @param Set<String> opportunityIds 
    * @param Map<String Opportunity> opportunityDetails 
    **/
    public static void getOpportunityMap(Map<String,id> opportunityIdquoteId,Map<String, Opportunity> opportunityDetails,Map<Id, Opportunity> quoteIdToOppRecdMap,Boolean isEndCustCheck){
        List<Opportunity> opportunityDtl = new List<Opportunity>([SELECT Id,Name,Account.Core_Business_Party_Id__c, Account.Core_Unified_Global_Customer_BP_Id__c FROM Opportunity 
                                                                  WHERE Id IN :opportunityIdquoteId.keyset()]);
        For(Opportunity opDtl:opportunityDtl){
            if(!isEndCustCheck){
            opportunityDetails.put(opDtl.Id,opDtl);
            }else{
                quoteIdToOppRecdMap.put(opportunityIdquoteId.get(opDtl.Id),opDtl);
            }
        }
    }

    /**
    * @description check for any integration error during create deal
    * @author Subhanku | 02-22-2023 
    * @param Set<Id> quoteIdWithFolioNameChangeSet 
    * @param Set<Id> quoteIdWithFolioErrorSet 
    **/
    public static void checkForIntegrationError(Set<Id> quoteIdWithFolioNameChangeSet,Set<Id> quoteIdWithFolioErrorSet){
        List<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id,Pricing_Error_Messages__c,Pricing_Status_Nm__c,Pricing_Integration_Status_Nm__c,
                                                  SBQQ__Quote__c from SBQQ__QuoteLine__c where SBQQ__Quote__c IN: quoteIdWithFolioNameChangeSet 
                                                  and (Pricing_Integration_Status_Nm__c IN: Label.Pricing_IntegrationStatus.Split(','))
                                                  and Pricing_Status_Nm__c =: Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview];
        for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
            String errMsg = quoteLine.Pricing_Error_Messages__c;
            if(quoteLine.Pricing_Integration_Status_Nm__c == Label.Pricing_Tender_MyDeal_Integration_Status_Error){
                if(!(errMsg.containsIgnoreCase(Label.Pricing_Folio_Error_1) || errMsg.containsIgnoreCase(Label.Pricing_Folio_Error_2))){
                    quoteIdWithFolioErrorSet.add(quoteLine.SBQQ__Quote__c);
                }
            }else{
                quoteIdWithFolioErrorSet.add(quoteLine.SBQQ__Quote__c);
            }
        }
    }

    /**
    * @description creating map of quote id to pricing start date for validating quoteline end date
    * @author Subhanku | 02-22-2023 
    * @param Set<Id> quoteIdWithStartDatechange 
    * @param Map<Id List<SBQQ__QuoteLine__c>> quotelineStartDateChange 
    **/
    public static void getQuoteToStartDateMap(Set<Id> quoteIdWithStartDatechange,Map<Id,List<SBQQ__QuoteLine__c>> quotelineStartDateChange){
        for(SBQQ__QuoteLine__c qli: [Select Id, Pricing_Quote_Line_Number__c, Pricing_End_Date_dt__c,SBQQ__Quote__c from SBQQ__QuoteLine__c where SBQQ__Quote__c IN :quoteIdWithStartDatechange]){
            if(quotelineStartDateChange.containsKey(qli.SBQQ__Quote__c)){
                quoteLineStartDateChange.get(qli.SBQQ__Quote__c).add(qli);
            }else{
                quotelineStartDateChange.put(qli.SBQQ__Quote__c, new List<SBQQ__QuoteLine__c>{qli});
            }
        }
    }

    /**
    * @description fix added for flip flop issue
    * @author Subhanku | 02-22-2023 
    * @param SBQQ__Quote__c quote 
    * @param Map<Decimal String> quoteLineNumberToStatusMap 
    * @param Map<Decimal String> quoteLineNumberToRecordTypeMap 
    * @param Map<Decimal String> quoteLineNumberToClientRecordTypeMap 
    **/
    public static void statusRevertFix(SBQQ__Quote__c quote,Map<Decimal,String> quoteLineNumberToStatusMap,Map<Decimal,String> quoteLineNumberToRecordTypeMap,Map<Decimal,String> quoteLineNumberToClientRecordTypeMap, Map<Decimal,String> quoteLineNumberToFinancialIncentiveRecordTypeMap){
        if(quote.Pricing_Status_Precedence_Number__c != null && quoteLineNumberToStatusMap.containsKey(quote.Pricing_Status_Precedence_Number__c) 
           && quoteLineNumberToStatusMap.get(quote.Pricing_Status_Precedence_Number__c) != quote.SBQQ__Status__c) {
               quote.SBQQ__Status__c = quoteLineNumberToStatusMap.get(quote.Pricing_Status_Precedence_Number__c);
           }
        if(quote.Pricing_Status_Precedence_Number__c != null && (quoteLineNumberToClientRecordTypeMap.containsKey(quote.Pricing_Status_Precedence_Number__c) || quoteLineNumberToRecordTypeMap.containsKey(quote.Pricing_Status_Precedence_Number__c) || quoteLineNumberToFinancialIncentiveRecordTypeMap.containsKey(quote.Pricing_Status_Precedence_Number__c)) 
           && (quoteLineNumberToClientRecordTypeMap.get(quote.Pricing_Status_Precedence_Number__c) != quote.recordTypeId  || quoteLineNumberToRecordTypeMap.get(quote.Pricing_Status_Precedence_Number__c) != quote.recordTypeId || quoteLineNumberToFinancialIncentiveRecordTypeMap.get(quote.Pricing_Status_Precedence_Number__c) != quote.recordTypeId)) {
            quote.recordTypeId = (quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote)?quoteLineNumberToClientRecordTypeMap.get(quote.Pricing_Status_Precedence_Number__c): quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote ? quoteLineNumberToFinancialIncentiveRecordTypeMap.get(quote.Pricing_Status_Precedence_Number__c) : quoteLineNumberToRecordTypeMap.get(quote.Pricing_Status_Precedence_Number__c);  
        }
    }   
    
    public static void validateQLIProductagainstOpportunityProduct(Map<String, Id> oppIdtoQuoteIdMap, Map<Id, Boolean> quoteIdwithProdMap){
        for(SBQQ__QuoteLine__c qli: [SELECT Id, SBQQ__Quote__c, Pricing_Product_Nm__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN: oppIdtoQuoteIdMap.values()]){
            if(quoteIdtoProdMap.containsKey(qli.SBQQ__Quote__c)){
                quoteIdtoProdMap.get(qli.SBQQ__Quote__c).add(qli.Pricing_Product_Nm__c);
            }
            else{
                quoteIdtoProdMap.put(qli.SBQQ__Quote__c, new Set<Id>{qli.Pricing_Product_Nm__c});
            }
        }
        if(quoteIdtoProdMap.size() > 0 ){
            for(OpportunityLineItem opplItem: [SELECT Id, OpportunityId, Product2Id FROM OpportunityLineItem WHERE OpportunityId IN: oppIdtoQuoteIdMap.keySet()]){
                if(quoteIdtoProdMap.get(oppIdtoQuoteIdMap.get(opplItem.OpportunityId)).contains(opplItem.Product2Id)){
                    quoteIdwithProdMap.put(oppIdtoQuoteIdMap.get(opplItem.OpportunityId), false);
                    break;
                }
                else{
                    quoteIdwithProdMap.put(oppIdtoQuoteIdMap.get(opplItem.OpportunityId), true);
                }
                
            }
        }
    }

    
    /**
    * @description :Method to validate Quotes unified Endcustomer to opportunity Account End customer.
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 03-13-2024 
    * @param opptyIdtoQuoteIdMap 
    * @param quoteIdvalidEndCustomerMap 
    **/
    public static void validateEndCustOfQuoteAndOppty(Map<String,Id> opptyIdtoQuoteIdMap, Map<Id, Boolean> quoteIdvalidEndCustomerMap){
        for(SBQQ__Quote__c quote: [SELECT Id,Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_Country_EndCustomer_Id__c, Pricing_Unified_Global_End_Customer_Nm__r.Pricing_RequestID__r.Core_Unified_Global_Customer_BP_Id__c,Pricing_IsUnifiedCustomer__c  FROM SBQQ__Quote__c WHERE id IN: opptyIdtoQuoteIdMap.values()]){ 
            if(quote.Pricing_IsUnifiedCustomer__c && quoteIdToOppRecdMap.containskey(quote.id)  && quote.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_RequestID__r.Core_Unified_Global_Customer_BP_Id__c != quoteIdToOppRecdMap.get(quote.id).Account.Core_Unified_Global_Customer_BP_Id__c){
                quoteIdvalidEndCustomerMap.put(quote.id,true);
            }
            else{
                quoteIdvalidEndCustomerMap.put(quote.id,false);  //send warning
            }
        }
    } 

    /**
    * @description: Method to sent QuoteLine Approve Notification to AE when opportunity Won/Lost. 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 03-13-2024 
    * @param quoteIds 
    **/
    public static void qlApproveAENotifyForOppWonLost(set<id> quoteIds){
        Map<Id,Id> quoteNotifyMap= new Map <Id,Id>();
        List<SBQQ__QuoteLine__c> quoteLineList = ([SELECT Id, Name,SBQQ__Quote__c,Pricing_Status_Nm__c ,SBQQ__Quote__r.Pricing_Intel_Account_Exec_Email_Txt__c,Pricing_Product_Nm__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN: quoteIds and Pricing_Quote_Program_Nm__c =: Label.Pricing_Tender_Quote_Program]);
        for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                if(!quoteNotifyMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_Quote_Status_Approved && !String.isBlank(quoteline.SBQQ__Quote__r.Pricing_Intel_Account_Exec_Email_Txt__c)){
                    quoteNotifyMap.put(quoteLine.SBQQ__Quote__c, quoteLine.Id);
                }
        }
        if(!quoteNotifyMap.isEmpty()){
            Pricing_EmailUtility.sendEmailToReciepents(new Set<Id>(quoteNotifyMap.values()),Label.Pricing_QuoteLine_Approve_OppWonLost_Notification);
        }
    }

/**
* @description: Method to validate if End Customer Opportunity ID text field contains a valid 15- or 18-character Salesforce ID or is blank.
* @author Deepthi | 21-09-2026 
* @param q 
* @return Boolean
**/
public static Boolean isValidEndCustomerOpportunityId(SBQQ__Quote__c q) {
    if (String.isBlank(q.Pricing_End_Customer_Opportunity_Txt__c)) {
        return true;
    }

    String val = q.Pricing_End_Customer_Opportunity_Txt__c.trim();

    // Validates against the Custom Label regex pattern
    Boolean isValidFormat = Pattern.matches(Label.Pricing_SalesforceId_Regex, val);

    if (!isValidFormat) {
        q.Pricing_End_Customer_Opportunity_Txt__c.addError(
            Label.Pricing_InvalidSalesforceIdErrorMsg
        );
        return false;
    }

    return true;
}
//-----------------------End - Refactored code------------------------------------------------------------------------------------//

//Citrus change
public static void autoPopulateIntelAccountExceutive(Map<Id, SBQQ__Quote__c> ugEndCustomerChangedQuotes,List<SBQQ__Quote__c> lstquote){
     List<SBQQ__Quote__c> quoteList = new  List<SBQQ__Quote__c>();
     // Citrus: Auto Populate Intel Account Executive and Intel Account Executive Email
     if (!ugEndCustomerChangedQuotes.isEmpty()) {
     	Map<Id, Account> quoteToIntelAccRecMap = getIntelAccByUnifiedEndCustomer(ugEndCustomerChangedQuotes);
        for (SBQQ__Quote__c q : lstquote) {
            String salesRepEmail = q.Pricing_Intel_Sales_Rep_Email_Txt__c;
            Account acc = quoteToIntelAccRecMap.get(q.Id);
            Boolean isAccountExecutiveAndEmailBlank = q.Pricing_Account_Executive_Nm__c == null && q.Pricing_Intel_Account_Exec_Email_Txt__c == null;
			quoteList.add(new SBQQ__Quote__c(
                            Id = q.Id,
                            Pricing_Account_Executive_Nm__c = isAccountExecutiveAndEmailBlank ? (acc != null ? (acc.Owner !=null && acc.Owner.Email != salesRepEmail ? acc.OwnerId: null): null) : q.Pricing_Account_Executive_Nm__c,
                            Pricing_Intel_Account_Exec_Email_Txt__c = isAccountExecutiveAndEmailBlank ? (acc != null && acc.Owner !=null && acc.Owner.Email !=null && acc.Owner.Email != salesRepEmail ? acc.Owner.Email : null) : q.Pricing_Intel_Account_Exec_Email_Txt__c,
                            Pricing_Is_Covered_Account_cb__c = acc != null ? acc.Core_Covered_Account__c : false
                            
                        ));
              }
         }
      if (!quoteList.isEmpty()) {
     	SBQQ.TriggerControl.disable();
        update quoteList;
		SBQQ.TriggerControl.enable();
       }
	}
}