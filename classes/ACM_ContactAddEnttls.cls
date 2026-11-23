public class ACM_ContactAddEnttls implements Queueable {
    Map<String, Id> entitlementIdMap =new Map<String, Id>();
    List<String> entitlementNames = new List<String>();
    ID newContact;
    Boolean isBulk = false;
    List<Contact> newContact1 = new List<Contact>();
    public ACM_ContactAddEnttls(Map<String, Id> entitlementIdMap,List<String> entitlementNames, ID newContact){
        this.entitlementIdMap = entitlementIdMap;
        this.entitlementNames = entitlementNames;
        this.newContact = newContact;
    }

    public ACM_ContactAddEnttls(List<contact> newContact,boolean isBulk){
        this.isBulk = isBulk;
        this.newContact1 = newContact;
    }
	 public void execute(QueueableContext context)
    {
        
        if(isBulk){
            List<Core_Contact_Entitlement__c> contactEntitlements = new List<Core_Contact_Entitlement__c>();
            List<ID> clist = new List<ID>();
            for(Contact c : newContact1){
                clist.add(c.id);
            }
            for(Core_Contact_Entitlement__c ce : [Select id,Core_From_Source__c,Core_Selected__c,Core_Data_Loaded__c,Core_Status__c from Core_Contact_Entitlement__c where Core_Contact_Id__c in : clist and Core_Category__c != null]){
                    ce.Core_Selected__c = true;
                            ce.Core_Data_Loaded__c = true;
                            ce.Core_Status__c = 'Pending';
                            contactEntitlements.add(ce);
            }
            Database.update(contactEntitlements, false);
        }else {
        List<Core_Contact_Entitlement__c> contactEntitlements = new List<Core_Contact_Entitlement__c>();
        for (String entName : entitlementNames) {
                    if (entitlementIdMap.containsKey(entName)) {
                        contactEntitlements.add(new Core_Contact_Entitlement__c(
                            Core_Contact_Id__c = newContact,
                            Core_Entitlement_Id__c = entitlementIdMap.get(entName),
                            Core_Selected__c = true,
                            Core_From_Source__c = false,
                            Core_Update_Reason__c = 'WOM Email Request',
                            Core_Data_Loaded__c = true,
                            Core_Status__c = 'Pending'
                        ));
                    }
                }

                if (!contactEntitlements.isEmpty()) {
                    Database.insert(contactEntitlements,false);
                }
        }
    }
}