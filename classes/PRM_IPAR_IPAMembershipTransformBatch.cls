public class PRM_IPAR_IPAMembershipTransformBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    public final Id prLocRecTypeId = Schema.SObjectType.PRM_IPAMembership_Attributes__c.getRecordTypeInfosByDeveloperName().get('Intel_Account_Attributes').getRecordTypeId();
    public final Id prOPIDRecTypeId = Schema.SObjectType.PRM_IPAMembership_Attributes__c.getRecordTypeInfosByDeveloperName().get('X1PID_Account_Attributes').getRecordTypeId();
    public Integer totalProcessed = 0;
    public Integer totalSuccess = 0;
    public List<PRM_IPAMembership_Attributes__c> membershipRecords = new List<PRM_IPAMembership_Attributes__c>();
    public String csvData = 'RecordTypeId, PRM_Account_Id__c, PRM_Branded_Point_earning_excl_Dt__c, PRM_Branded_Point_earning_excl_Ind__c, PRM_Component_Point_earning_excl_Dt__c, PRM_Component_Point_earning_excl_Ind__c, PRM_ODM_whiteboxPointEarning_excl_Dt__c, PRM_ODM_whiteboxPointEarning_excl_Ind__c, PRM_Point_Status_Dt__c, PRM_Point_Status_Reason_Txt__c, PRM_Point_Status_Txt__c, PRM_Points_Not_Eligible_Dt__c, PRM_Points_Not_Eligible_Ind__c, PRM_Points_Not_Eligible_Reason_Txt__c, PRM_Points_Opt_in_Dt__c, PRM_Points_Opt_in_Ind__c, PRM_Registration_Source_Txt__c\n';
    
    public List<Core_Log_Entry__c> errorLogs = new List<Core_Log_Entry__c>();
    public Database.QueryLocator start(Database.BatchableContext bc) {   
        String query;
        String opidRecType='Partner Account Group';
        //string prid ='0012i00000ELXojAAH';
		query='Select id from Account where id in (Select PRM_Account_Id__c from PRM_AccountchannelMembership__c where PRM_Status_Nm__c =\'Approved\') and id not in (Select PRM_Account_Id__c from PRM_IPAMembership_Attributes__c ) and Core_Deactivated__c =false and RecordType.name in (\'Partner Account Group\') limit 10000';// and id=:prid';
        return Database.getQueryLocator(query);
	}
	
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        Set<Id> accountIds = new Set<Id>();
        
        Map<Id,Set<PRM_Profile_Responses__c>> accountToResponsesMap = new Map<id,Set<PRM_Profile_Responses__c>>();
        List<String> questionCodesList = new List<String>{'PRM_Opt_In','PRM_Point_Not_Eligible','PRM_Status','PRM_Status_date','IPA_Registration_Source','PRM_ODM_Whitebox_Point','PRM_Branded_Point','PRM_Component_point'};
        if(scope!=null && !scope.isEmpty()){
            for(Account acc: scope){
                accountIds.add(acc.Id);
            }
        }
        System.debug('@NJ accountIds'+accountIds);
        //Get the profile response records for above accounts
        List<PRM_Profile_Responses__c> responses = [SELECT PRM_Account_Id__c, PRM_Account_Id__r.RecordType.Name, PRM_Account_Id__r.Core_IPA_Partner_Role__c, PRM_Response_Txt__c, PRM_Profile_Questions_Id__r.PRM_Question_Cd__c, 
                                            PRM_Reason_Text__c FROM PRM_Profile_Responses__c WHERE PRM_Account_Id__c IN :accountIds and PRM_Profile_Questions_Id__r.PRM_Question_Cd__c in: questionCodesList and PRM_InActive_Ind__c=false order by LastModifieddate desc];
        // Group responses by account ID
        if(responses!=null && !responses.isEmpty()){
            for (PRM_Profile_Responses__c response : responses) {
                if (!accountToResponsesMap.containsKey(response.PRM_Account_Id__c)) {
                    accountToResponsesMap.put(response.PRM_Account_Id__c, new Set<PRM_Profile_Responses__c>{response});
                }
                accountToResponsesMap.get(response.PRM_Account_Id__c).add(response);
            }
        }
        System.debug('@NJ accountToResponsesMap'+accountToResponsesMap);
        if(accountToResponsesMap!=null && !accountToResponsesMap.isEmpty()){
            System.debug('@NJ accountToResponsesMap.keyset()'+accountToResponsesMap.keyset());
            Pattern p = Pattern.compile('[a-zA-Z]');
            for(Id acc:accountToResponsesMap.keyset()){
                Boolean isManufacturer = false;
                PRM_IPAMembership_Attributes__c membershipRecord = new PRM_IPAMembership_Attributes__c();
                membershipRecord.PRM_Account_Id__c = acc;
                membershipRecord.PRM_Inactive_Ind__c = false; // ✅ REQUIRED
                
                for (PRM_Profile_Responses__c response : accountToResponsesMap.get(acc)) {
                    Date parsedDate = null;
                    //Assign record type 
                    if(response.PRM_Account_Id__r.RecordType.Name=='Partner Account Group'){
                        membershipRecord.RecordTypeId=prOPIDRecTypeId;
                    }	
                    else if(response.PRM_Account_Id__r.RecordType.Name=='Intel Account'){
                        membershipRecord.RecordTypeId = prLocRecTypeId;
                    }
                    String questionCode = response.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c;
                    String responseText = response.PRM_Response_Txt__c;
                    String reasonText = response.PRM_Reason_Text__c;

                    if(responseText!=null && !String.isBlank(responseText)){
                        //if response text is a date then correct format
                        if (responseText.contains('-')) {
                            // Handle yyyy-MM-dd format
                            parsedDate = Date.valueOf(responseText);
                        } else if (responseText.contains('/')) {
                            // Handle MM/dd/yyyy format
                            List<String> dateParts = responseText.split('/');
                            if (dateParts.size() == 3) {
                                Integer month = Integer.valueOf(dateParts[0]);
                                Integer day = Integer.valueOf(dateParts[1]);
                                Integer year = Integer.valueOf(dateParts[2]);
                                // Validate month, day, and year
                                if (month > 0 && month <= 12 && day > 0 && day <= 31 && year > 0) {
                                    parsedDate = Date.newInstance(year, month, day);
                                }
                            }
                        }

                        if(response.PRM_Account_Id__r.Core_IPA_Partner_Role__c=='Manufacturer'){
                            membershipRecord.PRM_Points_Opt_in_Ind__c = TRUE;
                            membershipRecord.PRM_Points_Opt_in_Dt__c = system.today();
                            membershipRecord.PRM_Point_Status_Txt__c='Active';
                            membershipRecord.PRM_Point_Status_Dt__c=system.today();
                            membershipRecord.PRM_Point_Status_Reason_Txt__c='Role Eligible for points';
                        }else{
                            if(questionCode=='PRM_Opt_In'){    
                                if (parsedDate != null) {
                                    membershipRecord.PRM_Points_Opt_in_Dt__c = parsedDate;
                                    membershipRecord.PRM_Points_Opt_in_Ind__c =true;
                                }else if (responseText=='TRUE'){
                                    membershipRecord.PRM_Points_Opt_in_Dt__c = system.today();
                                    membershipRecord.PRM_Points_Opt_in_Ind__c = true;
                                } else if(responseText == 'FALSE'){
                                    membershipRecord.PRM_Points_Opt_in_Dt__c = null;
                                    membershipRecord.PRM_Points_Opt_in_Ind__c = false;
                                }                  
                            }else if(questionCode=='PRM_Point_Not_Eligible'){
                                if(parsedDate != null) {
                                    membershipRecord.PRM_Points_Not_Eligible_Dt__c = parsedDate;
                                    membershipRecord.PRM_Points_Not_Eligible_Ind__c =true;
                                }else if (responseText=='TRUE'){
                                    membershipRecord.PRM_Points_Not_Eligible_Dt__c = system.today();
                                    membershipRecord.PRM_Points_Not_Eligible_Ind__c =true;
                                }else if(responseText == 'FALSE'){
                                    membershipRecord.PRM_Points_Not_Eligible_Dt__c = null;
                                    membershipRecord.PRM_Points_Not_Eligible_Ind__c =false;
                                }
                                membershipRecord.PRM_Points_Not_Eligible_Reason_Txt__c = reasonText;
                            }else if(questionCode=='PRM_Status'){//check negative scenario
                                membershipRecord.PRM_Point_Status_Txt__c = responseText;
                                membershipRecord.PRM_Point_Status_Reason_Txt__c = reasonText;  
                            }else if(questionCode=='PRM_Status_date'){
                                if (parsedDate != null) {
                                    membershipRecord.PRM_Point_Status_Dt__c = parsedDate;
                                }
                            }
                        }if(questionCode=='IPA_Registration_Source'){
                            membershipRecord.PRM_Registration_Source_Txt__c = responseText;
                        }else if(questionCode=='PRM_ODM_Whitebox_Point'){
                            if (parsedDate != null) {
                                membershipRecord.PRM_ODM_whiteboxPointEarning_excl_Dt__c = parsedDate;
                                membershipRecord.PRM_ODM_whiteboxPointEarning_excl_Ind__c = true;
                            }
                            else if (responseText=='TRUE'){
                                membershipRecord.PRM_ODM_whiteboxPointEarning_excl_Dt__c = System.today();
                                membershipRecord.PRM_ODM_whiteboxPointEarning_excl_Ind__c = true;
                            }  
                            else if (responseText=='FALSE'){
                                membershipRecord.PRM_ODM_whiteboxPointEarning_excl_Dt__c = null;
                                membershipRecord.PRM_ODM_whiteboxPointEarning_excl_Ind__c = false;
                            }           
                        }else if(questionCode=='PRM_Branded_Point'){
                            if (parsedDate != null) {
                                membershipRecord.PRM_Branded_Point_earning_excl_Dt__c = parsedDate;
                                membershipRecord.PRM_Branded_Point_earning_excl_Ind__c = true;
                            }else if (responseText =='TRUE'){   
                                membershipRecord.PRM_Branded_Point_earning_excl_Dt__c = system.today();
                                membershipRecord.PRM_Branded_Point_earning_excl_Ind__c = true;
                            }  
                            else if (responseText =='false'){   
                                membershipRecord.PRM_Branded_Point_earning_excl_Dt__c = null;
                                membershipRecord.PRM_Branded_Point_earning_excl_Ind__c = false;
                            }                          
                        }else if(questionCode=='PRM_Component_point'){
                            if (parsedDate != null) {
                                membershipRecord.PRM_Component_Point_earning_excl_Dt__c =parsedDate;
                                membershipRecord.PRM_Component_Point_earning_excl_Ind__c = true;
                            }else if (responseText =='TRUE'){ 
                                membershipRecord.PRM_Component_Point_earning_excl_Dt__c = system.today();
                                membershipRecord.PRM_Component_Point_earning_excl_Ind__c = true;
                            }  
                            else if (responseText =='TRUE'){ 
                                membershipRecord.PRM_Component_Point_earning_excl_Dt__c = null;
                                membershipRecord.PRM_Component_Point_earning_excl_Ind__c = false;
                            }     
                        }            
                    }else{
                        if(questionCode=='IPA_Registration_Source'){
                            membershipRecord.PRM_Registration_Source_Txt__c = 'Web';
                        }
                    }
                }
                membershipRecords.add(membershipRecord);
            }
        }
       
        
    }
    public void finish(Database.BatchableContext bc){

        if(membershipRecords!=null && !membershipRecords.isEmpty()){
            for(PRM_IPAMembership_Attributes__c membershipRecord:membershipRecords){
                csvData+=membershipRecord.RecordTypeId+','+membershipRecord.PRM_Account_Id__c+','+membershipRecord.PRM_Branded_Point_earning_excl_Dt__c+','+membershipRecord.PRM_Branded_Point_earning_excl_Ind__c+','+membershipRecord.PRM_Component_Point_earning_excl_Dt__c+','+membershipRecord.PRM_Component_Point_earning_excl_Ind__c+','+membershipRecord.PRM_ODM_whiteboxPointEarning_excl_Dt__c+','+membershipRecord.PRM_ODM_whiteboxPointEarning_excl_Ind__c+','+membershipRecord.PRM_Point_Status_Dt__c+','+membershipRecord.PRM_Point_Status_Reason_Txt__c+','+membershipRecord.PRM_Point_Status_Txt__c+','+membershipRecord.PRM_Points_Not_Eligible_Dt__c+','+membershipRecord.PRM_Points_Not_Eligible_Ind__c+','+membershipRecord.PRM_Points_Not_Eligible_Reason_Txt__c+','+membershipRecord.PRM_Points_Opt_in_Dt__c+','+membershipRecord.PRM_Points_Opt_in_Ind__c+','+membershipRecord.PRM_Registration_Source_Txt__c+'\n';
            }
        }

        Blob csvBlob = Blob.valueOf(csvData);
        Attachment attachment = new Attachment();
        attachment.Name = 'IPAMembershipInfo.csv';
        attachment.Body = csvBlob;
        attachment.ParentId = '001Dw00002082IuIAI';
        if(!Test.isRunningTest()){
            insert attachment;
        }

    }
}