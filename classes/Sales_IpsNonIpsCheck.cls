@isTest
public without sharing class Sales_IpsNonIpsCheck {
    /*public class ComputerInput {
        @InvocableVariable
        public String ContactId;
      }
      public class ComputerOutput {
        @InvocableVariable
        public String supportlinkIps;
           @InvocableVariable
        public String errorMsgIps;
            @InvocableVariable
        public boolean IpsNonIpsCheck;
    }
    @InvocableMethod(label='Ips Non Ips Check')
    public static List<ComputerOutput> createComputerDetails(List<ComputerInput> computerInputs) {
          String contactId;
          //boolean check=false;
          List<ComputerOutput> outputData = new List<ComputerOutput>();
          for (ComputerInput compInput : computerInputs) {
               contactId=compInput.ContactId;
          }
              
                Contact con = [SELECT Id,Core_IPS_Active__c from contact where Id =:contactId];
         for (ComputerInput compInput : computerInputs) {
             ComputerOutput output = new ComputerOutput();
              if(con.Core_IPS_Active__c==true){
                  output.supportlinkIps=System.Label.Sales_URL_IPS_User;
                  output.IpsNonIpsCheck=true;
              }
              else{
                   output.errorMsgIps=System.Label.Sales_Ips_Error_Message;
                  output.IpsNonIpsCheck=false;
              }
              outputData.add(output);
          }
        return outputData;
    }*/
}