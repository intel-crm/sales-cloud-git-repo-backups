public without sharing class Sales_ContactCustomerAdditionalInfo {
    public class ComputerInput {
        @InvocableVariable
        public String PoNo;
        @InvocableVariable
        public String LacSerialNo;
        @InvocableVariable
        public String HostId;
        @InvocableVariable
        public String ProdName;
        @InvocableVariable
        public String ContactId;
    }
    public class ComputerOutput {
        @InvocableVariable
        public String isSuccess;
    }
    @InvocableMethod(label='Additional Info case creation')
    public static List<ComputerOutput> additionalInfo(List<ComputerInput> computerInputs) {
        String PoNumber,LacSerialNo,HostId;
        String returnMsg='';
        boolean Check=false;
        List<Order> orderList = new List<Order>();
        List<Sales_License__c> licenseList = new List<Sales_License__c>();
        List<Sales_Host__c> hostList = new List<Sales_Host__c>();
        for (ComputerInput compInput : computerInputs) {
            PoNumber=compInput.PoNo;
            LacSerialNo=compInput.LacSerialNo;
            HostId=compInput.HostId;
        }
        if(PoNumber!=null){
            orderList = new List<Order>([SELECT Id from Order where Sales_PO_Number_Txt__c =:PoNumber]);
            if(!orderList.isEmpty()){
                Check=true;
            }
        }
        if(LacSerialNo!=null){
            licenseList = new List<Sales_License__c>([SELECT Id from Sales_License__c where Sales_License_Activation_Code__c =:LacSerialNo]); 
            if(!licenseList.isEmpty()){
                Check=true;
            }
        }
        if(HostId!=null){
            hostList = new List<Sales_Host__c>([SELECT Id from Sales_Host__c where Temporary_NIC_ID__c=: hostid OR Name=:hostid]);
            if(!hostList.isEmpty()){
                Check=true;
            }
        }
        List<ComputerOutput> computeroutput = new List<ComputerOutput>();        
        ComputerOutput output = new ComputerOutput();
        if(Check==true){
            returnMsg='sucesss';
        }
        else{
            returnMsg='failure';
        }
        output.isSuccess = returnMsg;
        computeroutput.add(output);
        return computeroutput;
    }
}