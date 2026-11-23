({
	getSentiments : function(cmp, event, helper) {
		var txt = document.getElementById( "txtTextToAnalyse" ).value;
        var getSentiment = cmp.get('c.findSentiment');
        getSentiment.setParams({
            text: txt
        });
        getSentiment.setCallback(this, 
            function(response) {
            	var state = response.getState();           
            	if (cmp.isValid() && state === "SUCCESS") {
	                var result = response.getReturnValue();
                    var positive;
                    var negative;
                    var neutral;
                    
                    for(var i=0; i < result.probabilities.length;i++ ){
                        var label =  result.probabilities[i].label;
                        var probability =  result.probabilities[i].probability;
                        if(label == 'positive'){
                            positive = probability;
                        }else if(label == 'negative'){
                            negative = probability;
                        }else if(label == 'neutral'){
                            neutral = probability;
                        }
                    }
                    var sentiment = ""; 
					if( negative > positive && negative > neutral ) { 
                                sentiment = "Sorry! Einstein says it's Negative."; 
                     } else if( positive > negative && positive > neutral ) { 
                                sentiment = "Yay! Einstein says it's Positive."; 
					 } else { 
                                sentiment = "Oopsie! That kinda looks Neutral."; 
                     } 
                     alert( sentiment );                    
					console.log('###result###'+ JSON.stringify(result.probabilities));
                    cmp.set("v.isSpinner", false);
                }
            }
        );
        $A.enqueueAction(getSentiment);
	}
})