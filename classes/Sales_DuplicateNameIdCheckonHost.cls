public  without sharing class Sales_DuplicateNameIdCheckonHost {
    public class ContactInput {
        @InvocableVariable
        public String scontactId;
        @InvocableVariable
        public String computername;
        @InvocableVariable
        public String computerid;
    }
    public class ComputerOutput {
        @InvocableVariable
        public String message ;
    }
    @InvocableMethod(label='Duplicate Host check in Chatbot')
    public static List<ComputerOutput> getHostDetails(List<ContactInput> inputs){
        Set<String> primaryAdminIdSet = new Set<String>();
        String ComputerName;
        String ComputerId;
        Map<String, String> mapofInputs = new map<String, String>();
        Boolean flag=false;
        for(ContactInput c : inputs){
            ComputerName= c.computername;
            ComputerId=c.computerid;
            mapofInputs.put(ComputerId, ComputerName);
            primaryAdminIdSet.add(c.scontactId);
        }
        for(Sales_License_Admin_Delegate__c licAdmin : [Select Id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_DlgAdmin_Contact__c from Sales_License_Admin_Delegate__c where Sales_License_DlgAdmin_Contact__c IN:primaryAdminIdSet and Sales_License_isActive__c=true]){
            primaryAdminIdSet.add(licAdmin.Sales_License_PrimaryAdmin_Contact__c);
        }
        if(primaryAdminIdSet.size() > 0){
            for(Sales_Host__c hostObj : [Select Id,Sales_Contact__c,Sales_isActiveHost__c,(Select Id From Licenses__r  LIMIT 1),Sales_License_Type__c,Sales_Computer_Type__c,Sales_Computer_Name_Txt__c,Name from Sales_Host__c WHERE Sales_isActiveHost__c = true AND Sales_Contact__c IN:primaryAdminIdSet order by CreatedDate desc]){
                if(hostObj.Sales_Computer_Name_Txt__c == ComputerName || hostObj.Name == ComputerId) {
                    flag=true;
                    break;
                }    
            }
        }
        List<ComputerOutput> computeroutput = new List<ComputerOutput>();        
        if(flag==true)
        {
            ComputerOutput output=new ComputerOutput();
            output.message='Duplicate is present';
            computeroutput.add(output);
        }
        return computeroutput;
    }
}