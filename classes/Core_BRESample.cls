public class Core_BRESample {
 public void BRECall ()
 {
     // Creating a custom action named 'Base_Application_Fee' associated with the Apex class 'DecisionMatrixController'
    Invocable.Action action = Invocable.Action.createCustomAction('Base_Application_Fee', 'DecisionMatrixController');
    
    // Setting parameters for the action
    action.setInvocationParameter('input1', 'Event');
    action.setInvocationParameter('input2', 'License');
    
    // Invoking the action and storing the results
    List<Invocable.Action.Result> results = action.invoke();
 }
}