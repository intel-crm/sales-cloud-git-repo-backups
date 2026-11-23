public class Summer23 {
    
    //OLD WAY ->system.label.labelName
	//NEW WAY-> label.get(null,labelName,translation)
   
    public void checknewfeature()
    {
       	system.debug('Label 23 release'+system.label.get('','Core_Oppty_No_of_Days'));//empty to follow the or namespace
    	system.debug('Release Translation'+system.label.translationexists('','Core_Oppty_No_of_Days','de'));
        
        //Use the iterable feature with set
        set<String> letters = new set<String>{'a','b','c','d'};
        system.debug(String.join(letters,'+'));
    }
	
	
}