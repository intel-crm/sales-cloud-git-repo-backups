public class PendingApprovalNotifier implements Schedulable {

    public void execute(SchedulableContext sc) {

        List<ProcessInstance> pendingApprovals = [
            SELECT Id, TargetObjectId, CreatedDate,
                   (SELECT Id, ActorId, StepStatus FROM Steps WHERE StepStatus = 'Pending') 
            FROM ProcessInstance 
            WHERE Status = 'Pending' 
            AND CreatedDate <= :DateTime.now().addHours(-1)  // 1 hours ago
        ];
        ProcessInstance processInstance = pendingApprovals[0];
        List<ProcessInstanceStep> instanceSteps = [SELECT Id, StepStatus, ActorId
                                                       FROM ProcessInstanceStep
                                                       WHERE ProcessInstanceId = :processInstance.Id
                                                       AND StepStatus = 'Pending'];
        
    }
}