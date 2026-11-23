public class UCD_AccountXWalkOnMergeQueueable implements Queueable, Database.AllowsCallouts {
    private Map<Id, String> accMap;
    private Map<Id, List<Id>> cwlIdMap;
    private Map<Id, List<Id>> cpeIdMap;

    // Constructor
    public UCD_AccountXWalkOnMergeQueueable(Map<Id, String> accMap, Map<Id, List<Id>> cwlIdMap, Map<Id, List<Id>> cpeIdMap) {
        this.accMap = accMap;
        this.cwlIdMap = cwlIdMap;
        this.cpeIdMap = cpeIdMap;
    }

    // Execute method (runs the callouts)
    public void execute(QueueableContext context) {
        for (Id acc : accMap.keySet()) {
            UCD_ACM_AccountDeactivationService acctRelitoService = new UCD_ACM_AccountDeactivationService();

            // First API Call
            try {
                acctRelitoService.removeAcctXWalk(accMap.get(acc), acc, 'DEACTIVATE');
            } catch (Exception e) {
                System.debug('Error in removeAcctXWalk for ' + acc + ': ' + e.getMessage());
            }

            // Second API Call
            if (cwlIdMap.containsKey(acc) && cwlIdMap.get(acc) != null) {
                try {
                    acctRelitoService.removeCWLXWalk(accMap.get(acc), 'DEACTIVATE', new Set<Id>(cwlIdMap.get(acc)));
                } catch (Exception e) {
                    System.debug('Error in removeCWLXWalk for ' + acc + ': ' + e.getMessage());
                }
            }

            // Third API Call
            if (cpeIdMap.containsKey(acc) && cpeIdMap.get(acc) != null) {
                try {
                    acctRelitoService.removeCPEXWalk(accMap.get(acc), 'DEACTIVATE', new Set<Id>(cpeIdMap.get(acc)));
                } catch (Exception e) {
                    System.debug('Error in removeCPEXWalk for ' + acc + ': ' + e.getMessage());
                }
            }
        }
    }
}