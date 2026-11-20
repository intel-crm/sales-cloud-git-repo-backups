/*****************************************************************************************************
Class Name          :    Core_MDF_IUPGMReqStaging_Queueable
Test Class Name     :    Core_MDF_IUPGMReqStaging_Queueable_Test
Description         :    Queueable dispatcher for the IUPGM staging pipeline. It routes staging
                         records to the correct asynchronous processing branch and preserves a
                         single child enqueue per transaction.
Created By          :    Ramapriya
******************************************************************************************************/
public class Core_MDF_IUPGMReqStaging_Queueable implements Queueable {

    public enum Operation {
        INITIATE,      // new staging records → gate evaluation
        USER_CREATED,  // AGS confirmed user creation → request permission set
        PS_APPROVED    // AGS approved permission set → create/update IUPGM
    }

    private final Map<Operation, Set<Id>> opToIds;

    /** Creates a single-operation queueable for backward-compatible callers. */
    public Core_MDF_IUPGMReqStaging_Queueable(Set<Id> ids, Operation op) {
        this.opToIds = new Map<Operation, Set<Id>>{ op => ids };
    }
    /** Creates a multi-operation queueable used by the trigger handler. */
    public Core_MDF_IUPGMReqStaging_Queueable(Map<Operation, Set<Id>> opToIds) {
        this.opToIds = opToIds;
    }
/******************************************************************************************************
    Method Name:        execute
    Description:        Executes queued operations in deterministic order.
    Added By:           Ramapriya
    *******************************************************************************************************/
    
    public void execute(QueueableContext ctx) {
        
        if (opToIds == null || opToIds.isEmpty()) return;

        
        processOp(Operation.INITIATE);
        processOp(Operation.USER_CREATED);
        processOp(Operation.PS_APPROVED);
    }

    /** Dispatches one queued operation to the matching service handler method. */
    private void processOp(Operation op) {
        if (!opToIds.containsKey(op)) return;
        Set<Id> ids = opToIds.get(op);
        if (ids == null || ids.isEmpty()) return;

        switch on op {
            when INITIATE    { Core_MDF_IUPGMReqStaging_ServiceHandler.initiateAsync(ids); }
            when USER_CREATED{ Core_MDF_IUPGMReqStaging_ServiceHandler.handleUserCreatedAsync(ids); }
            when PS_APPROVED { Core_MDF_IUPGMReqStaging_ServiceHandler.handlePSApprovedAsync(ids); }
        }
    }
}