public without sharing class PRM_ProfileResponseCtlr {
    //Wrapper stores information related to Questions and maps questions to responses and answers
    public class FormWrapper{
        @AuraEnabled
        PRM_Profile_Questions__c question {get;set;}
        @AuraEnabled
        List<PRM_Profile_Answer__c> answers {get;set;}
        @AuraEnabled
        PRM_Profile_Responses__c response {get;set;}
        @AuraEnabled
        List<PRM_Profile_Responses__c> lstMultiResponse {get;set;} // only for multiselect values as they have multiple responses
        @AuraEnabled
        Public String accountId; //When recordId is ACM Id.
        @AuraEnabled
        Public Boolean isNotAccess = true; //to know the whether the user have access or not
    }
    
    //Method to get info for the given account and channel program in form of the above wrapper
    @AuraEnabled 
    public static List<FormWrapper> getResponses(Id recordId, String channelProg, String objectName){
        Id accId;
        List<FormWrapper> returnList = new List<FormWrapper>();
        Map<Id,List<PRM_Profile_Answer__c>> mapQuesToAns = new  Map<Id,List<PRM_Profile_Answer__c>>();
        Map<Id,PRM_Profile_Responses__c> mapQuesToRes = new  Map<Id,PRM_Profile_Responses__c>();
        Map<Id,List<PRM_Profile_Responses__c>> mapQuesToMulti = new  Map<Id,List<PRM_Profile_Responses__c>>();
        List<String> channelProgramNames = new List<String>();
        Set<Id> channelProgId = new Set<Id>();
        Set<Id> setQuesId = new Set<Id>();
        List<PRM_Profile_Questions__c> lstQues = new List<PRM_Profile_Questions__c>();
        
        
        if(objectName =='PRM_AccountChannelMembership__c'){
            PRM_AccountChannelMembership__c acm = [Select Id, Name,PRM_Channel_Program_Id__c,PRM_Channel_Program_Id__r.Name,PRM_Account_Id__c From PRM_AccountChannelMembership__c Where Id =:recordId AND PRM_Channel_Program_Id__r.Name = 'Intel Partner Alliance' LIMIT 1];
            accId = acm.PRM_Account_Id__c;
            channelProgId.add(acm.PRM_Channel_Program_Id__c);
        }else{
            accId = recordId;
        }
        if(channelProg != null){
            if(channelProg.contains(',')){
                channelProgramNames = channelProg.split(',');
            }else{
                channelProgramNames.add(channelProg);
            }
        }
        for(ChannelProgram cp :[select id from channelProgram where name in : channelProgramNames]){
            channelProgId.add(cp.id);
        }
        if(!channelProgId.isEmpty()){
            for(PRM_Profile_Questions__c ques : [select id,PRM_Channel_Program_Id__c,PRM_Question_Type_Nm__c,PRM_Question_Display_Txt__c,PRM_Question_Display_Type_Nm__c  from PRM_Profile_Questions__c where PRM_Channel_Program_Id__c in : channelProgId order by PRM_Display_Order_Nbr__c asc]){
                setQuesId.add(ques.Id);
                lstQues.add(ques);
            }
        }
        if(!setQuesId.isEmpty()){
            for(PRM_Profile_Answer__c objAns : [select id,PRM_Answer_Display_Txt__c,PRM_Answer_Cd__c,PRM_Profile_Questions_Id__c from PRM_Profile_Answer__c where PRM_Profile_Questions_Id__c in: setQuesId]){
                if(mapQuesToAns.containsKey(objAns.PRM_Profile_Questions_Id__c)) {List<PRM_Profile_Answer__c> ansList = mapQuesToAns.get(objAns.PRM_Profile_Questions_Id__c);
                    ansList.add(objAns);
                    mapQuesToAns.put(objAns.PRM_Profile_Questions_Id__c, ansList);
                } else {
                    mapQuesToAns.put(objAns.PRM_Profile_Questions_Id__c, new List<PRM_Profile_Answer__c> { objAns});
                }
            }
            if(accId != null){
                for(PRM_Profile_Responses__c objResp : [select PRM_Account_Id__c,PRM_Profile_Answer_Id__c,PRM_Profile_Questions_Id__c,PRM_Response_Txt__c,PRM_Profile_Questions_Id__r.PRM_Question_Type_Nm__c,PRM_InActive_Ind__c from PRM_Profile_Responses__c Where PRM_Account_Id__c =:accId and PRM_Profile_Questions_Id__c in :setQuesId] ){
                    if(objResp.PRM_Profile_Questions_Id__r.PRM_Question_Type_Nm__c != 'Multiselect'){
                        mapQuesToRes.put(objResp.PRM_Profile_Questions_Id__c,objResp);
                    }else{
                        if(mapQuesToMulti.containsKey(objResp.PRM_Profile_Questions_Id__c)) {List<PRM_Profile_Responses__c> respList = mapQuesToMulti.get(objResp.PRM_Profile_Questions_Id__c);
                            respList.add(objResp);
                            mapQuesToMulti.put(objResp.PRM_Profile_Questions_Id__c, respList);
                        } else {mapQuesToMulti.put(objResp.PRM_Profile_Questions_Id__c, new List<PRM_Profile_Responses__c> { objResp});
                        }
                    }
                    
                }
            }
        }
        Id userId = UserInfo.getUserId();
        List<UserRecordAccess> userRecordAccess= [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =: accId];
        for(PRM_Profile_Questions__c objQues : lstQues){
            FormWrapper returnWrap = new FormWrapper();
            returnWrap.question = objQues;
            if(!mapQuesToAns.isEmpty() && mapQuesToAns.containsKey(objQues.Id)){
                returnWrap.answers = mapQuesToAns.get(objQues.Id);
            }
            if(!mapQuesToRes.isEmpty() && mapQuesToRes.containsKey(objQues.Id)){
                returnWrap.response = mapQuesToRes.get(objQues.Id);
            }
            if(!mapQuesToMulti.isEmpty() && mapQuesToMulti.containsKey(objQues.Id)){
                returnWrap.lstMultiResponse = mapQuesToMulti.get(objQues.Id);
            }
            if(accId != null){
                returnWrap.accountId = accId;
                 
                for(UserRecordAccess accShare :userRecordAccess){
                    if(accShare.HasEditAccess==false){
                        returnWrap.isNotAccess=true;
                    }else{
                        returnWrap.isNotAccess=false;
                    }
                }           
            }
            returnList.add(returnWrap);
        }
        return returnList;
    } 
    @AuraEnabled 
    public static void saveResponse(List<PRM_Profile_Responses__c> lstResp,List<PRM_Profile_Responses__c> delResp){
        List<PRM_Profile_Responses__c> updateRes = new List<PRM_Profile_Responses__c>();
        List<PRM_Profile_Responses__c> updateRes1 = new List<PRM_Profile_Responses__c>();
        List<PRM_Profile_Responses__c> updateRes2 = new List<PRM_Profile_Responses__c>();
        if(!delResp.isEmpty()){
            system.debug('delResp---'+delResp);
            update delResp;
        }
        if(!lstResp.isEmpty()){
            system.debug('lstResp---'+lstResp.size());
            system.debug('lstResp---'+lstResp[0].PRM_InActive_Ind__c);
            upsert lstResp;
        }
    }
}