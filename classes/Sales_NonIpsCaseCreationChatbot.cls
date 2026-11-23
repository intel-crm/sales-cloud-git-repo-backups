public without sharing class Sales_NonIpsCaseCreationChatbot {
 public class ContactInput {
        @InvocableVariable
      public String scontId;
    }
    @InvocableMethod(label='Find License Issue Details')
    public static list<List<pickListWrapper>> fetchNonIPSCaseCreation(List<ContactInput> contactId){
         List<List<pickListWrapper>> listLic = new List<List<pickListWrapper>>();
         List<pickListWrapper> tempWrapperList =new List<pickListWrapper>();
        for(Sales_Non_IPS_Service__mdt temp: [SELECT Id,Type_of_License_Issue__c FROM Sales_Non_IPS_Service__mdt  where Active__c = true order by Type_of_License_Issue__c]){
           pickListWrapper optionlist = new pickListWrapper();
            optionlist.label=temp.Type_of_License_Issue__c;
            optionlist.value=temp.Type_of_License_Issue__c;
            tempWrapperList.add(optionlist);
           
        }
        listLic.add(tempWrapperList);
         return listLic;
    }
       public without sharing class pickListWrapper{
        @InvocableVariable public  String label;
        @InvocableVariable public  String value;
    }
}