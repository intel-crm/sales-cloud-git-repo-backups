public virtual class testTriggerHandler {

    /************* INTEL CODE **************/
    // Collections for optional consolidated DML at the end of trigger execution
    public static List<sObject>   sObjectsToInsert = new List<sObject>();
    public static Map<Id,sObject> sObjectsToUpdate = new Map<Id,sObject>();
    public static Map<Id,sObject> sObjectsToDelete = new Map<Id,sObject>();
    private static Boolean consolidatedDMLDone = false;
    /************* /INTEL CODE *************/
    
    // static map of handlername, times run() was invoked
    private static Map<String, LoopCount> loopCountMap;
    private static Set<String> bypassedHandlers;
    
    // the current context of the trigger, overridable in tests
    @TestVisible
    private TriggerContext context;
    
    // the current context of the trigger, overridable in tests
    @TestVisible
    private Boolean isTriggerExecuting;
    
    // static initialization
    static {
        loopCountMap = new Map<String, LoopCount>();
        bypassedHandlers = new Set<String>();
    }
    
    // constructor
    public testTriggerHandler() {
        this.setTriggerContext();
    }

    /***************************************
    * public instance methods
    ***************************************/
    
    // main method that will be called during execution
    public void run() {
        system.debug('TriggerHandler -inside run()');
        // dispatch to the correct handler method
        if(this.context == TriggerContext.BEFORE_INSERT) {
            system.debug('TriggerHandler - Before Insert==>@@');
            this.beforeInsert();
        } else if(this.context == TriggerContext.BEFORE_UPDATE) {
            system.debug('TriggerHandler - Before update==>@@');
            this.beforeUpdate();
        } else if(this.context == TriggerContext.BEFORE_DELETE) {
            system.debug('TriggerHandler - Before Delete==>@@');
            this.beforeDelete();
        } else if(this.context == TriggerContext.AFTER_INSERT) {
            system.debug('TriggerHandler - After Insert==>@@');
            this.afterInsert();
        } else if(this.context == TriggerContext.AFTER_UPDATE) {
            system.debug('TriggerHandler - After update==>@@');
            this.afterUpdate();
        } else if(this.context == TriggerContext.AFTER_DELETE) {
            system.debug('TriggerHandler - After Delete==>@@');
            this.afterDelete();
        } else if(this.context == TriggerContext.AFTER_UNDELETE) {
            system.debug('TriggerHandler - After UnDelete==>@@');
            this.afterUndelete();
        }
        
        /************* INTEL CODE **************/
        performConsolidatedDML();
        /************* /INTEL CODE *************/
    }

    
    
    public void clearMaxLoopCount() {
    }
    
    /***************************************
    * public static methods
    ***************************************/
    

    
   
    
    /************* INTEL CODE **************/
    public static Boolean isActive(String functionalityName) {
        
        // Note: querying custom metadata is faster than normal SOQL, since it's cached,
        // and it doesn't count towards SOQL limits
        List<Trigger_Execution__mdt> executionEntries = [
            select Active__c, Inactive_for_Profile__c, Inactive_for_User__c
            from Trigger_Execution__mdt
            where DeveloperName = :functionalityName limit 1];
        
        // Check for trigger execution entry
        if (!executionEntries.isEmpty()) {
            // Check to see if the trigger functionality is active
            if (executionEntries[0].Active__c == true) {
                // Check for the user override to make it inactive for this profile or user
                if ((executionEntries[0].Inactive_for_Profile__c == UserInfo.getProfileId()) ||
                    (executionEntries[0].Inactive_for_User__c == UserInfo.getUserId())) {
                    return false;
                }
                // Trigger is on and not inactive for this user
                else return true;
            }
            // Trigger is inactive
            else return false;
        }
        // No trigger execution entry
        else return false;
    }
    /************* /INTEL CODE *************/

    /***************************************
    * private instancemethods
    ***************************************/
    
    @TestVisible
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    }
    
    @TestVisible
    private void setTriggerContext(String ctx, Boolean testMode) {
        if(!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        } else {
            this.isTriggerExecuting = true;
        }
    
        if((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
           (ctx != null && ctx == 'before insert')) {
               this.context = TriggerContext.BEFORE_INSERT;
           }
        else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
                (ctx != null && ctx == 'before update')) {
                    this.context = TriggerContext.BEFORE_UPDATE;
                }
        else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
                (ctx != null && ctx == 'before delete')) {
                    this.context = TriggerContext.BEFORE_DELETE;
                }
        else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
                (ctx != null && ctx == 'after insert')) {
                    this.context = TriggerContext.AFTER_INSERT;
                }
        else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
                (ctx != null && ctx == 'after update')) {
                    this.context = TriggerContext.AFTER_UPDATE;
                }
        else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
                (ctx != null && ctx == 'after delete')) {
                    this.context = TriggerContext.AFTER_DELETE;
                }
        else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
                (ctx != null && ctx == 'after undelete')) {
                    this.context = TriggerContext.AFTER_UNDELETE;
                }
    }
    
    // increment the loop count


    // make sure this trigger should continue to run

    
    @TestVisible
    private String getHandlerName() {
        return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }
    
    /************* INTEL CODE **************/
    @TestVisible
    private void performConsolidatedDML() {
        
        if (!consolidatedDMLDone) {
            consolidatedDMLDone = true;
            
            // Perform any inserts, updates, and deletes, if we have any records
            if (sObjectsToInsert.size() > 0) {
                insert sObjectsToInsert;
            }
            if (sObjectsToUpdate.size() > 0) {
                update sObjectsToUpdate.values();
            }
            if (sObjectsToDelete.size() > 0) {
                delete sObjectsToDelete.values();
            }
        }
    }
    /************* /INTEL CODE *************/

    /***************************************
    * context methods
    ***************************************/
    
    // context-specific methods for override
    @TestVisible
    protected virtual void beforeInsert(){}
    @TestVisible
    protected virtual void beforeUpdate(){}
    @TestVisible
    protected virtual void beforeDelete(){}
    @TestVisible
    protected virtual void afterInsert(){}
    @TestVisible
    protected virtual void afterUpdate(){}
    @TestVisible
    protected virtual void afterDelete(){}
    @TestVisible
    protected virtual void afterUndelete(){}
    
    /***************************************
    * inner classes
    ***************************************/

    // inner class for managing the loop count per handler
    @TestVisible
    private class LoopCount {
        private Integer max;
        private Integer count;
        
        public LoopCount() {
            this.max = 5;
            this.count = 0;
        }
        
        public LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
        }
        
        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }
        
        public Boolean exceeded() {
            if(this.max < 0) return false;
            if(this.count > this.max) {
                return true;
            }
            return false;
        }
        
        public Integer getMax() {
            return this.max;
        }
        
        public Integer getCount() {
            return this.count;
        }
        
        public void setMax(Integer max) {
            this.max = max;
        }
    }
    
    // possible trigger contexts
    @TestVisible
    private enum TriggerContext {
        BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
            AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
            AFTER_UNDELETE
            }
    
    // exception class
    public class TriggerHandlerException extends Exception {}
    
}