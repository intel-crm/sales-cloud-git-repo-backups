public without sharing class PRM_ProfileResponseCtlr {
    //Wrapper stores information related to Questions and maps questions to responses and answers
    public class FormWrapper{
        @AuraEnabled
        Public PRM_Profile_Questions__c question {get;set;}
        @AuraEnabled
        Public List<PRM_Profile_Answer__c> answers {get;set;}
        @AuraEnabled
        Public PRM_Profile_Responses__c response {get;set;}
        @AuraEnabled
        Public List<PRM_Profile_Responses__c> lstMultiResponse {get;set;} // only for multiselect values as they have multiple responses
        @AuraEnabled
        Public String accountId; //When recordId is ACM Id.
        @AuraEnabled
        Public Boolean isNotAccess = true; //to know the whether the user have access or not
    }
    
    //Method to get info for the given account and channel program in form of the above wrapper
    @AuraEnabled 
    public static List<FormWrapper> getResponses(Id recordId, String channelProg, String objectName){//cognitive complexity of 54 => less than 15
        Id accId;
        List<String> channelProgramNames = new List<String>();
        List<FormWrapper> returnList = new List<FormWrapper>();
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
            channelProgramNames = channelProg.contains(',') ? channelProg.split(',') : new List<String>{channelProg};
        }
        for(ChannelProgram cp :[select id from channelProgram where name in : channelProgramNames]){
            channelProgId.add(cp.id);
        }
        if(!channelProgId.isEmpty()){
            for(PRM_Profile_Questions__c ques : [select id,PRM_Channel_Program_Id__c,PRM_Question_Type_Nm__c,PRM_Question_Display_Txt__c,PRM_Question_Display_Type_Nm__c,PRM_Question_Cd__c from PRM_Profile_Questions__c where PRM_Channel_Program_Id__c in : channelProgId and PRM_InActive_Ind__c = false order by PRM_Display_Order_Nbr__c asc]){
                setQuesId.add(ques.Id);
                lstQues.add(ques);
            }
        }
        if(!setQuesId.isEmpty()){
            returnList = generateResponse(setQuesId,lstQues,accId);
        }
       return returnList;
        
    } 
    public static List<FormWrapper> generateResponse(Set<Id> setQuesId,List<PRM_Profile_Questions__c> lstQues, Id accId){
        
        Map<Id,List<PRM_Profile_Answer__c>> mapQuesToAns = new  Map<Id,List<PRM_Profile_Answer__c>>();
        Map<Id,PRM_Profile_Responses__c> mapQuesToRes = new  Map<Id,PRM_Profile_Responses__c>();
        Map<Id,List<PRM_Profile_Responses__c>> mapQuesToMulti = new  Map<Id,List<PRM_Profile_Responses__c>>();
            for(PRM_Profile_Answer__c objAns : [select id,PRM_Answer_Display_Txt__c,PRM_Answer_Cd__c,PRM_Profile_Questions_Id__c from PRM_Profile_Answer__c where PRM_Profile_Questions_Id__c in: setQuesId]){
                if(mapQuesToAns.containsKey(objAns.PRM_Profile_Questions_Id__c)) {List<PRM_Profile_Answer__c> ansList = mapQuesToAns.get(objAns.PRM_Profile_Questions_Id__c);
                    ansList.add(objAns);
                    mapQuesToAns.put(objAns.PRM_Profile_Questions_Id__c, ansList);
                } else {
                    mapQuesToAns.put(objAns.PRM_Profile_Questions_Id__c, new List<PRM_Profile_Answer__c> { objAns});
                }
            }
            if(accId != null){
              /*  List<PRM_Profile_Responses__c> listResponse = [select id,PRM_Account_Id__c,PRM_Profile_Answer_Id__c,PRM_Profile_Questions_Id__c,PRM_Response_Txt__c,PRM_Profile_Questions_Id__r.PRM_Question_Type_Nm__c,PRM_Profile_Questions_Id__r.PRM_Question_Display_Txt__c,LastModifiedDate,LastModifiedBy.Name,PRM_View_History__c,PRM_InActive_Ind__c,PRM_Reason_Text__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c from PRM_Profile_Responses__c Where PRM_Account_Id__c =:accId and PRM_Profile_Questions_Id__c in :setQuesId and PRM_Profile_Questions_Id__r.PRM_Question_Type_Nm__c != 'Multiselect'];

                List<PRM_Profile_Responses__c> updatePoints = PRM_ProfileResponseCtlr.pointsStatusCalculation(listResponse,accId,fromGetResponse);
                if(updatePoints.size()>0){
                    upsert updatePoints;
                }*/

                for(PRM_Profile_Responses__c objResp : [select id,PRM_Account_Id__c,PRM_Profile_Answer_Id__c,PRM_Profile_Questions_Id__c,PRM_Response_Txt__c,PRM_Profile_Questions_Id__r.PRM_Question_Type_Nm__c,PRM_Profile_Questions_Id__r.PRM_Question_Display_Txt__c,LastModifiedDate,LastModifiedBy.Name,PRM_View_History__c,PRM_InActive_Ind__c,PRM_Reason_Text__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c from PRM_Profile_Responses__c Where PRM_Account_Id__c =:accId and PRM_Profile_Questions_Id__c in :setQuesId order by LastModifiedDate desc,CreatedDate desc,Id desc] ){
                    if(objResp.PRM_Profile_Questions_Id__r.PRM_Question_Type_Nm__c != 'Multiselect' &&
                    !mapQuesToRes.containsKey(objResp.PRM_Profile_Questions_Id__c)){
                     
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
        responseWrapper obj1=new responseWrapper();
        obj1.lstQues=lstQues;
        obj1.mapQuesToAns=mapQuesToAns;
        obj1.mapQuesToRes=mapQuesToRes;
        obj1.mapQuesToMulti=mapQuesToMulti;
        obj1.accId=accId;
        return  generateResponseWrapper(obj1);//Athr fixes
        //return  generateResponseWrapper(lstQues,mapQuesToAns,mapQuesToRes,mapQuesToMulti,accId);
    }
    /*
    public static List<FormWrapper> generateResponseWrapper(List<PRM_Profile_Questions__c> lstQues,Map<Id,List<PRM_Profile_Answer__c>> mapQuesToAns, Map<Id,PRM_Profile_Responses__c> mapQuesToRes, Map<Id,List<PRM_Profile_Responses__c>> mapQuesToMulti, Id accId){
        //Id userId = UserInfo.getUserId();
        List<FormWrapper> returnList = new List<FormWrapper>();
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
            }
                for(UserRecordAccess accShare :userRecordAccess){
                    returnWrap.isNotAccess = !accShare.HasEditAccess;
            }
            returnList.add(returnWrap);
        }
        return returnList;
    } 
*/

     public class responseWrapper{
        public List<PRM_Profile_Questions__c> lstQues{get;set;}
        public Map<Id,List<PRM_Profile_Answer__c>> mapQuesToAns{get;set;}
        public Map<Id,PRM_Profile_Responses__c> mapQuesToRes{get;set;}
        public Map<Id,List<PRM_Profile_Responses__c>> mapQuesToMulti{get;set;}
        public Id accId{get;set;}
    }//Athr fixes

    public static List<FormWrapper> generateResponseWrapper(responseWrapper att){
        Id userId = UserInfo.getUserId();
        List<FormWrapper> returnList = new List<FormWrapper>();
        List<UserRecordAccess> userRecordAccess= [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =: att.accId];
        for(PRM_Profile_Questions__c objQues : att.lstQues){
            FormWrapper returnWrap = new FormWrapper();
            returnWrap.question = objQues;
            if(!att.mapQuesToAns.isEmpty() && att.mapQuesToAns.containsKey(objQues.Id)){
                returnWrap.answers = att.mapQuesToAns.get(objQues.Id);
            }
            if(!att.mapQuesToRes.isEmpty() && att.mapQuesToRes.containsKey(objQues.Id)){
                returnWrap.response = att.mapQuesToRes.get(objQues.Id);
            }
            if(!att.mapQuesToMulti.isEmpty() && att.mapQuesToMulti.containsKey(objQues.Id)){
                returnWrap.lstMultiResponse = att.mapQuesToMulti.get(objQues.Id);
            }
            if(att.accId != null){
                returnWrap.accountId = att.accId;       
            }
            for(UserRecordAccess accShare :userRecordAccess){
                    returnWrap.isNotAccess = !accShare.HasEditAccess;
                }  
            returnList.add(returnWrap);
        }
        return returnList;
    }
    
    @AuraEnabled 
    public static void saveResponse(List<PRM_Profile_Responses__c> lstResp,List<PRM_Profile_Responses__c> delResp,Id accId){
       /* List<PRM_Profile_Responses__c> reponseList = new List<PRM_Profile_Responses__c>();
        List<PRM_Profile_Responses__c> updateRes1 = new List<PRM_Profile_Responses__c>();
        List<PRM_Profile_Responses__c> updateRes2 = new List<PRM_Profile_Responses__c>();	*/
       
        if(!delResp.isEmpty()){
            update delResp;                      
        }
       if(!lstResp.isEmpty()){
            upsert lstResp;
        }
    }

   
    @AuraEnabled
    public static boolean disableFlagValues(id accounId){
      

        Id intelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId(); 
        
        for (Core_Account_Group_Member__c coreActGrpMem : [select Id, Core_Intel_Account_Id__c,Core_Inactive_Ind__c,Core_Intel_Account_Id__r.RecordTypeId from Core_Account_Group_Member__c where Core_Intel_Account_Id__c =:accounId and Core_Inactive_Ind__c=false and Core_Intel_Account_Id__r.RecordTypeId =:intelRecordTypeId ]){
            return true;
        }
       
        return false;
    }
    
   /* public class ProfileReponseWrapper{
        public string pointNE{get; set { pointNE ='Null';}}
        public string optin{get;set { optin ='Null';}}
        public boolean TnCSigned{get;set{ TnCSigned=False;}}
        public string optInDate{set;get;}
        public string NEDate{set;get;}
    }

    public static List<PRM_Profile_Responses__c> pointsStatusCalculation(List<PRM_Profile_Responses__c> responseList,Id acntId,boolean fromGetResponse)
    {
       // ProfileReponseWrapper prWrap=new ProfileReponseWrapper ();
        List<PRM_Profile_Responses__c> updateRes = new List<PRM_Profile_Responses__c>();
        List<PRM_Profile_Responses__c> updatePoints = new List<PRM_Profile_Responses__c>();
        
        Point_Status_Calculation__mdt pointsMdt = new Point_Status_Calculation__mdt();
        Map<String,PRM_Profile_Responses__c> oldPointsMap = new Map<String,PRM_Profile_Responses__c>();
        Map<Id,String> questionCodeMap = new Map<Id,String>();
        Map<String,Id> qstnMap = new Map<String,Id>();
        Set<Id> setIds = new Set<Id>();
        string pointNE ='Null';
        string optin='Null';
        boolean TnCSigned=False;
        string optInDate;
        string NEDate;
        system.debug('listresponse'+responseList);
        List<String> pointsQ = new List<String>{'PRM_Status_date','PRM_Status'};
        for(PRM_Profile_Questions__c qstn:[select id,PRM_Question_Cd__c from PRM_Profile_Questions__c]){
            qstnMap.put(qstn.PRM_Question_Cd__c,qstn.id);
            questionCodeMap.put(qstn.id,qstn.PRM_Question_Cd__c);
        }
        //CAG
        Id accid;
        List<Core_Account_Group_Member__c> CAG= [SELECT Id, Name, Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Partner_Account_Id__r.Core_OnePartnerID__c,Core_Inactive_Ind__c from Core_Account_Group_Member__c WHERE Core_Intel_Account_Id__c =:acntId AND Core_Inactive_Ind__c != true limit 1];
        if(CAG.size()>0){
        accid=CAG[0].Core_Partner_Account_Id__c;
        }
        else{
            accid=acntId;
        }
        System.debug('here at historic response');
        Map<id,PRM_Profile_Responses__c> lstResp = new Map<id,PRM_Profile_Responses__c>();
      //  List<PRM_Profile_Responses__c> prevResp =;
        for(PRM_Profile_Responses__c oldData:[select id,PRM_Account_Id__c,PRM_Profile_Answer_Id__c,PRM_Profile_Questions_Id__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,PRM_Response_Txt__c,PRM_Profile_Questions_Id__r.PRM_Question_Type_Nm__c,PRM_Profile_Questions_Id__r.PRM_Question_Display_Txt__c,LastModifiedDate,LastModifiedBy.Name,PRM_View_History__c,PRM_InActive_Ind__c,PRM_Reason_Text__c,PRM_ResponseDate__c from PRM_Profile_Responses__c Where PRM_Account_Id__c =:accid order by LastModifiedDate ASC])
        {
            lstResp.put(oldData.PRM_Profile_Questions_Id__c,oldData);
        }
        for(PRM_Profile_Responses__c lstRespnew:responseList )
        {
            lstResp.put(lstRespnew.PRM_Profile_Questions_Id__c,lstRespnew);
        }
       System.debug('values'+lstResp.values());
       System.debug('values1111'+questionCodeMap);
        for(PRM_Profile_Responses__c pr: lstResp.values()){
            if(questionCodeMap.get(pr.PRM_Profile_Questions_Id__c) == 'PRM_Opt_In'){
            if( !(String.isEmpty(pr.PRM_Response_Txt__c)) && (pr.PRM_Response_Txt__c.toUppercase()!='FALSE')){
              optin='TRUE';
              optInDate=PR.PRM_Response_Txt__c;
            }           
            }
            if(questionCodeMap.get(pr.PRM_Profile_Questions_Id__c) == 'PRM_Point_Not_Eligible'){
                if( !(String.isEmpty(pr.PRM_Response_Txt__c)) && (pr.PRM_Response_Txt__c.toUppercase()!='FALSE')){
                    NEDate = pr.PRM_Response_Txt__c; 
                    pointNE = 'TRUE';
                }
                else{pointNE ='FALSE';
                }
                }
            if(questionCodeMap.get(pr.PRM_Profile_Questions_Id__c) == 'PRM_Status' || questionCodeMap.get(pr.PRM_Profile_Questions_Id__c) == 'PRM_Status_date'){
                updateRes.add(pr);
            }
           
        }
        System.debug('Existing recs '+ updateRes);
        if([Select COUNT() from PRM_AccountLegalAgreemntAssociation__c where PRM_Account_Id__c =:accid and PRM_InActive_Ind__c=FALSE and PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name ='Intel Partner Alliance'] >0)
        {
            TnCSigned = True;
        }
        
        String queryMdt = 'select id,Opt_In__c,Points_Not_eligible__c,Status_Date__c,Points_Status__c,T_C_Signed__c FROM Point_Status_Calculation__mdt where ';
        if(pointNE == 'TRUE'){
            //String TT='TRUE';
            queryMdt+='Points_Not_eligible__c=:pointNE';
        }
        else if(optin=='Null'){
            queryMdt+='Points_Not_eligible__c=:pointNE AND Opt_In__c=:optin';
        }
        else{
            queryMdt+='Opt_In__c=:optin and Points_Not_eligible__c=:pointNE and T_C_Signed__c=:TnCSigned';
        }
        pointsMdt= database.query(queryMdt);        
        System.debug('MDT '+pointsMdt.Points_Status__c+' date '+pointsMdt.Status_Date__c);
        for(PRM_Profile_Responses__c oldResp:[select id,PRM_Account_Id__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,PRM_Response_Txt__c from PRM_Profile_Responses__c where PRM_Account_Id__c =:accid and (PRM_Profile_Questions_Id__r.PRM_Question_Cd__c = 'PRM_Status' OR PRM_Profile_Questions_Id__r.PRM_Question_Cd__c = 'PRM_Status_date')])
        {
            if((oldResp.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c == 'PRM_Status') ||(oldResp.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c == 'PRM_Status_date')){
            oldPointsMap.put(oldResp.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,oldresp);
            }
        }
       System.debug(oldPointsMap);
        Boolean toChange=true;
        if(updateRes.size()>0){
        for(PRM_Profile_Responses__c prUpdate:updateRes){
            if(prUpdate.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c == 'PRM_Status'){
                prUpdate.PRM_Response_Txt__c = pointsMdt.Points_Status__c;
                //to avoid rewriting the date which is set based on system date
                if(prUpdate.PRM_Response_Txt__c == 'Active' && (prUpdate.PRM_Response_Txt__c==oldPointsMap.get(prUpdate.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c).PRM_Response_Txt__c)){
                    toChange=false;
                }
                if(prUpdate.PRM_Response_Txt__c == 'Active' && ( (oldPointsMap.get(prUpdate.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c).PRM_Response_Txt__c == 'Not Eligible' || oldPointsMap.get(prUpdate.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c).PRM_Response_Txt__c ==  'Eligible' )))
                {                   
                 if(oldPointsMap.get('PRM_Status_date')!=null){
                    updatePoints.add(prUpdate);
                    oldPointsMap.get('PRM_Status_date').PRM_Response_Txt__c =  string.valueOf(System.today());
                    updatePoints.add(oldPointsMap.get('PRM_Status_date'));
                }
                break;
                }
                
                //if(oldPointsMap.get(prUpdate.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c)!=null && prUpdate.PRM_Response_Txt__c!=(oldPointsMap.get(prUpdate.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c)).PRM_Response_Txt__c)                
                updatePoints.add(prUpdate);
            }
            else if(prUpdate.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c == 'PRM_Status_date'){
                system.debug(toChange+' help+');
                if(pointsMdt.Status_Date__c == 'Opt In Date' && toChange){
                   
                prUpdate.PRM_Response_Txt__c = optInDate;
                }
                else if(pointsMdt.Status_Date__c == 'Null' && toChange){
                prUpdate.PRM_Response_Txt__c = '';
                }
                else if(pointsMdt.Status_Date__c == 'Points NE Date' && toChange) {
                prUpdate.PRM_Response_Txt__c =NEDate;
                }
                system.debug( prUpdate.PRM_Response_Txt__c +' here '+(oldPointsMap.get(prUpdate.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c).PRM_Response_Txt__c));
                //if(oldPointsMap.get(prUpdate.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c)!=null && prUpdate.PRM_Response_Txt__c!=(oldPointsMap.get(prUpdate.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c)).PRM_Response_Txt__c)
                system.debug(oldPointsMap.get(prUpdate.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c));
                system.debug( prUpdate.PRM_Response_Txt__c +' here '+(oldPointsMap.get(prUpdate.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c).PRM_Response_Txt__c));
                updatePoints.add(prUpdate);   
            }
        }
        }
        else{
        //new instance of PR
        PRM_Profile_Responses__c prResp = new PRM_Profile_Responses__c();
        prResp.PRM_Profile_Questions_Id__c = qstnMap.get('PRM_Status');
        prResp.PRM_Response_Txt__c = pointsMdt.Points_Status__c;
        prResp.PRM_Reason_Text__c ='saveresponse';
        prResp.PRM_Account_Id__c = acntId;
        updatePoints.add(prResp);
        PRM_Profile_Responses__c prRespDate = new PRM_Profile_Responses__c();
        prRespDate.PRM_Profile_Questions_Id__c = qstnMap.get('PRM_Status_date');
        if(pointsMdt.Status_Date__c == 'Opt In Date'){
            prRespDate.PRM_Response_Txt__c = optInDate;
        }
        else if(pointsMdt.Status_Date__c == 'Null'){
            prRespDate.PRM_Response_Txt__c = '';
        }
        else if(pointsMdt.Status_Date__c == 'Points NE Date') {
            prRespDate.PRM_Response_Txt__c = NEDate;
        }
        prRespDate.PRM_Account_Id__c = acntId;
        updatePoints.add(prRespDate);
        }
       /* if(updatePoints.size()>0)
        upsert updatePoints;
      // getresponses will send points data
       if(fromGetResponse){
       
           return updatePoints;
       }
      else{
                for(PRM_Profile_Responses__c addPR:responseList){
                    updatePoints.add(addPR);
                }
                return updatePoints;
        }
       }*/
       
    
}