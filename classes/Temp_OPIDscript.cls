public class Temp_OPIDscript {
    
    public static void TempScript(){
    
        Set<id> LocationAccntsIdset = new Set<id>();// to store location accnts
        Set<id> OPIDAndLocationAccnts = new Set<id>();// to store OPID accnts
        List<Core_Account_Group_Member__c> OPIDmemberlist = new List<Core_Account_Group_Member__c>();  
        Set<ID> opidAndLocationIds = New Set<ID>(); 
        Map<String,PRM_Profile_Responses__c> responseLimitMap = New Map<String,PRM_Profile_Responses__c>();    
        Set<String> StringOfQuestions= New Set<String>{'PRM_Component_point','PRM_Branded_Point','PRM_ODM_Whitebox_Point','PRM_Point_Not_Eligible','PRM_Opt_In'};
        String responseQuestions = System.Label.PRM_Response_Questions;
        Set<String> responseQuestionsIdSet = new Set<String>();
        Set<String> responseOpidStringSet = new Set<String>();
        Set<String> responseLocStringSet = new Set<String>(); 
        List<PRM_Profile_Responses__c> responseOpidLevel = New List<PRM_Profile_Responses__c>();
        List<PRM_Profile_Responses__c> responseLocLevel = New List<PRM_Profile_Responses__c>();
        Map<String,PRM_Profile_Responses__c> responseLocStringMap = New Map<String,PRM_Profile_Responses__c>();
        Map<String,PRM_Profile_Responses__c> responseOpidStringMap = New Map<String,PRM_Profile_Responses__c>();
        Map<id,List<Core_Account_Group_Member__c>> CagMapOpidIntelMap = new Map<id,list<Core_Account_Group_Member__c>>(); 
        Map<id,list<PRM_Profile_Responses__c>> allreponsesLocationLevelMap2 = new Map<id,list<PRM_Profile_Responses__c>>();
        Map<id,set<string>> allreponsesLocationLevelMap = new Map<id,set<string>>();  
        List<PRM_Profile_Responses__c> FinalProfileRespnseListRollDown= New List<PRM_Profile_Responses__c>();
        List<PRM_Profile_Responses__c> mistmatchResponseOPID = New List<PRM_Profile_Responses__c>();
        Set<Id> mistmatchResponseOPIDSet = New set<Id>();
        String accountNamesString = '';
        String resposneNamesString = '';
        Set<String> OPIDNamesSet = new Set<String>();
        for(String str: responseQuestions.split(';')){
            responseQuestionsIdSet.add(str);
        }
for(Core_Account_Group_Member__c CagMember :[SELECT Name,Core_Partner_Account_Id__c,Core_Inactive_Ind__c,Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c  WHERE Core_Inactive_Ind__c=false AND Core_Intel_Partner_Alliance_PartnerGroup__c=true AND (createddate  > 2022-02-23T00:00:00.000+0000 or LastModifiedDate > 2022-02-23T00:00:00.000+0000) ]){
                          LocationAccntsIdset.add(CagMember.Core_Intel_Account_Id__c);
                          OPIDAndLocationAccnts.add(CagMember.Core_Partner_Account_Id__c);
                          OPIDmemberlist.add(CagMember);
                    if(CagMapOpidIntelMap.keyset().contains(CagMember.Core_Partner_Account_Id__c)){
                    // this map will have unique contacts with their latest email log version
                    List<Core_Account_Group_Member__c> ListOfCags = CagMapOpidIntelMap.get(CagMember.Core_Partner_Account_Id__c);
                    ListOfCags.add(CagMember);
                    CagMapOpidIntelMap.put(CagMember.Core_Partner_Account_Id__c, ListOfCags);
                    }
                    else{
                    CagMapOpidIntelMap.put(CagMember.Core_Partner_Account_Id__c,new List<Core_Account_Group_Member__c>{CagMember}) ;
                    } 
}
        opidAndLocationIds.addall(OPIDAndLocationAccnts);  
        opidAndLocationIds.addall(LocationAccntsIdset);  
   if(!opidAndLocationIds.IsEmpty()){
            for(PRM_Profile_Responses__c  OPIDTemp :[select PRM_Profile_Questions_Id__C, PRM_Profile_Questions_Id__r.PRM_Question_Cd__c ,PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c, PRM_Account_Id__c,PRM_Account_Id__r.name, PRM_View_History__c, PRM_Response_Txt__c,  PRM_InActive_Ind__c ,PRM_Question_Display_Text__c, PRM_Reason_Text__c, RecordTypeId from PRM_Profile_Responses__c where PRM_Account_Id__c  IN: opidAndLocationIds and PRM_Profile_Questions_Id__r.PRM_Question_Cd__c IN: StringOfQuestions  AND (createddate  > 2022-02-23T00:00:00.000+0000 or LastModifiedDate > 2022-02-23T00:00:00.000+0000) order by createddate desc]){
                if(OPIDTemp != null){
                    // The below IF condition to grt only 5 rsponses per account.
                    if(!responseLimitMap.containskey(OPIDTemp.PRM_Account_Id__c+OPIDTemp.PRM_Question_Display_Text__c)){
                        responseLimitMap.put(OPIDTemp.PRM_Account_Id__c+OPIDTemp.PRM_Question_Display_Text__c,OPIDTemp);
                        if(OPIDAndLocationAccnts.contains(OPIDTemp.PRM_Account_Id__c) && responseQuestionsIdSet.contains(OPIDTemp.PRM_Question_Display_Text__c)) {
                            responseOpidLevel.add(OPIDTemp);
                            responseOpidStringSet.add(OPIDTemp.PRM_Account_Id__c+OPIDTemp.PRM_Question_Display_Text__c);
                            responseOpidStringMap.put(OPIDTemp.PRM_Account_Id__c+OPIDTemp.PRM_Question_Display_Text__c,OPIDTemp);
                        }                        
                    }
                }
            }                        
        }

        if(!responseLocLevel.IsEmpty()){
            for(PRM_Profile_Responses__c LocRespnse: responseLocLevel){
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
        if(!responseOpidLevel.isEmpty()){
            // A Map with key as intel Id and value as OPID
            for(PRM_Profile_Responses__c tempPrf : responseOpidLevel){  
                for(Core_Account_Group_Member__c tempCag : CagMapOpidIntelMap.get(tempPrf.PRM_Account_Id__c) ){  
                    if (tempPrf.PRM_Account_Id__c == tempCag.Core_Partner_Account_Id__c ){
                        if (!allreponsesLocationLevelMap.keyset().isEmpty() && allreponsesLocationLevelMap.containskey(tempCag.Core_Intel_Account_Id__c)){
                            if(allreponsesLocationLevelMap.get(tempCag.Core_Intel_Account_Id__c).contains(tempPrf.PRM_Question_Display_Text__c)){
                                for(PRM_Profile_Responses__c locResponseLoop  : allreponsesLocationLevelMap2.get(tempCag.Core_Intel_Account_Id__c)){
                                    if(locResponseLoop.PRM_Question_Display_Text__c == tempPrf.PRM_Question_Display_Text__c){
                                        if(locResponseLoop.PRM_Response_Txt__c  != tempPrf.PRM_Response_Txt__c ){
                                            mistmatchResponseOPID.add(tempPrf);
                                            mistmatchResponseOPIDSet.add(tempPrf.PRM_Account_Id__c);
                                            OPIDNamesSet.add(tempPrf.PRM_Account_Id__r.name);
                                        }
                                        
                                    }
                                }
                            }
                            else{
                                mistmatchResponseOPID.add(tempPrf);
                                mistmatchResponseOPIDSet.add(tempPrf.PRM_Account_Id__c);
                                OPIDNamesSet.add(tempPrf.PRM_Account_Id__r.name);
                            }
                        }                        
                        else{
                            mistmatchResponseOPID.add(tempPrf);
                            mistmatchResponseOPIDSet.add(tempPrf.PRM_Account_Id__c);
                            OPIDNamesSet.add(tempPrf.PRM_Account_Id__r.name);
                            //     }
                        }    
                    }
                }
            }
        }
        for(string str : OPIDNamesSet){
            accountNamesString = accountNamesString + str + '\n' ;
        }    
        for(id str : mistmatchResponseOPIDSet){
            resposneNamesString = resposneNamesString + str + '\n' ;
        }    
    system.debug('mistmatchResponseOPID are '+mistmatchResponseOPID);
    system.debug('mistmatchResponseOPID size is  '+mistmatchResponseOPID.size());
    system.debug('accountNamesString is  '+accountNamesString); 
    system.debug('resposneNamesString is  '+resposneNamesString);        
    system.debug('Total no of unique mismatch OPIDs are  '+OPIDNamesSet.size()); 

    } 
    
}