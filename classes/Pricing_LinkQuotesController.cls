/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-10-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Pricing_LinkQuotesController {
    public static Boolean isPartnerUser = Pricing_QuoteLineController.isPartnerUser();
    @AuraEnabled
    public static List<QuoteDetails> getQuotes(Id quoteId){
        Map<Id,SBQQ__Quote__c> quoteMap = new Map<Id,SBQQ__Quote__c>([SELECT Id, Name, Pricing_End_Customer_Name__c, Pricing_End_Customer_Country_Nm__c, 
                                                                      Pricing_Project_Name_Nm__c, SBQQ__Account__r.Name, Pricing_Program_Type_Nm__c 
                                                                      FROM SBQQ__Quote__c WHERE Id =: quoteId]);
        List<SBQQ__Quote__c> quotesList = [SELECT Id, Name, Pricing_End_Customer_Name__c, Pricing_End_Customer_Country_Nm__c, 
                                           Pricing_Project_Name_Nm__c, SBQQ__Account__c, SBQQ__Account__r.Name, Pricing_Group_Nm__r.Id,Pricing_Group_Nm__r.Name, 
                                           Pricing_Program_Type_Nm__c FROM SBQQ__Quote__c 
                                           WHERE Id !=: quoteMap.get(quoteId).Id AND 
                                           SBQQ__Account__c =: quoteMap.get(quoteId).SBQQ__Account__c AND Pricing_Quote_Program_Nm__c =: System.Label.Pricing_Tender_Quote_Program
                                           ORDER BY Name Asc limit 500];
        List<QuoteDetails> quoteLinkList = new List<QuoteDetails>();
        for(SBQQ__Quote__c quote : quotesList){
            QuoteDetails quoteDtls = new QuoteDetails();
            quoteDtls.Id = quote.Id;
            quoteDtls.quoteNumber = quote.Name;
            quoteDtls.groupName = quote.Pricing_Group_Nm__r.Name;
            quoteDtls.quoteType = quote.Pricing_Program_Type_Nm__c;
            quoteDtls.endCustomer = quote.Pricing_End_Customer_Name__c;
            quoteDtls.endCustomerCountry = quote.Pricing_End_Customer_Country_Nm__c;
            quoteDtls.projectName = quote.Pricing_Project_Name_Nm__c;
            quoteDtls.quoteNumberUrl = (!isPartnerUser)?(URL.getSalesforceBaseURL().toExternalForm()+'/'+quote.Id):(System.Label.Pricing_Tender_Quote_PartnerUser_URL+quote.Id);
            quoteDtls.groupNameUrl = (!isPartnerUser)?((quote.Pricing_Group_Nm__r.Id != null)?URL.getSalesforceBaseURL().toExternalForm()+'/'+quote.Pricing_Group_Nm__r.Id:''):((quote.Pricing_Group_Nm__r.Id != null)?System.Label.Pricing_Tender_Quote_Group_PartnerUser_URL+quote.Pricing_Group_Nm__r.Id:'');
            quoteLinkList.add(quoteDtls);
        }
        return quoteLinkList;
    }
    
    @AuraEnabled
    public static boolean getQuoteLinkStatus(Id quoteId){
        SBQQ__Quote__c quoteRec = [SELECT Id, Name, Pricing_Group_Nm__c FROM SBQQ__Quote__c WHERE Id =: quoteId];
        if(quoteRec.Pricing_Group_Nm__c != null){
            return true;
        }
        else{
            return false;
        }
    }
    
    @AuraEnabled
    public static List<QuoteGroupWrapper> getQuoteGroup(Id quoteId){
        SBQQ__Quote__c quoteRec = [SELECT Id, Name, Pricing_Group_Nm__c FROM SBQQ__Quote__c WHERE Id =: quoteId];
        List<QuoteGroupWrapper> quoteGroupList = new List<QuoteGroupWrapper>();
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c, Pricing_Group_Nm__r.Id, Pricing_Group_Nm__r.Name, 
                                          Pricing_End_Customer_Name__c, Pricing_End_Customer_Country_Nm__c, 
                                          Pricing_Project_Name_Nm__c, SBQQ__Account__r.Id, SBQQ__Account__r.Name, 
                                          Pricing_Program_Type_Nm__c FROM SBQQ__Quote__c 
                                          WHERE Pricing_Group_Nm__c =: quoteRec.Pricing_Group_Nm__c ORDER BY Name Asc];
        for(SBQQ__Quote__c quote: quoteList){
            QuoteGroupWrapper quoteGrpWrap = new QuoteGroupWrapper();
            quoteGrpWrap.quoteNumber = quote.Name;
            quoteGrpWrap.groupName = quote.Pricing_Group_Nm__r.Name;
            quoteGrpWrap.quoteType = quote.Pricing_Program_Type_Nm__c;
            quoteGrpWrap.endCustomer = quote.Pricing_End_Customer_Name__c;
            quoteGrpWrap.endCustomerCountry = quote.Pricing_End_Customer_Country_Nm__c;
            quoteGrpWrap.projectName = quote.Pricing_Project_Name_Nm__c;
            quoteGrpWrap.quoteNumberUrl = (!isPartnerUser)?(URL.getSalesforceBaseURL().toExternalForm()+'/'+quote.Id):(System.Label.Pricing_Tender_Quote_PartnerUser_URL+quote.Id);
            quoteGrpWrap.groupNameUrl = (!isPartnerUser)?((quote.Pricing_Group_Nm__r.Id != null)?URL.getSalesforceBaseURL().toExternalForm()+'/'+quote.Pricing_Group_Nm__r.Id:''):((quote.Pricing_Group_Nm__r.Id != null)?System.Label.Pricing_Tender_Quote_Group_PartnerUser_URL+quote.Pricing_Group_Nm__r.Id:'');
            quoteGroupList.add(quoteGrpWrap);
        }
        return quoteGroupList;
    }
    
    @AuraEnabled
    public static List<QuoteDetails> findRecords(Id quoteId, String searchKey, String searchCriteria) 
    {
        Map<Id,SBQQ__Quote__c> quoteMap = new Map<Id,SBQQ__Quote__c>([SELECT Id, Name, Pricing_End_Customer_Name__c, 
                                                                      Pricing_End_Customer_Country_Nm__c, Pricing_Project_Name_Nm__c, 
                                                                      SBQQ__Account__r.Name, Pricing_Program_Type_Nm__c 
                                                                      FROM SBQQ__Quote__c WHERE Id =: quoteId]);
        String searchString = '%'+searchKey+'%';
        List<SBQQ__Quote__c> quoteRecList = new List<SBQQ__Quote__c>();
        if(searchCriteria == 'Quote Number'){
            quoteRecList = [SELECT Id, Name, SBQQ__Account__c, SBQQ__Account__r.Name, Pricing_End_Customer_Name__c, 
                            Pricing_End_Customer_Country_Nm__c, Pricing_Project_Name_Nm__c, Pricing_Group_Nm__r.Id,Pricing_Group_Nm__r.Name, 
                            Pricing_Program_Type_Nm__c FROM SBQQ__Quote__c 
                            WHERE Id !=: quoteMap.get(quoteId).Id  
                            AND Name LIKE: searchString
                            AND SBQQ__Account__c =: quoteMap.get(quoteId).SBQQ__Account__c ORDER BY Name Asc];
        }
        else if(searchCriteria == 'Project'){
            quoteRecList = [SELECT Id, Name, SBQQ__Account__c, SBQQ__Account__r.Name, Pricing_End_Customer_Name__c, 
                            Pricing_End_Customer_Country_Nm__c, Pricing_Project_Name_Nm__c, Pricing_Group_Nm__r.Id,Pricing_Group_Nm__r.Name, 
                            Pricing_Program_Type_Nm__c FROM SBQQ__Quote__c 
                            WHERE Id !=: quoteMap.get(quoteId).Id  
                            AND Pricing_Project_Name_Nm__c LIKE: searchString 
                            AND SBQQ__Account__c =: quoteMap.get(quoteId).SBQQ__Account__c ORDER BY Name Asc];
        }
        else if(searchCriteria == 'End Customer'){
            quoteRecList = [SELECT Id, Name, SBQQ__Account__c, SBQQ__Account__r.Name, Pricing_End_Customer_Name__c, 
                            Pricing_End_Customer_Country_Nm__c, Pricing_Project_Name_Nm__c, Pricing_Group_Nm__r.Id,Pricing_Group_Nm__r.Name, 
                            Pricing_Program_Type_Nm__c FROM SBQQ__Quote__c 
                            WHERE Id !=: quoteMap.get(quoteId).Id  
                            AND Pricing_End_Customer_Name__c LIKE: searchString  
                            AND SBQQ__Account__c =: quoteMap.get(quoteId).SBQQ__Account__c ORDER BY Name Asc];
        }
        else if(searchCriteria == 'Quote Type'){
            quoteRecList = [SELECT Id, Name, SBQQ__Account__c, SBQQ__Account__r.Name, Pricing_End_Customer_Name__c, 
                            Pricing_End_Customer_Country_Nm__c, Pricing_Project_Name_Nm__c, Pricing_Group_Nm__r.Id,Pricing_Group_Nm__r.Name, 
                            Pricing_Program_Type_Nm__c FROM SBQQ__Quote__c 
                            WHERE Id !=: quoteMap.get(quoteId).Id  
                            AND Pricing_Program_Type_Nm__c LIKE: searchString
                            AND SBQQ__Account__c =: quoteMap.get(quoteId).SBQQ__Account__c ORDER BY Name Asc];
        }
        List<QuoteDetails> quoteLinkList = new List<QuoteDetails>(); 
        for(SBQQ__Quote__c quoteRec: quoteRecList){
            QuoteDetails quoteDtls = new QuoteDetails();
            quoteDtls.Id = quoteRec.Id;
            quoteDtls.quoteNumber = quoteRec.Name;
            quoteDtls.groupName = quoteRec.Pricing_Group_Nm__r.Name;
            quoteDtls.quoteType = quoteRec.Pricing_Program_Type_Nm__c;
            quoteDtls.endCustomer = quoteRec.Pricing_End_Customer_Name__c;
            quoteDtls.endCustomerCountry = quoteRec.Pricing_End_Customer_Country_Nm__c;
            quoteDtls.projectName = quoteRec.Pricing_Project_Name_Nm__c;
            quoteDtls.quoteNumberUrl = (!isPartnerUser)?(URL.getSalesforceBaseURL().toExternalForm()+'/'+quoteRec.Id):(System.Label.Pricing_Tender_Quote_PartnerUser_URL+quoteRec.Id);
            quoteDtls.groupNameUrl = (!isPartnerUser)?((quoteRec.Pricing_Group_Nm__r.Id != null)?URL.getSalesforceBaseURL().toExternalForm()+'/'+quoteRec.Pricing_Group_Nm__r.Id:''):((quoteRec.Pricing_Group_Nm__r.Id != null)?System.Label.Pricing_Tender_Quote_Group_PartnerUser_URL+quoteRec.Pricing_Group_Nm__r.Id:'');
            quoteLinkList.add(quoteDtls);
        }
        return quoteLinkList;
    }
    
    @AuraEnabled
    public static String linkQuotes(List<String> quoteNumList, Id quoteId){
        SBQQ__Quote__c quoteRec = [SELECT Id, Pricing_Group_Nm__c FROM SBQQ__Quote__c WHERE Id =: quoteId];
        List<SBQQ__Quote__c> quoteIdList = [SELECT Id, Pricing_Group_Nm__c FROM SBQQ__Quote__c WHERE Name IN: quoteNumList];
        List<SBQQ__Quote__c> quotesToUpd = new List<SBQQ__Quote__c>();
        Pricing_Quote_Group__c quoteGrp = new Pricing_Quote_Group__c();
        insert quoteGrp;
        quoteRec.Pricing_Group_Nm__c = quoteGrp.Id;
        for(SBQQ__Quote__c quote: quoteIdList){
            quote.Pricing_Group_Nm__c = quoteGrp.Id;
            quotesToUpd.add(quote);
        }
        quotesToUpd.add(quoteRec);
        update quotesToUpd;
        Pricing_Quote_Group__c qGrp = [SELECT Id, Name FROM Pricing_Quote_Group__c WHERE Id =: quoteGrp.Id];
        return qGrp.Name;
    }
    
    @AuraEnabled
    public static String linkQuoteWoGrp(List<String> quoteNumList, String groupName, Id quoteId){
        SBQQ__Quote__c quoteRec = [SELECT Id, Pricing_Group_Nm__c FROM SBQQ__Quote__c WHERE Id =: quoteId];
        List<SBQQ__Quote__c> quoteIdList = [SELECT Id, Pricing_Group_Nm__c FROM SBQQ__Quote__c 
                                            WHERE Name IN: quoteNumList];
        List<SBQQ__Quote__c> quotesToUpd = new List<SBQQ__Quote__c>();
        Pricing_Quote_Group__c quoteGrp = [SELECT Id, Name FROM Pricing_Quote_Group__c WHERE Name =: groupName];
        for(SBQQ__Quote__c quote: quoteIdList){
            if(quote.Pricing_Group_Nm__c == null){
                quote.Pricing_Group_Nm__c = quoteGrp.Id;
                quotesToUpd.add(quote);
            }
        }
        quoteRec.Pricing_Group_Nm__c = quoteGrp.Id;
        quotesToUpd.add(quoteRec);
        update quotesToUpd;
        return quoteGrp.Name;
    }
    
    @AuraEnabled
    public static List<QuoteGroupWrapper> removeQuoteLink(Id quoteId, List<String> quoteNbrs){
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c FROM SBQQ__Quote__c WHERE Name IN: quoteNbrs];
        Id quoteGrpId = quoteList[0].Pricing_Group_Nm__c;
        List<SBQQ__Quote__c> quoteGrpRecsToUpd = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quoteRec: quoteList){
            quoteRec.Pricing_Group_Nm__c = null;
            quoteGrpRecsToUpd.add(quoteRec);
        }
        update quoteGrpRecsToUpd;
        List<QuoteGroupWrapper> quoteGroupList = getQuoteGroupDtlsUnlink(quoteId, quoteGrpId);
        return quoteGroupList;
    }
    
    public static List<QuoteGroupWrapper> getQuoteGroupDtlsUnlink(Id quoteId, Id grpId){
        SBQQ__Quote__c quoteRec = [SELECT Id, Name, Pricing_Group_Nm__c FROM SBQQ__Quote__c WHERE Id =: quoteId];
        List<QuoteGroupWrapper> quoteGroupList = new List<QuoteGroupWrapper>();
        if(quoteRec.Pricing_Group_Nm__c != null){
            List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c, Pricing_Group_Nm__r.Id, Pricing_Group_Nm__r.Name, 
                                              Pricing_End_Customer_Name__c, Pricing_End_Customer_Country_Nm__c, 
                                              Pricing_Project_Name_Nm__c, SBQQ__Account__r.Id, SBQQ__Account__r.Name, 
                                              Pricing_Program_Type_Nm__c FROM SBQQ__Quote__c 
                                              WHERE Pricing_Group_Nm__c =: quoteRec.Pricing_Group_Nm__c ORDER BY Name Asc];
            if(quoteList.size()==1){
                Pricing_QuoteGroupUnlinkController unlink = new Pricing_QuoteGroupUnlinkController();
                unlink.getQuoteGroupToDelete(grpId);
            }
            else{
                for(SBQQ__Quote__c quote: quoteList){
                    QuoteGroupWrapper quoteGrpWrap = new QuoteGroupWrapper();
                    quoteGrpWrap.quoteNumber = quote.Name;
                    quoteGrpWrap.groupName = quote.Pricing_Group_Nm__r.Name;
                    quoteGrpWrap.quoteType = quote.Pricing_Program_Type_Nm__c;
                    quoteGrpWrap.endCustomer = quote.Pricing_End_Customer_Name__c;
                    quoteGrpWrap.endCustomerCountry = quote.Pricing_End_Customer_Country_Nm__c;
                    quoteGrpWrap.projectName = quote.Pricing_Project_Name_Nm__c;
                    quoteGrpWrap.quoteNumberUrl = (!isPartnerUser)?(URL.getSalesforceBaseURL().toExternalForm()+'/'+quote.Id):(System.Label.Pricing_Tender_Quote_PartnerUser_URL+quote.Id);
                    quoteGrpWrap.groupNameUrl = (!isPartnerUser)?((quote.Pricing_Group_Nm__r.Id != null)?URL.getSalesforceBaseURL().toExternalForm()+'/'+quote.Pricing_Group_Nm__r.Id:''):((quote.Pricing_Group_Nm__r.Id != null)?System.Label.Pricing_Tender_Quote_Group_PartnerUser_URL+quote.Pricing_Group_Nm__r.Id:'');
                    quoteGroupList.add(quoteGrpWrap);
                }
            }
        }
        else{
            List<SBQQ__Quote__c> quoteGrpRecs = [SELECT Id, Name, Pricing_Group_Nm__c, Pricing_Group_Nm__r.Id, Pricing_Group_Nm__r.Name, 
                                                 Pricing_End_Customer_Name__c, Pricing_End_Customer_Country_Nm__c, 
                                                 Pricing_Project_Name_Nm__c, SBQQ__Account__r.Id, SBQQ__Account__r.Name, 
                                                 Pricing_Program_Type_Nm__c FROM SBQQ__Quote__c 
                                                 WHERE Pricing_Group_Nm__c =: grpId ORDER BY Name Asc];
            if(quoteGrpRecs.size()==0 || quoteGrpRecs.size()==1){
                Pricing_QuoteGroupUnlinkController unlink = new Pricing_QuoteGroupUnlinkController();
                unlink.getQuoteGroupToDelete(grpId);
            }
            else{
                for(SBQQ__Quote__c quoteGrp: quoteGrpRecs){
                    QuoteGroupWrapper quoteGrpWrapDtl = new QuoteGroupWrapper();
                    quoteGrpWrapDtl.quoteNumber = quoteGrp.Name;
                    quoteGrpWrapDtl.groupName = quoteGrp.Pricing_Group_Nm__r.Name;
                    quoteGrpWrapDtl.quoteType = quoteGrp.Pricing_Program_Type_Nm__c;
                    quoteGrpWrapDtl.endCustomer = quoteGrp.Pricing_End_Customer_Name__c;
                    quoteGrpWrapDtl.endCustomerCountry = quoteGrp.Pricing_End_Customer_Country_Nm__c;
                    quoteGrpWrapDtl.projectName = quoteGrp.Pricing_Project_Name_Nm__c;
                    quoteGrpWrapDtl.quoteNumberUrl = (!isPartnerUser)?(URL.getSalesforceBaseURL().toExternalForm()+'/'+quoteGrp.Id):(System.Label.Pricing_Tender_Quote_PartnerUser_URL+quoteGrp.Id);
                    quoteGrpWrapDtl.groupNameUrl = (!isPartnerUser)?((quoteGrp.Pricing_Group_Nm__r.Id != null)?URL.getSalesforceBaseURL().toExternalForm()+'/'+quoteGrp.Pricing_Group_Nm__r.Id:''):((quoteGrp.Pricing_Group_Nm__r.Id != null)?System.Label.Pricing_Tender_Quote_Group_PartnerUser_URL+quoteGrp.Pricing_Group_Nm__r.Id:'');
                    quoteGroupList.add(quoteGrpWrapDtl);
                }
            }
        }
        return quoteGroupList;
    }
    
    @AuraEnabled
    public static String verifyLinkStatus(List<String> quoteNbrs){
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c, Pricing_Group_Nm__r.Name 
                                          FROM SBQQ__Quote__c WHERE Name IN: quoteNbrs];
        Set<String> groupNameSet = new Set<String>();
        String groupName;
        String linkStatus;
        String quoteGroupStatus;
        for(SBQQ__Quote__c quote: quoteList){
            if(quote.Pricing_Group_Nm__r.Name != null){
                groupNameSet.add(quote.Pricing_Group_Nm__r.Name);
            }
        }
        if(groupNameSet.size() > 1){
            linkStatus = 'false';
        }
        else if(groupNameSet.size() == 1){
            for(String grpName: groupNameSet){
                if(grpName != null){
                    groupName = grpName;
                }
            }
        }
        else{
            linkStatus = 'true';
        }
        if(linkStatus != null){
            quoteGroupStatus = linkStatus;
        }
        else if(groupName != null){
            quoteGroupStatus = groupName;
        }
        return quoteGroupStatus;
    }
    
    @AuraEnabled
    public static String getQuoteNumber(Id quoteId){
        return [SELECT Id, Name FROM SBQQ__Quote__c WHERE Id =: quoteId].Name;
    }
    
    @AuraEnabled
    public static List<DataTableColumns> getMetadataColumns(String columnsCategory){
        List<DataTableColumns> lstDataColumns = new List<DataTableColumns>();
        List<string> columnList = new List<string>();
        List<string> fieldAPINameList = new List<string>();
        Pricing_Dynamic_Data_Table__mdt dynamicDataTableMetadata = [SELECT Id, Label, Pricing_Field_Label__c, Pricing_Field_Value__c 
                                                                    FROM Pricing_Dynamic_Data_Table__mdt WHERE Label =: columnsCategory LIMIT 1];
        if(dynamicDataTableMetadata != null) {
            if(dynamicDataTableMetadata.Pricing_Field_Label__c != null) {
                columnList = dynamicDataTableMetadata.Pricing_Field_Label__c.split(',');
            }
            if(dynamicDataTableMetadata.Pricing_Field_Value__c != null) {
                fieldAPINameList = dynamicDataTableMetadata.Pricing_Field_Value__c.split(',');
            }
            if(columnList.size() > 0) {
                for(integer i = 0; i < columnList.size(); i++) {
                    DataTableColumns datacolumn = new DataTableColumns(columnList[i].trim(), 
                                                                       fieldAPINameList[i].substringBefore(':').trim(), 
                                                                       fieldAPINameList[i].substringAfter(':').trim(), 
                                                                       'true');
                    TypeAttributes tyb = new TypeAttributes('_blank');
                    Label lbl = new Label(fieldAPINameList[i].substringBefore(':').trim());
                    tyb.label = lbl;
                    datacolumn.typeAttributes = tyb;
                    lstDataColumns.add(datacolumn);
                }
                return lstDataColumns;
            }
            else {
                return null;
            } 
        } 
        else {
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static boolean getQuoteGroupLinkStatus(Id quoteId){
        try{
        List<SBQQ__Quote__c> quoteRec = [SELECT Id, Pricing_Group_Nm__c FROM SBQQ__Quote__c WHERE Id =: quoteId]; 
        if(quoteRec.size()>0 && quoteRec[0].Pricing_Group_Nm__c != null){
            return true;
        }
        else{
            return false;
        }
        }
        catch(exception ex) {
            Pricing_Tender_Utility.logError(ex);
            return false; 
        }
    }
    
     @AuraEnabled
    public static Boolean isReadOnlyUser() {
        Boolean isReadOnlyUser = Pricing_QuoteTeam_SharingController.isDPMLegalFinanceUser();
        return isReadOnlyUser;
    }
    
    //Wrapper class to return Dynamic DataTable columns
    public class DataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public TypeAttributes typeAttributes {get;set;}
        @AuraEnabled
        public String sortable {get;set;}
        
        public DataTableColumns(String label, String fieldName, String type, String sortable)
        {
            this.label     = label;
            this.fieldName = (fieldName == 'quoteNumber' || fieldName == 'groupName')?fieldName+'Url':fieldName;
            this.type      = type;
            this.sortable = sortable;
        }
    }
    
    public class TypeAttributes{
        @AuraEnabled
        public Label label {get;set;}
        @AuraEnabled
        public String target {get;set;}
        public TypeAttributes(String target){
            this.target = target;
        }
    }
    
    public class Label{
        @AuraEnabled
        public String fieldName {get;set;}
        public Label(String fieldName){
            this.fieldName = fieldName;
        }
    }
    
    public class QuoteDetails {
        @AuraEnabled public String Id {set;get;}
        @AuraEnabled public String quoteNumber {set;get;}
        @AuraEnabled public String groupName {set;get;}
        @AuraEnabled public String quoteType {set;get;}
        @AuraEnabled public String endCustomer {set;get;}
        @AuraEnabled public String endCustomerCountry {set;get;}
        @AuraEnabled public String projectName {set;get;}
        @AuraEnabled public String quoteNumberUrl {set;get;}
        @AuraEnabled public String groupNameUrl {set;get;}
    }
    
    public class QuoteGroupWrapper{
        @AuraEnabled public String quoteNumber {set;get;}
        @AuraEnabled public String groupName {set;get;}
        @AuraEnabled public String quoteType {set;get;}
        @AuraEnabled public String endCustomer {set;get;}
        @AuraEnabled public String endCustomerCountry {set;get;}
        @AuraEnabled public String projectName {set;get;}
        @AuraEnabled public String quoteNumberUrl {set;get;}
        @AuraEnabled public String groupNameUrl {set;get;}
    }
    
    public without sharing class Pricing_QuoteGroupUnlinkController {
        public void getQuoteGroupToDelete(Id grpId){
            Pricing_Quote_Group__c quoteGrp = [SELECT Id, Name FROM Pricing_Quote_Group__c 
                                               WHERE Id =: grpId];
            delete quoteGrp;
        }
    }
}