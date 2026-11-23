/****************************************************************************************************************************************
* Class Name        : Core_MDF_CloseActivity_Notification
* Test Class Name   :
* Created Date      : 4/28/2022
* Modification Log
* Created By        : Hemapriyadharshini.k
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture-Weezer         4/24/2022         Email notification for closed activities - Calling from batch class
*****************************************************************************************************************************************/
public class Core_MDF_Email_Notification { 
    
    public static void autoClosureNotification(List<String> pfrIDs)
    {   
        Blob pfrBlob;
        List<Id> pfrId = new List<Id>();
        string pfrListString='Activity Id,Activity Name, Activity Number, Program, Budget Type\n'; 
        //string emailTemplateName ='Core_MDF_CloseActivty_Batch';
        string pfrEmailTemplate ='Core_MDF_Close_Activity_Auto';
        if(pfrIDs != null && !pfrIDs.isEmpty())
        {
            Messaging.SingleEmailMessage pfrEmail = new  Messaging.SingleEmailMessage();
            Messaging.EmailFileAttachment pfrEmailCsvAttachment = new Messaging.EmailFileAttachment();
            
            // Quering Email Temaplate
            EmailTemplate emailTemplate = [SELECT Id,Body,Subject,HtmlValue, Name FROM EmailTemplate WHERE Name =: pfrEmailTemplate]; 
            
            // replacing Email Body Content adding count of records updated
            String htmlBody = emailTemplate.HtmlValue;
            htmlBody = htmlBody.replace('##Number', String.valueOf(pfrIDs.size()));
            htmlBody.stripHtmlTags();
            // replacing Email Subject adding count of records updated
            String subject = emailTemplate.Subject; 
            subject = subject.replace('##Closed', String.valueOf(pfrIDs.size()));
            
            // Quering Updated record values to show in CSV file
            for(PartnerFundRequest pfrLists : [Select Id, Title,Core_MDF_Activity_Number__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Program__c 
                                               from PartnerFundRequest 
                                               Where Id IN:pfrIDs]){
                                                   pfrListString += pfrLists.Id +',' + pfrLists.Title.escapeCsv() +',' + pfrLists.Core_MDF_Activity_Number__c.escapeCsv()  +',' + pfrLists.Core_MDF_Program__c.escapeCsv()  + ',' +pfrLists.Core_MDF_Budget_Type_nm__c.escapeCsv() +'\n'; 
                                                   pfrBlob = blob.valueOf(pfrListString);    
                                               }
            system.debug('pfrBlob'+pfrBlob);
            pfrEmailCsvAttachment.setContentType('application/csv');
            pfrEmailCsvAttachment.setBody(pfrBlob);
            pfrEmailCsvAttachment.setFileName('Total Number of Closed Activities '+pfrIDs.size()+' '+'.csv');
            pfrEmail.setFileAttachments(new Messaging.EmailFileAttachment[] {pfrEmailCsvAttachment});
            pfrEmail.setToAddresses(new String[] {'hemapriyadharshinix.karunanithi@intel.com'});
            pfrEmail.setHtmlBody(htmlBody);
            pfrEmail.setSubject(subject);
            //  pfrEmail.setTargetObjectId(UserInfo.getUserId());
            //  pfrEmail.setSaveAsActivity(False);
            system.debug('msg'+pfrEmail);
            if(pfrEmail !=null)
            {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {pfrEmail});
            }  
        }
    }
    @InvocableMethod(label='Approver Email Notification')
    public static void approverEmailNotification(List<Core_MDF_Exception__c> exceptionList){
        system.debug('Coming in-->>');
        string ExpEmailTemplate ='';
        String category = 'Exception Queue';
        String program = 'Intel Partner Alliance';
        List<String> exceptionRole = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Exception_Approvers').split(';');
        List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();
        Map<String, Map<String, List<Id>>> resultMap = new Map<String, Map<String, List<Id>>>();
        List<String> ExceptionGeo = new List<String>();
        List<String> ExceptionGroup = new List<String>();
        List<String> ExceptionGroups = new List<String>();
        Set<Id> userIds = new Set<Id>();
        List<Id> groupMembers = new List<Id>();
        List<Id>IUPGMQueueUserIds = new List<Id>();
        Boolean sendEmailOnce = true;
        String ExceptionGroupStr='';
        
        for(Core_MDF_Exception__c expt : exceptionList){
            ExceptionGeo.add((String.isNotBlank(expt.Core_MDF_Host_Region_nm__c)) ? expt.Core_MDF_Host_Region_nm__c : expt.Core_MDF_Region_txt__c);
        }
        List<Core_MDF_Custom_Label_Configration__mdt> mdtRecList = [SELECT DeveloperName, Core_MDF_Value_Txt__c,Core_MDF_Value2_Txt__c,Core_MDF_Value3_Txt__c,
                                                                    Core_MDF_Value4_Txt__c,Core_MDF_Category_Txt__c, Core_MDF_Org_Specific_Ind__c
                                                                    FROM Core_MDF_Custom_Label_Configration__mdt WHERE Core_MDF_Category_Txt__c =: category
                                                                    AND Core_MDF_Value_Txt__c =: program];
        
        for(Core_MDF_Custom_Label_Configration__mdt clConfig : mdtRecList){
            ExceptionGroup.add(clConfig.Core_MDF_Value3_Txt__c);
        }
        if(!ExceptionGroup.isEmpty()){
            ExceptionGroupStr ='(\'' + String.join(ExceptionGroup, '\', \'') + '\')';
            system.debug('----ExceptionGroupStr'+ExceptionGroupStr);
        }
        if(String.isNotBlank(ExceptionGroupStr)){
            ExceptionGroupStr = String.escapeSingleQuotes(ExceptionGroupStr);
            system.debug('beforeEscape--'+ExceptionGroupStr);
            ExceptionGroupStr = ExceptionGroupStr.replaceAll('\\\\','');
            ExceptionGroups.add(ExceptionGroupStr);
            system.debug('AfEscape--'+ExceptionGroupStr);
        }
        system.debug('AfEscape--'+ExceptionGroups);
        //Quering groupMember
         For(GroupMember GroupId : [Select UserOrGroupId 
                                    From GroupMember 
                                    where Group.DeveloperName IN: ExceptionGroup]){
            groupMembers.add(GroupId.UserOrGroupId);
        }
        system.debug('groupMembers-->'+groupMembers);
        for(Core_MDF_Exception__c expt : exceptionList){
            String region = (String.isNotBlank(expt.Core_MDF_Host_Region_nm__c)) ? expt.Core_MDF_Host_Region_nm__c : expt.Core_MDF_Region_txt__c;
            Map<string,List<Id>> resultsubMap;
            if(expt.Core_MDF_Program_nm__c == 'Core_MDF_Intel_Partner_Alliance'){
                resultMap = getIupgmRecordsException(program,expt.Core_MDF_Account_id__c,region,exceptionRole);
            }
            system.debug('resultMap-->'+resultMap);
          
            if(resultMap != null){
                String allAccountNOKeyPMG = program + region + 'Core_MDF_CCP_Internal_IPA_Program_Adm' + expt.Core_MDF_Account_id__c;
                String allAccountNOKeyWWPMG = program + 'WW'+ 'Core_MDF_CCP_Internal_IPA_Program_Adm' + expt.Core_MDF_Account_id__c;
                String allAccountYesKeyPMG = program + region + 'Core_MDF_CCP_Internal_IPA_Program_Adm' +'null';
                String allAccountYesKeyWWPMG = program + 'WW' + 'Core_MDF_CCP_Internal_IPA_Program_Adm' +'null';
                String allAccountNOKeyBL = program + region + 'Core_MDF_CCP_Internal_IPA_Budget_Loader' + expt.Core_MDF_Account_id__c;
                String allAccountNOKeyWWBL= program + 'WW'+ 'Core_MDF_CCP_Internal_IPA_Budget_Loader' + expt.Core_MDF_Account_id__c;
                String allAccountYesKeyBL = program + region + 'Core_MDF_CCP_Internal_IPA_Budget_Loader' +'null';
                String allAccountYesKeyWWBL = program + 'WW' + 'Core_MDF_CCP_Internal_IPA_Budget_Loader' +'null';
                if(resultMap.containsKey('allAccountsYesOrNo')){
                    resultsubMap = resultMap.get('allAccountsYesOrNo'); 
                    for(String key :resultsubMap.keySet()){
                        system.debug('resultsubMap key-->'+key);
                        if(key == allAccountNOKeyPMG || key == allAccountNOKeyWWPMG ||
                           key == allAccountYesKeyPMG || key == allAccountYesKeyWWPMG || 
                           key == allAccountNOKeyBL || key == allAccountNOKeyWWBL ||
                           key == allAccountYesKeyBL || key == allAccountYesKeyWWBL){
                               userIds.addAll(resultsubMap.get(Key));}}
                }else if(resultMap.containsKey('allAccountsYes')){
                    resultsubMap = resultMap.get('allAccountsYes');
                    for(String key :resultsubMap.keySet()){
                        if(key == allAccountYesKeyPMG || key == allAccountYesKeyWWPMG ||
                          key == allAccountYesKeyBL || key == allAccountYesKeyWWBL){
                            userIds.addAll(resultsubMap.get(Key));}}
                }else if(resultMap.containsKey('allAccountsNO')){
                    resultsubMap = resultMap.get('allAccountsNO');
                    for(String key :resultsubMap.keySet()){
                        if(key == allAccountNOKeyPMG || key == allAccountNOKeyWWPMG ||
                          key == allAccountNOKeyBL || key == allAccountNOKeyWWBL){
                            userIds.addAll(resultsubMap.get(Key));}}}}
            system.debug('userIds-->'+userIds);
            
            for(Id userId : userIds){
                if(groupMembers.contains(userId)){
                    IUPGMQueueUserIds.add(userId);}
            }
            system.debug('IUPGMQueueUserIds-->'+IUPGMQueueUserIds);
            
            if(IUPGMQueueUserIds != NULL && !IUPGMQueueUserIds.isEmpty()){ 
                 if(userIds != NULL && !userIds.isEmpty()){
                    Core_MDF_GenericClassToSendMail.MailParams sendEmailToExptionApprovers = new Core_MDF_GenericClassToSendMail.MailParams();
                    sendEmailToExptionApprovers.recordId = expt.Id;
                    sendEmailToExptionApprovers.templateName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Notify_Exception_Approvers');
                    sendEmailToExptionApprovers.userIdList = IUPGMQueueUserIds;
                    sendEmailToExptionApprovers.sendDiff = false;
                    inputList.add(sendEmailToExptionApprovers);
                    system.debug('inputList-->'+inputList);
                }
            }
        }
        if(inputList != NULL && inputList.size() >0 && sendEmailOnce){
            Core_MDF_GenericClassToSendMail.sendEmailMethod(inputList); 
            sendEmailOnce = false;
        }
    }
    public static Map<String, Map<String, List<Id>>> getIupgmRecordsException(String expProgram,Id ExpAccountId, String expGeo, List<String> exceptionRole) {     
        
        system.debug('expProgram-->'+expProgram);
        system.debug('ExpAccountId-->'+ExpAccountId);
        system.debug('expGeo-->'+expGeo);
        system.debug('exceptionRole-->'+exceptionRole);  
        List<String> program = new List<String>();     
        
        Map<String,string> roleCheckforAccountAccessMap = new Map<String,string>();
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        String category = 'Exception Roles';
        String dummyRole ='Core_MDF_CCP_Internal_IPA_Program_Adm';     
        String dummyRole1 ='Core_MDF_CCP_Internal_IPA_Budget_Loader';
        List<Core_MDF_Custom_Label_Configration__mdt> mdtRecList = [SELECT DeveloperName, Core_MDF_Value_Txt__c,Core_MDF_Value2_Txt__c,Core_MDF_Value3_Txt__c,
                                                                    Core_MDF_Value4_Txt__c,Core_MDF_Category_Txt__c, Core_MDF_Org_Specific_Ind__c
                                                                    FROM Core_MDF_Custom_Label_Configration__mdt WHERE Core_MDF_Category_Txt__c =: 'Exception Roles'
                                                                    AND Core_MDF_Value_Txt__c =: expProgram];
        
        system.debug('mdtRecList-->'+mdtRecList); 
        List<String> values = new List<String>();
        for(Core_MDF_Custom_Label_Configration__mdt mdtRec: mdtRecList){
            roleCheckforAccountAccessMap.put(mdtRec.Core_MDF_Value_Txt__c+mdtRec.Core_MDF_Value2_Txt__c,mdtRec.Core_MDF_Value3_Txt__c);
        }
        
        System.debug('<<roleCheckforAccountAccessMap>>' + roleCheckforAccountAccessMap);
        List<String> geoList = expGeo.split(';');
        system.debug('geoList-->'+geoList);
        Map<String, Map<String, List<Id>>> resultMap = new Map<String, Map<String, List<Id>>>();
        String qryStr;
        String geoStr='';
        String exceptionRoleStr='';
        geoList.add('WW');
        system.debug('----geoList'+geoList);
        if(!geoList.isEmpty()){
            geoStr ='(\'' + String.join(geoList, '\', \'') + '\')';
            system.debug('----geoStr'+geoStr);
        }
        if(String.isNotBlank(geoStr)){
            geoStr = String.escapeSingleQuotes(geoStr);
            system.debug('beforeEscape--'+geoStr);
            geoStr = geoStr.replaceAll('\\\\','');
        }
        if(!exceptionRole.isEmpty()){
            exceptionRoleStr ='(\'' + String.join(exceptionRole, '\', \'') + '\')';
            system.debug('----exceptionRole'+exceptionRoleStr);
        }
         if(String.isNotBlank(exceptionRoleStr)){
            exceptionRoleStr = String.escapeSingleQuotes(exceptionRoleStr);
            system.debug('beforeEscape--'+exceptionRoleStr);
            exceptionRoleStr = exceptionRoleStr.replaceAll('\\\\','');
            system.debug('AfEscape--'+exceptionRoleStr);
        }
        
        try{
            qryStr = 'SELECT Id, Core_MDF_User_id__c,Core_MDF_Region_cd__c, '+
                ' Core_MDF_Program_nm__c, Core_MDF_Role_nm__c, ' +
                ' Core_MDF_All_Accounts_cd__c, Core_MDF_Account_id__c ' +
                ' FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c'+
                ' WHERE Core_MDF_Program_nm__c =: expProgram' +
                ' and Core_MDF_Region_cd__c INCLUDES ' + geoStr +
                ' and (Core_MDF_Role_nm__c =: dummyRole Or Core_MDF_Role_nm__c =: dummyRole1)'+
                ' and Core_MDF_is_User_Active_ind__c = true '+
                ' and Core_MDF_Active_Ind__c = true' +
                ' and Core_MDF_Is_Not_an_Approver_Ind__c = false';
            System.debug('<<qryStr>>' + qryStr);
            iupgmList= Database.Query(qryStr);
            system.debug('iupgmList-->'+iupgmList);
            Map<string,List<Id>> subMap = new Map<string,List<Id>>();
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmObj : iupgmList){
                String key =iupgmObj.Core_MDF_Program_nm__c +iupgmObj.Core_MDF_Role_nm__c;
                system.debug('key-->'+key);
                system.debug('key iupgmObj.Core_MDF_Region_cd__c-->'+iupgmObj.Core_MDF_Region_cd__c);
                if(roleCheckforAccountAccessMap.containsKey(key)){
                    List<String> geoStrList;
                    if(iupgmObj.Core_MDF_Region_cd__c != NULL){
                        System.debug('<<iupgmObj.Core_MDF_Region_cd__c>>' + iupgmObj.Core_MDF_Region_cd__c);
                        geoStrList = iupgmObj.Core_MDF_Region_cd__c.split(';');
                        System.debug('<<geoStrList>>' + geoStrList);
                    }
                    for(String geo: geoStrList){
                        String subMapKey =iupgmObj.Core_MDF_Program_nm__c +geo+iupgmObj.Core_MDF_Role_nm__c+iupgmObj.Core_MDF_Account_id__c;
                        subMap = new Map<string,List<Id>>();
                        if(roleCheckforAccountAccessMap.get(key) == 'allAccountsYesOrNo'){ 
                            if(resultMap.containsKey('allAccountsYesOrNo')){
                                subMap = resultMap.get('allAccountsYesOrNo');
                            }
                            if(!subMap.containsKey(subMapKey)){
                                subMap.put(subMapKey, new List<Id>());
                            }
                            subMap.get(subMapKey).add(iupgmObj.Core_MDF_User_id__c);
                            resultMap.put('allAccountsYesOrNo', subMap);
                            System.debug('<<resultMap>>' + resultMap);
                        }
                        else if(roleCheckforAccountAccessMap.get(key) == 'allAccountsYes' && iupgmObj.Core_MDF_All_Accounts_cd__c=='YES'){
                            if(resultMap.containsKey('allAccountsYes')){
                                subMap = resultMap.get('allAccountsYes');
                            }
                            if(!subMap.containsKey(subMapKey)){
                                subMap.put(subMapKey, new List<Id>());
                            }
                            subMap.get(subMapKey).add(iupgmObj.Core_MDF_User_id__c);
                            resultMap.put('allAccountsYes', subMap);
                        }
                        else if(roleCheckforAccountAccessMap.get(key) == 'allAccountsNo' && iupgmObj.Core_MDF_All_Accounts_cd__c=='NO' && ExpAccountId == iupgmObj.Core_MDF_Account_id__c){
                            if(resultMap.containsKey('allAccountsNo')){
                                subMap = resultMap.get('allAccountsNo');
                            }
                            if(!subMap.containsKey(subMapKey)){
                                subMap.put(subMapKey, new List<Id>());
                            }
                            subMap.get(subMapKey).add(iupgmObj.Core_MDF_User_id__c);
                            resultMap.put('allAccountsNo', subMap);
                        }
                    }
                }
            }
            System.debug('resultMapFinal-->' + resultMap);
        } catch(Exception e){//Core_MDF_CCP_UtilityClass.logError(e);
        }
        return resultMap;
    }
}