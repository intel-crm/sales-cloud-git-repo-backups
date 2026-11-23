public with sharing class ProfileResponsePointsCalculation implements Queueable {
    public static String logEntryMsg='';    
    List<PRM_Profile_Responses__c> OPIDProfileReponseUpdate;
    Map<Id,PRM_Profile_Responses__c> oldMap;
    public ProfileResponsePointsCalculation(List<PRM_Profile_Responses__c> prResponses,Map<Id,PRM_Profile_Responses__c> oldResponses) {
        OPIDProfileReponseUpdate = prResponses;
        oldMap = oldResponses;
    }
    public void execute(QueueableContext context) { 
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
   // try{
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
    system.debug('size'+accountId);
    if(accountId.size()>0){
        logEntryMsg+='\n Profile Response considered for Points Calculation for accounts '+accountId;
        for(Core_Account_Group_Member__c cag:[SELECT Id, Name, Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Partner_Account_Id__r.Core_OnePartnerID__c,Core_Inactive_Ind__c from Core_Account_Group_Member__c WHERE Core_Intel_Account_Id__c in :accountId AND Core_Inactive_Ind__c != true]){
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
        System.debug('map val'+mapProfileResponse);
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
                pStatus= pointStatusMap.get(acntId);
            }
            if(pointStatusDateMap.containsKey(acntId)){
                pStatusDate= pointStatusDateMap.get(acntId);
            }
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
                            if( pStatusDate.PRM_Response_Txt__c != optInDate){
                                pStatusDate.PRM_Response_Txt__c = optInDate;
                                listProfileResponse.add(pStatusDate);   
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
                        if(pStatus.PRM_Response_Txt__c != null){
                            pStatusDate.PRM_Response_Txt__c = null;
                            listProfileResponse.add(pStatusDate);
                        }
                    } 
                    else{
                        PRM_Profile_Responses__c statusDate = new PRM_Profile_Responses__c();
                        statusDate.PRM_Response_Txt__c = null;
                        statusDate.PRM_Profile_Questions_Id__c =questionCodeIdMap.get('PRM_Status_date');
                        statusDate.PRM_Account_Id__c = acntId;
                        listProfileResponse.add(statusDate);
                    }
                }
            }           
        }
            if(listProfileResponse.size()>0){   
                logEntryMsg+='\n List of Profile Responses getting Inserted/Updated '+listProfileResponse;  
                //pointsRun = false;    
               upsert listProfileResponse;
            }
         }
         else{
            logEntryMsg+='\nResponses not considered for Points Calculation';
         }
      /*}catch(Exception ex){
        logEntryMsg+='\n Caught with exception '+ex.getMessage();
        PRM_ErrorUtilityClass.logError(ex);
      }
      finally{
       // Core_Log_Entry.logEntryWithDetails('PRM_ProfileResponse', 'IPA Registrations', 'ProfileResponse', 'Medium','' ,logEntryMsg, '', '', '');           
      }*/
  }
}