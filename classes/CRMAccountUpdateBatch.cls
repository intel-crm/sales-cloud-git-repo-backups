public class CRMAccountUpdateBatch implements Database.Batchable<sObject> {

    public List<Id> ACCLIST = new List<Id>();

    public CRMAccountUpdateBatch(List<Id> acclist)

    {

        this.ACCLIST = acclist;

    }

    public class FlowInputs {

        @InvocableVariable public List<Id> accId;

    }

    @invocablemethod

    public static void accUpdate(List<FlowInputs> requests)

    {

        List<Id> acclist = new List<Id>();

        for(FlowInputs req : requests)   

        {

            acclist.addAll(req.accId);

        }

        Id jobId = Database.executeBatch(new CRMAccountUpdateBatch(acclist));

    }

   public Database.QueryLocator start(Database.BatchableContext BC){

      String query = 'SELECT ID, Name FROM Account WHERE ID IN : ACCLIST';

      return Database.getQueryLocator(query);

   }

    public void execute(Database.BatchableContext BC , List<Sobject> scope){
	
	List<Account> accUpdateList = new List<Account>();

        for(Account acc : (List<Account>)scope) {

            accUpdateList.add(acc);

        }
		
		try{
			update accUpdateList;
		}
		catch(Exception e){
			system.debug('Exception occured'+e);
		}
		

   }

   public void finish(Database.BatchableContext BC){

   }

}