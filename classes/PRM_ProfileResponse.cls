/**********************************************************************************************************************
Class Name    : PRM_ProfileResponse
Version       : 1.0
Created Date  : June 2019
Function      : Inserting profile response and registration profile response from 'PRM_Profile_Response__c' field of PRM_Registration_Request__c object

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------
* Rahul Kainth              11 June,2019            Inserting profile response and registration profile response from 
Harshit                      'PRM_Profile_Response__c' field of PRM_Registration_Request__c object

***********************************************************************************************************************/
public without sharing class PRM_ProfileResponse {
    public static  boolean firstRunAfterUpdate = true;
    public static String logEntryMsg='';
    public static boolean pointsRun = true;
   public static List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
   public static set<Id> contactIdsForCompPCR=new set<Id>();
   public static boolean fromPointsCalculation = false;
   public static boolean fromOPID = true;
   public static boolean activateInactivateBenefitExecuted = False;
   public static Set<String> opidtoLocRDMap = new Set<String>();
    
    /*
* @description      : Creation of profile response by comparing 'PRM_Profile_Response__c' field's value with profile question 
and profile answer table
* @name             : createResponse
* @param            : List<PRM_Registration_Request__c> regRequest - Getting registration request from PRM_CreateAccountAndRelatedRecords class
* @param            : List<Account> accList - Getting inserted account list from PRM_CreateAccountAndRelatedRecords class
* @param            : List<Contact> contList - Getting inserted contact list from PRM_CreateAccountAndRelatedRecords class
* @param      : Boolean flag - true if registration profile response is getting created
false - if profile response is getting created
* @throws exception : NONE
*/
    public static void createResponse(List<PRM_Registration_Request__c> regRequest,List<Account> accList,List<Contact> contList,Boolean flag){
        Map<String,PRM_Profile_Questions__c> profQuesMap = new Map<String,PRM_Profile_Questions__c>();
        Map<String,PRM_Profile_Answer__c> profAnsMap = new Map<String,PRM_Profile_Answer__c>();
        //Set<String> ss = new Set<String>();
        Map<String,PRM_Profile_Responses__c> existingPRMap = new Map<String,PRM_Profile_Responses__c>();
        //check for duplicates
        if(accList != null && accList.size()>0)
        {
            for(PRM_Profile_Responses__c pr : [Select id,PRM_Account_Id__c,PRM_Profile_Questions_Id__c,PRM_Profile_Answer_Id__c,PRM_Contact_Id__c from PRM_Profile_Responses__c where PRM_Account_Id__c =: accList[0].Id])
            {
                existingPRMap.put(String.valueOf(pr.PRM_Account_Id__c)+String.valueOf(pr.PRM_Profile_Questions_Id__c)+String.valueOf(pr.PRM_Profile_Answer_Id__c),pr);
            }
        }
        List<PRM_Profile_Responses__c> profResponseList = new List<PRM_Profile_Responses__c>();
        List<PRM_Registration_Profile_Response__c> listOfRegResponse = new List<PRM_Registration_Profile_Response__c>();
        for(PRM_Profile_Questions__c profQues : [Select Id,PRM_Question_Cd__c,PRM_Question_Type_Nm__c from PRM_Profile_Questions__c]){
            profQuesMap.put(profQues.PRM_Question_Cd__c,profQues);
        }
        for(PRM_Profile_Answer__c profAns : [Select Id,PRM_Answer_Cd__c,PRM_Answer_Display_Txt__c from PRM_Profile_Answer__c]){
            profAnsMap.put(profAns.PRM_Answer_Cd__c,profAns);
        }
        for(PRM_Registration_Request__c rr : regRequest){
            if(rr.PRM_Profile_Response__c != null && rr.PRM_Profile_Response__c!= ''){
                for(String s : rr.PRM_Profile_Response__c.split('}')){
                    Id questionId;
                    Id answerId;
                    String questionCode = s.substringAfter(Label.PRM_QuestionCode+' ').substringBefore(' '+Label.PRM_ResponseCode);
                    String answerCode =  s.substringAfter(Label.PRM_ResponseCode+' ').substringBefore(' '+Label.PRM_ResponseValue);
                    String responseValue = s.substringAfter(Label.PRM_ResponseValue+' ').substringBefore('}');
                    if(profQuesMap.containsKey(questionCode)){
                        questionId = profQuesMap.get(questionCode).Id;
                    }
                    if(profAnsMap.containsKey(answerCode)){
                        answerId = profAnsMap.get(answerCode).Id;
                    }
                    
                    //to create registration profile response 
                    if(flag){
                        PRM_Registration_Profile_Response__c registrationResponse = new PRM_Registration_Profile_Response__c();
                        if(questionId != null){
                            registrationResponse.PRM_Profile_Question_Id__c = questionId;
                        }
                        if(answerId != null){
                            registrationResponse.PRM_Profile_Answer_Id__c = answerId;
                        }
                        if(rr.Id != null){
                            registrationResponse.PRM_Registration_Request_Id__c = rr.Id;
                        }
                        
                        registrationResponse.PRM_Response_Txt__c = responseValue;
                        listOfRegResponse.add(registrationResponse);
                    }
                    
                    //to create profile response
                    else{
                        PRM_Profile_Responses__c profResponse = new PRM_Profile_Responses__c();
                        if(questionId != null){
                            profResponse.PRM_Profile_Questions_Id__c = questionId;
                        }
                        if(answerId != null){
                            profResponse.PRM_Profile_Answer_Id__c = answerId;
                        }
                        
                        //profResponse.PRM_Response_Txt__c = responseValue;
                        if(contList.size() > 0){
                            profResponse.PRM_Contact_Id__c = contList[0].Id;
                        }
                        if(accList.size() > 0){
                            profResponse.PRM_Account_Id__c = accList[0].Id;
                            if(existingPRMap != null && existingPRMap.get(String.valueOf(profResponse.PRM_Account_Id__c)+String.valueOf(profResponse.PRM_Profile_Questions_Id__c)+String.valueOf(profResponse.PRM_Profile_Answer_Id__c)) != null){
                                profResponse = existingPRMap.get(String.valueOf(profResponse.PRM_Account_Id__c)+String.valueOf(profResponse.PRM_Profile_Questions_Id__c)+String.valueOf(profResponse.PRM_Profile_Answer_Id__c)) ;
                            } 
                            if(profQuesMap.keySet().contains(questionCode) && profQuesMap.get(questionCode).PRM_Question_Type_Nm__c != Label.PRM_TextArea){
                                if(profAnsMap.keySet().contains(answerCode)){
                                    profResponse.PRM_Response_Txt__c = profAnsMap.get(answerCode).PRM_Answer_Display_Txt__c;
                                }
                            }
                            else {
                                profResponse.PRM_Response_Txt__c = responseValue;
                            }
                            profResponse.PRM_InActive_Ind__c = false;
                            profResponseList.add(profResponse);
                        }
                    }
                }
            }
        }
        if(profResponseList != null && profResponseList.size()>0){
            upsert profResponseList;
        }
        if(listOfRegResponse != null && listOfRegResponse.size()>0){
            insert listOfRegResponse;
        }
    }
 //consumes 4 soqa 1-account, 1-ABA,1-profile Questions, 1-bnft mat, 1-acm
   /* public static void inactiveBenefit(List<PRM_Profile_Responses__c> newProfileReponse, Map<id, PRM_Profile_Responses__c>oldMap){
        try{
            if(!fromPointsCalculation && fromOPID){
            System.debug('No of SOQL Executed till at Start of inactiveBenefit-->'+Limits.getQueries());
            System.debug('called for accounts'+newProfileReponse);
            List<String> questionCodes = label.PRM_Question_code.split(';');  // not eligible      
            set<Id> accountids = new Set<id>(); // to be used as aggregate ids of both acts and opids        
            Map<Id,Id> mapOfActIdOPID = new Map<id,id>();
            
            //get all the benefit matrix records with respect to Points Redeedm Benefit
            set<String> bnftmatset = new set<String>();           
            set<Id> pointsNotEligibleIds = new set<id>();
            for(PRM_Profile_Questions__c pq: [select id from PRM_Profile_Questions__c where PRM_Question_Cd__c in :questionCodes]){
                pointsNotEligibleIds.add(pq.Id);
            }
            System.debug('pointsNotEligibleIds -->'+pointsNotEligibleIds);
            
            //there can be multiple account with same profile response
            for(PRM_Profile_Responses__c pr : newProfileReponse){
                System.debug('newProfileReponse -->'+pr);
                if(((pr.PRM_Response_Txt__c=='true') || (pr.PRM_Response_Txt__c!='' && pr.PRM_Response_Txt__c!='false')) && pointsNotEligibleIds.contains(pr.PRM_Profile_Questions_Id__c)){
                    accountids.add(pr.PRM_Account_Id__c);     
                }
            }
            
            System.debug('accountids -->'+accountids);
            if(accountids.size()>0){
               for(PRM_VXBnftMatrix__c bnftrec : [select PRM_Partner_Role_Nm__c from PRM_VXBnftMatrix__c where PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c='BFTPTSREDM']){
                    bnftmatset.add(bnftrec.PRM_Partner_Role_Nm__c);
                }
                
            System.debug('bnftmatset -->'+bnftmatset);
            if(accountids!=null && !accountids.isEmpty()){
                for(Account actRec: [select id, Core_IPA_One_Partner_Id__c from Account where id in : accountids]){   //QUERY -1 - Account         
                    mapOfActIdOPID.put(actRec.Id,actRec.Core_IPA_One_Partner_Id__c);
                }    
            }
            
            System.debug('mapOfActIdOPID ->'+mapOfActIdOPID);
            // get all the opid ACM's
            
            Map<Id,List<PRM_AccountChannelMembership__c>> opidAcmsListMap = new Map<id, List<PRM_AccountChannelMembership__c>>();        
            Map<id,Map<Id,PRM_AccountChannelMembership__c>> opidChildActIdACMMap = new Map<id,Map<Id,PRM_AccountChannelMembership__c>>();
            
            if(mapOfActIdOPID != null && !mapOfActIdOPID.IsEmpty()){
                for(PRM_AccountChannelMembership__c acmrecord : [select PRM_Channel_Program_Level_Id__r.name,PRM_Partner_Role__c, PRM_Status_Nm__c, PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_One_Partner_Id__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c in :mapOfActIdOPID.values() and PRM_Status_Nm__c='Approved' and PRM_Account_Id__r.RecordType.DeveloperName ='Core_Partner_Account_Group']){
                    if(acmrecord.PRM_Channel_Program_Level_Id__r.name!='member' && bnftmatset.contains(acmrecord.PRM_Partner_Role__c)){
                        
                        // one partner ids and child acmrecords
                        if(opidChildActIdACMMap.containsKey(acmrecord.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c)){
                            Map<Id,PRM_AccountChannelMembership__c> acmMp = opidChildActIdACMMap.get(acmrecord.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c);
                            acmMp.put(acmrecord.PRM_Account_Id__c,acmrecord);
                            opidChildActIdACMMap.put(acmrecord.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c, acmMp);
                        }else{
                            opidChildActIdACMMap.put(acmrecord.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c, new Map<Id,PRM_AccountChannelMembership__c>{acmrecord.PRM_Account_Id__c=>acmrecord});
                        }
                        
                        //account ids and their acm records
                        if(opidAcmsListMap!=null && !opidAcmsListMap.isEmpty() && opidAcmsListMap.containsKey(acmrecord.PRM_Account_Id__c)){
                            List<PRM_AccountChannelMembership__c> acmList = opidAcmsListMap.get(acmrecord.PRM_Account_Id__c);
                            acmList.add(acmrecord);
                            opidAcmsListMap.put(acmrecord.PRM_Account_Id__c, acmList);
                        }else{
                            opidAcmsListMap.put(acmrecord.PRM_Account_Id__c, new List<PRM_AccountChannelMembership__c>{acmrecord});
                        }
                    }else{
                        accountids.add(acmrecord.PRM_Account_Id__c);
                    }
                    
                }
                
                System.debug('opidAcmsListMap -->'+opidAcmsListMap);
            }
            // set with all one partner id and account id
            if( mapOfActIdOPID != null && !mapOfActIdOPID.isEmpty() && opidAcmsListMap != null && !opidAcmsListMap.isEmpty() ) {
                System.debug('opidAcmsListMap -->'+ opidAcmsListMap);
                system.debug('opidChildActIdACMMap'+opidChildActIdACMMap);
                for(Id actId :opidAcmsListMap.keySet()){
                    system.debug('The actId is '+actId);
                    if(!(opidAcmsListMap.get(actId).size()>1) && !(opidChildActIdACMMap.get(actId).size()>1 )){
                        accountids.add(actId);                        
                    }
                }
                //accountids.addAll(mapOfActIdOPID.values());    
            }        
            System.debug('accountids -->'+accountids);
            
            Map<Id,List<PRM_AccountBenefitAssociation__c>> actABAtobeUpdated = new Map<Id,List<PRM_AccountBenefitAssociation__c>>();
            
            List<PRM_AccountBenefitAssociation__c> toBeUpdatedABA = new list<PRM_AccountBenefitAssociation__c>();
            
            // get all the account benefit association records for the account ids
            set<Id> updatedBenefitIds = new set<Id>();
            
            if(accountids!=null && !accountids.isEmpty()){
                for(PRM_AccountBenefitAssociation__c aba : [select id,PRM_Status_Nm__c,PRM_Account_Id__c,PRM_Partner_Benefit_Id__r.name from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c in:accountids AND PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c in :System.Label.PRM_benefits_for_point_not_eligible_flag.split(';') and PRM_Status_Nm__c='Active']){//QUERY 3 - ABA
                    aba.PRM_Status_Nm__c = System.label.PRM_Status_Inactive;
                    aba.PRM_Status_Reason_Txt__c =System.label.PRM_Points_Not_eligible_Flag_checked;
                    
                    if(actABAtobeUpdated.containsKey(aba.PRM_Account_Id__c)){
                        List<PRM_AccountBenefitAssociation__c> abaList  =actABAtobeUpdated.get(aba.PRM_Account_Id__c);
                        abaList.add(aba);
                        actABAtobeUpdated.put(aba.PRM_Account_Id__c,abaList);
                    }else{
                        actABAtobeUpdated.put(aba.PRM_Account_Id__c, new List<PRM_AccountBenefitAssociation__c>{aba});
                    }                       
                }            
                
                if(actABAtobeUpdated!=null && !actABAtobeUpdated.isEmpty()){
                    for(Id id : actABAtobeUpdated.keySet()){
                        toBeUpdatedABA.addAll(actABAtobeUpdated.get(id));
                    }
                }
                
                System.debug('toBeUpdatedABA -->'+toBeUpdatedABA);
                
                if(toBeUpdatedABA!=null && !toBeUpdatedABA.isEmpty()){
                    Database.update(toBeUpdatedABA);
                }
                system.debug('Inactivdatebenefit accountids-->'+accountids);
               contactIdsForCompPCR=getContactsOfCompStatusPCR(accountids);
                system.debug('contactIdsForCompPCR--->'+contactIdsForCompPCR);
               
                for(Core_Contact_Entitlement__c ce : [select id,Core_Contact_Id__r.AccountId from Core_Contact_Entitlement__c where Core_Contact_Id__c in: contactIdsForCompPCR and Core_Selected__c=TRUE and Core_Status__c='Complete' and Core_Contact_Id__r.AccountId in :actABAtobeUpdated.keySet() and Core_Entitlement_Id__r.name in :Label.PRM_EntitlementNamesToInactive.split(';') ]){
                    ce.Core_Selected__c = false;
                    ce.Core_Status__c ='Pending';
                    ce.Core_Data_Loaded__c=true;
                    ceList.add(ce);
                }
                
                if(ceList!=null && !ceList.isEmpty()){
                    system.debug('ceList-->'+ceList);
                    Database.update(ceList);
                }
                
          }  
        }  
            System.debug('No of SOQL Executed at End of inactiveBenefit -->'+Limits.getQueries());        
     }
    }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
    public static void activateBenefit(List<PRM_Profile_Responses__c> newProfileReponse, Map<id, PRM_Profile_Responses__c>oldMap){
        try{
            if(!fromPointsCalculation && fromOPID){
            System.debug('No of SOQL Executed till at Start of inactiveBenefit-->'+Limits.getQueries());
            
            List<String> questionCodes = label.PRM_Question_code.split(';');  // not eligible
            List<String> questionCodesOptIn = label.PRM_Question_Code_OptIn.split(';');  // Opt In   
            set<Id> accountids = new Set<id>(); // to be used as aggregate ids of both acts and opids        
            Map<Id,Id> mapOfActIdOPID = new Map<id,id>();
            Boolean PointNotEligInd ; //indicator for pointsnoteligible
            Boolean PointOptIn ; //indicator for pointsoptin
            
            //get all the benefit matrix records with respect to Points Redeedm Benefit
            set<String> bnftmatset = new set<String>();
            List<String> OptinAndNotEligPoints = new List<String>(); 
            Set<Id> FinalId = new Set<Id>();
            
            OptinAndNotEligPoints.addAll(questionCodes) ; 
            OptinAndNotEligPoints.addAll(questionCodesOptIn) ;  
            
            system.debug('The combined list is '+OptinAndNotEligPoints);          
            
            set<Id> pointsNotEligibleIds = new set<id>();
            set<Id> pointsOptInIds = new set<id>();    
            
            for(PRM_Profile_Questions__c pq: [select id,PRM_Question_Cd__c from PRM_Profile_Questions__c where PRM_Question_Cd__c in :OptinAndNotEligPoints]){
                if(questionCodes.contains(pq.PRM_Question_Cd__c)){
                    pointsNotEligibleIds.add(pq.Id);                
                }
                if(questionCodesOptIn.contains(pq.PRM_Question_Cd__c)){
                    pointsOptInIds.add(pq.Id);                
                }                       
            }           
            System.debug('pointsNotEligibleIds -->'+pointsNotEligibleIds);
            System.debug('pointsOptInIds -->'+pointsOptInIds);
            //there can be multiple account with same profile response
            for(PRM_Profile_Responses__c pr : newProfileReponse){
                System.debug('newProfileReponse -->'+pr);
                PRM_Profile_Responses__c PROld ;
                
                if(pr.PRM_Question_Display_Text__c  == 'Points Not eligible' && (pr.PRM_Response_Txt__c == 'false' || pr.PRM_Response_Txt__c=='null')){
                    PointNotEligInd = false;
                    FinalId.add(pr.PRM_Account_Id__c);
                }
                System.debug('newProfileReponse11 -->'+pr.PRM_Question_Display_Text__c+''+pr.PRM_Response_Txt__c);
                if(pr.PRM_Question_Display_Text__c  == 'Points Opt-in' && pr.PRM_Response_Txt__c!='false' ){
                    PointOptIn = true;    
                    FinalId.add(pr.PRM_Account_Id__c);
                }
                
            }
            System.debug('val'+PointOptIn);
            if((PointNotEligInd == false && PointOptIn == true) || PointNotEligInd == false) {
                accountids.addall(FinalId);  
            }
            System.debug('accountids -->'+accountids);
            if(accountids.size()>0){     
             for(PRM_VXBnftMatrix__c bnftrec : [select PRM_Partner_Role_Nm__c from PRM_VXBnftMatrix__c where PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c='BFTPTSREDM']){
                bnftmatset.add(bnftrec.PRM_Partner_Role_Nm__c);
            }
            
            System.debug('bnftmatset -->'+bnftmatset);
            if(accountids!=null && !accountids.isEmpty()){
                for(Account actRec: [select id, Core_IPA_One_Partner_Id__c from Account where id in : accountids]){   //QUERY -1 - Account         
                    mapOfActIdOPID.put(actRec.Id,actRec.Core_IPA_One_Partner_Id__c);
                }    
            }
            
            System.debug('mapOfActIdOPID ->'+mapOfActIdOPID);
            // get all the opid ACM's
            
            Map<Id,List<PRM_AccountChannelMembership__c>> opidAcmsListMap = new Map<id, List<PRM_AccountChannelMembership__c>>();        
            Map<id,Map<Id,PRM_AccountChannelMembership__c>> opidChildActIdACMMap = new Map<id,Map<Id,PRM_AccountChannelMembership__c>>();
            
            if(mapOfActIdOPID != null && !mapOfActIdOPID.IsEmpty()){
                for(PRM_AccountChannelMembership__c acmrecord : [select PRM_Channel_Program_Level_Id__r.name,PRM_Partner_Role__c, PRM_Status_Nm__c, PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_One_Partner_Id__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c in :mapOfActIdOPID.values() and PRM_Status_Nm__c='Approved' and PRM_Account_Id__r.RecordType.DeveloperName ='Core_Partner_Account_Group']){
                    if(acmrecord.PRM_Channel_Program_Level_Id__r.name!='member' && bnftmatset.contains(acmrecord.PRM_Partner_Role__c)){
                        
                        // one partner ids and child acmrecords
                        if(opidChildActIdACMMap.containsKey(acmrecord.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c)){
                            Map<Id,PRM_AccountChannelMembership__c> acmMp = opidChildActIdACMMap.get(acmrecord.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c);
                            acmMp.put(acmrecord.PRM_Account_Id__c,acmrecord);
                            opidChildActIdACMMap.put(acmrecord.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c, acmMp);
                        }else{
                            opidChildActIdACMMap.put(acmrecord.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c, new Map<Id,PRM_AccountChannelMembership__c>{acmrecord.PRM_Account_Id__c=>acmrecord});
                        }
                        
                        //account ids and their acm records
                        if(opidAcmsListMap!=null && !opidAcmsListMap.isEmpty() && opidAcmsListMap.containsKey(acmrecord.PRM_Account_Id__c)){
                            List<PRM_AccountChannelMembership__c> acmList = opidAcmsListMap.get(acmrecord.PRM_Account_Id__c);
                            acmList.add(acmrecord);
                            opidAcmsListMap.put(acmrecord.PRM_Account_Id__c, acmList);
                        }else{
                            opidAcmsListMap.put(acmrecord.PRM_Account_Id__c, new List<PRM_AccountChannelMembership__c>{acmrecord});
                        }
                    }else{
                        accountids.add(acmrecord.PRM_Account_Id__c);
                    }
                    
                }
                
                System.debug('opidAcmsListMap -->'+opidAcmsListMap);
            }
            // set with all one partner id and account id
            if( mapOfActIdOPID != null && !mapOfActIdOPID.isEmpty() && opidAcmsListMap != null && !opidAcmsListMap.isEmpty() ) {
                System.debug('opidAcmsListMap -->'+ opidAcmsListMap);
                for(Id actId :opidAcmsListMap.keySet()){
                    if(!(opidAcmsListMap.get(actId).size()>1) && !(opidChildActIdACMMap.get(actId).size()>1 )){
                        accountids.add(actId);                        
                    }
                }
                //accountids.addAll(mapOfActIdOPID.values());    
            }        
            System.debug('accountids -->'+accountids);
            
            Map<Id,List<PRM_AccountBenefitAssociation__c>> actABAtobeUpdated = new Map<Id,List<PRM_AccountBenefitAssociation__c>>();
            
            List<PRM_AccountBenefitAssociation__c> toBeUpdatedABA = new list<PRM_AccountBenefitAssociation__c>();
            
            // get all the account benefit association records for the account ids
            set<Id> updatedBenefitIds = new set<Id>();
            
            if(accountids!=null && !accountids.isEmpty()){
                for(PRM_AccountBenefitAssociation__c aba : [select id,PRM_Status_Nm__c,PRM_Account_Id__c,PRM_Partner_Benefit_Id__r.name from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c in:accountids AND PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c in :System.Label.PRM_benefits_for_point_not_eligible_flag.split(';') and PRM_Status_Nm__c='Inactive']){//QUERY 3 - ABA
                    aba.PRM_Status_Nm__c = 'Active';
                    aba.PRM_Status_Reason_Txt__c ='';
                    
                    if(actABAtobeUpdated.containsKey(aba.PRM_Account_Id__c)){
                        List<PRM_AccountBenefitAssociation__c> abaList  =actABAtobeUpdated.get(aba.PRM_Account_Id__c);
                        abaList.add(aba);
                        actABAtobeUpdated.put(aba.PRM_Account_Id__c,abaList);
                    }else{
                        actABAtobeUpdated.put(aba.PRM_Account_Id__c, new List<PRM_AccountBenefitAssociation__c>{aba});
                    }                       
                }            
                
                if(actABAtobeUpdated!=null && !actABAtobeUpdated.isEmpty()){
                    for(Id id : actABAtobeUpdated.keySet()){
                        toBeUpdatedABA.addAll(actABAtobeUpdated.get(id));
                    }
                }
                
                System.debug('toBeUpdatedABA -->'+toBeUpdatedABA);
                
                if(toBeUpdatedABA!=null && !toBeUpdatedABA.isEmpty()){
                    Database.update(toBeUpdatedABA);
                }
        system.debug('activdatebenefit accountids-->'+accountids);
        contactIdsForCompPCR=getContactsOfCompStatusPCR(accountids);
                system.debug('contactIdsForCompPCR--->'+contactIdsForCompPCR);
                for(Core_Contact_Entitlement__c ce : [select id,Core_Contact_Id__r.AccountId from Core_Contact_Entitlement__c where Core_Contact_Id__c in: contactIdsForCompPCR and Core_Selected__c=FALSE and Core_Status__c='Complete' and Core_Contact_Id__r.AccountId in :actABAtobeUpdated.keySet() and Core_Entitlement_Id__r.name in :Label.PRM_EntitlementNamesToInactive.split(';')  ]){                
                    ce.Core_Selected__c = true;
                    ce.Core_Status__c ='Pending';
                    ce.Core_Data_Loaded__c =true;
                    ceList.add(ce);
                }
                
                if(ceList!=null && !ceList.isEmpty()){
                    Database.update(ceList);
                }
                
            } 
        }   
            System.debug('No of SOQL Executed at End of inactiveBenefit -->'+Limits.getQueries());
       }
    }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    } */     
    
    //activateInactiveBenefit() method inactivates/activates benefits and related entitlment when Points Not eligible/Optin Flag is Checked on profile response 
    /*public static void activateInactiveBenefit(List<PRM_Profile_Responses__c> newProfileReponse, Map<id, PRM_Profile_Responses__c>oldMap){
        try{
            if(!fromPointsCalculation && fromOPID){
            System.debug('No of SOQL Executed till at Start of inactiveBenefit-->'+Limits.getQueries());
            set<id> accountId = new set<id>();
            List<String> questionCodes = label.PRM_Question_code.split(';');  // not eligible
            List<String> questionCodesOptIn = label.PRM_Question_Code_OptIn.split(';');  // Opt In   
            set<Id> accountids = new Set<id>(); // to be used as aggregate ids of both acts and opids
            System.debug('Inside Method accountids -->'+newProfileReponse);        
            Map<Id,Id> mapOfActIdOPID = new Map<id,id>();
            Map<Id,String> questionIdCodeMap = new Map<Id,String>();
            Map<String,id> questionCodeIdMap = new  Map<String,id>();    
            Boolean PointNotEligInd ; //indicator for pointsnoteligible
            Boolean PointOptIn ; //indicator for pointsoptin
            boolean inactivate = false;
            
            //get all the benefit matrix records with respect to Points Redeedm Benefit
            set<String> bnftmatset = new set<String>();
            List<String> OptinAndNotEligPoints = new List<String>(); 
            Set<Id> FinalId = new Set<Id>();
            
            OptinAndNotEligPoints.addAll(questionCodes) ; 
            OptinAndNotEligPoints.addAll(questionCodesOptIn) ;  
            
           // system.debug('The combined list is '+OptinAndNotEligPoints);
                      
            //System.debug('bnftmatset -->'+bnftmatset);
            
            set<Id> pointsNotEligibleIds = new set<id>();
            set<Id> pointsOptInIds = new set<id>();    
            
            for(PRM_Profile_Questions__c pq: [select id,PRM_Question_Cd__c from PRM_Profile_Questions__c]){
                if(questionCodes.contains(pq.PRM_Question_Cd__c)){
                    pointsNotEligibleIds.add(pq.Id);                
                }
                if(questionCodesOptIn.contains(pq.PRM_Question_Cd__c)){
                    pointsOptInIds.add(pq.Id);                
                }    
                questionCodeIdMap.put(pq.PRM_Question_Cd__c,pq.id);
                questionIdCodeMap.put(pq.id,pq.PRM_Question_Cd__c);                   
            }  
            
            //System.debug('pointsNotEligibleIds -->'+pointsNotEligibleIds);
            //System.debug('pointsOptInIds -->'+pointsOptInIds);
            //there can be multiple account with same profile response
            for(PRM_Profile_Responses__c pr : newProfileReponse){
                //System.debug('newProfileReponse -->'+pr);
                PRM_Profile_Responses__c PROld ;                
                // from Inactive
                if(((pr.PRM_Response_Txt__c=='true') || (pr.PRM_Response_Txt__c!='' && pr.PRM_Response_Txt__c!='false')) && pointsNotEligibleIds.contains(pr.PRM_Profile_Questions_Id__c)){
                    PointNotEligInd = true;
                    System.debug('Inside first If::::'+PointNotEligInd);
                    if(!accountids.contains(pr.PRM_Account_Id__c)){
                        accountids.add(pr.PRM_Account_Id__c);
                    }
                    else{
                      //  accountids.remove(pr.PRM_Account_Id__c);
                    }   
                }
                //System.debug('Inside Method after clean up accountids -->'+accountids);
                
                //Active
                if(pr.PRM_Question_Display_Text__c  == 'Points Not eligible' && (pr.PRM_Response_Txt__c == 'false' || pr.PRM_Response_Txt__c=='null')){
                    System.debug('Inside Second If::::');
                    PointNotEligInd = false;
                    FinalId.add(pr.PRM_Account_Id__c);
                    //System.debug('FinalId 1 -->'+FinalId);
                }
                
                if(pr.PRM_Question_Display_Text__c  == 'Points Opt-in' && pr.PRM_Response_Txt__c == 'true' ){
                    System.debug('Inside third If::::');
                    PointOptIn = true;    
                    FinalId.add(pr.PRM_Account_Id__c);
                    //System.debug('FinalId 2 -->'+FinalId);
                }
                if(oldMap!= null){
                    if(pr.PRM_Response_Txt__c != oldMap.get(pr.id).PRM_Response_Txt__c && (questionIdCodeMap.get(pr.PRM_Profile_Questions_Id__c) == 'PRM_Opt_In' || questionIdCodeMap.get(pr.PRM_Profile_Questions_Id__c) == 'PRM_Point_Not_Eligible'))
                        accountId.add(pr.PRM_Account_Id__c);
                    }
                    else{
                        if(questionIdCodeMap.get(pr.PRM_Profile_Questions_Id__c) == 'PRM_Opt_In' || questionIdCodeMap.get(pr.PRM_Profile_Questions_Id__c) == 'PRM_Point_Not_Eligible')
                        accountId.add(pr.PRM_Account_Id__c); 
                    }                
            }
            if(accountId.size()>0){
             //  PRM_ProfileResponse.pointsCalculation(accountId,newProfileReponse,questionIdCodeMap,questionCodeIdMap);
            }
             system.debug ('after for loop '+ accountIds);
            if(PointNotEligInd == true){
                system.debug ('PNE TRUE ');
               // accountids.addall(FinalId);  
                inactivate = true;
            }
            else if((PointNotEligInd == false && PointOptIn == true) || PointNotEligInd == false) {
                //System.debug('Inside forth If::::');
                accountids.addall(FinalId);  
            }
            
            
            //System.debug('accountids -->'+accountids);
            if(accountids.size()>0){                 
            for(PRM_VXBnftMatrix__c bnftrec : [select PRM_Partner_Role_Nm__c from PRM_VXBnftMatrix__c where PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c='BFTPTSREDM']){
                bnftmatset.add(bnftrec.PRM_Partner_Role_Nm__c);
            }
            if(accountids!=null && !accountids.isEmpty()){
                for(Account actRec: [select id, Core_IPA_One_Partner_Id__c from Account where id in : accountids]){   //QUERY -1 - Account         
                    mapOfActIdOPID.put(actRec.Id,actRec.Core_IPA_One_Partner_Id__c);
                }    
            }
            
            System.debug('mapOfActIdOPID ->'+mapOfActIdOPID);
            // get all the opid ACM's
            
            Map<Id,List<PRM_AccountChannelMembership__c>> opidAcmsListMap = new Map<id, List<PRM_AccountChannelMembership__c>>();        
            Map<id,Map<Id,PRM_AccountChannelMembership__c>> opidChildActIdACMMap = new Map<id,Map<Id,PRM_AccountChannelMembership__c>>();
            
            if(mapOfActIdOPID != null && !mapOfActIdOPID.IsEmpty()){
                for(PRM_AccountChannelMembership__c acmrecord : [select PRM_Channel_Program_Level_Id__r.name,PRM_Partner_Role__c, PRM_Status_Nm__c, PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_One_Partner_Id__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c in :mapOfActIdOPID.values() and PRM_Status_Nm__c='Approved' and PRM_Account_Id__r.RecordType.DeveloperName ='Core_Partner_Account_Group']){
                    if(acmrecord.PRM_Channel_Program_Level_Id__r.name!='member' && bnftmatset.contains(acmrecord.PRM_Partner_Role__c)){
                        
                        // one partner ids and child acmrecords
                        if(opidChildActIdACMMap.containsKey(acmrecord.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c)){
                            Map<Id,PRM_AccountChannelMembership__c> acmMp = opidChildActIdACMMap.get(acmrecord.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c);
                            acmMp.put(acmrecord.PRM_Account_Id__c,acmrecord);
                            opidChildActIdACMMap.put(acmrecord.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c, acmMp);
                        }else{
                            opidChildActIdACMMap.put(acmrecord.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c, new Map<Id,PRM_AccountChannelMembership__c>{acmrecord.PRM_Account_Id__c=>acmrecord});
                        }
                        
                        //account ids and their acm records
                        if(opidAcmsListMap!=null && !opidAcmsListMap.isEmpty() && opidAcmsListMap.containsKey(acmrecord.PRM_Account_Id__c)){
                            List<PRM_AccountChannelMembership__c> acmList = opidAcmsListMap.get(acmrecord.PRM_Account_Id__c);
                            acmList.add(acmrecord);
                            opidAcmsListMap.put(acmrecord.PRM_Account_Id__c, acmList);
                        }else{
                            opidAcmsListMap.put(acmrecord.PRM_Account_Id__c, new List<PRM_AccountChannelMembership__c>{acmrecord});
                        }
                    }else{
                        accountids.add(acmrecord.PRM_Account_Id__c);
                    }
                    
                }
                
                System.debug('opidAcmsListMap -->'+opidAcmsListMap);
               // System.debug('accountids--->'+accountids);
            }
            // set with all one partner id and account id
            if( mapOfActIdOPID != null && !mapOfActIdOPID.isEmpty() && opidAcmsListMap != null && !opidAcmsListMap.isEmpty() ) {
                System.debug('opidAcmsListMap -->'+ opidAcmsListMap);
                for(Id actId :opidAcmsListMap.keySet()){
                    if(!(opidAcmsListMap.get(actId).size()>1) && !(opidChildActIdACMMap.get(actId).size()>1 )){
                        if(!accountids.contains(actId)){
                            accountids.add(actId);
                        }
                        else{
                           // accountids.remove(actId);
                        }                       
                    }
                }
                //accountids.addAll(mapOfActIdOPID.values());    
            }        
            System.debug('accountids -->'+accountids);
            
            Map<Id,List<PRM_AccountBenefitAssociation__c>> actABAtobeUpdated = new Map<Id,List<PRM_AccountBenefitAssociation__c>>();
            
            List<PRM_AccountBenefitAssociation__c> toBeUpdatedABA = new list<PRM_AccountBenefitAssociation__c>();
            
            // get all the account benefit association records for the account ids
            set<Id> updatedBenefitIds = new set<Id>();
            
            
            if(accountids!=null && !accountids.isEmpty()){
                List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>();
                for(PRM_AccountBenefitAssociation__c aba : [select id,PRM_Status_Nm__c,PRM_Account_Id__c,PRM_Partner_Benefit_Id__r.name from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c in:accountids AND PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c in :System.Label.PRM_benefits_for_point_not_eligible_flag.split(';') ]){//QUERY 3 - ABA
                    System.debug('AccountBenefitAssociation List -->'+aba);
                    if(!inactivate)
                    {
                    if(aba.PRM_Status_Nm__c=='Inactive'){
                        aba.PRM_Status_Nm__c = System.label.PRM_Status_Active;
                        aba.PRM_Status_Reason_Txt__c ='';
                        System.debug('Line 591-->'+aba.PRM_Status_Nm__c);
                    }
                   }
                    else if(aba.PRM_Status_Nm__c=='Active'){
                        aba.PRM_Status_Nm__c = System.label.PRM_Status_Inactive;
                        aba.PRM_Status_Reason_Txt__c =System.label.PRM_Points_Not_eligible_Flag_checked;
                    }
                    
                    
                    if(actABAtobeUpdated.containsKey(aba.PRM_Account_Id__c)){
                        abaList  =actABAtobeUpdated.get(aba.PRM_Account_Id__c);
                        abaList.add(aba);
                        actABAtobeUpdated.put(aba.PRM_Account_Id__c,abaList);
                    }else{
                        actABAtobeUpdated.put(aba.PRM_Account_Id__c, new List<PRM_AccountBenefitAssociation__c>{aba});
                    }                       
                }    
                                        
                
                if(actABAtobeUpdated!=null && !actABAtobeUpdated.isEmpty()){
                    for(Id id : actABAtobeUpdated.keySet()){
                        toBeUpdatedABA.addAll(actABAtobeUpdated.get(id));
                    }
                }
                
                System.debug('toBeUpdatedABA -->'+toBeUpdatedABA);
                
                if(toBeUpdatedABA!=null && !toBeUpdatedABA.isEmpty()){
                    Database.update(toBeUpdatedABA);
                }
                
                contactIdsForCompPCR=getContactsOfCompStatusPCR(accountids);
                system.debug('contactIdsForCompPCR--->'+contactIdsForCompPCR);

                List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
                for(Core_Contact_Entitlement__c ce : [select id,Core_Status__c,Core_Data_Loaded__c,Core_Selected__c,Core_Contact_Id__r.AccountId from Core_Contact_Entitlement__c where Core_Contact_Id__c in:contactIdsForCompPCR and  Core_Contact_Id__r.AccountId in :actABAtobeUpdated.keySet() and Core_Entitlement_Id__r.name in :Label.PRM_EntitlementNamesToInactive.split(';') ]){
                    if(ce.Core_Selected__c == FALSE){//to activate points optin
                    ce.Core_Selected__c = true;
                    ce.Core_Status__c ='Pending';
                    ce.Core_Data_Loaded__c =true;
                    ceList.add(ce);
                    }
                    else if(ce.Core_Selected__c == TRUE && ce.Core_Status__c == 'Complete'){
                        ce.Core_Selected__c = false;
                        ce.Core_Status__c ='Pending';
                        ce.Core_Data_Loaded__c=true;
                        ceList.add(ce);

                    }
                }
                if(ceList!=null && !ceList.isEmpty()){
                    Database.update(ceList);
                }
                
            }    
            System.debug('No of SOQL Executed at End of inactiveBenefit -->'+Limits.getQueries());
         }
        }
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }*/
    public static void activateInactiveBenefit(List<PRM_Profile_Responses__c> newProfileReponse, Map<id, PRM_Profile_Responses__c>oldMap){
  try{
        activateInactivateBenefitExecuted = true;
        if(!fromPointsCalculation && fromOPID){
            Set<String> questionCodes = new Set<String>();
            Set<Id> pointsNotEligibleQstnCdIds = new Set<Id>();
            Set<Id> pointsOptInQstnCdIds = new Set<Id>();
            Set<Id> inactivateBenefitAccIds = new Set<Id>();
            Set<Id> activateBenefitAccIds = new Set<Id>();
            Map<Id, Id> mapOfOpidAccIdLocId = new Map<Id, Id>();
            Set<id> contactIdsForCompPCR = new Set<Id>();
            Set<Id> accountids = new Set<Id>();
     
            
            questionCodes.addAll(label.PRM_Question_code.split(';'));
            questionCodes.addAll(label.PRM_Question_Code_OptIn.split(';'));
            
            for(PRM_Profile_Questions__c pq: [select id,PRM_Question_Cd__c from PRM_Profile_Questions__c where PRM_Question_Cd__c IN: questionCodes]){
                if(label.PRM_Question_code.contains(pq.PRM_Question_Cd__c)){
                    pointsNotEligibleQstnCdIds.add(pq.Id);                
                }
                if(label.PRM_Question_Code_OptIn.contains(pq.PRM_Question_Cd__c)){
                    pointsOptInQstnCdIds.add(pq.Id);                
      }              
    }  

    for(PRM_Profile_Responses__c profResp :newProfileReponse){
           
      if(pointsNotEligibleQstnCdIds.contains(profResp.PRM_Profile_Questions_Id__c) 
               && String.isNotBlank(profResp.PRM_Response_Txt__c) 
               && profResp.PRM_Response_Txt__c != 'false' 
               && (oldMap == null || oldMap.get(profResp.id).PRM_Response_Txt__c == 'false' || oldMap.get(profResp.id).PRM_Response_Txt__c == null)){
        inactivateBenefitAccIds.add(profResp.PRM_Account_Id__c);
        activateBenefitAccIds.remove(profResp.PRM_Account_Id__c);
      }
            
            else if(pointsNotEligibleQstnCdIds.contains(profResp.PRM_Profile_Questions_Id__c) 
                    && String.isNotBlank(profResp.PRM_Response_Txt__c)
                            && (oldMap == null || (oldMap.get(profResp.id).PRM_Response_Txt__c != 'false' &&  oldMap.get(profResp.id).PRM_Response_Txt__c != profResp.PRM_Response_Txt__c ) || oldMap.get(profResp.id).PRM_Response_Txt__c == null)){
               activateBenefitAccIds.add(profResp.PRM_Account_Id__c);
            }
            else if(pointsOptInQstnCdIds.contains(profResp.PRM_Profile_Questions_Id__c) && String.isNotBlank(profResp.PRM_Response_Txt__c) 
                    && profResp.PRM_Response_Txt__c != 'false' 
                            && (oldMap == null || (oldMap.get(profResp.id).PRM_Response_Txt__c == 'false' &&  oldMap.get(profResp.id).PRM_Response_Txt__c != profResp.PRM_Response_Txt__c ) || oldMap.get(profResp.id).PRM_Response_Txt__c == null)
                    ){
        activateBenefitAccIds.add(profResp.PRM_Account_Id__c);
      }            
    }
    if(!activateBenefitAccIds.IsEmpty() || !inactivateBenefitAccIds.IsEmpty()){          
      for(Account actRec: [select id, Core_IPA_One_Partner_Id__c from Account where id in : inactivateBenefitAccIds or id in : activateBenefitAccIds]){   //QUERY -1 - Account       
        if(!String.IsBlank(actRec.Core_IPA_One_Partner_Id__c) && actRec.Core_IPA_One_Partner_Id__c != actRec.id){
          mapOfOpidAccIdLocId.put(actRec.Core_IPA_One_Partner_Id__c, actRec.id);
        }
      }        
      if(!mapOfOpidAccIdLocId.isEmpty()){
        for(PRM_AccountChannelMembership__c acmrecord : [SELECT PRM_Channel_Program_Level_Id__r.name,PRM_Partner_Role__c, PRM_Status_Nm__c, PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_One_Partner_Id__c 
                                                                 from PRM_AccountChannelMembership__c 
                                                                 where PRM_Account_Id__c in:mapOfOpidAccIdLocId.keySet() and PRM_Status_Nm__c='Approved' and PRM_Account_Id__r.RecordType.DeveloperName ='Core_Partner_Account_Group'
                                                                ]){
          if(inactivateBenefitAccIds.contains(mapOfOpidAccIdLocId.get(acmrecord.PRM_Account_Id__c))){
            inactivateBenefitAccIds.add(acmrecord.PRM_Account_Id__c);
          }else{
            activateBenefitAccIds.add(acmrecord.PRM_Account_Id__c);
          }
          
        }
      }
      
      List<PRM_AccountBenefitAssociation__c> actABAtobeUpdated = new List<PRM_AccountBenefitAssociation__c>();  
      Set<Id> abaAccIdsUpdated = new Set<Id>();  
      for(PRM_AccountBenefitAssociation__c aba : [select id,PRM_Status_Nm__c,PRM_Account_Id__c,PRM_Partner_Benefit_Id__r.name,PRM_Status_Reason_Txt__c 
                                                        from PRM_AccountBenefitAssociation__c 
                                                        where (PRM_Account_Id__c in:activateBenefitAccIds or PRM_Account_Id__c in:inactivateBenefitAccIds) AND PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c in :System.Label.PRM_benefits_for_point_not_eligible_flag.split(';')
                                                       ]){
        if(inactivateBenefitAccIds.contains(aba.PRM_Account_Id__c) && aba.PRM_Status_Nm__c=='Active'){
          aba.PRM_Status_Nm__c = System.label.PRM_Status_Inactive;
          aba.PRM_Status_Reason_Txt__c =System.label.PRM_Points_Not_eligible_Flag_checked;
          actABAtobeUpdated.add(aba);
          abaAccIdsUpdated.add(aba.PRM_Account_Id__c);
        }else if(activateBenefitAccIds.contains(aba.PRM_Account_Id__c) && aba.PRM_Status_Nm__c=='Inactive'){
          aba.PRM_Status_Nm__c = System.label.PRM_Status_Active;
          aba.PRM_Status_Reason_Txt__c ='';
          actABAtobeUpdated.add(aba);
          abaAccIdsUpdated.add(aba.PRM_Account_Id__c);
        }                          
      }      
      if(!actABAtobeUpdated.isEmpty()){
                Database.update(actABAtobeUpdated,false);
      }      
      accountids.addAll(activateBenefitAccIds);
      accountids.addAll(inactivateBenefitAccIds);
      
      contactIdsForCompPCR=getContactsOfCompStatusPCR(accountids);
      if(!contactIdsForCompPCR.isEmpty()){
                // commented as part of soql 101 fix.
        //Database.update(ceList) 

                //added this logic as part of soql 101 fix - 6 May 2025 : TWC729-7872
                if(System.isBatch() || System.isQueueable() || System.isFuture()) {
                    updateCERecords(contactIdsForCompPCR,abaAccIdsUpdated,inactivateBenefitAccIds,activateBenefitAccIds);
                }
                else{
                    updateCERecordsAsync(contactIdsForCompPCR,abaAccIdsUpdated,inactivateBenefitAccIds,activateBenefitAccIds);
                }
      }
      
    }
    }
  }catch(Exception e){
    //System.debug('The following exception has occurred: ' + e.getMessage());
        Core_Log_Entry.logEntryWithException('PRM_ProfileResponse', 'IPA', 'ProfileResponse', 'Medium',logEntryMsg,'' , '', '', '',e);     
  }
}

    /**
        *  @description      : IPA 2.0 - activate/inactivate benefits based on points not eligible and point opt in  
        *  @name             : activateInactiveBenefit_IPAR
        *  @param            : List<PRM_IPAMembership_Attributes__c> newIpaMemAtt, Map<id, PRM_IPAMembership_Attributes__c>oldMap
        *  @throws exception : NONE
        * @userstory         : TWC729-7967
    **/
    public static void activateInactiveBenefit_IPAR(List<PRM_IPAMembership_Attributes__c> newIpaMemAtt, Map<id, PRM_IPAMembership_Attributes__c>oldMap){
        String logEntryMsg = 'Inside activateInactiveBenefit_IPAR:newIpaMemAtt:'+newIpaMemAtt+'::\noldMap:'+oldMap;
        try{
            activateInactivateBenefitExecuted = true;
            List<PRM_AccountBenefitAssociation__c> actABAtobeUpdated = new List<PRM_AccountBenefitAssociation__c>();  
            Set<Id> abaAccIdsUpdated = new Set<Id>();
            Map<Id,PRM_IPAMembership_Attributes__c> allAccountIds = new Map<Id,PRM_IPAMembership_Attributes__c>();
            Set<Id> opidAccountids = new Set<Id>();
            Set<Id> intelAccountIds = new Set<Id>();  
            Set<id> contactIdsForCompPCR = new Set<Id>();
            Set<Id> inactiveIntelAccts = new Set<ID>();
            Set<Id> activeIntelAccts = new Set<ID>();
            Id OpidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
            if(!fromPointsCalculation && fromOPID){
                Set<Id> inactivateBenefitAccIds = new Set<Id>();
                Set<Id> activateBenefitAccIds = new Set<Id>();
                Set<Id> allOpidAccts = new Set<Id>();        
                for(PRM_IPAMembership_Attributes__c ipaMemAtt: newIpaMemAtt){
                    allAccountIds.put(ipaMemAtt.PRM_Account_Id__c,ipaMemAtt);
                }
                if(allAccountIds!=null){
                    //ATHR Fix - TWC729-9556
                    for(PRM_AccountChannelMembership__c acmrecord : [SELECT PRM_Account_Id__c/* PRM_Channel_Program_Level_Id__r.name,PRM_Partner_Role__c, PRM_Status_Nm__c,PRM_Account_Id__r.Core_IPA_One_Partner_Id__c */
                                                                 from PRM_AccountChannelMembership__c 
                                                                 where PRM_Account_Id__c in:allAccountIds.keySet() and PRM_Status_Nm__c='Approved' and PRM_Account_Id__r.RecordType.DeveloperName ='Core_Partner_Account_Group'
                                                                ]){
                        Boolean isEligible = allAccountIds.get(acmrecord.PRM_Account_Id__c).PRM_Points_Opt_in_Ind__c ? true: false;
                        Boolean wasEligible = (oldMap!=null && oldMap.get(allAccountIds.get(acmrecord.PRM_Account_Id__c).id).PRM_Points_Opt_in_Ind__c )? true: false;
                        Boolean isNotEligible = allAccountIds.get(acmrecord.PRM_Account_Id__c).PRM_Points_Not_Eligible_Ind__c ? true: false;
                         Boolean wasNotEligible = (oldMap!=null && oldMap.get(allAccountIds.get(acmrecord.PRM_Account_Id__c).id).PRM_Points_Not_Eligible_Ind__c) ? true:false;
                        if( isNotEligible && (oldMap==null || !wasNotEligible)){
                            inactivateBenefitAccIds.add(acmrecord.PRM_Account_Id__c);
                        }else if(!isNotEligible  && (oldMap==null ||wasNotEligible )){
                            activateBenefitAccIds.add(acmrecord.PRM_Account_Id__c);
                        }
                        else if(isEligible && (oldmap ==null || !wasEligible)){
                            activateBenefitAccIds.add(acmrecord.PRM_Account_Id__c);
                        }
                    }
                }  
                logEntryMsg += '\nInside activateInactiveBenefit_IPAR:inactivateBenefitAccIds:'+inactivateBenefitAccIds+'::\nactivateBenefitAccIds:'+activateBenefitAccIds;         
                if(!activateBenefitAccIds.IsEmpty() || !inactivateBenefitAccIds.IsEmpty()){          
                    allOpidAccts.addAll(activateBenefitAccIds);
                    allOpidAccts.addAll(inactivateBenefitAccIds);     
                    for(PRM_AccountBenefitAssociation__c aba : [select id,PRM_Status_Nm__c,PRM_Account_Id__c,PRM_Partner_Benefit_Id__r.name,PRM_Status_Reason_Txt__c 
                                                            from PRM_AccountBenefitAssociation__c 
                                                            where (PRM_Account_Id__c in:activateBenefitAccIds or PRM_Account_Id__c in:inactivateBenefitAccIds) AND PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c in :System.Label.PRM_benefits_for_point_not_eligible_flag.split(';')
                                                        ]){
                        if(inactivateBenefitAccIds.contains(aba.PRM_Account_Id__c) && aba.PRM_Status_Nm__c=='Active'){
                            aba.PRM_Status_Nm__c = System.label.PRM_Status_Inactive;
                            aba.PRM_Status_Reason_Txt__c =System.label.PRM_Points_Not_eligible_Flag_checked;
                            actABAtobeUpdated.add(aba);
                            abaAccIdsUpdated.add(aba.PRM_Account_Id__c);
                        }else if(activateBenefitAccIds.contains(aba.PRM_Account_Id__c) && aba.PRM_Status_Nm__c=='Inactive'){
                            aba.PRM_Status_Nm__c = System.label.PRM_Status_Active;
                             aba.PRM_Status_Reason_Txt__c ='Points Optin flag checked';//TWC729-8089 : Adding reason text : NJ
                            actABAtobeUpdated.add(aba);
                            abaAccIdsUpdated.add(aba.PRM_Account_Id__c);
                        }                          
                    }
                    logEntryMsg += '\nInside activateInactiveBenefit_IPAR:actABAtobeUpdated:'+actABAtobeUpdated+'::\nabaAccIdsUpdated:'+abaAccIdsUpdated; 
                    if(!actABAtobeUpdated.isEmpty()){
                        Database.update(actABAtobeUpdated,false);
                    }      
                    opidAccountids.addAll(activateBenefitAccIds);
                    opidAccountids.addAll(inactivateBenefitAccIds);
                    logEntryMsg += '\nInside activateInactiveBenefit_IPAR:opidAccountids:'+opidAccountids; 
                    
                    for(Core_Account_Group_member__c cag : [SELECT id,Core_Intel_Account_Id__c,Core_Partner_Account_Id__c from Core_Account_Group_Member__c where Core_Partner_Account_Id__c in: opidAccountids and Core_Intel_Partner_Alliance_PartnerGroup__c = true]){
                        if(abaAccIdsUpdated.contains(cag.Core_Partner_Account_Id__c)){
                        intelAccountIds.add(cag.Core_Intel_Account_Id__c);
                    }
                        if(inactivateBenefitAccIds.contains(cag.Core_Partner_Account_Id__c)){
                            inactiveIntelAccts.add(cag.Core_Intel_Account_Id__c);
                        }
                        if(activateBenefitAccIds.contains(cag.Core_Partner_Account_Id__c)){
                            activeIntelAccts.add(cag.Core_Intel_Account_Id__c);
                        }
                    }
                    logEntryMsg += '\nInside activateInactiveBenefit_IPAR:intelAccountIds:'+intelAccountIds+'::\ninactiveIntelAccts:'+inactiveIntelAccts+'::\nactiveIntelAccts:'+activeIntelAccts;
                    contactIdsForCompPCR=getContactsOfCompStatusPCR(intelAccountIds);

                    logEntryMsg += '\nInside activateInactiveBenefit_IPAR:contactIdsForCompPCR:'+contactIdsForCompPCR; 

                    if(!contactIdsForCompPCR.isEmpty()){
                        // commented as part of soql 101 fix.
                        //Database.update(ceList) 

                        //added this logic as part of soql 101 fix - 6 May 2025 : TWC729-7872
                        if(System.isBatch() || System.isQueueable() || System.isFuture()) {
                            updateCERecords_IPAR(contactIdsForCompPCR,abaAccIdsUpdated,inactivateBenefitAccIds,activateBenefitAccIds);
                        }
                        else{
                            updateCERecordsAsync_IPAR(contactIdsForCompPCR,abaAccIdsUpdated,inactivateBenefitAccIds,activateBenefitAccIds);
                        }
                    }
                }
            }    
        }catch(Exception e){
            //System.debug('The following exception has occurred: ' + e.getMessage());
            Core_Log_Entry.logEntryWithException('PRM_ProfileResponse', 'IPA', 'ProfileResponse', 'Medium',logEntryMsg,'' , '', '', '',e);     
        }

        PRM_ProfileResponseOptIn.createLogEntry(logEntryMsg,'PRM_ProfileResponse');
    }
    public static void updateCERecords_IPAR(Set<Id> contactIdsForCompPCR, Set<Id> abaAccIdsUpdated, Set<Id> inactivateBenefitAccIds, Set<Id> activateBenefitAccIds){

        String logEntryMsg = 'Inside updateCERecords_IPAR:contactIdsForCompPCR:'+contactIdsForCompPCR+'::\nabaAccIdsUpdated:'+abaAccIdsUpdated+'::\ninactivateBenefitAccIds:'+inactivateBenefitAccIds+'::\nactivateBenefitAccIds:'+activateBenefitAccIds;

        List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
            
      for(Core_Contact_Entitlement__c ce : [select id,Core_Status__c,Core_Data_Loaded__c,Core_Selected__c,Core_Contact_Id__r.AccountId, Core_Contact_Id__r.Account.Core_IPA_One_Partner_Id__c from Core_Contact_Entitlement__c where Core_Contact_Id__c in:contactIdsForCompPCR and  
                                                  Core_Contact_Id__r.Account.Core_IPA_One_Partner_Id__c in :abaAccIdsUpdated and Core_Entitlement_Id__r.name in :Label.PRM_EntitlementNamesToInactive.split(';') ]){
        if(inactivateBenefitAccIds.contains(ce.Core_Contact_Id__r.Account.Core_IPA_One_Partner_Id__c) && ce.Core_Selected__c == TRUE && ce.Core_Status__c == 'Complete'){
          ce.Core_Selected__c = false;
          ce.Core_Status__c ='Pending';
          ce.Core_Data_Loaded__c=true;
          ceList.add(ce);        
        }else if(activateBenefitAccIds.contains(ce.Core_Contact_Id__r.Account.Core_IPA_One_Partner_Id__c) && ce.Core_Selected__c == FALSE){
                    ce.Core_Selected__c = true;
          ce.Core_Status__c ='Pending';
          ce.Core_Data_Loaded__c =true;
          ceList.add(ce);
        }
      }

       logEntryMsg += 'Inside updateCERecords_IPAR:ceList:'+ceList;
      

            if (ceList != null) {
                List<Database.SaveResult> saveResultList = Database.update(ceList,false);
                for (Database.SaveResult sr : saveResultList ) {
                    if(!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors()){
                            Core_Log_Entry.logEntryWithDetails('PRM_ProfileResponse', 'IPA', 'ProfileResponse', 'Medium','Profile Rsponse Async Update' ,err.getMessage(), sr.getId(), 'Core_Contact_Entitlement__c', 'Core_Contact_Entitlement__c'); 
                        }
                    }
                }
            }

            PRM_ProfileResponseOptIn.createLogEntry(logEntryMsg,'PRM_ProfileResponse');

    }
    //added this new future method as part of soql 101 fix - 6 May 2025 : TWC729-7872
    @future
    public static void updateCERecordsAsync_IPAR(Set<Id> contactIdsForCompPCR,Set<Id> abaAccIdsUpdated,Set<Id> inactivateBenefitAccIds, Set<Id> activateBenefitAccIds) {
        updateCERecords_IPAR(contactIdsForCompPCR,abaAccIdsUpdated,inactivateBenefitAccIds,activateBenefitAccIds);
    }
    //added this new method as part of soql 101 fix - 6 May 2025 : TWC729-7872
    public static void updateCERecords(Set<Id> contactIdsForCompPCR, Set<Id> abaAccIdsUpdated, Set<Id> inactivateBenefitAccIds, Set<Id> activateBenefitAccIds){
        List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
            
      for(Core_Contact_Entitlement__c ce : [select id,Core_Status__c,Core_Data_Loaded__c,Core_Selected__c,Core_Contact_Id__r.AccountId from Core_Contact_Entitlement__c where Core_Contact_Id__c in:contactIdsForCompPCR and  
                                                  Core_Contact_Id__r.AccountId in :abaAccIdsUpdated and Core_Entitlement_Id__r.name in :Label.PRM_EntitlementNamesToInactive.split(';') ]){
        if(inactivateBenefitAccIds.contains(ce.Core_Contact_Id__r.AccountId) && ce.Core_Selected__c == TRUE && ce.Core_Status__c == 'Complete'){
          ce.Core_Selected__c = false;
          ce.Core_Status__c ='Pending';
          ce.Core_Data_Loaded__c=true;
          ceList.add(ce);        
        }else if(activateBenefitAccIds.contains(ce.Core_Contact_Id__r.AccountId) && ce.Core_Selected__c == FALSE){
                    ce.Core_Selected__c = true;
          ce.Core_Status__c ='Pending';
          ce.Core_Data_Loaded__c =true;
          ceList.add(ce);
        }
      }
            if (ceList != null) {
                List<Database.SaveResult> saveResultList = Database.update(ceList,false);
                for (Database.SaveResult sr : saveResultList ) {
                    if(!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors()){
                            Core_Log_Entry.logEntryWithDetails('PRM_ProfileResponse', 'IPA', 'ProfileResponse', 'Medium','Profile Rsponse Async Update' ,err.getMessage(), sr.getId(), 'Core_Contact_Entitlement__c', 'Core_Contact_Entitlement__c'); 
                        }
                    }
                }
            }
    }
    //added this new future method as part of soql 101 fix - 6 May 2025 : TWC729-7872
    @future
    public static void updateCERecordsAsync(Set<Id> contactIdsForCompPCR,Set<Id> abaAccIdsUpdated,Set<Id> inactivateBenefitAccIds, Set<Id> activateBenefitAccIds) {
        updateCERecords(contactIdsForCompPCR,abaAccIdsUpdated,inactivateBenefitAccIds,activateBenefitAccIds);
    }
     /* This method is used for fetching contact Ids of PCRS with complete status
     added by LATA for scenario: Flag updates - when flag is updated at account level, 
    entitlements belonging to inactive contact are also getting updated.
    Developer : LATA */
                     
    public static set<Id> getContactsOfCompStatusPCR(set<Id> accIds){
              set<Id> contactIdsForCompPCR=new set<Id>();
                for(PRM_Account_Contact_Relationship__c acrRec : [select id,PRM_Relationship_Id__r.name,PRM_Account_Id__r.Core_IPA_Partner_Segment__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c, PRM_Account_Id__r.Core_IPA_One_Partner_Id__c, PRM_Contact_Id__c, PRM_Contact_Id__r.Core_IPA_PartnerRole__c , PRM_Partner_Role__c,PRM_Account_Id__c,PRM_Contact_Id__r.Core_IPA_Contact_Segment__c from PRM_Account_Contact_Relationship__c where PRM_InActive_Ind__c=false and PRM_Status_Nm__c='Complete' and PRM_Account_Id__c in: accIds]){
                  contactIdsForCompPCR.add(acrRec.PRM_Contact_Id__c);
                }
                return contactIdsForCompPCR;
    }
    
    public static void OPIDToLoctionRollDown(List<PRM_Profile_Responses__c> OPIDProfileReponseUpdate, Map<id, PRM_Profile_Responses__c> oldMap){        
        Set<ID> OPIDProfileResponseID = new Set<ID>();
        List<PRM_Profile_Responses__c> OPIDProfileResponesList = new List<PRM_Profile_Responses__c>();
        List<Core_Account_Group_Member__c> LocationAccountList = new List<Core_Account_Group_Member__c>();
        List<PRM_Profile_Responses__c> FinalProfileRespnseList = new List<PRM_Profile_Responses__c>();
        //List<PRM_Profile_Responses__c> allreponsesLocationLevel = new List<PRM_Profile_Responses__c>();
        List<PRM_Profile_Responses__c> allreponsesOPIDLevel = new List<PRM_Profile_Responses__c>();
        Map<id,list<PRM_Profile_Responses__c>> allreponsesLocationLevelMap2 = new Map<id,list<PRM_Profile_Responses__c>>();
        Map<id,set<string>> allreponsesLocationLevelMap = new Map<id,set<string>>();      
        //      Map<id,set<string>> allreponsesLocationLevelMap2 = new Map<id,set<string>>();      
        Set<ID> locAccountIdsOnCag = new Set<ID>();
        
        String responseQuestions = System.Label.PRM_Response_Questions;
        Set<String> responseQuestionsIdSet = new Set<String>();
        
        for(String str: responseQuestions.split(';')){
            responseQuestionsIdSet.add(str);
        }
        for(PRM_Profile_Responses__c newPrRes :  OPIDProfileReponseUpdate )  {
            PRM_Profile_Responses__c oldPrRes ;
            if(oldMap!=null && oldMap.size()>0){
                oldPrRes = (PRM_Profile_Responses__c)oldMap.get(newPrRes.Id); 
            }
            if((oldMap == null  && (newPrRes.PRM_Response_Txt__c != null  || newPrRes.PRM_Reason_Text__c != null  )) ||  ( oldMap != null && ( newPrRes.PRM_Response_Txt__c != oldPrRes.PRM_Response_Txt__c || newPrRes.PRM_Reason_Text__c != oldPrRes.PRM_Reason_Text__c))){                    
                OPIDProfileResponseID.add(newPrRes.PRM_Account_Id__c);  // adding specialties to a set
                OPIDProfileResponesList.add(newPrRes);            
            }    
        }      
        if(!OPIDProfileResponseID.IsEmpty()){
            for(Core_Account_Group_Member__c Temp : [SELECT Name,Core_Partner_Account_Id__c,Core_Inactive_Ind__c,Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c  WHERE Core_Partner_Account_Id__c IN:OPIDProfileResponseID AND Core_Inactive_Ind__c=false AND Core_Intel_Partner_Alliance_PartnerGroup__c=true ]){
                LocationAccountList.add(Temp);
                locAccountIdsOnCag.add(Temp.Core_Intel_Account_Id__c);
            }
        }
        // Get all the responses for the OPID 
        if(!locAccountIdsOnCag.IsEmpty()){
            for(PRM_Profile_Responses__c LocRespnse: [ select PRM_Profile_Questions_Id__C, PRM_Profile_Questions_Id__r.PRM_Question_Cd__c ,PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c, PRM_Account_Id__c, PRM_View_History__c, PRM_Response_Txt__c,  PRM_InActive_Ind__c ,PRM_Question_Display_Text__c, PRM_Reason_Text__c, RecordTypeId  from PRM_Profile_Responses__c where PRM_Account_Id__c in :locAccountIdsOnCag and PRM_Question_Display_Text__c in:responseQuestionsIdSet order by  CreatedDate desc  ]){
                allreponsesOPIDLevel.add(LocRespnse)  ;
                if(allreponsesLocationLevelMap.keyset().contains(LocRespnse.PRM_Account_Id__c)){
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
        if(!LocationAccountList.IsEmpty() && !OPIDProfileResponseID.IsEmpty()){
            for(PRM_Profile_Responses__c ResponseList:OPIDProfileResponesList ){
                for(Core_Account_Group_Member__c TempLocation:LocationAccountList){
                    if(ResponseList.PRM_Account_Id__c==TempLocation.Core_Partner_Account_Id__c){
                        if (allreponsesLocationLevelMap.containskey(TempLocation.Core_Intel_Account_Id__c)){
                            //The below method will check if the response is already available at location level
                            if(allreponsesLocationLevelMap.get(TempLocation.Core_Intel_Account_Id__c).contains(ResponseList.PRM_Question_Display_Text__c)){
                                for(PRM_Profile_Responses__c locResponseLoop  : allreponsesLocationLevelMap2.get(TempLocation.Core_Intel_Account_Id__c)){
                                    if(locResponseLoop.PRM_Question_Display_Text__c == ResponseList.PRM_Question_Display_Text__c){
                                        PRM_Profile_Responses__c OPIDPrf = new PRM_Profile_Responses__c();
                                        OPIDPrf.id      = locResponseLoop.id ;
                                        OPIDPrf.PRM_Response_Txt__c=ResponseList.PRM_Response_Txt__c;
                                        if (ResponseList.PRM_Question_Display_Text__c == 'Points Not eligible' || ResponseList.PRM_Question_Display_Text__c == 'Point Status'){
                                            OPIDPrf.PRM_Reason_Text__c= ResponseList.PRM_Reason_Text__c;
                                        }
                                        FinalProfileRespnseList.add(OPIDPrf);
                                    }
                                }
                            }
                            else{
                                if(responseQuestionsIdSet.contains(ResponseList.PRM_Question_Display_Text__c)){
                                PRM_Profile_Responses__c OPIDPrf = new PRM_Profile_Responses__c();
                                OPIDPrf.PRM_Account_Id__c= TempLocation.Core_Intel_Account_Id__c;
                                OPIDPrf.PRM_Profile_Questions_Id__C = ResponseList.PRM_Profile_Questions_Id__c;
                                OPIDPrf.PRM_Response_Txt__c=ResponseList.PRM_Response_Txt__c;
                                if (ResponseList.PRM_Question_Display_Text__c == 'Points Not eligible' || ResponseList.PRM_Question_Display_Text__c == 'Point Status'){
                                    OPIDPrf.PRM_Reason_Text__c= ResponseList.PRM_Reason_Text__c;
                                }  
                                FinalProfileRespnseList.add(OPIDPrf);
                            } 
                            }
                        }else
                        {
                            if(responseQuestionsIdSet.contains(ResponseList.PRM_Question_Display_Text__c)){
                            PRM_Profile_Responses__c OPIDPrf = new PRM_Profile_Responses__c();
                            OPIDPrf.PRM_Account_Id__c= TempLocation.Core_Intel_Account_Id__c;
                            OPIDPrf.PRM_Profile_Questions_Id__C = ResponseList.PRM_Profile_Questions_Id__c;
                            OPIDPrf.PRM_Response_Txt__c=ResponseList.PRM_Response_Txt__c;
                            if (ResponseList.PRM_Question_Display_Text__c == 'Points Not eligible' || ResponseList.PRM_Question_Display_Text__c == 'Point Status'){
                                OPIDPrf.PRM_Reason_Text__c= ResponseList.PRM_Reason_Text__c;
                            }  
                            FinalProfileRespnseList.add(OPIDPrf);
                        }
                        }
                    }           
                }       
            }
            try
            {
                fromOPID = true;
                fromPointsCalculation = false;
                upsert FinalProfileRespnseList;
                PRM_ProfileResponses_TriggerHandler.firstUpdateRun = true;              
            }catch(Exception ex){
                PRM_ErrorUtilityClass.logError(ex);
            }
        }      
    }
    /**
        *  @description      : IPA 2.0 - opid to location roll down of IPA membership attributes 
        *  @name             : OPIDToLoctionRollDown_IPAR
        *  @param            : List<PRM_IPAMembership_Attributes__c> newIpaMemAtt, Map<id, PRM_IPAMembership_Attributes__c>oldMap
        *  @throws exception : NONE
        * @userstory         : TWC729-7967
    **/
     public static void OPIDToLoctionRollDown_IPAR(List<PRM_IPAMembership_Attributes__c> opidIPAMemAttr, Map<id, PRM_IPAMembership_Attributes__c> oldMap){  
        string errorMsgonRolldown =''; 
        errorMsgonRolldown+='\ninside OPIDToLocationRollDown_IPAR, opidIPAMemAttr: '+opidIPAMemAttr;     
        Set<ID> opidRecordId = new Set<ID>();
        List<PRM_IPAMembership_Attributes__c> opidIpaMemAttrList = new List<PRM_IPAMembership_Attributes__c>();
        Map<Id,List<Core_Account_Group_member__c>> opidCagMap = new Map<Id,List<Core_Account_Group_member__c>>();
        Set<ID> locAccountIdsOnCag = new Set<ID>();
        Map<Id,PRM_IPAMembership_Attributes__c> locAcctIpaMemAttMap = new Map<Id,PRM_IPAMembership_Attributes__c>();
        Set<PRM_IPAMembership_Attributes__c> locIpaMemAttrSet = new Set<PRM_IPAMEMbership_Attributes__c>();
        List<PRM_IPAMembership_Attributes__c> listofIpaMemtoUpsert = new List<PRM_IPAMembership_Attributes__c>();
        Id inteIpaMemAttrRecordId = Schema.SObjectType.PRM_IPAMembership_Attributes__c.getRecordTypeInfosByName().get('Intel Account Attributes').getRecordTypeId();
        
        for(PRM_IPAMembership_Attributes__c newIpaMemAtt :  opidIPAMemAttr )  {
            PRM_IPAMembership_Attributes__c oldIpaMemAtt ;
            if(oldMap!=null && oldMap.size()>0){
                oldIpaMemAtt = oldMap.get(newIpaMemAtt.Id); 
            }
            if(oldMap == null ||  ( oldMap != null && (newIpaMemAtt.LastModifiedDate != oldIpaMemAtt.LastModifiedDate))){                    
                opidRecordId.add(newIpaMemAtt.PRM_Account_Id__c);  // adding specialties to a set
                opidIpaMemAttrList.add(newIpaMemAtt);            
            }    
        }      
        if(!opidRecordId.IsEmpty()){
            for(Core_Account_Group_Member__c temp : [SELECT Name,Core_Partner_Account_Id__c,Core_Inactive_Ind__c,Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c  WHERE Core_Partner_Account_Id__c IN:opidRecordId AND Core_Inactive_Ind__c=false AND Core_Intel_Partner_Alliance_PartnerGroup__c=true ]){
                List<Core_Account_Group_Member__c> cagList = new List<Core_Account_Group_member__c>();
                if(opidCagMap.containsKey(temp.Core_Partner_Account_Id__c)){
                    cagList.addall(opidCagMap.get(temp.Core_Partner_Account_Id__c));
                }
                cagList.add(temp);
                opidCagMap.put(temp.Core_Partner_Account_Id__c,cagList);
                locAccountIdsOnCag.add(temp.Core_Intel_Account_Id__c);
            }
        }
        // Get all the responses for the OPID 
        if(!locAccountIdsOnCag.IsEmpty()){
            for(PRM_IPAMembership_Attributes__c locIpaMemAtt: [ SELECT Id,RecordTypeId, PRM_Points_Not_Eligible_Reason_Txt__c, PRM_Points_Not_Eligible_Ind__c, PRM_Points_Not_Eligible_Dt__c, PRM_Component_Point_earning_excl_Ind__c, PRM_Component_Point_earning_excl_Dt__c, PRM_Branded_Point_earning_excl_Ind__c, PRM_Branded_Point_earning_excl_Dt__c, PRM_ODM_whiteboxPointEarning_excl_Ind__c, PRM_ODM_whiteboxPointEarning_excl_Dt__c,PRM_Activity_earning_excluded__c,PRM_Activity_earning_excluded_Start_Date__c,PRM_Client_Business_earning_excluded__c,PRM_ClientBusinessexcluded_StartDate__c,PRM_Ethernet_Business_earning_excluded__c,PRM_Ethernet_BusinessexcludedStartDt__c,PRM_Server_Business_earning_excluded__c,PRM_Server_Business_excluded_Start_Date__c, PRM_Registration_Source_Txt__c, PRM_Points_Opt_in_Ind__c, PRM_Points_Opt_in_Dt__c, PRM_Point_Status_Txt__c, PRM_Point_Status_Dt__c, PRM_Point_Status_Reason_Txt__c, PRM_Account_Id__c FROM PRM_IPAMembership_Attributes__c where PRM_Account_Id__c in :locAccountIdsOnCag ]){//varun
                locAcctIpaMemAttMap.put(locIpaMemAtt.PRM_Account_Id__c,locIpaMemAtt);        
            }
        }         
        errorMsgonRolldown+='opidCagMap: '+opidCagMap;
        errorMsgonRolldown+='opidRecordId: '+opidRecordId;
        if(!opidCagMap.IsEmpty() && !opidRecordId.IsEmpty()){
            for(PRM_IPAMembership_Attributes__c ipaMemAtt:opidIpaMemAttrList ){
                if(!opidCagMap.isEmpty() && opidCagMap.containsKey(ipaMemAtt.PRM_Account_Id__c)){
                    for(Core_Account_Group_Member__c cag: opidCagMap.get(ipaMemAtt.PRM_Account_Id__c) ){
                    PRM_IPAMembership_Attributes__c locMemAttr = new PRM_IPAMembership_Attributes__c();
                    if (locAcctIpaMemAttMap.containskey(cag.Core_Intel_Account_Id__c)){
                        //The below method will check if the response is already available at location level
                        locMemAttr = locAcctIpaMemAttMap.get(cag.Core_Intel_Account_Id__c);
                    }else{
                        locMemAttr.PRM_Account_Id__c= cag.Core_Intel_Account_Id__c;
                        locMemAttr.RecordTypeId =inteIpaMemAttrRecordId;
                    }
                    locMemAttr = createIpaMembershipAttribute_IPAR(locMemAttr,ipaMemAtt);
                    opidtoLocRDMap.add(locMemAttr.PRM_Account_Id__c);
                    listofIpaMemtoUpsert.add(locMemAttr);
                    }
                }
            }           
        }       
        try{
            fromOPID = true;
            fromPointsCalculation = false;
            if(!listofIpaMemtoUpsert.IsEmpty()){
                errorMsgonRolldown+='listofIpaMemtoUpsert: '+listofIpaMemtoUpsert;
                errorMsgonRolldown+='fromOPID: '+fromOPID;
                errorMsgonRolldown+='fromPointsCalculation: '+fromPointsCalculation;
                //upsert all ipa membership attributes for OPID and intel account
                Database.UpsertResult[] result = Database.upsert(listofIpaMemtoUpsert,false);
                for(Database.UpsertResult sr : result){
                    if(!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors()) {
                            errorMsgonRolldown += err.getMessage()+' ';
                        } 
                        errorMsgonRolldown+= '\n';
                    }
                }
            }
            PRM_ProfileResponses_TriggerHandler.firstUpdateRun = true;  
        }catch(Exception ex){
            errorMsgonRolldown+=ex.getMessage();   
        }finally{
            PRM_ProfileResponseOptIn.createLogEntry(errorMsgonRolldown,'PRM_ProfileResponse');
        }   
    }     
     /**
        *  @description      : IPA 2.0 - stamp values from one ipa membership to another
        *  @name             : createIpaMembershipAttribute_IPAR
        *  @param            : PRM_IPAMembership_Attributes__c ipaMemAttReceive, PRM_IPAMembership_Attributes__c ipaMemAttGet
        *  @throws exception : NONE
        * @userstory         : TWC729-7967
    **/ 
    public static PRM_IPAMembership_Attributes__c createIpaMembershipAttribute_IPAR(PRM_IPAMembership_Attributes__c ipaMemAttReceive, PRM_IPAMembership_Attributes__c ipaMemAttGet){
        ipaMemAttReceive.PRM_Points_Not_Eligible_Reason_Txt__c = ipaMemAttGet.PRM_Points_Not_Eligible_Reason_Txt__c ;
        ipaMemAttReceive.PRM_Points_Not_Eligible_Ind__c = ipaMemAttGet.PRM_Points_Not_Eligible_Ind__c ;
        ipaMemAttReceive.PRM_Points_Not_Eligible_Dt__c = ipaMemAttGet.PRM_Points_Not_Eligible_Dt__c;
        ipaMemAttReceive.PRM_Component_Point_earning_excl_Ind__c = ipaMemAttGet.PRM_Component_Point_earning_excl_Ind__c;
        ipaMemAttReceive.PRM_Component_Point_earning_excl_Dt__c = ipaMemAttGet.PRM_Component_Point_earning_excl_Dt__c;
        ipaMemAttReceive.PRM_Branded_Point_earning_excl_Ind__c = ipaMemAttGet.PRM_Branded_Point_earning_excl_Ind__c;
        ipaMemAttReceive.PRM_Branded_Point_earning_excl_Dt__c = ipaMemAttGet.PRM_Branded_Point_earning_excl_Dt__c;
        ipaMemAttReceive.PRM_ODM_whiteboxPointEarning_excl_Ind__c = ipaMemAttGet.PRM_ODM_whiteboxPointEarning_excl_Ind__c;
        ipaMemAttReceive.PRM_ODM_whiteboxPointEarning_excl_Dt__c = ipaMemAttGet.PRM_ODM_whiteboxPointEarning_excl_Dt__c;
        ipaMemAttReceive.PRM_Activity_earning_excluded__c = ipaMemAttGet.PRM_Activity_earning_excluded__c; //varun
        ipaMemAttReceive.PRM_Activity_earning_excluded_Start_Date__c = ipaMemAttGet.PRM_Activity_earning_excluded_Start_Date__c;
        ipaMemAttReceive.PRM_Client_Business_earning_excluded__c = ipaMemAttGet.PRM_Client_Business_earning_excluded__c;
        ipaMemAttReceive.PRM_ClientBusinessexcluded_StartDate__c = ipaMemAttGet.PRM_ClientBusinessexcluded_StartDate__c;
        ipaMemAttReceive.PRM_Ethernet_Business_earning_excluded__c = ipaMemAttGet.PRM_Ethernet_Business_earning_excluded__c;
        ipaMemAttReceive.PRM_Server_Business_earning_excluded__c = ipaMemAttGet.PRM_Server_Business_earning_excluded__c;
        ipaMemAttReceive.PRM_Server_Business_excluded_Start_Date__c = ipaMemAttGet.PRM_Server_Business_excluded_Start_Date__c;
        ipaMemAttReceive.PRM_Ethernet_BusinessexcludedStartDt__c = ipaMemAttGet.PRM_Ethernet_BusinessexcludedStartDt__c;
        ipaMemAttReceive.PRM_Registration_Source_Txt__c = ipaMemAttGet.PRM_Registration_Source_Txt__c;
        ipaMemAttReceive.PRM_Points_Opt_in_Ind__c = ipaMemAttGet.PRM_Points_Opt_in_Ind__c;
        ipaMemAttReceive.PRM_Points_Opt_in_Dt__c = ipaMemAttGet.PRM_Points_Opt_in_Dt__c;
        ipaMemAttReceive.PRM_Point_Status_Txt__c = ipaMemAttGet.PRM_Point_Status_Txt__c;
        ipaMemAttReceive.PRM_Point_Status_Dt__c = ipaMemAttGet.PRM_Point_Status_Dt__c;
        ipaMemAttReceive.PRM_Point_Status_Reason_Txt__c = ipaMemAttGet.PRM_Point_Status_Reason_Txt__c;
        return ipaMemAttReceive;
    }

        //This method is to calculate Points Status and Points Status Date based on Points Opt-In and Points Not Eligible field ,Called from ProfileResponse trigger and ALA trigger    
        public static void pointsCalculation(List<PRM_Profile_Responses__c> OPIDProfileReponseUpdate, Map<Id,PRM_Profile_Responses__c> oldMap)
        {  
            //if(pointsRun){
            set<id> accountId = new set<id>();
            set<id> acntIdSet = new set<ID>();
            Map<Id,String> questionIdCodeMap = new Map<Id,String>();
            Map<String,id> questionCodeIdMap = new  Map<String,id>();
            map<id,PRM_Profile_Responses__c> pointStatusMap = new map<id,PRM_Profile_Responses__c>();
            map<id,PRM_Profile_Responses__c> pointStatusDateMap = new map<id,PRM_Profile_Responses__c>();
            boolean updateToday = false;
            boolean tochange = true;
            Map<id,Boolean> tncSigned = new  Map<id,Boolean>();
            Map<id,Boolean> tncLocSigned = new  Map<id,Boolean>();
            map<id,List<PRM_Profile_Responses__c>> mapProfileResponse= new  map<id,List<PRM_Profile_Responses__c>>();
            List<String>  questionType = new List<String>{'PRM_Opt_In','PRM_Point_Not_Eligible','PRM_Status_date','PRM_Status'};
            List<PRM_Profile_Responses__c> listProfileResponse = new List<PRM_Profile_Responses__c>();
            Set<Id> OPIDList = new Set<Id>();
            try{
            logEntryMsg+='\n Inside PointsCalculation method';
            for(PRM_Profile_Questions__c qstn:[select id,PRM_Question_Cd__c from PRM_Profile_Questions__c where PRM_Question_Cd__c in :questionType]){
                questionCodeIdMap.put(qstn.PRM_Question_Cd__c,qstn.id);
                questionIdCodeMap.put(qstn.id,qstn.PRM_Question_Cd__c);
            }
            for(PRM_Profile_Responses__c pr : OPIDProfileReponseUpdate){
                if(oldMap!= null){
                if(pr.PRM_Response_Txt__c != oldMap.get(pr.id).PRM_Response_Txt__c && (questionIdCodeMap.get(pr.PRM_Profile_Questions_Id__c) == 'PRM_Opt_In' || questionIdCodeMap.get(pr.PRM_Profile_Questions_Id__c) == 'PRM_Point_Not_Eligible'))
                    accountId.add(pr.PRM_Account_Id__c);
                }
                else{
                    if(questionIdCodeMap.get(pr.PRM_Profile_Questions_Id__c) == 'PRM_Opt_In' || questionIdCodeMap.get(pr.PRM_Profile_Questions_Id__c) == 'PRM_Point_Not_Eligible')
                    accountId.add(pr.PRM_Account_Id__c); 
                }
            }
            if(accountId.size()>0){
                logEntryMsg+='\n Profile Response considered for Points Calculation for accounts '+accountId;
                //for(Core_Account_Group_Member__c cag:[SELECT Id, Name, Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Partner_Account_Id__r.Core_OnePartnerID__c,Core_Inactive_Ind__c from Core_Account_Group_Member__c WHERE Core_Intel_Account_Id__c in :accountId AND Core_Inactive_Ind__c != true]){
                //TWC729-7584 - ApexGuru
                for(Core_Account_Group_Member__c cag:[SELECT Id, Name, Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Partner_Account_Id__r.Core_OnePartnerID__c,Core_Inactive_Ind__c from Core_Account_Group_Member__c WHERE Core_Intel_Account_Id__c in :accountId AND Core_Inactive_Ind__c =false]){  
                    accountId.remove(cag.Core_Intel_Account_Id__c);
                    acntIdSet.add(cag.Core_Partner_Account_Id__c);
                    OPIDList.add(cag.Core_Partner_Account_Id__c);
                }
                acntIdSet.addall(accountId);
            List<PRM_Profile_Responses__c> profRespList = [select id,PRM_Account_Id__c,PRM_Profile_Answer_Id__c,PRM_Profile_Questions_Id__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,PRM_Response_Txt__c,PRM_Profile_Questions_Id__r.PRM_Question_Type_Nm__c,PRM_Profile_Questions_Id__r.PRM_Question_Display_Txt__c,LastModifiedDate,LastModifiedBy.Name,PRM_View_History__c,PRM_InActive_Ind__c,PRM_Reason_Text__c from PRM_Profile_Responses__c Where PRM_Account_Id__c in :acntIdSet and PRM_Profile_Questions_Id__r.PRM_Question_Cd__c in:questionType and id not in:OPIDProfileReponseUpdate order by LastModifiedDate ASC ];
            
            for(PRM_Profile_Responses__c latestResp : OPIDProfileReponseUpdate){
                if(acntIdSet.contains(latestResp.PRM_Account_Id__c)){
                    if(!mapProfileResponse.containskey(latestResp.PRM_Account_Id__c)){
                        List<PRM_Profile_Responses__c> listOofResp = new List<PRM_Profile_Responses__c>();
                        listOofResp.add(latestResp);
                        mapProfileResponse.put((latestResp.PRM_Account_Id__c),listOofResp);
                    }else{
                        mapProfileResponse.get(latestResp.PRM_Account_Id__c).add(latestResp);
                    }
                }
            }
            for(PRM_Profile_Responses__c prUpdate: profRespList){         
                if(prUpdate.PRM_Profile_Questions_Id__r.PRM_Question_Display_Txt__c == 'Point Status'){             
                    pointStatusMap.put((prUpdate.PRM_Account_Id__c),prUpdate);            
                }
                
                if(prUpdate.PRM_Profile_Questions_Id__r.PRM_Question_Display_Txt__c == 'Point Status Date'){
                    pointStatusDateMap.put((prUpdate.PRM_Account_Id__c),prUpdate);
                } 
                
                if(!mapProfileResponse.containskey(prUpdate.PRM_Account_Id__c)){
                    List<PRM_Profile_Responses__c> listOofResp = new List<PRM_Profile_Responses__c>();
                    listOofResp.add(prUpdate);
                    mapProfileResponse.put((prUpdate.PRM_Account_Id__c),listOofResp);
                }else{
                    mapProfileResponse.get(prUpdate.PRM_Account_Id__c).add(prUpdate);
                }             
            }
            //for accounts without OPID - TnC checked at respective account  */
           /* for(PRM_AccountLegalAgreemntAssociation__c legal:[Select id,PRM_Account_Id__c from PRM_AccountLegalAgreemntAssociation__c where PRM_Account_Id__c in :acntIdSet and PRM_InActive_Ind__c=FALSE and PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name ='Intel Partner Alliance']){         
                tncSigned.put(legal.PRM_Account_Id__c,true);
            }
            //for OPID accounts - TnC is checked at all the location accounts
            for(PRM_AccountLegalAgreemntAssociation__c legal:[Select id,PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_One_Partner_Id__c from PRM_AccountLegalAgreemntAssociation__c where PRM_Account_Id__c in:locationAcnts.keySet() and PRM_InActive_Ind__c=FALSE and PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name ='Intel Partner Alliance']){   
                
                tncLocSigned.put(locationAcnts.get(legal.PRM_Account_Id__c),true);
                //<map(opid,true)
            } */
            
            //To check the T&C signed for location accounts
           Id OpidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();      
            for(PRM_AccountLegalAgreemntAssociation__c legal:[Select id,PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_One_Partner_Id__c,PRM_Account_Id__r.RecordTypeId from PRM_AccountLegalAgreemntAssociation__c where (PRM_Account_Id__c in :acntIdSet or PRM_Account_Id__r.Core_IPA_One_Partner_Id__c in :acntIdSet) and PRM_InActive_Ind__c=FALSE and PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name ='Intel Partner Alliance']){   
                if(legal.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c != null && legal.PRM_Account_Id__r.RecordTypeId != OpidAccRecordTypeId)      
                     tncLocSigned.put(legal.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c,true);
                else{
                    tncSigned.put(legal.PRM_Account_Id__c,true);
                }
            }
             
            
            for(Id acntId : mapProfileResponse.keySet()){
                String PNE,optIn,optInDate,NEDate;
                Boolean isSigned = false;
                for(PRM_Profile_Responses__c PrValue :mapProfileResponse.get(acntId)){
                    if(questionIdCodeMap.get(PrValue.PRM_Profile_Questions_Id__c) == 'PRM_Opt_In'){
                        if((String.isNotBlank(PrValue.PRM_Response_Txt__c)) && (PrValue.PRM_Response_Txt__c.toUppercase()!='FALSE')){
                            optin ='TRUE';
                            optInDate = PrValue.PRM_Response_Txt__c;
                        }
                    }
                    else if(questionIdCodeMap.get(PrValue.PRM_Profile_Questions_Id__c) == 'PRM_Point_Not_Eligible'){
                        if((String.isNotBlank(PrValue.PRM_Response_Txt__c)) && (PrValue.PRM_Response_Txt__c.toUppercase()!='FALSE')){
                            PNE = 'TRUE';
                            NEDate = PrValue.PRM_Response_Txt__c;
                        }
                    }
                }
                PRM_Profile_Responses__c pStatus,pStatusDate;
                if(pointStatusMap.containsKey(acntId)){
                    pStatus= pointStatusMap.get(acntId);}                
                if(pointStatusDateMap.containsKey(acntId)){
                    pStatusDate= pointStatusDateMap.get(acntId);}
                
                if(PNE == 'TRUE'){           
                    if(pStatus!= null){             
                        if(pStatus.PRM_Response_Txt__c!='Not Eligible'){
                            pStatus.PRM_Response_Txt__c='Not Eligible';
                            listProfileResponse.add(pStatus);   
                        }                 
                    } 
                    else{
                        PRM_Profile_Responses__c statusResp = new PRM_Profile_Responses__c();                    
                        statusResp.PRM_Response_Txt__c='Not Eligible';
                        statusResp.PRM_Account_Id__c = acntId;
                        statusResp.PRM_Profile_Questions_Id__c =questionCodeIdMap.get('PRM_Status');                  
                        listProfileResponse.add(statusResp);                 
                    }
                    if(pStatusDate!=null){
                        if(pStatusDate.PRM_Response_Txt__c != NEDate){
                            pStatusDate.PRM_Response_Txt__c = NEDate;
                            listProfileResponse.add(pStatusDate);   
                        }     
                        
                    } 
                    else{
                        PRM_Profile_Responses__c statusDate = new PRM_Profile_Responses__c();
                        statusDate.PRM_Response_Txt__c = NEDate;
                        statusDate.PRM_Profile_Questions_Id__c =questionCodeIdMap.get('PRM_Status_date');
                        statusDate.PRM_Account_Id__c = acntId;
                        listProfileResponse.add(statusDate);
                    }
                }
                
                else{
          
                    if(optin == 'TRUE'){ 
            if(OPIDList.contains(acntId)){
                        if(tncLocSigned.get(acntId)!=null) 
                            isSigned = tncLocSigned.get(acntId);
            }
            else if(tncSigned.get(acntId)!=null){
                            isSigned = tncSigned.get(acntId);
                        }
                        if(isSigned){
                            if(pStatus!= null){                            
                                //to not override todays date
                                if(pStatus.PRM_Response_Txt__c == 'Active')
                                { tochange = false;}
                                if(pStatus.PRM_Response_Txt__c == 'Eligible' || pStatus.PRM_Response_Txt__c == 'Not Eligible')
                                { updateToday = true;}
                                if( pStatus.PRM_Response_Txt__c!='Active'){
                                    pStatus.PRM_Response_Txt__c='Active';                    
                                    listProfileResponse.add(pStatus);      
                                }              
                            } 
                            else{
                                PRM_Profile_Responses__c statusResp = new PRM_Profile_Responses__c();                    
                                statusResp.PRM_Response_Txt__c='Active';
                                statusResp.PRM_Account_Id__c = acntId;
                                statusResp.PRM_Profile_Questions_Id__c =questionCodeIdMap.get('PRM_Status');                  
                                listProfileResponse.add(statusResp);
                                
                            }
                            if(pStatusDate!=null){
                                if(updateToday){
                                    if(pStatusDate.PRM_Response_Txt__c != string.valueOf(System.today())){
                                        pStatusDate.PRM_Response_Txt__c = string.valueOf(System.today());  
                                        listProfileResponse.add(pStatusDate);  
                                    } 
                                }
                                else if(toChange){
                                    if(pStatusDate.PRM_Response_Txt__c != optInDate){ 
                                        pStatusDate.PRM_Response_Txt__c = optInDate;
                                        listProfileResponse.add(pStatusDate);  
                                    }
                                }
                            } 
                            else{
                                PRM_Profile_Responses__c statusDate = new PRM_Profile_Responses__c();
                                statusDate.PRM_Response_Txt__c = optInDate;
                                statusDate.PRM_Profile_Questions_Id__c =questionCodeIdMap.get('PRM_Status_date');
                                statusDate.PRM_Account_Id__c = acntId;
                                listProfileResponse.add(statusDate);
                            }
                        }
                        else{
              
                            if(pStatus!= null){ 
                                if(pStatus.PRM_Response_Txt__c == 'Not Eligible')
                                { tochange = false;}
                                if(pStatus.PRM_Response_Txt__c == 'Eligible' || pStatus.PRM_Response_Txt__c == 'Active')
                                { updateToday = true;}                            
                                if(pStatus.PRM_Response_Txt__c !='Not Eligible'){
                                    pStatus.PRM_Response_Txt__c='Not Eligible';                    
                                    listProfileResponse.add(pStatus);
                                }                    
                            } 
                            else{
                                PRM_Profile_Responses__c statusResp = new PRM_Profile_Responses__c();                    
                                statusResp.PRM_Response_Txt__c='Not Eligible';
                                statusResp.PRM_Account_Id__c = acntId;
                                statusResp.PRM_Profile_Questions_Id__c =questionCodeIdMap.get('PRM_Status');                  
                                listProfileResponse.add(statusResp);                                
                            }
                            
                            if(pStatusDate!=null){
                                if(updateToday){
                                    if(pStatusDate.PRM_Response_Txt__c != string.valueOf(System.today())){
                                        pStatusDate.PRM_Response_Txt__c = string.valueOf(System.today());  
                                        listProfileResponse.add(pStatusDate);  
                                    } 
                                }
                                else if(toChange){
                                    if(pStatusDate.PRM_Response_Txt__c != NEDate){ 
                                        pStatusDate.PRM_Response_Txt__c = NEDate;
                                        listProfileResponse.add(pStatusDate);  
                                    }
                                }
                                
                            } 
                            else{
                                PRM_Profile_Responses__c statusDate = new PRM_Profile_Responses__c();
                                statusDate.PRM_Response_Txt__c = NEDate;
                                statusDate.PRM_Profile_Questions_Id__c =questionCodeIdMap.get('PRM_Status_date');
                                statusDate.PRM_Account_Id__c = acntId;
                                listProfileResponse.add(statusDate);
                            }                
                        }
                    }
                    else{
            if(OPIDList.contains(acntId)){
                        if(tncLocSigned.get(acntId)!=null) 
                            isSigned = tncLocSigned.get(acntId);
            }
            else if(tncSigned.get(acntId)!=null){
                            isSigned = tncSigned.get(acntId);
                        }
                        if(isSigned){
              if(pStatus!= null){  
                               /* if(pStatus.PRM_Response_Txt__c == 'Eligible')
                                { tochange = false;}
                                if(pStatus.PRM_Response_Txt__c == 'Not Eligible' || pStatus.PRM_Response_Txt__c == 'Active' || pStatus.PRM_Response_Txt__c =='')
                                { updateToday = true;}  */                          
                                if(pStatus.PRM_Response_Txt__c !='Eligible'){
                                    pStatus.PRM_Response_Txt__c='Eligible';                    
                                    listProfileResponse.add(pStatus);
                                }                    
                            } 
                            else{
                                PRM_Profile_Responses__c statusResp = new PRM_Profile_Responses__c();                    
                                statusResp.PRM_Response_Txt__c='Eligible';
                                statusResp.PRM_Account_Id__c = acntId;
                                statusResp.PRM_Profile_Questions_Id__c =questionCodeIdMap.get('PRM_Status');                  
                                listProfileResponse.add(statusResp);                                
                            }
                            
                            if(pStatusDate!=null){
                                //if(updateToday){
                                    if(pStatusDate.PRM_Response_Txt__c != string.valueOf(System.today())){
                                        pStatusDate.PRM_Response_Txt__c = string.valueOf(System.today());  
                                        listProfileResponse.add(pStatusDate);  
                                    } 
                               /* }
                                else if(toChange){
                                    if( pStatusDate.PRM_Response_Txt__c != optInDate){
                                        pStatusDate.PRM_Response_Txt__c = optInDate;
                                        listProfileResponse.add(pStatusDate);   
                                    } 
                                }*/
                                
                            } 
                            else{
                                PRM_Profile_Responses__c statusDate = new PRM_Profile_Responses__c();
                                statusDate.PRM_Response_Txt__c = optInDate;
                                statusDate.PRM_Profile_Questions_Id__c =questionCodeIdMap.get('PRM_Status_date');
                                statusDate.PRM_Account_Id__c = acntId;
                                listProfileResponse.add(statusDate);
                            }
            }
            else{
              if(pStatus!= null){                        
                if(pStatus.PRM_Response_Txt__c !='Not Eligible'){
                  pStatus.PRM_Response_Txt__c='Not Eligible';                    
                  listProfileResponse.add(pStatus);      
                }              
              } 
              else{
                PRM_Profile_Responses__c statusResp = new PRM_Profile_Responses__c();                    
                statusResp.PRM_Response_Txt__c='Not Eligible';
                statusResp.PRM_Account_Id__c = acntId;
                statusResp.PRM_Profile_Questions_Id__c =questionCodeIdMap.get('PRM_Status');                  
                listProfileResponse.add(statusResp);                            
              }
              
              if(pStatusDate!=null){
                if(pStatus.PRM_Response_Txt__c != NEDate){
                                    pStatusDate.PRM_Response_Txt__c = NEDate != null? NEDate: String.valueOf(System.Today());
                  listProfileResponse.add(pStatusDate);
                }
              } 
              else{
                PRM_Profile_Responses__c statusDate = new PRM_Profile_Responses__c();
                statusDate.PRM_Response_Txt__c = NEDate;
                statusDate.PRM_Profile_Questions_Id__c =questionCodeIdMap.get('PRM_Status_date');
                statusDate.PRM_Account_Id__c = acntId;
                listProfileResponse.add(statusDate);
              }
            }
                    }
                }          
            }
            if(listProfileResponse.size()>0){   
                logEntryMsg+='\n List of Profile Responses getting Inserted/Updated '+listProfileResponse;     
                pointsRun=false;
                fromPointsCalculation = true; 
                PRM_ProfileResponses_TriggerHandler.fromPoints = true;
                //system.debug('updated here with '+listProfileResponse);
                Database.upsert(listProfileResponse,false);
            }
         }
         else{
            logEntryMsg+='\nResponses not considered for Points Calculation';
         }
      }catch(Exception ex){
        logEntryMsg+='\n Caught with exception '+ex.getMessage();
        PRM_ErrorUtilityClass.logError(ex);
      }
      finally{
       // Core_Log_Entry.logEntryWithDetails('PRM_ProfileResponse', 'IPA Registrations', 'ProfileResponse', 'Medium','' ,logEntryMsg, '', '', '');           
      }
     //}
    }

    /*------- IPA 2.0 Profile Response Design Change Starts ----------*/
    public static void createResponse_IPAR(List<PRM_Registration_Request__c> regRequest,List<Account> accList){//TWC727-2858 : IPA 2.0 : Profile Responses- Points Status Calculations
     string errorMsgCreateRsp =''; 
     errorMsgCreateRsp+=' inside createResponse_IPAR, regRequest: '+regRequest;
    Map<Id,PRM_IPAMembership_Attributes__c> existingPRMap = new Map<Id,PRM_IPAMembership_Attributes__c>();
    List<PRM_IPAMembership_Attributes__c> profResponseList = new List<PRM_IPAMembership_Attributes__c>();
    Schema.RecordTypeInfo prLocRecTypeInfo = Schema.SObjectType.PRM_IPAMembership_Attributes__c.getRecordTypeInfosByDeveloperName().get('Intel_Account_Attributes');
    Id prLocRecTypeId=prLocRecTypeInfo.getRecordTypeId();
    //check for duplicates
    if(accList != null && accList.size()>0){
        for(PRM_IPAMembership_Attributes__c pr : [Select id,PRM_Account_Id__c from PRM_IPAMembership_Attributes__c where PRM_Account_Id__c =: accList[0].Id]){
            existingPRMap.put(pr.PRM_Account_Id__c, pr);
        }
    }   
    for(PRM_Registration_Request__c rr : regRequest){
        if(String.isNotBlank(rr.PRM_Profile_Response__c)){
                for(String s : rr.PRM_Profile_Response__c.split('}')){
                String questionCode = s.substringAfter(Label.PRM_QuestionCode+' ').substringBefore(' '+Label.PRM_ResponseCode);
                String answerCode =  s.substringAfter(Label.PRM_ResponseCode+' ').substringBefore(' '+Label.PRM_ResponseValue);
                String responseValue = s.substringAfter(Label.PRM_ResponseValue+' ').substringBefore('}');
                String uniqueCodeFromReg = questionCode+'|'+answerCode;
                System.debug('uniqueCodeFromReg---'+uniqueCodeFromReg);
                //to create profile response
                PRM_IPAMembership_Attributes__c profResponse; 
                if(accList.size() > 0){
                    Id accountId = accList[0].Id;
                    if(existingPRMap.containsKey(accountId)){
                        profResponse = existingPRMap.get(accountId);
                    } else {
                        profResponse = new PRM_IPAMembership_Attributes__c();
                        profResponse.PRM_Account_Id__c = accountId;
                        profResponse.RecordTypeId = prLocRecTypeId;
                    }
                    //  Always re-activate IPA Membership
                    profResponse.PRM_Inactive_ind__c = false;
                    //If the codes matches from Registration and the metadata, populate the corresponding responsevalue from Profile Response from Registration
                    Map<String, Object> qstnAnsCodeMap= PRM_IPAR_ProfileResponse_Utility.getProfResponsemdt();
                    System.debug('qstnAnsCodeMap--'+qstnAnsCodeMap);
                   // for(String key : qstnAnsCodeMap.keySet()) {
                       
                    if(qstnAnsCodeMap.containsKey(uniqueCodeFromReg)){
                        system.debug('Metadata codes are equal'); 
                        //if(record.get('Question_Code__c')==PRM_ProfileResponse_Utility.IPA_REG_SRC){
                            profResponse.PRM_Registration_Source_Txt__c= responseValue;
                            system.debug('profResponse----'+profResponse.PRM_Registration_Source_Txt__c);
                        //}
                    }
                    //}
                    
                    profResponseList.add(profResponse);
                }
            }       
        }
        
    }
        try{
            errorMsgCreateRsp+='profResponseList: '+profResponseList;
    if(profResponseList.size()>0){
        //upsert profResponseList;
        Database.UpsertResult[] result = Database.Upsert(profResponseList,false);
        for (Database.UpsertResult sr : result ) {
                    if(!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors()){
                            errorMsgCreateRsp += err.getMessage()+' ';
                        }
                    }
                }

    }
    }catch(Exception ex){
            errorMsgCreateRsp+=ex.getMessage();   
    }finally{
        PRM_ProfileResponseOptIn.createLogEntry(errorMsgCreateRsp,'PRM_ProfileResponse');
    }
    }

  }