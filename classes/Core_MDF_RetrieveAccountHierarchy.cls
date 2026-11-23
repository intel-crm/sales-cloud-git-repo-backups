public with sharing class Core_MDF_RetrieveAccountHierarchy {
    
    public class Item {

        public string label;
        public string name;
        public boolean expanded;
        public string id;
        public List<Item> items;
    }
 
    @AuraEnabled
    public static String getAccountHierachy(){

        string accountId = '001g000002AT2MVAA1'; 
        string programId = '0Pkg00000008OTTCA2';
        


        List<Item> accountHierachy = new List<Item>();
        List<Account> accounts = [select id, name, Core_MDF_Parent_Fund_Account__c  from Account where Core_MDF_CoMarketing_Ultimate_Account__c = :accountId and Core_MDF_Channel_Program__c = :programId];
        
        //Get first level account
        for (Account acc : accounts) {

            if(acc.Core_MDF_Parent_Fund_Account__c == accountId){
                Item item0 = new Item();
                item0.label = acc.name;
                item0.name = acc.name;
                item0.id = acc.id;
                item0.expanded = true;
                item0.items = new List<Item>(); 
                System.debug('First Level' + item0.Id + ' name ' + acc.name);
                //Get the next level
                for (Account accLevel1 : accounts) {

                    if(accLevel1.Core_MDF_Parent_Fund_Account__c == item0.Id){
                     System.debug('Second Level' + accLevel1.Id + ' name ' + accLevel1.name);
                        Item item1 = new Item();
                        item1.label = accLevel1.name;
                        item1.name = accLevel1.name;
                        item1.id = accLevel1.id;
                        item1.expanded = true;
                        item1.items = new List<Item>(); 
                        
                        for (Account accLevel2 : accounts) {
                        
                            if(accLevel2.Core_MDF_Parent_Fund_Account__c == item1.Id){
                                System.debug('Third Level' + accLevel2.Id + ' name ' + accLevel2.name);
                                Item item2 = new Item();
                                item2.label = accLevel2.name;
                                item2.name = accLevel2.name;
                                item2.id = accLevel2.id;
                                item2.expanded = true;
                                item1.items.add(item2);
                            }
                        }
                        item0.items.add(item1);//Add at the end
                    }       
                     
                    }
                    System.debug('Adding'); 
                    accountHierachy.add(item0);//Add at the end        
            }
        }
        //System.debug('Final Output' + JSON.serialize(accountHierachy));
        return  JSON.serialize(accountHierachy);
    }

}