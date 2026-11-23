public class lwcCSVUploaderController {
    
    @AuraEnabled
    public static List<Account> saveFile(String base64Data,String loggedInUserId ) {

			String strIntelContactRecType = 'Intel Contact';
        	List<User> lstLoggedInUser = [SELECT Id, ContactId, Contact.AccountId, Contact.Core_IPA_PartnerRole__c, Core_IPA_One_Partner_Id__c FROM User WHERE Id = : loggedInUserId];
        Id idIntelAccRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(strIntelContactRecType).getRecordTypeId();
        String data = JSON.deserializeUntyped(base64Data).toString();
            System.debug('Heyoo'+ data);

        list<Contact> lstCCToInsert = new list<Contact>();


        list<String> lstCSVLines = data.split('\n');
        


        for(Integer i = 1; i < lstCSVLines.size(); i++){


            Contact acc = new Contact();


            String csvLine = lstCSVLines[i];


            String prevLine = csvLine;
            Integer startIndex;
            Integer endIndex;
            
            while(csvLine.indexOf('"') > -1){
            
                if(startIndex == null){
                    startIndex = csvLine.indexOf('"');
                    csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex+1, csvLine.length());
                }else{
                    if(endIndex == null){
                        endIndex = csvLine.indexOf('"');
                        csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex+1, csvLine.length());
                    }
                }
                
                if(startIndex != null && endIndex != null){
                    String sub = csvLine.substring(startIndex, endIndex);
                    sub = sub.replaceAll(',', ':comma:');
                    csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
                    startIndex = null;
                    endIndex = null;
                }
            }
            
            List<String> csvRowData = new List<String>();


            for(String column : csvLine.split(',')){


                column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');


                csvRowData.add(column);


            }
                    system.debug('Hello'+csvRowData);

            acc.FirstName = csvRowData[0];
            acc.LastName= csvRowData[1];
            acc.Email = csvRowData[2];
            acc.MailingCountry=csvRowData[3];
            acc.Core_Preferred_Language__c=csvRowData[4];
            acc.AccountId=lstLoggedInUser[0].Contact.AccountId;
            acc.Core_IPA_PartnerRole__c = lstLoggedInUser[0].Contact.Core_IPA_PartnerRole__c;
            acc.RecordTypeId = idIntelAccRecId;


            lstCCToInsert.add(acc);
        }


        
        insert lstCCToInsert;



        return [Select Id, Name, Website,Phone  From Account Where CreatedDate>=:Date.TODAY()];
    }



}