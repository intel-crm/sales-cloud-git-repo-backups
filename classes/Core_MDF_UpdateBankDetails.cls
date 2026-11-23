/****************************************************************************************************************************************
* Class Name  : Core_MDF_UpdateBankDetails 
* Version     : 1.0 
* Created Date: 11-02-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Varun Kumar                   11-02-2018                    Created Core_MDF_UpdateBankDetails class to update bank details based on the supplier number
*****************************************************************************************************************************************/

public with sharing class Core_MDF_UpdateBankDetails{
    
    /*****************************************************************************************************************************************
    Method Name:                                             updateBankRecords
    @return    :                                               
    @parameters:                                             inboundMap
    Description:                                             US182834 - Actual creation of the Bank
    Added By   :                                             Varun Kumar  -  11-02-2018
    Modified By:                  Date:                      Changes: 
    *****************************************************************************************************************************************/
    public static void updateBankRecords(Map<Id,Core_Integration_Inbound_Message__c> inboundMap){
        if (TriggerHandler.isActive('Core_MDF_UpdateBankRecordsFromIIM')) {
            List<Core_MDF_BankJSONParser> jsonParsedList = new List<Core_MDF_BankJSONParser>();
            Map<Id, List<Core_MDF_BankJSONParser>> abc = new Map<Id, List<Core_MDF_BankJSONParser>>();
            List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();
            Map<String, Core_MDF_Bank__c> supplierIdBankMap = new Map<String, Core_MDF_Bank__c>();
            List<Core_MDF_Bank__c> bankListToBeUpdated = new List<Core_MDF_Bank__c>();
            Map<String, Core_MDF_Bank__c> supplierIdBankMapToBeInserted = new Map<String, Core_MDF_Bank__c>();
            Integer errorCnt=0;
            String msgId='';
            Map<String,Integer> updateStatusMap=new Map<String,Integer>();
            if(inboundMap.size() > 0){
                for(Core_Integration_Inbound_Message__c ciim : inboundMap.values()){
                    String payLoad = ciim.Core_Payload__c;
                    msgId = ciim.Id;
                    String ignoreNull = payLoad.replaceAll(':null', ':""');
                    ignoreNull = ignoreNull.replaceAll(':Null', ':""');
                    ignoreNull = ignoreNull.replaceAll(':NULL', ':""');
                    try{
                        //jsonParsedList.addAll(Core_MDF_BankJSONParser.parse(ignoreNull));
                        for(Core_MDF_BankJSONParser jsonParsed : Core_MDF_BankJSONParser.parse(ignoreNull)){
                            Core_MDF_Bank__c bankRecord = new Core_MDF_Bank__c();
                            bankRecord = parseBank(jsonParsed, ciim.Id);
                            supplierIdBankMap.put(bankRecord.Core_MDF_Supplier_Number__c, bankRecord);
                        }
                    }catch(Exception e)
                    {
                        errorCnt++; //To get the count when the exception is thrown
                        String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e); 
                        logErrorinLogObjectWithReason(errorDetails,Label.Core_MDF_OriginName);
                    }
                    
                    updateStatusMap.put(msgId,errorCnt);
                }
            }
            try{
                
                
                for(Core_MDF_Bank__c bankRecord : [SELECT Id, Name, Core_MDF_Bank_Beneficiary_Name__c,
                                                        Core_MDF_Swift_Code__c, Core_MDF_DUNS__c, 
                                                        Core_MDF_Routing_Number__c, Core_MDF_ESD_Hold_Indicator__c, 
                                                        Core_MDF_Intermediary_Indicator__c, Core_MDF_Supplier_Number__c,
                                                        Core_MDF_Supplier_Name__c,Core_MDF_Bank_Location__c, Core_MDF_ESD_Update__c
                                                FROM Core_MDF_Bank__c
                                                WHERE Core_MDF_Supplier_Number__c IN :supplierIdBankMap.keySet()]){
                    Core_MDF_Bank__c bankRec = supplierIdBankMap.get(bankRecord.Core_MDF_Supplier_Number__c);
                    if(bankRec != NULL && 
                      (bankRecord.Name != bankRec.Name ||
                      bankRecord.Core_MDF_Bank_Beneficiary_Name__c != bankRec.Core_MDF_Bank_Beneficiary_Name__c ||
                      bankRecord.Core_MDF_Swift_Code__c != bankRec.Core_MDF_Swift_Code__c ||
                      bankRecord.Core_MDF_DUNS__c != bankRec.Core_MDF_DUNS__c ||
                      bankRecord.Core_MDF_Routing_Number__c != bankRec.Core_MDF_Routing_Number__c ||
                      bankRecord.Core_MDF_Intermediary_Indicator__c != bankRec.Core_MDF_Intermediary_Indicator__c ||
                      bankRecord.Core_MDF_ESD_Hold_Indicator__c != bankRec.Core_MDF_ESD_Hold_Indicator__c ||
                      bankRecord.Core_MDF_Bank_Location__c != bankRec.Core_MDF_Bank_Location__c ||
                       //Adding supplier name
                      bankRecord.Core_MDF_Supplier_Name__c!=bankRec.Core_MDF_Supplier_Name__c)){
                        bankRec.Id = bankRecord.Id;
                        bankListToBeUpdated.add(bankRec);
                        supplierIdBankMapToBeInserted.put(bankRecord.Core_MDF_Supplier_Number__c,bankRec);
                    }
                }
                supplierIdBankMap = NULL;
                if(supplierIdBankMapToBeInserted.size() > 0){
                    //Database.SaveResult[] srList = Database.update(supplierIdBankMapToBeInserted.values(), false); 
                    Database.SaveResult[] srList = Database.update(bankListToBeUpdated, false);
                    String failedBanksString = '';
                    // Iterate through each returned result
                    for(Integer i=0; i < srList.size(); i++) {
                        if(!srList.get(i).isSuccess()) {Database.Error errors =  srList.get(i).getErrors().get(0);failedBanksString += bankListToBeUpdated[i].Id + ' -> ' + errors.getMessage() + 'Fields: ' + errors.getFields() + ', ';
                        }
                    }
                    
                    failedBanksString = failedBanksString.endsWith(', ') ? failedBanksString.substringBeforeLast(', ') : failedBanksString;
                    
                    if(failedBanksString.length() > 0){
                        String errorDetails = 'Class & Method Name = Core_MDF_UpdateBankDetails -> updateBankRecords;\n' +
                                              'Exception Message = Failed Bank Ids: ' + failedBanksString + ';\n' +
                                              'LineNumber = 112' + ';\n' +
                                              'Logged in user = ' + UserInfo.getName();
                        logErrorinLogObjectWithReason(errorDetails,Label.Core_MDF_OriginName);
                    }
                }
            }
            catch(Exception e){errorCnt++;String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e); logErrorinLogObjectWithReason(errorDetails,Label.Core_MDF_OriginName);updateStatusMap.put(msgId,errorCnt);}
            finally
            {
                List<Core_Integration_Inbound_Message__c> ciimList = new List<Core_Integration_Inbound_Message__c>();
                for(Core_Integration_Inbound_Message__c ciim :[SELECT Id,Core_Processing_Status__c FROM 
                                                                 Core_Integration_Inbound_Message__c WHERE Id IN :updateStatusMap.keySet()]){
                                                                     
                    errorCnt=updateStatusMap.get(ciim.Id);
                                                                                    
                    if(errorCnt==0 && 'Pending'==ciim.Core_Processing_Status__c)
                    {
                        ciim.Core_Processing_Status__c='Successful';
                    }
                    else
                    {
                        ciim.Core_Processing_Status__c='Failed';
                    }
                    ciimList.add(ciim);
                }
                if(ciimList.size() > 0){
                    update ciimList;
                }
            }
        }
    } 
    
    /***************************************************************************************************** 
    Method Name:        logErrorinLogObjectWithReason
    @return  :          void
    @parameters:        errorMessage - This will contain the Exception that is caught in class.
    strReason - This will contain reasons for the exception.
    Description:        Whenever an exception is passed as an argument, it will call the getErrorDetails method and
    pass the string returned to create the Log Entry record through the logErrorinLogObject method.
    Added By:           Accenture - SB - 09/14/2018
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static void logErrorinLogObjectWithReason(string errorMessage,string strReason)
    {
        String subject = Label.Core_MDF_CCP_Support_Email_Subject + ' ' +  strReason + ' ' + Label.CCP_Support_Email_Subject_Part2;
        Map<String, String> coreLogMap = new Map<String, String>();
        coreLogMap.put('Core_Details__c', errorMessage);
        coreLogMap.put('Core_Message__c', subject);
        coreLogMap.put('Core_Origin__c', strReason);
        coreLogMap.put('Core_Project__c',Label.Core_MDF_Program_Name);
        coreLogMap.put('Core_Scope__c',strReason);
        coreLogMap.put('Core_Severity__c', 'Normal');
        coreLogMap.put('Core_Support_Email__c', Label.Core_MDF_CCP_Support_Email);
        coreLogMap.put('Core_Support_Link__c', Label.Core_MDF_CCP_Support_Link);
        coreLogMap.put('Core_Tags__c', strReason + '\t' + 'Co-Marketing') ;
        String errorText = Core_MDF_CCP_UtilityClass.createLogEntry(coreLogMap);
    }

    /***************************************************************************************************** 
    Method Name:        logErrorinLogObjectWithReason
    @return  :          void
    @parameters:        errorMessage - This will contain the Exception that is caught in class.
    strReason - This will contain reasons for the exception.
    Description:        Whenever an exception is passed as an argument, it will call the getErrorDetails method and
    pass the string returned to create the Log Entry record through the logErrorinLogObject method.
    Added By:           Accenture - SB - 09/14/2018
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    private static Core_MDF_Bank__c parseBank(Core_MDF_BankJSONParser jsonParsed, Id ciimId){
        Core_MDF_Bank__c bankRecord = new Core_MDF_Bank__c();
        bankRecord.Name = jsonParsed.bnk_nm.trim();
        bankRecord.Core_MDF_Bank_Beneficiary_Name__c = jsonParsed.bnfcy_nm.trim();
        bankRecord.Core_MDF_Swift_Code__c = jsonParsed.swift_cd.trim();
        bankRecord.Core_MDF_DUNS__c = jsonParsed.DUNS_NBR.trim();
        bankRecord.Core_MDF_Routing_Number__c = jsonParsed.bnk_nbr.trim();
        if(jsonParsed.SUPPL_HLD_PMT_IND.trim() == 'Y'){
            bankRecord.Core_MDF_ESD_Hold_Indicator__c = true;
        } else if(jsonParsed.SUPPL_HLD_PMT_IND.trim() == 'N'){
            bankRecord.Core_MDF_ESD_Hold_Indicator__c = false;
        }
        bankRecord.Core_MDF_Intermediary_Indicator__c = jsonParsed.intrmd_bank_ind.trim();
        bankRecord.Core_MDF_Supplier_Number__c = jsonParsed.ap_vndr_nbr.trim();
        bankRecord.Core_MDF_Bank_Location__c = jsonParsed.ctry_cd.trim();
        bankRecord.Core_MDF_ESD_Update__c = true;
        //Adding the IIM Id
        bankRecord.Core_MDF_IIM_Name_txt__c = ciimId;
        //Adding supplier name
        bankRecord.Core_MDF_Supplier_Name__c=jsonParsed.suppl_nm.trim();
        return bankRecord;
    }
}