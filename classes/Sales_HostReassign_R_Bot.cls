public with sharing class Sales_HostReassign_R_Bot {
    public class HostOutput {
        @InvocableVariable
        public String outputString;
    }
    public class ComputerInput { 
        @InvocableVariable
        public Sales_Host__c selecthostObject;
        @InvocableVariable
        public Sales_Host__c newhosttoassign;
    }
    @InvocableMethod(label = 'Create Computer rehosting')
    public static List < HostOutput > createComputerDetails(List < ComputerInput > computerInputs) {
        Integer isValidcheck = 0;
        Set < Id > hostIdsInput = new Set < Id > (); 
        Map < Id, Sales_Host__c > mapOfHostIdComputerInpts = new Map < Id, Sales_Host__c > ();
        Map < Id, String > mapOfHostObj = new Map < Id, String > ();
        Map < String, Sales_Host__c > mapOfHostNameHostObject = new Map < String, Sales_Host__c > ();
        
        for (ComputerInput compInput: computerInputs) {
            mapOfHostIdComputerInpts.put(compInput.selecthostObject.id, compInput.selecthostObject);
            hostIdsInput.add(compInput.newhosttoassign.id);
        }
        
        List < Sales_License__c > licenseList = [SELECT Id, Name, Sales_License_Avbl_Rehost_Nbr__c, Sales_License_Host_Node_Id__c, Sales_License_Activation_Code__c, Sales_Tool_License_Type__c
                                                 FROM Sales_License__c where Sales_License_Host_Node_Id__c in: mapOfHostIdComputerInpts.keySet() and Sales_License_Web_Display_Flag__c = true and Sales_License_Type__c != 'Optional'
                                                ];
        
        List<Sales_Host__c> hostList = [SELECT Id, Name FROM Sales_Host__c WHERE Id IN: hostIdsInput];
        if (licenseList.size() > 0) {
            for (Sales_License__c lc: licenseList) {
                
                Sales_Host__c hostObj = new Sales_Host__c();
                for (Sales_Host__c host: hostList) {
                    hostObj.id = host.id;
                }
                if (!mapOfHostNameHostObject.containskey(hostObj.Name)) {
                    mapOfHostNameHostObject.put(hostObj.Name, hostObj);
                }
                mapOfHostObj.put(lc.id, hostObj.Name);
            }
        }
        List < HostOutput > outList = new List < HostOutput > ();
        HostOutput ot = new HostOutput();
        List < Sales_License__c > licenseToBeUpdatedList = new List < Sales_License__c > ();
        for (Sales_License__c lc: [SELECT Id, Name, Sales_License_Avbl_Rehost_Nbr__c, Sales_License_Host_Node_Id__c, Sales_License_Activation_Code__c, Sales_Tool_License_Type__c
                                   FROM Sales_License__c where Sales_License_Host_Node_Id__c in: hostIdsInput and Sales_License_Web_Display_Flag__c = true and Sales_License_Type__c != 'Optional']) {
                                       if (lc.Sales_License_Avbl_Rehost_Nbr__c > 0) {
                                           isValidcheck = isValidcheck + 1;
                                       } else if (lc.Sales_License_Avbl_Rehost_Nbr__c == 0) {
                                           ot.outputString = 'Available rehost Quantity is zero. Please contact support for increasing the Quantity'; 
                                       } else if (lc.Sales_License_Avbl_Rehost_Nbr__c < 0) {
                                           ot.outputString = 'Available rehost Quantity is not valid. Please contact support for increasing the Quantity'; 
                                       }
                                   }
        if (isValidcheck >= 1) {
            for (Sales_License__c licenseItem: licenseList) {
                licenseItem.Sales_License_Host_Node_Id__c = mapOfHostNameHostObject.get(mapOfHostObj.get(licenseItem.Id)).id; 
                licenseItem.Sales_License_Status__c = 'Licensed';
                licenseItem.Sales_License_Avbl_Qty_Nbr__c = 0;
                licenseToBeUpdatedList.add(licenseItem);
            }
        }
        if (licenseToBeUpdatedList.size() > 0) {
            update licenseToBeUpdatedList; 
            ot.outputString = 'You have successfully assigned a host';
        }
        outList.add(ot);
        return outList;
    }
}