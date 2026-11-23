public with sharing  class core_IPS_PortalEdqController {
    
    /* Name: Shobhit Srivastav
     * Last Modified date: 23/01/2023
     * Changes: Added logic to check, Is selected country belong to embargoed 
     */
    
    @AuraEnabled
    public static Case SubmitCaseRecord(Case newRecord, Contact contactRecord, String caseEDQdata){
        boolean isProductChanged = false;
        string countryRegion;
        // Start 23/01/2023 Shobhit Srivastav Added logic to check, Is selected country belong to embargoed 
        Id recordTypeIdGEC = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS GEC ReadOnly').getRecordTypeId();
        Map<String, embargo_country__mdt> embargoCountry = embargo_country__mdt.getAll();
            if(newRecord.Core_IPS_Country_Region__c!=null){
               countryRegion =newRecord.Core_IPS_Country_Region__c.replaceAll('[^a-zA-Z0-9]', '_');
            }
            
              if(embargoCountry.containsKey(countryRegion)) {
                  if(embargoCountry.get(countryRegion).State__c == null || embargoCountry.get(countryRegion).State__c == '') {
                    newRecord.Core_IPS_GEC_Flag__c = true;
                    newRecord.IsStopped = true;  
                    newRecord.Status = 'On Hold';
                    newRecord.Core_Sub_Status__c = 'GEC Hold';
                    newRecord.recordtypeID =  recordTypeIdGEC;  
                  } else{
                  List<String> State = embargoCountry.get(countryRegion).State__c.split(',');
                  if(State.contains(newRecord.Core_IPS_Embargoed_State__c)) {
                    newRecord.Core_IPS_GEC_Flag__c = true;
                    newRecord.IsStopped = true;  
                    newRecord.Status = 'On Hold';
                    newRecord.Core_Sub_Status__c = 'GEC Hold';
                    newRecord.recordtypeID =  recordTypeIdGEC;
                  }
                  }
              }
       if(newRecord.ContactId != null && (newRecord.Core_IPS_Country_Region__c != null || newRecord.Core_IPS_Embargoed_State__c != null)) {
            Boolean needUpdate = false;
            Contact toUpdateCon;
            if(Contact.SObjectType.getDescribe().isAccessible()) {
            toUpdateCon = [Select Id,Core_Country_Region__c,Core_IPS_Embargoed_State__c From Contact Where Id = :newRecord.ContactId];
            }
            if(toUpdateCon != null && ((toUpdateCon.Core_Country_Region__c==null || toUpdateCon.Core_Country_Region__c=='') && Schema.sObjectType.Contact.fields.Core_Country_Region__c.isUpdateable())) {
                toUpdateCon.Core_Country_Region__c= newRecord.Core_IPS_Country_Region__c;
                needUpdate = true; 
            } 
            // Added Null Check by chetan as part of 101 SOQL fix
            if(toUpdateCon != null &&  newRecord.Core_IPS_Embargoed_State__c != null && ((toUpdateCon.Core_IPS_Embargoed_State__c == null || toUpdateCon.Core_IPS_Embargoed_State__c == '') && Schema.sObjectType.Contact.fields.Core_IPS_Embargoed_State__c.isUpdateable())) {
                 toUpdateCon.Core_IPS_Embargoed_State__c = newRecord.Core_IPS_Embargoed_State__c;
                 needUpdate = true;
            }
            if(needUpdate) {
                Core_IPS_AdminUtility.updateContact(toUpdateCon);
            }
        }
        // End 23/01/2023 Shobhit Srivastav Added logic to check, Is selected country belong to embargoed
        if(newRecord.Core_Issue_Description__c != null) {
            string strDescValue;
            strDescValue =  Core_Utility.replaceSpecialChar(newRecord.Core_Issue_Description__c);
            //#TWC745-4419 FLS create and update added -Gangadhar #28-07-2023
        if(Schema.sObjectType.Case.fields.Description.isCreateable()||Schema.sObjectType.Case.fields.Description.isUpdateable()){
           	newRecord.Description = Core_Utility.replaceHtmlTags(strDescValue);
            }
        }  
        if(string.isNOTBlank(''+newRecord.id)) {
            List<case> csLst=new List<case>();
            csLst = [select id ,AssetId from case where id =:newRecord.id];
            if(!csLst.isEmpty() && csLst[0].assetId != newRecord.assetId ) {
                isProductChanged = true;
            }
        }    
        
        Case upsertedCase = Core_IPS_AdminUtility.createCase(newRecord);
        List<Core_IPS_Response__c> existingEDQResponses = Core_IPS_Questions_Utility.getEnvDetailCoreResponse(upsertedCase.id);
        Map<Id,ID> questionResponseMap = new Map<Id, id>();
        for(Core_IPS_Response__c response : existingEDQResponses){
            questionResponseMap.put(response.Core_IPS_Question_Master__c, response.id);
        }
        String lsListString = JSON.serialize(caseEDQdata);
        List<Core_IPS_Response__c> getResponse = new List<Core_IPS_Response__c>();
        List<LWCResponseEDQ>  classTwoWrap = LWCResponseEDQ.parse(caseEDQdata);
        
        Map<Id,Boolean> agentEDQMap = new Map<Id,Boolean>();
        List<Core_IPS_Assigned_Environment_Variables__c> edqList;
        String supportedProdId;
        if(newRecord.AssetId!=null){
            supportedProdId = core_IPS_caseCreate_LEX.getSupportedProd(newRecord.AssetId);
        }
        edqList = [select id,Core_IPS_Question__c,Core_IPS_Question_Text__c,Core_Agent_Only__c from Core_IPS_Assigned_Environment_Variables__c where Core_Supported_Product__c =:supportedProdId  OR Core_Product_Issue_Sub_Category__c =: newRecord.Core_Case_Issue_Sub_Category__c ];
        for (integer i=0; i<edqList.size(); i++) { 
            agentEDQMap.put(edqList[i].Core_IPS_Question__c,edqList[i].Core_Agent_Only__c);  
        }

        for(LWCResponseEDQ c: classTwoWrap){
            Core_IPS_Response__c newres = new Core_IPS_Response__c(Core_IPS_Case__c = upsertedCase.Id);
            newres.Core_IPS_Question_Master__c = c.edq[0].qquestion;
            newres.id = questionResponseMap.get(c.edq[0].qquestion); // get the ID for existing question response if any
            if(agentEDQMap.containsKey(c.edq[0].qquestion)){
                newres.Core_IPS_Agent_Only__c = agentEDQMap.get(c.edq[0].qquestion);
            }
            if(c.edq[0].ttype == 'Multiselect Picklist' || c.edq[0].ttype == 'Picklist') {
	    // Commented this line as part of Store Empty EDQs
              //  if(c.edq[0].vvalue == null || c.edq[0].vvalue == '' || String.isBlank(c.edq[0].vvalue) ) {
               // } else {
                    if(c.edq[0].ttype == 'Multiselect Picklist') {
                        List<String> lstStringmul = c.edq[0].vvalue.split(',');
                        for(String vb : lstStringmul) {
                            Core_IPS_Response__c newresaddmulti = new Core_IPS_Response__c();
                            newresaddmulti.Core_IPS_Question_Master__c = c.edq[0].qquestion;
                          //  newresaddmulti.Core_IPS_Answer_Master__c = vb; // Commented this line as part of Store Empty EDQs
                           // added by chiru
                           if(String.isBlank(vb)){
                            newresaddmulti.Core_IPS_Answer_Master__c = null;
                          }else {
                            newresaddmulti.Core_IPS_Answer_Master__c = vb;
                          } 
                            newresaddmulti.Core_IPS_Case__c = upsertedCase.Id;	
                            getResponse.add(newresaddmulti);
                        }
                    } else {
		      // Commented this line as part of Store Empty EDQs
                       // newres.Core_IPS_Answer_Master__c = c.edq[0].vvalue;
		       //added by chiru
                       if(String.isBlank(c.edq[0].vvalue)){
                        newres.Core_IPS_Answer_Master__c = null;
                       }else {
                         newres.Core_IPS_Answer_Master__c = c.edq[0].vvalue;
                       }
                        getResponse.add(newres);
                    }                 
               // }    // Commented this line as part of Store Empty EDQs
                
            }
            
            if(c.edq[0].ttype == 'Text Area' || c.edq[0].ttype == 'Text' ){
              //  if(c.edq[0].vvalue == null || c.edq[0].vvalue == '' || String.isBlank(c.edq[0].vvalue)) {
               // } else {
                  //  newres.Core_IPS_Answer__c = c.edq[0].vvalue;
                   if(String.isBlank(c.edq[0].vvalue)){
                        newres.Core_IPS_Answer__c = null;
                       }else {
                         newres.Core_IPS_Answer__c = c.edq[0].vvalue;
                       }
                    getResponse.add(newres);        
               // }
            }
        }
        
        Core_IPS_AdminUtility.upsertEnvDetailsToCreate(getResponse,upsertedCase.Id, isProductChanged);       
        return upsertedCase;
    }  
    
    @AuraEnabled(cacheable=true)
    public static String getcurrentuserprofile(){
        User currentuser;
        List< PermissionSetAssignment> pset;
        currentUser = [SELECT Id, Name, Profile.Name,Profile.Id FROM User WHERE Id=:UserInfo.getUserId()];
        pset = [SELECT Id, PermissionSetId, PermissionSet.Name,  AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE Assignee.Id =:currentUser.Id AND PermissionSet.Name ='Core_IPS_Partner_FAE_Permission_Set'];
        String profileName = null;
        if(currentUser.Profile.Name == System.Label.Core_IPS_External_Customer_Profile){
            profileName = 'Customer';
            return profileName;
        }
        else if(currentUser.Profile.Id == System.Label.Core_IPS_Agent_Partner_Profile_id ){
            profileName = 'PartnerAgent';
            return profileName;
        }
        else if(!pset.isempty() && currentUser.Profile.Name == System.Label.Core_IPS_Partner_Profile_Name && pset[0].PermissionSet.Name =='Core_IPS_Partner_FAE_Permission_Set'){
            profileName = 'PartnerFAE';
            return profileName;
        } 
        profileName = 'Partner';
        return profileName;
    }
}