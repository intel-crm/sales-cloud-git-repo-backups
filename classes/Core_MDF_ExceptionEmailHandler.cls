/****************************************************************************************************************************************
* Class Name        : Core_MDF_ExceptionEmailHandler
* Created Date      : 24/4/2023
* Modification Log
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture Hemapriyadharshini         24/4/2023         To send email to Exception Reviewer for IPA based on IUPGM users
*****************************************************************************************************************************************/
public without sharing class Core_MDF_ExceptionEmailHandler{
private static string EXCEPTION_PENDING_REVIEW_STATUS = 'Pending Review'; 
public static void sendEmailToExceptionReviewer(List<Core_MDF_Exception__c> excpList){
        try{
            List<Core_MDF_Exception__c> expPendingReviewList = new List<Core_MDF_Exception__c>();
            for(Core_MDF_Exception__c excp : excpList){ 
                if(excp.Core_MDF_Program_nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType') 
                                        && excp.Core_MDF_Exception_Status_nm__c == EXCEPTION_PENDING_REVIEW_STATUS){
                       expPendingReviewList.add(excp);  
                   }
            }
            List<String> hostGeoList = new List<String>();
            List<String> budgetTypeList = new List<String>();
            List<String> accountIdList = new List<String>();
            // Highlight: Unused Local Variable - 14285 - Indira 
            // List<String> geoList = new List<String>();
            Map<String, set<Id>> iupgmGeoUserIdsMap = new Map<String, set<Id>>();
            Map<String, set<Id>> iupgmGeoBudgetUserIdsMap  = new Map<String, set<Id>>();
            String iupgmGeoKey ='';
            String geo='';
            String role= '';
            String iupgmGeoBudgetKey ='';
            // Highlight: Unused Local Variable - 14285 - Indira
            // String exceptionGeoKey ='';
            // String exceptionBudgetKey ='';
            
            Boolean sendEmailOnce = true;
            String region='';
            String program='';
            // Highlight: Unused Local Variable - 14285 - Indira
            // Boolean allIUPGMAccountCheck = false;
            string objName = System.Label.Core_MDF_ObjectName;
            // Highlight: Unused Local Variable - 14285 - Indira
            // List<Id> userIds = new List<Id>();
            IUPGMInputWrapper iupgmInputs = new IUPGMInputWrapper();
            for(Core_MDF_Exception__c excp : expPendingReviewList){
                region = (String.isNotBlank(excp.Core_MDF_HostRegion_txt__c)) ? excp.Core_MDF_HostRegion_txt__c : excp.Core_MDF_Region_txt__c;
                accountIdList.add(excp.Core_MDF_Account_id__c);
                program =  Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Prg_Name');
                hostGeoList.add(excp.Core_MDF_HostRegion_txt__c);
                budgetTypeList.add(excp.Core_MDF_Budget_Type_nm__c);
                geo = region;
                role = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Exception_Reviewer_Role');
            }
            iupgmInputs.accountId = accountIdList;
            iupgmInputs.budgetType = budgetTypeList;
            iupgmInputs.geo = geo;
            iupgmInputs.program = program;
            iupgmInputs.hostGeo=hostGeoList; 
            iupgmInputs.objectName =objName;
            iupgmInputs.role = role;
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = getIUPGMRecords(iupgmInputs);
            if(iupgmList != null){
                for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmList){
                    String prgAcc = (iupgm.Core_MDF_Account_id__c != null) ? iupgm.Core_MDF_Program_nm__c+iupgm.Core_MDF_Account_id__c : iupgm.Core_MDF_Program_nm__c;
                    String prgAccRegBudType = (iupgm.Core_MDF_Account_id__c != null) ? iupgm.Core_MDF_Program_nm__c+iupgm.Core_MDF_Account_id__c : iupgm.Core_MDF_Program_nm__c;
            
                    for(string regionIupgm :iupgm.Core_MDF_Region_cd__c.split(';')){
                        // US - TWC702-14285: Flatten nested IFs (no logic change)
                        // Handle case when user has all budget type access
                        if(iupgm.Core_MDF_All_Budget_Type_Access_Ind__c && iupgm.Core_MDF_Region_cd__c != null){
            
                                iupgmGeoKey = prgAcc+regionIupgm;
            
                                if(!iupgmGeoUserIdsMap.containsKey(iupgmGeoKey)){
                                    iupgmGeoUserIdsMap.put(iupgmGeoKey,new set<Id>());
                                }
            
                                iupgmGeoUserIdsMap.get(iupgmGeoKey).add(iupgm.Core_MDF_User_id__c);
                            continue; // Skip to next iteration since we handled this case
                        }
                        // US - TWC702-14285: Flatten nested IFs (no logic change)s
                        // Handle case when user doesn't have all budget type access
                        if(!iupgm.Core_MDF_All_Budget_Type_Access_Ind__c && iupgm.Core_MDF_Budget_Type_nm__c != null){
            
                                for(string budgetTypeIupgm :iupgm.Core_MDF_Budget_Type_nm__c.split(';')){
            
                                    iupgmGeoBudgetKey = prgAccRegBudType+regionIupgm+budgetTypeIupgm;
            
                                    if(!iupgmGeoBudgetUserIdsMap.containsKey(iupgmGeoBudgetKey)){
                                        iupgmGeoBudgetUserIdsMap.put(iupgmGeoBudgetKey,new set<Id>());
                                    }
            
                                    iupgmGeoBudgetUserIdsMap.get(iupgmGeoBudgetKey).add(iupgm.Core_MDF_User_id__c);
                            }
                        }
                    }
                }
            }
            // Highlight: Unused Local Variable - 14285 - Indira
           // List<string> regList = new List<String>{region};
                for(Core_MDF_Exception__c exp : expPendingReviewList){
                    set<Id> userIdSet =  new Set<Id>();
                    List<Id> userIdList =  new List<Id>();
            for(string regionExp : region.split(',')){
                if(iupgmGeoUserIdsMap != null){
                    for(String key : iupgmGeoUserIdsMap.keySet()){
                    if((key == (program+exp.Core_MDF_Account_id__c+regionExp)) || (key == (program+exp.Core_MDF_Account_id__c+'WW'))){
                        userIdSet.addAll(iupgmGeoUserIdsMap.get(key));
                    } 
                    else if((key == (program+regionExp)) || (key == (program+'WW'))){
                        userIdSet.addAll(iupgmGeoUserIdsMap.get(key));
                    } 
                }
              }
             if(iupgmGeoBudgetUserIdsMap != null){ 
               for(String key : iupgmGeoBudgetUserIdsMap.keySet()){
                for(string budgetTypeExp :exp.Core_MDF_Budget_Type_nm__c.split(';')){
                        if((key == (program+exp.Core_MDF_Account_id__c+regionExp+budgetTypeExp)) || (key == (program+exp.Core_MDF_Account_id__c+'WW'+budgetTypeExp))){
                            userIdSet.addAll(iupgmGeoBudgetUserIdsMap.get(key));
                        } 
                        else if((key == (program+regionExp+budgetTypeExp)) || (key == (program+'WW'+budgetTypeExp))){
                            userIdSet.addAll(iupgmGeoBudgetUserIdsMap.get(key));
                        } 
                    }          
                }
              }
            }
            if(!userIdSet.isEmpty()){
                userIdList.addAll(userIdSet);
            }
            Map<Id,List<Id>> exceptionUserIdMap = new Map<Id,List<Id>>();
            exceptionUserIdMap.put(exp.Id,userIdList);
            List<Core_MDF_GenericClassToSendMail.MailParams> sendEmailToExptionApprovers = getSendEmailToExceptionApprovers(exceptionUserIdMap);
            
            if(sendEmailToExptionApprovers != NULL && sendEmailToExptionApprovers.size() >0 && sendEmailOnce){
                Core_MDF_GenericClassToSendMail.sendEmailMethod(sendEmailToExptionApprovers); 
                sendEmailOnce = false;
            }
        }
    }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);
                       }
}
public static List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> getIUPGMRecords(IUPGMInputWrapper iupgmInputs){
    List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new list<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
    try{
        string qryStr;
        string program ='';
        string role= '';
        String allAccountsYes = 'Yes';
        String allAccountsNo = 'No';
        List<String> geoStr = new List<String>();
        List<string> accountId = new List<String>();
        // OLD: String geoString=''; (removed - replaced with escapedGeoStr list in secure fix)
        string geoIupgm='';
        
        if(iupgmInputs != null){
            geoIupgm = iupgmInputs.geo;
            accountId =  iupgmInputs.accountId; 
            program = iupgmInputs.program;
            role = iupgmInputs.role;
        } 
        for(string str : geoIupgm.split(',')){
            geoStr.add(str);
        }
            geoStr.add('WW');
            // US - TWC702-14285: Avoid Untrusted/Unescaped Variables in DML Query - BEGIN
            // OLD: geoString ='(\'' + String.join(geoStr, '\', \'') + '\')';
            // OLD: String region = String.escapeSingleQuotes(geoString).replaceAll('\\\\','');
            List<String> escapedGeoStr = new List<String>();
            for(String geoVal : geoStr) {
                escapedGeoStr.add(String.escapeSingleQuotes(geoVal));
            }
            String region = '(\'' + String.join(escapedGeoStr, '\', \'') + '\')';
            // US - TWC702-14285: Avoid Untrusted/Unescaped Variables in DML Query - END

        qryStr = 'SELECT Id, Core_MDF_User_id__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Region_cd__c, '+
            ' Core_MDF_Program_nm__c,Core_MDF_All_Budget_Type_Access_Ind__c,Core_MDF_Region_Sub_Region_nm__c, Core_MDF_Role_nm__c, ' +
            ' Core_MDF_All_Accounts_cd__c, Core_MDF_Account_id__c ' +
            ' FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c'+
            ' WHERE Core_MDF_Program_nm__c =: program ' +
            ' and Core_MDF_Region_cd__c INCLUDES ' + region + 
            ' and Core_MDF_Role_nm__c =: role '+
            ' and Core_MDF_is_User_Active_ind__c = true '+
            ' and Core_MDF_Active_Ind__c = true' +
            ' and Core_MDF_Is_Not_an_Approver_Ind__c = false';
        
        qryStr += ' and (Core_MDF_All_Accounts_cd__c = ' + '\'' + String.escapeSingleQuotes(allAccountsYes) + '\'' +
            ' OR (Core_MDF_All_Accounts_cd__c = ' +  '\'' + String.escapeSingleQuotes(allAccountsNo) + '\'' +
            ' and Core_MDF_Account_id__c =:accountId))';
                   
        iupgmList= Database.Query(qryStr);
        return iupgmList;
    }
    catch(Exception e){
        Core_MDF_CCP_UtilityClass.logError(e);
    }
    return null;
}

public static List<Core_MDF_GenericClassToSendMail.MailParams> getSendEmailToExceptionApprovers(Map<Id,List<Id>> exceptionUserIdMap){
    List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();
    
    if(!exceptionUserIdMap.isEmpty()){
        for(Id excpUserId : exceptionUserIdMap.keySet()){
            Core_MDF_GenericClassToSendMail.MailParams sendEmailToExptionApprovers = new Core_MDF_GenericClassToSendMail.MailParams();
            sendEmailToExptionApprovers.recordId = excpUserId;
            sendEmailToExptionApprovers.templateName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Notify_Exception_Approvers');
            sendEmailToExptionApprovers.userIdList = exceptionUserIdMap.get(excpUserId);
            sendEmailToExptionApprovers.sendDiff = false;
            inputList.add(sendEmailToExptionApprovers);
        }
    }
    return inputList;
}
public class IUPGMInputWrapper{
    public string objectName{get;set;} 
    public List<string> accountId{get;set;}
    public List<string> budgetType{get;set;}
    public string geo{get;set;} 
    public string role{get;set;} 
    public string program{get;set;}
    public List<string> hostGeo{get;set;} 
}

}