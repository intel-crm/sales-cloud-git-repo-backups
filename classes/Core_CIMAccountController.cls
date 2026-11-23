/**************************************************************************************
Apex Class Name:  Core_CIMAccountController
Version     : 1.0 
Created Date: 26 May 2020
Function    : class to update account records from CIM response
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan             05/26/2020              Original Version

*************************************************************************************/
public class Core_CIMAccountController{
    
    
    /*************
    * Method name  : accountUpdate
    * Description  : Update accounts as per the CIM response
    * Return Type  : VOID
    * Parameter    : AccountWrapper, recordid
    ************/
    
    public static void accountUpdate(Core_XMLParserHandler.finalWrapper AccountWrapper, id recordid){
        
        String query = '';
        String CIMId = '';
        String ErrorDesc ='';
        set<id> sfId = new set<id>();
        List<Account> accList = new List<Account>(); 
        Core_XMLParserHandler.finalWrapper fWrp= new Core_XMLParserHandler.finalWrapper();
        fWrp = AccountWrapper;
        Map<String, List<Core_XMLParserHandler.SourceRecord>> srsMap = new map<string, List<Core_XMLParserHandler.SourceRecord>>();
        Map<String, Core_XMLParserHandler.ElectronicAddress> electricAddressMap = new map<string, Core_XMLParserHandler.ElectronicAddress>();
        
        try{
            srsMap = getSourceRecords(fWrp);//source record map
            system.debug('srsmap-->'+srsMap);
            electricAddressMap = getElectronicAddress(fWrp); //electronic address map
            system.debug('electricAddressMap-->'+electricAddressMap);
            sfId = getSfidsFromSrsRec(srsMap); //sfids from sales cloud source records
            system.debug('sfId-->'+sfId);
            
            //getting the list of accounts based on CIM id and Salesforce ids.
            if(fWrp.snpWr != null && fWrp.snpWr.bo != null && fWrp.snpWr.bo.BusinessOrganizationPartyId != null){  
            CIMId  = fWrp.snpWr.bo.BusinessOrganizationPartyId;
                if(!String.isBlank(CIMId)){
                    if(sfId.size() > 0){
                        query = 'select id, Core_Last_MsgId__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from account where Core_CIM_ID__c =: CIMId OR id IN: sfId FOR UPDATE';
                    }
                    else{
                        query = 'select id, Core_Last_MsgId__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from account where Core_CIM_ID__c =: CIMId FOR UPDATE';
                    }
                    system.debug('query-->'+query);
                    accList = database.query(query);
                }
            }
            //TBD Survivor
            List<account> nonSurvivor;
            if(fWrp.headwr.EventType.equalsIgnoreCase(Core_ConstantUtility.HDR_EVTTYPE_MERGE)){
                if(fWrp.mbWr.SurvivorBusinessOrganizationPartyId != null && fWrp.mbWr.NonSurvivorBusinessOrganizationPartyId != null){
                   nonSurvivor = [select id, Core_CIM_ID__c, Core_Last_MsgId__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from account where Core_CIM_ID__c =: fWrp.mbWr.NonSurvivorBusinessOrganizationPartyId FOR UPDATE];
                }
                for(account nonacc : nonSurvivor){
                    nonacc.Core_CIM_ID__c = CIMId;
                }
            }
            
            accList.addAll(nonSurvivor);
            system.debug('accList-->'+accList);
            if(accList.size() > 0 ){
                List<Account> updateAccountList = new List<account>();
                
                for(account a : accList){
                    if(a.Core_Last_MsgId__c != null){
                    if(Integer.valueOf(fWrp.headwr.MsgId) > Integer.valueOf(a.Core_Last_MsgId__c)){
                        if(fWrp.snpWr.pa.GoldenPhysicalAddressInd.equalsIgnoreCase(Core_ConstantUtility.Y_INDICATOR )){
                            
                            //primay address update
                            a.BillingStreet = fWrp.snpWr.pa.PhysicalStreetAddressTxt;
                            a.BillingCity = fWrp.snpWr.pa.CityNm;
                            a.BillingState = fWrp.snpWr.pa.CountrySubdivisionCd;
                            a.BillingPostalCode = fWrp.snpWr.pa.PostalCd;
                            a.BillingCountry = fWrp.snpWr.pa.CountryCd;  
                        }
                        
                        //alternate address update
                        if(fWrp.snpWr.pa.NonLatinDataInd.equalsIgnoreCase(Core_ConstantUtility.Y_INDICATOR )){
                            if(srsMap.get('CIMHUB-LATIN') != null){
                                List<Core_XMLParserHandler.SourceRecord> sr= srsMap.get('CIMHUB-LATIN');
                                if(sr.size()>0){
                                    a.Core_Alt_Address_1__c = sr[0].pa.PhysicalStreetAddressTxt;
                                    a.Core_Alt_Language_City__c = sr[0].pa.CityNm;
                                    a.Core_Alt_Language_State_Province__c = sr[0].pa.CountrySubdivisionCd;
                                    a.Core_Alt_Language_Postal_Code__c = sr[0].pa.PostalCd;
                                    a.Core_Alt_Language_country__c = sr[0].pa.CountryCd;    
                                }
                            }   
                        }
                        
                        //Legal Name update
                        if(fWrp.snpWr.bonm.GoldenNameInd.equalsIgnoreCase(Core_ConstantUtility.Y_INDICATOR )){
                            if(fWrp.snpWr.bonm.BusinessOrganizationNm != null){
                                a.Core_Account_Legal_Name__c = fWrp.snpWr.bonm.BusinessOrganizationNm;
                            }
                        }
                        if(fWrp.snpWr.bonm.NonLatinInd.equalsIgnoreCase(Core_ConstantUtility.Y_INDICATOR )){
                    
                        }
                        
                        //update business id
                        String bId ='';
                        if(srsMap.get('ERPM') != null){
                            List<Core_XMLParserHandler.SourceRecord> sr= srsMap.get('ERPM');
                            for(Core_XMLParserHandler.SourceRecord srERPM: sr){
                                bId += srERPM.sbo.id +','; 
                            }
                            bId  = bId.subString(0,bId.length() - 1);
                            a.Core_Business_Partner_Id__c = bId;
                        }
                        
                        //electric address update
                        if(electricAddressMap.get('FAX') != null){
                            a.fax = electricAddressMap.get('FAX').ElectronicAddressTxt;
                        }
                        if(electricAddressMap.get('PHONE') != null){
                            a.phone = electricAddressMap.get('PHONE').ElectronicAddressTxt;
                        }
                        if(electricAddressMap.get('URL') != null){
                            a.website = electricAddressMap.get('URL').ElectronicAddressTxt;
                        }
                        
                        //messageId udpate.
                        a.Core_Last_MsgId__c = fWrp.headwr.MsgId;
                        
                        //update MAG
                        //system.debug('@@@@MAG'+fWrp.snpWr.botpwl.WatchListTypeCd);
                        if(fWrp.snpWr.botpwl.WatchListTypeCd != null){
                            if(fWrp.snpWr.botpwl.WatchListTypeCd.equalsIgnoreCase(Core_ConstantUtility.SNP_MAG)){
                                
                                a.Core_Military_Aerospace_and_Government__c = true;
                            }
                            else if(fWrp.snpWr.botpwl.WatchListTypeCd.equalsIgnoreCase(Core_ConstantUtility.SNP_ECB) || fWrp.snpWr.botpwl.WatchListTypeCd.equalsIgnoreCase(Core_ConstantUtility.SNP_EC)){
                                
                                a.Core_Export_Compliance_Block_Reason__c = fWrp.snpWr.botpwl.WatchListTypeNm; 
                                a.Core_Export_Compliance_Block__c = true;
                            }
                        }
                        
                        updateAccountList.add(a);
                    }
                    else{
                        ErrorDesc = 'MsgId in XML is less than the MsgId already present in account ';
                    }
                }
                else{
                      ErrorDesc = 'MsgId in null in account record in salesforce';
                    }  
                }
                //updateLogIIM(ErrorDesc,recordid,'Failed',fWrp.headwr.MsgId,CIMId);
                
                system.debug('updateAccountList--> '+updateAccountList);
                if(ErrorDesc ==''){
                    integer count = 0;
                    Database.SaveResult[] srr = database.update(updateAccountList,true);
                    for (Database.SaveResult sr : srr) {
                        if (sr.isSuccess()) {
                            count++;
                        }
                    }
                    if(accList.size() == count){
                        updateLogIIM('Records updated Successfully',recordid,'Successful',fWrp.headwr.MsgId,CIMId);
                    }
                }
                else{
                    updateLogIIM(ErrorDesc,recordid,'Failed',fWrp.headwr.MsgId,CIMId);
                }
            }
            else{// when no accounts are found with that CIM id.
                
                updateLogIIM('no account is found with that CIM ID',recordid,'Failed',fWrp.headwr.MsgId,CIMId);
            }
        
        }
        catch(exception e){
            system.debug(e.getMessage());
            system.debug('Exception e '+e.getLineNumber());
            updateLogIIM(e.getMessage()+'--Line Number:'+e.getLineNumber(),recordid,'Failed',fWrp.headwr.MsgId,CIMId);
        }
    }
    
    /*************
    * Method name  : inactivateAccount
    * Description  : Inactive the account as per the CIM response
    * Return Type  : VOID
    * Parameter    : AccountWrapper, recordid
    *************/
    
    public static void inactivateAccount(Core_XMLParserHandler.finalWrapper AccountWrapper, id recordid){
        
        String query = '';
        String CIMId='';
        String ErrorDesc ='';
        set<id> sfId = new set<id>();
        List<Account> accList = new List<Account>(); 
        Core_XMLParserHandler.finalWrapper fWrp= new Core_XMLParserHandler.finalWrapper();
        fWrp = AccountWrapper;
        Map<String, List<Core_XMLParserHandler.SourceRecord>> srsMap = new map<string, List<Core_XMLParserHandler.SourceRecord>>();
       
        try{
            //srsMap = getSourceRecords(fWrp);
            sfId = getSfidsFromSrsRec(srsMap);
            CIMId  = fWrp.snpWr.bo.BusinessOrganizationPartyId;
            
            if(!String.isBlank(CIMId)){
                if(sfId.size() > 0){
                    query = 'select id, Core_Last_MsgId__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from account where Core_CIM_ID__c =: CIMId OR id IN: sfId FOR UPDATE';
                }
                else{
                    query = 'select id, Core_Last_MsgId__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from account where Core_CIM_ID__c =: CIMId FOR UPDATE';
                }
            }
            //List<Account> accList = [select id, Core_Last_MsgId__c,core_Account_Not_in_CIM__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from account where Core_CIM_ID__c =: CIMId OR id IN:sfId];
            accList = database.query(query);
            system.debug('acnt size()-->'+accList.size());
            if(accList.size() > 0 ){
                List<Account> updateAccountList = new List<account>();
                for(account a : accList){
                    if(a.Core_Last_MsgId__c != null){
                        if(Integer.valueOf(fWrp.headwr.MsgId) > Integer.valueOf(a.Core_Last_MsgId__c)){
                            a.core_Account_Not_in_CIM__c = true;
                            a.Core_Last_MsgId__c = fWrp.headwr.MsgId;
                            updateAccountList.add(a);
                        }
                        else{
                            ErrorDesc = 'MsgId in XML is less than the MsgId already present in account';
                        }
                    }
                    else{
                        ErrorDesc = 'MsgId in null in account record in salesforce';
                    }
                }
                updateLogIIM(ErrorDesc,recordid,'Failed',fWrp.headwr.MsgId,CIMId);
                system.debug('inactive account--> '+updateAccountList);
                if(ErrorDesc ==''){
                integer count = 0;
                    Database.SaveResult[] srr = database.update(updateAccountList,true);
                    for (Database.SaveResult sr : srr) {
                        if (sr.isSuccess()) {
                            count++;
                        }
                    }
                    if(accList.size() == count){
                        updateLogIIM('Records updated Successfully',recordid,'Successful',fWrp.headwr.MsgId,CIMId);
                    }
               } 
            }
        }
        catch(exception e){
            system.debug(e.getMessage());
            system.debug('Exception e '+e.getLineNumber());
            updateLogIIM(e.getMessage()+'--Line Number:'+e.getLineNumber(),recordid,'Failed',fWrp.headwr.MsgId,CIMId);
        }
    }
    
    /*************
    * Method name  : getSourceRecords
    * Description  : Parse the Source Records (ERPM, SLSCLD & CIMHUB)
    * Return Type  : Map<String, List<Core_XMLParserHandler.SourceRecord>>
    * Parameter    : Core_XMLParserHandler.finalWrapper fWrp
    *************/
    public static Map<String, List<Core_XMLParserHandler.SourceRecord>> getSourceRecords(Core_XMLParserHandler.finalWrapper fWrp){
    
        Map<String, List<Core_XMLParserHandler.SourceRecord>> srsMap = new map<string, List<Core_XMLParserHandler.SourceRecord>>();
        
        if(fWrp.sourceRecordWr != null && fWrp.sourceRecordWr.SourceRecord.size() > 0){
            for(Core_XMLParserHandler.SourceRecord sr: fWrp.sourceRecordWr.SourceRecord){
                if(sr.SourceSystemCd != null){
                    if(sr.SourceSystemCd.equalsIgnoreCase(Core_ConstantUtility.SR_CIMHUB)){
                        srsMap.put(sr.SourceSystemCd, new List<Core_XMLParserHandler.SourceRecord>{sr});
                    }
                    else if(sr.SourceSystemCd.equalsIgnoreCase(Core_ConstantUtility.SR_ERPM) && sr.dedup.EngagementDeduplicationGroupCd.equalsIgnoreCase(Core_ConstantUtility.SR_DEDUP_ITP)){
                        if(!srsMap.containskey(sr.SourceSystemCd)){
                            srsMap.put(sr.SourceSystemCd, new List<Core_XMLParserHandler.SourceRecord>{sr});
                        }
                        else{
                            srsMap.get(sr.SourceSystemCd).add(sr);
                        }
                    }
                    else if(sr.SourceSystemCd.equalsIgnoreCase(Core_ConstantUtility.SR_SLSCLD)){
                        if(!srsMap.containskey(sr.SourceSystemCd)){
                            srsMap.put(sr.SourceSystemCd, new List<Core_XMLParserHandler.SourceRecord>{sr});
                        }
                        else{
                            srsMap.get(sr.SourceSystemCd).add(sr);
                        }
                    }
                }
            }
        }
        return srsMap;
    }
    
    
    /*************
    * Method name  : getElectronicAddress
    * Description  : parse the electronic Address in Snapshot
    * Return Type  : Map<String, Core_XMLParserHandler.ElectronicAddress>
    * Parameter    : Core_XMLParserHandler.finalWrapper fWrp
    *************/
    public static Map<String, Core_XMLParserHandler.ElectronicAddress> getElectronicAddress(Core_XMLParserHandler.finalWrapper fWrp){
    
        Map<String, Core_XMLParserHandler.ElectronicAddress> electricAddressMap = new map<string, Core_XMLParserHandler.ElectronicAddress>();
        
        if(fWrp.snpWr != null && fWrp.snpWr.eleAdd.size() > 0){
            for(Core_XMLParserHandler.ElectronicAddress ea : fWrp.snpWr.eleAdd){
                if(ea.ElectronicAddressTypeCd != null){
                    if(ea.ElectronicAddressTypeCd.equalsIgnoreCase(Core_ConstantUtility.SNP_ELEC_ADR_FAX)){
                        electricAddressMap.put(ea.ElectronicAddressTypeCd, ea);
                    }
                
                    else if(ea.ElectronicAddressTypeCd.equalsIgnoreCase(Core_ConstantUtility.SNP_ELEC_ADR_PHONE )){
                    
                        electricAddressMap.put(ea.ElectronicAddressTypeCd, ea);
                    
                    }
                    else if(ea.ElectronicAddressTypeCd.equalsIgnoreCase(Core_ConstantUtility.SNP_ELEC_ADR_URL )){
                    
                        electricAddressMap.put(ea.ElectronicAddressTypeCd, ea);
                    
                    }
                }
            }
        }
        return electricAddressMap;
    }
    
    
    /*************
    * Method name  : getSfidsFromSrsRec
    * Description  : get the salesforce ids from sales cloud Source Records.
    * Return Type  : set<id>
    * Parameter    : Map<String, List<Core_XMLParserHandler.SourceRecord>> srsMap
    *************/
    public static set<id> getSfidsFromSrsRec(Map<String, List<Core_XMLParserHandler.SourceRecord>> srsMap){
    
        set<id> sfId = new set<id>();
        system.debug('@@salescloud-->'+srsMap.get('SLSCLD'));
        if(srsMap.get('SLSCLD') != null){
            List<Core_XMLParserHandler.SourceRecord> slscld= srsMap.get('SLSCLD');
            for(Core_XMLParserHandler.SourceRecord sls:slscld){
                sfId.add(sls.sbo.id);
            }
        }
        return sfId;
    }    
    
    /*************
    * Method name  : updateLogIIM
    * Description  : Update the Log Entery Object for any exception
    * Return Type  : VOID
    * Parameter    : message, recordid
    *************/
    
    public static void updateLogIIM(String message, id recordid, String Status,String msgId, String CIMID){
        
        Core_Integration_Inbound_Message__c ExcepLog = new Core_Integration_Inbound_Message__c();
        ExcepLog.id = recordid;
        ExcepLog.Core_CIM_ID__c = CIMID;
        ExcepLog.Core_Message_ID__c = msgId;
        ExcepLog.Core_Processing_Status__c = status;
        if(status =='Failed'){
            ExcepLog.Core_Processing_Status__c = status;
            ExcepLog.Core_Exception_Message__c = message;
            ExcepLog.Core_Error_Description__c = 'Apex Class:Core_CIMAccountController';
        }
        
        Update ExcepLog;
    }
    
}