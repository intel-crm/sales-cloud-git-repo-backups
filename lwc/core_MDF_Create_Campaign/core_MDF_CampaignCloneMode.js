import { LightningElement, track, wire, api } from 'lwc';     
    
export default function checkHelpervalididty(template){
    
    var allTextAreaValid = [...template.querySelectorAll('lightning-textarea')]
    .reduce((validSoFar, inputCmp) => {
        console.log('data from helper')
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
    }, true); 
            
        
}