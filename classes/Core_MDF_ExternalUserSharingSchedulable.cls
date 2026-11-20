public without sharing class Core_MDF_ExternalUserSharingSchedulable implements Schedulable{

    public Set<String> userOrGroupIdSet = new Set<String>(); 
    public Integer counter;

    public Core_MDF_ExternalUserSharingSchedulable(Set<String> userOrGroupIdSet,Integer counter){
        this.userOrGroupIdSet = userOrGroupIdSet;
        this.counter = counter;
    }

    public void execute(SchedulableContext SC) {
        
        Core_MDF_ExternalUserSharing batchinstance = new Core_MDF_ExternalUserSharing(true,userOrGroupIdSet,counter);
        Database.executeBatch(batchinstance);
    }
}