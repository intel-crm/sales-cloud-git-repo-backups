/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 03-25-2025
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_QuoteTeam_Trigger_Handler extends TriggerHandler  {
    
    public static boolean isApprovalReassign = false;
    public static String userEmail;
    public static boolean hasQuoteLineResubmission = false;
    public static boolean isInertedFromQuoteTriggerorApi = false;
    //IQR Context variables
    public List<Pricing_Quote_Team__c> iqrTriggerNewList = new List<Pricing_Quote_Team__c>();
    public List<Pricing_Quote_Team__c> iqrTriggerOldList = new List<Pricing_Quote_Team__c>();
    public Map<Id,Pricing_Quote_Team__c> iqrTriggerNewMap = new Map<Id,Pricing_Quote_Team__c>();
    public String iqrQTMRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Quote_Team__c',Label.Pricing_Tender_Quote_Team_RecordType);
    
    public Pricing_QuoteTeam_Trigger_Handler(){
        if(Trigger.new != null){
            for(Pricing_Quote_Team__c qtm : (List<Pricing_Quote_Team__c>)Trigger.new){ 
                if(qtm.RecordTypeId == iqrQTMRecordTypeId){
                    iqrTriggerNewList.add(qtm);
                }
                if(Trigger.newMap != null && qtm.RecordTypeId == iqrQTMRecordTypeId){
                        iqrTriggerNewMap.put(qtm.Id,qtm);
                }
            }
        }
        if(Trigger.old != null){
            for(Pricing_Quote_Team__c qtm : (List<Pricing_Quote_Team__c>)Trigger.old){
                if(qtm.RecordTypeId == iqrQTMRecordTypeId){
                    iqrTriggerOldList.add(qtm);
                }
            } 
        } 
    }
    
    public override void afterInsert(){
        createQuoteSharesForQTM(iqrTriggerNewMap);  
        if(isActive('Pricing_QuoteTeam_EmailNotification') && !Pricing_BulkInsertUpdateAESalesRep_Batch.isBulkAEUpdateInsertOnQuoteQTM){
            sendEmailNotification(iqrTriggerNewList);
        }
        //For resubmission when 
        List<String> roleList = new List<String>();
        for(Pricing_Quote_Team__c qtm : iqrTriggerNewList){
            roleList.add(qtm.Pricing_Role_Nm__c);
        }
        if(roleList.contains(Label.Pricing_Quote_Team_Role_FSE) && !isApprovalReassign){
            quoteLineResubmission(iqrTriggerNewList);
        }
    }
    
    public override void beforeDelete(){
        deleteQuoteSharesforQTMs(iqrTriggerOldList);
    }
    
    public static void createQuoteSharesOnOwnerChange(Set<Id> quoteIds){
        if(quoteIds.size() > 0){
            Map<Id,Pricing_Quote_Team__c> quoteTeam = new Map<Id,Pricing_Quote_Team__c>([SELECT id,Pricing_Role_Nm__c,Pricing_Quote_Team_Member_Id__c,Pricing_Quote_Id__c,Pricing_Grant_Access_Ind__c 
                                                                                         FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Id__c IN :quoteIds]); 
            if(quoteTeam.size() > 0){
                createQuoteSharesForQTM(quoteTeam);
            }
        }        
    }
    
    public static void createQuoteSharesForQTM(Map<Id,Pricing_Quote_Team__c> quoteTeamMembersMap ){
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        Map<Id,Id> quoteIdtoUpdateFSEUserIdMap = new Map<Id,Id>();
        Map<String,Pricing_Quote_Team_Role_Access_Mapping__mdt> roleMappings = getRolesMappingMdt();
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        try{
            for(Pricing_Quote_Team__c qtm : quoteTeamMembersMap.values()){
                quoteIds.add(qtm.Pricing_Quote_Id__c);
                userIds.add(qtm.Pricing_Quote_Team_Member_Id__c);
                if(qtm.Pricing_Role_Nm__c == Label.Pricing_Quote_Team_Role_FSE && !quoteIdtoUpdateFSEUserIdMap.containsKey(qtm.Pricing_Quote_Id__c)){
                        quoteIdtoUpdateFSEUserIdMap.put(qtm.Pricing_Quote_Id__c,qtm.Pricing_Quote_Team_Member_Id__c);
                }
            }
            Map<id,List<SBQQ__Quote__share>> quoteIdShareMap = new Map<id,List<SBQQ__Quote__share>>();
            getQuoteSharesMap(quoteIds,quoteIdShareMap);
            List<Pricing_Quote_Team__c> qtmTobeUpdated = new List<Pricing_Quote_Team__c>();
            List<Pricing_Quote_Team__c> qtmTobeUpdatedList = new List<Pricing_Quote_Team__c>();
            List<SBQQ__Quote__share> newQuoteSahres = new List<SBQQ__Quote__share>();
            Map<Id,List<String>> userPermSetAssignmentMap = new Map<Id,List<String>>();      
            getUserPSMap(userIds,userPermSetAssignmentMap);
            List<Pricing_Comments__c> comments = new List<Pricing_Comments__c>([SELECT Id, Pricing_Quote__r.Id, RecordType.Id from Pricing_Comments__c WHERE RecordType.Id =:commentRecordTypeId AND Pricing_Quote__r.Id IN:quoteIds]);
            List<Pricing_Comments__Share> commentShares = new List<Pricing_Comments__Share>();
            Set<Id> quoteIdsForCommentShare = new Set<Id>();
            //Pricing_Tender_PermissionSets_TenderAccountExecutive
            for(Pricing_Quote_Team__c qtm : [SELECT id,Pricing_Role_Nm__c,Pricing_Quote_Team_Member_Id__c,Pricing_Quote_Id__c,Pricing_Grant_Access_Ind__c,Pricing_Quote_Team_Member_Id__r.Email,Pricing_Quote_Id__r.Pricing_Account_Executive_Nm__r.Email,Pricing_Quote_Id__r.Pricing_Intel_Account_Exec_Email_Txt__c 
                                             FROM Pricing_Quote_Team__c WHERE Id IN :quoteTeamMembersMap.keySet() and Pricing_Quote_Team_Member_Id__r.isActive = true]){
                                                 if(userPermSetAssignmentMap.containsKey(qtm.Pricing_Quote_Team_Member_Id__c) 
                                                    && roleMappings.containsKey(qtm.Pricing_Role_Nm__c) &&
                                                    userPermSetAssignmentMap.get(qtm.Pricing_Quote_Team_Member_Id__c).contains(roleMappings.get(qtm.Pricing_Role_Nm__c).Permission_Set_API_Nm__c)){
                                                        boolean isShareAvailable = false;
                                                        if(quoteIdShareMap.containsKey(qtm.Pricing_Quote_Id__c)){
                                                            for(SBQQ__Quote__share qShare : quoteIdShareMap.get(qtm.Pricing_Quote_Id__c)){
                                                                if(qShare.UserOrGroupId == qtm.Pricing_Quote_Team_Member_Id__c){
                                                                    isShareAvailable = true;    
                                                                    qtm.Pricing_Grant_Access_Ind__c = True;
                                                                    qtmTobeUpdated.add(qtm);
                                                                    break;
                                                                }
                                                            }  
                                                        }
                                                        if(!isShareAvailable && (qtm.Pricing_Role_Nm__c == Label.Pricing_Quote_Team_Role_ITS || qtm.Pricing_Role_Nm__c == Label.Pricing_Quote_Team_Role_Account_Executive)){
                                                            qtm.Pricing_Grant_Access_Ind__c = True;
                                                            if(!qtmTobeUpdated.contains(qtm)){
                                                                qtmTobeUpdated.add(qtm);
                                                            }
                                                            newQuoteSahres.add(new SBQQ__Quote__Share(ParentId = qtm.Pricing_Quote_Id__c,
                                                                                                      UserOrGroupId = qtm.Pricing_Quote_Team_Member_Id__c,
                                                                                                      AccessLevel = roleMappings.get(qtm.Pricing_Role_Nm__c).Pricing_Access_Level_Nm__c,
                                                                                                      RowCause = Schema.SBQQ__Quote__Share.RowCause.Manual)); 
                                                            if(!comments.isEmpty()){
                                                                for(Pricing_Comments__c comment : comments){
                                                                    if(!quoteIdsForCommentShare.contains(comment.Id)){
                                                                        commentShares.add(new Pricing_Comments__Share(ParentId = comment.Id,
                                                                                                                      UserOrGroupId = qtm.Pricing_Quote_Team_Member_Id__c,
                                                                                                                      AccessLevel = 'edit',
                                                                                                                      RowCause = Schema.Pricing_Comments__Share.RowCause.Manual));
                                                                    }
                                                                    quoteIdsForCommentShare.add(comment.Id);
                                                                }
                                                            }     
                                                        }
                                                        else if(qtm.Pricing_Role_Nm__c == Label.Pricing_Quote_Team_Role_FSE){
                                                            qtm.Pricing_Grant_Access_Ind__c = True;
                                                            if(!qtmTobeUpdated.contains(qtm)){
                                                                qtmTobeUpdated.add(qtm);
                                                            }
                                                        }
                                                    }else{
                                                        qtmTobeUpdatedList.add(qtm);
                                                    }
                                             }
            if(newQuoteSahres.size() > 0){
                insert newQuoteSahres;
            }
            if(commentShares.size() > 0){
                insert commentShares;
            }            
            if(qtmTobeUpdated.size() > 0){
                update qtmTobeUpdated;
            }  
            Set<Id> quoteIdsToBeUpdated = new Set<Id>();
            List<SBQQ__Quote__c> quoteToBeUpdated = new List<SBQQ__Quote__c>();
            Map<Id,SBQQ__Quote__c> quotesTobeUpdatedMap = new Map<Id,SBQQ__Quote__c>();
            for(Pricing_Quote_Team__c qtmUpdated : qtmTobeUpdated){
                if(!quoteIdsToBeUpdated.contains(qtmUpdated.Pricing_Quote_Id__c)){
                    if(qtmUpdated.Pricing_Role_Nm__c == Label.Pricing_Quote_Team_Role_Account_Executive && qtmUpdated.Pricing_Quote_Team_Member_Id__r.Email == qtmUpdated.Pricing_Quote_Id__r.Pricing_Intel_Account_Exec_Email_Txt__c){
                        addQuoteToMap(quotesTobeUpdatedMap, qtmUpdated.Pricing_Quote_Id__c, 'Pricing_Account_Executive_Nm__c', String.valueOf(qtmUpdated.Pricing_Quote_Team_Member_Id__c));
                        quoteIdsToBeUpdated.add(qtmUpdated.Pricing_Quote_Id__c);
                    } else if(qtmUpdated.Pricing_Role_Nm__c == Label.Pricing_Quote_Team_Role_Account_Executive && String.isEmpty(qtmUpdated.Pricing_Quote_Id__r.Pricing_Intel_Account_Exec_Email_Txt__c)){
                        
                        addQuoteToMap(quotesTobeUpdatedMap, qtmUpdated.Pricing_Quote_Id__c, 'Pricing_Intel_Account_Exec_Email_Txt__c', qtmUpdated.Pricing_Quote_Team_Member_Id__r.Email);
                        quoteIdsToBeUpdated.add(qtmUpdated.Pricing_Quote_Id__c);
                    }
                }
            }
            
            for(Pricing_Quote_Team__c qtmUpdated : qtmTobeUpdatedList){
                if(!quoteIdsToBeUpdated.contains(qtmUpdated.Pricing_Quote_Id__c) && qtmUpdated.Pricing_Role_Nm__c == Label.Pricing_Quote_Team_Role_Account_Executive && String.isEmpty(qtmUpdated.Pricing_Quote_Id__r.Pricing_Intel_Account_Exec_Email_Txt__c)){
                    
                    addQuoteToMap(quotesTobeUpdatedMap, qtmUpdated.Pricing_Quote_Id__c, 'Pricing_Intel_Account_Exec_Email_Txt__c', qtmUpdated.Pricing_Quote_Team_Member_Id__r.Email);
                    quoteIdsToBeUpdated.add(qtmUpdated.Pricing_Quote_Id__c);
                }
            }
            
            //To update Quote Sales rep if blank and FSE is added on the quote team
            if(!quoteIdtoUpdateFSEUserIdMap.isEmpty()){
                List<SBQQ__Quote__c> quoteListToUpdate = [SELECT id FROM SBQQ__Quote__c WHERE id IN :quoteIdtoUpdateFSEUserIdMap.keySet() AND
                                                          Pricing_Intel_Sales_Rep_Email_Txt__c=null];
                Set<Id> quoteIdSetToUpdate = (new Map<Id,SBQQ__Quote__c>(quoteListToUpdate)).keySet(); 
                Set<Id> quoteIdsToUpdateFSEIds = new Set<Id>();       
                Map<Id,String> userIdUserEmailMap = new Map<Id,String>();
                List<Id> fseUserIdSet = quoteIdtoUpdateFSEUserIdMap.values();
                for(User usr:[Select id,Email FROM User where ID IN :fseUserIdSet]){
                    userIdUserEmailMap.put(usr.Id,usr.Email);
                }
                for(Id quoteId : quoteIdtoUpdateFSEUserIdMap.keySet()){
                    if(quoteIdSetToUpdate.contains(quoteId) && !quoteIdsToUpdateFSEIds.contains(quoteId)){
                        
                        addQuoteToMap(quotesTobeUpdatedMap, quoteId, 'Pricing_Intel_Sales_Rep_Email_Txt__c', userIdUserEmailMap.get(quoteIdtoUpdateFSEUserIdMap.get(quoteId)));
                        quoteIdsToUpdateFSEIds.add(quoteId);
                    }
                }
            } 
            
            if(quotesTobeUpdatedMap.size() > 0){
                if(!isInertedFromQuoteTriggerorApi){
                    update quotesTobeUpdatedMap.values();
                }else{
                    isInertedFromQuoteTriggerorApi = false;
                }
            }
        }catch(exception ex){Pricing_Tender_Utility.logError(ex);}
    }
    
    public static void addQuoteToMap(Map<Id,SBQQ__Quote__c> quotesTobeUpdatedMap, Id quoteId, String fieldName, String value){
        if(quotesTobeUpdatedMap.containsKey(quoteId)){
            quotesTobeUpdatedMap.get(quoteId).put(fieldName, value);
        }else{
            SBQQ__Quote__c quoteToBeUpdated = new SBQQ__Quote__c();
            quoteToBeUpdated.put('Id', quoteId);
            quoteToBeUpdated.put(fieldName, value);
            quotesTobeUpdatedMap.put(quoteId, quoteToBeUpdated);
        }
    }
    
    public static void deleteQuoteSharesforQTMs(List<Pricing_Quote_Team__c> quoteTeamMembersList){ 
        //This method is triggered before deletion of quote team member to remove quote share record
        Map<Id,List<Id>> quoteIdUserIdMap = new Map<Id,List<Id>>();
        Set<Id> quoteIdsTobeUpdated = new Set<Id>();
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> qtmIds = new Set<Id>();
        Set<Id> aeDeletedQuotes = new Set<Id>();
        Set<Id> fseDeletedQuotes = new Set<Id>();
        
        for(Pricing_Quote_Team__c qtm: quoteTeamMembersList) {   
            quoteIds.add(qtm.Pricing_Quote_Id__c);
            
            qtmIds.add(qtm.Id);
        }       
        
        List<Pricing_Quote_Team__c> quoteTeamLst = [Select id,Pricing_Quote_Id__r.OwnerId,Pricing_Quote_Id__r.SBQQ__SalesRep__c,Pricing_Quote_Id__r.Pricing_Account_Executive_Nm__c,
                                                    Pricing_Quote_Id__r.Pricing_Intel_Account_Exec_Email_Txt__c,Pricing_Quote_Team_Member_Id__c,Pricing_Quote_Team_Member_Id__r.Email,
                                                    Pricing_Role_Nm__c,Pricing_Grant_Access_Ind__c from Pricing_Quote_Team__c where Id IN :qtmIds];
        
        List<SBQQ__Quote__share> quoteSharesToBeDeleted = new List<SBQQ__Quote__share>(); 
        List<Pricing_Comments__Share> commentsSharesToBeDeleted = new List<Pricing_Comments__Share>();   // vru               
        for(Pricing_Quote_Team__c qtm : quoteTeamLst){
            //to check weather the removing user is a sales rep or owner
            if(qtm.Pricing_Quote_Team_Member_Id__c != qtm.Pricing_Quote_Id__r.SBQQ__SalesRep__c && qtm.Pricing_Quote_Team_Member_Id__c != qtm.Pricing_Quote_Id__r.OwnerId && qtm.Pricing_Role_Nm__c!=Label.Pricing_Quote_Team_Role_FSE){ //
                if(quoteIdUserIdMap.containsKey(qtm.Pricing_Quote_Id__c)){
                    quoteIdUserIdMap.get(qtm.Pricing_Quote_Id__c).add(qtm.Pricing_Quote_Team_Member_Id__c);
                }else{
                    quoteIdUserIdMap.put(qtm.Pricing_Quote_Id__c, new List<Id>{qtm.Pricing_Quote_Team_Member_Id__c});
                }               
            }  
            //system.debug('quoteIdUserIdMap==>'+quoteIdUserIdMap);
            if(qtm.Pricing_Role_Nm__c == Label.Pricing_Quote_Team_Role_Account_Executive){
                aeDeletedQuotes.add(qtm.Pricing_Quote_Id__c);
                if(qtm.Pricing_Quote_Team_Member_Id__r.Email.equalsIgnoreCase(qtm.Pricing_Quote_Id__r.Pricing_Intel_Account_Exec_Email_Txt__c) || qtm.Pricing_Quote_Id__r.Pricing_Intel_Account_Exec_Email_Txt__c == null){
                    quoteIdsTobeUpdated.add(qtm.Pricing_Quote_Id__c);
                }
            } 
            if(qtm.Pricing_Role_Nm__c == Label.Pricing_Quote_Team_Role_FSE){
                fseDeletedQuotes.add(qtm.Pricing_Quote_Id__c);
            }            
        }
        
        if(!quoteIdUserIdMap.isEmpty()){
            for(SBQQ__Quote__share quoteShare : [SELECT id,ParentId,UserOrGroupId FROM SBQQ__Quote__share WHERE ParentId IN :quoteIdUserIdMap.keySet()]){
                if(quoteIdUserIdMap.get(quoteShare.ParentId).contains(quoteShare.UserOrGroupId)){
                    quoteSharesToBeDeleted.add(quoteShare);
                }
            }
            for(Pricing_Comments__Share commentShare : [SELECT id,ParentId,UserOrGroupId,Parent.Pricing_Quote__r.Id FROM Pricing_Comments__Share WHERE Parent.Pricing_Quote__c IN :quoteIdUserIdMap.keySet()]){
                if(quoteIdUserIdMap.get(commentShare.Parent.Pricing_Quote__r.Id).contains(commentShare.UserOrGroupId)){                   
                    commentsSharesToBeDeleted.add(commentShare);
                } 
            }
            
            if(commentsSharesToBeDeleted.size() > 0){
                delete commentsSharesToBeDeleted;
            }
            if(quoteSharesToBeDeleted.size() > 0){
                delete quoteSharesToBeDeleted;
            }
        }
        //Update Quote primary AE on removal from Quote Team
        if(quoteIds.size() > 0){
            
            Map<Id,SBQQ__Quote__c> quotesTobeUpdtaed = new Map<Id,SBQQ__Quote__c>();
            List<SBQQ__Quote__c> quotes = [SELECT id,Pricing_Account_Executive_Nm__c,Pricing_Intel_Account_Exec_Email_Txt__c,
                                           (SELECT Id,Pricing_Quote_Team_Member_Id__c,Pricing_Quote_Team_Member_Id__r.Email FROM Quote_Teams__r WHERE Pricing_Role_Nm__c =:Label.Pricing_Quote_Team_Role_Account_Executive AND (NOT Id IN :qtmIds) ORDER BY Pricing_Grant_Access_Ind__c  DESC LIMIT 1) FROM SBQQ__Quote__c WHERE Id IN :quoteIds];
            
        
            if(quotes.size() > 0){
                for(SBQQ__Quote__c quote: quotes){    
                    if(aeDeletedQuotes.contains(quote.Id)){
                        quotesTobeUpdtaed.put(quote.Id,new SBQQ__Quote__c(Id = quote.Id,Pricing_Account_Executive_Nm__c = ((quote.Quote_Teams__r.size() > 0 && quoteIdsTobeUpdated.contains(quote.Id))? quote.Quote_Teams__r[0].Pricing_Quote_Team_Member_Id__c : (aeDeletedQuotes.contains(quote.Id) && quote.Quote_Teams__r.size() == 0) ? null:quote.Pricing_Account_Executive_Nm__c),
                                                                          Pricing_Intel_Account_Exec_Email_Txt__c = ((quote.Quote_Teams__r.size() > 0 && quoteIdsTobeUpdated.contains(quote.Id))? quote.Quote_Teams__r[0].Pricing_Quote_Team_Member_Id__r.Email : (aeDeletedQuotes.contains(quote.Id) && quote.Quote_Teams__r.size() == 0 ? null:quote.Pricing_Intel_Account_Exec_Email_Txt__c) )));
                        
                    }   
                }
                
            }
            //To update Quote Sales rep on FSE Quote Team deletion
            if(!fseDeletedQuotes.isEmpty()){
                //List of Quotes along with FSE QTMs where FSE has to be updated
                List<SBQQ__Quote__c> quotesToUpdateForFSE = [SELECT id,SBQQ__SalesRep__c,Pricing_Intel_Sales_Rep_Email_Txt__c,
                                                             (SELECT Id,Pricing_Quote_Id__c,Pricing_Quote_Id__r.SBQQ__Account__c,Pricing_Quote_Team_Member_Id__c,Pricing_Quote_Team_Member_Id__r.Email
                                                              FROM Quote_Teams__r WHERE Pricing_Role_Nm__c =:Label.Pricing_Quote_Team_Role_FSE AND (NOT Id IN :qtmIds)) FROM SBQQ__Quote__c WHERE Id IN :fseDeletedQuotes];   
                List<Pricing_Quote_Team__c> fseQTMList = new List<Pricing_Quote_Team__c>();
                
                Set<Id> fseQTMUserIdSet = new Set<Id>();
                Set<Id> fseUserWithPSSet = new Set<Id>();
                Set<Id> accountIds = new Set<Id>();
                Set<Id> quoteIdsWithFSESet = new Set<Id>();
                Map<Id,Set<Id>> accountIdFSEUserIdMap = new Map<Id,Set<Id>>();
                for(SBQQ__Quote__c quote:quotesToUpdateForFSE){
                    for(Pricing_Quote_Team__c fseQTM : quote.Quote_Teams__r){
                        fseQTMList.addAll(quote.Quote_Teams__r);
                        fseQTMUserIdSet.add(fseQTM.Pricing_Quote_Team_Member_Id__c);
                        accountIds.add(fseQTM.Pricing_Quote_Id__r.SBQQ__Account__c);
                        quoteIdsWithFSESet.add(fseQTM.Pricing_Quote_Id__c);
                    }                  
                }
                
                if(!fseQTMUserIdSet.isEmpty()){
                    List<PermissionSetAssignment> fsePermSetDtls = new List<PermissionSetAssignment>([SELECT Assignee.Email,PermissionSet.Name,AssigneeId
                                                                                                      FROM PermissionSetAssignment 
                                                                                                      WHERE Assignee.Id IN :fseQTMUserIdSet AND Assignee.IsActive = true
                                                                                                      AND PermissionSet.Name =: Label.Pricing_Tender_PermissionSets_TenderUser]);
                    for(PermissionSetAssignment psa:fsePermSetDtls){
                        fseUserWithPSSet.add(psa.Assignee.Id); //Set with FSE QTMs having FSE PS
                    }
                }
                if(!accountIds.isEmpty()){
                    for(AccountTeamMember accTeam : [SELECT Id,User.Email,UserId,AccountId FROM AccountTeamMember WHERE AccountId IN:accountIds]){
                        if(accountIdFSEUserIdMap.containsKey(accTeam.AccountId)){
                            accountIdFSEUserIdMap.get(accTeam.AccountId).add(accTeam.UserId);  //Map of Account IDs and set of the Account Team member user IDs
                        }else{
                            accountIdFSEUserIdMap.put(accTeam.AccountId,new Set<Id>{accTeam.UserId} );
                        }
                    }
                }
                Map<Id,String> quoteIdFSEEmailNewMap = new Map<Id,String>();
                if(!fseQTMList.isEmpty()){
                    for(Pricing_Quote_Team__c fseQTM:fseQTMList){
                        if(fseUserWithPSSet.contains(fseQTM.Pricing_Quote_Team_Member_Id__c) && accountIdFSEUserIdMap.containsKey(fseQTM.Pricing_Quote_Id__r.SBQQ__Account__c) && 
                           accountIdFSEUserIdMap.get(fseQTM.Pricing_Quote_Id__r.SBQQ__Account__c).contains(fseQTM.Pricing_Quote_Team_Member_Id__c)){
                               quoteIdFSEEmailNewMap.put(fseQTM.Pricing_Quote_Id__c, fseQTM.Pricing_Quote_Team_Member_Id__r.Email); //Map of QuoteId and valid FSE email to be updated on Quote
                           }
                    }
                }
                
                for(SBQQ__Quote__c quote: quotesToUpdateForFSE){
                    if(fseDeletedQuotes.contains(quote.id)){
                        if(quotesTobeUpdtaed.containsKey(quote.id)){
                            quotesTobeUpdtaed.get(quote.id).Pricing_Intel_Sales_Rep_Email_Txt__c=quoteIdsWithFSESet.contains(quote.id)?quoteIdFSEEmailNewMap.get(quote.Id):null; //If quote is already present for AE updation
                        }else{
                            quotesTobeUpdtaed.put(quote.id,(new SBQQ__Quote__c(Id = quote.Id,Pricing_Intel_Sales_Rep_Email_Txt__c = quoteIdsWithFSESet.contains(quote.id)?quoteIdFSEEmailNewMap.get(quote.Id):null )));        
                        }
                    }    
                }       
            } 
            
            if(quotesTobeUpdtaed.size() > 0){ 
                QuoteBusinessLogic.isQTMChanged = false; //Flag to avoid recursion of removal/update of AE and FSE from Quote
                update quotesTobeUpdtaed.values();
            }
        }       
    } 
    
    private static Map<String,Pricing_Quote_Team_Role_Access_Mapping__mdt> getRolesMappingMdt(){  
        
        Map<String,Pricing_Quote_Team_Role_Access_Mapping__mdt> rolesMap = new Map<String,Pricing_Quote_Team_Role_Access_Mapping__mdt>();
        for(Pricing_Quote_Team_Role_Access_Mapping__mdt mdt : [SELECT Pricing_Role_Nm__c,Pricing_Access_Level_Nm__c,Permission_Set_API_Nm__c
                                                               FROM Pricing_Quote_Team_Role_Access_Mapping__mdt WHERE Pricing_IsActive_Ind__c=True]){
                                                                   rolesMap.put(mdt.Pricing_Role_Nm__c, mdt);
                                                               }
        return rolesMap;
    }    
    
    public static void sendEmailNotification(List<Pricing_Quote_Team__c> quoteTeam){
        if(quoteTeam.size() > 0){   
            Set<Id> qtmIds = new Set<Id>();
            for(Pricing_Quote_Team__c qtm : quoteTeam){
                qtmIds.add(qtm.Id);
            }
            if(qtmIds.size()>0){
                Pricing_EmailUtility.sendEmail(qtmIds,Label.Pricing_QuoteTeam_EmailNotification_Template,true);
            }     
        }
    }
    
    public static void quoteLineResubmission(List<Pricing_Quote_Team__c> quoteTeam){
        hasQuoteLineResubmission = true;
        Set<Id> quoteIds = new Set<Id>();      
        set<Id> quoteLineId = new set<ID>();          
        
        List<ProcessInstanceWorkitem> processInsWork = new List<ProcessInstanceWorkitem>();
        if(quoteTeam.size() > 0){           
            for(Pricing_Quote_Team__c qtm : quoteTeam){
                quoteIds.add(qtm.Pricing_Quote_Id__c);
            }
        }
        if(quoteIds.size() > 0){
            
            for(SBQQ__QuoteLine__c quoteLine : [SELECT Id From SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN : quoteIds and Pricing_Status_Nm__c =: Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview]) {
                if(quoteLine != null) { 
                    quoteLineId.add(quoteLine.id);
                }
            }
            if (quoteLineId.size() > 0){
                Pricing_Publish_Quote.approveOrRejectQLI(quoteLineId, Label.Pricing_Tender_QuoteLine_Action_Reject, Label.Pricing_Tender_QuoteLine_Action_Reject);
                if(!System.isBatch() && !System.isFuture()){
                    Pricing_Publish_Quote.publishQuoteLinesToMultipleFSEFuture(quoteLineId);
                }
                else{
                    Pricing_Publish_Quote.publishQuoteLinesToMultipleFSE(quoteLineId);
                }
            }
            hasQuoteLineResubmission = false;        
        }
    }

    public static void getQuoteSharesMap(Set<Id> quoteIds,Map<Id,List<SBQQ__Quote__share>> quoteIdShareMap){
        for(SBQQ__Quote__share quoteShare : [SELECT id,ParentId,UserOrGroupId,AccessLevel FROM SBQQ__Quote__share WHERE ParentId IN :quoteIds]){
            if(quoteIdShareMap.containsKey(quoteShare.parentId)){
                quoteIdShareMap.get(quoteShare.parentId).add(quoteShare);
            }else{
                quoteIdShareMap.put(quoteShare.parentId, new List<SBQQ__Quote__share>{quoteShare}); 
            }
        }
    }

    public static void getUserPSMap(Set<Id> userIds,Map<Id,List<String>> userPermSetAssignmentMap){
        for(PermissionSetAssignment psa :[SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE AssigneeId IN :userIds]){
            if(userPermSetAssignmentMap.containsKey(psa.AssigneeId)){
                userPermSetAssignmentMap.get(psa.AssigneeId).add(psa.PermissionSet.Name);
            }else{
                userPermSetAssignmentMap.put(psa.AssigneeId, new List<String>{psa.PermissionSet.Name});
            }
        } 
    }
}