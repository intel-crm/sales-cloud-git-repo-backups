public class ER_SearchCMFService { 

    @AuraEnabled(cacheable=false) 

    public static Object getCMF(String cmfGroupId,List<ER_SearchCMFService.RequestCMFModel> input) { 

        Map<String, String> returnResult = new Map<String, String>{}; 

            String params =''; 

        try{ 

            string filter = buildFilter(cmfGroupId,input); 

            filter = filter.replaceALl('"','%22').replaceAll(' ','%20'); 

            Map < String , String > mapOfHeaders = new Map < String, String> { 

                'Content-Type' => 'application/json' }; 

                    string url = '$start_index='+input[0].pageFirstRec+'&$filter=' +filter + '&$format=json&$orderby=DirectCustomerProfileId+ASC'; 

            String endPoint = 'callout:SalesCRM_Apigee' +  '/customer/v7/direct-customer-details?' + url+'&$count=1000'; 

            String strResponseCount; 

            if(input[0].pageFirstRec == 0){ 

                String countEndPoint = 'callout:SalesCRM_Apigee' +  '/customer/v7/direct-customer-details/$count' + '?$filter=' +filter + '&$format=json'; 

                HttpRequest reqCount = new HttpRequest();   

                reqCount.setEndpoint(countEndPoint); 

                reqCount.setMethod('GET'); 

                reqCount.setHeader('Content-Type', 'application/json'); 

                reqCount.setTimeout(120000); 

                Http http = new Http();        

                HTTPResponse resCount = http.send(reqCount); 

                params ='ResponeStatus'+resCount.getStatusCode() + '-Filter'+ filter; 

                strResponseCount = resCount.getBody(); 

            }         

            HttpRequest req = new HttpRequest();  

            req.setEndpoint(endPoint); 

            req.setMethod('GET'); 

            req.setHeader('Content-Type', 'application/json'); 

            req.setTimeout(120000); 

            Http http = new Http();       

            HTTPResponse res = http.send(req); 

            params = 'Status'+res.getStatusCode() + '-filter'+ filter; 

            String strResponse = res.getBody();  

            Object obj=JSON.deserializeUntyped(res.getBody()); 

            Map<String,Object> resMap=(Map<String,Object>)obj; 

            object newObj = resMap.get('elements'); 

            String jsonSubset = JSON.serialize(resMap.get('elements')); 

            List<elements> dataElements =(List<elements>)JSON.deserialize(jsonSubset, List<elements>.class); 

            //System.debug('Class'+dataElements); 

             

            Map<String,ER_SearchCMFService.elements> cmfDataMap = new Map<String,ER_SearchCMFService.elements>(); 

            Integer count =0; 

            for( elements rec : dataElements){ 

                System.debug('ANS'+rec.DirectCustomerProfileId); 

                String unique =rec.DirectCustomerProfileId+''+rec.SalesOrganizationCd+''+rec.DistributionChannelCd+''+rec.DistributionChannelNm + ' '+ rec.DirectCustomerRelationshipFunctionalRoleCd +' ' + rec.DirectCustomerRelationshipFunctionalRoleNm; 

                rec.disableButton = true; 

                cmfDataMap.put(unique,rec); 

                count++; 

            } 

            for(ER_CMFGroupAssociation__c rec : [SELECT ER_Customer_Master_File__r.ER_CMFUnique__c from ER_CMFGroupAssociation__c  WHERE ER_Customer_Master_File__r.ER_CMFUnique__c IN : cmfDataMap.keySet()]){ 

                cmfDataMap.get(rec.ER_Customer_Master_File__r.ER_CMFUnique__c).disableButton = false; 

                System.debug('In 53'); 

            } 

             

                 

                 

                 

                 

                /*else{ 

cmfDataMap.get(rec.ER_Customer_Master_File__r.ER_CMFUnique__c).GroupName = rec.ER_Customer_Master_File_Group__r.Name; 

cmfDataMap.get(rec.ER_Customer_Master_File__r.ER_CMFUnique__c).GroupLink = System.URL.getOrgDomainUrl().toExternalForm()+'/'+rec.ER_Customer_Master_File_Group__r.Id; 

cmfDataMap.get(rec.ER_Customer_Master_File__r.ER_CMFUnique__c).CmfAssoc = rec.Name; 

cmfDataMap.get(rec.ER_Customer_Master_File__r.ER_CMFUnique__c).CmfAssocLink = System.URL.getOrgDomainUrl().toExternalForm()+'/'+rec.Id; 

}*/

                 

                 

             

            System.debug('class'+cmfDataMap); 

            returnResult.put('RecordCount',strResponseCount); 

            returnResult.put('Elements',JSON.serialize(cmfDataMap.values())); 

             

             

             

             

            ER_ErrorUtility.createLogEntry('Search CMF Response ',null,'Low','ER_SearchCMFService',params.substring(0,255)); 

             

        } 

        catch(Exception ex){ 

            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException(); 

            custEx.Message = ex.getMessage(); 

            custEx.Cause = ex.getCause(); 

            custEx.StackTraceString = ex.getStackTraceString(); 

            custEx.LineNumber = ex.getLineNumber();                 

            custEx.TypeName = ex.getTypeName(); 

            ER_ErrorUtility.createLogEntry('Search CMF Response ',custEx,'High','ER_SearchCMFService',params); 

        } 

        return returnResult; 

    } 

     

    public class elements{ 

         

        public String DirectCustomerProfileId{get;set;} 

        public String SalesOrganizationCd{get;set;} 

        public String DistributionChannelCd{get;set;} 

        public String DistributionChannelNm{get;set;} 

        public String DirectCustomerRelationshipFunctionalRoleCd{get;set;} 

        public String DirectCustomerRelationshipFunctionalRoleNm{get;set;} 

        public String PhysicalStreetAddressTxt{get;set;} 

        public String CityNm{get;set;} 

        public String CountrySubDivisionNm{get;set;} 

        public String CountryNm{get;set;} 

        public String PostalCd{get;set;} 

        public List<String> GroupName{get;set;} 

        public String DirectCustomerProfileNm{get;set;} 

        public String GeographyCd{get;set;} 

        public String CentralDeleteInd{get;set;} 

        public String DirectCustomerRoleCd{get;set;} 

        public List<String> GroupLink{get;set;} 

        public String CmfAssoc{get;set;} 

        public String CmfAssocLink{get;set;} 

        public String PartnerCustomerProfileId{get;set;} 

        public Boolean disableButton{get;set;} 

         

         

         

         

         

         

         

         

         

    } 

     

    private static string buildFilter(String cmfGroupId,List<ER_SearchCMFService.RequestCMFModel> cmfs) { 

        string cmfIdFilter = ''; 

        string cmfNameFilter = ''; 

        string salesOrgCodeFilter = ''; 

        string salesDistiChannelCodeFilter = ''; 

        string accountGroupId; 

        string directCustomerRelationalCd; 

        string partnerCustProfileId; 

        String filter = 'COALESCE(\"SalesAreaOrderBlockCd\",\'\')+not+in+(\'99\',\'01\')'; 

        for(ER_SearchCMFService.RequestCMFModel cmf : cmfs) { 

            if(string.isNotBlank(cmf.cmfId)) { 

                cmfIdfilter = '\"DirectCustomerProfileId"=\'' + String.escapeSingleQuotes(cmf.cmfId) +'\''; 

            } 

            if(string.isNotBlank(cmf.cmfName)) { 

                cmfNameFilter = '\"DirectCustomerProfileNm"=\'' + String.escapeSingleQuotes(cmf.cmfName) +'\''; 

            } 

            if(string.isNotBlank(cmf.salesOrgCode)) { 

                salesOrgCodeFilter = '\"SalesOrganizationCd"=\'' + String.escapeSingleQuotes(cmf.salesOrgCode) +'\''; 

            } 

            if(string.isNotBlank(cmf.salesDistiChannelCode)) { 

                salesDistiChannelCodeFilter = '\"DistributionChannelCd"=\'' + String.escapeSingleQuotes(cmf.salesDistiChannelCode) + '\''; 

            } 

             

            filter = string.isNotBlank(filter) && string.isNotBlank(cmfIdfilter) ? filter + 'AND' + cmfIdfilter : filter + cmfIdfilter; 

            filter = string.isNotBlank(filter) && string.isNotBlank(cmfNameFilter) ? filter + 'AND' + cmfNameFilter : filter + cmfNameFilter; 

            filter = string.isNotBlank(filter) && string.isNotBlank(salesOrgCodeFilter) ? filter + 'AND' + salesOrgCodeFilter : filter + salesOrgCodeFilter; 

            filter = string.isNotBlank(filter) && string.isNotBlank(salesDistiChannelCodeFilter) ? filter + 'AND' + salesDistiChannelCodeFilter : filter + salesDistiChannelCodeFilter; 

             

             

             

        } 

        List<ER_ContactGroupAssociation__c> accWithODM =[Select id,ER_Contact__r.Account.Core_IsODM__c from ER_ContactGroupAssociation__c where ER_Customer_Master_File_Group__r.id=:cmfGroupId AND ER_Contact__r.Account.Core_IsODM__c = true AND ER_Active__c =true  Limit 1 ]; 

        if(accWithODM !=null && !accWithODM.isEmpty()){ 

            accountGroupId= '"DirectCustomerRoleCd"' + '=' +'\'0002\''; 

            directCustomerRelationalCd = '"DirectCustomerRelationshipFunctionalRoleCd"' + '=' +'\'WE\''; 

        }  

        else{ 

            accountGroupId= '"DirectCustomerRoleCd"' + '=' +'\'0001\'';  

            directCustomerRelationalCd = '"DirectCustomerRelationshipFunctionalRoleCd"' + '=' +'\'AG\''; 

        } 

        partnerCustProfileId =  '"DirectCustomerProfileId"' + '=' + '"PartnerCustomerProfileId"';  

         filter = string.isNotBlank(filter)  ? filter + 'AND' + partnerCustProfileId : filter + partnerCustProfileId;    

        filter = string.isNotBlank(filter)  ? filter + 'AND' + accountGroupId : filter + accountGroupId; 

        filter = string.isNotBlank(filter)  ? filter + 'AND' + directCustomerRelationalCd : filter + directCustomerRelationalCd; 

             

        return filter; 

    } 

     

    public class RequestCMFModel { 

        @AuraEnabled 

        public string cmfId {set;get;} 

        @AuraEnabled 

        public string cmfName {set;get;} 

        @AuraEnabled 

        public string salesOrgCode {set;get;} 

        @AuraEnabled

        public string salesDistiChannelCode {set;get;} 

        @AuraEnabled 

        public Integer pageFirstRec {set;get;} 

    } 

     

     

    public class JsonParser{ 

        @AuraEnabled 

        public String DirectCustomerProfileId{set;get;} 

        @AuraEnabled 

        public String DirectCustomerProfileTrimId{set;get;} 

        @AuraEnabled 

        public String DirectCustomerProfileNm{set;get;} 

        @AuraEnabled 

        public String NielsenId{set;get;} 

        @AuraEnabled 

        public String DistributionChannelCd{set;get;} 

        @AuraEnabled 

        public String DistributionChannelNm{set;get;} 

        @AuraEnabled 

        public String SalesOfficeCd{set;get;} 

        @AuraEnabled 

        public String SalesOfficeNm{set;get;} 

        @AuraEnabled 

        public String DivisionCd{set;get;} 

        @AuraEnabled 

        public String GeographyCd{set;get;} 

        @AuraEnabled 

        public String SalesGroupCd{set;get;} 

        @AuraEnabled 

        public String SalesGroupNm{set;get;} 

        @AuraEnabled 

        public String SalesOrganizationCd{set;get;} 

        @AuraEnabled 

        public String SalesOrganizationGroupCd{set;get;} 

        @AuraEnabled 

        public String DirectCustomerRevenueReportingClassificationCd{set;get;} 

        @AuraEnabled 

        public String DirectCustomerRevenueReportingClassificationNm{set;get;} 

        @AuraEnabled 

        public String CustomerSupplyAllocationClassificationCd{set;get;} 

        @AuraEnabled 

        public String CustomerSupplyAllocationClassificationNm{set;get;} 

        @AuraEnabled 

        public String CustomerGroupTwoCd{set;get;} 

        @AuraEnabled 

        public String CustomerGroupThreeCd{set;get;} 

        @AuraEnabled 

        public String CustomerGroupFourCd{set;get;} 

        @AuraEnabled 

        public String CustomerGroupFiveCd{set;get;} 

        @AuraEnabled 

        public String PartnerCustomerProfileId{set;get;} 

        @AuraEnabled 

        public String DirectCustomerRelationshipFunctionalRoleCd{set;get;} 

        @AuraEnabled 

        public String DirectCustomerRelationshipFunctionalRoleNm{set;get;} 

        @AuraEnabled

        public String DirectCustomerPriceGroupCd{set;get;} 

        @AuraEnabled

        public String DirectCustomerRoleCd{set;get;} 

        @AuraEnabled 

        public String CentralDeleteInd{set;get;} 

        @AuraEnabled 

        public String EnglishPhysicalStreetAddressLine3{set;get;} 

        @AuraEnabled 

        public String EnglishPhysicalStreetAddressLine4{set;get;} 

        @AuraEnabled 

        public Object CustomerCentralOrderBlockCd{set;get;} 

        @AuraEnabled 

        public Object CustomerCentralBillingBlockCd{set;get;} 

        @AuraEnabled 

        public Object CustomerCentralDeliveryBlockCd{set;get;} 

        @AuraEnabled 

        public String DirectCustomerBusinessRoutingCd{set;get;} 

        @AuraEnabled 

        public String DirectCustomerBusinessRoutingNm{set;get;} 

        @AuraEnabled 

        public String IntelUltimateBusinessPartyId{set;get;} 

        @AuraEnabled 

        public Object SalesAreaOrderBlockCd{set;get;} 

        @AuraEnabled 

        public Object SalesAreaOrderBlockNm{set;get;} 

        @AuraEnabled 

        public Object SalesAreaBillingBlockCd{set;get;} 

        @AuraEnabled 

        public Object SalesAreaBillingBlockNm{set;get;} 

        @AuraEnabled 

        public Object SalesAreaDeliveryBlockCd{set;get;} 

        @AuraEnabled 

        public Object SalesAreaDeliveryBlockNm{set;get;} 

        @AuraEnabled 

        public String SalesAreaSalesBlockInd{set;get;} 

        @AuraEnabled 

        public String CountryCd{set;get;} 

        @AuraEnabled 

        public String CountryNm{set;get;} 

        @AuraEnabled 

        public String CityNm{set;get;} 

        @AuraEnabled 

        public String PostalCd{set;get;} 

        @AuraEnabled 

        public String CountrySubdivisionCd{set;get;} 

        @AuraEnabled 

        public String CountrySubdivisionNm{set;get;} 

        @AuraEnabled 

        public String PhysicalStreetAddressTxt{set;get;} 

        @AuraEnabled 

        public String PhysicalAddressCareOfNm{set;get;} 

        @AuraEnabled 

        public String PaymentTermCd{set;get;} 

        @AuraEnabled 

        public String CurrencyCd{set;get;} 

        @AuraEnabled 

        public String InternationalCommerceTermCd{set;get;} 

        @AuraEnabled 

        public String InternationalCommerceTermCd2{set;get;} 

        @AuraEnabled 

        public String DirectCustomerCategoryCd{set;get;} 

        @AuraEnabled 

        public String DirectCustomerKeywordTxt{set;get;} 

        @AuraEnabled 

        public String CreateAgentId{set;get;} 

        @AuraEnabled 

        public String CreateDtm{set;get;} 

        @AuraEnabled 

        public String ChangeAgentId{set;get;} 

        @AuraEnabled 

        public String ChangeDtm{set;get;} 

         

    } 

     

     

     

    @AuraEnabled 

    public static void saveCMFData(String bagId,List<ER_SearchCMFService.JsonParser> inputData, Boolean isCMFToGroup) { 

        Map<String,ER_SearchCMFService.JsonParser> cmfDataMap = new Map<String,ER_SearchCMFService.JsonParser>(); 

       

        for(ER_SearchCMFService.JsonParser rec: inputData){ 

            String unique =rec.DirectCustomerProfileId+''+rec.SalesOrganizationCd+''+rec.DistributionChannelCd+''+rec.DistributionChannelNm + ' '+ rec.DirectCustomerRelationshipFunctionalRoleCd +' ' + rec.DirectCustomerRelationshipFunctionalRoleNm; 


            cmfDataMap.put(unique,rec); 

        } 

        if(!cmfDataMap.isEmpty()){  
             System.debug('Size' + cmfDataMap.Size());
            insertCMFRec(bagId,cmfDataMap,isCMFToGroup); 

        } 

    } 
public static void insertCMFRec(String bagId, Map<String, ER_SearchCMFService.JsonParser> cmfDataToBeAddedMap, Boolean isCMFToGroup) {
    try {
        if (isCMFToGroup) {
            List<ER_Customer_Master_File__c> cmfDataToBeInserted = new List<ER_Customer_Master_File__c>();
            Set<String> cmfUniqueKeySet = new Set<String>();

            for (ER_SearchCMFService.JsonParser parser : cmfDataToBeAddedMap.values()) {
                String uniqueKey = parser.DirectCustomerProfileId + parser.SalesOrganizationCd + parser.DistributionChannelCd +
                                   parser.DistributionChannelNm + ' ' + parser.DirectCustomerRelationshipFunctionalRoleCd + ' ' +
                                   parser.DirectCustomerRelationshipFunctionalRoleNm;

                ER_Customer_Master_File__c rec = new ER_Customer_Master_File__c();
                rec.Name = parser.DirectCustomerProfileId;
                rec.ER_CMF_Name__c = parser.DirectCustomerProfileNm;
                rec.ER_Sales_Org_Name__c = parser.GeographyCd;
                rec.ER_Sales_Org_Code__c = parser.SalesOrganizationCd;
                rec.ER_Sales_Disti_Chnl_Name__c = parser.DistributionChannelNm;
                rec.ER_Sales_Disti_Chnl_Code__c = parser.DistributionChannelCd;
                rec.ER_Central_Block__c = Boolean.valueOf(parser.CentralDeleteInd);
                rec.ER_CMFUnique__c = uniqueKey;
                rec.ER_CMF_Address__c = parser.PhysicalStreetAddressTxt + ' ' + parser.CityNm + ' ' + parser.CountrySubDivisionNm + ' ' + parser.CountryNm + ' ' + parser.PostalCd;
                rec.ER_Account_Group__c = parser.DirectCustomerRoleCd;
                rec.ER_Direct_Customer_Relationship_Code__c = parser.DirectCustomerRelationshipFunctionalRoleCd;
                rec.ER_Direct_Customer_Relationship_Name__c = parser.DirectCustomerRelationshipFunctionalRoleNm;
                rec.ER_SalesAreaOrderBlockCd__c = String.valueOf(parser.SalesAreaOrderBlockCd);
                rec.ER_SalesAreaOrderBlockNm__c = String.valueOf(parser.SalesAreaOrderBlockNm);

                cmfDataToBeInserted.add(rec);
                cmfUniqueKeySet.add(uniqueKey);
            }

            if (!cmfDataToBeInserted.isEmpty()) {
                List<Database.UpsertResult> cmfInsertionResult = Database.upsert(cmfDataToBeInserted, false);
                for (Database.UpsertResult sr : cmfInsertionResult) {
                    if (!sr.isSuccess()) {
                        for (Database.Error err : sr.getErrors()) {
                            System.debug('Insert Error - ' + err.getMessage());
                        }
                    }
                }

                Set<String> cmfGroupSet = new Set<String>();
                for (ER_CMFGroupAssociation__c cga : [
                    SELECT ER_Customer_Master_File__r.ER_CMFUnique__c
                    FROM ER_CMFGroupAssociation__c
                    WHERE ER_Customer_Master_File_Group__c = :bagId AND ER_Active__c = TRUE
                ]) {
                    cmfGroupSet.add(cga.ER_Customer_Master_File__r.ER_CMFUnique__c);
                }

                Map<String, Id> cmfUniqueToIdMap = new Map<String, Id>();
                for (ER_Customer_Master_File__c cmf : [
                    SELECT Id, ER_CMFUnique__c
                    FROM ER_Customer_Master_File__c
                    WHERE ER_CMFUnique__c IN :cmfUniqueKeySet
                ]) {
                    cmfUniqueToIdMap.put(cmf.ER_CMFUnique__c, cmf.Id);
                }

                List<ER_CMFGroupAssociation__c> cmfAssociationList = new List<ER_CMFGroupAssociation__c>();
                for (String unique : cmfUniqueKeySet) {
                    if (!cmfGroupSet.contains(unique)) {
                        Id cmfId = cmfUniqueToIdMap.get(unique);
                        if (cmfId != null) {
                            ER_CMFGroupAssociation__c assoc = new ER_CMFGroupAssociation__c();
                            assoc.ER_Customer_Master_File__c = cmfId;
                            assoc.ER_Customer_Master_File_Group__c = bagId;
                            assoc.ER_Active__c = true;
                            cmfAssociationList.add(assoc);
                        }
                    }
                }

                if (!cmfAssociationList.isEmpty()) {
                    insert cmfAssociationList;
                }
            }
        } else {
            Map<String, Id> cmfIdToAccountId = new Map<String, Id>();
            for (Account acc : [
                SELECT Id, Core_Direct_Account_Id__c
                FROM Account
                WHERE RecordType.Name = 'Direct Account' AND Core_Direct_Account_Id__c != null
            ]) {
                cmfIdToAccountId.put(acc.Core_Direct_Account_Id__c.trim(), acc.Id);
            }

            List<ER_Account_Business_Partner__c> abpList = new List<ER_Account_Business_Partner__c>();
            for (ER_SearchCMFService.JsonParser parser : cmfDataToBeAddedMap.values()) {
                String cmfId = parser.DirectCustomerProfileId != null ? parser.DirectCustomerProfileId.trim() : '';
                Id accountId = cmfIdToAccountId.get(cmfId);

                if (accountId != null) {
                    ER_Account_Business_Partner__c abp = new ER_Account_Business_Partner__c();
                    abp.Account__c = accountId;
                    abp.ER_Account_Group__c = parser.DirectCustomerRoleCd;
                    abp.ER_CMFGroupAssociation__c = bagId;
                    abpList.add(abp);
                } else {
                    System.debug('️ No account found for CMF ID: ' + cmfId);
                }
            }

            if (!abpList.isEmpty()) {
                insert abpList;
                System.debug(' Inserted ' + abpList.size() + ' ER_Account_Business_Partner__c records.');
            } else {
                System.debug('No ER_Account_Business_Partner__c records to insert.');
            }
        }
    } catch (Exception ex) {
        ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
        custEx.Message = ex.getMessage();
        custEx.Cause = ex.getCause();
        custEx.StackTraceString = ex.getStackTraceString();
        custEx.LineNumber = ex.getLineNumber();
        custEx.TypeName = ex.getTypeName();
        ER_ErrorUtility.createLogEntry('Save CMF Data', custEx, 'High', 'ER_SearchCMFService', null);
    }
}




    @AuraEnabled(cacheable=true) 

    public static List<CMFGroupData> getCmfGroupDetails(String uniqueString) { 

        List<ER_CMFGroupAssociation__c> associationRecList = [SELECT id,name,ER_Customer_Master_File_Group__r.Name,ER_Customer_Master_File_Group__r.Id,ER_Customer_Master_File_Group__r.ER_Active__c,ER_Customer_Master_File_Group__r.ER_Count_of_Customer_Master_Files__c,ER_Customer_Master_File_Group__r.ER_Count_of_Contacts__c from ER_CMFGroupAssociation__c WHERE ER_Customer_Master_File__r.ER_CMFUnique__c =:uniqueString]; 

        List<CMFGroupData> CMFGroupDataList = new List<CMFGroupData>(); 

        for(ER_CMFGroupAssociation__c rec : associationRecList){ 

            CMFGroupData grouprec = new CmfGroupData(); 

            grouprec.GroupName = rec.ER_Customer_Master_File_Group__r.Name; 

            grouprec.GroupLink = System.URL.getOrgDomainUrl().toExternalForm()+'/'+rec.ER_Customer_Master_File_Group__r.Id; 

            grouprec.Active = rec.ER_Customer_Master_File_Group__r.ER_Active__c; 

            grouprec.ActiveCMFCount = Integer.valueOf(rec.ER_Customer_Master_File_Group__r.ER_Count_of_Customer_Master_Files__c); 

            grouprec.ActiveContactCount = Integer.valueOf(rec.ER_Customer_Master_File_Group__r.ER_Count_of_Contacts__c); 

            CMFGroupDataList.add(grouprec); 

             

        } 

        return CMFGroupDataList;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  

         

    } 

     @AuraEnabled(cacheable=true) 

    public static List<CMFGroupDataAccount> getCmfAccountDetails(String cmfId) { 

        System.debug('ANS'+cmfId); 

        List<Account> associationRecList = [SELECT id,name from Account WHERE Core_Direct_Account_Id__c =:cmfId AND RecordType.Name ='Direct Account']; 

        List<CMFGroupDataAccount> CMFGroupDataList1 = new List<CMFGroupDataAccount>(); 

        for(Account rec : associationRecList){ 

            CMFGroupDataAccount grouprec = new CMFGroupDataAccount(); 

            grouprec.AccountName = rec.Name; 

            grouprec.AccountLink = System.URL.getOrgDomainUrl().toExternalForm()+'/'+rec.Id; 

            CMFGroupDataList1.add(grouprec); 

             

        } 

        return CMFGroupDataList1;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  

         

    } 

     public class CMFGroupData { 

        @AuraEnabled 

        public string GroupName {set;get;} 

        @AuraEnabled 

        public string GroupLink {set;get;} 

         @AuraEnabled 

        public Boolean Active {set;get;} 

        @AuraEnabled 

        public Integer ActiveCMFCount{set;get;} 

         @AuraEnabled 

        public Integer ActiveContactCount{set;get;} 

     } 

     public class CMFGroupDataAccount { 

        @AuraEnabled 

        public string AccountName {set;get;} 

        @AuraEnabled

        public string AccountLink {set;get;} 

     } 

     

}