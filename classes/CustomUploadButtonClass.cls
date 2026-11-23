public with sharing class CustomUploadButtonClass {
    
    public static Map<String, String> countryRegionMap = new Map<String, String>();
	public static Map<String, String> preferedLanguageMap = new Map<String, String>();
    
    @AuraEnabled
    public static boolean readCSVFile(Id idContentDocument){
        list<Contact> lstContToInsert = new list<Contact>();
		System.debug('Docu Id'+ idContentDocument);
        //ID contactId = [Select ContactId from User where id =: Userinfo.getUserid()].ContactId;
        //ID AccID  = [Select AccountID from Contact where id =: contactId].AccountId;
        if(idContentDocument != null) {
            
            // getting File Data based on document id 
            ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument];
            // split the file data
            list<String> lstCSVLines = objVersion.VersionData.toString().split('\n');

            System.debug('Object Version'+objVersion);
            System.debug('lstCSVLines'+lstCSVLines);
            for(Integer i = 1; i < lstCSVLines.size(); i++){
                Contact objCont = new Contact();
                list<String> csvRowData = lstCSVLines[i].split(',');
                System.debug('csvRowData====> '+csvRowData);
                objCont.FirstName = csvRowData[0];
                objCont.LastName = csvRowData[1];
                objCont.Email = csvRowData[2];
                //objCont.AccountID = AccID;
                lstContToInsert.add(objCont);
            }

            try{
                if(!lstContToInsert.isEmpty()) {
                    insert lstContToInsert;
                    return true;
                }
            }
            catch (Exception ex) {
                throw new AuraHandledException(ex.getMessage());
                
            } 
        }
        return false;
    }

    @AuraEnabled
    public static boolean getData(Object jsonResponce){
        String str = JSON.serialize(jsonResponce);
        pickValueAssignment();
        CustomUploadButtonClass cubObj = new CustomUploadButtonClass();
        CustomUploadButtonClass.DataSetWrapper setWrapper = (CustomUploadButtonClass.DataSetWrapper) JSON.deserialize('{"data":'+str+'}', CustomUploadButtonClass.DataSetWrapper.class);
        system.debug(countryRegionMap);
        system.debug(preferedLanguageMap);
        return true;
    }
    
    public static void pickValueAssignment(){        
        Schema.DescribeFieldResult fieldResult = Contact.Core_Country_Region__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
            countryRegionMap.put(f.getLabel(), f.getValue());
        }
        
        fieldResult = Contact.Core_Preferred_Language__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
            preferedLanguageMap.put(f.getLabel(), f.getValue());
        }
    }
    
    public class DataSetWrapper{
        List<DataSet> data {set;get;}
    }
    
    public class DataSet{
        public String Firstname {set;get;}
        public String Lastname {set;get;}
        public String Email {set;get;}
        public String CountryRegion {set;get;}
        public String PreferredLanguage {set;get;}
    }

}